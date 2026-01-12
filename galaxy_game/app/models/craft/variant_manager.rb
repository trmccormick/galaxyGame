# app/services/craft/variant_manager.rb
module Craft
  class VariantManager
    # Use the path that matches where json-data is mounted in Docker
    BASE_PATH = GalaxyGame::Paths::JSON_DATA.join('operational_data', 'crafts').freeze
    
    def initialize(craft_id)
      @craft_id = craft_id
      @base_data = load_base_data
      @variants = load_variants
    end
    
    def available_variants
      @variants.keys
    end
    
    def get_variant(variant_id)
      return nil unless @variants.key?(variant_id)
      
      # Deep merge base craft data with variant-specific data
      variant_data = @variants[variant_id]
      
      # Handle special fields that need custom merging
      merged_data = @base_data.dup
      
      # Extract fields that should not override base properties
      id = merged_data["id"]
      name_override = variant_data["name"]
      system_overrides = variant_data.delete("system_overrides") || {}
      
      # Perform the deep merge
      merged_data = deep_merge(merged_data, variant_data)
      
      # Restore base ID
      merged_data["id"] = id if id
      
      # Apply name if provided
      merged_data["name"] = name_override if name_override
      
      # Apply system overrides
      if merged_data["systems"] && system_overrides.any?
        system_overrides.each do |system_name, overrides|
          if merged_data["systems"][system_name]
            merged_data["systems"][system_name] = merged_data["systems"][system_name].merge(overrides)
          else
            merged_data["systems"][system_name] = overrides
          end
        end
      end
      
      # Set variant configuration
      merged_data["operational_status"] ||= {}
      merged_data["operational_status"]["variant_configuration"] = variant_id
      
      merged_data
    end
    
    private
    
    def load_base_data
      path = BASE_PATH.join(@craft_id.split('/')[0..-2].join('/'), "#{@craft_id.split('/').last}.json")
      JSON.parse(File.read(path))
    rescue => e
      Rails.logger.error("Error loading base craft data for #{@craft_id}: #{e.message}")
      {}
    end
    
    def load_variants
      variants = {}
      variant_path = BASE_PATH.join(@craft_id.split('/')[0..-2].join('/'), 'variants')
      
      return variants unless File.directory?(variant_path)
      
      Dir.glob(File.join(variant_path, "#{@craft_id.split('/').last}_*.json")).each do |file|
        variant_data = JSON.parse(File.read(file))
        variant_id = variant_data["id"]
        variants[variant_id] = variant_data
      end
      
      variants
    rescue => e
      Rails.logger.error("Error loading variants for #{@craft_id}: #{e.message}")
      {}
    end
    
    def deep_merge(hash1, hash2)
      merger = proc do |_, v1, v2|
        if v1.is_a?(Hash) && v2.is_a?(Hash)
          v1.merge(v2, &merger)
        else
          v2
        end
      end
      
      hash1.merge(hash2, &merger)
    end
  end
end