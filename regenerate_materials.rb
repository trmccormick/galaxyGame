#!/usr/bin/env ruby
require 'json'
require 'fileutils'

# Script to regenerate corrupted material JSON files
# Run from the galaxy_game directory

MATERIALS_DIR = 'data/json-data/resources/materials'

# Template for different material types
TEMPLATES = {
  'gases' => {
    'reactive' => {
      "template" => "material",
      "category" => "gases",
      "subcategory" => "reactive",
      "chemical_formula" => nil, # Will be set per material
      "molar_mass" => nil, # Will be set per material
      "state_at_stp" => "gas",
      "properties" => {
        "unit_of_measurement" => "kg",
        "purity" => "high",
        "state_at_room_temp" => "gas",
        "transparent" => true,
        "oxidizer" => false,
        "radioactive" => false
      },
      "storage" => {
        "pressure" => "standard",
        "temperature" => "standard",
        "stability" => "stable",
        "incompatible_with" => []
      },
      "handling" => {
        "ppe_required" => [],
        "hazard_class" => [],
        "disposal" => "standard"
      }
    },
    'inert' => {
      "template" => "material",
      "category" => "gases",
      "subcategory" => "inert",
      "chemical_formula" => nil,
      "molar_mass" => nil,
      "state_at_stp" => "gas",
      "properties" => {
        "unit_of_measurement" => "kg",
        "purity" => "high",
        "state_at_room_temp" => "gas",
        "transparent" => true,
        "oxidizer" => false,
        "radioactive" => false
      },
      "storage" => {
        "pressure" => "standard",
        "temperature" => "standard",
        "stability" => "stable",
        "incompatible_with" => []
      },
      "handling" => {
        "ppe_required" => [],
        "hazard_class" => [],
        "disposal" => "standard"
      }
    },
    'compound' => {
      "template" => "material",
      "category" => "gases",
      "subcategory" => "compound",
      "chemical_formula" => nil,
      "molar_mass" => nil,
      "state_at_stp" => "gas",
      "properties" => {
        "unit_of_measurement" => "kg",
        "purity" => "high",
        "state_at_room_temp" => "gas",
        "transparent" => true,
        "oxidizer" => false,
        "radioactive" => false
      },
      "storage" => {
        "pressure" => "standard",
        "temperature" => "standard",
        "stability" => "stable",
        "incompatible_with" => []
      },
      "handling" => {
        "ppe_required" => [],
        "hazard_class" => [],
        "disposal" => "standard"
      }
    }
  },
  'building' => {
    'structural' => {
      "template" => "material",
      "category" => "building",
      "subcategory" => "structural",
      "properties" => {
        "unit_of_measurement" => "kg",
        "purity" => "high",
        "state_at_room_temp" => "solid",
        "density" => "2.5",
        "tensile_strength" => "100",
        "corrosion_resistance" => "high"
      },
      "storage" => {
        "pressure" => "atmospheric",
        "temperature" => "room",
        "stability" => "stable",
        "incompatible_with" => []
      },
      "handling" => {
        "ppe_required" => [],
        "hazard_class" => [],
        "disposal" => "recycle"
      }
    },
    'functional' => {
      "template" => "material",
      "category" => "building",
      "subcategory" => "functional",
      "properties" => {
        "unit_of_measurement" => "kg",
        "purity" => "high",
        "state_at_room_temp" => "solid",
        "density" => "1.5",
        "thermal_conductivity" => "low",
        "electrical_conductivity" => "low"
      },
      "storage" => {
        "pressure" => "atmospheric",
        "temperature" => "room",
        "stability" => "stable",
        "incompatible_with" => []
      },
      "handling" => {
        "ppe_required" => [],
        "hazard_class" => [],
        "disposal" => "recycle"
      }
    }
  },
  'processed' => {
    'metals' => {
      "template" => "material",
      "category" => "processed",
      "subcategory" => "metals",
      "properties" => {
        "unit_of_measurement" => "kg",
        "purity" => "high",
        "state_at_room_temp" => "solid",
        "density" => "7.8",
        "melting_point" => "1500",
        "electrical_conductivity" => "high",
        "thermal_conductivity" => "high"
      },
      "storage" => {
        "pressure" => "atmospheric",
        "temperature" => "room",
        "stability" => "stable",
        "incompatible_with" => []
      },
      "handling" => {
        "ppe_required" => [],
        "hazard_class" => [],
        "disposal" => "recycle"
      }
    },
    'alloys' => {
      "template" => "material",
      "category" => "processed",
      "subcategory" => "alloys",
      "properties" => {
        "unit_of_measurement" => "kg",
        "purity" => "high",
        "state_at_room_temp" => "solid",
        "density" => "2.7",
        "melting_point" => "660",
        "tensile_strength" => "200",
        "corrosion_resistance" => "high"
      },
      "storage" => {
        "pressure" => "atmospheric",
        "temperature" => "room",
        "stability" => "stable",
        "incompatible_with" => []
      },
      "handling" => {
        "ppe_required" => [],
        "hazard_class" => [],
        "disposal" => "recycle"
      }
    },
    'polymers' => {
      "template" => "material",
      "category" => "processed",
      "subcategory" => "polymers",
      "properties" => {
        "unit_of_measurement" => "kg",
        "purity" => "high",
        "state_at_room_temp" => "solid",
        "density" => "1.2",
        "melting_point" => "200",
        "thermal_conductivity" => "low",
        "electrical_conductivity" => "low"
      },
      "storage" => {
        "pressure" => "atmospheric",
        "temperature" => "room",
        "stability" => "stable",
        "incompatible_with" => []
      },
      "handling" => {
        "ppe_required" => [],
        "hazard_class" => [],
        "disposal" => "recycle"
      }
    },
    'semiconductors' => {
      "template" => "material",
      "category" => "processed",
      "subcategory" => "semiconductors",
      "properties" => {
        "unit_of_measurement" => "kg",
        "purity" => "ultra_high",
        "state_at_room_temp" => "solid",
        "density" => "2.3",
        "melting_point" => "1414",
        "electrical_conductivity" => "semiconductor",
        "thermal_conductivity" => "medium"
      },
      "storage" => {
        "pressure" => "atmospheric",
        "temperature" => "room",
        "stability" => "stable",
        "incompatible_with" => ["moisture"]
      },
      "handling" => {
        "ppe_required" => ["gloves"],
        "hazard_class" => [],
        "disposal" => "electronic_waste"
      }
    },
    'composites' => {
      "template" => "material",
      "category" => "processed",
      "subcategory" => "composites",
      "properties" => {
        "unit_of_measurement" => "kg",
        "purity" => "high",
        "state_at_room_temp" => "solid",
        "density" => "1.8",
        "tensile_strength" => "150",
        "thermal_conductivity" => "low"
      },
      "storage" => {
        "pressure" => "atmospheric",
        "temperature" => "room",
        "stability" => "stable",
        "incompatible_with" => []
      },
      "handling" => {
        "ppe_required" => [],
        "hazard_class" => [],
        "disposal" => "recycle"
      }
    }
  },
  'raw' => {
    'geological' => {
      'ore' => {
        "template" => "material",
        "category" => "raw",
        "subcategory" => "geological",
        "type" => "ore",
        "properties" => {
          "unit_of_measurement" => "kg",
          "purity" => "variable",
          "state_at_room_temp" => "solid",
          "density" => "3.5",
          "hardness" => "medium"
        },
        "storage" => {
          "pressure" => "atmospheric",
          "temperature" => "room",
          "stability" => "stable",
          "incompatible_with" => []
        },
        "handling" => {
          "ppe_required" => ["dust_mask"],
          "hazard_class" => [],
          "disposal" => "mining_waste"
        }
      },
      'soil' => {
        "template" => "material",
        "category" => "raw",
        "subcategory" => "geological",
        "type" => "soil",
        "properties" => {
          "unit_of_measurement" => "kg",
          "purity" => "variable",
          "state_at_room_temp" => "solid",
          "density" => "1.5",
          "particle_size" => "fine"
        },
        "storage" => {
          "pressure" => "atmospheric",
          "temperature" => "room",
          "stability" => "stable",
          "incompatible_with" => []
        },
        "handling" => {
          "ppe_required" => ["dust_mask"],
          "hazard_class" => [],
          "disposal" => "landfill"
        }
      }
    }
  },
  'liquids' => {
    "template" => "material",
    "category" => "liquids",
    "properties" => {
      "unit_of_measurement" => "liter",
      "purity" => "high",
      "state_at_room_temp" => "liquid",
      "density" => "1.0"
    },
    "storage" => {
      "pressure" => "atmospheric",
      "temperature" => "room",
      "stability" => "stable",
      "incompatible_with" => []
    },
    "handling" => {
      "ppe_required" => [],
      "hazard_class" => [],
      "disposal" => "standard"
    }
  },
  'components' => {
    "template" => "material",
    "category" => "components",
    "properties" => {
      "unit_of_measurement" => "kg",
      "purity" => "high",
      "state_at_room_temp" => "solid",
      "density" => "2.0"
    },
    "storage" => {
      "pressure" => "atmospheric",
      "temperature" => "room",
      "stability" => "stable",
      "incompatible_with" => []
    },
    "handling" => {
      "ppe_required" => [],
      "hazard_class" => [],
      "disposal" => "recycle"
    }
  }
}

