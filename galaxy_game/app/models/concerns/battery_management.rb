# app/models/concerns/battery_management.rb (DEDICATED VERSION)
module BatteryManagement
  extend ActiveSupport::Concern

  included do
    if defined?(ActiveRecord::Base) && self < ActiveRecord::Base
      attribute :operational_data, :jsonb, default: -> { {} } unless method_defined?(:operational_data)
      after_initialize :initialize_battery_data, if: :new_record?
    end
  end

  # Initializes default battery data within operational_data.
  def initialize_battery_data
    operational_data['battery'] ||= {
      'capacity' => 100.0,
      'current_charge' => 100.0,
      'drain_rate' => 1.0
    }
  end

  # Returns the current charge level of the battery.
  def battery_level
    operational_data.dig('battery', 'current_charge') || battery_capacity
  end

  # Returns the maximum capacity of the battery.
  def battery_capacity
    operational_data.dig('battery', 'capacity') || 100.0
  end

  # Returns the current battery charge as a percentage (0-100).
  def battery_percentage
    return 0.0 if battery_capacity.zero? # Avoid division by zero
    (battery_level.to_f / battery_capacity) * 100.0
  end


  # Returns the max charge rate (kW) for this battery. Override in including class if needed.
  def max_charge_rate
    operational_data.dig('battery', 'max_charge_rate_kw')
  end

  # Returns the max discharge rate (kW) for this battery. Override in including class if needed.
  def max_discharge_rate
    operational_data.dig('battery', 'max_discharge_rate_kw')
  end

  # Charges the battery by the specified amount, respecting max charge rate and capacity.
  # Returns the amount actually charged.
  def charge_battery(amount)
    return 0.0 if amount.nil? || amount <= 0
    operational_data['battery'] ||= {}
    current = battery_level
    capacity = battery_capacity
    max_rate = max_charge_rate || amount
    # Limit by max charge rate
    charge_amt = [amount, max_rate].min
    # Don't exceed capacity
    new_charge = [current + charge_amt, capacity].min
    actual_charged = new_charge - current
    operational_data['battery']['current_charge'] = new_charge
    save! if respond_to?(:save!)
    actual_charged
  end

  # Alias for charge_battery
  alias_method :recharge_battery, :charge_battery

  # Discharges the battery by the specified amount, respecting max discharge rate and available charge.
  # Returns the amount actually discharged.
  def discharge_battery(amount)
    return 0.0 if amount.nil? || amount <= 0
    operational_data['battery'] ||= {}
    current = battery_level
    max_rate = max_discharge_rate || amount
    # Limit by max discharge rate and available charge
    discharge_amt = [amount, max_rate, current].min
    operational_data['battery']['current_charge'] = current - discharge_amt
    save! if respond_to?(:save!)
    discharge_amt
  end

  # For compatibility: consume_battery is an alias for discharge_battery
  alias_method :consume_battery, :discharge_battery

  # Returns the inherent constant drain rate of the battery itself (e.g., self-discharge).
  # This is a power rate (kW equivalent) that might be added to total power usage.
  def battery_drain
    operational_data.dig('battery', 'drain_rate') || 1.0
  end
end