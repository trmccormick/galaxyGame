class SubBrownDwarf < ApplicationRecord
    include OrbitalMechanics
  
    belongs_to :solar_system, optional: true
    has_one :spatial_location, as: :spatial_context, dependent: :destroy
  
    # Validations
    validates :identifier, presence: true, uniqueness: true
    validates :luminosity, numericality: { greater_than_or_equal_to: 0 }
    validates :mass, presence: true, numericality: { greater_than_or_equal_to: 5.0e26, less_than_or_equal_to: 1.0e27 } # 5-13 Jupiter masses
    validates :radius, presence: true, numericality: { greater_than: 0 }
    validates :temperature, presence: true, numericality: { greater_than_or_equal_to: 100, less_than_or_equal_to: 1000 } # Sub-brown dwarfs are even cooler
  
    def name
      super.presence || identifier
    end
  
    def orphan_object?
      true # Most sub-brown dwarfs are free-floating
    end
  
    def habitability_score
      "Sub-brown dwarfs are too cold to sustain life, but their moons could be explored."
    end
  end
  