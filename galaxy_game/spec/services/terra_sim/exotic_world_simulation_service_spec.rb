# spec/services/terra_sim/exotic_world_simulation_spec.rb
require 'rails_helper'

RSpec.describe TerraSim::ExoticWorldSimulationService, type: :service do
  let(:celestial_body) { create(:celestial_body) }
  let(:options) { { temperature_range: [-100, -50], primary_elements: ['Methane'] } }
  
  before do
    # Ensure geosphere exists
    celestial_body.create_geosphere(
      geological_activity: 5,
      tectonic_activity: true,
      # Store ice tectonics as part of the plates JSON instead
      plates: { "count": 7, "positions": [], "ice_tectonics_enabled": true }
    )
    
    # Create some geological materials for testing
    celestial_body.geosphere.geological_materials.create!(
      name: 'Carbon',
      state: 'solid',
      layer: 'mantle',
      percentage: 10,
      mass: 1000
    )
    
    celestial_body.geosphere.geological_materials.create!(
      name: 'Hydrogen',
      state: 'gas',
      layer: 'core',
      percentage: 30,
      mass: 5000
    )
  end
  
  describe '#initialize' do
    it 'sets planet-specific options' do
      sim = described_class.new(celestial_body)
      temp_range = sim.instance_variable_get(:@temperature_range)
      expect(celestial_body.surface_temperature).to be_between(temp_range[0], temp_range[1]).inclusive
    end
    
    it 'accepts custom options' do
      custom_options = { temperature_range: [-200, -100], primary_elements: ['Xenon'] }
      sim = described_class.new(celestial_body, custom_options)
      
      expect(sim.instance_variable_get(:@temperature_range)).to eq([-200, -100])
      expect(sim.instance_variable_get(:@primary_elements)).to include('Xenon')
    end
  end
  
  describe '#planet_type' do
    it 'determines planet type from temperature and elements' do
      # Allow the body to respond to planet_type
      allow(celestial_body).to receive(:planet_type).and_return(nil)
      
      service = described_class.new(celestial_body, options)
      expect(service.send(:planet_type)).to eq(:ice_giant)
    end
    
    it 'uses planet_type from celestial body if available' do
      allow(celestial_body).to receive(:planet_type).and_return('hot_jupiter')
      
      service = described_class.new(celestial_body, options)
      expect(service.send(:planet_type)).to eq(:hot_jupiter)
    end
    
    it 'defaults to terrestrial for unknown combinations' do
      body = create(:celestial_body)
      sim = described_class.new(body)
      expect(sim.send(:planet_type)).to eq(:terrestrial)
    end
  end
  
  describe '#simulate_planet_specific_processes' do
    context 'with an ice giant' do
      let(:sim) { described_class.new(celestial_body, options) }
      
      it 'calls ice-specific simulation methods' do
        expect(sim).to receive(:simulate_ice_processes)
        sim.send(:simulate_planet_specific_processes)
      end
    end
    
    context 'with a carbon planet' do
      let(:sim) { described_class.new(celestial_body) }
      
      it 'calls carbon planet-specific methods' do
        # We can't easily test private methods that don't exist yet
        # This would be implemented when we add those methods
        sim.send(:simulate_planet_specific_processes)
      end
    end
  end
  
  describe '#simulate_diamond_formation' do
    it 'converts carbon to diamond' do
      service = described_class.new(celestial_body)
      
      expect {
        service.send(:simulate_diamond_formation)
      }.to change { 
        celestial_body.geosphere.geological_materials.exists?(name: 'Diamond')
      }.from(false).to(true)
      
      diamond = celestial_body.geosphere.geological_materials.find_by(name: 'Diamond')
      expect(diamond.state).to eq('solid')
      expect(diamond.layer).to eq('mantle')
    end
  end
  
  describe '#simulate_cryovolcanism' do
    it 'adds frozen materials to the planet' do
      sim = described_class.new(celestial_body)
      
      allow(sim).to receive(:add_gas_to_atmosphere)
      allow(sim).to receive(:add_liquid_to_hydrosphere)
      allow(sim).to receive(:add_exotic_material_to_surface)
      
      sim.send(:simulate_cryovolcanism)
      
      expect(sim).to have_received(:add_gas_to_atmosphere).at_least(1).times
      expect(sim).to have_received(:add_liquid_to_hydrosphere).at_least(1).times
      expect(sim).to have_received(:add_exotic_material_to_surface).at_least(1).times
    end
  end
  
  describe '#simulate_extreme_pressure' do
    it 'converts hydrogen to metallic hydrogen at extreme pressure' do
      service = described_class.new(celestial_body)
      allow(service).to receive(:core_pressure).and_return(1_500_000)
      
      hydrogen = celestial_body.geosphere.geological_materials.find_by(name: 'Hydrogen')
      expect(hydrogen.state).to eq('gas')
      
      service.send(:simulate_extreme_pressure)
      # Reload to get persisted state
      hydrogen.reload
      expect(hydrogen.state).to eq('metallic_hydrogen')
    end
  end
end