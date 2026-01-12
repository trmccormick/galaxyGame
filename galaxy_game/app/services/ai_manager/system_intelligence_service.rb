module AIManager
  class SystemIntelligenceService
    attr_reader :celestial_body

    def initialize(celestial_body)
      @celestial_body = celestial_body
    end

    # ========== MAIN INTERFACE METHODS ==========

    def system_status
      operational_structures = structures_in_system.select(&:operational?)
      total_structures = structures_in_system.count
      overall_ratio = total_structures > 0 ? operational_structures.count.to_f / total_structures : 0.0

      {
        operational_structures: operational_structures,
        operational_ratio: overall_ratio.round(3),
        status: overall_ratio < 0.5 ? :critical : overall_ratio < 0.8 ? :warning : :healthy
      }
    end

    def narrative_status
      status = system_status
      ratio = status[:operational_ratio]

      case status[:status]
      when :critical
        "System #{celestial_body.name} is in critical condition with only #{(ratio * 100).round}% operational infrastructure. Immediate intervention required."
      when :warning
        "System #{celestial_body.name} shows warning signs with #{(ratio * 100).round}% operational infrastructure. Monitor closely."
      else
        "System #{celestial_body.name} is healthy with #{(ratio * 100).round}% operational infrastructure."
      end
    end

    def licensing_runway
      ssc = find_system_specific_corp
      return nil unless ssc

      usd_balance = Financial::Account.find_by(accountable: ssc, currency: Financial::Currency.find_by(symbol: 'USD'))&.balance || 0
      daily_fee = calculate_average_daily_transit_fee

      return Float::INFINITY if daily_fee.zero?

      (usd_balance / daily_fee).round(1)
    end

    def sustainability_delta
      # Calculate if system is producing more than consuming
      production = calculate_total_production
      consumption = calculate_total_consumption

      production - consumption
    end

    def logistics_efficiency
      settlements = settlements_in_system
      contracts = Logistics::Contract.where(
        from_settlement_id: settlements.pluck(:id)
      ).or(
        Logistics::Contract.where(to_settlement_id: settlements.pluck(:id))
      )

      return 0.0 if contracts.empty?

      fulfilled = contracts.where(status: :delivered).count
      fulfilled.to_f / contracts.count
    end

    def economic_health_score
      ssc = find_system_specific_corp
      return 0 unless ssc

      gcc_balance = Financial::Account.find_by(accountable: ssc, currency: Financial::Currency.find_by(symbol: 'GCC'))&.balance || 0
      usd_balance = Financial::Account.find_by(accountable: ssc, currency: Financial::Currency.find_by(symbol: 'USD'))&.balance || 0

      calculate_economic_health_score(gcc_balance, usd_balance)
    end

    # Query off-market transfer volume for system intelligence
    def off_market_volume(time_range = 30.days.ago..Time.current)
      Financial::VirtualLedgerService.off_market_volume(celestial_body, time_range)
    end

    # Price comparison report: local currency vs global reserve
    def local_price_report(item_id, local_currency = 'MCC')
      exchange_service = Financial::ExchangeRateService.new
      global_price = exchange_service.price_for(item_id, 'GCC')
      local_price = exchange_service.price_for(item_id, local_currency)

      {
        item_id: item_id,
        global_reserve_price: global_price,
        local_currency_price: local_price,
        local_currency: local_currency,
        price_ratio: local_price && global_price ? (local_price / global_price).round(3) : nil
      }
    end

    # ========== HELPER METHODS ==========

    def find_system_specific_corp
      Organizations::BaseOrganization.find_by(
        identifier: "#{celestial_body.name.parameterize.upcase}_DEV_CORP"
      )
    end

    def settlements_in_system
      Settlement::BaseSettlement.joins(:location).where(celestial_locations: { celestial_body: celestial_body })
    end

    def structures_in_system
      Structures::BaseStructure.where(settlement_id: settlements_in_system.pluck(:id))
    end

    def celestial_locations
      Location::CelestialLocation.where(celestial_body: celestial_body)
    end

    def calculate_average_daily_transit_fee
      # Estimate based on system activity
      # This is a simplified calculation - in reality would analyze transit logs
      base_fee_per_day = 1000.0 # $1000/day baseline

      # Scale based on system development
      settlement_count = settlements_in_system.count
      activity_multiplier = [1.0, settlement_count / 5.0].max

      base_fee_per_day * activity_multiplier
    end

    def calculate_total_production
      # Simplified - would sum up all production outputs
      structures_in_system.sum do |structure|
        structure.operational_data&.dig('production', 'total_output') || 0
      end
    end

    def calculate_total_consumption
      # Simplified - would sum up all consumption inputs
      structures_in_system.sum do |structure|
        structure.operational_data&.dig('consumption', 'total_input') || 0
      end
    end

    def calculate_economic_health_score(gcc_balance, usd_balance)
      # Simple scoring algorithm
      gcc_score = [gcc_balance / 100000.0 * 50, 50].min # Max 50 points for GCC
      usd_score = [usd_balance / 100000.0 * 50, 50].min # Max 50 points for USD

      (gcc_score + usd_score).round
    end
  end
end