module AIManager
  class LlmPlannerService
    # This service is responsible for calling the LLM to create large, strategic plans
    # (e.g., initial base layout, phased expansion, defense strategies)
    # based on the Settlement's current state and environment context.
    
    def initialize(settlement_or_location_context:, game_data_generator:)
      @context = settlement_or_location_context # Could be a Lavatube or an existing Settlement
      @game_data_generator = game_data_generator
    end

    def generate_initial_construction_plan
      Rails.logger.info "[LLM Planner] Generating initial construction plan for #{@context.name}"

      # --- 1. CONSTRUCT LLM CONTEXT ---
      # This is crucial: providing the LLM with enough detail about the environment
      llm_params = {
        plan_name: "Initial Setup for #{@context.name}",
        target_settlement_id: @context.id,
        phase: "InitialConstruction",
        # Pass details about the environment to the LLM
        environment_type: "Lava Tube",
        lavatube_details: {
          length: @context.length,
          diameter: @context.diameter,
          skylight_count: @context.skylights.count,
          avg_skylight_diameter: @context.skylights.average(:diameter),
          # Use a rescue in case there are no access points yet
          common_access_type: (@context.access_points.group(:access_type).count.max_by{|k,v| v}&.first || 'none')
        },
        # Describe what kind of plan we need
        planning_goal: "Provide a detailed plan for the absolute initial construction of a basic, self-sufficient base within this lava tube. Focus on essential survival units.",
        desired_unit_types_pool: "Habitat Module, Power Node, Airlock Unit, Water Condenser, Basic Storage Module, Comm Hub"
      }

      # --- 2. CALL LLM AND RETRIEVE PLAN ---
      # Expected output from the LLM is a structured JSON, e.g.:
      # { "plan_id": "...", "steps": [ { "unit_type": "Habitat Module", "count": 1, "location": "..." } ] }
      plan_data = @game_data_generator.generate_item(
        "/home/galaxy_game/app/data/templates/initial_settlement_plan_template.json",
        "/home/galaxy_game/app/data/ai_plans/initial_plan_for_#{@context.name.parameterize}.json",
        llm_params
      )

      # --- 3. APPLY PLAN TO GAME STATE ---
      if plan_data && plan_data['steps']
        parse_and_apply_plan(@context, plan_data)
        Rails.logger.info "[LLM Planner] Successfully generated and applied plan: #{plan_data['plan_id']}"
        return plan_data
      end
      
      Rails.logger.warn "[LLM Planner] LLM generated an invalid or empty plan structure."
      nil # Return nil if the plan is unusable

    rescue StandardError => e
      Rails.logger.error "[LLM Planner] Error generating plan: #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      nil # Return nil or raise a custom error
    end

    private

    # Placeholder method to integrate the LLM's plan into the game's construction system.
    def parse_and_apply_plan(settlement, plan_data)
      plan_data['steps'].each do |step|
        # This is where we would add items to the ConstructionQueue model.
        # The ConstructionQueue would then inform the ResourcePlanner's 'calculate_required_resources' method.
        # Example:
        # ConstructionQueue.create!(
        #   settlement: settlement,
        #   unit_type: step['unit_type'],
        #   quantity: step['count']
        # )
        Rails.logger.debug "Queuing construction: #{step['count']} x #{step['unit_type']}"
      end
    end
  end
end