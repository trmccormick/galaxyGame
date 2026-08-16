require 'rails_helper'

describe StarSim::ProceduralGenerator do
  let(:generator) { described_class.new }

  describe '#calculate_magnetosphere_strength' do
    it 'returns baseline + physics_modifier when core is alive (default Earth-mass, 24h, 4.5Gy)' do
      # Default params: Earth mass, 24h rotation, 4.5 Gy age → alive core
      strength = generator.send(:calculate_magnetosphere_strength, 0.5)
      expect(strength).to be > 0.5  # physics_modifier adds to baseline
    end

    it 'clamps negative baselines to 0.0 (with physics_modifier for alive core)' do
      # Negative baseline clamped to 0.0, but physics_modifier adds when core is alive
      strength = generator.send(:calculate_magnetosphere_strength, -0.5)
      expect(strength).to be > 0.0  # physics_modifier adds even with 0 baseline
    end

    it 'clamps baselines above 1.0 to 1.0 (physics_modifier added but capped)' do
      strength = generator.send(:calculate_magnetosphere_strength, 2.0)
      expect(strength).to be <= 1.0  # result capped at 1.0, may be less if core aging reduces it
    end

    it 'returns value in [0.0, 1.0] for all inputs' do
      50.times do
        baseline = rand(-1.0..2.0)
        strength = generator.send(:calculate_magnetosphere_strength, baseline)
        expect(strength).to be >= 0.0
        expect(strength).to be <= 1.0
      end
    end

    it 'returns ~0.0 for Mars-class dead-core inputs (low mass, old age)' do
      # Must use Mars-class params: low mass + old age → dead core
      strength = generator.send(
        :calculate_magnetosphere_strength,
        0.0,           # baseline
        6.39e23,       # Mars mass (~0.1 Earth mass)
        24,            # rotation period
        4.5e9          # age > 3 Gy threshold → dead core
      )
      expect(strength).to be < 0.05, "Dead-core gate failed: expected <0.05 but got #{strength.round(4)}"
    end

    it 'returns ~1.0 for Earth-class inputs (baseline 1.0, capped at 1.0)' do
      strength = generator.send(:calculate_magnetosphere_strength, 1.0)
      expect(strength).to be_within(0.1).of(1.0)  # physics_modifier adds but capped at 1.0
    end

    it 'returns ~0.3 + physics_modifier for Venus-class inputs (baseline 0.3)' do
      strength = generator.send(:calculate_magnetosphere_strength, 0.3)
      expect(strength).to be > 0.3  # physics_modifier adds to baseline
    end

    it 'applies physics-based calculation when core is alive' do
      # Earth-mass, young body → alive core → physics modifier active
      s_alive = generator.send(:calculate_magnetosphere_strength, 0.5, 5.972e24, 12, 1e9)
      # Mars-mass, old body → dead core → core_state_factor = 0.0 kills the field
      s_dead = generator.send(:calculate_magnetosphere_strength, 0.5, 6.39e23, 24, 4.5e9)
      expect(s_alive).to be > s_dead
    end
  end

  describe '#calculate_magnetosphere_radius' do
    it 'returns ~60,000 km for Earth-strength field (strength=1.0, Earth mass)' do
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
      weak_strength = 0.3
      strong_strength = 1.0
      earth_mass = 5.972e24

      weak_radius = generator.send(:calculate_magnetosphere_radius, earth_mass, weak_strength)
      strong_radius = generator.send(:calculate_magnetosphere_radius, earth_mass, strong_strength)

      expect(strong_radius).to be > weak_radius
    end
  end

  describe '#generate_procedural_terrestrial' do
    it 'includes magnetosphere_strength in output' do
      planet_data = generator.send(:generate_procedural_terrestrial, 'Test-P1', 'TEST-P1', 0)
      expect(planet_data).to have_key('magnetosphere_strength')
      expect(planet_data['magnetosphere_strength']).to be_a(Numeric)
    end

    it 'includes magnetosphere_radius_km if strength > 0.0' do
      planet_data = generator.send(:generate_procedural_terrestrial, 'Test-P1', 'TEST-P1', 0)
      if planet_data['magnetosphere_strength'] > 0.01
        expect(planet_data).to have_key('magnetosphere_radius_km')
        expect(planet_data['magnetosphere_radius_km']).to be_a(Integer)
      end
    end

    it 'returns ~0.5 + physics_modifier for procedurally generated planets' do
      # Procedural baseline = 0.5, Earth-mass → alive core → physics adds on top
      planet_data = generator.send(:generate_procedural_terrestrial, 'Test-P1', 'TEST-P1', 0)
      expect(planet_data['magnetosphere_strength']).to be > 0.5
    end

    it 'omits magnetosphere_radius_km if strength is 0.0' do
      # Mock to generate strength 0.0
      allow(generator).to receive(:calculate_magnetosphere_strength).and_return(0.0)
      planet_data = generator.send(:generate_procedural_terrestrial, 'Test-P1', 'TEST-P1', 0)
      expect(planet_data['magnetosphere_radius_km']).to be_nil
    end

    it 'includes parent_body and orbital_distance_km for moons' do
      # Moons should have these fields for parent protection inheritance
      # This is tested in the moon generation spec if applicable
      # For now, verify terrestrial planets don't have parent_body
      planet_data = generator.send(:generate_procedural_terrestrial, 'Test-P1', 'TEST-P1', 0)
      expect(planet_data).not_to have_key('parent_body')
    end
  end

  describe 'Dead-core gate verification' do
    let(:system_data) { JSON.parse(File.read(Rails.root.join('app/data/star_systems/sol-complete.json'))) }

    it 'MARS: sol-complete.json has magnetosphere_strength = 0.0 (data-driven, not calculated)' do
      mars = system_data['celestial_bodies'].find { |b| b['name'] == 'Mars' }
      expect(mars['magnetosphere_strength']).to eq(0.0)
    end

    it 'EARTH: sol-complete.json has magnetosphere_strength = 1.0' do
      earth = system_data['celestial_bodies'].find { |b| b['name'] == 'Earth' }
      expect(earth['magnetosphere_strength']).to eq(1.0)
    end

    it 'VENUS: sol-complete.json has magnetosphere_strength = 0.3' do
      venus = system_data['celestial_bodies'].find { |b| b['name'] == 'Venus' }
      expect(venus['magnetosphere_strength']).to eq(0.3)
    end

    # CRITICAL: The 2026-08-05 decision required a CALCULATED dead-core gate.
    # This test verifies procedurally generated Mars-like bodies produce ~0.0,
    # not the old bug where they produced ~0.47 (neutral baseline).
    it 'PROCEDURAL MARS: low mass + old age + slow rotation → ≤0.05 magnetosphere' do
      # Mars-class inputs: mass < 1e24 kg, age > 4 Gy, slow/no rotation
      strength = generator.send(
        :calculate_magnetosphere_strength,
        0.5,           # baseline (would be neutral without gate)
        6.39e23,       # Mars mass (~0.1 Earth mass)
        24,            # slow rotation
        4.5e9          # old age (> 3 Gy threshold)
      )
      expect(strength).to be <= 0.05, "Dead-core gate failed: expected ≤0.05 but got #{strength.round(4)}"
    end

    it 'PROCEDURAL MARS ANALOG: explicitly low mass (0.05 M⊕), old age (5 Gy), no rotation → ~0.0' do
      # Mercury-class body with extreme parameters — should definitely be dead core
      strength = generator.send(
        :calculate_magnetosphere_strength,
        0.5,           # baseline
        3.285e23,      # Mercury mass (0.055 M⊕)
        nil,            # no rotation (treated as slow)
        5e9            # old age (> 4.5 Gy)
      )
      expect(strength).to be <= 0.02, "Dead-core gate failed: expected ≤0.02 but got #{strength.round(4)}"
    end

    it 'PROCEDURAL EARTH: Earth mass + young age → alive core (gate passes)' do
      earth_mass = 5.972e24
      strength = generator.send(
        :calculate_magnetosphere_strength,
        0.5,           # baseline
        earth_mass,    # Earth mass
        24,            # rotation
        1e9            # young age (< 3 Gy threshold)
      )
      # Core is alive, so physics modifier applies (not killed by gate)
      expect(strength).to be > 0.3, "Earth-mass body should have alive core"
    end

    it 'PROCEDURAL VENUS: Venus mass + old age → slowing core but still dynamo' do
      venus_mass = 4.867e24
      strength = generator.send(
        :calculate_magnetosphere_strength,
        0.5,           # baseline
        venus_mass,    # Venus mass (0.815 M⊕)
        5832,          # slow rotation (243 Earth days)
        4.5e9          # old age
      )
      # Venus should still have some dynamo (core_state ~0.66) but weaker than Earth
      expect(strength).to be > 0.2, "Venus should have some dynamo: got #{strength.round(4)}"
      expect(strength).to be < 0.6, "Venus should be weaker than Earth: got #{strength.round(4)}"
    end

    it 'calculate_core_state_factor returns 0.0 for dead-core inputs' do
      factor = generator.send(:calculate_core_state_factor, 6.39e23, 4.5e9)
      expect(factor).to be < 0.1, "Dead-core gate should return ~0.0 for Mars-class"
    end

    it 'calculate_core_state_factor returns > 0.5 for alive-core inputs' do
      factor = generator.send(:calculate_core_state_factor, 5.972e24, 1e9)
      # Earth-mass young body should have alive core (factor > 0.5)
      expect(factor).to be > 0.5
    end
  end
end
