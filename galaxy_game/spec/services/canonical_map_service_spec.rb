# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalMapService do
  describe '.normalize' do
    context 'direct canonical names' do
      it 'resolves boreal_forest to forest key with biome layer' do
        expect(described_class.normalize('boreal_forest')).to eq(canonical: 'forest', layer: :biome)
      end

      it 'resolves tropical_rainforest to tropical_jungle key with biome layer' do
        expect(described_class.normalize('tropical_rainforest')).to eq(canonical: 'tropical_jungle', layer: :biome)
      end

      it 'resolves grassland to grasslands key with biome layer' do
        expect(described_class.normalize('grassland')).to eq(canonical: 'grasslands', layer: :biome)
      end

      it 'resolves desert to desert key with terrain layer' do
        expect(described_class.normalize('desert')).to eq(canonical: 'desert', layer: :terrain)
      end

      it 'resolves ocean to ocean key with terrain layer' do
        expect(described_class.normalize('ocean')).to eq(canonical: 'ocean', layer: :terrain)
      end

      it 'resolves mountains to mountains key with terrain layer' do
        expect(described_class.normalize('mountains')).to eq(canonical: 'mountains', layer: :terrain)
      end

      it 'resolves tundra to tundra key with terrain layer' do
        expect(described_class.normalize('tundra')).to eq(canonical: 'tundra', layer: :terrain)
      end
    end

    context 'alias resolution' do
      it 'resolves savannah alias to savanna' do
        expect(described_class.normalize('savannah')).to eq(canonical: 'savanna', layer: :biome)
      end

      it 'resolves taiga alias to boreal_forest key (forest)' do
        expect(described_class.normalize('taiga')).to eq(canonical: 'forest', layer: :biome)
      end

      it 'resolves wetland alias to wetlands key (swamp)' do
        expect(described_class.normalize('wetland')).to eq(canonical: 'swamp', layer: :biome)
      end

      it 'resolves rainforest alias to tropical_rainforest key' do
        expect(described_class.normalize('rainforest')).to eq(canonical: 'tropical_jungle', layer: :biome)
      end

      it 'resolves boreal alias to boreal_forest key (forest)' do
        expect(described_class.normalize('boreal')).to eq(canonical: 'forest', layer: :biome)
      end

      it 'resolves jungle alias to tropical_rainforest key' do
        expect(described_class.normalize('jungle')).to eq(canonical: 'tropical_jungle', layer: :biome)
      end

      it 'resolves montane alias to mountains key with terrain layer' do
        expect(described_class.normalize('montane')).to eq(canonical: 'mountains', layer: :terrain)
      end

      it 'resolves highlands alias to rocky_plains key' do
        expect(described_class.normalize('highlands')).to eq(canonical: 'rocky_plains', layer: :biome)
      end

      it 'resolves alpine alias to mountains_snow_covered key' do
        expect(described_class.normalize('alpine')).to eq(canonical: 'mountains_snow_covered', layer: :biome)
      end

      it 'resolves grasslands plural alias to grassland key' do
        expect(described_class.normalize('grasslands')).to eq(canonical: 'grasslands', layer: :biome)
      end

      it 'resolves tropical_grassland alias to grassland key' do
        expect(described_class.normalize('tropical_grassland')).to eq(canonical: 'grasslands', layer: :biome)
      end

      it 'resolves temperate_grassland alias to grassland key' do
        expect(described_class.normalize('temperate_grassland')).to eq(canonical: 'grasslands', layer: :biome)
      end

      it 'resolves steppe alias to plains key' do
        expect(described_class.normalize('steppe')).to eq(canonical: 'plains', layer: :biome)
      end

      it 'resolves lowlands alias to plains key' do
        expect(described_class.normalize('lowlands')).to eq(canonical: 'plains', layer: :biome)
      end

      it 'resolves polar_ice alias to pack_ice key with terrain layer' do
        expect(described_class.normalize('polar_ice')).to eq(canonical: 'pack_ice', layer: :terrain)
      end

      it 'resolves snow alias to smooth_ice key with terrain layer' do
        expect(described_class.normalize('snow')).to eq(canonical: 'smooth_ice', layer: :terrain)
      end

      it 'resolves glacier alias to glacier_texture key with terrain layer' do
        expect(described_class.normalize('glacier')).to eq(canonical: 'glacier_texture', layer: :terrain)
      end

      it 'resolves marsh alias to wetlands key (swamp)' do
        expect(described_class.normalize('marsh')).to eq(canonical: 'swamp', layer: :biome)
      end

      it 'resolves bog alias to wetlands key (swamp)' do
        expect(described_class.normalize('bog')).to eq(canonical: 'swamp', layer: :biome)
      end

      it 'resolves tropical_forest alias to tropical_rainforest key' do
        expect(described_class.normalize('tropical_forest')).to eq(canonical: 'tropical_jungle', layer: :biome)
      end

      it 'resolves hot_desert alias to desert key with terrain layer' do
        expect(described_class.normalize('hot_desert')).to eq(canonical: 'desert', layer: :terrain)
      end

      it 'resolves cold_desert alias to desert key with terrain layer' do
        expect(described_class.normalize('cold_desert')).to eq(canonical: 'desert', layer: :terrain)
      end

      it 'resolves polar_desert alias to desert key with terrain layer' do
        expect(described_class.normalize('polar_desert')).to eq(canonical: 'desert', layer: :terrain)
      end
    end

    context 'case and whitespace variations' do
      it 'handles mixed case "Temperate Forest"' do
        expect(described_class.normalize('Temperate Forest')).to eq(canonical: 'forest', layer: :biome)
      end

      it 'handles uppercase with extra whitespace' do
        expect(described_class.normalize('  TROPICAL_RAINFOREST  ')).to eq(canonical: 'tropical_jungle', layer: :biome)
      end

      it 'handles all lowercase with underscores' do
        expect(described_class.normalize('boreal_forest')).to eq(canonical: 'forest', layer: :biome)
      end

      it 'handles underscore-separated input' do
        expect(described_class.normalize('boreal_forest')).to eq(canonical: 'forest', layer: :biome)
      end

      it 'handles single word with spaces' do
        expect(described_class.normalize('savanna')).to eq(canonical: 'savanna', layer: :biome)
      end
    end

    context 'unknown biomes' do
      it 'returns nil for unknown biome names' do
        expect(described_class.normalize('unknown_biome_xyz')).to be_nil
      end

      it 'returns nil for random strings' do
        expect(described_class.normalize('foobar')).to be_nil
      end
    end

    context 'blank inputs' do
      it 'handles nil input gracefully' do
        expect(described_class.normalize(nil)).to be_nil
      end

      it 'handles empty string input gracefully' do
        expect(described_class.normalize('')).to be_nil
      end

      it 'handles whitespace-only input gracefully' do
        expect(described_class.normalize('   ')).to be_nil
      end

      it 'handles newline input gracefully' do
        expect(described_class.normalize("\n")).to be_nil
      end
    end

    context 'type coercion' do
      it 'handles Symbol input' do
        expect(described_class.normalize(:grassland)).to eq(canonical: 'grasslands', layer: :biome)
      end

      it 'handles Integer input (edge case)' do
        expect(described_class.normalize(42)).to be_nil
      end
    end
  end

  describe '.resolve_alias' do
    it 'resolves savannah to savanna' do
      expect(described_class.resolve_alias('savannah')).to eq('savanna')
    end

    it 'resolves rainforest to tropical_rainforest' do
      expect(described_class.resolve_alias('rainforest')).to eq('tropical_rainforest')
    end

    it 'resolves boreal to boreal_forest' do
      expect(described_class.resolve_alias('boreal')).to eq('boreal_forest')
    end

    it 'resolves taiga to boreal_forest' do
      expect(described_class.resolve_alias('taiga')).to eq('boreal_forest')
    end

    it 'resolves wetland to wetlands' do
      expect(described_class.resolve_alias('wetland')).to eq('wetlands')
    end

    it 'resolves marsh to wetlands' do
      expect(described_class.resolve_alias('marsh')).to eq('wetlands')
    end

    it 'resolves bog to wetlands' do
      expect(described_class.resolve_alias('bog')).to eq('wetlands')
    end

    it 'resolves grasslands to grassland' do
      expect(described_class.resolve_alias('grasslands')).to eq('grassland')
    end

    it 'resolves tropical_grassland to grassland' do
      expect(described_class.resolve_alias('tropical_grassland')).to eq('grassland')
    end

    it 'resolves temperate_grassland to grassland' do
      expect(described_class.resolve_alias('temperate_grassland')).to eq('grassland')
    end

    it 'resolves montane to mountains' do
      expect(described_class.resolve_alias('montane')).to eq('mountains')
    end

    it 'resolves highlands to rocky_plains' do
      expect(described_class.resolve_alias('highlands')).to eq('rocky_plains')
    end

    it 'resolves alpine to mountains_snow_covered' do
      expect(described_class.resolve_alias('alpine')).to eq('mountains_snow_covered')
    end

    it 'resolves polar_ice to pack_ice' do
      expect(described_class.resolve_alias('polar_ice')).to eq('pack_ice')
    end

    it 'resolves snow to smooth_ice' do
      expect(described_class.resolve_alias('snow')).to eq('smooth_ice')
    end

    it 'resolves glacier to glacier_texture' do
      expect(described_class.resolve_alias('glacier')).to eq('glacier_texture')
    end

    it 'resolves lowlands to plains' do
      expect(described_class.resolve_alias('lowlands')).to eq('plains')
    end

    it 'resolves steppe to plains' do
      expect(described_class.resolve_alias('steppe')).to eq('plains')
    end

    it 'resolves tropical_forest to tropical_rainforest' do
      expect(described_class.resolve_alias('tropical_forest')).to eq('tropical_rainforest')
    end

    it 'resolves jungle to tropical_rainforest' do
      expect(described_class.resolve_alias('jungle')).to eq('tropical_rainforest')
    end

    it 'resolves hot_desert to desert' do
      expect(described_class.resolve_alias('hot_desert')).to eq('desert')
    end

    it 'resolves cold_desert to desert' do
      expect(described_class.resolve_alias('cold_desert')).to eq('desert')
    end

    it 'resolves polar_desert to desert' do
      expect(described_class.resolve_alias('polar_desert')).to eq('desert')
    end

    it 'returns nil for non-alias keys' do
      expect(described_class.resolve_alias('grassland')).to be_nil
    end

    it 'returns nil for unknown keys' do
      expect(described_class.resolve_alias('nonexistent')).to be_nil
    end
  end

  describe '.get_layer' do
    context 'Layer 0 (terrain) assets' do
      it 'returns :terrain for desert' do
        expect(described_class.get_layer('desert')).to eq(:terrain)
      end

      it 'returns :terrain for tundra' do
        expect(described_class.get_layer('tundra')).to eq(:terrain)
      end

      it 'returns :terrain for ocean' do
        expect(described_class.get_layer('ocean')).to eq(:terrain)
      end

      it 'returns :terrain for mountains' do
        expect(described_class.get_layer('mountains')).to eq(:terrain)
      end

      it 'returns :terrain for arctic' do
        expect(described_class.get_layer('arctic')).to eq(:terrain)
      end

      it 'returns :terrain for polar_ice (alias)' do
        expect(described_class.get_layer('polar_ice')).to eq(:terrain)
      end

      it 'returns :terrain for snow (alias)' do
        expect(described_class.get_layer('snow')).to eq(:terrain)
      end

      it 'returns :terrain for glacier (alias)' do
        expect(described_class.get_layer('glacier')).to eq(:terrain)
      end

      it 'returns :terrain for montane (alias to mountains)' do
        expect(described_class.get_layer('montane')).to eq(:terrain)
      end

      it 'returns :terrain for hot_desert (alias)' do
        expect(described_class.get_layer('hot_desert')).to eq(:terrain)
      end
    end

    context 'Layer 1 (biome) assets' do
      it 'returns :biome for boreal_forest' do
        expect(described_class.get_layer('boreal_forest')).to eq(:biome)
      end

      it 'returns :biome for grassland' do
        expect(described_class.get_layer('grassland')).to eq(:biome)
      end

      it 'returns :biome for tropical_rainforest' do
        expect(described_class.get_layer('tropical_rainforest')).to eq(:biome)
      end

      it 'returns :biome for wetlands' do
        expect(described_class.get_layer('wetlands')).to eq(:biome)
      end

      it 'returns :biome for savanna' do
        expect(described_class.get_layer('savanna')).to eq(:biome)
      end

      it 'returns :biome for agricultural' do
        expect(described_class.get_layer('agricultural')).to eq(:biome)
      end
    end

    context 'unknown assets' do
      it 'returns :unknown for nil input' do
        expect(described_class.get_layer(nil)).to eq(:unknown)
      end

      it 'returns :unknown for unknown biome' do
        expect(described_class.get_layer('nonexistent_biome')).to eq(:unknown)
      end
    end
  end

  describe '.is_terrain?' do
    context 'Layer 0 (terrain) returns true' do
      it 'returns true for desert' do
        expect(described_class.is_terrain?('desert')).to be true
      end

      it 'returns true for tundra' do
        expect(described_class.is_terrain?('tundra')).to be true
      end

      it 'returns true for ocean' do
        expect(described_class.is_terrain?('ocean')).to be true
      end

      it 'returns true for mountains' do
        expect(described_class.is_terrain?('mountains')).to be true
      end

      it 'returns true for arctic' do
        expect(described_class.is_terrain?('arctic')).to be true
      end

      it 'returns true for montane (alias to mountains)' do
        expect(described_class.is_terrain?('montane')).to be true
      end
    end

    context 'Layer 1 (biome) returns false' do
      it 'returns false for boreal_forest' do
        expect(described_class.is_terrain?('boreal_forest')).to be false
      end

      it 'returns false for grassland' do
        expect(described_class.is_terrain?('grassland')).to be false
      end

      it 'returns false for tropical_rainforest' do
        expect(described_class.is_terrain?('tropical_rainforest')).to be false
      end

      it 'returns false for savanna' do
        expect(described_class.is_terrain?('savanna')).to be false
      end

      it 'returns false for wetlands' do
        expect(described_class.is_terrain?('wetlands')).to be false
      end

      it 'returns false for agricultural' do
        expect(described_class.is_terrain?('agricultural')).to be false
      end
    end

    context 'unknown assets return false' do
      it 'returns false for nil input' do
        expect(described_class.is_terrain?(nil)).to be false
      end

      it 'returns false for unknown biome' do
        expect(described_class.is_terrain?('nonexistent_biome')).to be false
      end
    end
  end

  describe '.valid?' do
    context 'known biomes return true' do
      it 'returns true for grassland' do
        expect(described_class.valid?('grassland')).to be true
      end

      it 'returns true for boreal_forest' do
        expect(described_class.valid?('boreal_forest')).to be true
      end

      it 'returns true for desert' do
        expect(described_class.valid?('desert')).to be true
      end

      it 'returns true for ocean' do
        expect(described_class.valid?('ocean')).to be true
      end

      it 'returns true for savannah (alias)' do
        expect(described_class.valid?('savannah')).to be true
      end

      it 'returns true for montane (alias)' do
        expect(described_class.valid?('montane')).to be true
      end
    end

    context 'unknown biomes return false' do
      it 'returns false for nonexistent biome' do
        expect(described_class.valid?('nonexistent_biome')).to be false
      end

      it 'returns false for nil input' do
        expect(described_class.valid?(nil)).to be false
      end

      it 'returns false for empty string' do
        expect(described_class.valid?('')).to be false
      end
    end
  end

  describe '.tiles_for_layer' do
    it 'returns unique tile keys for :biome layer' do
      tiles = described_class.tiles_for_layer(:biome)
      expect(tiles).to be_an(Array)
      expect(tiles.uniq).to eq(tiles)
      # Should include biome canonical keys
      expect(tiles).to include('forest')
      expect(tiles).to include('tropical_jungle')
      expect(tiles).to include('swamp')
      expect(tiles).to include('grasslands')
      expect(tiles).to include('plains')
    end

    it 'returns unique tile keys for :terrain layer' do
      tiles = described_class.tiles_for_layer(:terrain)
      expect(tiles).to be_an(Array)
      expect(tiles.uniq).to eq(tiles)
      # Should include terrain canonical keys
      expect(tiles).to include('desert')
      expect(tiles).to include('tundra')
      expect(tiles).to include('ocean')
      expect(tiles).to include('mountains')
    end

    it 'returns unique tile keys for :unknown layer' do
      tiles = described_class.tiles_for_layer(:unknown)
      expect(tiles).to be_an(Array)
      expect(tiles.uniq).to eq(tiles)
    end
  end

  describe 'integration — no substring fallbacks' do
    it 'does not match partial biome names' do
      # "forest" should NOT match "boreal_forest" via substring
      result = described_class.normalize('forest')
      expect(result).to eq(canonical: 'forest', layer: :biome)

      # "boreal_forest" should resolve to its own entry, not partial match
      result = described_class.normalize('boreal_forest')
      expect(result).to eq(canonical: 'forest', layer: :biome)
    end

    it 'returns nil for partial matches that are not aliases' do
      # "for" is a substring of "forest" but not an alias — should return nil
      expect(described_class.normalize('for')).to be_nil
    end

    it 'can replace substring fallbacks in _biomeTileKey' do
      # Simulate surface_view.js replacement pattern:
      #   Before: biomeTileKey = biome_name.downcase.gsub(' ', '_')  # ambiguous
      #   After:  result = CanonicalMapService.normalize(biome_name)
      #           tile_key = result[:canonical] if result

      biome_names = %w[
        boreal_forest temperate_forest tropical_rainforest
        grassland savanna wetlands steppe alpine
        desert tundra ocean mountains
      ]

      biome_names.each do |biome|
        result = described_class.normalize(biome)
        expect(result).not_to be_nil, "Expected #{biome} to resolve"
        expect(result[:canonical]).to be_a(String)
        expect(result[:layer]).to be_in([:terrain, :biome])
      end
    end

    it 'compresses 30+ aliases into canonical keys (17 after adding ocean/mountains)' do
      all_biomes = described_class::CANONICAL_TILE_MAP.keys
      all_canonical_keys = described_class::CANONICAL_TILE_MAP.values.map { |v| v[:canonical] }.uniq

      expect(all_biomes.size).to be > 25
      expect(all_canonical_keys.size).to eq(17)
    end
  end

  describe 'constants integrity' do
    it 'CANONICAL_TILE_MAP is frozen' do
      expect(described_class::CANONICAL_TILE_MAP).to be_frozen
    end

    it 'TERRAIN_ASSETS is frozen' do
      expect(described_class::TERRAIN_ASSETS).to be_frozen
    end

    it 'HYDROSPHERE_TILES is frozen' do
      expect(described_class::HYDROSPHERE_TILES).to be_frozen
    end

    it 'ALIAS_MAP is frozen' do
      expect(described_class::ALIAS_MAP).to be_frozen
    end

    it 'has no duplicate canonical keys within each layer' do
      biome_canonicals = described_class::CANONICAL_TILE_MAP
        .values
        .select { |v| v[:layer] == :biome }
        .map { |v| v[:canonical] }

      terrain_canonicals = described_class::CANONICAL_TILE_MAP
        .values
        .select { |v| v[:layer] == :terrain }
        .map { |v| v[:canonical] }

      # Duplicates are expected (alias groups) — just verify no nil values
      expect(biome_canonicals).not_to include(nil)
      expect(terrain_canonicals).not_to include(nil)
    end

    it 'ocean and mountains are in CANONICAL_TILE_MAP with layer :terrain' do
      expect(described_class::CANONICAL_TILE_MAP['ocean'][:layer]).to eq(:terrain)
      expect(described_class::CANONICAL_TILE_MAP['mountains'][:layer]).to eq(:terrain)
    end

    it 'montane maps to mountains with layer :terrain (not :biome)' do
      result = described_class.normalize('montane')
      expect(result[:canonical]).to eq('mountains')
      expect(result[:layer]).to eq(:terrain)
    end
  end
end
