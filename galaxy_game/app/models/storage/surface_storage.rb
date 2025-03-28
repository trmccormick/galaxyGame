module Storage
  class SurfaceStorage < ApplicationRecord
    belongs_to :inventory
    belongs_to :celestial_body, class_name: 'CelestialBodies::CelestialBody'
    belongs_to :settlement, class_name: 'Settlement::BaseSettlement'
    has_many :material_piles, class_name: 'Storage::MaterialPile', dependent: :destroy

    validates :inventory, presence: true
    validates :celestial_body, presence: true
    validates :settlement, presence: true
    validates :item_type, presence: true

    attr_accessor :item_type

    after_initialize :set_defaults

    def self.create_with_attributes(celestial_body:, item_type:)
      new(celestial_body: celestial_body).tap do |storage|
        storage.item_type = item_type
      end
    end

    # Checks if we can store a given quantity of an item
    def can_store_quantity?(quantity)
      true
    end

    # Applies surface conditions to check if an item can be stored
    def check_item_conditions(item)
      apply_surface_conditions(item)
    end

    # Track different material piles on the surface
    def add_pile(material_name:, amount:, source_unit: nil)
      pile = material_piles.find_or_initialize_by(
        material_type: material_name
      )
      pile.amount ||= 0
      pile.amount += amount
      pile.quality_factor ||= 1.0
      pile.save!
      true
    rescue StandardError => e
      Rails.logger.error("Failed to add pile: #{e.message}")
      false
    end

    private

    def set_defaults
      self.item_type ||= 'Solid'
    end

    # Applies surface conditions of the celestial body to the item
    def apply_surface_conditions(item)
      return unless celestial_body

      temperature = celestial_body.surface_temperature
      pressure = celestial_body.known_pressure
      composition = celestial_body.atmosphere&.composition || []

      # Modify item based on atmosphere
      if composition.include?('O2')
        # Simulate corrosion by setting the corroded flag in metadata
        item.metadata['corroded'] = true
        item.save!
      end

      if composition.include?('CO2')
        # Simulate quality degradation by reducing durability
        item.degrade(5) if item.durability
      end

      # Implement state changes based on temperature and pressure if needed
    end

    def handle_solid_state(item, temperature)
      # Check if the temperature causes melting or sublimation
      # Implementation if needed
    end

    def handle_liquid_state(item, temperature)
      # Check if the temperature causes freezing or evaporation
      # Implementation if needed
    end

    def handle_gaseous_state(item, temperature)
      # If temperature falls below the gas's condensation point
      # Implementation if needed
    end

    def apply_atmospheric_effects(item, composition)
      # Handle effects of the atmosphere, like corrosion or reactions
      # Implementation if needed
    end
  end
end