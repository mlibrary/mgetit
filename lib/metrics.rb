require "yaml"
require "erb"
require "logger"
require "prometheus/middleware/collector"
require "active_support/notifications"

module Metrics
  module NoOpMetric
    def self.increment(*)
    end

    def self.observe(*)
    end
  end

  class Middleware < Prometheus::Middleware::Collector
    KNOWN_PATHS = ["/citation-linker", "/assets", "/favicon.ico"]
    APP_PATHS = ["/resolve", "/go", "/link_router"]

    protected

    def init_request_metrics
      requests_name = :"#{@metrics_prefix}_requests_total"
      durations_name = :"#{@metrics_prefix}_request_duration_seconds"
      @requests = @registry.get(requests_name) || NoOpMetric
      @durations = @registry.get(durations_name) || NoOpMetric
    end

    def init_exception_metrics
      exceptions_name = :"#{@metrics_prefix}_exceptions_total"
      @exceptions = @registry.get(exceptions_name) || NoOpMetric
    end

    def strip_ids_from_path(path)
      p = super
      return "/known-path" if KNOWN_PATHS.any? { |known_path| p.start_with?(known_path) }
      return "/not-a-path" unless APP_PATHS.any? { |app_path| p.start_with?(app_path) }
      p.gsub(%r{/go/[^/]+}, "/go/:id").gsub(%r{/link_router/index/[^/]+}, "/link_router/index/:id")
    end
  end

  class << self
    def load_config(filename = "config/metrics.yml")
      config = YAML.load(ERB.new(File.read(filename)).result)
      configure_data_store(config["data_store"])
      configure_metrics(config["metrics"])
      configure_puma_variables(config["puma"])
      configure_subscriptions(config["subscriptions"])
      configure_logger(config["logger"])
      Yabeda.configure!
    end

    def configure_puma(puma)
      puma.activate_control_app(@control_app_url, @control_app_token)
      puma.plugin :yabeda
      puma.plugin :yabeda_prometheus
      puma.prometheus_exporter_url(@prometheus_exporter_url)
      puma.on_worker_boot do
        uri = URI(@prometheus_exporter_url)
        ObjectSpace.each_object(TCPServer).each do |server|
          next if server.closed?
          family, port, host, _ = server.addr
          if family == "AF_INET" && port == uri.port && host == uri.host
            server.close
          end
        end
      end
      if @data_store_dir
        puma.on_prometheus_exporter_boot do
          Dir[File.join(@data_store_dir, "*.bin")].each do |file_path|
            next if file_path.end_with?("___#{$$}.bin")
            File.unlink(file_path)
          end
        end
        puma.on_worker_shutdown do
          Dir[File.join(@data_store_dir, "*___#{$$}.bin")].each do |file_path|
            File.unlink(file_path)
          end
        end
      end
    end

    def registry
      Prometheus::Client.registry
    end

    def results_count_bucketing(count)
      count = count.to_i
      return "<10" if count < 10
      return "10" if count == 10
      return "11-29" if count < 30
      return "30" if count == 30
      return ">30"
    end

    attr_reader :logger

    private

    def configure_logger(config)
      severity = case config["level"]
      when "warn"
        Logger::WARN
      when "info"
        Logger::INFO
      when "debug"
        Logger::DEBUG
      when "error"
        Logger::ERROR
      when "fatal"
        Logger::FATAL
      when "unknown"
        Logger::UNKNOWN
      else
        Logger::INFO
      end

      logger_target = config["file"] || $stdout

      @logger = Logger.new(logger_target)
      @logger.level = severity
    end

    def configure_subscriptions(config)
      return unless config
      require File.expand_path(config, File.expand_path("..", __dir__))
    end

    def configure_puma_variables(config)
      @control_app_url = config["control_app_url"]
      @control_app_token = if (token = config["control_app_token"])
        {auth_token: token}
      else
        {no_token: true}
      end
      @prometheus_exporter_url = config["prometheus_exporter_url"]
    end

    def configure_metrics(metrics)
      metrics.each do |metric|
        case metric["type"]
        when "counter", "summary", "gauge"
          registry.send(
            metric["type"],
            metric["name"].to_sym,
            docstring: metric["docstring"],
            labels: (metric["labels"] || []).map(&:to_sym),
            preset_labels: metric["preset_labels"] || {},
            store_settings: metric["store_settings"] || {}
          )
        when "histogram"
          registry.histogram(
            metric["name"].to_sym,
            docstring: metric["docstring"],
            labels: (metric["labels"] || []).map(&:to_sym),
            preset_labels: metric["preset_labels"] || {},
            buckets: metric["buckets"] || Prometheus::Client::Histogram::DEFAULT_BUCKETS,
            store_settings: metric["store_settings"] || {}
          )
        end
      end
    end

    def configure_data_store(config)
      return unless config
      if config["class"] == "Prometheus::Client::DataStores::DirectFileStore"
        @data_store_dir = config["dir"]
        return unless @data_store_dir
        Prometheus::Client.config.data_store =
          Prometheus::Client::DataStores::DirectFileStore.new(dir: @data_store_dir)
      end
    end
  end
end

def Metrics(name)
  metric = Metrics.registry.get(name)
  yield metric if metric
end
