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

  # Consumes a specified amount of battery charge.
  # Automatically saves the record if it's an ActiveRecord object.
  def consume_battery(amount)
    return if amount.nil? || amount <= 0

    operational_data['battery'] ||= {} # Ensure battery hash exists
    current = battery_level
    new_level = [current - amount, 0.0].max # Charge cannot go below zero
    operational_data['battery']['current_charge'] = new_level

    save if respond_to?(:save) # Save if the including class is an ActiveRecord model
  end

  # Recharges the battery by a specified amount.
  # Automatically saves the record if it's an ActiveRecord object.
  def recharge_battery(amount)
    return if amount.nil? || amount <= 0

    operational_data['battery'] ||= {} # Ensure battery hash exists
    current = battery_level
    max_capacity = battery_capacity
    new_level = [current + amount, max_capacity].min
    operational_data['battery']['current_charge'] = new_level

    save if respond_to?(:save) # Save if the including class is an ActiveRecord model
  end

  # Alias for recharge_battery, providing an alternative method name.
  alias charge_battery recharge_battery

  # Returns the inherent constant drain rate of the battery itself (e.g., self-discharge).
  # This is a power rate (kW equivalent) that might be added to total power usage.
  def battery_drain
    operational_data.dig('battery', 'drain_rate') || 1.0
  end
end