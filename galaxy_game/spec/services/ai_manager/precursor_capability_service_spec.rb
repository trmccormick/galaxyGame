# spec/services/ai_manager/precursor_capability_service_spec.rb
require 'rails_helper'
require_relative '../../../app/services/ai_manager'

RSpec.describe AIManager::PrecursorCapabilityService do
  let(:solar_system) { create(:solar_system) }
  
  # Use existing factory traits
  let!(:mars) { create(:terrestrial_planet, :mars, solar_system: solar_system) }
  let!(:luna) { create(:celestial_body, :luna, solar_system: solar_system) }
  
  # Create Titan manually since no trait exists yet
  let!(:titan) do
    body = create(:celestial_body,
      solar_system: solar_system,
      identifier: 'titan',
      name: 'Titan',
      radius: 2574700.0,
      mass: 1.3452e23
    )
    
    # Create thick nitrogen/methane atmosphere
    atmosphere = create(:atmosphere, celestial_body: body, pressure: 1.46, temperature: 94.0)
    create(:gas, atmosphere: atmosphere, name: 'N2', percentage: 95.0)
    create(:gas, atmosphere: atmosphere, name: 'CH4', percentage: 5.0)
    
    body
  end
  
  describe '#can_produce_locally?' do
    context 'with Mars (CO2 atmosphere + water ice)' do
      let(:service) { described_class.new(mars) }

      it 'returns true for regolith' do
        expect(service.can_produce_locally?('regolith')).to be true
      end

      it 'returns true for water_ice' do
        expect(service.can_produce_locally?('water_ice')).to be true
      end

      it 'returns true for co2' do
        expect(service.can_produce_locally?('co2')).to be true
      end

      it 'returns false for methane (not in Mars atmosphere)' do
        expect(service.can_produce_locally?('methane')).to be false
      end
    end

    context 'with Luna (regolith + He3)' do
      let(:service) { described_class.new(luna) }

      it 'returns true for regolith' do
        expect(service.can_produce_locally?('regolith')).to be true
      end

      it 'returns true for oxygen (from regolith processing)' do
        # Oxygen can be extracted from lunar regolith
        expect(service.can_produce_locally?('oxygen')).to be true
      end

      it 'returns false for methane (not available on Luna)' do
        expect(service.can_produce_locally?('methane')).to be false
      end
    end
  end

  describe '#local_resources' do
    context 'with Titan (methane/nitrogen atmosphere)' do
      let(:service) { described_class.new(titan) }

      it 'includes atmospheric methane' do
        expect(service.local_resources).to include('methane')
      end

      it 'includes nitrogen' do
        expect(service.local_resources).to include('nitrogen')
      end

      it 'includes regolith' do
        expect(service.local_resources).to include('regolith')
      end
    end
  end

  describe '#precursor_enables?' do
    let(:service) { described_class.new(mars) }

    it 'enables oxygen production on Mars (via CO2 processing)' do
      expect(service.precursor_enables?(:oxygen)).to be true
    end

    it 'enables water production on Mars (subsurface ice)' do
      expect(service.precursor_enables?(:water)).to be true
    end

    it 'enables regolith processing on Mars' do
      expect(service.precursor_enables?(:regolith_processing)).to be true
    end

    it 'enables metal extraction (iron oxide in regolith)' do
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
      expect(service.production_capabilities[:atmosphere]).to include('co2')
    end
  end

  describe 'data-driven approach' do
    it 'does not hardcode world identifiers' do
      source_code = File.read(__FILE__.gsub('_spec.rb', '.rb'))
      
      expect(source_code).not_to include("when 'mars'")
      expect(source_code).not_to include("when 'luna'")
      expect(source_code).not_to include("when 'titan'")
    end

    it 'queries actual celestial body spheres' do
      service = described_class.new(mars)

      # Should use actual geosphere/atmosphere data
      expect(mars.geosphere).to receive(:surface_composition).at_least(:once).and_call_original
      expect(mars.atmosphere).to receive(:composition).at_least(:once).and_call_original

      service.local_resources
    end
  end
end
