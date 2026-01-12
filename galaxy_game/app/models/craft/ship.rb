module Craft
  class Ship < BaseCraft
    # Add specific ship-related logic here
    # For example, methods specific to ships or additional associations

    # Example: A ship can have fuel levels, specific movement systems, etc.
    has_one :fuel, dependent: :destroy
    has_many :crew_members, class_name: 'CrewMember', dependent: :destroy

    validates :ship_type, presence: true # Ensure ship has a type (like "Battleship", "Explorer", etc.)

    after_create :initialize_fuel

    # Ship-specific methods
    def initialize_fuel
      self.create_fuel(level: 100)  # assuming 100 is the initial fuel level
    end

    def fuel_level
      fuel.level
    end

    def refuel(amount)
      update(fuel: fuel.level + amount)
    end

    # Additional ship functionality, like moving, navigation, combat systems, etc.

    private

    def validate_shipment_capacity
      if units.size > max_units_allowed
        errors.add(:base, 'Ship exceeds maximum allowed unit capacity')
      end
    end
  end
end



  