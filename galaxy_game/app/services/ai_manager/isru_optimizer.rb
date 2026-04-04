# app/services/ai_manager/isru_optimizer.rb
#
# ISRU Optimizer — Produces a phased ISRU deployment plan for a settlement.
#
# Reads:
#   - Market::Order unfilled buy queue  (what compounds are demanded)
#   - AIManager::ISRUEvaluator#assess_capabilities  (what ISRU units/resources exist)
#
# Returns a phase list covering only the gaps between what is demanded and
# what the settlement's current ISRU chain already produces.
#
# Phase chain follows real planetary ISRU physics:
#   Phase 1 (power) — handled by evaluator :blocked passthrough
#   Phase 2 — Raw regolith supply
#   Phase 3 — Thermal extraction unit (TEU): 300–800°C heats regolith → mixed volatiles
#   Phase 4 — Planetary volatiles extractor (PVE): separates H2O, CO2, N2 from mixed volatiles
#   Phase 5 — Gas conversion unit (GCU): CO2 + 2H2O → CH4 + 2O2 (Sabatier+electrolysis)

module AIManager
  class IsruOptimizer
    # Each phase is selected when its :needed_if lambda returns true.
    # Ordered by physical dependency — lower phase number must deploy before higher.
    DEPLOYMENT_CHAIN = [
      {
        phase:       2,
        name:        :regolith_supply,
        description: 'Establish raw regolith supply via surface mining rover — feedstock for all regolith-based ISRU',
        needed_if:   ->(caps, _orders) {
          caps.dig(:resource_availability, :raw_regolith).to_f < 100
        }
      },
      {
        phase:       3,
        name:        :thermal_extraction,
        description: 'Deploy thermal extraction unit — resistive heating 300–800°C drives volatile compounds off regolith as mixed gas',
        needed_if:   ->(caps, _orders) {
          !caps[:teu_present]
        }
      },
      {
        phase:       4,
        name:        :volatile_separation,
        description: 'Deploy planetary volatiles extractor — separates H2O, CO2, and N2 from heated mixed volatiles',
        needed_if:   ->(caps, _orders) {
          !caps[:regolith_processing]
        }
      },
      {
        phase:       5,
        name:        :gas_conversion,
        description: 'Deploy gas conversion unit — integrated Sabatier+electrolysis: CO2 + 2H2O → CH4 + 2O2',
        needed_if:   ->(caps, orders) {
          orders.any? { |o| %w[CH4 O2].include?(o.resource) } && !caps[:methane_generation]
        }
      }
    ].freeze

    def initialize(shared_context)
      @shared_context = shared_context
    end

    # Returns a phased ISRU deployment plan driven by the settlement's unfilled
    # buy orders and current ISRU capability assessment.
    #
    # Return shapes:
    #   { phases: [], reason: :no_unfilled_orders }   — no pending buy orders
    #   { phases: [], reason: :all_satisfied, production_rates: {...} }
    #   evaluator blocked hash                         — power insufficient
    #   { phases: [...], demanded: [...], production_rates: {...}, ... }
    def optimize_isru_priorities(settlement)
      orders = open_buy_orders(settlement)
      return { phases: [], reason: :no_unfilled_orders } if orders.empty?

      capabilities = AIManager::ISRUEvaluator.new(settlement).assess_capabilities
      return capabilities if capabilities[:status] == :blocked

      phases = needed_phases(capabilities, orders)

      if phases.empty?
        return { phases: [], reason: :all_satisfied,
                 production_rates: capabilities[:production_rates] }
      end

      {
        phases:            phases,
        demanded:          orders.map(&:resource).compact.uniq,
        production_rates:  capabilities[:production_rates],
        overall_readiness: capabilities[:overall_readiness],
        recommendations:   capabilities[:recommendations]
      }
    end

    private

    def open_buy_orders(settlement)
      Market::Order
        .where(base_settlement: settlement)
        .buy
        .reject { |o| o.fulfilled? || o.expired? }
    end

    def needed_phases(capabilities, orders)
      DEPLOYMENT_CHAIN
        .select { |spec| spec[:needed_if].call(capabilities, orders) }
        .map    { |spec| spec.reject { |k, _| k == :needed_if } }
    end
  end
end

