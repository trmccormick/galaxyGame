# app/services/economic_config.rb
# Centralized access to economic configuration parameters
# Provides convenient methods to access values from economic_parameters.yml

class EconomicConfig
  class << self
    # Get any value from config using dot notation
    # Example: get('transport.rates_per_kg.bulk_material') => 100.0
    def get(key_path, default = nil)
      keys = key_path.split('.')
      value = keys.reduce(config) { |hash, key| hash&.dig(key) }
      value.nil? ? default : value
    end
    
    # Transport cost methods
    def transport_rate(category)
      rate = get("transport.rates_per_kg.#{category}")
      return rate if rate
      
      # Fallback to bulk_material if category not found
      get('transport.rates_per_kg.bulk_material', 100.0)
    end
    
    def route_modifier(route_key)
      get("transport.route_modifiers.#{route_key}", 1.0)
    end
    
    def technology_multiplier
      get('transport.technology_multiplier', 1.0)
    end
    
    # Earth pricing methods
    def earth_spot_price(material_id)
      normalized_id = normalize_material_id(material_id)
      get("earth_spot_prices.#{normalized_id}")
    end
    
    def refining_factor(process_type)
      get("refining_factors.#{process_type}", get('refining_factors.default', 1.0))
    end
    
    def logistics_multiplier(handling_type)
      get("logistics_multipliers.#{handling_type}", get('logistics_multipliers.default', 1.0))
    end
    
    # NPC behavior methods
    def npc(key_path)
      get("npc_behavior.#{key_path}")
    end
    
    def npc_sell_markup(market_exists: false)
      if market_exists
        npc('market_based.sell_markup')
      else
        npc('cost_based.sell_markup')
      end
    end
    
    def npc_buy_discount(market_exists: false)
      if market_exists
        npc('market_based.buy_discount')
      else
        npc('cost_based.buy_discount')
      end
    end
    
    # Currency methods
    def usd_to_gcc_peg
      get('currency.usd_to_gcc_peg', 1.0)
    end
    
    # Local production methods
    def local_production_cost(resource_id, maturity_stage = :mature)
      # First try to get specific resource cost at maturity
      base_cost = get("local_production.costs_at_maturity.#{normalize_material_id(resource_id)}")
      return base_cost if base_cost
      
      # If no specific cost, use Earth price * maturity multiplier
      earth_price = earth_spot_price(resource_id)
      return nil unless earth_price
      
      maturity_multiplier = get("local_production.maturity_stages.#{maturity_stage}.multiplier", 1.0)
      (earth_price * maturity_multiplier).round(2)
    end
    
    # Utility methods
    def reload!
      @config = nil
      load_config
    end
    
    def config
      @config ||= load_config
    end
    
    def era
      get('era', 'mature_space_industry')
    end
    
    def version
      get('version', '1.0')
    end
    
    # Export all config as hash (useful for debugging)
    def to_h
      config.deep_dup
    end
    
    # Validate configuration on load
    def validate!
      errors = []
      
      # Check required keys exist
      required_keys = [
        'currency.usd_to_gcc_peg',
        'transport.rates_per_kg.bulk_material',
        'npc_behavior.cost_based.sell_markup',
        'npc_behavior.cost_based.buy_discount'
      ]
      
      required_keys.each do |key|
        errors << "Missing required config: #{key}" if get(key).nil?
      end
      
      # Check values are reasonable
      errors << "USD to GCC peg must be positive" if usd_to_gcc_peg <= 0
      errors << "Transport rates must be positive" if transport_rate('bulk_material') <= 0
      errors << "NPC sell markup must be >= 1.0" if npc_sell_markup < 1.0
      errors << "NPC buy discount must be <= 1.0" if npc_buy_discount > 1.0
      
      if errors.any?
        raise ConfigurationError, "Economic configuration errors:\n#{errors.join("\n")}"
      end
      
      true
    end

    def self.transport_rate(category)
      config = self.current_config
      config.dig('economy', 'transport', 'rates_per_kg', category) || 100.0
    end
    
    # Cryptocurrency mining methods
    def gcc_max_supply
      get('cryptocurrency.gcc_mining.max_supply', 21_000_000_000)
    end
    
    def gcc_halving_interval_days
      get('cryptocurrency.gcc_mining.halving_interval_days', 730)
    end
    
    def gcc_issuance_model
      get('cryptocurrency.gcc_mining.issuance_model', 'capped_deflationary')
    end
    
    def gcc_difficulty_scaling_enabled?
      get('cryptocurrency.gcc_mining.difficulty_scaling', true)
    end
    
    def gcc_initial_block_reward
      get('cryptocurrency.gcc_mining.initial_block_reward', 1000)
    end
    
    def gcc_minimum_block_reward
      get('cryptocurrency.gcc_mining.minimum_block_reward', 1)
    end
    
    private
    
    def load_config
      config_path = Rails.root.join('config', 'economic_parameters.yml')
      
      unless File.exist?(config_path)
        raise ConfigurationError, "Economic configuration file not found at #{config_path}"
      end
      
      yaml_content = YAML.load_file(config_path)
      
      unless yaml_content && yaml_content['economy']
        raise ConfigurationError, "Invalid economic configuration format"
      end
      
      yaml_content['economy']
    rescue Psych::SyntaxError => e
      raise ConfigurationError, "YAML syntax error in economic_parameters.yml: #{e.message}"
    end
    
    def normalize_material_id(material_id)
      return nil unless material_id
      material_id.to_s.downcase.gsub(/\s+/, '_')
    end
  end
  
  # Custom error class for configuration issues
  class ConfigurationError < StandardError; end
end