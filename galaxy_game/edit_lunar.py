import json

# Load the JSON file
with open('app/data/operational_data/crafts/space/spacecraft/cycler_lunar_support_data.json', 'r') as f:
    data = json.load(f)

# Add the prerequisites
data['prerequisites'] = {
    'build_lunar_space_elevator': {
        'requires': 'cnt_delivery_from_venus_or_mars_foundry'
    }
}

# Write back
with open('app/data/operational_data/crafts/space/spacecraft/cycler_lunar_support_data.json', 'w') as f:
    json.dump(data, f, indent=2)
