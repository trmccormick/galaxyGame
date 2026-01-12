require 'yaml'
require 'json'

class NameGeneratorService
  def initialize
    @names = YAML.load_file(Rails.root.join('config', 'names.yml'))
  end

  def generate_identifier
    [*('A'..'Z')].sample(rand(2..4)).join + '-' + rand(100..999999).to_s
  end
  alias_method :generate_system_name, :generate_identifier

  def generate_star_proper_name
    return generate_identifier unless @names&.dig('planet_names', 'generic')&.any?
    
    @names['planet_names']['generic'].sample
  end

  def generate_settlement_star_name
    # Pick from terrestrial names that end with "Prime" for settlement
    prime_names = @names&.dig('planet_names', 'terrestrial')&.select { |name| name.end_with?(' Prime') } || []
    return generate_identifier if prime_names.empty?
    
    # Return the base name (remove " Prime")
    base_name = prime_names.sample.sub(' Prime', '')
    
    # Ensure uniqueness by adding prefixes if needed
    generate_unique_star_name(base_name)
  end

  def generate_unique_star_name(base_name)
    prefixes = ['New', 'Nova', 'Greater', 'Lesser', 'Southern', 'Northern', 'Eastern', 'Western', 'Upper', 'Lower']
    
    # First try the base name
    candidate = base_name
    return candidate unless star_name_exists?(candidate)
    
    # If taken, try with prefixes
    prefixes.each do |prefix|
      candidate = "#{prefix} #{base_name}"
      return candidate unless star_name_exists?(candidate)
    end
    
    # If all taken, add a number
    counter = 2
    loop do
      candidate = "#{base_name} #{counter}"
      return candidate unless star_name_exists?(candidate)
      counter += 1
    end
  end

  def generate_star_name(system_identifier, index)
    letter_suffix = (index < 26 ? ('A'.ord + index).chr : "A#{('A'.ord + index - 26).chr}")
    "#{system_identifier}-#{letter_suffix}"
  end

  def generate_planet_identifier(system_identifier, planet_counter)
    "#{system_identifier}-#{('b'.ord + planet_counter - 1).chr}"
  end

  def generate_planet_name(star_name, planet_index)
    if planet_index == 0
      "#{star_name} Prime"
    else
      "#{star_name} #{roman_numeral(planet_index + 1)}"
    end
  end

  private

  def star_name_exists?(name)
    # In a real implementation, this would check the database
    # For now, assume no conflicts (or implement a simple in-memory check if needed)
    false
  end

  private

  def roman_numeral(number)
    roman_numerals = {
      1 => 'I', 2 => 'II', 3 => 'III', 4 => 'IV', 5 => 'V',
      6 => 'VI', 7 => 'VII', 8 => 'VIII', 9 => 'IX', 10 => 'X',
      11 => 'XI', 12 => 'XII', 13 => 'XIII', 14 => 'XIV', 15 => 'XV'
    }
    roman_numerals[number] || number.to_s
  end
end