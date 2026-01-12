module HasConstructionCosts
  extend ActiveSupport::Concern

  def calculate_construction_cost
    puts "🔧 DEBUG: Starting construction cost calculation..."
    total_cost = 0.0
    
    # 1. Base craft construction cost
    blueprint_cost = get_blueprint_purchase_cost
    total_cost += blueprint_cost
    puts "🔧 DEBUG: Blueprint cost: #{blueprint_cost} GCC"
    
    # 2. Unit construction costs
    base_units.each do |unit|
      unit_cost = get_component_blueprint_cost(unit.unit_type, 'unit')
      total_cost += unit_cost
      puts "🔧 DEBUG: Unit #{unit.unit_type}: #{unit_cost} GCC"
    end
    
    # 3. Module construction costs
    base_modules.each do |mod|
      module_cost = get_component_blueprint_cost(mod.module_type, 'module')
      total_cost += module_cost
      puts "🔧 DEBUG: Module #{mod.module_type}: #{module_cost} GCC"
    end
    
    # 4. Rig construction costs
    base_rigs.each do |rig|
      rig_cost = get_component_blueprint_cost(rig.rig_type, 'rig')
      total_cost += rig_cost
      puts "🔧 DEBUG: Rig #{rig.rig_type}: #{rig_cost} GCC"
    end
    
    puts "🔧 DEBUG: Total construction cost: #{total_cost} GCC"
    total_cost
  end

  def get_component_blueprint_cost(component_id, component_type)
    puts "🔧 DEBUG: Looking for #{component_type} blueprint: #{component_id}"
    
    blueprint_service = Lookup::BlueprintLookupService.new
    
    # First try the expected categories for each type
    blueprint_data = case component_type
                     when 'unit'
                       find_unit_blueprint(blueprint_service, component_id)
                     when 'module'
                       find_module_blueprint(blueprint_service, component_id)
                     when 'rig'
                       find_rig_blueprint(blueprint_service, component_id)
                     else
                       nil
                     end
    
    if blueprint_data
      puts "🔧 DEBUG: Found #{component_type} blueprint with keys: #{blueprint_data.keys}"
      puts "🔧 DEBUG: Blueprint category: #{blueprint_data['category']}"
      puts "🔧 DEBUG: Blueprint type: #{blueprint_data['type'] || blueprint_data['blueprint_type']}"
      
      cost_data = blueprint_data.dig('cost_data', 'purchase_cost')
      if cost_data && cost_data['currency'] == 'GCC'
        puts "🔧 DEBUG: Found #{component_type} cost: #{cost_data['amount']} GCC"
        return cost_data['amount'].to_f
      else
        puts "🔧 DEBUG: #{component_type} blueprint found but no cost_data.purchase_cost"
      end
    else
      puts "🔧 DEBUG: No #{component_type} blueprint found for: #{component_id}"
    end
    
    0.0
  end

  private

  def find_unit_blueprint(service, unit_id)
    # Try unit-specific categories first
    unit_categories = ['energy', 'computers', 'propulsion', 'storage', 'sensors', 'power']
    
    unit_categories.each do |category|
      blueprint = service.find_blueprint(unit_id, category)
      if blueprint && (blueprint['type'] == 'unit' || blueprint['template']&.include?('unit'))
        puts "🔧 DEBUG: Found unit with category #{category}"
        return blueprint
      end
    end
    
    # Fallback: find any blueprint but prefer units
    all_matches = service.all_blueprints.select { |bp| bp['id'] == unit_id }
    unit_match = all_matches.find { |bp| bp['type'] == 'unit' || bp['template']&.include?('unit') }
    return unit_match if unit_match
    
    nil
  end

  def find_module_blueprint(service, module_id)
    # Try module-specific categories first
    module_categories = ['sensors', 'energy', 'utility', 'thermal_control', 'power']
    
    module_categories.each do |category|
      blueprint = service.find_blueprint(module_id, category)
      if blueprint && (blueprint['blueprint_type'] == 'module' || blueprint['template']&.include?('module'))
        puts "🔧 DEBUG: Found module with category #{category}"
        return blueprint
      end
    end
    
    # Fallback: find any blueprint but prefer modules
    all_matches = service.all_blueprints.select { |bp| bp['id'] == module_id }
    module_match = all_matches.find { |bp| bp['blueprint_type'] == 'module' || bp['template']&.include?('module') }
    return module_match if module_match
    
    nil
  end

  def find_rig_blueprint(service, rig_id)
    # Try rig-specific categories
    rig_categories = ['expansion_rig', 'computer', 'utility']
    
    rig_categories.each do |category|
      blueprint = service.find_blueprint(rig_id, category)
      if blueprint && (blueprint['category'] == 'expansion_rig' || blueprint['template']&.include?('rig'))
        puts "🔧 DEBUG: Found rig with category #{category}"
        return blueprint
      end
    end
    
    nil
  end

  def get_blueprint_purchase_cost
    puts "🔧 DEBUG: Looking for satellite blueprint cost..."
    
    blueprint_service = Lookup::BlueprintLookupService.new
    blueprint_id = default_blueprint_id
    blueprint_data = blueprint_service.find_blueprint(blueprint_id, 'satellite')
    
    if blueprint_data
      puts "🔧 DEBUG: Found blueprint data with keys: #{blueprint_data.keys}"
      cost_data = blueprint_data.dig('cost_data', 'purchase_cost')
      if cost_data && cost_data['currency'] == 'GCC'
        puts "🔧 DEBUG: Found satellite cost: #{cost_data['amount']} GCC"
        return cost_data['amount'].to_f
      end
    end
    
    puts "🔧 DEBUG: No satellite blueprint cost found"
    0.0
  end

  def default_blueprint_id
    raise NotImplementedError, "#{self.class} must implement #default_blueprint_id"
  end

  def blueprint_category
    raise NotImplementedError, "#{self.class} must implement #blueprint_category"
  end
end