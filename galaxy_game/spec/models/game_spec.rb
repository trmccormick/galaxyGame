require 'rails_helper'

RSpec.describe Game do
  before(:all) do
    # Create required Currencies
    @gcc = Currency.find_or_create_by!(symbol: 'GCC') do |c|
      c.name = 'Galactic Crypto Currency'
      c.is_system_currency = true
      c.precision = 8
    end
    @usd = Currency.find_or_create_by!(symbol: 'USD') do |c|
      c.name = 'United States Dollar'
      c.is_system_currency = true
      c.precision = 2
    end
  end

  let(:game) { described_class.new }
  let(:player) { create(:player) }
  let(:location) { create(:celestial_location, name: "Test Location") }

  let!(:base_settlement) do
    create(:base_settlement, :independent, :with_storage,
           name: "Mars Base One",
           current_population: 5,
           owner: player,
           location: location)
  end

  let!(:storage_unit) do
    create(:base_unit, :storage,
           name: "Test Storage",
           unit_type: "storage",
           owner: base_settlement,
           attachable: base_settlement,
           operational_data: {
             'storage' => {
               'capacity' => 500,
               'current_contents' => 'N2'
             },
             'output_resources' => [] # <-- Add this line
           })
  end

  let!(:housing_unit) do
    create(:base_unit, :housing,
           name: "Habitat Module",
           unit_type: "housing",
           owner: base_settlement,
           attachable: base_settlement,
           operational_data: {
             'capacity' => 6,
             'consumables' => { energy: 4, water: 15, oxygen: 10 },
             'output_resources' => [] # <-- Add this line
           })
  end

  describe '#assign_task' do
    let!(:settlement) { create(:settlement, name: "Luna Outpost Alpha") }

    it 'adds a new task to the task list with correct completion time' do
      game.assign_task(settlement, "Build solar panel", 3.0)

      expect(game.tasks.size).to eq(1)
      task = game.tasks.first
      expect(task[:description]).to eq("Build solar panel")
      expect(task[:completion_time]).to eq(3.0)
      expect(task[:settlement]).to eq(settlement)
    end
  end

  describe '#advance_time' do
    let!(:settlement) { create(:settlement, name: "Mars Base One") }
    let!(:planet) { create(:terrestrial_planet, name: "Mars") }

    before do
      game.assign_task(settlement, "Deploy solar collector", 5.0)

      allow(planet).to receive(:should_simulate?).and_return(true)
      allow(PlanetUpdateService).to receive(:new)
        .with(planet, 5.0)
        .and_return(instance_double(PlanetUpdateService, run: true))
    end

    it 'advances game time and completes a task' do
      expect { game.advance_time }.to output(/Task completed: Deploy solar collector/).to_stdout

      expect(game.elapsed_time).to eq(5.0)
      expect(game.tasks).to be_empty
    end
  end

  describe '#advance_time with no tasks' do
    it 'prints a message when there are no tasks' do
      expect { game.advance_time }.to output(/No active tasks/).to_stdout
    end
  end
end
