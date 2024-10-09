require 'rails_helper'

RSpec.describe Colony, type: :model do
  it "can have multiple domes" do
    colony = Colony.create(name: "Mars Outpost", capacity: 1000)
    dome = Dome.create(name: "Research Dome", capacity: 100, current_occupancy: 0, colony: colony)
    expect(colony.domes).to include(dome)
  end

  it "can calculate total capacity" do
    colony = Colony.create(name: "Mars Outpost", capacity: 1000)
    Dome.create(name: "Research Dome", capacity: 100, current_occupancy: 0, colony: colony)
    Dome.create(name: "Living Dome", capacity: 200, current_occupancy: 0, colony: colony)
    expect(colony.total_capacity).to eq(300)
  end

  it "can calculate remaining capacity" do
    colony = Colony.create(name: "Mars Outpost", capacity: 1000)
    Dome.create(name: "Research Dome", capacity: 100, current_occupancy: 30, colony: colony)
    Dome.create(name: "Living Dome", capacity: 200, current_occupancy: 50, colony: colony)
    expected_remaining_capacity = colony.total_capacity - (30 + 50)
    expect(colony.remaining_capacity).to eq(expected_remaining_capacity)
  end

  it "can mine GCC from satellites and computers" do
    colony = Colony.create(name: "Mars Outpost", capacity: 1000)
    satellite = Satellite.create(colony: colony)
    computer = Computer.create(colony: colony, mining_power: 200)

    # Simulate mining and check if account balance updates
    initial_balance = colony.account.balance
    expect { colony.mine_gcc }.to change { colony.account.balance }.by(satellite.mine + computer.mine)
  end

  it "should not exceed total power while mining" do
    colony = Colony.create(name: "Mars Outpost", capacity: 1000)
    satellite = Satellite.create(colony: colony)
    computer = Computer.create(colony: colony, mining_power: 150)

    # Set available power to 100 to check the limiting
    allow(colony).to receive(:available_power).and_return(100)
    expect { colony.mine_gcc }.to change { colony.account.balance }.by(satellite.mine)
  end

  it "can manage inventories" do
    colony = Colony.create(name: "Mars Outpost", capacity: 1000)
    inventory = Inventory.create(name: "Oxygen", quantity: 500, material_type: :raw_material, settlement_id: colony.id)

    expect(colony.inventories).to include(inventory)
    expect(inventory.tradeable?).to be_truthy
  end

  it "validates capacity and current occupancy" do
    colony = Colony.new(name: "Mars Outpost", capacity: 1000, current_occupancy: 1001)
    expect(colony).to_not be_valid
    expect(colony.errors[:current_occupancy]).to include("can't be greater than capacity")

    colony.current_occupancy = 999
    expect(colony).to be_valid
  end
end

