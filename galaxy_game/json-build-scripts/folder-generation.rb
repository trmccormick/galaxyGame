require 'fileutils'

# Base path for all directories
BASE_PATH = "/home/galaxy_game/app/data"

# Blueprint directory structure
BLUEPRINT_STRUCTURE = {
  "blueprints" => {
    "crafts" => [
      "space/satellites",
      "space/spacecraft",
      "space/landers",
      "space/probes",
      "atmospheric",
      "ground"
    ],
    "structures" => [
      "habitation",           # Habitation modules, living quarters
      "landing_infrastructure", # Landing pads, docking bays
      "life_support",         # Atmosphere, water, food production
      "manufacturing",        # Assembly lines, fabricators
      "power_generation",     # Power plants, solar arrays
      "resource_extraction",  # Mining facilities, drills
      "resource_processing",  # Refineries, processing plants
      "science_research",     # Research labs, observation posts
      "storage",              # Storage facilities, tanks
      "transportation",       # Transport infrastructure
      "space_stations"        # Space stations and orbital habitats
    ],
    "units" => [
      "production/extractors",
      "production/refineries",
      "production/fabricators",
      "energy",
      "habitats",
      "life_support",
      "computers",
      "propulsion",
      "robots/deployment",
      "robots/construction",
      "robots/maintenance",
      "robots/exploration",
      "robots/life_support",
      "robots/logistics",
      "robots/resource",
      "storage",
      "specialized"           # Specialized units for unique tasks
    ],
    "modules" => [
      "computer",           # Computing and control modules
      "defense",            # Defensive and security modules
      "energy",             # Energy management modules
      "infrastructure",     # Structural connection modules (airlocks, docking)
      "life_support",       # Air, water, and waste recycling
      "power",              # Power generation modules
      "production",         # Manufacturing modules
      "propulsion",         # Movement and propulsion enhancements
      "science",            # Research and analysis modules
      "sensors",            # Sensor and scanning modules 
      "storage",            # Additional storage modules
      "utility"             # General purpose utility modules
    ],
    "components" => [
      "electronics",
      "mechanical",
      "structural",
      "specialized"
    ],
    "rigs" => [
      "computer",
      "defense", 
      "energy",
      "infrastructure",
      "life_support",
      "power",
      "production",
      "propulsion",
      "science",
      "storage",
      "utility"
    ]
  },
  
  "resources" => {
    "materials" => [
      "raw/geological",
      "raw/biological",
      "raw/atmospheric",
      "processed/metals",
      "processed/alloys",
      "processed/polymers",
      "processed/ceramics",
      "processed/composites",
      "chemicals/industrial",
      "chemicals/biochemical",
      "chemicals/exotic",
      "building/structural",
      "building/functional",
      "gases/inert",
      "gases/reactive",
      "gases/compound",
      "liquids/coolants",
      "liquids/solvents",
      "liquids/reagents",
      "byproducts/waste",
      "byproducts/recyclable"
    ],
    "fuels" => [
      "solid",
      "liquid/chemical",
      "liquid/nuclear",
      "gas",
      "plasma",
      "exotic"
    ],
    "chemicals" => [
      "solvents",
      "catalysts",
      "reagents",
      "compounds",
      "solutions"
    ]
  },
  
  # Other data directories to create
  "operational_data" => {
    "crafts" => [
      "space/satellites",
      "space/spacecraft",
      "space/landers",
      "space/probes",
      "atmospheric",
      "ground"
    ],
    "structures" => [
      "habitation",
      "landing_infrastructure",
      "life_support",
      "manufacturing",
      "power_generation",
      "resource_extraction",
      "resource_processing",
      "science_research",
      "storage",
      "transportation",
      "space_stations"
    ],
    "units" => [
      "production/extractors",
      "production/refineries",
      "production/fabricators",
      "energy",
      "habitats",
      "life_support",
      "computers",
      "propulsion",
      "robots/deployment",
      "robots/construction",
      "robots/maintenance",
      "robots/exploration",
      "robots/life_support",
      "robots/logistics",   
      "robots/resource",         
      "storage",
      "specialized"
    ],
    "modules" => [
      "computer",
      "defense", 
      "energy",
      "infrastructure",
      "life_support",
      "power",
      "production",
      "propulsion",
      "science",
      "sensors",      
      "storage",
      "utility"
    ],
    "rigs" => [
      "computer",
      "defense", 
      "energy",
      "infrastructure",
      "life_support",
      "power",
      "production",
      "propulsion",
      "science",
      "storage",
      "utility"
    ]
  },
  
  "items" => {
    "components" => [
      "electronics",
      "mechanical",
      "structural",
      "specialized"
    ],
    "consumable" => [
      "life_support",
      "power",
      "medical",
      "food",
      "industrial"
    ],
    "container" => [
      "liquid",
      "solid",
      "gas",
      "specialty"
    ],
    "equipment" => [
      "personal",
      "scientific",
      "industrial",
      "medical"
    ],
    "tool" => [
      "hand_tools",
      "power_tools",
      "scientific",
      "medical"
    ],
    "furniture" => [
      "residential",
      "industrial",
      "scientific"
    ],
    "crafted_parts" => [
      "structural",
      "mechanical",
      "electronic",
      "specialized"
    ]
  },
  
  # Add these top-level directories
  # "units" => [
  #   "production/extractors",
  #   "production/refineries",
  #   "production/fabricators",
  #   "energy",
  #   "habitats",
  #   "life_support",
  #   "computers",
  #   "propulsion",
  #   "storage"
  # ],
  # "rigs" => [
  #   "computer",
  #   "defense", 
  #   "energy",
  #   "infrastructure",
  #   "life_support",
  #   "power",
  #   "production",
  #   "propulsion",
  #   "science",
  #   "storage",
  #   "utility"
  # ],
  # "modules" => [
  #   "computer",
  #   "defense", 
  #   "energy",
  #   "infrastructure",
  #   "life_support",
  #   "power",
  #   "production",
  #   "propulsion",
  #   "science",
  #   "storage",
  #   "utility"
  # ]
}

