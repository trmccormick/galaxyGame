require 'rails_helper'

RSpec.describe PlanetUpdateService, type: :service do
  # Setup for terrestrial planet
  let(:terrestrial_planet) { create(:terrestrial_planet) }
  
  # Setup for gas giant
  let(:gas_giant) { create(:gas_giant) }
  
  # Time skipped in days
  let(:time_skipped) { 10.0 }
  
  describe "#initialize" do
    it "sets up planet and time_skipped" do
      service = PlanetUpdateService.new(terrestrial_planet, time_skipped)
      expect(service.instance_variable_get(:@planet)).to eq(terrestrial_planet)
      expect(service.instance_variable_get(:@time_skipped)).to eq(time_skipped)
      expect(service.instance_variable_get(:@events)).to eq([])
    end
  end
  
  describe "#run" do
    context "with non-planetary body" do
      let(:star) { create(:star) }
      let(:service) { PlanetUpdateService.new(star, time_skipped) }
      
      it "returns immediately" do
        # Stars don't have 'type', use class-based checks instead
        allow(star).to receive(:is_a?).with(CelestialBodies::CelestialBody).and_return(true)
        allow(star).to receive(:is_a?).with(CelestialBodies::Star).and_return(true)
        allow(star).to receive(:is_a?).with(CelestialBodies::Planets::Planet).and_return(false)
        allow(star).to receive(:class).and_return(CelestialBodies::Star)
        
        expect(service.run).to be_nil
      end
    end
    
    context "with a terrestrial planet" do
      let(:service) { PlanetUpdateService.new(terrestrial_planet, time_skipped) }
      
      before do
        # Stub the private methods to prevent actual simulation
        allow(service).to receive(:simulate_detailed)
        allow(service).to receive(:log_simulation_results)
      end
      
      it "simulates in detail for short time periods" do
        expect(service).to receive(:simulate_detailed)
        service.run
      end
      
      it "returns an array of events" do
        # Stub @events to have some content
        service.instance_variable_set(:@events, [{day: 5, type: :test, description: "Test event"}])
        expect(service.run).to eq([{day: 5, type: :test, description: "Test event"}])
      end
    end
    
    context "with a longer time period" do
      let(:service) { PlanetUpdateService.new(terrestrial_planet, 60.0) }
      
      before do
        # Stub the private methods to prevent actual simulation
        allow(service).to receive(:simulate_progressive)
        allow(service).to receive(:log_simulation_results)
      end
      
      it "uses progressive simulation for longer periods" do
        expect(service).to receive(:simulate_progressive)
        service.run
      end
    end
  end
  
  describe "private methods" do
    let(:service) { PlanetUpdateService.new(terrestrial_planet, time_skipped) }
    
    describe "#simulate_detailed" do
      before do
        # Stub all the process methods
        allow(service).to receive(:process_atmosphere)
        allow(service).to receive(:process_geosphere)
        allow(service).to receive(:process_hydrosphere)
        allow(service).to receive(:process_biosphere)
        allow(service).to receive(:process_sphere_interfaces)
        allow(service).to receive(:update_planet_properties)
      end
      
      it "processes all spheres" do
        expect(service).to receive(:process_atmosphere)
        expect(service).to receive(:process_geosphere)
        expect(service).to receive(:process_hydrosphere)
        expect(service).to receive(:process_biosphere)
        
        service.send(:simulate_detailed)
      end
      
      it "processes sphere interfaces" do
        expect(service).to receive(:process_sphere_interfaces)
        service.send(:simulate_detailed)
      end
      
      it "updates planet properties" do
        expect(service).to receive(:update_planet_properties)
        service.send(:simulate_detailed)
      end
    end
    
    describe "#simulate_progressive" do
      before do
        # Stub methods that would be called during simulation
        allow(service).to receive(:step_simulation)
        allow(service).to receive(:check_for_events)
      end
      
      it "uses the correct intervals for different time periods" do
        # Test with a huge time value that will definitely trigger the very_long range
        service.instance_variable_set(:@time_skipped, 10000.0)
        
        # Check for at least one call of each interval
        expect(service).to receive(:step_simulation).with(1).at_least(:once)
        expect(service).to receive(:step_simulation).with(7).at_least(:once) 
        expect(service).to receive(:step_simulation).with(30).at_least(:once)
        expect(service).to receive(:step_simulation).with(365).at_least(:once)
        
        service.send(:simulate_progressive)
      end
      
      it "checks for events after each simulation step" do
        expect(service).to receive(:check_for_events).at_least(10).times
        service.send(:simulate_progressive)
      end
    end
    
    # Add a console debug to see what's happening
    describe "#sphere processing methods" do
      let(:atmosphere_service) { double("TerraSim::AtmosphereSimulationService") }
      let(:geosphere_service) { double("TerraSim::GeosphereSimulationService") }
      let(:hydrosphere_service) { double("TerraSim::HydrosphereSimulationService") }
      let(:biosphere_service) { double("TerraSim::BiosphereSimulationService") }
      
      before do
        # Make sure the planet has all spheres
        allow(terrestrial_planet).to receive(:atmosphere).and_return(double("Atmosphere"))
        allow(terrestrial_planet).to receive(:geosphere).and_return(double("Geosphere"))
        allow(terrestrial_planet).to receive(:hydrosphere).and_return(double("Hydrosphere"))
        allow(terrestrial_planet).to receive(:biosphere).and_return(double("Biosphere"))
        
        # Make these doubles accept any method calls
        allow(atmosphere_service).to receive(:simulate).with(any_args)
        allow(geosphere_service).to receive(:simulate).with(any_args)
        allow(hydrosphere_service).to receive(:simulate).with(any_args)
        allow(biosphere_service).to receive(:simulate).with(any_args)
        
        # Stub the TerraSim services
        allow(TerraSim::AtmosphereSimulationService).to receive(:new).and_return(atmosphere_service)
        allow(TerraSim::GeosphereSimulationService).to receive(:new).and_return(geosphere_service)
        allow(TerraSim::HydrosphereSimulationService).to receive(:new).and_return(hydrosphere_service)
        allow(TerraSim::BiosphereSimulationService).to receive(:new).and_return(biosphere_service)
      end
      
      it "processes atmosphere correctly" do
        expect(TerraSim::AtmosphereSimulationService).to receive(:new).with(terrestrial_planet)
        expect(atmosphere_service).to receive(:simulate).with(time_skipped)
        
        # Add direct call to see what's happening
        service.send(:process_atmosphere)
      end
      
      it "processes geosphere correctly" do
        expect(TerraSim::GeosphereSimulationService).to receive(:new).with(terrestrial_planet)
        expect(geosphere_service).to receive(:simulate).with(time_skipped)
        
        service.send(:process_geosphere)
      end
      
      it "processes hydrosphere correctly" do
        expect(TerraSim::HydrosphereSimulationService).to receive(:new).with(terrestrial_planet)
        expect(hydrosphere_service).to receive(:simulate).with(time_skipped)
        
        service.send(:process_hydrosphere)
      end
      
      it "processes biosphere correctly" do
        expect(TerraSim::BiosphereSimulationService).to receive(:new).with(terrestrial_planet)
        expect(biosphere_service).to receive(:simulate).with(time_skipped)
        
        service.send(:process_biosphere)
      end
    end
  end
end