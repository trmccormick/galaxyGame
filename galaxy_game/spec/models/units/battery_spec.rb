require 'rails_helper'

RSpec.describe Units::Battery, type: :model do
  let(:battery_data) do
    {
      "battery" => {
        "capacity" => 500.0,
        "current_charge" => 400.0,
        "max_charge_rate_kw" => 50.0,
        "max_discharge_rate_kw" => 75.0,
        "efficiency" => 0.95
      }
    }
  end

  let(:battery) do
    described_class.new(
      name: "Test Battery",
      unit_type: "satellite_battery",
      identifier: "BATTERY_001",
      operational_data: battery_data
    )
  end

  before do
    allow(battery).to receive(:save!).and_return(true)
  end

  describe "battery attributes" do
    it "reports correct battery capacity" do
      expect(battery.battery_capacity).to eq(500.0)
    end

    it "reports correct battery level" do
      expect(battery.battery_level).to eq(400.0)
    end

    it "calculates battery percentage correctly" do
      expect(battery.battery_percentage).to eq(80.0)
    end
    
    it "handles zero capacity" do
      battery.operational_data["battery"]["capacity"] = 0
      expect(battery.battery_percentage).to eq(0)
    end
  end

  describe "#charge_battery" do
    it "charges the battery by the specified amount" do
      charged = battery.charge_battery(50.0)
      expect(charged).to eq(50.0)
      expect(battery.battery_level).to eq(450.0)
    end

    it "limits charging to max charge rate" do
      charged = battery.charge_battery(100.0)
      expect(charged).to eq(50.0) # Limited by max_charge_rate_kw
      expect(battery.battery_level).to eq(450.0)
    end

    it "limits charging to battery capacity" do
      battery.operational_data["battery"]["current_charge"] = 480.0
      charged = battery.charge_battery(50.0)
      expect(charged).to eq(20.0) # Limited by remaining capacity
      expect(battery.battery_level).to eq(500.0)
    end
  end

  describe "#discharge_battery" do
    it "discharges the battery by the specified amount" do
      discharged = battery.discharge_battery(50.0)
      expect(discharged).to eq(50.0)
      expect(battery.battery_level).to eq(350.0)
    end

    it "limits discharging to max discharge rate" do
      discharged = battery.discharge_battery(100.0)
      expect(discharged).to eq(75.0) # Limited by max_discharge_rate_kw
      expect(battery.battery_level).to eq(325.0)
    end

    it "limits discharging to available charge" do
      battery.operational_data["battery"]["current_charge"] = 50.0
      discharged = battery.discharge_battery(100.0)
      expect(discharged).to eq(50.0) # Limited by current charge
      expect(battery.battery_level).to eq(0.0)
    end
  end

  describe "interaction with BatteryManagement concern" do
    it "has both specialized and concern methods" do
      # Specialized method
      expect(battery).to respond_to(:discharge_battery)
      
      # Methods from concern
      expect(battery).to respond_to(:recharge_battery)
      expect(battery).to respond_to(:consume_battery)
      expect(battery).to respond_to(:battery_drain)
    end
    
    it "prefers specialized methods over concern methods" do
      # Our specialized charge_battery should be used
      expect(battery).to receive(:charge_battery).with(30.0)
      battery.charge_battery(30.0)
      
      # The alias should now point to our implementation
      expect(battery).to receive(:charge_battery).with(20.0)
      battery.recharge_battery(20.0)
    end
  end
end