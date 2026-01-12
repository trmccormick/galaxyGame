# app/services/ai_manager/pattern_validator.rb
module AIManager
  class PatternValidator
    VALIDATION_RULES = {
      equipment_feasibility: :check_equipment_exists,
      resource_sufficiency: :check_resources_adequate,
      physics_compliance: :check_physics_realistic,
      economic_viability: :check_cost_reasonable,
      timeline_realistic: :check_timeline_achievable
    }.freeze

    def initialize(celestial_body_data = nil)
      @world_knowledge = WorldKnowledgeService.new(celestial_body_data)
    end

    def validate_pattern(pattern)
      results = {
        valid: true,
        confidence: 1.0,
        warnings: [],
        errors: [],
        suggested_fixes: []
      }

      VALIDATION_RULES.each do |rule_name, method|
        check_result = send(method, pattern)

        if check_result[:error]
          results[:valid] = false
          results[:errors] << check_result
          results[:confidence] -= 0.2
        elsif check_result[:warning]
          results[:warnings] << check_result
          results[:confidence] -= 0.05
        end
      end

      results[:confidence] = [results[:confidence], 0.0].max
      results[:status] = determine_status(results)

      results
    end

    def augment_pattern(pattern)
      # Use world knowledge to enhance incomplete patterns
      augmented = pattern.deep_dup

      # Get world-specific knowledge
      world_resources = @world_knowledge.assess_local_resources
      production_capabilities = @world_knowledge.assess_production_capabilities(pattern[:equipment_requirements])

      # Add suggested ISRU equipment if resources are insufficient
      validation_result = validate_pattern(pattern)

      if validation_result[:errors].any? { |e| e[:rule] == :resource_sufficiency }
        suggested_isru = @world_knowledge.suggest_isru_equipment(pattern[:world_type], validation_result[:errors])

        augmented[:suggested_isru_additions] = suggested_isru unless suggested_isru.empty?
      end

      # Add local resource availability information
      augmented[:world_resources] = world_resources
      augmented[:production_capabilities] = production_capabilities

      # Calculate augmented resource totals
      duration = pattern.dig(:phase_structure, :estimated_total_duration) || 30
      crew_size = estimate_crew_size(pattern)

      if crew_size > 0
        augmented[:augmented_resources] = {
          oxygen_total: (production_capabilities[:oxygen_production_rate] * duration),
          water_total: (production_capabilities[:water_production_rate] * duration),
          food_total: (production_capabilities[:food_production_rate] * duration)
        }
      end

      augmented
    end

    def assess_world_compatibility(pattern)
      # Use world knowledge to assess how well this pattern fits the current world
      world_resources = @world_knowledge.assess_local_resources
      production_capabilities = @world_knowledge.assess_production_capabilities(pattern[:equipment_requirements])

      compatibility_score = 0.5 # Base score
      reasons = []

      # Check if pattern has ISRU equipment that matches world resources
      has_water_extraction = pattern_equipment_includes?(pattern, ['water_extractor', 'ice_mining', 'atmospheric_processor'])
      has_oxygen_generation = pattern_equipment_includes?(pattern, ['oxygen_generator', 'electrolysis', 'sabathier'])

      if world_resources[:water_available] && has_water_extraction
        compatibility_score += 0.2
        reasons << "water_extraction_matches_world"
      end

      if world_resources[:oxygen_available] && has_oxygen_generation
        compatibility_score += 0.2
        reasons << "oxygen_generation_matches_world"
      end

      # Check production capabilities alignment
      if production_capabilities[:oxygen_production_rate] > 0 && has_oxygen_generation
        compatibility_score += 0.1
        reasons << "oxygen_production_capable"
      end

      if production_capabilities[:water_production_rate] > 0 && has_water_extraction
        compatibility_score += 0.1
        reasons << "water_production_capable"
      end

      {
        score: [compatibility_score, 1.0].min,
        reasons: reasons
      }
    end

    def pattern_equipment_includes?(pattern, equipment_names)
      units = pattern.dig(:equipment_requirements, :units) || []
      modules = pattern.dig(:equipment_requirements, :modules) || []

      all_equipment = units + modules
      equipment_names.any? do |name|
        all_equipment.any? { |item| item.to_s.downcase.include?(name.downcase) }
      end
    end

    private

    def check_equipment_exists(pattern)
      missing = []

      # Check craft fit equipment
      craft_fit = pattern.dig(:equipment_requirements, :craft_fit) || {}
      craft_fit.each do |equipment_type, items|
        next unless items.is_a?(Array)
        items.each do |item|
          unit_id = extract_id(item)
          # For now, we'll assume equipment exists if it has a reasonable ID format
          # In a real implementation, this would check against a database
          unless valid_equipment_id?(unit_id)
            missing << unit_id
          end
        end
      end

      # Check deployable units (these are equipment)
      deployable_units = pattern.dig(:equipment_requirements, :inventory, :deployable_units) || []
      deployable_units.each do |unit|
        unit_id = extract_id(unit)
        unless valid_equipment_id?(unit_id)
          missing << unit_id
        end
      end

      if missing.any?
        {
          error: true,
          rule: :equipment_feasibility,
          message: "Equipment not found in database: #{missing.join(', ')}",
          suggested_fix: "Create equipment blueprints or update IDs"
        }
      else
        { valid: true }
      end
    end

    def check_resources_adequate(pattern)
      # Get supplies and consumables from equipment_requirements.inventory
      supplies = pattern.dig(:equipment_requirements, :inventory, :supplies) || []
      consumables = pattern.dig(:equipment_requirements, :inventory, :consumables) || []
      duration = pattern.dig(:phase_structure, :estimated_total_duration) || 30 # default 30 days

      # Estimate crew size from equipment (rough heuristic)
      crew_size = estimate_crew_size(pattern)

      return { valid: true } if crew_size.zero? # Skip if no crew estimated

      # Check life support requirements
      oxygen_needed = crew_size * duration * 0.84  # kg/day per person
      water_needed = crew_size * duration * 3.0    # kg/day per person
      food_needed = crew_size * duration           # kg/day per person (conservative)

      oxygen_available = find_consumable_amount(consumables, "oxygen")
      water_available = find_consumable_amount(consumables, "water")
      food_available = find_consumable_amount(consumables, "food")

      # Use world knowledge to assess local production capabilities
      world_resources = @world_knowledge.assess_local_resources
      equipment_list = @world_knowledge.send(:extract_equipment_list, pattern)
      production_capabilities = @world_knowledge.assess_production_capabilities(equipment_list)

      # Calculate effective available resources including local production
      effective_oxygen = oxygen_available + (production_capabilities[:oxygen_production_rate] * duration)
      effective_water = water_available + (production_capabilities[:water_production_rate] * duration)
      effective_food = food_available + (production_capabilities[:food_production_rate] * duration)

      warnings = []
      errors = []

      # Check oxygen
      if effective_oxygen < oxygen_needed * 0.8
        if oxygen_available < oxygen_needed * 0.8
          errors << "Oxygen critically insufficient (#{oxygen_available.round}kg available, #{oxygen_needed.round}kg needed)"
        else
          warnings << "Oxygen marginal with local production (#{effective_oxygen.round}kg effective, #{oxygen_needed.round}kg needed)"
        end
      end

      # Check water
      if effective_water < water_needed * 0.8
        if water_available < water_needed * 0.8
          errors << "Water critically insufficient (#{water_available.round}kg available, #{water_needed.round}kg needed)"
        else
          warnings << "Water marginal with local production (#{effective_water.round}kg effective, #{water_needed.round}kg needed)"
        end
      end

      # Check food
      if effective_food < food_needed * 0.8
        if food_available < food_needed * 0.8
          errors << "Food critically insufficient (#{food_available.round}kg available, #{food_needed.round}kg needed)"
        else
          warnings << "Food marginal with local production (#{effective_food.round}kg effective, #{food_needed.round}kg needed)"
        end
      end

      if errors.any?
        {
          error: true,
          rule: :resource_sufficiency,
          message: errors.join(", "),
          suggested_fix: "Add ISRU units for #{errors.map { |e| e.split.first.downcase }.join(', ')} production or increase carried supplies"
        }
      elsif warnings.any?
        {
          warning: true,
          rule: :resource_sufficiency,
          message: warnings.join(", "),
          suggested_fix: "Consider adding backup ISRU systems for reliability"
        }
      else
        { valid: true }
      end
    end

    def check_physics_realistic(pattern)
      # Calculate basic physics checks
      total_mass = calculate_total_mass(pattern)
      power_generation = estimate_power_generation(pattern)
      power_consumption = estimate_power_consumption(pattern)

      issues = []

      # Power balance check
      if power_consumption > power_generation * 1.2
        issues << "Insufficient power: #{power_consumption}kW needed, #{power_generation}kW available"
      end

      # Mass sanity check
      if total_mass > 5000000 # 5 million kg seems excessive
        issues << "Total mass suspiciously high: #{total_mass}kg"
      elsif total_mass < 10000 # 10 tons seems too light for a settlement
        issues << "Total mass suspiciously low: #{total_mass}kg"
      end

      if issues.any?
        {
          error: issues.any? { |i| i.include?("power") }, # Power is critical
          rule: :physics_compliance,
          message: issues.join(", "),
          suggested_fix: issues.include?("power") ? "Add nuclear reactors or solar arrays" : "Review mass calculations"
        }
      else
        { valid: true }
      end
    end

    def check_cost_reasonable(pattern)
      estimated_cost = pattern.dig(:economic_model, :estimated_cost)
      import_ratio = pattern.dig(:economic_model, :import_ratio)

      return { valid: true } unless estimated_cost # Skip if no cost data

      warnings = []
      warnings << "Cost suspiciously low (#{estimated_cost} GCC)" if estimated_cost < 100_000
      warnings << "Cost extremely high (#{estimated_cost} GCC)" if estimated_cost > 50_000_000
      warnings << "Import ratio too high (#{import_ratio})" if import_ratio && import_ratio > 0.6

      if warnings.any?
        {
          warning: true,
          rule: :economic_viability,
          message: warnings.join(", "),
          suggested_fix: "Review economic model calculations"
        }
      else
        { valid: true }
      end
    end

    def check_timeline_achievable(pattern)
      duration = pattern.dig(:phase_structure, :estimated_total_duration)
      phases = pattern.dig(:deployment_sequence)&.length || 1

      return { valid: true } unless duration # Skip if no duration data

      if duration < phases * 24  # Less than 24 hours per phase
        {
          warning: true,
          rule: :timeline_realistic,
          message: "Timeline may be too aggressive (#{duration}h for #{phases} phases = #{(duration/phases).round}h per phase)",
          suggested_fix: "Review phase durations"
        }
      else
        { valid: true }
      end
    end

    def determine_status(results)
      return :invalid if !results[:valid]
      return :experimental if results[:confidence] < 0.5
      return :needs_review if results[:warnings].any?
      :validated
    end

    # Helper methods
    def extract_id(item)
      return item unless item.is_a?(String)
      # Extract ID from strings like "Robotic Deployment and Docking Unit (1)"
      match = item.match(/(.+)\s*\(\d+\)/)
      match ? match[1].strip : item
    end

    def valid_equipment_id?(id)
      return false if id.nil? || id.empty?
      # Basic validation - ID should be reasonable length and format
      id.length > 3 && id.length < 50 && !id.include?(" ") && id.downcase == id
    end

    def estimate_crew_size(pattern)
      # Rough estimation based on habitat units and equipment
      habitat_count = 0
      robot_count = 0

      # Check for habitat units in craft_fit or directly in equipment_requirements
      craft_fit_units = pattern.dig(:equipment_requirements, :craft_fit, :units) || []
      direct_units = pattern.dig(:equipment_requirements, :units) || []
      all_units = craft_fit_units + direct_units

      all_units.each do |unit|
        if unit.to_s.downcase.include?("habitat")
          habitat_count += extract_count(unit)
        end
      end

      # Check for robots (which might indicate automation)
      all_units.each do |unit|
        if unit.to_s.downcase.include?("robot")
          robot_count += extract_count(unit)
        end
      end

      # Estimate 2-4 people per habitat unit, reduced by automation
      base_crew = habitat_count * 3
      automation_bonus = robot_count * 0.5
      [base_crew - automation_bonus, 1].max # Minimum 1 person
    end

    def extract_count(item)
      return 1 unless item.is_a?(String)
      match = item.match(/\((\d+)\)/)
      match ? match[1].to_i : 1
    end

    def find_consumable_amount(consumables, resource_name)
      consumables.each do |consumable|
        if consumable.to_s.downcase.include?(resource_name.downcase)
          # Extract amount from strings like "oxygen (1000 kilogram)"
          match = consumable.match(/#{resource_name}\s*\((\d+)\s*(\w+)\)/i)
          if match
            amount = match[1].to_f
            unit = match[2].downcase
            # Convert to kg if needed
            case unit
            when "ton", "metric_ton"
              amount *= 1000
            when "day"
              # For food, convert days to kg (assume 0.6kg per person per day)
              amount *= 0.6 if resource_name.downcase == "food"
            end
            return amount
          end
        end
      end
      0
    end

    def calculate_total_mass(pattern)
      # Get total mass from equipment_requirements
      total_mass_str = pattern.dig(:equipment_requirements, :total_mass) || "0 kg"
      match = total_mass_str.match(/(\d+)/)
      match ? match[1].to_i : 0
    end

    def estimate_power_generation(pattern)
      # Rough estimation based on nuclear reactors
      reactor_count = 0

      craft_fit = pattern.dig(:equipment_requirements, :craft_fit) || {}
      modules = craft_fit[:modules] || []

      modules.each do |mod|
        if mod.to_s.downcase.include?("reactor") || mod.to_s.downcase.include?("nuclear")
          reactor_count += extract_count(mod)
        end
      end

      # Assume 100kW per reactor
      reactor_count * 100
    end

    def estimate_power_consumption(pattern)
      # Rough estimation based on equipment count
      units = pattern.dig(:equipment_requirements, :units) || []
      modules = pattern.dig(:equipment_requirements, :modules) || []

      # Assume 5kW per unit, 10kW per module
      (units.length * 5) + (modules.length * 10)
    end
  end
end