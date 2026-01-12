service = Lookup::StarSystemLookupService.new
systems = service.instance_variable_get(:@systems)
puts 'All systems:'
systems.each { |s| puts "- ID: #{s[:id]}, Name: #{s[:name]}, Source: #{s[:_source_type]}, Celestial bodies: #{s[:celestial_bodies]&.class}" }
puts ''
puts 'Looking for Sol...'
data = service.fetch('Sol')
puts "Found: #{data ? data[:id] : 'nil'}"