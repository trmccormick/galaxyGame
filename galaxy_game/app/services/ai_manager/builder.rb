module AIManager
  class Builder
    # This class handles the process of actually triggering construction jobs
    # based on the AI's planning
    
    def initialize(settlement)
      @settlement = settlement
    end
    
    # Execute a construction plan from the AI
    def execute_construction_plan(plan)
      return false unless plan && plan['recommended_units_to_build']
      
      executed_jobs = []
      
      plan['recommended_units_to_build'].each do |item|
        # Create as many as recommended by the plan
        item['count'].times do
          job = create_construction_job(item)
          executed_jobs << job if job
        end
      end
      
      # Return the jobs that were created
      executed_jobs
    end
    
    # Check if resources are available for a planned structure
    def can_build?(structure_type, variant = nil)
      # Calculate materials needed
      materials_needed = calculate_materials_for(structure_type, variant)
      
      # Check if materials are available in inventory
      materials_needed.all? do |material, amount|
        @settlement.inventory.available(material) >= amount
      end
    end
    
    # Find the best location for a structure
    def suggest_location(structure_type)
      case structure_type
      when 'dome'
        find_dome_location
      when 'habitat_module'
        find_habitat_location
      when 'power_plant'
        find_power_plant_location
      else
        nil
      end
    end
    
    private
    
    def create_construction_job(item)
      # Create the appropriate construction job based on the item type
      case item['unit_type']
      when 'habitat_module'
        create_habitat_module_job(item)
      when 'power_plant'
        create_power_plant_job(item)
      when 'storage_facility'
        create_storage_facility_job(item)
      when 'dome'
        create_dome_job(item)
      else
        Rails.logger.warn "[AI Builder] Unknown unit type: #{item['unit_type']}"
        nil
      end
    end
    
    def create_habitat_module_job(item)
      # Create a habitat module structure
      habitat = Structures::HabitatModule.create!(
        name: "Habitat Module #{@settlement.structures.where(type: 'habitat_module').count + 1}",
        settlement: @settlement,
        module_type: item['variant'] || 'standard',
        capacity: item['specifications']&.dig('capacity') || 4,
        location_within_settlement: item['location_suggestion'] || suggest_location('habitat_module')
      )
      
      # Create the construction job
      ConstructionJobService.create_job(
        habitat,
        'habitat_construction',
        target_values: {
          priority: item['priority'] || 'medium'
        }
      )
    end
    
    # Similar methods for other structure types...
    
    def calculate_materials_for(structure_type, variant = nil)
      # Get material requirements from blueprints
      blueprint = Blueprint.find_by(
        structure_type: structure_type,
        variant: variant
      )
      
      return {} unless blueprint
      
      # Return the materials hash from the blueprint
      blueprint.materials || {}
    end
    
    def find_dome_location
      # Logic to find a good location for a dome
      # This might use settlement.location data to find suitable terrain
      "Area #{rand(1..5)}"
    end
    
    # Similar methods for other location finding...
  end
end