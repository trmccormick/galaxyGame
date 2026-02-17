# HammerProtocol
# Schedules high-mass transit to breach $M_{max}$ and force Sol-side exit shift

module AIManager
  class HammerProtocol
    def initialize(system, wormhole_manager)
      @system = system
      @wormhole_manager = wormhole_manager
    end

    def execute
      return false if legendary_anomaly?(@system)
      # Simulate high-mass transit to breach $M_{max}$
      @system[:current_mass] = @system[:instability_threshold] + 1
      @wormhole_manager.execute_shift_discharge(@system)
      true
    end

    def legendary_anomaly?(system)
      AIManager::ExpansionDecisionService::LEGENDARY_SYSTEM_IDS.include?(system[:system_id]) &&
        system[:permanent_pair] && system[:em_bloom_rate] == 0 && system[:stability_decay] == 0
    end
  end
end
