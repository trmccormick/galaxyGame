# spec/services/terra_sim/simulator_spec.rb
require 'rails_helper'

RSpec.describe TerraSim::Simulator, type: :service do
  let(:solar_system) { create(:solar_system) }
  let(:star) { create(:star, luminosity: 3.846e26, solar_system: solar_system) }
  let(:celestial_body) { create(:celestial_body, solar_system: solar_system, distance_from_star: 1.496e11, albedo: 0.3) }
  
  subject { described_class.new(celestial_body) }

  describe '#calc_current' do
    context 'when star is present' do
      before do
        atmosphere
        biosphere
        subject.calc_current
      end

      it 'calculates and updates the surface temperature' do
        expect(celestial_body.reload.surface_temperature).to be > 0
      end

      it 'calculates and updates the atmospheric pressure' do
        expect(atmosphere.reload.pressure).to be > 0
      end

      it 'updates the gravity' do
        expect(celestial_body.reload.gravity).to be > 0
      end

      it 'applies greenhouse effect to the surface temperature' do
        initial_temperature = celestial_body.surface_temperature / calculate_greenhouse_effect
        expect(celestial_body.reload.surface_temperature).to be > initial_temperature
      end

      it 'updates the biosphere with the habitable ratio and ice latitude' do
        expect(biosphere.reload.habitable_ratio).to be > 0
        expect(biosphere.reload.ice_latitude).to be_a(Float)
      end
    end

    context 'when star is not present' do
      let(:solar_system) { nil }

      it 'does not raise an error' do
        expect { subject.calc_current }.not_to raise_error
      end

      it 'does not update the celestial body attributes' do
        expect { subject.calc_current }.not_to change(celestial_body, :surface_temperature)
      end
    end
  end

  describe '#calculate_greenhouse_effect' do
    it 'returns a multiplier greater than 1.0 for non-zero greenhouse gas concentration' do
      atmosphere
      result = subject.send(:calculate_greenhouse_effect)
      expect(result).to be > 1.0
    end

    it 'returns 1.0 if no atmosphere is present' do
      celestial_body.atmosphere = nil
      result = subject.send(:calculate_greenhouse_effect)
      expect(result).to eq(1.0)
    end
  end

  describe '#atmosphere_gas_effect' do
    it 'calculates total greenhouse gas effect based on gas composition' do
      atmosphere
      result = subject.send(:atmosphere_gas_effect)
      expect(result).to eq(0.041) # 0.04 (CO2) + 0.001 (CH4)
    end

    it 'returns 0.0 if no atmosphere is present' do
      celestial_body.atmosphere = nil
      result = subject.send(:atmosphere_gas_effect)
      expect(result).to eq(0.0)
    end
  end
end


  