# app/services/ai_manager/depot_adapter.rb
## Adapter module for OrbitalSettlement depot creation only
## All PORO and DepotWrapper logic removed 2026-04-11 per refactor task

module AIManager
  module DepotAdapter
    # Create or find an OrbitalSettlement depot for a world
    # @param world_key [Symbol] Key identifying the world (e.g., :mars, :venus)
    # @param world [CelestialBody] The celestial body object
    # @return [Settlement::OrbitalSettlement]
    def self.create_depot(world_key, world)
      depot = Settlement::OrbitalSettlement.find_or_create_by!(
        name: "#{world.name} Orbital Depot"
      ) do |d|
        d.settlement_type = 'station'
        d.current_population = 0
        d.operational_data = {
          'world_key' => world_key.to_s,
          'purpose' => 'terraforming_gas_storage'
        }
      end

      unless depot.location
        name_service = NameGeneratorService.new
        Location::CelestialLocation.create!(
          celestial_body: world,
          name: name_service.generate_identifier,
          coordinates: '0.00°N 0.00°E',
          altitude: calculate_orbital_altitude(world),
          locationable: depot
        )
      end

      depot
    end

    # Calculate orbital altitude based on world type
    # @param world [CelestialBody]
    # @return [Float] Altitude in meters
    def self.calculate_orbital_altitude(world)
      km = world.properties&.dig('standard_orbital_altitude_km')
      return km.to_f * 1000.0 if km.present?
      10_000_000.0 # default 10,000 km
    end
  end
end
