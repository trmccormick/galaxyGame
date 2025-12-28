require 'rails_helper'

RSpec.describe Game do
  before(:all) do
    # Create required Currencies
    @gcc = Financial::Currency.find_or_create_by!(symbol: 'GCC') do |c|
      c.name = 'Galactic Crypto Currency'
      c.is_system_currency = true
      c.precision = 8
    end
    @usd = Financial::Currency.find_or_create_by!(symbol: 'USD') do |c|
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


  # NOTE: assign_task and advance_time methods do not exist in the current Game class.
  # Instead, test advancing time and processing jobs/settlements using advance_by_days.

  describe '#advance_by_days' do
    let!(:settlement) { create(:base_settlement, name: "Mars Base One") }
    let!(:planet) { create(:terrestrial_planet, name: "Mars") }

    it 'advances the simulation by the given number of days' do
      initial_time = game.elapsed_time
      game.advance_by_days(5)
      expect(game.elapsed_time).to eq(initial_time + 5)
    end

    it 'does not advance time if days is zero or negative' do
      initial_time = game.elapsed_time
      game.advance_by_days(0)
      expect(game.elapsed_time).to eq(initial_time)
      game.advance_by_days(-2)
      expect(game.elapsed_time).to eq(initial_time)
    end
  end


  # If you want to test job/settlement processing, add tests here for process_settlements or process_manufacturing_jobs
end
