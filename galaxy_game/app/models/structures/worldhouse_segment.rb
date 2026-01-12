# app/models/structures/worldhouse_segment.rb
# A segment of a worldhouse structure
module Structures
  class WorldhouseSegment < ApplicationRecord
    self.table_name = 'worldhouse_segments'
    
    include Coverable  # Add coverable functionality
    
    belongs_to :worldhouse, class_name: 'Structures::Worldhouse'
    has_many :construction_jobs, as: :jobable, dependent: :destroy
    
    # Components used in this segment (references existing component system)
    has_many :segment_components, 
             class_name: 'Structures::SegmentComponent',
             dependent: :destroy
    
    validates :segment_index, presence: true
    validates :length_m, presence: true, numericality: { greater_than: 0 }
    validates :width_m, presence: true, numericality: { greater_than: 0 }
    
    # Segment type attribute
    attribute :segment_type, :string, default: 'residential'
    
    enum status: {
      planned: 'planned',
      materials_requested: 'materials_requested',
      under_construction: 'under_construction',
      enclosed: 'enclosed',
      operational: 'operational'
    }
    
    # Implement Enclosable interface
    def length_m
      self[:length_m] || 0
    end
    
    def width_m
      self[:width_m] || 0
    end
    
    def area_m2
      length_m * width_m
    end
    
    def area_km2
      area_m2 / 1_000_000.0
    end
    
    # For CoveringCalculator compatibility
    def diameter
      Math.sqrt(length_m**2 + width_m**2)
    end
    
    # Calculate how many panels needed (using existing component system)
    def required_panel_count
      # Each modular_structural_panel is 5x5m = 25m²
      (area_m2 / 25.0).ceil
    end
    
    # Calculate material requirements (uses existing items/components)
    def required_materials
      panel_count = required_panel_count
      
      {
        'modular_structural_panel' => panel_count,
        'structural_support_beam' => (panel_count * 0.2).ceil, # 1 beam per 5 panels
        'pressure_seal' => panel_count,
        'mounting_hardware' => (panel_count * 4).ceil # 4 mounts per panel
      }
    end
    
    # Start construction
    def begin_construction!
      return false unless planned?
      
      # Create material requests using existing system
      required_materials.each do |item_id, quantity|
        MaterialRequest.create!(
          requestable: self,
          material_name: item_id,
          quantity_requested: quantity,
          priority: 'high'
        )
      end
      
      update!(status: 'materials_requested')
    end
    
    # Complete segment
    def complete!
      return false unless under_construction?
      
      update!(status: 'enclosed')
      worldhouse.recalculate_progress!
    end
  end
end
