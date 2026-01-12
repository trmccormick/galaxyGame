# needs tested

require 'nokogiri'
require 'open-uri'
require 'json'

BASE_URL = 'https://en.wikipedia.org/wiki/List_of_brown_dwarfs'

# Converts RA (h, m, s) to degrees
def ra_to_degrees(ra_string)
  match = ra_string.match(/(\d+)h\s*(\d+)m\s*([\d.]+)s/)
  return nil unless match

  h, m, s = match[1].to_f, match[2].to_f, match[3].to_f
  (h + (m / 60) + (s / 3600)) * 15
end

# Converts Dec (° ' ") to degrees
def dec_to_degrees(dec_string)
  match = dec_string.match(/([+-]?\d+)°\s*(\d+)′\s*([\d.]+)″/)
  return nil unless match

  deg, arcmin, arcsec = match[1].to_f, match[2].to_f, match[3].to_f
  deg + (arcmin / 60) + (arcsec / 3600)
end

# Converts RA/Dec/Distance to 3D Cartesian coordinates
def celestial_to_cartesian(ra_deg, dec_deg, distance_ly)
  ra_rad = ra_deg * Math::PI / 180
  dec_rad = dec_deg * Math::PI / 180
  d = distance_ly.to_f

  x = d * Math.cos(dec_rad) * Math.cos(ra_rad)
  y = d * Math.cos(dec_rad) * Math.sin(ra_rad)
  z = d * Math.sin(dec_rad)

  { x: x.round(2), y: y.round(2), z: z.round(2) }
end

# Fetches and parses the brown dwarf table
def fetch_brown_dwarfs(url)
  puts "Fetching brown dwarfs from #{url}..."
  doc = Nokogiri::HTML(URI.open(url))

  brown_dwarfs = []
  table = doc.css('table.wikitable tbody')

  table.css('tr').each do |row|
    cells = row.css('td')
    next if cells.empty?

    name = cells[0].text.strip
    ra = cells[1].text.strip
    dec = cells[2].text.strip
    distance = cells[4].text.strip.to_f
    spectral_type = cells[5].text.strip

    ra_deg = ra_to_degrees(ra)
    dec_deg = dec_to_degrees(dec)

    if ra_deg.nil? || dec_deg.nil?
      puts "Skipping #{name} due to missing coordinates."
      next
    end

    coordinates = celestial_to_cartesian(ra_deg, dec_deg, distance)

    brown_dwarfs << {
      name: name,
      ra: ra,
      dec: dec,
      distance_ly: distance,
      spectral_type: spectral_type,
      x_coordinate: coordinates[:x],
      y_coordinate: coordinates[:y],
      z_coordinate: coordinates[:z]
    }
  end

  puts "Found #{brown_dwarfs.size} brown dwarfs."
  brown_dwarfs
end

# Saves brown dwarf data to JSON
def save_to_json(data, filename)
  File.write(filename, JSON.pretty_generate(data))
  puts "Data saved to #{filename}."
end

# Imports into Rails database (if Rails is defined)
def import_into_spatial_location(data)
  data.each do |bd|
    SpatialLocation.find_or_create_by(
      name: bd[:name],
      x_coordinate: bd[:x_coordinate],
      y_coordinate: bd[:y_coordinate],
      z_coordinate: bd[:z_coordinate]
    ) do |location|
      location.spatial_context = nil  # Assign relevant context
      location.locationable = nil  # Assign if needed
    end
    puts "Imported: #{bd[:name]}"
  end
end

# Main execution
def main
  brown_dwarfs = fetch_brown_dwarfs(BASE_URL)
  save_to_json(brown_dwarfs, 'brown_dwarfs.json')

  # Import into Rails (if using Rails)
  import_into_spatial_location(brown_dwarfs) if defined?(Rails)
end

main
