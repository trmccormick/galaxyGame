# app/models/concerns/settlement_fees.rb
# Per-Location Market Fee Configuration
# Included by both BaseSettlement and OrbitalSettlement.
# Fees stored in operational_data['fees'] jsonb — set by AI Manager or owner.

module SettlementFees
  extend ActiveSupport::Concern

  def broker_fee_type
    (operational_data || {}).dig('fees', 'broker_fee_type')
  end

  def broker_fee_type=(value)
    self.operational_data ||= {}
    self.operational_data['fees'] ||= {}
    self.operational_data['fees']['broker_fee_type'] = value
  end

  def broker_fee_value
    (operational_data || {}).dig('fees', 'broker_fee_value')
  end

  def broker_fee_value=(value)
    self.operational_data ||= {}
    self.operational_data['fees'] ||= {}
    self.operational_data['fees']['broker_fee_value'] = value
  end

  def transaction_fee_type
    (operational_data || {}).dig('fees', 'transaction_fee_type')
  end

  def transaction_fee_type=(value)
    self.operational_data ||= {}
    self.operational_data['fees'] ||= {}
    self.operational_data['fees']['transaction_fee_type'] = value
  end

  def transaction_fee_value
    (operational_data || {}).dig('fees', 'transaction_fee_value')
  end

  def transaction_fee_value=(value)
    self.operational_data ||= {}
    self.operational_data['fees'] ||= {}
    self.operational_data['fees']['transaction_fee_value'] = value
  end

  def order_duration_min
    (operational_data || {}).dig('fees', 'order_duration_min')
  end

  def order_duration_min=(value)
    self.operational_data ||= {}
    self.operational_data['fees'] ||= {}
    self.operational_data['fees']['order_duration_min'] = value
  end

  def order_duration_max
    (operational_data || {}).dig('fees', 'order_duration_max')
  end

  def order_duration_max=(value)
    self.operational_data ||= {}
    self.operational_data['fees'] ||= {}
    self.operational_data['fees']['order_duration_max'] = value
  end

  # Calculate broker fee for a given transaction amount
  def calculate_broker_fee(amount)
    return 0.0 unless broker_fee_type && broker_fee_value

    case broker_fee_type
    when 'percentage'
      (amount * broker_fee_value / 100.0).round(2)
    when 'fixed'
      broker_fee_value.to_f
    else
      0.0
    end
  end

  # Calculate transaction fee for a given transaction amount
  def calculate_transaction_fee(amount)
    return 0.0 unless transaction_fee_type && transaction_fee_value

    case transaction_fee_type
    when 'percentage'
      (amount * transaction_fee_value / 100.0).round(2)
    when 'fixed'
      transaction_fee_value.to_f
    else
      0.0
    end
  end

  # Default fee configuration (can be overridden by AI Manager)
  def default_fee_configuration
    {
      broker_fee_type: 'percentage',
      broker_fee_value: 5.0,
      transaction_fee_type: 'percentage',
      transaction_fee_value: 2.0,
      order_duration_min: 1,
      order_duration_max: 72
    }
  end

  # Apply default fee configuration to this settlement
  def apply_default_fees!
    defaults = default_fee_configuration
    self.broker_fee_type = defaults[:broker_fee_type]
    self.broker_fee_value = defaults[:broker_fee_value]
    self.transaction_fee_type = defaults[:transaction_fee_type]
    self.transaction_fee_value = defaults[:transaction_fee_value]
    self.order_duration_min = defaults[:order_duration_min]
    self.order_duration_max = defaults[:order_duration_max]
    save!
  end
end
