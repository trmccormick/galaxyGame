# app/models/concerns/has_external_connections.rb
module HasExternalConnections
  extend ActiveSupport::Concern

  included do
    def get_external_connection(port_name)
      craft_info&.dig('ports', port_name) || craft_info&.dig('umbilical_ports', port_name)
    end

    def has_external_connection?(port_name)
      get_external_connection(port_name).present?
    end
  end
end
