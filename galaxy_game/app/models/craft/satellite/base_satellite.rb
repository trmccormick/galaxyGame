# app/models/craft/satellite/base_satellite.rb
module Craft
  module Satellite
    class BaseSatellite < BaseCraft
      include CryptocurrencyMining # Grants mining behaviors to all satellites

      # Explicitly redefine the association with the full class path
      has_many :base_units, class_name: '::Units::BaseUnit', as: :attachable, dependent: :destroy
      has_many :units, through: :base_units, source: :itself

      belongs_to :orbiting_celestial_body,
                class_name: 'CelestialBodies::CelestialBody',
                optional: true

      def needs_atmosphere?
        false # Satellites don't need atmosphere
      end

      # Valid deployment location check for satellites
      def valid_deployment_location?(location_type)
        location_type_s = location_type.to_s
        
        # If operational data has specific deployment locations, only those are valid
        if operational_data.present? && 
           operational_data['deployment'].present? && 
           operational_data['deployment']['deployment_locations'].present?
          
          # Get the specific locations from operational data
          specific_locations = operational_data['deployment']['deployment_locations']
          return specific_locations.map(&:to_s).include?(location_type_s)
        end
        
        # Fallback to standard space locations if no specific locations defined
        valid_space_locations = [
          'orbital',
          'high_orbital',
          'low_orbital',
          'geosynchronous_orbit',
          'polar_orbit',
          'equatorial_orbit',
          'lagrangian_point',
          'deep_space',
          'asteroid_belt',
          'wormhole_proximity',
          'planetary_orbit',
          'satellite_orbit',
          'station_orbit',
          'uncharted_system_orbit'
        ].freeze

        valid_space_locations.include?(location_type_s)
      end

      # Deploy method implementation
      def deploy(location, options = {})
        location_type = location.to_s

        raise "Invalid deployment location" unless valid_deployment_location?(location_type)

        self.stabilizing_wormhole = options[:wormhole] if location_type == 'wormhole_proximity'
        self.orbiting_celestial_body = options[:celestial_body] if location_type.include?('orbital')

        update!(current_location: location_type, deployed: true)
      end

      # Wormhole stabilization
      def stabilize_wormhole(wormhole)
        return false unless operational?
        return false unless can_stabilize_wormhole?
        
        self.stabilizing_wormhole = wormhole
        save
      end

      # Check for specific unit types
      def has_unit?(unit_type)
        base_units.where(unit_type: unit_type).exists?
      end

      # Method to build units based on craft configuration
      def build_units_and_modules
        # Clear existing units first
        base_units.destroy_all
        
        # Get recommended units from operational data
        craft_data = resolved_craft_data
        
        return unless craft_data.present? && craft_data['recommended_units'].present?
        
        recommended_units = craft_data['recommended_units']
        return unless recommended_units.is_a?(Array)
        
        # Create each unit
        recommended_units.each do |unit_info|
          # Extract unit type and count
          if unit_info.is_a?(Hash)
            unit_type = unit_info['id']
            count = unit_info['count'] || 1
          else
            unit_type = unit_info.to_s
            count = 1
          end
          
          next unless unit_type.present?
          
          # Get unit data
          unit_lookup_service = Lookup::UnitLookupService.new
          unit_data = unit_lookup_service.find_unit(unit_type)
          next unless unit_data.present?
          
          # Create the specified number of units
          count.times do
            base_units.create!(
              unit_type: unit_type,
              name: unit_data['name'] || unit_type.to_s.humanize,
              identifier: "#{unit_type}_#{SecureRandom.hex(4)}",
              operational_data: unit_data,
              owner: self.owner # Pass the owner from the satellite to the unit
            )
          end
        end
      end

      def resolved_craft_data
        return operational_data if operational_data.present? && operational_data['recommended_units'].present?
        
        lookup_service = Lookup::CraftLookupService.new
        lookup_service.find_craft(craft_type)
      end

      def can_stabilize_wormhole?
        has_unit?('wormhole_stabilizer') || modules.any? { |mod| mod.stabilization_capable? }
      end    
      
      def has_maintenance_robot?
        base_units.any? do |unit|
          data = unit.operational_data || {}
          task_types = data.dig("processing_capabilities", "task_types") || []
          task_types.include?("repair_system")
        end
      end      

      # Callback to build units on creation
      after_create :build_satellite_units

      private

      # Use the same implementation as build_units_and_modules
      def build_satellite_units
        build_units_and_modules
      end
    end
  end
end