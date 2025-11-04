ActiveSupport::Notifications.subscribe("track.rack_attack") do |event|
  next unless event.payload[:request].env["rack.attack.matched"] == "haz_cookie"
  Metrics(:cookie_size_bytes) do |metric|
    metric.observe(event.payload[:request].env["HTTP_COOKIE"].bytesize)
  end
end

ActiveSupport::Notifications.subscribe("cookie_purge.spectrum_json") do |event|
  Metrics(:cookie_purges_total) do |metric|
    metric.increment
  end
end


