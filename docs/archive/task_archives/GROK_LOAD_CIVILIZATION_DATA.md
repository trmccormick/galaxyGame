# TASK: Load Real Earth Civilization Data into Monitor View

## Current Status
✅ Civilization layer toggle implemented and working
✅ Rendering logic for colored markers completed
✅ Controller tests passing (41 examples, 0 failures)
⚠️ **Not loading actual Earth data from JSON files yet**

## Problem
The civilization layer is rendering placeholder/empty data. We have curated JSON files with real Earth features that need to be loaded and displayed.

## Available Data Files

Location: `data/json-data/star_systems/sol/celestial_bodies/earth/geological_features/`

**Files with real data:**
1. `major_cities.json` - 25 major cities (Cairo, London, San Francisco, etc.)
2. `resource_hubs.json` - 12 resource hubs (Persian Gulf Oil, Siberian Coal, Chilean Copper, etc.)
3. `strategic_locations.json` - 15 strategic locations (Panama Canal, Suez Canal, Gibraltar, etc.)
4. `ancient_wonders.json` - 3 ancient wonders (Pyramids, Colosseum, Machu Picchu)
5. `canyons.json` - 4 major canyons (Grand Canyon, etc.)

**File format example:**
```json
{
  "celestial_body": "earth",
  "feature_type": "major_city",
  "tier": "strategic",
  "last_updated": "2026-02-07",
  "total_features": 25,
  "features": [
    {
      "id": "earth_city_001",
      "name": "New Cairo",
      "original_name": "Cairo",
      "feature_type": "major_city",
      "coordinates": {
        "latitude": 30.0444,
        "longitude": 31.2357,
        "system": "geographic"
      },
      "gameplay_data": {
        "settlement_bonus": ["river_trade", "cultural_center"],
        "starting_population": 1000000
      }
    }
  ]
}
```

## Implementation Required

### 1. Create Civilization Data Loader Service

**File:** `app/services/civilization/feature_loader.rb`

```ruby
module Civilization
  class FeatureLoader
    def initialize(celestial_body)
      @body = celestial_body
      @features_path = Rails.root.join('data', 'json-data', 'star_systems', 'sol', 
                                        'celestial_bodies', @body.name.downcase, 
                                        'geological_features')
    end
    
    def load_all_features
      {
        cities: load_feature_file('major_cities.json'),
        resource_hubs: load_feature_file('resource_hubs.json'),
        strategic_locations: load_feature_file('strategic_locations.json'),
        ancient_wonders: load_feature_file('ancient_wonders.json'),
        canyons: load_feature_file('canyons.json')
      }
    end
    
    private
    
    def load_feature_file(filename)
      file_path = @features_path.join(filename)
      
      return [] unless File.exist?(file_path)
      
      data = JSON.parse(File.read(file_path))
      features = data['features'] || []
      
      # Convert to format needed for monitor view
      features.map do |feature|
        convert_to_grid_coordinates(feature)
      end
    rescue => e
      Rails.logger.error "Error loading #{filename}: #{e.message}"
      []
    end
    
    def convert_to_grid_coordinates(feature)
      coords = feature['coordinates']
      
      # Convert lat/lon to grid coordinates
      # Assuming 1800x900 grid (equirectangular projection)
      # X = (lon + 180) * 5
      # Y = (90 - lat) * 5
      
      grid_x = ((coords['longitude'] + 180) * 5).round
      grid_y = ((90 - coords['latitude']) * 5).round
      
      {
        id: feature['id'],
        name: feature['name'],
        original_name: feature['original_name'] || feature['name'],
        type: feature['feature_type'],
        location: {
          grid_x: grid_x,
          grid_y: grid_y,
          latitude: coords['latitude'],
          longitude: coords['longitude']
        },
        population: feature.dig('gameplay_data', 'starting_population'),
        strategic_value: feature['strategic_value'] || [],
        gameplay_data: feature['gameplay_data'] || {}
      }
    end
  end
end
```

### 2. Update Controller to Load Real Data

**File:** `app/controllers/admin/celestial_bodies_controller.rb`

Add to the `monitor` action:

