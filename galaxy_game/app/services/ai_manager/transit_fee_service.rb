# TransitFeeService
# Charges GCC per transit ton and distributes dividends to founding corporations

module AIManager
  class TransitFeeService
    def initialize
      @fee_log = []
    end

    def enable_fees(system)
      system[:transit_fees_enabled] = true
      system[:fee_log] ||= []
    end

    def charge_fee(system, tons, corporation)
      return unless system[:transit_fees_enabled]
      fee = calculate_fee(tons)
      log = { corporation: corporation, tons: tons, fee: fee }
      system[:fee_log] << log
      distribute_dividends(system, fee)
      fee
    end

    def calculate_fee(tons)
      (tons * 10).to_i # 10 GCC per ton (example rate)
    end

    def distribute_dividends(system, fee)
      # Example: split fee among founding corporations
      founders = system[:founding_corporations] || []
      return if founders.empty?
      share = fee / founders.size
      founders.each do |corp|
        # In real system, credit corp's account
        system[:dividends] ||= {}
        system[:dividends][corp] ||= 0
        system[:dividends][corp] += share
      end
    end
  end
end
