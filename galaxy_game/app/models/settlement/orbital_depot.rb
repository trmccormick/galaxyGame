# app/models/settlement/orbital_depot.rb
# Production-ready OrbitalDepot as a SpaceStation subclass
# Uses the game's Inventory system for persistent gas storage
#
# TODO: This replaces the temporary PORO OrbitalDepot in app/models/orbital_depot.rb
# Migration steps:
# 1. Create orbital depot settlements via seeds or admin interface
# 2. Update AIManager::TerraformingManager to use Settlement::OrbitalDepot
# 3. Add RSpec tests for gas storage operations
# 4. Remove temporary PORO model

module Settlement
  class OrbitalDepot < SpaceStation
    # Orbital depot is a specialized space station for gas/liquid storage
    # Located at strategic points (planetary orbits, Lagrange points, etc.)
    
    validates :settlement_type, inclusion: { in: %w[base outpost] }
    
    before_create :set_depot_defaults
    
    # Gas storage operations using Inventory system
    
    # Add gas to depot inventory
    # @param gas_name [String] Name of gas (e.g., 'H2', 'O2')
    # @param amount [Float] Amount in kg
    # @param metadata [Hash] Optional metadata (source, purity, etc.)
    # @return [Boolean] Success status
    def add_gas(gas_name, amount, metadata = {})
      raise ArgumentError, "Amount must be positive" if amount < 0
      
      # Use inventory system with metadata for tracking
      inventory.add_item(
        gas_name,
        amount,
        self, # owner
        metadata.merge(storage_type: 'depot_gas')
      )
    end
    
    # Remove gas from depot inventory
    # @param gas_name [String] Name of gas
    # @param amount [Float] Amount to remove in kg
    # @param metadata [Hash] Metadata to match specific gas batch
    # @return [Float] Actual amount removed (capped by available)
    def remove_gas(gas_name, amount, metadata = {})
      raise ArgumentError, "Amount must be positive" if amount < 0
      
      available = get_gas(gas_name, metadata)
      amount_to_remove = [amount, available].min
      
      return 0.0 if amount_to_remove <= 0
      
      metadata_filter = metadata.merge(storage_type: 'depot_gas')
      success = inventory.remove_item(gas_name, amount_to_remove, self, metadata_filter)
      
      success ? amount_to_remove : 0.0
    end
    
    # Get current gas inventory
    # @param gas_name [String] Name of gas
    # @param metadata [Hash] Optional metadata filter
    # @return [Float] Total amount in kg
    def get_gas(gas_name, metadata = {})
      metadata_filter = metadata.merge(storage_type: 'depot_gas')
      
      # Query inventory items matching gas name and metadata
      matching_items = inventory.items.where(name: gas_name)
      
      # Filter by metadata if provided
      if metadata_filter.any?
        matching_items = matching_items.where("metadata @> ?", metadata_filter.to_json)
      end
      
      matching_items.sum(:amount)
    end
    
    # Check if depot has at least the requested amount
    # @param gas_name [String] Name of gas
    # @param amount [Float] Required amount
    # @param metadata [Hash] Optional metadata filter
    # @return [Boolean]
    def has_gas?(gas_name, amount, metadata = {})
      get_gas(gas_name, metadata) >= amount
    end
    
    # Get total mass of all gases
    # @return [Float] Total mass in kg
    def total_gas_mass
      inventory.items
        .where("metadata @> ?", {storage_type: 'depot_gas'}.to_json)
        .sum(:amount)
    end
    
    # Get inventory summary by gas type
    # @return [Hash] Gas name => amount mapping
    def gas_inventory_summary
      inventory.items
        .where("metadata @> ?", {storage_type: 'depot_gas'}.to_json)
        .group(:name)
        .sum(:amount)
    end
    
    # Get full depot status including location and capacity
    # @return [Hash]
    def depot_status
      {
        name: name,
        location: location&.to_s,
        celestial_body: celestial_body&.name,
        total_gas_mass: total_gas_mass,
        gas_inventory: gas_inventory_summary,
        storage_capacity: total_storage_capacity,
        available_capacity: available_capacity,
        operational: operational?
      }
    end
    
    # Check if depot is operational
    # @return [Boolean]
    def operational?
      # Check life support, power, etc.
      has_sufficient_power? && life_support_active?
    end
    
    # Gas-specific storage capacity (from specialized storage units)
    # @return [Float] Capacity in kg
    def gas_storage_capacity
      base_units
        .select { |unit| unit.can_store?('gas') }
        .sum { |unit| unit.operational_data.dig('storage', 'capacity').to_f }
    end
    
    # Available gas storage capacity
    # @return [Float]
    def available_gas_capacity
      gas_storage_capacity - total_gas_mass
    end
    
    private
    
    def set_depot_defaults
      self.settlement_type ||= 'outpost'
      self.name ||= "Orbital Depot #{location&.celestial_body&.name}"
    end
    
    def has_sufficient_power?
      # TODO: Implement power management check
      true
    end
    
    def life_support_active?
      # TODO: Implement life support check
      true
    end
  end
end