```ruby
def monitor
  @celestial_body = CelestialBodies::CelestialBody.find(params[:id])
  
  # Existing terrain data
  @terrain_map = @celestial_body.geosphere.terrain_map
  
  # Load civilization features from JSON files
  feature_loader = Civilization::FeatureLoader.new(@celestial_body)
  @civilization_features = feature_loader.load_all_features
  
  # Flatten for JavaScript (all features in one array with type)
  @all_features = [
    *@civilization_features[:cities].map { |f| f.merge(category: 'city') },
    *@civilization_features[:resource_hubs].map { |f| f.merge(category: 'resource_hub') },
    *@civilization_features[:strategic_locations].map { |f| f.merge(category: 'strategic_location') },
    *@civilization_features[:ancient_wonders].map { |f| f.merge(category: 'ancient_wonder') },
    *@civilization_features[:canyons].map { |f| f.merge(category: 'canyon') }
  ]
end
```

### 3. Update Monitor View to Use Real Data

**File:** `app/views/admin/celestial_bodies/monitor.html.erb`

Update the JavaScript section:

```javascript
// Load civilization features from controller
const civilizationFeatures = <%= raw @all_features.to_json %>;

console.log('Loaded civilization features:', civilizationFeatures.length);

// Render civilization layer
function renderCivilizationLayer(ctx, features, layerToggle) {
  if (!layerToggle || !features || features.length === 0) return;
  
  features.forEach(feature => {
    const x = feature.location.grid_x;
    const y = feature.location.grid_y;
    
    // Get color based on category
    const color = getFeatureColor(feature.category);
    const size = getFeatureSize(feature);
    
    // Draw marker
    ctx.fillStyle = color;
    ctx.beginPath();
    ctx.arc(x * scale, y * scale, size, 0, 2 * Math.PI);
    ctx.fill();
    
    // Draw outline for visibility
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 1;
    ctx.stroke();
    
    // Draw name if zoomed in enough
    if (scale > 2) {
      ctx.fillStyle = '#ffffff';
      ctx.font = '10px Arial';
      ctx.fillText(feature.name, x * scale + size + 2, y * scale + 3);
    }
  });
}

function getFeatureColor(category) {
  const colors = {
    'city': '#fbbf24',              // Gold/amber
    'resource_hub': '#84cc16',      // Lime green
    'strategic_location': '#ef4444', // Red
    'ancient_wonder': '#a855f7',     // Purple
    'canyon': '#0ea5e9'              // Sky blue
  };
  return colors[category] || '#ffffff';
}

function getFeatureSize(feature) {
  // Size based on type and importance
  if (feature.category === 'city') {
    const pop = feature.population || 100000;
    if (pop > 5000000) return 8;
    if (pop > 1000000) return 6;
    return 4;
  }
  
  if (feature.category === 'ancient_wonder') return 6;
  if (feature.category === 'strategic_location') return 5;
  if (feature.category === 'resource_hub') return 5;
  if (feature.category === 'canyon') return 4;
  
  return 4;
}
```

### 4. Add Click Handler for Feature Details

```javascript
// Add to canvas click handler
canvas.addEventListener('click', function(event) {
  if (!layers.civilization) return;
  
  const rect = canvas.getBoundingClientRect();
  const clickX = Math.floor((event.clientX - rect.left) / scale);
  const clickY = Math.floor((event.clientY - rect.top) / scale);
  
  // Find feature within 5 pixels
  const clicked = civilizationFeatures.find(f => {
    const dx = f.location.grid_x - clickX;
    const dy = f.location.grid_y - clickY;
    const distance = Math.sqrt(dx * dx + dy * dy);
    return distance < 5;
  });
  
  if (clicked) {
    showFeatureDetails(clicked);
  }
});

function showFeatureDetails(feature) {
  const detailsHtml = `
    <div class="feature-details">
      <h4>${feature.name}</h4>
      ${feature.original_name ? `<p><em>Originally: ${feature.original_name}</em></p>` : ''}
      <p><strong>Type:</strong> ${feature.category.replace('_', ' ')}</p>
      <p><strong>Location:</strong> ${feature.location.latitude.toFixed(2)}°, ${feature.location.longitude.toFixed(2)}°</p>
      ${feature.population ? `<p><strong>Population:</strong> ${feature.population.toLocaleString()}</p>` : ''}
      ${feature.strategic_value.length > 0 ? `<p><strong>Strategic Value:</strong> ${feature.strategic_value.join(', ')}</p>` : ''}
    </div>
  `;
  
  // Display in a modal or sidebar (implement as needed)
  console.log('Feature clicked:', feature);
  alert(detailsHtml.replace(/<[^>]*>/g, '\n')); // Temporary - replace with proper UI
}
```

