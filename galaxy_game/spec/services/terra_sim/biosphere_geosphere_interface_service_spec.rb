require 'rails_helper'

RSpec.describe TerraSim::BiosphereGeosphereInterfaceService, type: :service do
  # Create celestial body with default spheres
  let(:celestial_body) { create(:celestial_body) }
  
  # Access existing spheres
  let(:biosphere) { celestial_body.biosphere }
  let(:geosphere) { celestial_body.geosphere }

  # Update sphere attributes if needed
  before do
    geosphere.update!(weathering_rate: 10.0)
    biosphere.update!(biodiversity_index: 0.8)
    
    # Reload to ensure associations are up to date
    celestial_body.reload
    biosphere.reload
    geosphere.reload
  end
  
  # Create subject after setup
  subject { described_class.new(celestial_body) }
  
  describe '#initialize' do
    it 'sets the celestial body and sphere references' do
      expect(subject.instance_variable_get(:@celestial_body)).to eq(celestial_body)
      expect(subject.instance_variable_get(:@biosphere)).to eq(biosphere)
      expect(subject.instance_variable_get(:@geosphere)).to eq(geosphere)
    end
  end
  
  describe '#simulate' do
    context 'when spheres are missing' do
      it 'returns nil if biosphere is missing' do
        # Create a new celestial body with only a geosphere
        body = create(:celestial_body)
        # Remove the biosphere
        body.biosphere.destroy
        # Add a geosphere if it doesn't exist
        create(:geosphere, celestial_body: body) unless body.geosphere
        body.reload
        
        service = described_class.new(body)
        # This should now be nil
        expect(service.instance_variable_get(:@biosphere)).to be_nil
        expect(service.simulate).to be_nil
      end
      
      it 'returns nil if geosphere is missing' do
        # Create a new celestial body with only a biosphere
        body = create(:celestial_body)
        # Remove the geosphere
        body.geosphere.destroy
        # Add a biosphere if it doesn't exist
        create(:biosphere, celestial_body: body) unless body.biosphere
        body.reload
        
        service = described_class.new(body)
        expect(service.instance_variable_get(:@geosphere)).to be_nil
        expect(service.simulate).to be_nil
      end
    end
    
    # Test for calculating soil health
    it 'calculates and updates soil health based on both spheres' do
      # No need for debugging prints in final code
      expect_any_instance_of(CelestialBodies::Spheres::Biosphere).to receive(:update_soil_health).with(95.0)
      result = subject.simulate
      expect(result).to be true
    end
  end
end