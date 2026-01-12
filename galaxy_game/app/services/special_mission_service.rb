class SpecialMissionService
  # Service for generating SpecialMission objects when NPC needs are critical
  # Rewards: GCC (based on EAP) + specific bonus to attract player intervention

  def self.generate_critical_mission(settlement, material, required_quantity, urgency_level = :high)
    return nil unless should_generate_mission?(settlement, material, required_quantity)

    eap_price = Market::NpcPriceCalculator.send(:calculate_eap_ceiling, settlement, material)
    return nil unless eap_price

    # Calculate reward based on EAP + bonus
    base_reward = eap_price * required_quantity
    bonus_multiplier = calculate_bonus_multiplier(urgency_level)
    total_reward = base_reward * bonus_multiplier

    mission = SpecialMission.create!(
      settlement: settlement,
      material: material,
      required_quantity: required_quantity,
      reward_eap: total_reward,
      bonus_multiplier: bonus_multiplier,
      operational_data: {
        urgency_level: urgency_level,
        generated_at: Time.current,
        reason: 'critical_npc_need',
        expires_at: calculate_expiry_time(urgency_level)
      }
    )

    Rails.logger.info "[SpecialMission] Generated critical mission #{mission.id} for #{required_quantity} #{material} at #{settlement.name}"
    mission
  end

  def self.check_and_generate_missions
    Settlement::BaseSettlement.find_each do |settlement|
      check_settlement_needs(settlement)
    end
  end

  private

  def self.should_generate_mission?(settlement, material, required_quantity)
    # Check if settlement has critical shortage
    current_amount = settlement.inventory&.current_storage_of(material) || 0
    return false if current_amount >= required_quantity

    # Check if internal logistics can handle it
    internal_can_handle = check_internal_logistics_capacity(settlement, material, required_quantity - current_amount)
    return false if internal_can_handle

    # Check if there's already an open mission for this material
    existing_mission = SpecialMission.where(settlement: settlement, material: material, status: :open).exists?
    !existing_mission
  end

  def self.check_internal_logistics_capacity(settlement, material, shortfall)
    # Check if any allied settlements can provide this material
    # For now, return false (simplified - would need to implement alliance/trade agreement logic)
    false
  end

  def self.calculate_bonus_multiplier(urgency_level)
    case urgency_level
    when :critical
      2.0   # 100% bonus
    when :high
      1.5   # 50% bonus
    when :medium
      1.2   # 20% bonus
    else
      1.1   # 10% bonus
    end
  end

  def self.calculate_expiry_time(urgency_level)
    case urgency_level
    when :critical
      1.hour.from_now
    when :high
      6.hours.from_now
    when :medium
      24.hours.from_now
    else
      48.hours.from_now
    end
  end

  def self.check_settlement_needs(settlement)
    critical_materials = %w[oxygen water food]

    critical_materials.each do |material|
      required = calculate_required_amount(settlement, material)
      current = settlement.inventory&.current_storage_of(material) || 0

      if current < required * 0.1 # Critical: less than 10% of required
        generate_critical_mission(settlement, material, required - current, :critical)
      elsif current < required * 0.3 # High: less than 30% of required
        generate_critical_mission(settlement, material, required - current, :high)
      end
    end
  end

  def self.calculate_required_amount(settlement, material)
    # Simplified calculation based on settlement size
    base_amounts = {
      'oxygen' => 1000,
      'water' => 500,
      'food' => 200
    }

    base = base_amounts[material] || 100
    population_multiplier = settlement.population&.size || 1

    base * population_multiplier
  end
end