### 5. Add Tests

**File:** `spec/services/civilization/feature_loader_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe Civilization::FeatureLoader do
  let(:earth) { create(:celestial_body, name: 'Earth') }
  let(:loader) { described_class.new(earth) }
  
  describe '#load_all_features' do
    it 'loads all feature types' do
      features = loader.load_all_features
      
      expect(features).to have_key(:cities)
      expect(features).to have_key(:resource_hubs)
      expect(features).to have_key(:strategic_locations)
      expect(features).to have_key(:ancient_wonders)
      expect(features).to have_key(:canyons)
    end
    
    it 'converts lat/lon to grid coordinates' do
      features = loader.load_all_features
      
      # Check that features have grid coordinates
      if features[:cities].any?
        city = features[:cities].first
        expect(city[:location]).to have_key(:grid_x)
        expect(city[:location]).to have_key(:grid_y)
        expect(city[:location][:grid_x]).to be_between(0, 1800)
        expect(city[:location][:grid_y]).to be_between(0, 900)
      end
    end
    
    it 'handles missing files gracefully' do
      mars = create(:celestial_body, name: 'Mars')
      mars_loader = described_class.new(mars)
      
      # Mars doesn't have these files yet
      features = mars_loader.load_all_features
      
      expect(features[:cities]).to eq([])
      expect(features[:resource_hubs]).to eq([])
    end
  end
end
```

## Expected Results

After implementation:

1. **Load Earth in monitor view**
2. **Toggle Civilization layer ON**
3. **Should see:**
   - 25 gold markers for major cities (Cairo, London, SF, etc.)
   - 12 green markers for resource hubs (Persian Gulf, Siberia, Chile, etc.)
   - 15 red markers for strategic locations (Panama, Suez, Gibraltar, etc.)
   - 3 purple markers for ancient wonders (Pyramids, Colosseum, Machu Picchu)
   - 4 blue markers for canyons (Grand Canyon, etc.)

4. **Markers should be at correct geographic locations**
   - Pyramids near Nile delta
   - London in UK
   - Panama in Central America
   - Grand Canyon in Arizona
   - etc.

5. **Click on marker → Shows feature details**

## Validation Steps

1. **Run tests:**
   ```bash
   bundle exec rspec spec/services/civilization/feature_loader_spec.rb
   bundle exec rspec spec/controllers/admin/celestial_bodies_controller_spec.rb
   ```

2. **Manual test:**
   - Navigate to Earth monitor view
   - Check browser console for "Loaded civilization features: 59" (25+12+15+3+4)
   - Toggle civilization layer ON
   - Verify markers appear at correct locations
   - Click markers to see details

3. **Verify coordinates:**
   - Pyramids should be near coordinates (30°N, 31°E) → grid ~(1056, 300)
   - London should be at (51.5°N, 0.1°W) → grid ~(899, 192)
   - Grand Canyon at (36°N, 112°W) → grid ~(340, 270)

## Success Criteria

- [ ] FeatureLoader service created and tested
- [ ] Controller loads real data from JSON files
- [ ] Monitor view renders 59 features for Earth
- [ ] Features appear at correct geographic locations
- [ ] Different feature types have different colors
- [ ] Click handler shows feature details
- [ ] All tests passing
- [ ] No console errors

## Time Estimate

- Service implementation: 1 hour
- Controller integration: 30 minutes
- View updates: 1 hour
- Tests: 1 hour
- Total: 3.5 hours

This completes the civilization layer with real Earth data! After this works for Earth, the same system can be extended to Mars, Luna, and other bodies once we extract their city/feature data from Civ4/FreeCiv maps.
