# scripts/lib/pattern_summarizer.rb

require 'json'

class PatternSummarizer
  def self.create_summary
    puts "=== Creating Pattern Summary ==="
    
    bodies = ['earth', 'luna', 'mars']
    summary = {
      version: '1.0.0',
      created_at: Time.current.iso8601,
      bodies: {}
    }
    
    bodies.each do |body|
      file = GalaxyGame::Paths::AI_MANAGER_PATH.join("geotiff_patterns_#{body}.json")
      next unless File.exist?(file)
      
      patterns = JSON.parse(File.read(file))
      
      summary[:bodies][body] = {
        body_type: patterns['body_type'],
        characteristics: patterns['characteristics'],
        pattern_types: patterns['patterns'].keys,
        file_size_kb: File.size(file) / 1024
      }
    end
    
    # Save summary
    output_file = GalaxyGame::Paths::AI_MANAGER_PATH.join('pattern_summary.json')
    File.write(output_file, JSON.pretty_generate(summary))
    
    puts "✓ Summary created: #{output_file}"
    puts ""
    puts "Body Types Available:"
    summary[:bodies].each do |body, info|
      puts "  #{body.upcase}: #{info[:body_type]}"
      puts "    Patterns: #{info[:pattern_types].join(', ')}"
      puts "    Size: #{info[:file_size_kb]} KB"
    end
  end
end