# Molar masses for common gases
MOLAR_MASSES = {
  'hydrogen' => 2.016,
  'helium' => 4.0026,
  'nitrogen' => 28.0134,
  'oxygen' => 31.9988,
  'argon' => 39.948,
  'neon' => 20.1797,
  'methane' => 16.04,
  'ammonia' => 17.031,
  'water' => 18.01528,
  'carbon_dioxide' => 44.01,
  'carbon_monoxide' => 28.01,
  'nitrous_oxide' => 44.013,
  'sulfur_dioxide' => 64.066,
  'hydrogen_sulfide' => 34.08,
  'ozone' => 48.00,
  'acetylene' => 26.04,
  'chlorine' => 70.906,
  'fluorine' => 37.9968,
  'hydrogen_chloride' => 36.46,
  'nitrogen_dioxide' => 46.0055,
  'sulfur_hexafluoride' => 146.06
}

# Chemical formulas for gases
CHEMICAL_FORMULAS = {
  'hydrogen' => 'H2',
  'helium' => 'He',
  'nitrogen' => 'N2',
  'oxygen' => 'O2',
  'argon' => 'Ar',
  'neon' => 'Ne',
  'methane' => 'CH4',
  'ammonia' => 'NH3',
  'water' => 'H2O',
  'carbon_dioxide' => 'CO2',
  'carbon_monoxide' => 'CO',
  'nitrous_oxide' => 'N2O',
  'sulfur_dioxide' => 'SO2',
  'hydrogen_sulfide' => 'H2S',
  'ozone' => 'O3',
  'acetylene' => 'C2H2',
  'chlorine' => 'Cl2',
  'fluorine' => 'F2',
  'hydrogen_chloride' => 'HCl',
  'nitrogen_dioxide' => 'NO2',
  'sulfur_hexafluoride' => 'SF6'
}

