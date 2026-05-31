# spec/services/ai_manager/precursor_capability_service_spec.rb
require 'rails_helper'
require_relative '../../../app/services/ai_manager'

RSpec.describe AIManager::PrecursorCapabilityService, :uses_seeded_bodies do
  let!(:solar_system) { SolarSystem.find_by!(id: '1') }
  let!(:mars) { CelestialBodies::CelestialBody.find_by!(identifier: 'MARS-01') }
  let!(:luna) { CelestialBodies::CelestialBody.find_by!(identifier: 'LUNA-01') }
  let!(:titan) { CelestialBodies::CelestialBody.find_by!(identifier: 'TITAN-01') }
  
  describe '#can_produce_locally?' do
    context 'with Mars (CO2 atmosphere + water ice)' do
      let(:service) { described_class.new(mars) }

      it 'returns true for regolith' do
        expect(service.can_produce_locally?('regolith')).to be true
      end

      it 'returns true for H2O' do
        expect(service.can_produce_locally?('H2O')).to be true
      end

      it 'returns true for CO2' do
        expect(service.can_produce_locally?('CO2')).to be true
      end

      it 'returns false for CH4 (not in Mars atmosphere)' do
        expect(service.can_produce_locally?('CH4')).to be false
      end
    end

    context 'with Luna (regolith + He3)' do
      let(:service) { described_class.new(luna) }

      it 'returns true for regolith' do
        expect(service.can_produce_locally?('regolith')).to be true
      end

      it 'returns true for O2 (from regolith processing)' do
        expect(service.can_produce_locally?('O2')).to be true
      end

      it 'returns false for CH4 (not available on Luna)' do
        expect(service.can_produce_locally?('CH4')).to be false
      end
    end
  end

  describe '#local_resources' do
    context 'with Titan (methane/nitrogen atmosphere)' do
      let(:service) { described_class.new(titan) }

      it 'includes atmospheric CH4' do
        expect(service.local_resources).to include('CH4')
      end

      it 'includes N2' do
        expect(service.local_resources).to include('N2')
      end

      it 'includes regolith' do
        expect(service.local_resources).to include('regolith')
      end
    end
  end

  describe '#precursor_enables?' do
    let(:service) { described_class.new(mars) }

    it 'enables O2 production on Mars (via CO2 processing)' do
      expect(service.precursor_enables?(:oxygen)).to be true
    end

    it 'enables H2O extraction on Mars (from stored volatiles)' do
      expect(service.precursor_enables?(:water)).to be true
    end

    it 'enables regolith processing on Mars' do
      expect(service.precursor_enables?(:regolith_processing)).to be true
    end

    it 'enables metal extraction from crust composition' do
      expect(service.precursor_enables?(:metals)).to be true
    end
  end

  describe '#production_capabilities' do
    let(:service) { described_class.new(mars) }

    it 'returns capabilities hash' do
      capabilities = service.production_capabilities

      expect(capabilities).to have_key(:atmosphere)
      expect(capabilities).to have_key(:surface)
      expect(capabilities).to have_key(:subsurface)
      expect(capabilities).to have_key(:regolith)
    end

    it 'includes CO2 in atmospheric resources' do
      expect(service.production_capabilities[:atmosphere]).to include('CO2')
    end
  end

  describe 'data-driven approach' do
    it 'does not hardcode world identifiers' do
      source_code = File.read(__FILE__.gsub('_spec.rb', '').gsub('spec/', 'app/') + '.rb')
      
      expect(source_code).not_to include("when 'mars'")
      expect(source_code).not_to include("when 'luna'")
      expect(source_code).not_to include("when 'titan'")
    end

    it 'queries actual celestial body spheres' do
      service = described_class.new(mars)

      # Should use actual geosphere/atmosphere data
      expect(mars.geosphere).to receive(:crust_composition).at_least(:once).and_call_original
      expect(mars.atmosphere).to receive(:gas_percentage).at_least(:once).and_call_original

      service.local_resources
    end
  end
end
