module Naming
  class PlanetNameService
    DATA_PATH = GalaxyGame::Paths::NAMES_PATH.join('planet_names.json')

    def initialize
      @names_data = load_names_data
      @used_names = Set.new # In-memory cache for this session
    end

    def generate_planet_name(terraformable: false, system_identifier: nil, index: nil, settlement_type: nil, world_composition: nil)
      # Determine name category based on world composition and settlement type
      category = determine_category(world_composition, settlement_type)

      # Get available names for this category
      available_names = @names_data[category] || @names_data['rocky'] || []

      # Try to find an unused name
      candidate = find_unused_name(available_names, system_identifier, index)

      # If we can't find a unique name, add a suffix
      unless candidate && unique?(candidate)
        candidate = add_suffix_to_name(candidate || available_names.sample, system_identifier)
      end

      # Mark as used
      @used_names.add(candidate)

      candidate
    end

    private

    def determine_category(world_composition, settlement_type)
      # First check for specific settlement types
      case settlement_type&.to_s&.downcase
      when 'industrial', 'manufacturing', 'production'
        'industrial'
      when 'mining', 'extraction', 'resource'
        'mining'
      when 'research', 'science', 'laboratory'
        'research'
      when 'military', 'defense', 'security'
        'military'
      when 'corporate', 'trade', 'commerce'
        'corporate'
      end

      # Then check world composition
      case world_composition&.to_s&.downcase
      when 'terrestrial', 'earth-like', 'habitable'
        'terrestrial'
      when 'oceanic', 'water', 'aquatic'
        'oceanic'
      when 'desert', 'arid', 'dry'
        'desert'
      when 'ice', 'frozen', 'cryogenic'
        'ice'
      when 'volcanic', 'lava', 'magma'
        'volcanic'
      when 'rocky', 'stone', 'crustal'
        'rocky'
      when 'metallic', 'metal', 'iron'
        'metallic'
      when 'carbonaceous', 'organic', 'hydrocarbon'
        'carbonaceous'
      when 'siliceous', 'silica', 'quartz'
        'siliceous'
      when 'icy_moon', 'ice_moon'
        'icy_moon'
      when 'asteroid', 'asteroidal'
        'asteroid'
      else
        # Default fallback
        'rocky'
      end
    end

    private

    def load_names_data
      return {} unless File.exist?(DATA_PATH)

      begin
        JSON.parse(File.read(DATA_PATH))
      rescue JSON::ParserError => e
        Rails.logger.warn "Failed to load planet names data: #{e.message}"
        {}
      end
    end

    def find_unused_name(names, system_identifier, index)
      # Simple deterministic selection based on system and index
      # This ensures reproducible names for the same system
      seed = (system_identifier.hash + (index || 0)) % names.length
      names[seed]
    end

    def add_suffix_to_name(base_name, system_identifier)
      suffixes = @names_data['suffixes'] || ['I', 'II', 'III']
      suffix = suffixes.sample

      "#{base_name} #{suffix}"
    end

    def unique?(name)
      # Check in-memory cache first
      return false if @used_names.include?(name)
      
      # Check database for existing planets
      # Use the correct model name
      if defined?(CelestialBodies::Planets::Planet)
        !CelestialBodies::Planets::Planet.exists?(name: name)
      else
        # If model not loaded, assume unique
        true
      end
    rescue
      # If database check fails, assume it's unique
      true
    end
  end
end