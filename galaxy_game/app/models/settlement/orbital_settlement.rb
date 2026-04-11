# app/models/settlement/orbital_settlement.rb
module Settlement
  class OrbitalSettlement < BaseSettlement
    # BaseSettlement handles: has_many :structures, has_one :inventory, has_one :account
    # Note: settlement_type is inherited but ignored for orbital logic as structures define the role.

    # Returns the primary location based on the first deployed structure.
    # Orbital settlements do not have a 1:1 location; they are a constellation.
    def location
      structures.first&.celestial_location
    end

    def celestial_body
      location&.celestial_body
    end

    # Aggregates storage from all physical hulls (Station, Depot, etc.)
    def total_storage_capacity
      structures.sum(&:total_storage_capacity)
    end

    # This now accurately reflects the sum of all 'Habitat Units'
    # installed across the structure constellation.
    def population_capacity
      structures.sum(&:habitat_capacity)
    end

    # FUTURE: Hook for AI-driven expansion
    # When the generator creates a new specialized structure blueprint 
    # (e.g., 'venus_acid_skimmer'), this is where the settlement 
    # initiates the physical construction of that asset.
    def add_specialized_structure!(blueprint_id)
      structures.create!(
        identifier: blueprint_id,
        shell_status: 'planned'
      )
    end
  end
end