require 'rails_helper'

RSpec.describe OrbitalMechanics do
  let(:test_class) do
    Class.new do
      include OrbitalMechanics
      attr_accessor :mass, :spatial_location
    end
  end

  let(:test_object) { test_class.new }
  let(:other_object) { test_class.new }

  before do
    test_object.mass = 1.0e30 # Solar mass
    other_object.mass = 1.0e24 # Earth-like mass
    
    test_object.spatial_location = double(
      'SpatialLocation',
      x_coordinate: 0.0,
      y_coordinate: 0.0,
      z_coordinate: 0.0
    )
    allow(test_object.spatial_location).to receive(:distance_to).and_return(1.496e11) # 1 AU in meters
    
    other_object.spatial_location = double(
      'SpatialLocation',
      x_coordinate: 1.0,
      y_coordinate: 1.0,
      z_coordinate: 1.0
    )
    allow(other_object.spatial_location).to receive(:distance_to).and_return(1.496e11)
  end

  describe '#orbital_period_around' do
    it 'calculates orbital period using Kepler\'s Third Law' do
      period = other_object.orbital_period_around(test_object)
      expect(period).to be_within(1000000).of(44_501_451) # ~1.41 years in seconds for Earth around half-Sun-mass
    end

    it 'returns nil if spatial_location is missing' do
      other_object.spatial_location = nil
      expect(other_object.orbital_period_around(test_object)).to be_nil
    end
  end

  describe '#barycenter_with' do
    it 'calculates center of mass for two bodies' do
      x, y, z = test_object.barycenter_with(other_object)
      
      # With large mass difference, barycenter should be very close to larger mass
      expect(x).to be_within(0.001).of(0.0)
      expect(y).to be_within(0.001).of(0.0)
      expect(z).to be_within(0.001).of(0.0)
    end

    it 'returns nil if spatial_location is missing' do
      test_object.spatial_location = nil
      expect(test_object.barycenter_with(other_object)).to be_nil
    end
  end
end