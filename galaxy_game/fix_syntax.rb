lines = File.readlines('lib/tasks/ai_manager.rake')
fixed_lines = []
i = 0
while i < lines.length
  if lines[i] =~ /celestial_bodies = if File\.exist/
    # Replace the malformed conditional
    fixed_lines << '    # Load celestial bodies from Sol system for testing' << n
    fixed_lines << '    sol_system_path = Rails.root.join(data, json-data, star_systems, sol-complete.json)' << n
    fixed_lines << '    celestial_bodies = if File.exist?(sol_system_path)' << n
    fixed_lines << '                        JSON.parse(File.read(sol_system_path))[celestial_bodies] || []' << n
    fixed_lines << '                      else' << n
    fixed_lines << '                        []' << n
    fixed_lines << '                      end' << n
    i += 5  # Skip the malformed lines
  else
    fixed_lines << lines[i]
    i += 1
  end
end
File.write('lib/tasks/ai_manager.rake', fixed_lines.join)
puts Fixed
