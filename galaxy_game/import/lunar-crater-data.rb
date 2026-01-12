require 'nokogiri'
require 'open-uri'
require 'json'
require 'erb'

BASE_URL = 'https://en.wikipedia.org'

# Function to fetch catalog links from the main page
def fetch_catalog_links(main_url)
    puts "Fetching catalog links from #{main_url}..."
    doc = Nokogiri::HTML(URI.open(main_url))
  
    # Extract links from the "div-col" class under the Catalog section
    catalog_links = doc.css('div.div-col ul li a').map do |link|
      href = link['href']
      URI.join(BASE_URL, href).to_s
    end
  
    puts "Found #{catalog_links.size} catalog links."
    catalog_links
end

# Function to fetch craters from a single catalog page
def fetch_craters_from_page(url)
  puts "Fetching craters from #{url}..."
  doc = Nokogiri::HTML(URI.open(url))

  craters = doc.css('table.wikitable tbody tr').map do |row|
    cells = row.css('td')
    next if cells.empty?

    {
      name: cells[0].text.strip,
      coordinates: cells[1]&.at_css('span.geo-dec')&.text&.strip || cells[1]&.text&.strip,
      diameter: cells[2]&.text&.strip,
      depth: "Unknown" # Placeholder for depth
    }
  end.compact

  puts "Found #{craters.size} craters."
  craters
end

# Function to fetch additional data (e.g., depth) for a specific crater
def fetch_crater_details(crater)
    puts "Fetching details for #{crater[:name]}..."
    encoded_name = ERB::Util.url_encode(crater[:name].gsub(' ', '_'))
    page_url = URI.join(BASE_URL, "/wiki/#{encoded_name}_(crater)").to_s
  
    begin
      doc = Nokogiri::HTML(URI.open(page_url))
      depth_match = doc.at('th:contains("Depth") + td')&.text
  
      if depth_match
        depth_text = depth_match.strip.downcase
        if depth_text.include?('km')
          crater[:depth] = depth_text.split('km').first.strip.gsub(/[^\d.]/, '') + ' km'
        else
          crater[:depth] = 'unknown'
        end
        puts "Depth found: #{crater[:depth]}"
      else
        puts "Depth not found."
      end

      # Estimate depth if not found or unknown
      if crater[:depth] == 'unknown' || crater[:depth].nil? && crater[:diameter]
        diameter_km = crater[:diameter].to_f
        estimated_depth_km = (diameter_km * 0.2).round(2) # Simple estimation: 20% of diameter
        crater[:depth] = "#{estimated_depth_km} km (estimated)"
        puts "Estimated depth: #{crater[:depth]}"
      end 
    rescue OpenURI::HTTPError
      puts "Page not found for #{crater[:name]}."
    end
end

# Main script logic
def main
  main_url = 'https://en.wikipedia.org/wiki/List_of_craters_on_the_Moon'
  catalog_links = fetch_catalog_links(main_url)

  all_craters = []

  # Fetch craters from all catalog pages
  catalog_links.each_with_index do |catalog_url, catalog_index|
    puts "Processing catalog #{catalog_index + 1}/#{catalog_links.size}..."
    craters = fetch_craters_from_page(catalog_url)

    # Fetch additional details for each crater
    craters.each_with_index do |crater, crater_index|
      puts "Processing crater #{crater_index + 1}/#{craters.size} in catalog #{catalog_index + 1}..."
      fetch_crater_details(crater)
      sleep(1 + rand(2)) # Wait 1–3 seconds to avoid rate-limiting
    end

    all_craters += craters
  end

  # Save to JSON
  output_path = "lunar_craters.json"
  File.write(output_path, JSON.pretty_generate(all_craters))
  puts "Data saved to #{output_path}."
end

main



