module Construction
  class LogisticsService
    def self.calculate_material_costs(structure_blueprint_id)
      blueprint_path = Rails.root.join('data', 'json-data', 'blueprints', 'structures', 'space_stations', "#{structure_blueprint_id}_bp.json")
      
      unless File.exist?(blueprint_path)
        Rails.logger.error "[LogisticsService] Blueprint not found: #{blueprint_path}"
        return {}
      end
      
      blueprint = JSON.parse(File.read(blueprint_path))
      materials = blueprint.dig('blueprint_data', 'materials') || []
      
      costs = {}
      materials.each do |material|
        material_id = material['id']
        amount = material['amount']
        unit = material['unit']
        
        # Convert to standard units if needed
        standardized_amount = standardize_amount(amount, unit)
        
        costs[material_id] = {
          amount: standardized_amount,
          unit: 'kilogram' # standardize to kg
        }
      end
      
      costs
    end

    def self.material_shortage?(station, material_id)
      # Check if station has construction jobs that need this material
      # This is a simplified check - would need actual construction job tracking
      
      # For now, assume no shortages (would need to implement construction job system)
      0
    end
    
    private
    
    def self.standardize_amount(amount, unit)
      case unit
      when 'kilogram'
        amount
      when 'unit'
        # Assume 100kg per unit for structural panels
        amount * 100
      else
        amount
      end
    end
  end
end
