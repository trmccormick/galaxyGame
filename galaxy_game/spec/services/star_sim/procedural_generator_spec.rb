require 'rails_helper'

RSpec.describe StarSim::ProceduralGenerator, type: :service do
  let(:template_path) { GalaxyGame::Paths::TEMPLATE_PATH.join('alien_world_templates_v1.1.json') }
  let(:fallback_template_path) { GalaxyGame::Paths::TEMPLATE_PATH.join('alien_world_templates_v1.json') }
  let(:output_path) { GalaxyGame::Paths::STAR_SYSTEMS_PATH }

  let(:mock_atmosphere_generator) { instance_double('AtmosphereGeneratorService') }
  let(:mock_hydrosphere_generator) { instance_double('HydrosphereGeneratorService') }
  let(:mock_material_lookup) { instance_double('Lookup::MaterialLookupService') }
  let(:mock_planet_name_service) { instance_double('Naming::PlanetNameService') }

  let(:generator) do
    described_class.new(
      nil,
      mock_atmosphere_generator,
      mock_hydrosphere_generator,
      mock_material_lookup,
      mock_planet_name_service
    )
  end

  before do
    # Mock the atmosphere and hydrosphere generators
    allow(mock_atmosphere_generator).to receive(:generate_composition_for_body).and_return({
      'composition' => { 'N2' => { 'percentage' => 78.0 }, 'O2' => { 'percentage' => 21.0 } },
      'pressure' => 1.0,
      'total_atmospheric_mass' => 5.0e18
    })

    allow(mock_hydrosphere_generator).to receive(:generate).and_return({
      'total_water_mass' => 1.4e21,
      'surface_coverage' => 0.71
    })

    # Mock file operations
    allow(FileUtils).to receive(:mkdir_p)
    allow(File).to receive(:open)

    # Mock name generator - it expects 2 arguments for star names
    allow_any_instance_of(NameGeneratorService).to receive(:generate_system_name).and_return("Test System")
    allow_any_instance_of(NameGeneratorService).to receive(:generate_star_name).and_return("Test Star")

    # Mock planet name service
    allow(mock_planet_name_service).to receive(:generate_planet_name).and_return("Test Planet")

    # Mock File.exist? for template loading
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(kind_of(Pathname)).and_call_original
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with(kind_of(Pathname)).and_call_original
  end

  describe '#initialize' do
    it 'loads terraformable templates if they exist' do
      allow_any_instance_of(StarSim::ProceduralGenerator).to receive(:load_terraformable_templates).and_return([{'name' => 'Test Template'}])
      
      generator = described_class.new(
        nil,
        mock_atmosphere_generator,
        mock_hydrosphere_generator,
        mock_material_lookup
      )
      
      expect(generator.instance_variable_get(:@terraformable_templates).length).to eq(1)
    end

    it 'handles missing template file gracefully' do
      allow_any_instance_of(StarSim::ProceduralGenerator).to receive(:load_terraformable_templates).and_return([])
      
      generator = described_class.new(
        nil,
        mock_atmosphere_generator,
        mock_hydrosphere_generator,
        mock_material_lookup
      )
      
      expect(generator.instance_variable_get(:@terraformable_templates)).to eq([])
    end

    it 'handles malformed template JSON gracefully' do
      allow_any_instance_of(StarSim::ProceduralGenerator).to receive(:load_terraformable_templates).and_return([])
      
      generator = described_class.new(
        nil,
        mock_atmosphere_generator,
        mock_hydrosphere_generator,
        mock_material_lookup
      )
      
      expect(generator.instance_variable_get(:@terraformable_templates)).to eq([])
    end
  end

  describe '#generate_system_seed' do
    it 'generates a complete system structure' do
      result = generator.generate_system_seed(num_stars: 1, num_planets: 3)

      expect(result).to have_key('galaxy')
      expect(result).to have_key('solar_system')
      expect(result).to have_key('stars')
      expect(result).to have_key('celestial_bodies')

      expect(result['stars'].length).to eq(1)
      expect(result['celestial_bodies']['terrestrial_planets'].length).to eq(3)
    end

    it 'uses the correct system identifier format' do
      result = generator.generate_system_seed(num_stars: 1, num_planets: 1)

      expect(result['solar_system']['identifier']).to eq('TEST-SYSTEM')
    end
  end

  describe '#generate_terrestrial_planets' do
    context 'with available templates' do
      let(:template_data) do
        {
          'terrestrial_planets' => [
            {
              'name' => 'Template Planet',
              'identifier' => 'TPL-001',
              'mass' => '5.0e24',
              'radius' => 6.0e6,
              'albedo' => 0.3,
              'geosphere_attributes' => {
                'geological_activity' => 50,
                'tectonic_activity' => true
              }
            }
          ]
        }
      end

      before do
        allow(File).to receive(:exist?).with(template_path).and_return(true)
        allow(File).to receive(:read).with(template_path).and_return(template_data.to_json)
        allow(File).to receive(:exist?).with(fallback_template_path).and_return(false)

        # Reset the generator to load templates
        generator.instance_variable_set(:@terraformable_templates, template_data['terrestrial_planets'])
      end

      it 'uses templates for approximately 40% of planets' do
        # Mock rand to return values that will result in ~40% template usage
        # rand < 0.4 means use template, so we want ~4 out of 10 to be < 0.4
        # Each template planet calls rand 3 times (for variations), so we need enough values
        values = [0.1, 0.5, 0.2, 0.6, 0.3, 0.7, 0.15, 0.8, 0.35, 0.9, 0.1, 0.5, 0.2, 0.6, 0.3] # 5 values < 0.4 in 15
        call_count = 0
        allow(Kernel).to receive(:rand) do
          value = values[call_count % values.length] if call_count < values.length
          call_count += 1
          value || 0.5 # Default to > 0.4 if we run out
        end

        planets = generator.send(:generate_terrestrial_planets, 10, 'TEST-SYSTEM')

        # Should use templates for planets that chose to (based on rand)
        template_based = planets.select { |p| p['from_template'] }
        expect(template_based.length).to be_between(2, 6) # Approximately 40% of 10
      end

      it 'requests terraformed names for template-based planets' do
        allow_any_instance_of(Object).to receive(:rand).and_return(0.3) # Below 0.4 threshold = template
        allow(generator).to receive(:generate_moons_for_planet) # Prevent moon generation
        allow(generator).to receive(:generate_optimized_orbital_parameters).and_return({
          semi_major_axis_au: 1.0,
          eccentricity: 0.01,
          inclination_deg: 0.5,
          orbital_period_days: 365.25
        })

        mock_star = { "r_ecosphere" => 1.0, "name" => "Test Star", "type" => "G" }
        planets = generator.send(:generate_planets_for_star, mock_star, 'TEST-SYSTEM', 1)

        expect(mock_planet_name_service).to have_received(:generate_planet_name).with(
          terraformable: true,
          system_identifier: 'TEST-SYSTEM',
          index: 1,
          world_composition: 'terrestrial'
        )
      end

      it 'requests neutral names for procedural planets' do
        allow_any_instance_of(Object).to receive(:rand) do |*args|
          if args.empty?
            0.5
          else
            2
          end
        end

        mock_star = { "r_ecosphere" => 1.0, "name" => "Test Star", "type" => "G" }
        planets = generator.send(:generate_planets_for_star, mock_star, 'TEST-SYSTEM', 1)

        expect(mock_planet_name_service).to have_received(:generate_planet_name).with(
          terraformable: false,
          system_identifier: 'TEST-SYSTEM',
          index: 1,
          world_composition: 'rocky'
        )
      end

      it 'applies orbital optimization for template-based planets' do
        allow_any_instance_of(Object).to receive(:rand).and_return(0.3)
        allow(generator).to receive(:generate_moons_for_planet) # Prevent moon generation that causes test failure
        allow(generator).to receive(:generate_optimized_orbital_parameters).and_return({
          semi_major_axis_au: 1.0,
          eccentricity: 0.01,
          inclination_deg: 0.5,
          orbital_period_days: 365.25
        })

        planets = generator.send(:generate_terrestrial_planets, 1, 'TEST-SYSTEM')

        expect(generator).to have_received(:generate_optimized_orbital_parameters)
      end

      it 'generates procedural planets when not using templates' do
        allow_any_instance_of(Object).to receive(:rand) do |*args|
          if args.empty?
            0.5
          else
            2
          end
        end

        planets = generator.send(:generate_terrestrial_planets, 1, 'TEST-SYSTEM')

        planet = planets.first
        expect(planet['from_template']).to be false
        expect(planet['type']).to eq('terrestrial')
      end
    end

    context 'without templates' do
      before do
        generator.instance_variable_set(:@terraformable_templates, [])
      end

      it 'generates all planets procedurally' do
        planets = generator.send(:generate_terrestrial_planets, 3, 'TEST-SYSTEM')

        expect(planets.length).to eq(3)
        planets.each do |planet|
          expect(planet['type']).to eq('terrestrial')
          expect(planet).to have_key('mass')
          expect(planet).to have_key('radius')
        end
      end
    end
  end

  describe '#generate_from_template' do
    let(:template) do
      {
        'name' => 'Template Planet',
        'mass' => '5.0e24',
        'radius' => 6.0e6,
        'albedo' => 0.3,
        'geosphere_attributes' => { 'test' => 'data' }
      }
    end

    it 'creates planet data based on template' do
      result = generator.send(:generate_from_template, template, 'New Planet', 'NEW-001', 0)

      expect(result['name']).to eq('New Planet')
      expect(result['identifier']).to eq('NEW-001')
      expect(result['from_template']).to be true
      expect(result).to have_key('geosphere_attributes')
    end

    it 'applies small variations to prevent identical planets' do
      allow(generator).to receive(:rand).and_return(-0.05) # This will trigger -5% variation
      
      result = generator.send(:generate_from_template, template, 'New Planet', 'NEW-001', 0)
      
      # Mass should be reduced by 5%
      expect(result['mass']).to be < 5.0e24
    end

    it 'recalculates dependent properties after variation' do
      result = generator.send(:generate_from_template, template, 'New Planet', 'NEW-001', 0)

      # Should have recalculated density and gravity
      expect(result).to have_key('density')
      expect(result).to have_key('gravity')
    end
  end

  describe '#generate_optimized_orbital_parameters' do
    let(:mock_star) { double('star', luminosity: 1.0) }

    it 'places planets near habitable zone for terraformable planets' do
      allow(Kernel).to receive(:rand).and_return(0.5, 1.0, 0.05, 0.5) # Multiple rand calls
      
      result = generator.send(:generate_optimized_orbital_parameters, 0, mock_star)

      # Should be reasonably close to habitable zone for a sun-like star
      expect(result[:semi_major_axis_au]).to be_between(0.5, 2.0)
    end

    it 'calculates orbital period correctly' do
      allow(Kernel).to receive(:rand).and_return(0.5, 1.0) # Use HZ placement, distance = 1.5 AU
      
      result = generator.send(:generate_optimized_orbital_parameters, 0, mock_star)

      # For distance around 1 AU, period should be around 365 days
      expect(result[:orbital_period_days]).to be_between(250, 750)
    end
  end

  describe '#calculate_habitable_zone_center' do
    it 'returns 1 AU for sun-like stars' do
      mock_star = double('star', luminosity: 1.0)
      result = generator.send(:calculate_habitable_zone_center, mock_star)

      expect(result).to eq(1.0)
    end

    it 'scales with stellar luminosity' do
      mock_star = double('star', luminosity: 4.0) # 2x more luminous
      result = generator.send(:calculate_habitable_zone_center, mock_star)

      expect(result).to eq(2.0) # sqrt(4) = 2
    end

    it 'defaults to 1 AU when no star provided' do
      result = generator.send(:calculate_habitable_zone_center, nil)

      expect(result).to eq(1.0)
    end
  end

  describe '#generate_biosphere_data' do
    it 'provides enhanced biosphere for template-based planets' do
      planet_data = {
        "type" => 'terrestrial',
        "surface_temperature" => 288,
        "atmosphere" => { "pressure" => 1.0 },
        "gravity" => 1.0,
        "from_template" => true
      }

      result = generator.send(:generate_biosphere_data, planet_data)

      expect(result[:biodiversity_index]).to be > 0
      expect(result[:habitable_ratio]).to be > 0
    end

    it 'provides basic biosphere for planets with good conditions' do
      planet_data = {
        type: 'terrestrial',
        surface_temperature: 280,
        atmosphere: { pressure: 1.2 },
        gravity: 0.9
      }

      result = generator.send(:generate_biosphere_data, planet_data)

      expect(result[:biodiversity_index]).to be >= 0
    end

    it 'returns empty biosphere for unsuitable planets' do
      planet_data = {
        type: 'terrestrial',
        surface_temperature: 400, # Too hot
        atmosphere: { pressure: 0.1 } # Too thin
      }

      result = generator.send(:generate_biosphere_data, planet_data)

      expect(result[:biodiversity_index]).to eq(0.0)
    end
  end

  describe '#generate_stars' do
    it 'generates stars with realistic spectral types' do
      stars = generator.send(:generate_stars, 1, 'TEST-SYSTEM')

      star = stars.first
      expect(star).to have_key('name')
      expect(star).to have_key('type')
      expect(star).to have_key('mass')
      expect(star['type']).to match(/^[OBAFGKM]\d*V$/)
    end

    it 'respects spectral type probability distribution' do
      # Mock rand to always select M-type stars (most common)
      allow(generator).to receive(:rand).and_return(0.5) # Within M-type range

      stars = generator.send(:generate_stars, 10, 'TEST-SYSTEM')

      m_type_stars = stars.select { |s| s['type'].start_with?('M') }
      expect(m_type_stars.length).to be > 5 # Should be majority
    end
  end

  describe '#generate_system_seed_file' do
    it 'creates a JSON file with system data' do
      mock_file = double('file')
      allow(mock_file).to receive(:write)
      allow(File).to receive(:open).and_yield(mock_file)
      
      mock_seed_data = {
        solar_system: { identifier: 'TEST-SYSTEM' },
        stars: [],
        celestial_bodies: { terrestrial_planets: [] }
      }
      allow(generator).to receive(:generate_system_seed).and_return(mock_seed_data)

      generator.generate_system_seed_file(num_planets: 2, num_stars: 1)

      expect(mock_file).to have_received(:write)
    end

    it 'includes timestamp in filename' do
      allow(File).to receive(:open)
      
      mock_seed_data = {
        solar_system: { identifier: 'TEST-SYSTEM' },
        stars: [],
        celestial_bodies: { terrestrial_planets: [] }
      }
      allow(generator).to receive(:generate_system_seed).and_return(mock_seed_data)

      expect(generator).to receive(:generate_system_seed).and_return(mock_seed_data)

      generator.generate_system_seed_file(num_planets: 1, num_stars: 1)
    end
  end

  describe '#load_terraformable_templates' do
    it 'loads templates successfully' do
      templates = generator.send(:load_terraformable_templates)
      expect(templates).to be_an(Array)
    end

    it 'loads at least 4 templates' do
      templates = generator.send(:load_terraformable_templates)
      expect(templates.size).to be >= 4
    end

    it 'only includes terrestrial planets' do
      templates = generator.send(:load_terraformable_templates)
      templates.each do |template|
        expect(template['type']).to eq('terrestrial')
      end
    end

    it 'ensures templates have required fields' do
      templates = generator.send(:load_terraformable_templates)
      
      templates.each do |template|
        expect(template).to have_key('type')
        expect(template).to have_key('mass')
        expect(template).to have_key('radius')
        expect(template).to have_key('density')
        expect(template).to have_key('gravity')
        expect(template).to have_key('albedo')
        expect(template).to have_key('known_pressure')
        expect(template).to have_key('surface_temperature')
        expect(template).to have_key('geological_activity')
        expect(template).to have_key('geosphere_attributes')
      end
    end
  end

  describe 'integration test' do
    it 'generates a complete, valid system' do
      result = generator.generate_system_seed(num_stars: 2, num_planets: 5)

      # Check overall structure
      expect(result['stars'].length).to eq(2)
      expect(result['celestial_bodies']['terrestrial_planets'].length).to eq(5)

      # Check each planet has required attributes and orbital correctness
      result['celestial_bodies']['terrestrial_planets'].each do |planet|
        # Schema validation for terrestrial planets
        terrestrial_keys = %w[
          name identifier type mass radius density gravity albedo
          surface_temperature size known_pressure geological_activity
          geosphere_attributes orbits from_template
        ]
        terrestrial_keys.each do |key|
          expect(planet).to have_key(key), "Missing key '#{key}' in terrestrial planet"
        end

        # Symbol keys for generated data
        expect(planet).to have_key(:atmosphere)
        expect(planet).to have_key(:hydrosphere)
        expect(planet).to have_key(:biosphere)

        # Orbital correctness
        expect(planet["orbits"]).to be_an(Array)
        expect(planet["orbits"].first).to include(
          "around",
          "semi_major_axis_au",
          "eccentricity",
          "inclination_deg",
          "orbital_period_days",
          "distance"
        )
      end
    end

    it 'validates schema for all planet types' do
      result = generator.generate_system_seed(num_stars: 1, num_planets: 10)

      bodies = result['celestial_bodies']

      # Terrestrial planets
      bodies['terrestrial_planets'].each do |planet|
        expect(planet['type']).to eq('terrestrial')
        expect(planet).to have_key('from_template')
        expect(planet).to have_key('geosphere_attributes')
      end

      # Gas giants
      bodies['gas_giants'].each do |planet|
        expect(planet['type']).to eq('gas_giant')
        gas_giant_keys = %w[
          name identifier type mass radius density gravity albedo
          surface_temperature orbits
        ]
        gas_giant_keys.each do |key|
          expect(planet).to have_key(key), "Missing key '#{key}' in gas giant"
        end
        expect(planet).to have_key(:atmosphere)
        expect(planet).to have_key(:hydrosphere)
      end

      # Ice giants
      bodies['ice_giants'].each do |planet|
        expect(planet['type']).to eq('ice_giant')
        ice_giant_keys = %w[
          name identifier type mass radius density gravity albedo
          surface_temperature orbits
        ]
        ice_giant_keys.each do |key|
          expect(planet).to have_key(key), "Missing key '#{key}' in ice giant"
        end
        expect(planet).to have_key(:atmosphere)
        expect(planet).to have_key(:hydrosphere)
      end

      # Dwarf planets
      bodies['dwarf_planets'].each do |planet|
        expect(planet['type']).to eq('dwarf_planet')
        dwarf_keys = %w[
          name identifier type mass radius density gravity albedo
          surface_temperature orbits
        ]
        dwarf_keys.each do |key|
          expect(planet).to have_key(key), "Missing key '#{key}' in dwarf planet"
        end
        expect(planet).to have_key(:atmosphere)
        expect(planet).to have_key(:hydrosphere)
      end
    end

    it 'uses terraformable templates at an expected rate' do
      planets = 10.times.flat_map do
        generator.generate_system_seed(num_stars: 1, num_planets: 20)
          .dig("celestial_bodies", "terrestrial_planets")
      end

      template_like = planets.count { |p| p['from_template'] }
      ratio = template_like.to_f / planets.size

      expect(ratio).to be_between(0.25, 0.55)
    end

    it 'generates large systems without structural degradation' do
      data = generator.generate_system_seed(num_stars: 2, num_planets: 50)

      bodies = data["celestial_bodies"]
      total =
        bodies["terrestrial_planets"].size +
        bodies["gas_giants"].size +
        bodies["ice_giants"].size +
        bodies["dwarf_planets"].size

      expect(total).to be >= 50

      # Ensure no structural issues in large systems
      all_planets = bodies.values.flatten
      all_planets.each do |planet|
        expect(planet).to have_key('name')
        expect(planet).to have_key('identifier')
        expect(planet['orbits']).to be_an(Array)
        expect(planet['orbits'].first).to have_key('around')
      end
    end
  end
end