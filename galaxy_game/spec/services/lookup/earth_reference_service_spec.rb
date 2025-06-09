require 'rails_helper'

RSpec.describe Lookup::EarthReferenceService, type: :service do
  # Create a real service instance that reads from the fixture file
  let(:service) { described_class.new }
  
  # Basic tests for all methods
  describe 'Earth reference data' do
    it 'loads Earth data from the fixture file' do
      # If all these pass, it means the file was loaded successfully
      expect(service.radius).to be > 6000.0  # Approximately 6371 km
      expect(service.gravity).to be_within(0.1).of(9.8)
      expect(service.mass).to be > 5.0e24
      expect(service.atmospheric_pressure).to be > 100000.0  # ~101325 Pa
      expect(service.surface_temperature).to be_within(10).of(288)
      
      # Check atmosphere composition has expected gases
      expect(service.atmosphere_composition).to include("N2", "O2")
      expect(service.atmosphere_composition["N2"]["percentage"]).to be_within(5).of(78)
    end
  end
  
  # Test fallback behavior
  describe 'fallback behavior' do
    it 'uses fallback values when properties are missing' do
      # Create a service with incomplete data
      allow_any_instance_of(described_class).to receive(:load_earth_data) do |instance|
        # Set incomplete Earth data missing some properties
        instance.instance_variable_set(:@earth_data, {
          "name" => "Earth",
          "radius" => 6371000.0,
          # Missing gravity, mass, etc.
        })
      end
      
      # Service should use fallbacks for missing properties
      incomplete_service = described_class.new
      expect(incomplete_service.gravity).to be_within(0.1).of(9.8)
      expect(incomplete_service.mass).to be > 5.0e24
    end
  end
end