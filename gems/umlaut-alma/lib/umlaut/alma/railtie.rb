require 'rails'

module Umlaut
  module Alma
    class Railtie < Rails::Railtie

      initializer 'umlaut.preload' do
        require 'service_type_value'
        ServiceTypeValue.merge_hash!(
          fulltext_bundle: {
            display_name: 'Available Online',
            display_name_plural: 'Available Online'
          },
          disambiguation: {
            display_name: 'Disambiguation',
            display_name_plural: 'Disambiguations'
          },
          site_message: {
            display_name: 'Site Message',
            display_name_plural: 'Site Messages',
          }
        )
      end

      initializer 'umlaut_alma.initialize' do
        require_relative 'metadata'
        require_relative 'option'
        require_relative 'option_list'
        require_relative 'failed_option_list'
        require_relative 'client'
        require_relative 'service'
      end

    end
  end
end
