# app/services/ai_manager/depot_adapter.rb
# Adapter module to support both PORO and ActiveRecord OrbitalDepot implementations
# This allows gradual migration from test PORO to production Settlement::OrbitalDepot

module AIManager
  module DepotAdapter
    # Factory method to create depot based on environment configuration
    # @param world_key [Symbol] Key identifying the world (e.g., :mars, :venus)
    # @param world [CelestialBody] The celestial body object
    # @return [Object] Depot instance (either PORO or Settlement::OrbitalDepot)
    def self.create_depot(world_key, world)
      if use_activerecord_depot?
        create_ar_depot(world_key, world)
      else
        create_poro_depot(world_key, world)
      end
    end
    
    # Wrapper class providing unified interface for both depot types
    class DepotWrapper
      def initialize(depot)
        @depot = depot
        @is_ar = depot.is_a?(Settlement::OrbitalDepot)
      end
      
      # Add gas to depot
      # @param gas_name [String] Name of gas
      # @param amount [Float] Amount in kg
      # @param metadata [Hash] Optional metadata (for AR depots)
      def add_gas(gas_name, amount, metadata = {})
        if @is_ar
          @depot.add_gas(gas_name, amount, metadata)
        else
          @depot.add_gas(gas_name, amount)
        end
      end
      
      # Remove gas from depot
      # @param gas_name [String] Name of gas
      # @param amount [Float] Amount to remove
      # @param metadata [Hash] Optional metadata filter (for AR depots)
      # @return [Float] Actual amount removed
      def remove_gas(gas_name, amount, metadata = {})
        if @is_ar
          @depot.remove_gas(gas_name, amount, metadata)
        else
          @depot.remove_gas(gas_name, amount)
        end
      end
      
      # Get current gas amount
      # @param gas_name [String] Name of gas
      # @param metadata [Hash] Optional metadata filter (for AR depots)
      # @return [Float] Amount in kg
      def get_gas(gas_name, metadata = {})
        if @is_ar
          @depot.get_gas(gas_name, metadata)
        else
          @depot.get_gas(gas_name)
        end
      end
      
      # Check if depot has sufficient gas
      # @param gas_name [String] Name of gas
      # @param amount [Float] Required amount
      # @param metadata [Hash] Optional metadata filter (for AR depots)
      # @return [Boolean]
      def has_gas?(gas_name, amount, metadata = {})
        if @is_ar
          @depot.has_gas?(gas_name, amount, metadata)
        else
          @depot.has_gas?(gas_name, amount)
        end
      end
      
      # Get total mass of all gases
      # @return [Float]
      def total_mass
        if @is_ar
          @depot.total_gas_mass
        else
          @depot.total_mass
        end
      end
      
      # Get depot summary/status
      # @return [Hash]
      def summary
        if @is_ar
          @depot.depot_status
        else
          @depot.summary
        end
      end
      
      # Get the underlying depot object
      # @return [Object]
      def underlying_depot
        @depot
      end
      
      # Check if using ActiveRecord depot
      # @return [Boolean]
      def activerecord?
        @is_ar
      end
    end
    
    private
    
    # Check environment configuration for depot type
    # @return [Boolean]
    def self.use_activerecord_depot?
      ENV['USE_AR_DEPOT']&.downcase == 'true' || 
        ENV['RAILS_ENV'] == 'production'
    end
    
    # Create ActiveRecord depot
    # @param world_key [Symbol]
    # @param world [CelestialBody]
    # @return [Settlement::OrbitalDepot]
    def self.create_ar_depot(world_key, world)
      depot = Settlement::OrbitalDepot.find_or_create_by!(
        name: "#{world.name} Orbital Depot"
      ) do |d|
        d.settlement_type = 'outpost'
        d.current_population = 10
        d.operational_data = {
          'world_key' => world_key.to_s,
          'purpose' => 'terraforming_gas_storage'
        }
      end
      
      # Ensure depot has location
      unless depot.location
        Location::CelestialLocation.create!(
          celestial_body: world,
          latitude: 0.0,
          longitude: 0.0,
          altitude: calculate_orbital_altitude(world),
          locationable: depot
        )
      end
      
      # Ensure depot has gas storage unit
      if depot.base_units.none? { |u| u.operational_data&.dig('storage', 'type') == 'gas' }
        Units::BaseUnit.create!(
          attachable: depot,
          unit_type: 'storage',
          name: "#{world.name} Gas Storage Tank",
          operational_data: {
            'storage' => {
              'type' => 'gas',
              'capacity' => 1.0e14 # 100 trillion kg capacity
            }
          }
        )
      end
      
      depot
    end
    
    # Create PORO depot
    # @param world_key [Symbol]
    # @param world [CelestialBody]
    # @return [OrbitalDepot]
    def self.create_poro_depot(world_key, world)
      OrbitalDepot.new(
        celestial_body_id: world.id,
        name: "#{world.name} Orbital Depot"
      )
    end
    
    # Calculate orbital altitude based on world type
    # @param world [CelestialBody]
    # @return [Float] Altitude in meters
    def self.calculate_orbital_altitude(world)
      case world.class.name
      when /Mars/
        20_000_000.0 # 20,000 km for Mars L1
      when /Venus/
        15_000_000.0
      when /Titan/
        5_000_000.0
      else
        10_000_000.0 # Default 10,000 km
      end
    end
  end
end