def generate_material_json(file_path)
  # Parse path to determine category/subcategory
  relative_path = file_path.sub("#{MATERIALS_DIR}/", '')
  parts = relative_path.split('/')
  filename = File.basename(file_path, '.json')
  
  # Determine category and subcategory
  category = parts[0]
  subcategory = parts[1] if parts.length > 1
  type = parts[2] if parts.length > 2
  
  # Get template
  template = nil
  if category == 'raw' && subcategory == 'geological'
    template = TEMPLATES[category][subcategory][type]
  elsif category == 'gases'
    template = TEMPLATES[category][subcategory]
  else
    template = TEMPLATES[category][subcategory]
  end
  
  return nil unless template
  
  # Create material data
  material = template.dup
  
  # Set basic fields
  material['id'] = filename
  material['name'] = filename.split('_').map(&:capitalize).join(' ')
  material['description'] = "A #{subcategory} #{category} material"
  
  # Set gas-specific fields
  if category == 'gases'
    material['chemical_formula'] = CHEMICAL_FORMULAS[filename] || filename.upcase
    material['molar_mass'] = MOLAR_MASSES[filename] || 40.0
  end
  
  # Clean up null values
  material = clean_nulls(material)
  
  # Add metadata
  material['metadata'] = {
    "version" => "1.3",
    "type" => "material",
    "template_compliance" => "material_v1.3"
  }
  
  material
end

def clean_nulls(obj)
  if obj.is_a?(Hash)
    obj.each do |k, v|
      if v.nil?
        obj.delete(k)
      elsif v.is_a?(Hash) || v.is_a?(Array)
        clean_nulls(v)
      end
    end
  elsif obj.is_a?(Array)
    obj.each { |item| clean_nulls(item) }
  end
  obj
end

def regenerate_materials
  Dir.glob("#{MATERIALS_DIR}/**/*.json").each do |file_path|
    puts "Regenerating: #{file_path}"
    
    material_data = generate_material_json(file_path)
    next unless material_data
    
    File.write(file_path, JSON.pretty_generate(material_data))
  end
end

if __FILE__ == $0
  regenerate_materials
  puts "Material regeneration complete!"
end