module Structures
  class Skylight < ApplicationRecord
    self.table_name = 'skylights'
    
    belongs_to :lava_tube, class_name: 'CelestialBodies::Features::LavaTube', foreign_key: 'lavatube_id'
    
    # Validations from original model
    validates :diameter, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validate :position_within_lava_tube_length
    validate :diameter_within_lava_tube_diameter
    
    # Construction status tracking
    attribute :status, :string, default: 'uncovered' # uncovered, under_construction, waiting_for_equipment, primary_cover, upgrading, full_cover
    attribute :panel_type, :string
    attribute :construction_date, :datetime
    attribute :estimated_completion, :datetime
    attribute :notes, :string
    
    # For CoveringCalculator compatibility
    def diameter_m
      diameter
    end
    
    def width_m
      diameter
    end
    
    def length_m
      diameter
    end
    
    def area
      Math::PI * (diameter / 2.0)**2
    end
    
    # Construction methods
    def install_primary_cover(panel_type = "basic_transparent_crater_tube_cover_array")
      service = SkylightConstructionService.new(self, panel_type)
      if service.schedule_construction
        # Service will update status through its own methods
        return true
      end
      false
    end
    
    def install_secondary_cover(panel_type = "structural_cover_panel")
      return false unless status == "primary_cover"
      
      service = SkylightConstructionService.new(self, panel_type)
      if service.schedule_construction
        # Service will update status through its own methods
        return true
      end
      false
    end
    
    # Compatibility method for legacy code that might expect 'lavatube'
    def lavatube
      lava_tube
    end
    
    private
    
    def position_within_lava_tube_length
      return unless lava_tube && position
      lava_tube_length = lava_tube.length_m
      return unless lava_tube_length
      if position > lava_tube_length
        errors.add(:position, "cannot exceed lava tube length")
      end
    end
    
    def diameter_within_lava_tube_diameter
      return unless lava_tube && diameter
      lava_tube_width = lava_tube.width_m
      return unless lava_tube_width
      if diameter > lava_tube_width
        errors.add(:diameter, "cannot exceed lava tube width")
      end
    end
  end
end