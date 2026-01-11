require 'rails_helper'
require_relative '../../../app/services/ai_manager'


RSpec.describe AIManager::TerraformingManager do
  let(:mars) { create(:celestial_body, name: 'Mars', has_magnetosphere: false) }
  let(:venus) { create(:celestial_body, name: 'Venus', has_magnetosphere: false) }
  let(:titan) { create(:celestial_body, name: 'Titan', preservation_mode: true) }
  let(:worlds) { { mars: mars, venus: venus, titan: titan } }
  let(:simulation_params) { {} }
  let(:manager) { described_class.new(worlds: worlds, simulation_params: simulation_params) }

  describe '#calculate_gas_needs' do
    context 'with magnetosphere protection' do
      let(:mars) { create(:celestial_body, name: 'Mars', has_magnetosphere: true) }

      it 'returns gas needs for warming phase' do
        allow(manager).to receive(:determine_terraforming_phase).with(:mars).and_return(:warming)
        allow(manager).to receive(:calculate_warming_phase_needs).and_return({ co2: 1000 })

        result = manager.calculate_gas_needs(:mars)
        expect(result).to eq({ co2: 1000 })
      end
    end

    context 'without magnetosphere protection' do
      it 'returns empty hash' do
        result = manager.calculate_gas_needs(:mars)
        expect(result).to eq({})
      end
    end

    context 'with preservation mode and exceeded limit' do
      let(:titan) { create(:celestial_body, name: 'Titan', preservation_mode: true) }
      let!(:atmosphere) { create(:atmosphere, celestial_body: titan, total_atmospheric_mass: 100, base_values: { 'total_atmospheric_mass' => 200 }) }

      it 'returns empty hash' do
        result = manager.calculate_gas_needs(:titan)
        expect(result).to eq({})
      end
    end
  end

  describe '#has_magnetosphere_protection?' do
    context 'with natural magnetosphere' do
      let(:mars) { create(:celestial_body, has_magnetosphere: true) }

      it 'returns true' do
        expect(manager.send(:has_magnetosphere_protection?, mars)).to be true
      end
    end

    context 'without natural magnetosphere' do
      it 'returns false' do
        expect(manager.send(:has_magnetosphere_protection?, mars)).to be false
      end
    end
  end

  describe '#atmospheric_reduction_exceeded?' do
    context 'with preservation mode' do
      let(:titan) { create(:celestial_body, preservation_mode: true) }

      context 'when reduction exceeds 5%' do
        let!(:atmosphere) { create(:atmosphere, celestial_body: titan, total_atmospheric_mass: 95, base_values: { 'total_atmospheric_mass' => 100 }) }

        it 'returns true' do
          expect(manager.send(:atmospheric_reduction_exceeded?, titan)).to be true
        end
      end

      context 'when reduction is below 5%' do
        let!(:atmosphere) { create(:atmosphere, celestial_body: titan, total_atmospheric_mass: 96, base_values: { 'total_atmospheric_mass' => 100 }) }

        it 'returns false' do
          expect(manager.send(:atmospheric_reduction_exceeded?, titan)).to be false
        end
      end
    end

    context 'without preservation mode' do
      it 'returns false' do
        expect(manager.send(:atmospheric_reduction_exceeded?, mars)).to be false
      end
    end
  end

  describe '#determine_terraforming_phase' do
    context 'warming phase' do
      let(:mars) { create(:celestial_body, surface_temperature: 200) }

      it 'returns warming when temperature is low' do
        result = manager.determine_terraforming_phase(:mars)
        expect(result).to eq(:warming)
      end
    end

    context 'maintenance phase' do
      let(:mars) { create(:celestial_body, surface_temperature: 300) }
      let!(:hydrosphere) { create(:hydrosphere, celestial_body: mars) }

      before do
        allow_any_instance_of(CelestialBodies::Spheres::Hydrosphere).to receive(:state_distribution).and_return({ 'liquid' => 2.0 })
      end

      it 'returns maintenance when conditions are met' do
        result = manager.determine_terraforming_phase(:mars)
        expect(result).to eq(:maintenance)
      end
    end
  end

  describe '#should_seed_biosphere?' do
    context 'with existing biosphere' do
      let!(:biosphere) { create(:biosphere, celestial_body: mars) }

      it 'returns false' do
        result = manager.should_seed_biosphere?(:mars)
        expect(result).to be false
      end
    end

    context 'without biosphere and suitable conditions' do
      let(:mars) { create(:celestial_body, surface_temperature: 300) }
      let!(:hydrosphere) { create(:hydrosphere, celestial_body: mars) }

      before do
        allow_any_instance_of(CelestialBodies::Spheres::Hydrosphere).to receive(:state_distribution).and_return({ 'liquid' => 2.0 })
      end

      it 'returns true' do
        result = manager.should_seed_biosphere?(:mars)
        expect(result).to be true
      end
    end
  end
end