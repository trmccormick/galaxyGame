require 'json'

template = {
  'identifier' => 'TPL-A01',
  'name' => 'Template A01',
  'type' => 'terrestrial',
  'mass' => 1.0,
  'radius' => 1.0,
  'density' => 1.0,
  'size' => 'medium',
  'orbital_period' => 365.25,
  'surface_temperature' => 288.0,
  'gravity' => 1.0,
  'albedo' => 0.3,
  'insolation' => 1.0,
  'known_pressure' => 1.0,
  'geological_activity' => 'moderate',
  'atmosphere' => {
    'composition' => {
      'N2' => 78.0,
      'CO2' => 20.0,
      'Ar' => 2.0
    }
  },
  'geosphere_attributes' => {
    'crust_composition' => {
      'SiO2' => 50.0,
      'Al2O3' => 15.0,
      'Fe2O3' => 10.0
    },
    'stored_volatiles' => {
      'H2O' => 100.0,
      'CO2' => 50.0
    }
  },
  'engineered_atmosphere' => false,
  'terraforming_difficulty' => 5.0,
  'volatile_reservoir' => {
    'CO2' => 1000.0,
    'H2O' => 500.0
  },
  'material_yield_bias' => {
    'rare_earth' => 1.0,
    'precious_metal' => 1.0,
    'industrial_metal' => 1.0
  }
}

data = {
  'metadata' => {
    'name' => 'Alien World Templates',
    'version' => '1.1',
    'status' => 'stable',
    'schema' => 'alien_world_template_v1.1',
    'compatible_generator' => 'star_sim/procedural_generator',
    'created_at' => '2026-01-18',
    'notes' => 'Templates for generating alien terrestrial planets with unique atmospheric and geological characteristics.'
  },
  'terrestrial_planets' => []
}

(1..25).each do |i|
  t = template.dup
  id = sprintf('TPL-A%02d', i)
  t['identifier'] = id
  t['name'] = "Template A#{'%02d' % i}"
  data['terrestrial_planets'] << t
end

File.write('data/templates/alien_world_templates_v1.1.json', JSON.pretty_generate(data))