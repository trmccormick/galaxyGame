# spec/services/terra_sim/simulator_spec.rb
require 'rails_helper'

RSpec.describe TerraSim::Simulator, type: :service do
  # Create mocks for each service
  let(:atmosphere_service) { instance_double(TerraSim::AtmosphereSimulationService) }
  let(:geosphere_service) { instance_double(TerraSim::GeosphereSimulationService) }
  let(:hydrosphere_service) { instance_double(TerraSim::HydrosphereSimulationService) }
  let(:biosphere_service) { instance_double(TerraSim::BiosphereSimulationService) }
  let(:exotic_service) { instance_double(TerraSim::ExoticWorldSimulationService) }
  let(:interface_service) { instance_double(TerraSim::BiosphereGeosphereInterfaceService) }
  
  # Standard test objects
  let(:solar_system) { create(:solar_system) }
  let(:star) do 
    create(:star, solar_system: solar_system, 
           properties: { 'spectral_class' => 'G2V', 'stellar_class' => 'Main Sequence' })
  end
  
  let(:planet) do
    planet = build(:terrestrial_planet, solar_system: solar_system)
    planet.properties = {}
    planet.save!
    planet
  end
  
  # Setup atmosphere for some tests
  let!(:atmosphere) { create(:atmosphere, celestial_body: planet) }
  let!(:geosphere) { create(:geosphere, celestial_body: planet) }
  let!(:biosphere) { create(:biosphere, celestial_body: planet) }
  
  before do
    # Create star distance
    CelestialBodies::StarDistance.create!(
      star: star,
      celestial_body: planet,
      distance: 149_597_870_700 # 1 AU in meters
    )
    
    # Setup our mocks - allow them to receive simulate and return true
    allow(atmosphere_service).to receive(:simulate).and_return(true)
    allow(geosphere_service).to receive(:simulate).and_return(true)
    allow(hydrosphere_service).to receive(:simulate).and_return(true)
    allow(biosphere_service).to receive(:simulate).and_return(true)
    allow(exotic_service).to receive(:simulate).and_return(true)
    allow(interface_service).to receive(:simulate).and_return(true)
    
    # Setup the constructors to return our mocks
    allow(TerraSim::AtmosphereSimulationService).to receive(:new).and_return(atmosphere_service)
    allow(TerraSim::GeosphereSimulationService).to receive(:new).and_return(geosphere_service)
    allow(TerraSim::HydrosphereSimulationService).to receive(:new).and_return(hydrosphere_service)
    allow(TerraSim::BiosphereSimulationService).to receive(:new).and_return(biosphere_service)
    allow(TerraSim::ExoticWorldSimulationService).to receive(:new).and_return(exotic_service)
    allow(TerraSim::BiosphereGeosphereInterfaceService).to receive(:new).and_return(interface_service)
    
    # For certain methods in Simulator that might be failing
    allow(planet).to receive(:solar_constant).and_return(1367.0)
    
    # Initialize the simulator 
    @simulator = TerraSim::Simulator.new(planet)
  end
  
  describe '#calc_current' do
    context 'when star is present' do
      before do
        # Run the simulator
        @simulator.calc_current
      end
      
      it 'updates the surface temperature' do
        expect(planet.reload.surface_temperature).to be > 0
      end
      
      it 'simulates the atmosphere' do
        expect(atmosphere_service).to have_received(:simulate)
      end
      
      it 'simulates the biosphere-geosphere interface' do
        expect(interface_service).to have_received(:simulate)
      end
    end
    
    context 'when no star is present' do
      let(:isolated_planet) do
        p = build(:terrestrial_planet)
        p.properties = {}
        p.save!
        p
      end
      
      let(:isolated_simulator) { TerraSim::Simulator.new(isolated_planet) }
      
      before do
        # Setup mocks again for the isolated simulator
        allow(TerraSim::AtmosphereSimulationService).to receive(:new).and_return(atmosphere_service)
        allow(TerraSim::GeosphereSimulationService).to receive(:new).and_return(geosphere_service)
        allow(TerraSim::HydrosphereSimulationService).to receive(:new).and_return(hydrosphere_service)
        allow(TerraSim::BiosphereSimulationService).to receive(:new).and_return(biosphere_service)
        allow(TerraSim::ExoticWorldSimulationService).to receive(:new).and_return(exotic_service)
        allow(TerraSim::BiosphereGeosphereInterfaceService).to receive(:new).and_return(interface_service)
        
        # Create atmosphere to avoid nil checks
        create(:atmosphere, celestial_body: isolated_planet)
        
        # Run the simulator
        isolated_simulator.calc_current
      end
      
      it 'sets the temperature to space background temperature' do
        expect(isolated_planet.reload.surface_temperature).to eq(3)
      end
    end
  end
end


