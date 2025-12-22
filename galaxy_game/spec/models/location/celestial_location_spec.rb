# spec/models/location/celestial_location_spec.rb
require 'rails_helper'

RSpec.describe Location::CelestialLocation, type: :model do
  let(:celestial_body) { create(:celestial_body) }

  describe 'associations' do
    it { is_expected.to belong_to(:celestial_body) }
    it { is_expected.to belong_to(:locationable).optional }
  end

  describe 'validations' do
    subject { build(:celestial_location, celestial_body: celestial_body) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:celestial_body) }

    context 'coordinate format' do
      it 'accepts valid coordinates' do
        location = build(:celestial_location, celestial_body: celestial_body, coordinates: '45.50°N 120.50°W')
        expect(location).to be_valid
      end

      it 'rejects invalid coordinates' do
        location = build(:celestial_location, celestial_body: celestial_body, coordinates: 'invalid')
        expect(location).not_to be_valid
        expect(location.errors[:coordinates]).to include("must be in format '00.00°N/S 00.00°E/W'")
      end
    end

    context 'uniqueness validation' do
      let!(:existing_body) { create(:celestial_body) }
      let!(:another_body) { create(:celestial_body) }
      let!(:existing_location) { create(:celestial_location, celestial_body: existing_body, coordinates: '77.65°N 64.40°W') }
    
      it 'validates that coordinates are case-insensitively unique within the same celestial body' do
        new_location = build(:celestial_location, celestial_body: existing_body, coordinates: '77.65°n 64.40°w')
        expect(new_location.valid?).to be false
        expect(new_location.errors[:coordinates]).to include('has already been taken')
      end
    
      it 'validates that coordinates are unique with the same case within the same celestial body' do
        new_location = build(:celestial_location, celestial_body: existing_body, coordinates: '77.65°N 64.40°W')
        expect(new_location.valid?).to be false
        expect(new_location.errors[:coordinates]).to include('has already been taken')
      end
    
      it 'allows the same coordinates on a different celestial body' do
        new_location = build(:celestial_location, celestial_body: another_body, coordinates: '77.65°N 64.40°W')
        expect(new_location).to be_valid
      end
    
      it 'allows different coordinates on the same celestial body' do
        new_location = build(:celestial_location, celestial_body: existing_body, coordinates: '79.00°N 110.00°W')
        expect(new_location).to be_valid
      end
    end

    it 'is invalid without coordinates' do
      subject.coordinates = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:coordinates]).to include("can't be blank")
    end

    it 'is invalid with blank coordinates' do
      subject.coordinates = ""
      expect(subject).not_to be_valid
      expect(subject.errors[:coordinates]).to include("can't be blank")
    end
    
    # NEW: Altitude validations
    context 'altitude validation' do
      it 'accepts nil altitude (surface location)' do
        location = build(:celestial_location, celestial_body: celestial_body, altitude: nil)
        expect(location).to be_valid
      end
      
      it 'accepts zero altitude (surface location)' do
        location = build(:celestial_location, celestial_body: celestial_body, altitude: 0)
        expect(location).to be_valid
      end
      
      it 'accepts positive altitude (orbital location)' do
        location = build(:celestial_location, celestial_body: celestial_body, altitude: 400_000)
        expect(location).to be_valid
      end
      
      it 'rejects negative altitude' do
        location = build(:celestial_location, celestial_body: celestial_body, altitude: -1000)
        expect(location).not_to be_valid
        expect(location.errors[:altitude]).to be_present
      end
    end
  end
  
  # NEW: Scopes
  describe 'scopes' do
    let!(:surface_loc1) do
      create(:celestial_location,
        celestial_body: celestial_body,
        coordinates: '10.00°N 20.00°E',
        altitude: nil
      )
    end
    
    let!(:surface_loc2) do
      create(:celestial_location,
        celestial_body: celestial_body,
        coordinates: '15.00°N 25.00°E',
        altitude: 0
      )
    end
    
    let!(:low_orbit_loc) do
      create(:celestial_location,
        celestial_body: celestial_body,
        coordinates: '0.00°N 0.00°E',
        altitude: 400_000  # 400 km
      )
    end
    
    let!(:medium_orbit_loc) do
      create(:celestial_location,
        celestial_body: celestial_body,
        coordinates: '0.00°N 10.00°E',
        altitude: 20_000_000  # 20,000 km
      )
    end
    
    let!(:high_orbit_loc) do
      create(:celestial_location,
        celestial_body: celestial_body,
        coordinates: '0.00°N 20.00°E',
        altitude: 36_000_000  # 36,000 km
      )
    end
    
    describe '.surface_locations' do
      it 'returns locations with nil or zero altitude' do
        results = described_class.surface_locations
        expect(results).to include(surface_loc1, surface_loc2)
        expect(results).not_to include(low_orbit_loc, medium_orbit_loc, high_orbit_loc)
      end
    end
    
    describe '.orbital_locations' do
      it 'returns locations with positive altitude' do
        results = described_class.orbital_locations
        expect(results).to include(low_orbit_loc, medium_orbit_loc, high_orbit_loc)
        expect(results).not_to include(surface_loc1, surface_loc2)
      end
    end
    
    describe '.low_orbit' do
      it 'returns locations between 0 and 2,000 km' do
        results = described_class.low_orbit
        expect(results).to include(low_orbit_loc)
        expect(results).not_to include(medium_orbit_loc, high_orbit_loc)
      end
    end
    
    describe '.medium_orbit' do
      it 'returns locations between 2,000 and 35,786 km' do
        results = described_class.medium_orbit
        expect(results).to include(medium_orbit_loc)
        expect(results).not_to include(low_orbit_loc, high_orbit_loc)
      end
    end
    
    describe '.high_orbit' do
      it 'returns locations above 35,786 km' do
        results = described_class.high_orbit
        expect(results).to include(high_orbit_loc)
        expect(results).not_to include(low_orbit_loc, medium_orbit_loc)
      end
    end
  end
  
  # NEW: Location type helpers
  describe '#surface?' do
    it 'returns true for nil altitude' do
      location = build(:celestial_location, altitude: nil)
      expect(location.surface?).to be true
    end
    
    it 'returns true for zero altitude' do
      location = build(:celestial_location, altitude: 0)
      expect(location.surface?).to be true
    end
    
    it 'returns false for positive altitude' do
      location = build(:celestial_location, altitude: 400_000)
      expect(location.surface?).to be false
    end
  end
  
  describe '#orbital?' do
    it 'returns false for surface locations' do
      location = build(:celestial_location, altitude: 0)
      expect(location.orbital?).to be false
    end
    
    it 'returns true for orbital locations' do
      location = build(:celestial_location, altitude: 400_000)
      expect(location.orbital?).to be true
    end
  end
  
  describe '#orbit_type' do
    it 'returns nil for surface locations' do
      location = build(:celestial_location, altitude: 0)
      expect(location.orbit_type).to be_nil
    end
    
    it 'returns :low for low orbit (< 2,000 km)' do
      location = build(:celestial_location, altitude: 400_000)
      expect(location.orbit_type).to eq(:low)
    end
    
    it 'returns :medium for medium orbit (2,000-35,786 km)' do
      location = build(:celestial_location, altitude: 20_000_000)
      expect(location.orbit_type).to eq(:medium)
    end
    
    it 'returns :high for high orbit (> 35,786 km)' do
      location = build(:celestial_location, altitude: 36_000_000)
      expect(location.orbit_type).to eq(:high)
    end
  end
  
  # NEW: Altitude helpers
  describe '#altitude_km' do
    it 'returns nil for surface locations' do
      location = build(:celestial_location, altitude: nil)
      expect(location.altitude_km).to be_nil
    end
    
    it 'converts meters to kilometers' do
      location = build(:celestial_location, altitude: 400_000)
      expect(location.altitude_km).to eq(400.0)
    end
  end
  
  describe '#altitude_km=' do
    it 'sets altitude from kilometers' do
      location = build(:celestial_location)
      location.altitude_km = 400
      expect(location.altitude).to eq(400_000)
    end
    
    it 'sets nil from nil' do
      location = build(:celestial_location)
      location.altitude_km = nil
      expect(location.altitude).to be_nil
    end
  end
  
  # NEW: Coordinate parsing
  describe '#latitude' do
    it 'parses positive latitude from North coordinates' do
      location = build(:celestial_location, coordinates: '45.50°N 120.50°W')
      expect(location.latitude).to eq(45.50)
    end
    
    it 'parses negative latitude from South coordinates' do
      location = build(:celestial_location, coordinates: '45.50°S 120.50°W')
      expect(location.latitude).to eq(-45.50)
    end
    
    it 'handles zero latitude' do
      location = build(:celestial_location, coordinates: '0.00°N 0.00°E')
      expect(location.latitude).to eq(0.0)
    end
  end
  
  describe '#longitude' do
    it 'parses positive longitude from East coordinates' do
      location = build(:celestial_location, coordinates: '45.50°N 120.50°E')
      expect(location.longitude).to eq(120.50)
    end
    
    it 'parses negative longitude from West coordinates' do
      location = build(:celestial_location, coordinates: '45.50°N 120.50°W')
      expect(location.longitude).to eq(-120.50)
    end
    
    it 'handles zero longitude' do
      location = build(:celestial_location, coordinates: '0.00°N 0.00°E')
      expect(location.longitude).to eq(0.0)
    end
  end
  
  # NEW: Orbital mechanics (only if celestial_body supports it)
  describe 'orbital mechanics' do
    let(:earth) do
      double('Earth',
        name: 'Earth',
        mass: 5.972e24,
        radius: 6_371_000,
        gravitational_parameter: 3.986e14,
        surface_gravity: 9.8
      )
    end
    
    let(:orbital_location) do
      location = Location::CelestialLocation.new(
        name: 'Orbital Location',
        coordinates: '0.00°N 0.00°E',
        altitude: 408_000
      )
      allow(location).to receive(:celestial_body).and_return(earth)
      location
    end
    
    let(:surface_location) do
      location = Location::CelestialLocation.new(
        name: 'Surface Location',
        coordinates: '40.71°N 74.01°W',
        altitude: 0
      )
      allow(location).to receive(:celestial_body).and_return(earth)
      location
    end
    
    describe '#orbital_period' do
      it 'returns nil for surface locations' do
        expect(surface_location.orbital_period).to be_nil
      end
      
      it 'calculates period for orbital locations' do
        # ISS orbit ~90 minutes = 5400 seconds
        period = orbital_location.orbital_period
        expect(period).to be_within(300).of(5400)
      end
      
      it 'returns nil if celestial body lacks required methods' do
        simple_body = double('Body')
        location = Location::CelestialLocation.new(
          name: 'Simple Location',
          coordinates: '0.00°N 0.00°E',
          altitude: 400_000
        )
        allow(location).to receive(:celestial_body).and_return(simple_body)
        expect(location.orbital_period).to be_nil
      end
    end
    
    describe '#orbital_velocity' do
      it 'returns nil for surface locations' do
        expect(surface_location.orbital_velocity).to be_nil
      end
      
      it 'calculates velocity for orbital locations' do
        # ISS velocity ~7700 m/s
        velocity = orbital_location.orbital_velocity
        expect(velocity).to be_within(200).of(7700)
      end
      
      it 'returns nil if celestial body lacks required methods' do
        simple_body = double('Body')
        location = Location::CelestialLocation.new(
          name: 'Simple Location',
          coordinates: '0.00°N 0.00°E',
          altitude: 400_000
        )
        allow(location).to receive(:celestial_body).and_return(simple_body)
        expect(location.orbital_velocity).to be_nil
      end
    end
    
    describe '#gravity' do
      it 'returns surface gravity for surface locations' do
        expect(surface_location.gravity).to eq(9.8)
      end
      
      it 'calculates reduced gravity at altitude' do
        gravity = orbital_location.gravity
        expect(gravity).to be < 9.8
        expect(gravity).to be > 8.0
      end
      
      it 'returns nil if celestial body lacks required methods' do
        simple_body = double('Body', surface_gravity: 9.8)
        location = Location::CelestialLocation.new(
          name: 'Simple Location',
          coordinates: '0.00°N 0.00°E',
          altitude: 400_000
        )
        allow(location).to receive(:celestial_body).and_return(simple_body)
        # Will return nil because it can't calculate without mass/radius
        expect(location.gravity).to be_nil
      end
    end
  end
  
  # NEW: Description methods
  describe '#description' do
    let(:body) { double('Body', name: 'Mars') }
    
    it 'describes surface locations' do
      location = Location::CelestialLocation.new(
        name: 'Surface Location',
        celestial_body: body,
        coordinates: '28.50°N 80.60°W',
        altitude: 0
      )
      
      desc = location.description
      expect(desc).to include('Surface location')
      expect(desc).to include('28.50°N 80.60°W')
      expect(desc).to include('Mars')
    end
    
    it 'describes orbital locations' do
      location = Location::CelestialLocation.new(
        name: 'Orbital Location',
        celestial_body: body,
        coordinates: '0.00°N 0.00°E',
        altitude: 400_000
      )
      
      desc = location.description
      expect(desc).to include('Low orbit')
      expect(desc).to include('400 km')
      expect(desc).to include('Mars')
    end
  end
  
  describe '#full_coordinates' do
    it 'returns coordinates for surface locations' do
      location = build(:celestial_location,
        coordinates: '28.50°N 80.60°W',
        altitude: 0
      )
      
      expect(location.full_coordinates).to eq('28.50°N 80.60°W')
    end
    
    it 'includes altitude for orbital locations' do
      location = build(:celestial_location,
        coordinates: '0.00°N 0.00°E',
        altitude: 400_000
      )
      
      coords = location.full_coordinates
      expect(coords).to include('0.00°N 0.00°E')
      expect(coords).to include('400 km')
    end
  end
end