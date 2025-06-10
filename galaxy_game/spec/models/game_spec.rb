require 'rails_helper'
require_relative '../../app/models/settlement/base_settlement'
require_relative '../../app/models/units/base_unit'

RSpec.describe Game, type: :model do
  # Create a plain Ruby object instead of using database persistence
  let(:game) { Game.new }

  describe "initialization" do
    it "starts with elapsed time at 0" do
      expect(game.elapsed_time).to eq(0.0)
    end

    it "starts with an empty tasks array" do
      expect(game.tasks).to eq([])
    end
  end

  describe "#assign_task" do
    let(:settlement) { double("Settlement", name: "Test Settlement") }
    
    it "adds a task to the queue" do
      expect {
        game.assign_task(settlement, "Test Task", 5.0)
      }.to change { game.tasks.size }.by(1)
    end
    
    it "sorts tasks by completion time" do
      game.assign_task(settlement, "Task 1", 10.0)
      game.assign_task(settlement, "Task 2", 5.0)
      
      expect(game.tasks.first[:description]).to eq("Task 2")
    end
  end

  describe "#advance_time" do
    let(:settlement) { double("Settlement", name: "Test Settlement") }
    
    before do
      # Stub the process methods to avoid database access
      allow(game).to receive(:process_settlements)
      allow(game).to receive(:process_units)
      allow(game).to receive(:process_planets)
    end
    
    it "does nothing when there are no tasks" do
      expect(game.advance_time).to be_nil
    end
    
    it "advances time to the next task" do
      game.assign_task(settlement, "Test Task", 5.0)
      game.advance_time
      
      expect(game.elapsed_time).to eq(5.0)
    end
    
    it "processes game systems for the skipped time" do
      game.assign_task(settlement, "Test Task", 5.0)
      
      expect(game).to receive(:process_settlements).with(5.0)
      expect(game).to receive(:process_units).with(5.0)
      expect(game).to receive(:process_planets).with(5.0)
      
      game.advance_time
    end
  end

  describe "private methods" do
    let(:settlement) { double("Settlement::BaseSettlement", consume_resources: nil, name: "Test Settlement") }
    let(:unit) { double("Units::BaseUnit", operate: nil) }
    let(:planet) { double("CelestialBodies::CelestialBody", should_simulate?: true) }
    
    # Mock a service that doesn't exist yet
    let(:planet_service) { double("PlanetService", run: nil) }
    
    before do
      # Mock the class methods
      allow(Settlement::BaseSettlement).to receive(:all).and_return([settlement])
      allow(Units::BaseUnit).to receive(:all).and_return([unit])
      allow(CelestialBodies::CelestialBody).to receive(:all).and_return([planet])
      
      # Create a proper stub class that accepts the correct parameters
      planet_update_service_class = Class.new do
        def initialize(planet, time_skipped)
          # Constructor with correct parameters
        end
        
        def run
          # Method to be called
        end
      end
      
      # Use this class for the stub
      stub_const("PlanetUpdateService", planet_update_service_class)
      
      # Create a mock instance and allow new to return it
      allow(PlanetUpdateService).to receive(:new).with(planet, 1.0).and_return(planet_service)
    end
    
    it "processes settlements" do
      expect(settlement).to receive(:consume_resources).with(1.0)
      game.send(:process_settlements, 1.0)
    end
    
    it "processes units" do
      expect(unit).to receive(:operate).with(1.0)
      game.send(:process_units, 1.0)
    end
    
    it "processes planets" do
      expect(PlanetUpdateService).to receive(:new).with(planet, 1.0)
      expect(planet_service).to receive(:run)
      game.send(:process_planets, 1.0)
    end
  end
end

