module HasMassCalculation
  extend ActiveSupport::Concern

  def calculate_mass
    begin
      total_mass = 0.0
      
      # Base craft mass
      base_mass = get_base_craft_mass
      total_mass += base_mass
      
      # Add all units
      base_units.each do |unit|
        unit_mass = get_unit_mass(unit.unit_type)
        total_mass += unit_mass
      end
      
      # Add all modules  
      base_modules.each do |mod|
        module_mass = get_module_mass(mod.module_type)
        total_mass += module_mass
      end
      
      # Add all rigs
      base_rigs.each do |rig|
        rig_mass = get_rig_mass(rig.rig_type)
        total_mass += rig_mass
      end
      
      total_mass
      
    rescue => e
      Rails.logger.error "Mass calculation failed: #{e.message}"
      340.0  # Fallback
    end
  end

  def get_base_craft_mass
    # Try operational_data first
    if operational_data&.dig('physical_properties', 'empty_mass_kg')
      return operational_data['physical_properties']['empty_mass_kg'].to_f
    end
    
    # Fallback to blueprint lookup
    blueprint_service = Lookup::BlueprintLookupService.new
    blueprint_id = default_blueprint_id
    blueprint_data = blueprint_service.find_blueprint(blueprint_id, blueprint_category)
    
    if blueprint_data&.dig('physical_properties', 'empty_mass_kg')
      return blueprint_data['physical_properties']['empty_mass_kg'].to_f
    end
    
    raise "Could not find base craft mass"
  end

  def get_unit_mass(unit_type)
    blueprint_service = Lookup::BlueprintLookupService.new
    unit_blueprint = blueprint_service.find_blueprint(unit_type)
    
    if unit_blueprint
      # Try multiple possible paths
      if unit_blueprint.dig('physical_properties', 'empty_mass_kg')
        return unit_blueprint['physical_properties']['empty_mass_kg'].to_f
      elsif unit_blueprint.dig('physical_properties', 'mass_kg')
        return unit_blueprint['physical_properties']['mass_kg'].to_f
      elsif unit_blueprint.dig('operational_data_reference', 'physical_properties', 'mass_kg')
        return unit_blueprint['operational_data_reference']['physical_properties']['mass_kg'].to_f
      end
    end
    
    raise "Could not find mass for unit: #{unit_type}"
  end

  def get_module_mass(module_type)
    blueprint_service = Lookup::BlueprintLookupService.new
    module_blueprint = blueprint_service.find_blueprint(module_type)
    
    if module_blueprint
      if module_blueprint.dig('physical_properties', 'empty_mass_kg')
        return module_blueprint['physical_properties']['empty_mass_kg'].to_f
      elsif module_blueprint.dig('physical_properties', 'mass_kg')
        return module_blueprint['physical_properties']['mass_kg'].to_f
      end
    end
    
    raise "Could not find mass for module: #{module_type}"
  end

  def get_rig_mass(rig_type)
    blueprint_service = Lookup::BlueprintLookupService.new
    rig_blueprint = blueprint_service.find_blueprint(rig_type)
    
    if rig_blueprint
      if rig_blueprint.dig('physical_properties', 'empty_mass_kg')
        return rig_blueprint['physical_properties']['empty_mass_kg'].to_f
      elsif rig_blueprint.dig('physical_properties', 'mass_kg')
        return rig_blueprint['physical_properties']['mass_kg'].to_f
      end
    end
    
    raise "Could not find mass for rig: #{rig_type}"
  end

  private

  def default_blueprint_id
    raise NotImplementedError, "#{self.class} must implement #default_blueprint_id"
  end

  def blueprint_category
    raise NotImplementedError, "#{self.class} must implement #blueprint_category"
  end
end