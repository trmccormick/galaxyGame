module Structures
  class PlanetaryUmbilicalHub < BaseStructure
    # Planetary Umbilical Hub for connecting Heavy Lift Transport craft to settlements
    # Enables resource transfer and inventory visibility
    
    validates :name, presence: true
    
    after_create :add_industrial_refinery_module

    # Check if a specific craft is connected via this hub
    def connected_craft?(craft)
      connections = operational_data&.dig('umbilical_connections') || {}
      connection = connections[craft.id.to_s]
      connection && connection['status'] == 'active'
    end
    def connected_craft?(craft)
      connections = operational_data&.dig('umbilical_connections') || {}
      connection = connections[craft.id.to_s]
      connection && connection['status'] == 'active'
    end
    
    # Get all actively connected craft
    def connected_craft
      connections = operational_data&.dig('umbilical_connections') || {}
      connected_ids = connections.select { |_, conn| conn['status'] == 'active' }.keys
      Craft::BaseCraft.where(id: connected_ids)
    end
    
    # Disconnect a craft from this hub
    def disconnect_craft(craft)
      connections = operational_data&.dig('umbilical_connections') || {}
      if connections[craft.id.to_s]
        connections[craft.id.to_s]['status'] = 'disconnected'
        connections[craft.id.to_s]['disconnected_at'] = Time.current
        update!(operational_data: operational_data.merge('umbilical_connections' => connections))
      end
    end

    private

    def add_industrial_refinery_module
      modules.create!(
        name: 'Industrial Refinery Module',
        module_type: 'industrial_refinery_module',
        identifier: 'industrial_refinery_module'
      )
    end
  end
end
