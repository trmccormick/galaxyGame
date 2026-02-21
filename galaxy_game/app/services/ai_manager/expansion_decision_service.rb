        # Legendary Pair exclusion logic
        LEGENDARY_PAIRS = ["DJEW-716790", "FR-488530"].freeze

        def legendary_anomaly?(system)
          LEGENDARY_PAIRS.include?(system[:anomaly_id])
        end
    # Route Optimization: Maintenance Cost vs. Transit Revenue
    def optimize_routes(systems)
      systems.each do |system|
        next if legendary_anomaly?(system)
        maintenance_cost = system[:maintenance_cost] || 0
        transit_revenue = system[:transit_revenue] || 0
        if maintenance_cost > transit_revenue
          system[:recall_decommission] = true
        else
          system[:recall_decommission] = false
        end
      end
    end
# ExpansionDecisionService
# Scores scouted systems and determines expansion or Hammer Protocol

module AIManager
  class ExpansionDecisionService
    PRIZE_THRESHOLD = 0.7
    LEGENDARY_SYSTEM_IDS = %w[djew-716790 fr-488530]

    def initialize(systems)
      @systems = systems
    end

    def evaluate_systems
      @systems.each do |system|
        if legendary_anomaly?(system)
          system[:expansion_strategy] = :legendary
          system[:lore_log] = "The sensors are flat. No flux, no decay. It shouldn't be possible, but the link is perfect."
          next
        end
        score = score_system(system)
        if score >= PRIZE_THRESHOLD
          system[:expansion_strategy] = :natural_anchor
        else
          system[:expansion_strategy] = :hammer_protocol
        end
      end
    end

    def score_system(system)
      # Example: weighted sum of terraformable, resource, risk
      terraformable = system[:terraformable] ? 0.5 : 0.0
      resource = (system[:resource_score] || 0) * 0.4
      risk = (system[:risk_score] || 0) * -0.3
      terraformable + resource + risk
    end

    def legendary_anomaly?(system)
      system[:permanent_pair] && LEGENDARY_SYSTEM_IDS.include?(system[:system_id]) &&
        system[:em_bloom_rate] == 0 && system[:stability_decay] == 0
    end
  end
end
