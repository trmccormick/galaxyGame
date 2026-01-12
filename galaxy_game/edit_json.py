import json

# Load the JSON file
with open('app/data/operational_data/crafts/space/spacecraft/cycler_venus_harvester_data.json', 'r') as f:
    data = json.load(f)

# Add the production_loops
data['production_loops'] = {
    'cnt_production': {
        'input_unit': 'atmospheric_processor',
        'input_resource': 'CO2',
        'output_unit': 'cnt_fabricator_unit',
        'output_resource': 'carbon_nanotubes',
        'production_rate': '50 kg/hour per fabricator'
    }
}

# Write back
with open('app/data/operational_data/crafts/space/spacecraft/cycler_venus_harvester_data.json', 'w') as f:
    json.dump(data, f, indent=2)
