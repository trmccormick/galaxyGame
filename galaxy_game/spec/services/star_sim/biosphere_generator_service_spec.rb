require 'rails_helper'

RSpec.describe StarSim::BiosphereGeneratorService, type: :service do
  let(:service) { described_class.new }

  describe '#generate' do
    context 'when biosphere_complexity is :none' do
      let(:planet_data) do
        {
          'surface_temperature' => 288,
          'gravity' => 1.0,
          'atmosphere' => { 'pressure' => 1.0 },
          'hydrosphere' => { 'state_distribution' => { 'liquid' => 0.5 } }
        }
      end

      it 'returns nil for dead worlds' do
        result = service.generate(planet_data, complexity_level: :none)
        expect(result).to be_nil
      end
    end

    context 'when biosphere_complexity is :primitive' do
      let(:earth_like_planet) do
        {
          'surface_temperature' => 288,
          'gravity' => 1.0,
          'atmosphere' => { 'pressure' => 1.0 },
          'hydrosphere' => { 'state_distribution' => { 'liquid' => 0.5 } }
        }
      end

      it 'generates primitive biosphere with low biodiversity' do
        result = service.generate(earth_like_planet, complexity_level: :primitive)

        expect(result).to be_a(Hash)
        expect(result[:habitable_ratio]).to be_between(0.05, 0.15)
        expect(result[:biodiversity_index]).to be_between(0.02, 0.10)
      end

      it 'includes primitive life forms' do
        result = service.generate(earth_like_planet, complexity_level: :primitive)

        expect(result[:primary_producers]).to include('cyanobacteria', 'archaea')
        expect(result[:consumers]).to include('anaerobic bacteria')
        expect(result[:decomposers]).to include('bacteria', 'microorganisms')
      end

      it 'has low vegetation cover and biome count' do
        result = service.generate(earth_like_planet, complexity_level: :primitive)

        expect(result[:vegetation_cover]).to be_between(0.0, 0.05)
        expect(result[:biome_count]).to be_between(1, 2)
      end

      it 'includes era adjustment for early_solar_system' do
        result = service.generate(earth_like_planet, complexity_level: :primitive, seed_era: :early_solar_system)

        expect(result[:atmosphere_notes]).to include('Primordial atmosphere')
        expect(result[:oxygen_producing]).to be false
      end
    end

    context 'when biosphere_complexity is :basic' do
      let(:habitable_planet) do
        {
          'surface_temperature' => 288,
          'gravity' => 1.0,
          'atmosphere' => { 'pressure' => 1.0 },
          'hydrosphere' => { 'state_distribution' => { 'liquid' => 0.7 } }
        }
      end

      it 'generates basic biosphere with moderate biodiversity' do
        result = service.generate(habitable_planet, complexity_level: :basic)

        expect(result[:habitable_ratio]).to be_between(0.30, 0.60)
        expect(result[:biodiversity_index]).to be_between(0.40, 0.70)
      end

      it 'includes diverse life forms' do
        result = service.generate(habitable_planet, complexity_level: :basic)

        expect(result[:primary_producers]).to include('plants', 'phytoplankton')
        expect(result[:consumers]).to include('insects', 'zooplankton')
        expect(result[:decomposers]).to include('bacteria', 'fungi')
      end

      it 'has multiple biomes' do
        result = service.generate(habitable_planet, complexity_level: :basic)

        expect(result[:biome_count]).to be_between(3, 6)
        expect(result[:biome_distribution]).to include('temperate', 'desert', 'ocean')
      end

      it 'has higher vegetation cover than primitive' do
        result = service.generate(habitable_planet, complexity_level: :basic)

        expect(result[:vegetation_cover]).to be_between(0.1, 0.8)
      end
    end

    context 'when biosphere_complexity is :complex' do
      let(:earth_planet) do
        {
          'surface_temperature' => 288,
          'gravity' => 1.0,
          'atmosphere' => { 'pressure' => 1.0 },
          'hydrosphere' => { 'state_distribution' => { 'liquid' => 0.9 } }
        }
      end

      it 'generates complex biosphere with high biodiversity' do
        result = service.generate(earth_planet, complexity_level: :complex)

        expect(result[:habitable_ratio]).to be_between(0.85, 0.95)
        expect(result[:biodiversity_index]).to be_between(0.80, 1.0)
      end

      it 'includes complex life forms' do
        result = service.generate(earth_planet, complexity_level: :complex)

        expect(result[:primary_producers]).to include('plants', 'phytoplankton', 'mosses')
        expect(result[:consumers]).to include('animals', 'fish', 'birds', 'mammals')
        expect(result[:decomposers]).to include('bacteria', 'fungi', 'detritivores')
      end

      it 'has many biomes' do
        result = service.generate(earth_planet, complexity_level: :complex)

        expect(result[:biome_count]).to be_between(8, 15)
      end

      it 'estimates millions of species' do
        result = service.generate(earth_planet, complexity_level: :complex)

        expect(result[:estimated_species_count]).to be > 100_000
      end
    end
  end

  describe '#detect_complexity' do
    context 'with no liquid water' do
      let(:dry_planet) do
        {
          'surface_temperature' => 288,
          'gravity' => 1.0,
          'atmosphere' => { 'pressure' => 1.0 },
          'hydrosphere' => { 'state_distribution' => { 'liquid' => 0.0 } }
        }
      end

      it 'returns :none' do
        result = service.detect_complexity(dry_planet)
        expect(result).to eq(:none)
      end
    end

    context 'with optimal conditions (all 4 factors)' do
      let(:optimal_planet) do
        {
          'surface_temperature' => 288,
          'gravity' => 1.0,
          'atmosphere' => { 'pressure' => 1.0 },
          'hydrosphere' => { 'state_distribution' => { 'liquid' => 0.5 } }
        }
      end

      it 'returns :complex' do
        result = service.detect_complexity(optimal_planet)
        expect(result).to eq(:complex)
      end
    end

    context 'with marginal conditions (2 factors)' do
      let(:marginal_planet) do
        {
          'surface_temperature' => 270,  # Below optimal (260-320)
          'gravity' => 0.6,               # In range
          'atmosphere' => { 'pressure' => 2.5 },  # Above optimal (0.5-2.0)
          'hydrosphere' => { 'state_distribution' => { 'liquid' => 0.1 } }
        }
      end

      it 'returns :primitive' do
        result = service.detect_complexity(marginal_planet)
        expect(result).to eq(:primitive)
      end
    end

    context 'with cold Mars-like conditions' do
      let(:cold_planet) do
        {
          'surface_temperature' => 210,  # Too cold
          'gravity' => 0.4,               # Below range
          'atmosphere' => { 'pressure' => 0.01 },  # Too thin
          'hydrosphere' => { 'state_distribution' => { 'liquid' => 0.01 } }
        }
      end

      it 'returns :none' do
        result = service.detect_complexity(cold_planet)
        expect(result).to eq(:none)
      end
    end
  end

  describe 'era-specific adjustments' do
    let(:habitable_planet) do
      {
        'surface_temperature' => 288,
        'gravity' => 1.0,
        'atmosphere' => { 'pressure' => 1.0 },
        'hydrosphere' => { 'state_distribution' => { 'liquid' => 0.5 } }
      }
    end

    context 'when seed_era is :early_solar_system' do
      it 'reduces biodiversity for primitive life' do
        primitive = service.generate(habitable_planet, complexity_level: :primitive, seed_era: :early_solar_system)
        primitive_standard = service.generate(habitable_planet, complexity_level: :primitive, seed_era: :present_day)

        expect(primitive[:biodiversity_index]).to be < primitive_standard[:biodiversity_index]
      end

      it 'includes atmosphere notes' do
        result = service.generate(habitable_planet, complexity_level: :basic, seed_era: :early_solar_system)

        expect(result[:atmosphere_notes]).to include('Primordial')
      end

      it 'marks oxygen as not produced' do
        result = service.generate(habitable_planet, complexity_level: :primitive, seed_era: :early_solar_system)

        expect(result[:oxygen_producing]).to be false
      end
    end

    context 'when seed_era is :terraformed' do
      it 'enhances habitability' do
        terraformed = service.generate(habitable_planet, complexity_level: :basic, seed_era: :terraformed)
        standard = service.generate(habitable_planet, complexity_level: :basic, seed_era: :present_day)

        expect(terraformed[:habitable_ratio]).to be > standard[:habitable_ratio]
      end

      it 'includes terraformation index' do
        result = service.generate(habitable_planet, complexity_level: :basic, seed_era: :terraformed)

        expect(result).to have_key(:terraformation_index)
        expect(result[:terraformation_index]).to be_between(0.3, 0.8)
      end
    end

    context 'when seed_era is :present_day' do
      it 'generates standard biosphere' do
        result = service.generate(habitable_planet, complexity_level: :basic, seed_era: :present_day)

        expect(result).not_to have_key(:atmosphere_notes)
        expect(result).not_to have_key(:terraformation_index)
      end
    end
  end

  describe 'biome distribution' do
    let(:temperate_planet) do
      {
        'surface_temperature' => 288,
        'gravity' => 1.0,
        'atmosphere' => { 'pressure' => 1.0 },
        'hydrosphere' => { 'state_distribution' => { 'liquid' => 0.5 } }
      }
    end

    let(:tropical_planet) do
      {
        'surface_temperature' => 310,
        'gravity' => 1.0,
        'atmosphere' => { 'pressure' => 1.0 },
        'hydrosphere' => { 'state_distribution' => { 'liquid' => 0.5 } }
      }
    end

    let(:cold_planet) do
      {
        'surface_temperature' => 270,
        'gravity' => 1.0,
        'atmosphere' => { 'pressure' => 1.0 },
        'hydrosphere' => { 'state_distribution' => { 'liquid' => 0.5 } }
      }
    end

    it 'generates temperate biomes for moderate temperature' do
      result = service.generate(temperate_planet, complexity_level: :basic)

      expect(result[:biome_distribution]).to have_key('temperate')
      expect(result[:biome_distribution]['temperate']).to be > 0
    end

    it 'generates tropical biomes for warm temperature' do
      result = service.generate(tropical_planet, complexity_level: :basic)

      expect(result[:biome_distribution]).to have_key('tropical')
      expect(result[:biome_distribution]['tropical']).to be > 0
    end

    it 'generates cold biomes for cool temperature' do
      result = service.generate(cold_planet, complexity_level: :basic)

      expect(result[:biome_distribution]).to have_key('tundra').or have_key('cold')
    end

    it 'normalizes biome distribution to 1.0' do
      result = service.generate(temperate_planet, complexity_level: :basic)

      total = result[:biome_distribution].values.sum
      expect(total).to be_between(0.99, 1.01)  # Account for rounding
    end
  end

  describe 'species count estimation' do
    let(:habitable_planet) do
      {
        'surface_temperature' => 288,
        'gravity' => 1.0,
        'atmosphere' => { 'pressure' => 1.0 },
        'hydrosphere' => { 'state_distribution' => { 'liquid' => 0.5 } }
      }
    end

    it 'primitive life has fewer species' do
      primitive = service.generate(habitable_planet, complexity_level: :primitive)

      expect(primitive[:estimated_species_count]).to be < 100_000
    end

    it 'basic life has moderate species count' do
      basic = service.generate(habitable_planet, complexity_level: :basic)

      expect(basic[:estimated_species_count]).to be_between(10_000, 1_000_000)
    end

    it 'complex life has many species' do
      complex = service.generate(habitable_planet, complexity_level: :complex)

      expect(complex[:estimated_species_count]).to be > 100_000
    end

    it 'dead world has zero species' do
      result = service.generate(habitable_planet, complexity_level: :none)

      expect(result).to be_nil
    end
  end

  describe 'soil and habitat attributes' do
    let(:habitable_planet) do
      {
        'surface_temperature' => 288,
        'gravity' => 1.0,
        'atmosphere' => { 'pressure' => 1.0 },
        'hydrosphere' => { 'state_distribution' => { 'liquid' => 0.5 } }
      }
    end

    it 'primitive life has minimal soil development' do
      result = service.generate(habitable_planet, complexity_level: :primitive)

      expect(result[:soil_health]).to be_between(0.1, 0.3)
      expect(result[:soil_organic_content]).to be_between(0.001, 0.01)
      expect(result[:soil_microbial_activity]).to be_between(0.1, 0.3)
    end

    it 'complex life has developed soil' do
      result = service.generate(habitable_planet, complexity_level: :complex)

      expect(result[:soil_health]).to be_between(0.5, 0.9)
      expect(result[:soil_organic_content]).to be_between(0.05, 0.15)
      expect(result[:soil_microbial_activity]).to be_between(0.6, 0.95)
    end
  end

  describe 'invalid inputs' do
    context 'with missing hydrosphere' do
      let(:planet_data) do
        {
          'surface_temperature' => 288,
          'gravity' => 1.0,
          'atmosphere' => { 'pressure' => 1.0 }
        }
      end

      it 'detects as no biosphere' do
        result = service.detect_complexity(planet_data)
        expect(result).to eq(:none)
      end
    end

    context 'with missing atmosphere' do
      let(:planet_data) do
        {
          'surface_temperature' => 288,
          'gravity' => 1.0,
          'hydrosphere' => { 'state_distribution' => { 'liquid' => 0.5 } }
      }
      end

      it 'still generates biosphere if water exists' do
        result = service.detect_complexity(planet_data)
        # Should still check habitability based on water
        expect(result).not_to be_nil
      end
    end
  end
end
