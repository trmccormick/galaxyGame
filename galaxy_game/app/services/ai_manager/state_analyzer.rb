
# CRITICAL BUG FIX: Remove hardcoded resource_profile, delegate to live models
module AIManager
  class StateAnalyzer
    def analyze_state(settlement)
      result = {
        unfilled_buy_orders: Market::Order.where(
          settlement: settlement,
          order_type: :buy,
          status: :open
        ).order(created_at: :asc),
        inventory: settlement.inventory,
        surface_storage: settlement.surface_storage,
        power_available: calculate_power_available(settlement)
      }
      
      begin
        # Aggregate cost analysis across critical resources
        cost_data = aggregate_cost_analysis(settlement, result[:unfilled_buy_orders])
        result[:cost_analysis] = {
          viable: cost_data[:viable],           # Boolean — can we optimize costs?
          cost_pressure: cost_data[:pressure],  # Float 0.0-1.0 — how urgent is cost reduction?
          recommendations: cost_data[:recs]     # Array of resource names to produce locally
        }
      rescue => e
        Rails.logger.warn "[StateAnalyzer] Cost analysis failed: #{e.message}"
        result[:cost_analysis] = { viable: false, cost_pressure: 0.0, recommendations: [] }
      end
      
      result
    end

    private

    def calculate_power_available(settlement)
      settlement.base_units
                .select(&:operational?)
                .sum { |u| unit_power_output(u) }
    end

    def unit_power_output(unit)
      Lookup::UnitLookupService.new
        .find_unit(unit.unit_type)
        &.dig('operational_properties', 'power_output_kw')
        .to_f
    end

    def aggregate_cost_analysis(settlement, unfilled_buy_orders)
      # Get unique material names from unfilled_buy_orders
      resource_names = unfilled_buy_orders.map(&:resource_name).uniq.compact
      
      # Return safe defaults if no resources to analyze
      return { viable: true, cost_pressure: 0.0, recs: [] } if resource_names.empty?
      
      import_count = 0
      total_analyzed = 0
      recommendations = []
      
      resource_names.each do |resource_name|
        begin
          cost_result = Settlements::CostAnalyzer.compare_costs(resource_name, settlement)
          
          # Skip if error occurred
          next if cost_result[:recommendation] == :error
          
          total_analyzed += 1
          
          # Count import recommendations for pressure score
          if cost_result[:recommendation] == :import
            import_count += 1
          end
          
          # Collect resources where local production is cheaper
          if cost_result[:recommendation] == :produce_locally
            recommendations << resource_name
          end
          
        rescue Settlements::CostAnalyzer::ResourceNotFoundError => e
          # Skip resources that raise ResourceNotFoundError, log and continue
          Rails.logger.debug "[StateAnalyzer] Skipping #{resource_name}: #{e.message}"
          next
        end
      end
      
      # Calculate pressure score as ratio of import recommendations
      pressure = total_analyzed > 0 ? (import_count.to_f / total_analyzed) : 0.0
      
      {
        viable: total_analyzed > 0,
        cost_pressure: pressure,
        recs: recommendations
      }
    end
  end
end