require 'rails_helper'

RSpec.describe TerraSim::GeosphereSimulationService, type: :service do
  let(:celestial_body) { create(:celestial_body) }
  let(:geosphere) { create(:geosphere, celestial_body: celestial_body, geological_activity: 50) }
  
  subject { described_class.new(celestial_body) }
  
  before do
    # Ensure the geosphere exists
    geosphere
    
    # Stub methods that might cause issues
    allow(geosphere).to receive(:update_plate_positions).and_return(true)
    allow(geosphere).to receive(:update_erosion).and_return(true)
    allow(subject).to receive(:puts).and_return(nil) # Silent logging
    
    # Skip regolith_depth checks if columns don't exist
    allow(geosphere).to receive(:has_attribute?).with(:regolith_depth).and_return(true)
    allow(geosphere).to receive(:has_attribute?).with(:regolith_particle_size).and_return(true)
    allow(geosphere).to receive(:has_attribute?).with(:weathering_rate).and_return(true)
    allow(geosphere).to receive(:has_attribute?).with(:plates).and_return(true)
  end
  
  describe '#initialize' do
    it 'initializes with a celestial body and its geosphere' do
      expect(subject.instance_variable_get(:@celestial_body)).to eq(celestial_body)
      expect(subject.instance_variable_get(:@geosphere)).to eq(geosphere)
    end
    
    it 'sets up initial values from the geosphere' do
      expect(subject.instance_variable_get(:@plate_tectonics_enabled)).to eq(geosphere.tectonic_activity)
      expect(subject.instance_variable_get(:@geological_activity)).to eq(geosphere.geological_activity)
    end
  end
  
  describe '#simulate' do
    it 'calls all the simulation methods in order' do
      expect(subject).to receive(:simulate_tectonic_activity).once.ordered
      expect(subject).to receive(:manage_regolith_properties).once.ordered 
      expect(subject).to receive(:simulate_erosion).once.ordered
      expect(subject).to receive(:simulate_geological_events).once.ordered
      expect(subject).to receive(:update_geosphere_state).once.ordered
      
      subject.simulate
    end
  end
  
  describe '#simulate_tectonic_activity' do
    it 'updates plate positions when tectonic activity is enabled' do
      expect(geosphere).to receive(:update_plate_positions)
      subject.send(:simulate_tectonic_activity)
    end
    
    it 'does nothing when tectonic activity is disabled' do
      allow(geosphere).to receive(:tectonic_activity).and_return(false)
      service = described_class.new(celestial_body)
      allow(service).to receive(:puts).and_return(nil)
      
      expect(geosphere).not_to receive(:update_plate_positions)
      service.send(:simulate_tectonic_activity)
    end
  end
  
  describe '#manage_regolith_properties' do
    it 'calculates weathering rate and updates geosphere' do
      expect(subject).to receive(:calculate_weathering_rate).and_return(3.5)
      
      # The actual method now checks for attribute existence, so we need to mock
      # the update call differently
      expect(geosphere).to receive(:update).with(hash_including(weathering_rate: 3.5))
      
      subject.send(:manage_regolith_properties)
    end
  end
  
  describe '#calculate_weathering_rate' do
    it 'returns a non-negative value' do
      rate = subject.send(:calculate_weathering_rate)
      expect(rate).to be >= 0
    end
    
    context 'with atmosphere and hydrosphere' do
      let(:atmosphere) { create(:atmosphere, celestial_body: celestial_body, pressure: 1.0) }
      let(:hydrosphere) { create(:hydrosphere, celestial_body: celestial_body) }
      
      before do
        # Create the spheres
        atmosphere
        hydrosphere
        
        # Ensure celestial_body returns the atmosphere and hydrosphere
        allow(celestial_body).to receive(:atmosphere).and_return(atmosphere)
        allow(celestial_body).to receive(:hydrosphere).and_return(hydrosphere)
        
        # Fix this line - stub respond_to? with any arguments
        allow(hydrosphere).to receive(:respond_to?).and_return(true)
        allow(hydrosphere).to receive(:surface_water_percentage).and_return(70.0)
      end
      
      it 'calculates a higher weathering rate' do
        with_rate = subject.send(:calculate_weathering_rate)
        
        # Remove the hydrosphere and recalculate
        allow(celestial_body).to receive(:hydrosphere).and_return(nil)
        without_rate = subject.send(:calculate_weathering_rate)
        
        expect(with_rate).to be > without_rate
      end
    end
  end

  describe '#eruption' do
    it 'adds volcanic gases to the atmosphere' do
      # Create a complete test environment
      celestial_body = create(:celestial_body)
      atmosphere = create(:atmosphere, celestial_body: celestial_body)
      
      # Create the service with the right setup
      service = TerraSim::GeosphereSimulationService.new(celestial_body)
      
      # Track gas creation in the atmosphere
      expect {
        service.send(:eruption)
      }.to change { atmosphere.reload.gases.count }
    end
  end
end