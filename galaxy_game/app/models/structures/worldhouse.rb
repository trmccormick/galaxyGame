# app/models/structures/worldhouse.rb
# A Worldhouse is a STRUCTURE built on top of a geological feature
module Structures
  class Worldhouse < BaseStructure
    # Link to the underlying natural feature
    belongs_to :geological_feature, 
               class_name: 'CelestialBodies::Features::BaseFeature',
               foreign_key: :geological_feature_id,
               optional: false
    
    has_many :worldhouse_segments, 
             class_name: 'Structures::WorldhouseSegment',
             foreign_key: :worldhouse_id,
             dependent: :destroy
    
    validates :geological_feature, presence: true
    validate :feature_must_be_suitable
    
    # Structure attributes
    attribute :total_segments, :integer
    attribute :enclosed_segments, :integer, default: 0
    attribute :coverage_percent, :float, default: 0.0
    
    before_create :set_structure_name
    
    # Delegate to geological feature
    def feature_name
      geological_feature&.name
    end
    
    def feature_length_m
      geological_feature&.length_m
    end
    
    def feature_width_m
      geological_feature&.width_m
    end
    
    def feature_depth_m
      geological_feature&.depth_m
    end
    
    # Calculate dimensions from feature
    def opening_area_km2
      return nil unless feature_length_m && feature_width_m
      (feature_length_m / 1000.0) * (feature_width_m / 1000.0)
    end
    
    def enclosed_volume_km3
      return nil unless feature_length_m && feature_width_m && feature_depth_m
      (feature_length_m / 1000.0) * (feature_width_m / 1000.0) * (feature_depth_m / 1000.0)
    end
    
    def population_capacity
      return 0 unless enclosed_volume_km3
      # 50% usable space, 100 people per km³
      (enclosed_volume_km3 * 0.5 * 100).to_i
    end
    
    # Check if construction is complete
    def construction_complete?
      return false unless total_segments
      enclosed_segments >= total_segments
    end
    
    # Update progress based on segments
    def recalculate_progress!
      return unless total_segments && total_segments > 0
      
      completed = worldhouse_segments.enclosed.count
      percent = (completed.to_f / total_segments * 100).round(2)
      
      update!(
        enclosed_segments: completed,
        coverage_percent: percent
      )
      
      # Update geological feature status
      if construction_complete?
        geological_feature.enclose!
      end
    end
    
    private
    
    def set_structure_name
      self.name ||= "#{geological_feature.name} Worldhouse"
      self.structure_name ||= 'worldhouse'
    end
    
    def feature_must_be_suitable
      return unless geological_feature
      
      suitable_types = [
        'CelestialBodies::Features::Valley',
        'CelestialBodies::Features::Canyon', 
        'CelestialBodies::Features::LavaTube'
      ]
      
      unless geological_feature.class.name.in?(suitable_types)
        errors.add(:geological_feature, 'must be a valley, canyon, or lava tube')
      end
    end
  end
end