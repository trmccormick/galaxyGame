class Environment < ApplicationRecord
    has_many :plants
    has_many :animals
  
    BIOMES = {
      'Desert' => { temperature: (15.0..45.0), moisture: (0.0..10.0), sunlight: (70.0..100.0), soil_quality: 'Poor' },
      'Savannah' => { temperature: (20.0..30.0), moisture: (20.0..60.0), sunlight: (60.0..90.0), soil_quality: 'Moderate' },
      'Rainforest' => { temperature: (20.0..34.0), moisture: (75.0..100.0), sunlight: (70.0..100.0), soil_quality: 'Fertile' },
      'Deciduous Forest' => { temperature: (-10.0..25.0), moisture: (50.0..100.0), sunlight: (50.0..80.0), soil_quality: 'Rich' },
      'Taiga' => { temperature: (-30.0..15.0), moisture: (30.0..85.0), sunlight: (30.0..60.0), soil_quality: 'Poor' },
      'Tundra' => { temperature: (-50.0..10.0), moisture: (10.0..30.0), sunlight: (10.0..40.0), soil_quality: 'Permafrost' },
      'Grassland' => { temperature: (-20.0..30.0), moisture: (25.0..75.0), sunlight: (50.0..80.0), soil_quality: 'Fertile' },
      'Ice Cap' => { temperature: (-90.0..-30.0), moisture: (0.0..10.0), sunlight: (0.0..20.0), soil_quality: 'None' },
      'Ocean' => { temperature: (-2.0..30.0), moisture: (100.0..100.0), sunlight: (0.0..100.0), soil_quality: 'Varied' },
      'Wetlands' => { temperature: (0.0..35.0), moisture: (80.0..100.0), sunlight: (30.0..80.0), soil_quality: 'Rich' },
    }
  
    def self.suitable_plants_for(biome)
      Plant.where("temperature_range && ?", BIOMES[biome][:temperature])
           .where("moisture_range && ?", BIOMES[biome][:moisture])
           .where("sunlight_requirement >= ? AND sunlight_requirement <= ?", BIOMES[biome][:sunlight].min, BIOMES[biome][:sunlight].max)
    end
  
    def self.suitable_animals_for(biome)
      Animal.where("temperature_tolerance_range && ?", BIOMES[biome][:temperature])
            .where("humidity_tolerance_range && ?", BIOMES[biome][:moisture])
    end
  end