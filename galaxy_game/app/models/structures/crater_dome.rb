module Structures
  class CraterDome < BaseStructure
    # Keep your validations using the accessor methods
    validates :diameter, presence: true, numericality: { greater_than: 0 }
    validates :depth, presence: true, numericality: { greater_than: 0 }
    
    # Optional fields
    validates :layer_type, inclusion: { in: ['primary', 'secondary', 'both', nil] }
    
    # Lifecycle callbacks
    before_validation :set_structure_type
    before_validation :save_dimensions_to_operational_data

    def structure_type
      operational_data&.dig('structure_type') || 'crater_dome'
    end
    
    # Enclosure calculations
    def calculate_enclosure_materials
      CraterDomeMaterialsCalculator.calculate_materials(self)
    end
    
    def calculate_volume
      # Volume of a spherical cap approximation
      height = depth * 0.3 # Dome covers 30% of crater depth
      radius = diameter / 2.0
      (1.0/6.0) * Math::PI * height * (3 * radius**2 + height**2)
    end
    
    def calculate_surface_area
      # Surface area of a spherical cap approximation
      height = depth * 0.3
      radius = diameter / 2.0
      2 * Math::PI * radius * height
    end
    
    # Override getters to read from operational_data
    def diameter
      operational_data&.dig('dimensions', 'diameter')&.to_f || 0
    end
    
    def depth
      operational_data&.dig('dimensions', 'depth')&.to_f || 0
    end
    
    # Override setters to write to operational_data
    def diameter=(value)
      operational_data ||= {}
      operational_data['dimensions'] ||= {}
      operational_data['dimensions']['diameter'] = value.to_f
    end
    
    def depth=(value)
      operational_data ||= {}
      operational_data['dimensions'] ||= {}
      operational_data['dimensions']['depth'] = value.to_f  # Add this line
    end
    
    # Status accessor methods
    def status
      operational_data&.dig('status') || 'planned'
    end

    def status=(value)
      self.operational_data ||= {}
      self.operational_data['status'] = value
    end
    
    # Completion date accessors
    def completion_date
      date_str = operational_data&.dig('completion_date')
      date_str ? Time.parse(date_str) : nil
    rescue
      nil
    end
    
    def completion_date=(value)
      self.operational_data ||= {}
      self.operational_data['completion_date'] = value.to_s
    end
    
    # Estimated completion accessors
    def estimated_completion
      date_str = operational_data&.dig('estimated_completion')
      date_str ? Time.parse(date_str) : nil
    rescue
      nil
    end
    
    def estimated_completion=(value)
      self.operational_data ||= {}
      self.operational_data['estimated_completion'] = value.to_s
    end
    
    # Notes accessor
    def notes
      operational_data&.dig('notes')
    end
    
    def notes=(value)
      self.operational_data ||= {}
      self.operational_data['notes'] = value
    end
    
    # Add contained structures association
    has_many :contained_structures, class_name: 'Structures::BaseStructure', 
             foreign_key: 'container_structure_id'
    
    # Methods to add/remove structures inside the dome
    def add_structure(structure)
      structure.update(container_structure: self)
    end
    
    def remove_structure(structure)
      structure.update(container_structure: nil)
    end
    
    # Get all structures inside this dome
    def interior_structures
      contained_structures
    end
    
    # Add these methods to your CraterDome class:
    def layer_type
      operational_data&.dig('layer_type')
    end

    def layer_type=(value)
      self.operational_data ||= {}
      self.operational_data['layer_type'] = value
    end
    
    # ✅ ADD: Dome-specific atmosphere management
    def establish_controlled_environment!
      # Crater domes are built to be controlled environments
      atmosphere.update!(
        environment_type: 'artificial',
        sealing_status: true,
        pressure: 101.325,  # Earth normal
        temperature: 293.15, # 20°C
        composition: optimized_dome_composition
      )
      
      # Update all structures inside the dome
      update_nested_structure_atmospheres
    end

    def optimized_dome_composition
      # Slightly higher oxygen for better health in enclosed environment
      {
        "N2" => 76.0,
        "O2" => 23.0,
        "Ar" => 0.9,
        "CO2" => 0.04
      }
    end

    def update_nested_structure_atmospheres
      contained_structures.each do |nested_structure|
        next unless nested_structure.atmosphere
        
        # Structures in dome inherit dome's controlled atmosphere
        nested_structure.atmosphere.update!(
          temperature: self.atmosphere.temperature,
          pressure: self.atmosphere.pressure,
          composition: self.atmosphere.composition.dup,
          sealing_status: nested_structure.atmosphere.sealing_status, # Keep individual sealing
          base_values: nested_structure.atmosphere.base_values.merge({
            'dome_controlled' => true,
            'parent_dome_id' => self.id
          })
        )
      end
    end

    private
    
    def save_dimensions_to_operational_data
      # This is redundant with the accessor methods above, but included for clarity
      self.operational_data ||= {}
      self.operational_data['dimensions'] ||= {}
      self.operational_data['dimensions']['diameter'] = diameter if diameter
      self.operational_data['dimensions']['depth'] = depth if depth
    end
    
    def set_structure_type
      self.operational_data ||= {}
      self.operational_data['structure_type'] = 'crater_dome'
      self.structure_type = 'crater_dome'
    end
    
    # ✅ ATMOSPHERIC OVERRIDES: Only specify construction differences
    def atmosphere_type
      'artificial' # Constructed controlled environment
    end
    
    def default_sealing_status
      true # Built sealed
    end
  end
end