# Create the directory structure
def create_directory_structure
  BLUEPRINT_STRUCTURE.each do |parent_dir, sub_dirs|
    if sub_dirs.is_a?(Hash)
      # Handle nested structure (blueprints, resources, etc.)
      sub_dirs.each do |sub_parent, dirs|
        dirs.each do |dir|
          begin
            full_path = File.join(BASE_PATH, parent_dir, sub_parent, dir)
            FileUtils.mkdir_p(full_path)
            puts "Created: #{full_path}"
          rescue => e
            puts "ERROR creating #{full_path}: #{e.message}"
          end
        end
      end
    elsif sub_dirs.is_a?(Array)
      # Handle flat structure (top-level units, rigs, modules)
      sub_dirs.each do |dir|
        begin
          full_path = File.join(BASE_PATH, parent_dir, dir)
          FileUtils.mkdir_p(full_path)
          puts "Created: #{full_path}"
        rescue => e
          puts "ERROR creating #{full_path}: #{e.message}"
        end
      end
    end
  end
  
  # Create templates directory if it doesn't exist
  templates_path = File.join(BASE_PATH, "templates")
  begin
    FileUtils.mkdir_p(templates_path) unless File.directory?(templates_path)
    puts "Created: #{templates_path}" unless File.directory?(templates_path)
  rescue => e
    puts "ERROR creating templates directory: #{e.message}"
  end
end

# Execute directory creation
puts "Creating directory structure..."
create_directory_structure
puts "Directory structure creation complete!"

# Verify all directories were created
def verify_directories
  missing_dirs = []
  
  BLUEPRINT_STRUCTURE.each do |parent_dir, sub_dirs|
    if sub_dirs.is_a?(Hash)
      # Handle nested structure
      sub_dirs.each do |sub_parent, dirs|
        dirs.each do |dir|
          full_path = File.join(BASE_PATH, parent_dir, sub_parent, dir)
          missing_dirs << full_path unless Dir.exist?(full_path)
        end
      end
    elsif sub_dirs.is_a?(Array)
      # Handle flat structure
      sub_dirs.each do |dir|
        full_path = File.join(BASE_PATH, parent_dir, dir)
        missing_dirs << full_path unless Dir.exist?(full_path)
      end
    end
  end
  
  if missing_dirs.empty?
    puts "✓ All directories created successfully!"
  else
    puts "⚠️ Some directories were not created:"
    missing_dirs.each { |dir| puts "  - #{dir}" }
  end
end

# Run verification
verify_directories

# Provide instructions for the next steps
puts "\nNext steps:"
puts "1. Create template files in the templates directory"
puts "2. Use the GameDataGenerator to generate content"
puts "3. Update your LookupService classes to look in the new locations"