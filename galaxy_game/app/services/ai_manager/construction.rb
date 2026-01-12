module AIManager
  class Construction
    # This class handles the construction queue, translating high-level plans 
    # (from LLMPlannerService) and immediate operational needs (from DecisionTree)
    # into actionable jobs for the Builder component.
    
    def initialize(settlement, builder)
      @settlement = settlement
      @builder = builder # The component that actually executes the build/repair job
    end

    # --- PUBLIC API FOR LLM PLANNER SERVICE ---
    
    # Receives a single step from the LLM's generated plan and queues it.
    # This is the primary consumption point for strategic planning.
    # @param unit_type [String] e.g., 'Habitat Module'
    # @param quantity [Integer] Number of units to build
    # @param location [Object] Optional location/zone data
    def queue_construction_step(unit_type, quantity, location: nil)
      # Logic: Create a ConstructionQueue entry for the Builder to pick up.
      Rails.logger.info "[Construction] Queuing strategic build: #{quantity} x #{unit_type}."
      
      # Example: ConstructionQueue.create!(settlement: @settlement, unit: unit_type, count: quantity, priority: :medium)
    end
    
    # --- PUBLIC API FOR DECISION TREE (EMERGENCY) ---

    # Generates and queues a high-priority, small-scale fix during an emergency.
    # Bypasses the full LLM planning cycle.
    def queue_emergency_fix(problem_type, required_unit_type, required_count)
      Rails.logger.fatal "[Construction] EMERGENCY FIX: Queuing #{required_count} x #{required_unit_type} for #{problem_type}."
      
      # This job is given the highest priority level
      # Example: ConstructionQueue.create!(settlement: @settlement, unit: required_unit_type, count: required_count, priority: :critical)
      
      queue_construction_step(required_unit_type, required_count, location: 'critical_zone')
    end

    # --- OPERATIONAL ASSESSMENT (Used by DecisionTree for state checks) ---

    # Check the status of all ongoing construction jobs
    def construction_status
      # NOTE: Assuming ConstructionJob model exists
      jobs = @settlement.construction_jobs.active rescue []
      
      {
        total_jobs: jobs.count,
        by_type: jobs.group(:job_type).count,
        waiting_for_materials: jobs.where(status: 'materials_pending').count,
        in_progress: jobs.where(status: 'in_progress').count,
        estimated_completion: jobs.in_progress.order(:estimated_completion).first&.estimated_completion
      }
    end

    # Check if the settlement needs operational (non-strategic) construction types
    def operational_needs_assessment
      {
        # Assessment for immediate, non-planned needs
        needs_immediate_power: immediate_power_assessment,
        needs_immediate_habitat: immediate_habitat_assessment,
        # ... other operational checks
      }
    end

    private
    
    def immediate_habitat_assessment
      current_population = @settlement.current_population
      max_capacity = @settlement.max_population_capacity rescue 0
      
      # Habitat is critical if we are over capacity (100%)
      current_population >= max_capacity
    end
    
    def immediate_power_assessment
      current_usage = @settlement.power_usage_mw rescue 0
      current_production = @settlement.power_output_mw rescue 0
      
      # Power is critical if production is less than current usage
      current_usage >= current_production
    end

    # The user's original calculation methods (simplified, as they are now rarely used for the main loop)
    # def calculate_habitat_count_needed ...
    # def calculate_power_count_needed ...
  end
end