module AIManager
  class DecisionTree
    # This class handles top-level decision making for the AI, prioritizing
    # survival (life support), then operational stability (resources), then expansion.
    
    def initialize(settlement, game_data_generator)
      @settlement = settlement
      @game_data_generator = game_data_generator # Needed for LlmPlannerService
      
      # Initialize operational AI components
      # NOTE: AIManager::Construction and AIManager::Builder are assumed to exist.
      @construction = AIManager::Construction.new(settlement, nil)
      @resource_planner = AIManager::ResourcePlanner.new(settlement)
      @builder = AIManager::Builder.new(settlement)
    end
    
    # Main decision method - decide what to do next
    def make_decisions
      # Check priority heuristics first
      priority_heuristic = AIManager::PriorityHeuristic.new(@settlement)
      priorities = priority_heuristic.get_priorities

      if priorities.include?(:refill_oxygen)
        handle_oxygen_refill
        return
      elsif priorities.include?(:local_oxygen_generation)
        handle_local_oxygen_generation
        return
      elsif priorities.include?(:local_argon_extraction)
        handle_local_argon_extraction
        return
      elsif priorities.include?(:refill_nitrogen)
        handle_nitrogen_refill
        return
      elsif priorities.include?(:methane_synthesis)
        handle_methane_synthesis
        return
      elsif priorities.include?(:construct_storage_module)
        handle_construct_storage_module
        return
      elsif priorities.include?(:debt_repayment)
        handle_debt_repayment
        return
      end

      # Get current state
      state = assess_settlement_state
      
      # Decide priority action based on state
      case
      when state[:life_support_at_risk]
        handle_life_support_emergency
      when state[:severe_resource_shortage]
        handle_resource_emergency
      when state[:needs_expansion]
        # Calls the LLM Planner for strategic growth
        handle_expansion_needs
      when state[:resource_shortage]
        handle_resource_needs
      when state[:can_upgrade]
        handle_upgrade_opportunity
      else
        handle_normal_operations
      end
    end
    
    private
    
    def assess_settlement_state
      # Check for various conditions and return a state hash
      {
        life_support_at_risk: life_support_at_risk?,
        severe_resource_shortage: severe_resource_shortage?,
        resource_shortage: resource_shortage?,
        needs_expansion: needs_expansion?,
        can_upgrade: can_upgrade?
      }
    end
    
    # Various state checking methods (simplified for brevity)
    
    def life_support_at_risk?
      @settlement.life_support_status == 'failing' ||
      (@settlement.operational_data&.dig('atmosphere', 'o2_percentage')&.to_f || 20.0) < 18.0 ||
      (@settlement.operational_data&.dig('power_grid', 'status') == 'offline')
    end
    
    def severe_resource_shortage?
      critical_resources = ['Oxygen', 'Water', 'Food']
      
      critical_resources.any? do |resource|
        current = @settlement.inventory.available(resource) rescue 0
        needed = calculate_critical_resource_needs(resource)
        
        current < (needed * 0.5) # Less than 50% of needed amount
      end
    end

    def resource_shortage?
      # Check for non-critical resources needed for current queue
      @resource_planner.identify_resource_shortfalls.any?
    end
    
    def needs_expansion?
      # Heuristic: Population is high and no current expansion is queued
      @settlement.current_population > @settlement.habitat_capacity * 0.9 &&
      !@settlement.construction_queue.expansion_plans_active?
    end

    def can_upgrade?
      # Heuristic: Sufficient capital and idle production capacity
      @settlement.can_afford?(1000000) && @settlement.production_lines.idle.any?
    end
    
    # --- HANDLER METHODS ---
    
    def handle_life_support_emergency
      Rails.logger.warn "[AI] Life support emergency detected in #{@settlement.name}! Triggering Survival Override."
      
      # 1. Cancel non-critical jobs
      # cancel_non_critical_jobs
      
      # 2. Trigger EMERGENCY resource procurement (may involve exceeding Earth Anchor Price limits)
      plan = @resource_planner.generate_procurement_plan
      @resource_planner.execute_procurement_plan(plan)
      
      # 3. Repair or replace failing systems
      # repair_failing_systems
    end
    
    def handle_resource_emergency
      Rails.logger.warn "[AI] Severe resource shortage in #{@settlement.name}! Generating emergency procurement plan."

      # First try internal logistics contracts
      if try_internal_logistics
        Rails.logger.info "[AI] Internal logistics initiated for resource emergency"
        return
      end

      # Generate and execute the normal operational resource plan
      plan = @resource_planner.generate_procurement_plan
      success = @resource_planner.execute_procurement_plan(plan)

      # If procurement failed, create special missions for players
      if !success
        create_special_missions_for_critical_needs
      end
    end
    
    def handle_expansion_needs
      Rails.logger.info "[AI] Expansion needs detected. Calling LLM Planner for strategic growth."
      
      # The LLM Planner generates the high-level, multi-unit strategic plan (e.g., Phase 2)
      llm_planner = AIManager::LlmPlannerService.new(
        settlement_or_location_context: @settlement, 
        game_data_generator: @game_data_generator
      )
      
      # Call a generic expansion method
      plan = llm_planner.generate_expansion_plan
      
      if plan
        Rails.logger.info "[AI] LLM Planner successfully queued expansion plan: #{plan['plan_id']}"
      end
    end

    def handle_resource_needs
      Rails.logger.info "[AI] Resource shortage detected. Calling operational planner."
      plan = @resource_planner.generate_procurement_plan
      @resource_planner.execute_procurement_plan(plan)
    end
    
    def handle_upgrade_opportunity
      Rails.logger.info "[AI] Upgrade opportunity detected. Directing Builder to execute."
      # @builder.find_and_execute_upgrade_plan
    end
    
    def handle_normal_operations
      Rails.logger.debug "[AI] Normal operations. Idle or performing routine maintenance."
    end

    def handle_oxygen_refill
      Rails.logger.info "[AI] Oxygen levels critical. Prioritizing refill tasks over commercial trades."
      # Prioritize internal refill tasks
      # This could involve allocating resources to oxygen production or procurement
      @resource_planner.prioritize_oxygen_refill
    end

    def handle_local_oxygen_generation
      Rails.logger.info "[AI] Local O2 generation possible. Triggering maintenance or energy task."
      # Trigger MaintenanceMission for ISRU repair or EnergyTask for O2 generation from CO2
      @resource_planner.prioritize_energy_for_o2_generation
    end

    def handle_local_argon_extraction
      Rails.logger.info "[AI] Local Ar extraction possible. Triggering extraction service."
      # Trigger ExtractionService for Argon production
      ExtractionService.extract_argon_on_mars(@settlement, 10.0) # Example amount
    end

    def handle_nitrogen_refill
      Rails.logger.info "[AI] N2 levels critical. Initiating import contract for nitrogen."
      # Search for closest available N2 source and create logistics contract
      initiate_critical_import_contract('nitrogen')
    end

    def handle_atmospheric_maintenance(gas_type)
      Rails.logger.info "[AI] Atmospheric maintenance needed for #{gas_type}."
      
      # Query UnitLookupService for units with production_output: gas_type trait
      unit_lookup = Lookup::UnitLookupService.new
      production_units = unit_lookup.find_units_by_trait('production_output', gas_type)
      
      if production_units.any? || gas_type == 'oxygen' # For oxygen, always prioritize local
        # Prioritize local production
        if gas_type == 'oxygen'
          @resource_planner.prioritize_energy_for_o2_generation
        else
          @resource_planner.prioritize_energy_for_gas_generation(gas_type)
        end
      else
        # Fall back to import
        initiate_critical_import_contract(gas_type)
      end
    end

    # Legacy methods for backward compatibility
    def handle_mars_oxygen_maintenance
      handle_atmospheric_maintenance('oxygen')
    end

    def handle_mars_nitrogen_import
      handle_atmospheric_maintenance('nitrogen')
    end

    def handle_debt_repayment
      Rails.logger.info "[AI] Account negative. Setting Si export price ceiling for debt repayment."
      priority_heuristic = AIManager::PriorityHeuristic.new(@settlement)
      si_ask_price = priority_heuristic.calculate_si_ask_price
      # Set the ask price for Si exports
      @settlement.operational_data ||= {}
      @settlement.operational_data['market_settings'] ||= {}
      @settlement.operational_data['market_settings']['si_ask_ceiling'] = si_ask_price
      @settlement.save
    end
    
    def trigger_moxie_repair_or_energy_task
      # Trigger MaintenanceMission for MOXIE repair or EnergyTask to generate O2 from CO2
      # For now, prioritize energy allocation for O2 generation
      @resource_planner.prioritize_energy_for_o2_generation
    end

    def initiate_critical_import_contract(resource)
      # Search for closest available N2 (Luna or Earth) and lock contract based on best Time/Price ratio
      closest_source = find_closest_resource_source(resource)
      if closest_source
        # Calculate time/price ratio and create contract
        create_interplanetary_contract(closest_source, resource)
      end
    end
    
    def trigger_moxie_repair_or_energy_task
      # Trigger MaintenanceMission for MOXIE repair or EnergyTask to generate O2 from CO2
      # For now, prioritize energy allocation for O2 generation
      @resource_planner.prioritize_energy_for_o2_generation
    end

    def initiate_critical_import_contract(resource)
      # Search for closest available N2 (Luna or Earth) and lock contract based on best Time/Price ratio
      closest_source = find_closest_resource_source(resource)
      if closest_source
        # Calculate time/price ratio and create contract
        create_interplanetary_contract(closest_source, resource)
      end
    end

    def create_special_missions_for_critical_needs
      critical_shortages = identify_critical_shortages

      critical_shortages.each do |resource, needed|
        # Calculate reward based on EAP
        eap_price = Market::NpcPriceCalculator.send(:calculate_eap_ceiling, @settlement, resource)
        base_reward = eap_price * needed * 1.5 # 50% bonus for urgency
        bonus_multiplier = 2.0 # Double reward for special missions

        SpecialMission.create!(
          settlement: @settlement,
          material: resource,
          quantity: needed,
          reward_gcc: base_reward,
          bonus_multiplier: bonus_multiplier,
          status: :open,
          expires_at: 24.hours.from_now,
          operational_data: {
            purpose: 'critical_resource_emergency',
            created_by: 'ai_manager',
            urgency_level: 'critical'
          }
        )

        Rails.logger.info "[AI] Created special mission for #{needed} #{resource} at #{@settlement.name}"
      end
    end
    
    def handle_methane_synthesis
      Rails.logger.info "[AI] Excess CO and H2 detected. Initiating methane synthesis."
      # Trigger methane production from CO + H2
      initiate_methane_production
    end

    def handle_construct_storage_module
      Rails.logger.info "[AI] Storage capacity critical. Prioritizing storage module construction."
      # Queue construction of storage module from mars_resource_processing_phase_v1.json
      queue_storage_module_construction
    end
    
    private

    def identify_critical_shortages
      shortages = {}
      critical_resources = ['Oxygen', 'Water', 'Food']

      critical_resources.each do |resource|
        current = @settlement.inventory.available(resource) rescue 0
        needed = calculate_critical_resource_needs(resource)

        if current < (needed * 0.5) # Less than 50% of needed
          shortages[resource] = needed - current
        end
      end

      shortages
    end

    def find_settlement_suppliers(resource, minimum_quantity)
      # Find NPC settlements with surplus of this resource
      Settlement::BaseSettlement.where(owner: nil)
                                .where.not(id: @settlement.id)
                                .select do |settlement|
        available = settlement.inventory.available(resource) rescue 0
        available >= minimum_quantity
      end
    end

    def find_closest_resource_source(resource)
      # Find closest celestial body with available resource (Luna or Earth for N2)
      potential_sources = ['Luna', 'Earth']
      potential_sources.each do |body_name|
        body = CelestialBodies::CelestialBody.find_by(name: body_name)
        next unless body
        settlements = Settlement::BaseSettlement.joins(:location).where(locations: { celestial_body_id: body.id })
        settlements.each do |settlement|
          available = settlement.inventory.available(resource) rescue 0
          if available > 0
            return settlement
          end
        end
      end
      nil
    end

    def create_interplanetary_contract(source_settlement, resource)
      # Create interplanetary logistics contract based on best Time/Price ratio
      # For now, create a special mission or logistics contract
      needed = calculate_critical_resource_needs(resource)
      Logistics::Contract.create!(
        from_settlement: source_settlement,
        to_settlement: @settlement,
        material: resource,
        quantity: needed,
        transport_method: :orbital_transfer,
        status: :pending
      )
      Rails.logger.info "[AI] Created interplanetary contract for #{needed} #{resource} from #{source_settlement.name}"
    end
    
    def initiate_methane_production
      # Create a production job for methane synthesis
      # This would trigger the appropriate processing unit
      MethaneProductionJob.create!(
        settlement: @settlement,
        feedstock_co: 100.0, # kg
        feedstock_h2: 50.0,  # kg
        target_ch4: 75.0,    # kg
        status: :queued
      )
    end

    def queue_storage_module_construction
      # Load blueprint from mars_resource_processing_phase_v1.json
      blueprint = load_blueprint('mars_resource_processing_phase_v1.json', 'storage_module')
      if blueprint
        @construction.queue_construction(blueprint)
      end
    end

    def load_blueprint(blueprint_file, module_name)
      # Load blueprint data from JSON file
      blueprint_path = GalaxyGame::Paths::BLUEPRINTS_PATH.join(blueprint_file)
      if File.exist?(blueprint_path)
        blueprints = JSON.parse(File.read(blueprint_path))
        blueprints.find { |bp| bp['name'] == module_name }
      end
    end
    
    public
    
    # Utility methods...
    
    def find_closest_resource_source(resource)
      # Find settlements that have this resource available for trade
      # For now, return a mock settlement - in real implementation this would search the database
      Settlement::BaseSettlement.where.not(id: @settlement.id).first
    end
    
    def create_interplanetary_contract(source_settlement, resource)
      # Create an interplanetary trade contract
      # This would normally create a Logistics::InterplanetaryContract record
      Rails.logger.info "[AI] Creating interplanetary contract for #{resource} from #{source_settlement.name}"
      # Implementation would create the actual contract
    end
    
    def calculate_critical_resource_needs(resource)
      case resource
      when 'Oxygen'
        @settlement.current_population * 0.84 # kg per day per person
      when 'Water'
        @settlement.current_population * 2.5 # liters per day per person
      when 'Food'
        @settlement.current_population * 1.8 # kg per day per person
      else
        0
      end
    end
  end
end