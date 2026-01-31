# scripts/lib/pattern_validator.rb

require 'json'

class PatternValidator
  def self.validate_all
    puts "=== Validating All Pattern Files ==="
    
    bodies = ['earth', 'luna', 'mars']
    all_valid = true
    
    bodies.each do |body|
      file = GalaxyGame::Paths::AI_MANAGER_PATH.join("geotiff_patterns_#{body}.json")
      
      if File.exist?(file)
        valid = validate_pattern_file(body, file)
        all_valid &&= valid
      else
        puts "❌ Missing pattern file for #{body}"
        all_valid = false
      end
    end
    
    if all_valid
      puts "✅ All pattern files valid!"
    else
      puts "❌ Some pattern files invalid"
      exit 1
    end
  end
  
  private
  
  def self.validate_pattern_file(body, filepath)
    puts "Validating #{body}..."
    
    patterns = JSON.parse(File.read(filepath))
    
    # Check required keys
    required = ['body_type', 'characteristics', 'patterns', 'metadata']
    missing = required - patterns.keys
    
    if missing.any?
      puts "  ❌ Missing keys: #{missing.join(', ')}"
      return false
    end
    
    # Check patterns section
    unless patterns['patterns'].is_a?(Hash) && patterns['patterns'].any?
      puts "  ❌ Patterns section empty"
      return false
    end
    
    puts "  ✓ Valid (#{File.size(filepath) / 1024} KB)"
    true
  end
end