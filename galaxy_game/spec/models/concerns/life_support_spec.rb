require 'rails_helper'

RSpec.describe LifeSupport, type: :concern do
  before(:all) do
    Object.const_set(:FOOD_PER_PERSON, 2)
    Object.const_set(:WATER_PER_PERSON, 1)
    Object.const_set(:ENERGY_PER_PERSON, 3)
    Object.const_set(:STARVATION_THRESHOLD, 0.5)
    Object.const_set(:DEATH_RATE, 0.1)
  end

  after(:all) do
    Object.send(:remove_const, :FOOD_PER_PERSON)
    Object.send(:remove_const, :WATER_PER_PERSON)
    Object.send(:remove_const, :ENERGY_PER_PERSON)
    Object.send(:remove_const, :STARVATION_THRESHOLD)
    Object.send(:remove_const, :DEATH_RATE)
  end

  let(:test_class) do
    Class.new do
      include ActiveModel::Validations
      include GameConstants
      include LifeSupport
      
      attr_accessor :current_population, :current_food, :current_water, :current_energy
      
      def save
        true
      end
    end
  end

  let(:instance) { test_class.new }

  describe 'validations' do
    it 'allows nil population' do
      instance.current_population = nil
      expect(instance).to be_valid
    end

    it 'validates population is not negative' do
      instance.current_population = -1
      expect(instance).not_to be_valid
    end
  end

  describe '#calculate_life_support_requirements' do
    before do
      instance.current_population = 10
    end

    it 'returns empty hash for zero population' do
      instance.current_population = 0
      expect(instance.calculate_life_support_requirements).to eq({})
    end

    it 'calculates requirements for given population' do
      requirements = instance.calculate_life_support_requirements
      
      expect(requirements[:food]).to eq(10 * FOOD_PER_PERSON)
      expect(requirements[:water]).to eq(10 * WATER_PER_PERSON)
      expect(requirements[:energy]).to eq(10 * ENERGY_PER_PERSON)
      expect(requirements[:waste_processing]).to eq((10 * WATER_PER_PERSON * 0.6).to_i)
    end
  end

  describe '#check_resource_availability' do
    before do
      instance.current_population = 10
      instance.current_food = 1000
      instance.current_water = 1000
      instance.current_energy = 1000
    end

    it 'handles starvation when food is below threshold' do
      instance.current_population = 10
      instance.current_food = 5  # Set food below starvation threshold
      required_food = 10 * FOOD_PER_PERSON  # 20 units required
      starvation_threshold = required_food * STARVATION_THRESHOLD  # 10 units threshold
      expect { instance.check_resource_availability }.to change { instance.current_population }
    end

    it 'handles resource shortages' do
      instance.current_food = 0
      instance.current_water = 0
      instance.current_energy = 0
      
      expect(instance).to receive(:handle_resource_shortage).at_least(3).times
      instance.check_resource_availability
    end
  end

  describe '#handle_starvation' do
    it 'reduces population by death rate' do
      instance.current_population = 100
      expect { instance.send(:handle_starvation) }
        .to change { instance.current_population }
        .by(-(100 * DEATH_RATE).to_i)
    end
  end
end