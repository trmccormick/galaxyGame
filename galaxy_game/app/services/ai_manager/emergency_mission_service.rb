module AIManager
  class EmergencyMissionService
    EMERGENCY_REWARD_MULTIPLIER = 2.0
    BASE_DURATION_HOURS = 24

    def self.create_emergency_mission(settlement, resource_type)
      return nil unless qualifies_for_emergency?(settlement, resource_type)

      reward = calculate_emergency_reward(resource_type)
      return nil unless settlement_can_afford_reward?(settlement, reward)

      mission = create_mission_record(settlement, resource_type, reward)
      broadcast_to_players(mission)

      Rails.logger.info "[EmergencyMissionService] Created emergency mission: #{mission.id} for #{resource_type}"
      mission
    end

    private

    def self.qualifies_for_emergency?(settlement, resource_type)
      # Check if resource is survival-critical
      survival_resources = [:oxygen, :water, :food]
      return false unless survival_resources.include?(resource_type)

      # Check if normal procurement failed
      # This would check recent procurement attempts
      normal_procurement_failed?(settlement, resource_type)
    end

    def self.calculate_emergency_reward(resource_type)
      # Base reward = Earth Anchor Price × quantity × 1.5 × urgency multiplier
      base_price = earth_anchor_price(resource_type)
      quantity_needed = emergency_quantity(resource_type)

      (base_price * quantity_needed * 1.5 * EMERGENCY_REWARD_MULTIPLIER).to_i
    end

    def self.settlement_can_afford_reward?(settlement, reward_amount)
      # Settlement must have sufficient GCC for the reward
      settlement_funds(settlement) >= reward_amount * 1.2 # 20% buffer
    end

    def self.create_mission_record(settlement, resource_type, reward)
      # This would create an actual mission record in the database
      # For now, return a hash representation
      {
        id: "emergency_#{resource_type}_#{Time.current.to_i}",
        settlement_id: settlement.id,
        resource_type: resource_type,
        quantity: emergency_quantity(resource_type),
        reward_gcc: reward,
        expires_at: BASE_DURATION_HOURS.hours.from_now,
        status: :active,
        urgency: :critical,
        created_at: Time.current
      }
    end

    def self.broadcast_to_players(mission)
      # This would broadcast the mission to all players
      # Could use ActionCable, Redis pub/sub, or database notifications
      Rails.logger.info "[EmergencyMissionService] Broadcasting emergency mission #{mission[:id]} to players"

      # Placeholder for actual broadcasting logic
      broadcast_message = {
        type: :emergency_mission,
        mission_id: mission[:id],
        title: "URGENT: #{mission[:resource_type].to_s.titleize} Crisis",
        description: emergency_description(mission),
        reward: mission[:reward_gcc],
        expires_in: BASE_DURATION_HOURS,
        settlement: mission[:settlement_id]
      }

      # In a real implementation, this would go to a broadcasting service
      # BroadcastingService.broadcast_to_players(:emergencies, broadcast_message)
    end

    def self.emergency_description(mission)
      resource_name = mission[:resource_type].to_s.titleize
      quantity = mission[:quantity]
      reward = mission[:reward_gcc]

      "#{resource_name} Crisis at Settlement #{mission[:settlement_id]} - #{quantity} units needed. " \
      "Reward: #{reward} GCC (#{EMERGENCY_REWARD_MULTIPLIER}x bonus for urgency!)"
    end

    # Placeholder methods - would be implemented based on actual models/data
    def self.earth_anchor_price(resource_type)
      # Earth Anchor Prices from pricing system
      prices = {
        oxygen: 500,
        water: 300,
        food: 800
      }
      prices[resource_type] || 100
    end

    def self.emergency_quantity(resource_type)
      # Emergency quantities for survival-critical resources
      quantities = {
        oxygen: 500,    # kg
        water: 1000,    # liters
        food: 200       # meals
      }
      quantities[resource_type] || 100
    end

    def self.normal_procurement_failed?(settlement, resource_type)
      # Check if recent procurement attempts failed
      # This would query procurement history
      # Placeholder - assume procurement can fail
      true
    end

    def self.settlement_funds(settlement)
      # Get settlement's available GCC
      # Placeholder
      100000
    end
  end
end