require 'rails_helper'

RSpec.describe Craft::Transport::Cycler, type: :model do
  let(:cycler) { build(:cycler, cycler_type: 'earth_mars') }

  describe 'validations' do
    it { should validate_presence_of(:cycler_type) }
    it { should validate_presence_of(:orbital_period) }
  end

  describe 'associations' do
    it { should have_many(:docked_crafts) }
    it { should have_many(:scheduled_arrivals) }
    it { should have_many(:scheduled_departures) }
  end

  describe '#initialize_trajectory' do
    it 'sets correct orbital period for earth_mars cycler' do
      cycler.initialize_trajectory
      expect(cycler.orbital_period).to eq(780)
    end

    it 'sets correct orbital period for earth_venus cycler' do
      cycler.cycler_type = 'earth_venus'
      cycler.initialize_trajectory
      expect(cycler.orbital_period).to eq(584)
    end

    it 'sets correct orbital period for venus_mars cycler' do
      cycler.cycler_type = 'venus_mars'
      cycler.initialize_trajectory
      expect(cycler.orbital_period).to eq(333)
    end
  end

  describe '#validate_cycler_requirements' do
    it 'adds error if craft_type is not cycler' do
      cycler.craft_info = { 'type' => 'spaceship' }
      cycler.send(:validate_cycler_requirements)
      expect(cycler.errors[:base]).to include('Invalid craft type for cycler')
    end
  end
end