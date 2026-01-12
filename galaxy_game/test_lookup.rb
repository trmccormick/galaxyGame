service = Lookup::StarSystemLookupService.new
data = service.fetch('Sol')
puts 'Found system data'
puts "celestial_bodies class: #{data[:celestial_bodies].class}"
puts "Keys: #{data[:celestial_bodies].keys.join(', ')}" if data[:celestial_bodies].is_a?(Hash)