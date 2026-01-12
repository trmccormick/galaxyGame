# app/models/structures/segment_component.rb
# Tracks which components are installed in a segment
module Structures
  class SegmentComponent < ApplicationRecord
    self.table_name = 'segment_components'
    
    belongs_to :segment, class_name: 'Structures::WorldhouseSegment'
    belongs_to :item, class_name: 'Item'
    
    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :component_type, presence: true
    
    enum component_type: {
      structural: 'structural',  # modular_structural_panel
      transparent: 'transparent', # transparent variant
      solar: 'solar',            # solar variant
      insulated: 'insulated'     # insulated variant
    }
    
    # Calculate power generation if solar panels
    def power_output_mw
      return 0 unless solar?
      
      # Each 5x5m solar panel = 25m² at 200W/m² = 5kW
      (quantity * 0.005).round(3) # Convert to MW
    end
  end
end