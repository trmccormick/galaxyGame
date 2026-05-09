require 'rails_helper'

RSpec.describe Units::Robot, type: :model do
  let(:robot_data) do
    {
      "battery" => {
        "capacity" => 200.0,
        "current_charge" => 100.0,
        "max_charge_rate_kw" => 20.0,
        "max_discharge_rate_kw" => 30.0
      },
      "mobility_type" => "wheels"
    }
  end

  let(:robot) do
    described_class.new(
      name: "Test Robot",
      unit_type: "robot",
      identifier: "ROBOT_001",
      operational_data: Marshal.load(Marshal.dump(robot_data))
    )
  end

  before do
    allow(robot).to receive(:save!).and_return(true)
  end

  describe "battery management" do
    it "reports correct battery capacity and level" do
      expect(robot.battery_capacity).to eq(200.0)
      expect(robot.battery_level).to eq(100.0)
    end

    it "charges and discharges respecting limits" do
      expect(robot.charge_battery(50.0)).to eq(20.0) # limited by max_charge_rate_kw
      expect(robot.battery_level).to eq(120.0)
      expect(robot.discharge_battery(50.0)).to eq(30.0) # limited by max_discharge_rate_kw
      expect(robot.battery_level).to eq(90.0)
    end

    it "uses consume_battery as alias for discharge_battery" do
      # Start from 100.0 (default)
      expect(robot.consume_battery(10.0)).to eq(10.0)
      expect(robot.operational_data["battery"]["current_charge"]).to eq(90.0)
      expect(robot.battery_level).to eq(90.0)
    end
  end

  describe "mobility and drain" do
    it "returns correct mobility_type from operational_data" do
      expect(robot.mobility_type).to eq("wheels")
    end

    it "returns correct battery_drain for wheels" do
      expect(robot.battery_drain).to eq(2.0)
    end

    it "returns correct battery_drain for legs" do
      robot.mobility_type = "legs"
      expect(robot.battery_drain).to eq(3.0)
    end

    it "returns default battery_drain for unknown type" do
      robot.mobility_type = "hover"
      expect(robot.battery_drain).to eq(1.0)
    end
  end

  describe "task queue" do
    it "can assign and execute tasks" do
      robot.assign_task({"type" => "move", "target" => "A1"})
      expect(robot.operational_data["task_queue"]).not_to be_empty
      robot.execute_current_task
      expect(robot.operational_data["task_queue"]).to be_empty
      expect(robot.operational_data["last_location"]).to eq("A1")
    end
  end

  describe "status and recharge" do
    it "returns correct status and recharge need" do
      expect(robot.status).to eq("idle")
      robot.assign_task({"type" => "move", "target" => "A1"})
      expect(robot.status).to eq("busy")
      robot.operational_data["battery"]["current_charge"] = 10.0
      expect(robot.needs_recharge?).to be true
    end
  end
end
