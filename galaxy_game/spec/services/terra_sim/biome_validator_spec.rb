require 'rails_helper'

RSpec.describe TerraSim::BiomeValidator do
  let(:earth) do
    create(:terrestrial_planet, :earth).tap do |body|
      # Ensure geosphere exists
      body.geosphere || create(:geosphere, celestial_body: body)
      # Add terrain map with biomes
      body.geosphere.update_columns(
        terrain_map: {
          'elevation' => Array.new(10) { Array.new(10) { rand(0..1000) } },
          'temperature' => Array.new(10) { Array.new(10) { rand(273..313) } },
          'rainfall' => Array.new(10) { Array.new(10) { rand(0..3000) } },
          'biomes' => Array.new(10) { Array.new(10) { 'tropical_forest' } }
        }
      )
      body.reload
    end
  end
  let(:mars) do
    create(:terrestrial_planet, :mars).tap do |body|
      # Ensure geosphere exists
      body.geosphere || create(:geosphere, celestial_body: body)
      # Add terrain map with biomes
      body.geosphere.update_columns(
        terrain_map: {
          'elevation' => Array.new(10) { Array.new(10) { rand(0..1000) } },
          'temperature' => Array.new(10) { Array.new(10) { rand(200..250) } },
          'rainfall' => Array.new(10) { Array.new(10) { rand(0..100) } },
          'biomes' => Array.new(10) { Array.new(10) { 'desert' } }
        }
      )
      body.reload
    end
  end
  let(:validator) { described_class.new(earth) }

  describe '#validate_single_biome' do
    it 'accepts tropical forest at equator with high rainfall' do
      environment = {
        elevation: 100,
        latitude: 0,
        temperature: 298, # 25°C
        rainfall: 2000,
        slope: 5
      }
      result = validator.validate_single_biome(0, 0, 'tropical_forest', environment)
      expect(result[:valid]).to be true
    end

    it 'rejects tropical forest at pole' do
      environment = {
        elevation: 100,
        latitude: 80,
        temperature: 268, # -5°C
        rainfall: 2000,
        slope: 5
      }
      result = validator.validate_single_biome(0, 0, 'tropical_forest', environment)
      expect(result[:valid]).to be false
      expect(result[:reason]).to include('Too cold')
    end

    it 'rejects desert with high rainfall' do
      environment = {
        elevation: 200,
        latitude: 30,
        temperature: 308, # 35°C
        rainfall: 1000, # Too wet for desert
        slope: 5
      }
      result = validator.validate_single_biome(0, 0, 'desert', environment)
      expect(result[:valid]).to be false
      expect(result[:reason]).to include('Too wet')
    end

    it 'accepts desert in hot, dry conditions' do
      environment = {
        elevation: 200,
        latitude: 30,
        temperature: 318, # 45°C
        rainfall: 100, # Dry
        slope: 5
      }
      result = validator.validate_single_biome(0, 0, 'desert', environment)
      expect(result[:valid]).to be true
    end

    it 'rejects ocean on high elevation' do
      environment = {
        elevation: 1000, # Too high for ocean
        latitude: 0,
        temperature: 288,
        rainfall: 2000,
        slope: 5
      }
      result = validator.validate_single_biome(0, 0, 'ocean', environment)
      expect(result[:valid]).to be false
      expect(result[:reason]).to include('Elevation too high')
    end

    it 'accepts ice at poles with low temperature' do
      environment = {
        elevation: 100,
        latitude: 75,
        temperature: 258, # -15°C
        rainfall: 200,
        slope: 5
      }
      result = validator.validate_single_biome(0, 0, 'ice', environment)
      expect(result[:valid]).to be true
    end
  end

  describe '#suggest_correct_biome' do
    it 'suggests savanna for hot, dry environment' do
      environment = {
        elevation: 200,
        latitude: 30,
        temperature: 318, # 45°C
        rainfall: 50, # Very dry
        slope: 5
      }
      biome = validator.suggest_correct_biome(environment)
      expect(biome).to eq('savanna') # Savanna is better match than desert for this rainfall
    end

    it 'suggests tundra for polar environment' do
      environment = {
        elevation: 100,
        latitude: 80,
        temperature: 253, # -20°C
        rainfall: 100,
        slope: 5
      }
      biome = validator.suggest_correct_biome(environment)
      expect(biome).to eq('tundra') # Tundra fits temperature range better than ice
    end

    it 'suggests tropical forest for equatorial wet environment' do
      environment = {
        elevation: 50,
        latitude: 5,
        temperature: 303, # 30°C
        rainfall: 2500, # Very wet
        slope: 3
      }
      biome = validator.suggest_correct_biome(environment)
      expect(biome).to eq('tropical_forest')
    end
  end

  describe '#validate_biome_grid' do
    let(:earth_with_biomes) do
      create(:terrestrial_planet, :earth).tap do |body|
        # Ensure geosphere exists
        body.geosphere || create(:geosphere, celestial_body: body)
        body.geosphere.update!(terrain_map: {
          'elevation' => [[100, 200], [300, 400]],
          'biomes' => [['tropical_forest', 'desert'], ['temperate_forest', 'ice']],
          'width' => 2,
          'height' => 2
        })
        body.reload
      end
    end

    let(:validator_with_data) { described_class.new(earth_with_biomes) }

    it 'validates a grid of biomes' do
      result = validator_with_data.validate_biome_grid([['tropical_forest', 'desert'], ['temperate_forest', 'ice']])

      expect(result).to include(:score, :total_tiles, :valid_tiles, :errors, :summary)
      expect(result[:total_tiles]).to eq(4)
      expect(result[:score]).to be_a(Float)
    end

    it 'returns zero score for empty grid' do
      result = validator.validate_biome_grid(nil)
      expect(result[:score]).to eq(0)
      expect(result[:errors]).to include('No biome grid provided')
    end
  end

  describe '#calculate_environment' do
    it 'calculates environment for a location' do
      # Mock the terrain map
      allow(earth.geosphere).to receive(:terrain_map).and_return({
        'elevation' => [[100, 200], [300, 400]],
        'width' => 2,
        'height' => 2
      })

      environment = validator.calculate_environment(0, 0)

      expect(environment).to include(:x, :y, :elevation, :latitude, :temperature, :rainfall, :slope)
      expect(environment[:x]).to eq(0)
      expect(environment[:y]).to eq(0)
      expect(environment[:elevation]).to eq(100)
    end
  end
end