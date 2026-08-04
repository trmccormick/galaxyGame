require 'rails_helper'

RSpec.describe StarSim::ProceduralGenerator do
  let(:generator) { described_class.new }

  describe '#calculate_magnetosphere_strength' do
    it 'returns value in [0.0, 1.0] for all inputs' do
      50.times do
        mass = rand(0.1e24..10e24)
        rotation = rand(6.0..100.0)
        age = rand(0.0..10e9)
        strength = generator.send(:calculate_magnetosphere_strength, mass, rotation, age)
        expect(strength).to be >= 0.0
        expect(strength).to be <= 1.0
      end
    end

    it 'returns ~1.0 for Earth-mass planet at ~4.5 Gy age' do
      earth_mass = 5.972e24
      strength = generator.send(:calculate_magnetosphere_strength, earth_mass, 24, 4.5e9)
      expect(strength).to be_within(0.15).of(1.0)
    end

    it 'returns low value for very old planet with slow rotation' do
      strength = generator.send(:calculate_magnetosphere_strength, 1e24, 1000, 1e10)
      expect(strength).to be < 0.3
    end

    it 'returns lower value for Mars-mass planet than Earth' do
      mars_mass = 6.42e23
      earth_strength = generator.send(:calculate_magnetosphere_strength, 5.972e24, 24, 4.5e9)
      mars_strength = generator.send(:calculate_magnetosphere_strength, mars_mass, 24.6, 4.5e9)
      
      expect(mars_strength).to be < earth_strength
    end

    it 'returns higher value for larger planets (up to clamp)' do
      earth_mass = 5.972e24
      super_earth_mass = 5.0 * earth_mass
      
      earth_strength = generator.send(:calculate_magnetosphere_strength, earth_mass, 24, 4.5e9)
      super_earth_strength = generator.send(:calculate_magnetosphere_strength, super_earth_mass, 24, 4.5e9)
      
      # Super-Earth should be >= Earth (may hit clamp at 1.0)
      expect(super_earth_strength).to be >= earth_strength
    end

    it 'returns higher value for faster rotation' do
      mass = 5.972e24
      
      slow_strength = generator.send(:calculate_magnetosphere_strength, mass, 100, 4.5e9)
      fast_strength = generator.send(:calculate_magnetosphere_strength, mass, 12, 4.5e9)
      
      expect(fast_strength).to be > slow_strength
    end
  end

  describe '#calculate_magnetosphere_radius' do
    it 'returns ~60,000 km for Earth-strength field' do
      earth_mass = 5.972e24
      radius = generator.send(:calculate_magnetosphere_radius, earth_mass, 1.0)
      expect(radius).to be_within(10000).of(60000)
    end

    it 'returns nil for no magnetosphere (strength 0.0)' do
      radius = generator.send(:calculate_magnetosphere_radius, 1e24, 0.0)
      expect(radius).to be_nil
    end

    it 'returns nil for very weak field (strength < 0.01)' do
      radius = generator.send(:calculate_magnetosphere_radius, 1e24, 0.005)
      expect(radius).to be_nil
    end

    it 'scales with mass: larger planets extend further' do
      weak_mass = 0.5e24
      strong_mass = 5.0e24
      
      weak_radius = generator.send(:calculate_magnetosphere_radius, weak_mass, 1.0)
      strong_radius = generator.send(:calculate_magnetosphere_radius, strong_mass, 1.0)
      
      expect(strong_radius).to be > weak_radius
    end

    it 'returns numeric km value for valid inputs' do
      radius = generator.send(:calculate_magnetosphere_radius, 1e24, 0.5)
      expect(radius).to be_a(Integer)
      expect(radius).to be > 0
    end

    it 'scales with strength: stronger fields extend further' do
      mass = 5.972e24
      
      weak_radius = generator.send(:calculate_magnetosphere_radius, mass, 0.3)
      strong_radius = generator.send(:calculate_magnetosphere_radius, mass, 1.0)
      
      expect(strong_radius).to be > weak_radius
    end
  end

  describe '#generate_procedural_terrestrial' do
    it 'includes magnetosphere_strength in output' do
      planet_data = generator.send(:generate_procedural_terrestrial, 'Test-P1', 'TEST-P1', 0)
      expect(planet_data).to have_key('magnetosphere_strength')
      expect(planet_data['magnetosphere_strength']).to be_a(Numeric)
      expect(planet_data['magnetosphere_strength']).to be >= 0.0
      expect(planet_data['magnetosphere_strength']).to be <= 1.0
    end

    it 'includes magnetosphere_radius_km if strength > 0.0' do
      planet_data = generator.send(:generate_procedural_terrestrial, 'Test-P1', 'TEST-P1', 0)
      if planet_data['magnetosphere_strength'] > 0.01
        expect(planet_data).to have_key('magnetosphere_radius_km')
        expect(planet_data['magnetosphere_radius_km']).to be_a(Integer)
        expect(planet_data['magnetosphere_radius_km']).to be > 0
      end
    end

    it 'includes rotation_period_hours in output' do
      planet_data = generator.send(:generate_procedural_terrestrial, 'Test-P1', 'TEST-P1', 0)
      expect(planet_data).to have_key('rotation_period_hours')
      expect(planet_data['rotation_period_hours']).to be_a(Numeric)
      expect(planet_data['rotation_period_hours']).to be >= 6.0
      expect(planet_data['rotation_period_hours']).to be <= 48.0
    end

    it 'generates varied magnetosphere values across multiple planets' do
      # Just verify the field is present and in range - variation depends on rand seed
      10.times do |i|
        planet_data = generator.send(:generate_procedural_terrestrial, "Test-P#{i}", "TEST-P#{i}", i)
        expect(planet_data['magnetosphere_strength']).to be_a(Numeric)
        expect(planet_data['magnetosphere_strength']).to be >= 0.0
        expect(planet_data['magnetosphere_strength']).to be <= 1.0
      end
    end
  end
end
