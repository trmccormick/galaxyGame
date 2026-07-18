# frozen_string_literal: true

# CanonicalMapService normalizes biome names and resolves them to canonical tile mappings.
# This eliminates substring fallback bugs and provides the foundation for all future
# biome/terrain lookups across the game's rendering pipeline.
#
# Layer Ownership:
#   Layer 0 (Terrain): desert, tundra, ocean, mountains — base geological substrate
#   Layer 1 (Biome): forests, wetlands, grasses, mountains_ecological — ecological overlay
#
# Hydrosphere Model:
#   Two distinct questions for hydrosphere:
#     1. Which tiles are water? → Computed dynamically (bathtub fill from elevation + water_coverage)
#     2. What do those water tiles LOOK LIKE? → Tileset lookup (ocean.png, methane_lake.png, etc.)
#
# Rendering Order:
#   Elevation colour (static geological base)
#     │ computed via bathtub fill from elevation + water_coverage %
#   Liquid (dynamic, depth-based rgba overlay)
#     │ only on non-liquid cells (!isWet check)
#   Biome colour/sprite (ecological overlay)
#     │ only on non-liquid cells (!isWet check)
#   Resources (yellow tint) — optional

class CanonicalMapService
  # ========================================================================
  # Constants — frozen, never mutated at runtime
  # ========================================================================

  # 30 biome aliases → 16 canonical tiles
  # Each entry maps an alias to its canonical tile name and layer assignment
  CANONICAL_TILE_MAP = {
    # Ice Group (4 aliases)
    'arctic' => { canonical: 'smooth_ice_sheet_white', layer: :terrain },
    'polar_ice' => { canonical: 'pack_ice', layer: :terrain },
    'snow' => { canonical: 'smooth_ice', layer: :terrain },
    'glacier' => { canonical: 'glacier_texture', layer: :terrain },

    # Forest Group (8 aliases → 2 canonical keys)
    'boreal_forest' => { canonical: 'forest', layer: :biome },
    'temperate_forest' => { canonical: 'forest', layer: :biome },
    'forest' => { canonical: 'forest', layer: :biome },
    'boreal' => { canonical: 'forest', layer: :biome },
    'taiga' => { canonical: 'forest', layer: :biome },
    'tropical_rainforest' => { canonical: 'tropical_jungle', layer: :biome },
    'rainforest' => { canonical: 'tropical_jungle', layer: :biome },
    'tropical_forest' => { canonical: 'tropical_jungle', layer: :biome },

    # Wet Group (4 aliases → 1 canonical key)
    'wetlands' => { canonical: 'swamp', layer: :biome },
    'marsh' => { canonical: 'swamp', layer: :biome },
    'bog' => { canonical: 'swamp', layer: :biome },
    'wetland' => { canonical: 'swamp', layer: :biome },

    # Grass Group (6 aliases → 2 canonical keys)
    'grassland' => { canonical: 'grasslands', layer: :biome },
    'grasslands' => { canonical: 'grasslands', layer: :biome },
    'temperate_grassland' => { canonical: 'grasslands', layer: :biome },
    'tropical_grassland' => { canonical: 'grasslands', layer: :biome },
    'steppe' => { canonical: 'plains', layer: :biome },
    'lowlands' => { canonical: 'plains', layer: :biome },

    # Mountain Group (3 aliases → 3 canonical keys)
    'alpine' => { canonical: 'mountains_snow_covered', layer: :biome },
    'montane' => { canonical: 'mountains', layer: :terrain },
    'highlands' => { canonical: 'rocky_plains', layer: :biome },

    # Other (Direct Mapping — 7 aliases → 7 canonical keys)
    'desert' => { canonical: 'desert', layer: :terrain },
    'ocean' => { canonical: 'ocean', layer: :terrain },
    'mountains' => { canonical: 'mountains', layer: :terrain },
    'savanna' => { canonical: 'savanna', layer: :biome },
    'savannah' => { canonical: 'savanna', layer: :biome },
    'tundra' => { canonical: 'tundra', layer: :terrain },
    'agricultural' => { canonical: 'agricultural_fields', layer: :biome }
  }.freeze

  # Layer 0 terrain assets — also added to CANONICAL_TILE_MAP above for normalize() coverage
  TERRAIN_ASSETS = {
    'desert' => { canonical: 'desert', layer: :terrain },
    'tundra' => { canonical: 'tundra', layer: :terrain },
    'ocean' => { canonical: 'ocean', layer: :terrain },
    'mountains' => { canonical: 'mountains', layer: :terrain }
  }.freeze

  # Hydrosphere tileset mappings (computed coverage + tileset visuals)
  # Each chemical compound has liquid and frozen visual variants
  HYDROSPHERE_TILES = {
    'H2O' => { liquid: 'ocean.png', frozen: 'smooth_ice_sheet_white.png' },
    'CH4' => { liquid: 'methane_lake.png', frozen: 'frozen_methane.png' },
    'C2H6' => { liquid: 'ethane_lake.png', frozen: 'frozen_ethane.png' },
    'N2' => { liquid: 'nitrogen_liquid.png', frozen: 'frozen_nitrogen.png' },
    'NH3' => { liquid: 'ammonia_liquid.png', frozen: 'frozen_ammonia.png' }
  }.freeze

  # Alias resolution map — maps non-canonical names to canonical keys in CANONICAL_TILE_MAP
  ALIAS_MAP = {
    # Savanna variants
    'savannah' => 'savanna',

    # Forest variants
    'rainforest' => 'tropical_rainforest',
    'boreal' => 'boreal_forest',
    'taiga' => 'boreal_forest',
    'jungle' => 'tropical_rainforest',

    # Wetland variants
    'wetland' => 'wetlands',
    'marsh' => 'wetlands',
    'bog' => 'wetlands',

    # Grass variants
    'grasslands' => 'grassland',
    'tropical_grassland' => 'grassland',
    'temperate_grassland' => 'grassland',

    # Mountain variants
    'montane' => 'mountains',
    'highlands' => 'rocky_plains',
    'alpine' => 'mountains_snow_covered',

    # Ice variants
    'polar_ice' => 'pack_ice',
    'snow' => 'smooth_ice',
    'glacier' => 'glacier_texture',

    # Plains variants
    'lowlands' => 'plains',
    'steppe' => 'plains',

    # Forest cross-maps
    'tropical_forest' => 'tropical_rainforest',
    'boreal_forest' => 'boreal_forest',
    'temperate_forest' => 'temperate_forest',
    'tropical_rainforest' => 'tropical_rainforest',

    # Desert variants
    'hot_desert' => 'desert',
    'cold_desert' => 'desert',
    'polar_desert' => 'desert'
  }.freeze

  # ========================================================================
  # Class Methods
  # ========================================================================

  class << self
    # Normalize a biome name to its canonical form.
    #
    # Handles:
    #   - nil/blank inputs → returns nil
    #   - Case variations → downcases
    #   - Whitespace → strips and converts spaces to underscores
    #   - Direct lookup in CANONICAL_TILE_MAP
    #   - Alias resolution for non-canonical names
    #
    # @param biome_name [String, nil] The biome name to normalize
    # @return [Hash{canonical: String, layer: Symbol}, nil] Canonical tile info or nil if unknown
    def normalize(biome_name)
      return nil if biome_name.blank?

      key = biome_name.to_s.downcase.strip.gsub(' ', '_')

      # Direct lookup first (fast path for canonical names)
      return CANONICAL_TILE_MAP[key] if CANONICAL_TILE_MAP.key?(key)

      # Alias resolution for non-canonical names
      resolved = resolve_alias(key)
      return CANONICAL_TILE_MAP[resolved] if resolved && CANONICAL_TILE_MAP.key?(resolved)

      # Unknown biome — caller handles fallback (no substring matching)
      nil
    end

    # Resolve a known alias to its canonical key in CANONICAL_TILE_MAP.
    #
    # @param key [String] The normalized biome key to resolve
    # @return [String, nil] Canonical key or nil if not an alias
    def resolve_alias(key)
      ALIAS_MAP[key]
    end

    # Get the layer assignment for a biome/terrain name.
    #
    # @param biome_name [String, nil] The biome name to check
    # @return [Symbol] :terrain, :biome, or :unknown
    def get_layer(biome_name)
      normalized = normalize(biome_name)
      normalized&.dig(:layer) || :unknown
    end

    # Check if a name is Layer 0 (terrain) vs Layer 1 (biome).
    #
    # @param biome_name [String, nil] The biome name to check
    # @return [Boolean] true if Layer 0 terrain, false otherwise
    def is_terrain?(biome_name)
      get_layer(biome_name) == :terrain
    end

    # Get all canonical tile keys for a given layer.
    #
    # NOTE: This returns canonical biome/terrain KEYS only (not final asset filenames).
    # A separate lookup step will later turn those keys into specific tile variants.
    # Hydrosphere tiles are NOT included — they are liquid/frozen variants, not biome keys.
    #
    # @param layer [Symbol] :terrain or :biome
    # @return [Array<String>] Canonical tile keys for the layer
    def tiles_for_layer(layer)
      all_entries = CANONICAL_TILE_MAP.values.concat(TERRAIN_ASSETS.values)

      case layer
      when :terrain
        all_entries.select { |v| v[:layer] == :terrain }.map { |v| v[:canonical] }.uniq
      when :biome
        all_entries.select { |v| v[:layer] == :biome }.map { |v| v[:canonical] }.uniq
      else
        []
      end
    end

    # Validate that a biome name resolves to a known canonical tile.
    #
    # @param biome_name [String, nil] The biome name to validate
    # @return [Boolean] true if the biome is recognized
    def valid?(biome_name)
      !normalize(biome_name).nil?
    end
  end
end
