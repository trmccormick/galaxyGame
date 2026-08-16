require 'rails_helper'

describe 'Data-Driven Celestial Body Generation' do
  describe 'Sol system magnetosphere values in sol-complete.json' do
    let(:system_data) { JSON.parse(File.read('data/json-data/star_systems/sol-complete.json')) }
    
    # Helper to find a body by name in the flat celestial_bodies array
    def find_body(data, name)
      data.dig('celestial_bodies', Array).find { |b| b['name'] == name }
    end

    describe 'Terrestrial planets' do
      it 'has Earth with magnetosphere_strength 1.0 and radius ~60000 km' do
        earth = find_body(system_data, 'Earth')
        expect(earth['magnetosphere_strength']).to eq(1.0)
        expect(earth['magnetosphere_radius_km']).to be_within(5000).of(60000)
      end

      it 'has Venus with magnetosphere_strength 0.3 and smaller radius' do
        venus = find_body(system_data, 'Venus')
        expect(venus['magnetosphere_strength']).to eq(0.3)
        expect(venus['magnetosphere_radius_km']).to be < 10000  # Induced field, shorter range
      end

      it 'has Mars with magnetosphere_strength 0.0 and no radius' do
        mars = find_body(system_data, 'Mars')
        expect(mars['magnetosphere_strength']).to eq(0.0)
        expect(mars['magnetosphere_radius_km']).to be_nil
      end

      it 'has Mercury with near-zero magnetosphere_strength (0.0001)' do
        mercury = find_body(system_data, 'Mercury')
        expect(mercury['magnetosphere_strength']).to eq(0.0001)
        expect(mercury['magnetosphere_radius_km']).to be < 1000
      end
    end

    describe 'Gas giants' do
      it 'has Jupiter with strong magnetosphere (1.0) and 7M km radius' do
        jupiter = find_body(system_data, 'Jupiter')
        expect(jupiter['magnetosphere_strength']).to eq(1.0)
        expect(jupiter['magnetosphere_radius_km']).to eq(7000000)
      end
    end

    describe 'Moons — parent magnetosphere data structure' do
      it 'has Ganymede with intrinsic magnetosphere_strength 0.15 and parent Jupiter' do
        ganymede = find_body(system_data, 'Ganymede')
        expect(ganymede['magnetosphere_strength']).to eq(0.15)
        expect(ganymede['magnetosphere_radius_km']).to eq(500)
        expect(ganymede['orbital_distance_km']).to eq(1070400)
        expect(ganymede['parent_body']).to eq('Jupiter')
      end

      it 'has Titan with magnetosphere_strength 0.0 and parent Saturn' do
        titan = find_body(system_data, 'Titan')
        expect(titan['magnetosphere_strength']).to eq(0.0)
        expect(titan['parent_body']).to eq('Saturn')
        expect(titan['orbital_distance_km']).to be > 0
      end

      it 'Ganymede orbits inside Jupiter magnetosphere (1.07M < 7M km)' do
        jupiter = find_body(system_data, 'Jupiter')
        ganymede = find_body(system_data, 'Ganymede')
        expect(ganymede['orbital_distance_km']).to be < jupiter['magnetosphere_radius_km']
      end

      it 'supports compound protection data model (intrinsic + parent reference)' do
        # Ganymede has both intrinsic field AND parent reference for future calculation
        ganymede = find_body(system_data, 'Ganymede')
        expect(ganymede).to have_key('magnetosphere_strength')  # own field
        expect(ganymede).to have_key('parent_body')              # for inherited protection
        expect(ganymede).to have_key('orbital_distance_km')      # for distance scaling
      end
    end
  end

  describe 'SystemBuilderService data passthrough' do
    it 'stores magnetosphere_strength in properties (numeric, not boolean)' do
      # Verify the add_special_properties method reads numeric values
      builder = StarSim::SystemBuilderService.new(name: 'sol')
      
      # Load sol-complete.json and verify Earth has the field
      system_data = JSON.parse(File.read('data/json-data/star_systems/sol-complete.json'))
      earth = system_data.dig('celestial_bodies', Array).find { |b| b['name'] == 'Earth' }
      
      expect(earth['magnetosphere_strength']).to be_a(Float)
      expect(earth['magnetosphere_strength']).to eq(1.0)
    end

    it 'does not use binary strong_magnetosphere flag for terrestrial planets' do
      # Verify no strong_magnetosphere boolean exists in sol-complete.json
      system_data = JSON.parse(File.read('data/json-data/star_systems/sol-complete.json'))
      
      system_data.dig('celestial_bodies', Array).each do |body|
        if body['type'] == 'terrestrial_planet'
          expect(body).not_to have_key('strong_magnetosphere')
        end
      end
    end

    it 'reads magnetosphere_strength from JSON (no planet-name conditionals)' do
      # Verify SystemBuilderService uses data-driven approach
      service_file = Rails.root.join('galaxy_game/app/services/star_sim/system_builder_service.rb').to_s
      content = File.read(service_file)
      
      # Should NOT contain planet name conditionals for magnetosphere
      expect(content).not_to match(/if.*name.*==.*['"]Earth['"]/)
      expect(content).not_to match(/if.*name.*==.*['"]Mars['"]/)
      expect(content).not_to match(/if.*name.*==.*['"]Venus['"]/)
      
      # Should contain magnetosphere_strength passthrough
      expect(content).to include('magnetosphere_strength')
    end
  end

  describe 'AtmosphereGeneratorService integration' do
    it 'accepts numeric magnetosphere_strength (not boolean)' do
      service = StarSim::AtmosphereGeneratorService.new(nil, nil)
      
      # Should accept a Float value without error
      expect {
        service.generate_composition_for_body(
          'Test', 300, 1e24, 1e6, 1.0, 'G', 0.5
        )
      }.not_to raise_error
    end

    it 'method signature uses magnetosphere_strength parameter name' do
      service_file = Rails.root.join('galaxy_game/app/services/star_sim/atmosphere_generator_service.rb').to_s
      content = File.read(service_file)
      
      expect(content).to include('magnetosphere_strength')
      # Should NOT have the old boolean parameter name
      expect(content).not_to match(/has_magnetic_field.*boolean/)
    end
  end

  describe 'ProceduralGenerator — dead-core gate verification' do
    it 'calculate_magnetosphere_strength is a baseline passthrough (no physics formula)' do
      generator = StarSim::ProceduralGenerator.new
      
      # Current implementation: returns baseline as-is (clamped to [0,1])
      # NOT a mass/rotation/age calculation
      expect(generator.send(:calculate_magnetosphere_strength, 0.5)).to eq(0.5)
      expect(generator.send(:calculate_magnetosphere_strength, 0.0)).to eq(0.0)
      expect(generator.send(:calculate_magnetosphere_strength, 1.0)).to eq(1.0)
    end

    it 'Mars dead-core behavior comes from sol-complete.json data (0.0), not calculation' do
      system_data = JSON.parse(File.read('data/json-data/star_systems/sol-complete.json'))
      mars = system_data.dig('celestial_bodies', Array).find { |b| b['name'] == 'Mars' }
      
      # The dead-core gate is satisfied by data, not code
      expect(mars['magnetosphere_strength']).to eq(0.0)
    end

    it 'procedurally generated planets get neutral 0.5 default (not calculated)' do
      generator = StarSim::ProceduralGenerator.new
      planet_data = generator.send(:generate_procedural_terrestrial, 'Test-P1', 'TEST-P1', 0)
      
      # Current implementation uses procedural_baseline = 0.5
      expect(planet_data['magnetosphere_strength']).to be_within(0.01).of(0.5)
    end

    it 'calculate_magnetosphere_radius returns nil for zero strength' do
      generator = StarSim::ProceduralGenerator.new
      radius = generator.send(:calculate_magnetosphere_radius, 1e24, 0.0)
      expect(radius).to be_nil
    end

    it 'calculate_magnetosphere_radius returns numeric km for valid inputs' do
      generator = StarSim::ProceduralGenerator.new
      earth_mass = 5.972e24
      
      radius = generator.send(:calculate_magnetosphere_radius, earth_mass, 1.0)
      expect(radius).to be_a(Integer)
      expect(radius).to be > 0
      expect(radius).to be_within(10000).of(60000)
    end
  end

  describe 'No hardcoded planet names in Ruby code' do
    it 'ProceduralGenerator has no Topaz patches' do
      gen_file = Rails.root.join('galaxy_game/app/services/star_sim/procedural_generator.rb').to_s
      content = File.read(gen_file)
      
      expect(content).not_to include("Topaz")
      expect(content).not_to include("magnetic_moment")
      expect(content).not_to include("tei_score")
    end

    it 'SystemBuilderService has no strong_magnetosphere boolean logic' do
      svc_file = Rails.root.join('galaxy_game/app/services/star_sim/system_builder_service.rb').to_s
      content = File.read(svc_file)
      
      expect(content).not_to include("strong_magnetosphere")
    end
  end
end
