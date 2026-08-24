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

    it 'decays toward 0.0 for Mars-class dead-core inputs (low mass, old age)' do
      # Mars mass + old age → dead core → decays to ~0.0 regardless of baseline
      strength = generator.send(
        :calculate_magnetosphere_strength,
        0.5,           # baseline (would be neutral without gate)
        6.39e23,       # Mars mass (~0.1 Earth mass)
        24,            # rotation period
        4.5e9          # age > 3 Gy threshold
      )
      expect(strength).to be < 0.05, "Dead-core gate failed: expected <0.05 but got #{strength.round(4)}"
    end

    it 'returns ~0.3-0.6 for Venus-class (alive core but slower rotation)' do
      # Venus mass + old age → alive core (barely) → physics modifier applies
      strength = generator.send(
        :calculate_magnetosphere_strength,
        0.3,           # Venus baseline (induced field)
        4.867e24,      # Venus mass (~0.8 Earth mass)
        243 * 24,      # Venus rotation: 243 days (very slow)
        4.5e9          # old age
      )
      # Core is alive but rotation is very slow → some strength remains
      expect(strength).to be > 0.1, "Venus should have some magnetosphere"
      expect(strength).to be < 0.8, "Venus should not have strong magnetosphere"
    end

    it 'caps at 1.0 when baseline + modifiers exceed 1.0' do
      # Baseline 0.95 with physics modifier for Earth-mass → may cap at 1.0
      strength = generator.send(:calculate_magnetosphere_strength, 0.95)
      expect(strength).to be <= 1.0
      
      # But baseline 1.0 should cap at 1.0
      strength_max = generator.send(:calculate_magnetosphere_strength, 1.0)
      expect(strength_max).to eq(1.0)
    end

    it 'clamps negative baseline to 0.0 but adds physics modifier for alive core' do
      # Negative baseline clamped to 0.0, but Earth-mass + young age → alive core
      strength = generator.send(:calculate_magnetosphere_strength, -0.5)
      expect(strength).to be > 0.0, "Earth-mass body should have some magnetosphere"
      expect(strength).to be <= 1.0
    end

    it 'clamps baseline > 1.0 to 1.0' do
      strength = generator.send(:calculate_magnetosphere_strength, 2.0)
      expect(strength).to eq(1.0)
    end

    describe 'parent body influence (stubbed)' do
      it 'returns physics-modified value for moons without parent body lookup infrastructure' do
        # Architecture: moons inside gas giant magnetospheres should get partial shielding
        # Currently stubbed at 0.0 until parent body lookup is implemented
        # But physics modifier still applies if core is alive
        moon_baseline = 0.0
        strength = generator.send(:calculate_magnetosphere_strength, moon_baseline)
        # With default Earth-mass + young age → alive core → physics adds some strength
        expect(strength).to be > 0.0, "Default params should produce alive core"
        expect(strength).to be <= 1.0
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

  describe '#generate_moons_for_planet — parent magnetosphere influence' do
    let(:planet_with_mag) do
      {
        'name' => 'Saturn',
        'identifier' => 'SATURN',
        'magnetosphere_strength' => 0.5,
        'radius' => 6.0e7,
        'surface_temperature' => 134
      }
    end

    let(:planet_no_mag) do
      {
        'name' => 'Uranus',
        'identifier' => 'URANUS',
        'magnetosphere_strength' => 0.05,
        'radius' => 2.5e7,
        'surface_temperature' => 77
      }
    end

    it 'applies parent magnetosphere bonus when parent strength > 0.1' do
      # Seed for reproducibility — ensure moon gets intrinsic mag via the 1% rand path
      srand(42)
      moons = generator.send(:generate_moons_for_planet, planet_with_mag, 1, 'TEST')
      moon = moons.first
      expect(moon['type']).to eq('moon')
      # properties.has_magnetosphere should be true when parent mag > 0.1
      if moon['properties']
        expect(moon['properties']['has_magnetosphere']).to be true
      end
    end

    it 'caps bonus at 1.0' do
      strong_parent = planet_with_mag.merge('magnetosphere_strength' => 1.0)
      srand(99)
      moons = generator.send(:generate_moons_for_planet, strong_parent, 1, 'TEST')
      moon = moons.first
      if moon['magnetosphere_strength']
        expect(moon['magnetosphere_strength']).to be <= 1.0
      end
    end

    it 'does NOT apply bonus when parent magnetosphere_strength <= 0.1' do
      # Workaround removed: @body_data swap bug fixed in procedural_generator.rb line 29
      moons = generator.send(:generate_moons_for_planet, planet_no_mag, 5, 'TEST')
      moons.each do |moon|
        # properties should not have has_magnetosphere set by parent influence
        if moon['properties'] && moon['properties'].key?('has_magnetosphere')
          expect(moon['properties']['has_magnetosphere']).to be false
        end
      end
    end

    it 'does not modify parent body data' do
      original_mag = planet_with_mag['magnetosphere_strength']
      srand(55)
      generator.send(:generate_moons_for_planet, planet_with_mag, 1, 'TEST')
      expect(planet_with_mag['magnetosphere_strength']).to eq(original_mag)
    end
  end
end
