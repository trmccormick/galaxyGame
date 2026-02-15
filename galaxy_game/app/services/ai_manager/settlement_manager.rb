# app/services/ai_manager/settlement_manager.rb
module AIManager
  class SettlementManager
    attr_reader :settlement, :strategy_selector, :current_priorities,
                :capabilities, :expansion_plans

    def initialize(settlement, shared_context)
      @settlement = settlement
      @shared_context = shared_context
      @strategy_selector = StrategySelector.new(shared_context, ServiceCoordinator.new(shared_context))
      @current_priorities = []
      @capabilities = {}
      @expansion_plans = []
      @resource_requests = []

      initialize_capabilities
    end

    # Get current settlement resources
    def settlement_resources
      # This would query the settlement's inventory
      # For now, return a mock structure
      {
        minerals: 100,
        energy: 80,
        food: 60,
        water: 70,
        steel: 40,
        electronics: 30
      }
    end

    # Get settlement health score
    def settlement_health
      # Calculate overall settlement health
      # This would be based on population, resources, infrastructure, etc.
      0.75 # Mock value
    end

    # Collect resource requests from this settlement
    def collect_resource_requests
      # Get requests from strategy selector or settlement needs
      requests = @strategy_selector.evaluate_next_action(@settlement)

      # Convert to standardized request format
      [{
        settlement_id: @settlement.id,
        resource: requests[:resources]&.first || :energy,
        quantity: 50, # Mock quantity
        priority: requests[:priority] || :medium,
        requester: self
      }]
    end

    # Execute resource allocation for this settlement
    def execute_resource_allocation(allocation)
      Rails.logger.info "[SettlementManager] Executing allocation for #{@settlement.name}: #{allocation}"

      # This would trigger actual resource allocation logic
      # For now, just log
    end

    # Evaluate opportunities for this settlement
    def evaluate_opportunities(system_state)
      # Analyze settlement-specific opportunities
      opportunities = []

      # Check for expansion opportunities
      if settlement_health > 0.7 && system_state.system_health[:overall_score] > 0.6
        opportunities << {
          type: :expansion,
          settlement_id: @settlement.id,
          priority: :medium,
          location: @settlement.location&.celestial_body&.name,
          resources_required: [:steel, :electronics],
          timeline: :short_term
        }
      end

      # Check for resource opportunities
      resource_gaps = identify_resource_gaps
      if resource_gaps.any?
        opportunities << {
          type: :resource_acquisition,
          settlement_id: @settlement.id,
          priority: :high,
          resources_needed: resource_gaps,
          timeline: :immediate
        }
      end

      opportunities
    end

    # Update expansion plans for this settlement
    def update_expansion_plans(plans)
      @expansion_plans = plans
      Rails.logger.info "[SettlementManager] Updated expansion plans for #{@settlement.name}: #{plans.size} plans"
    end

    # Get settlement priority level
    def priority_level
      health = settlement_health

      if health < 0.3
        :critical
      elsif health < 0.5
        :high
      elsif health < 0.7
        :medium
      else
        :low
      end
    end

    # Check if settlement can contribute resources
    def can_contribute_resource?(resource, quantity)
      current = settlement_resources[resource] || 0
      current >= quantity
    end

    # Reserve resources for transfer
    def reserve_resources(resource, quantity)
      # This would mark resources as reserved for transfer
      Rails.logger.info "[SettlementManager] Reserved #{quantity} #{resource} for transfer from #{@settlement.name}"
      true
    end

    # Release reserved resources
    def release_resources(resource, quantity)
      # This would release reserved resources
      Rails.logger.info "[SettlementManager] Released #{quantity} #{resource} reservation from #{@settlement.name}"
    end

    private

    # Initialize settlement capabilities
    def initialize_capabilities
      @capabilities = {
        resource_acquisition: true,
        scouting: @settlement.settlement_type == 'outpost', # Example capability logic
        building: begin
                    @settlement.structures.where(structure_type: 'construction_facility').any?
                  rescue
                    false
                  end,
        expansion: settlement_health > 0.6
      }
    end

    # Identify resource gaps for this settlement
    def identify_resource_gaps
      gaps = []
      optimal_levels = { minerals: 100, energy: 100, food: 100, water: 100 }

      optimal_levels.each do |resource, optimal|
        current = settlement_resources[resource] || 0
        if current < optimal * 0.5 # Less than 50% of optimal
          gaps << resource
        end
      end

      gaps
    end
  end
end