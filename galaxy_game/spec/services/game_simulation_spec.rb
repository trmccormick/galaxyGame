require 'rails_helper'

RSpec.describe GameSimulation do
  let(:game_state) { double('GameState', year: 2200, day: 100.0, last_updated_at: nil, save!: true) }

  before do
    allow(game_state).to receive(:last_updated_at=)
  end
  subject(:game) { described_class.new(game_state: game_state) }

  describe '#initialize' do
    it 'sets the game_state' do
      expect(game.game_state).to eq(game_state)
    end
  end

  describe '#advance_by_days' do
    context 'when days is zero or negative' do
      it 'does not advance the game' do
        expect(game_state).not_to receive(:save!)
        game.advance_by_days(0)
        game.advance_by_days(-5)
      end
    end

    context 'when days is positive' do
      it 'advances the game time and saves the state' do
        expect(game_state).to receive(:save!)
        expect(game_state).to receive(:day=).with(105.0)
        game.advance_by_days(5)
      end

      it 'handles year rollover correctly' do
        current_day = 364.0
        rollover_game_state = double('GameState', year: 2200, last_updated_at: nil, save!: true)
        allow(rollover_game_state).to receive(:day) { current_day }
        allow(rollover_game_state).to receive(:day=) { |value| current_day = value }
        allow(rollover_game_state).to receive(:last_updated_at=)
        expect(rollover_game_state).to receive(:year=).with(2201)
        rollover_game = described_class.new(game_state: rollover_game_state)
        rollover_game.advance_by_days(1)
        expect(current_day).to eq(0.0)
      end
    end
  end

  describe '#process_celestial_bodies' do
    it 'simulates only bodies that should be simulated' do
      body1 = double('CelestialBody', should_simulate?: true, name: 'Earth', update_column: nil)
      body2 = double('CelestialBody', should_simulate?: false)
      allow(CelestialBodies::CelestialBody).to receive(:find_each).and_yield(body1).and_yield(body2)
      simulator = double('TerraSim::Simulator', calc_current: true)
      allow(TerraSim::Simulator).to receive(:new).with(body1).and_return(simulator)
      expect(simulator).to receive(:calc_current).with(1)
      game.send(:process_celestial_bodies, 1)
    end

    it 'logs errors if simulation fails' do
      body = double('CelestialBody', should_simulate?: true, name: 'Mars', update_column: nil)
      allow(CelestialBodies::CelestialBody).to receive(:find_each).and_yield(body)
      allow(TerraSim::Simulator).to receive(:new).and_raise(StandardError.new('Sim error'))
      expect(Rails.logger).to receive(:error).with('Error simulating Mars: Sim error')
      expect(Rails.logger).to receive(:error).with(an_instance_of(String))
      game.send(:process_celestial_bodies, 1)
    end
  end
end