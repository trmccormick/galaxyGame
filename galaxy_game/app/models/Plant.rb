class Plant < ApplicationRecord
    belongs_to :environment, optional: true

    # Validations
    validates :name, presence: true, uniqueness: true
    validates :growth_temperature_range, presence: true
    validates :growth_humidity_range, presence: true
  
    # Constants for plant health thresholds
    HEALTH_THRESHOLD = 0.0
    MAX_HEALTH = 100.0

    # Method to check if plant can grow in given environment
    def can_grow_in?(environment)
      temp_range = parse_range(growth_temperature_range)
      humidity_range = parse_range(growth_humidity_range)
      
      temp_range.include?(environment.temperature) && 
      humidity_range.include?(environment.humidity)
    end

    # Method to simulate growth and death
    def simulate_growth_and_death
      adjust_growth_rate
      adjust_death_rate
  
      self.current_health += growth_rate - death_rate
  
      if self.current_health > MAX_HEALTH
        self.current_health = MAX_HEALTH
      elsif self.current_health <= HEALTH_THRESHOLD
        destroy
      else
        save
      end
    end
  
    private
  
    # Adjust growth rate based on environmental and biome conditions
    def adjust_growth_rate
      optimal_temp = environment.temperature.in?(optimal_temperature_range)
      optimal_moist = environment.moisture.in?(optimal_moisture_range)
      biome_modifier = calculate_biome_modifier
  
      self.growth_rate = if optimal_temp && optimal_moist
                           5.0 * biome_modifier
                         else
                           0.0
                         end
    end
  
    # Adjust death rate based on environmental and biome conditions
    def adjust_death_rate
      optimal_temp = environment.temperature.in?(optimal_temperature_range)
      optimal_moist = environment.moisture.in?(optimal_moisture_range)
      biome_modifier = calculate_biome_modifier
  
      self.death_rate = if !optimal_temp || !optimal_moist
                          2.0 * biome_modifier
                        else
                          0.0
                        end
    end
  
    # Calculate a modifier based on the biome's impact on plant growth
    def calculate_biome_modifier
      case environment.biome
      when 'Desert'
        0.5 # Lower growth due to harsh conditions
      when 'Rainforest'
        1.5 # Higher growth due to ideal conditions
      else
        1.0 # Normal growth rate
      end
    end

    private

    # Parse string range like "20..30" into a Range object
    def parse_range(range_string)
      return Range.new(0, 0) if range_string.blank?
      
      if range_string.is_a?(Range)
        range_string
      else
        # Parse string like "20..30" or "20...30"
        min, max = range_string.to_s.scan(/-?\d+\.?\d*/).map(&:to_f)
        min..max
      end
    end
  end
  