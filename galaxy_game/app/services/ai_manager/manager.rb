# app/services/ai_manager/manager.rb
require_relative 'shared_context'
require_relative 'service_coordinator'
require 'structures'

module AIManager
  class Manager
    def initialize(target_entity:) # Changed to target_entity
      @target_entity = target_entity # This could be a Lavatube or an existing Settlement
      # Ensure you have access to GameDataGenerator instance,
      # maybe passed in or initialized here.
      @game_data_generator = Generators::GameDataGenerator.new # Or inject it via initializer

      # Initialize service coordination system
      initialize_service_coordination
    end

    def advance_time
      Rails.logger.info "[AI] Tick for #{@target_entity.name}"

      # Update economic metrics in shared context
      @service_coordinator.update_economic_metrics(@target_entity) if @target_entity.is_a?(Settlement::BaseSettlement)

      # Process any pending missions and resource requests
      @service_coordinator.process_pending_missions
      @service_coordinator.process_resource_requests

      # Logic to determine if initial construction is needed
      # This assumes @target_entity is a Lavatube or a nascent Settlement
      if @target_entity.respond_to?(:settlement_type) && @target_entity.settlement_type.nil? && !settlement_established?(@target_entity)
        run_initial_construction(@target_entity)
      elsif @target_entity.is_a?(Settlement::BaseSettlement) && needs_expansion?(@target_entity)
        run_expansion_plan(@target_entity)
      end
      # ... other AI logic
    end

    # Public interface for service coordination
    def start_mission(mission_data)
      @service_coordinator.start_mission(mission_data)
    end

    def advance_mission(mission_id)
      @service_coordinator.advance_mission(mission_id)
    end

    def get_mission_status(mission_id)
      @service_coordinator.get_mission_status(mission_id)
    end

    def acquire_resource(material, quantity)
      @service_coordinator.acquire_resource(material, quantity, @target_entity)
    end

    def check_resource_availability(material)
      @service_coordinator.check_resource_availability(material, @target_entity)
    end

    def scout_system(system_data = nil)
      @service_coordinator.scout_system(system_data)
    end

    def get_scouting_results(system_id = nil)
      @service_coordinator.get_scouting_results(system_id)
    end

    def queue_mission(mission_data)
      @shared_context.queue_mission(mission_data)
    end

    def request_resource(material, quantity, priority = :normal)
      @shared_context.request_resource(material, quantity, priority)
    end

    private

    def initialize_service_coordination
      # Initialize shared context
      @shared_context = SharedContext.new(settlement: @target_entity.is_a?(Settlement::BaseSettlement) ? @target_entity : nil)

      # Initialize service coordinator
      @service_coordinator = ServiceCoordinator.new(@shared_context)

      Rails.logger.info "[AI] Initialized service coordination for #{@target_entity.name}"
    end

    private

    # For new settlements (Lavatube is the context)
    def run_initial_construction(lavatube)
      Rails.logger.info "[AI] Evaluating initial construction needs for #{lavatube.name}"

      planner = AIManager::LlmPlannerService.new(
        settlement_or_location_context: lavatube,
        game_data_generator: @game_data_generator
      )
      initial_plan = planner.generate_initial_construction_plan

      if initial_plan
        Rails.logger.info "[AI] LLM generated initial plan: #{initial_plan['plan_name']}. Strategy: #{initial_plan['overall_strategy_notes']}"

        # Create the initial settlement if needed
        settlement = Settlement::BaseSettlement.find_by(location: lavatube.location) ||
                    establish_settlement_from_plan(lavatube, initial_plan)

        # Update shared context with new settlement
        @shared_context.settlement = settlement

        # Initialize production manager
        production_manager = AIManager::ProductionManager.new(settlement)

        # Manage resources for the construction plan
        resource_management = production_manager.manage_resources_for_construction(initial_plan)

        # Use service coordinator for any missing resources
        resource_management[:missing_materials].each do |material, quantity|
          Rails.logger.info "[AI] Requesting missing material via coordinator: #{material} x#{quantity}"
          @service_coordinator.acquire_resource(material, quantity, settlement)
        end

        Rails.logger.info "[AI] Resource management complete. Required: #{resource_management[:required_materials].size} materials, Missing: #{resource_management[:missing_materials].size} materials"

        # The production manager will have created the necessary construction jobs
        # and managed resources, so we don't need to create jobs here anymore

        # Return the created settlement and plan
        {
          settlement: settlement,
          plan: initial_plan,
          resource_management: resource_management
        }
      else
        Rails.logger.warn "[AI] LLM failed to generate an initial plan."
        nil
      end
    end

    # Placeholder: How to determine if a settlement already exists at this location
    def settlement_established?(lavatube)
      # Logic to check if a BaseSettlement already exists linked to this Lavatube
      Settlement::BaseSettlement.exists?(location: lavatube.location) # Example check
    end

    # Placeholder: Logic to actually create the initial BaseSettlement from the plan
    def establish_settlement_from_plan(lavatube, plan)
      # This is where the initial BaseSettlement record is created,
      # linking to the lavatube's location and incorporating LLM's plan elements.
      initial_settlement = Settlement::BaseSettlement.create!(
        name: "#{lavatube.name} Outpost",
        type: "Outpost", # The initial type
        location: lavatube.location,
        description: plan['overall_strategy_notes'], # Use LLM's notes for description
        # Set initial aggregated stats from the plan's targets
        current_population: plan['initial_resource_targets']['population_capacity_target'],
        power_output_mw: plan['initial_resource_targets']['power_output_mw_target'],
        resource_storage_cubic_meters: plan['initial_resource_targets']['resource_storage_cubic_meters_target'],
        # ... other initial attributes
      )
      Rails.logger.info "[AI] Established initial settlement: #{initial_settlement.name}"
      initial_settlement # Return the newly created settlement
    end


    # Example for later expansion
    def needs_expansion?(settlement)
      # Logic based on settlement's current state vs. goals
      max_capacity = settlement.respond_to?(:max_population_capacity) ? settlement.max_population_capacity : 1000
      settlement.current_population >= max_capacity * 0.8 # Needs more space
    end

    def run_expansion_plan(settlement)
      Rails.logger.info "[AI] Deciding on expansion for #{settlement.name}"
      # This would be another LLM call to get an expansion plan,
      # potentially passing current_settlement_state as context.
    end

    def self.fulfill_material_request(request)
      # TODO: Use robots, workforce, or internal production to fulfill the request
      Manufacturing::MaterialRequestSystem.trigger_resource_gathering(
        request.material_name,
        request.quantity,
        request.settlement
      )
      # TODO: Log or notify about NPC fulfillment
      Rails.logger.info "[AIManager] Fulfilled material request for #{request.material_name} at #{request.settlement.name}"
    end
  end
end
