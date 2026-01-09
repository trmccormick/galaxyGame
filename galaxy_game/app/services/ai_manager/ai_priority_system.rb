module AIManager
  class AiPrioritySystem
  CRITICAL_PRIORITIES = {
    life_support: 1000,
    atmospheric_maintenance: 900,
    debt_repayment: 800
  }

  OPERATIONAL_PRIORITIES = {
    resource_procurement: 500,
    construction: 300,
    expansion: 100
  }

  def initialize
    @last_check = Time.current
  end

  def check_critical(settlement)
    issues = []

    # Life support check
    if life_support_critical?(settlement)
      issues << {
        type: :life_support,
        priority: CRITICAL_PRIORITIES[:life_support],
        resources: critical_resources(settlement)
      }
    end

    # Atmospheric maintenance
    if atmospheric_critical?(settlement)
      issues << {
        type: :atmospheric_maintenance,
        priority: CRITICAL_PRIORITIES[:atmospheric_maintenance]
      }
    end

    # Debt repayment
    if debt_critical?(settlement)
      issues << {
        type: :debt_repayment,
        priority: CRITICAL_PRIORITIES[:debt_repayment],
        amount: outstanding_debt(settlement)
      }
    end

    issues.sort_by { |i| -i[:priority] } # Sort by priority descending
  end

  def check_operational(settlement)
    needs = []

    # Resource procurement
    shortage = resource_shortage(settlement)
    if shortage
      needs << {
        type: :resource_procurement,
        priority: OPERATIONAL_PRIORITIES[:resource_procurement],
        resource: shortage[:resource],
        amount: shortage[:amount]
      }
    end

    # Construction needs
    construction = construction_needs(settlement)
    if construction
      needs << {
        type: :construction,
        priority: OPERATIONAL_PRIORITIES[:construction],
        facility: construction[:facility]
      }
    end

    needs.sort_by { |n| -n[:priority] }
  end

  def can_expand?(settlement)
    # Only expand if no critical issues and operational needs are met
    check_critical(settlement).empty? &&
    check_operational(settlement).empty? &&
    settlement_stable?(settlement)
  end

  private

  def life_support_critical?(settlement)
    critical_resources = [:oxygen, :water, :food]
    critical_resources.any? do |resource|
      level = resource_level(settlement, resource)
      threshold = critical_threshold(resource)
      level < threshold
    end
  end

  def atmospheric_critical?(settlement)
    # Check if atmospheric systems need maintenance
    atmospheric_stability(settlement) < 0.8
  end

  def debt_critical?(settlement)
    debt = outstanding_debt(settlement)
    funds = settlement_funds(settlement)
    debt > funds * 0.5 # Debt > 50% of available funds
  end

  def settlement_stable?(settlement)
    !life_support_critical?(settlement) &&
    !debt_critical?(settlement) &&
    resource_levels_adequate?(settlement)
  end

  def critical_resources(settlement)
    [:oxygen, :water, :food].select do |resource|
      resource_level(settlement, resource) < critical_threshold(resource)
    end
  end

  # Placeholder methods - would be implemented based on actual settlement model
  def resource_level(settlement, resource)
    # Placeholder implementation
    case resource
    when :oxygen then 75
    when :water then 60
    when :food then 80
    else 100
    end
  end

  def critical_threshold(resource)
    25 # 25% is critical for all resources
  end

  def atmospheric_stability(settlement)
    0.9 # Placeholder - 90% stable
  end

  def outstanding_debt(settlement)
    0 # Placeholder - no debt
  end

  def settlement_funds(settlement)
    100000 # Placeholder - 100K GCC available
  end

  def resource_shortage(settlement)
    # Check for resource shortages
    # Placeholder - return nil (no shortage)
    nil
  end

  def construction_needs(settlement)
    # Check if settlement needs new facilities
    # Placeholder - return nil (no construction needed)
    nil
  end

  def resource_levels_adequate?(settlement)
    # Check if all resource levels are above minimum thresholds
    [:oxygen, :water, :food].all? do |resource|
      resource_level(settlement, resource) > 50 # 50% minimum
    end
  end
end
end