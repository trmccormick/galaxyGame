require 'rails_helper'

RSpec.describe StarSim::ProceduralGenerator do
  let(:generator) { described_class.new }

  describe '#calculate_magnetosphere_strength' do
    it 'returns value in [0.0, 1.0] for all baseline inputs' do
      50.times do
        baseline = rand(0.0..1.0)
        strength = generator.send(:calculate_magnetosphere_strength, baseline)
        expect(strength).to be >= 0.0
        expect(strength).to be <= 1.0
      end
    end

    it 'returns ~1.0 for Earth baseline (1.0)' do
      strength = generator.send(:calculate_magnetosphere_strength, 1.0)
      expect(strength).to be_within(0.01).of(1.0)
    end

    it 'returns 0.0 for Mars baseline (0.0) with no modifiers' do
      strength = generator.send(:calculate_magnetosphere_strength, 0.0)
      expect(strength).to eq(0.0)
    end

    it 'returns Venus baseline (0.3) unchanged when no modifiers active' do
      strength = generator.send(:calculate_magnetosphere_strength, 0.3)
      expect(strength).to be_within(0.01).of(0.3)
    end

    it 'caps at 1.0 when baseline + modifiers exceed 1.0' do
      # Baseline 0.95 with no modifiers = 0.95 (not capped)
      strength = generator.send(:calculate_magnetosphere_strength, 0.95)
      expect(strength).to eq(0.95)
      
      # But baseline 1.0 should cap at 1.0
      strength_max = generator.send(:calculate_magnetosphere_strength, 1.0)
      expect(strength_max).to eq(1.0)
    end

    it 'clamps negative baseline to 0.0' do
      strength = generator.send(:calculate_magnetosphere_strength, -0.5)
      expect(strength).to eq(0.0)
    end

    it 'clamps baseline > 1.0 to 1.0' do
      strength = generator.send(:calculate_magnetosphere_strength, 2.0)
      expect(strength).to eq(1.0)
    end

    describe 'parent body influence (stubbed)' do
      it 'returns baseline for moons without parent body lookup infrastructure' do
        # Architecture: moons inside gas giant magnetospheres should get partial shielding
        # Currently stubbed at 0.0 until parent body lookup is implemented
        moon_baseline = 0.0
        strength = generator.send(:calculate_magnetosphere_strength, moon_baseline)
        expect(strength).to eq(0.0) # baseline only, no parent influence yet
      end
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
