# Admin Monitoring Interface

## Overview

The Admin Monitoring Interface provides a comprehensive testing and monitoring environment for AI Manager operations, celestial body simulation, and game management. Built with a SimEarth-inspired aesthetic, it offers real-time data visualization and AI testing capabilities.

## Accessing the Interface

**URL Pattern**: `/admin/celestial_bodies/:id/monitor`

**Example**: `http://localhost:3000/admin/celestial_bodies/3/monitor`

Where `:id` is the ID of the celestial body you want to monitor.

## Features

### 1. Three-Panel Layout

#### Left Panel: AI Mission Control
- **AI Test Triggers**: Run AI Manager tests directly from the interface
  - Resource Extraction Test
  - Base Construction Test
  - ISRU Pipeline Test
- **Active Missions**: View currently running AI missions with progress bars
- **View Layers**: Toggle map visualization layers (terrain, water, biomes, features, temperature, resources)
- **Geological Features**: Quick reference to planetary geological features

#### Center Panel: Interactive Planetary Map
- **Real-time planet map visualization** with SimEarth-style interface
- **Layer-based rendering**: Toggle terrain, water, biomes, geological features, temperature, and resource overlays
- **Interactive features**: Click-to-inspect tiles and geological features with detailed information
- **Zoom controls**: Adjustable zoom level for detailed exploration
- **Geological markers**: Color-coded features (lava tubes, craters, strategic sites) with priority indicators
- **Coordinate display**: Latitude/longitude information for clicked locations

#### Right Panel: Sphere Data
- **Atmosphere**: Pressure, temperature, composition, total mass, habitability
- **Hydrosphere**: Water coverage, ocean mass, ice mass, average depth
- **Subsurface Hydrosphere**: Deep ocean composition and temperature
- **Cryosphere**: Ice shell type, thickness, and artificial status
- **Biosphere**: Biodiversity index, habitability ratio, life forms count
- **Geosphere**: Geological activity, tectonic status, volcanic activity

*Note: All sphere sections are always displayed. When a sphere does not exist on the celestial body, the section shows "Not Present" in orange text.*

### 2. Bottom Console Panel
- Real-time activity logging
- Color-coded messages (info: cyan, success: green, warning: yellow, error: red)
- Timestamp tracking
- Auto-scrolling with history limit (50 messages)

### 3. Real-Time Data Updates
- Automatic sphere data polling every 5 seconds
- Live progress bar updates for active missions
- Dynamic status indicators

## AI Manager Testing

### Test Types

#### 1. Resource Extraction Test
Tests AI Manager's ability to extract resources from celestial bodies using ISRU systems.

**Returns**:
```json
{
  "success": true,
  "test_type": "resource_extraction",
  "duration": "45 minutes",
  "resources_extracted": {
    "oxygen": 500,
    "water": 200,
    "regolith": 1000
  },
  "isru_efficiency": 0.85,
  "message": "Resource extraction test completed successfully"
}
```

#### 2. Base Construction Test
Tests AI Manager's ability to construct lunar/planetary bases using multi-mission pipeline.

**Returns**:
```json
{
  "success": true,
  "test_type": "base_construction",
  "phases_completed": 3,
  "total_phases": 5,
  "construction_time": "120 days",
  "settlement_gcc": 95000,
  "message": "Base construction test in progress - Phase 3/5 complete"
}
```

**Integrates with**: `multi_mission_lunar_base_pipeline.rake`

#### 3. ISRU Pipeline Test
Tests AI Manager's ability to run full ISRU-focused settlement operations.

**Returns**:
```json
{
  "success": true,
  "test_type": "isru_pipeline",
  "oxygen_produced": 10000,
  "water_produced": 5000,
  "fuel_produced": 2000,
  "earth_imports_reduced": 95,
  "message": "ISRU pipeline test completed - 95% Earth import reduction achieved"
}
```

**Integrates with**: `lunar_base:isru_focused` rake task

## API Endpoints

### GET `/admin/celestial_bodies/:id/monitor`
Main monitoring interface - renders the full admin view.

**Response**: HTML page

---

### GET `/admin/celestial_bodies/:id/sphere_data`
Retrieve real-time sphere data for a celestial body.

**Response**:
```json
{
  "atmosphere": {
    "pressure": 1.0,
    "temperature": 288.0,
    "total_mass": 5.1e18,
    "composition": {
      "N2": 78.08,
      "O2": 20.95,
      "Ar": 0.93,
      "CO2": 0.04
    },
    "scale_height": 8500.0,
    "habitable": true
  },
  "hydrosphere": {
    "water_coverage": 71.0,
    "ocean_mass": 1.4e21,
    "ice_mass": 2.6e19,
    "total_water": 1.426e21,
    "average_depth": 3688.0,
    "ice_coverage": 3.0
  },
  "geosphere": {
    "geological_activity": 75,
    "tectonic_active": true,
    "volcanic_activity": "moderate",
    "core_composition": {},
    "crust_composition": {},
    "magnetic_field": 0.5
  },
  "biosphere": {
    "biodiversity_index": 85.0,
    "habitable_ratio": 71.0,
    "life_forms_count": 8700000,
    "biomass": 5.5e11,
    "primary_producers": 375000
  },
  "planet_info": {
    "id": 3,
    "name": "Earth",
    "type": "CelestialBodies::Planets::Rocky::TerrestrialPlanet",
    "mass": 5.972e24,
    "radius": 6371000.0,
    "gravity": 9.807,
    "surface_temperature": 288.0,
    "orbital_period": 365.25
  }
}
```

---

### GET `/admin/celestial_bodies/:id/mission_log`
Retrieve AI mission activity log for a celestial body.

**Response**:
```json
{
  "missions": [
    {
      "id": 1,
      "type": "Resource Extraction",
      "status": "active",
      "start_time": "2026-01-13T12:00:00Z",
      "target_body": "Luna",
      "progress": 45,
      "messages": [
        {
          "time": "2026-01-13T12:00:00Z",
          "level": "info",
          "text": "Mission initialized"
        },
        {
          "time": "2026-01-13T13:00:00Z",
          "level": "success",
          "text": "ISRU systems deployed"
        }
      ]
    }
  ],
  "total_missions": 1,
  "active_missions": 1
}
```

---

### POST `/admin/celestial_bodies/:id/run_ai_test`
Trigger an AI Manager test mission.

**Parameters**:
- `test_type` (string, optional): Type of test to run
  - `resource_extraction` (default)
  - `base_construction`
  - `isru_pipeline`

**Example Request**:
```bash
curl -X POST http://localhost:3000/admin/celestial_bodies/4/run_ai_test \
  -H "Content-Type: application/json" \
  -d '{"test_type": "base_construction"}'
```

**Response**: See test type responses above

## Integration with Rake Tasks

The admin interface integrates with existing rake tasks for comprehensive testing:

### AI Manager Tests
```bash
# Extract test scenarios for AI training
rake ai_manager:extract_test_scenarios

# Validate AI patterns against game rules
rake ai_manager:validate_patterns

# Run Luna base build test
rake ai_manager:test_luna_base_build[5,true]

# Test wormhole expansion
rake ai_manager:test_wormhole_expansion[procedural,false]
```

### Multi-Mission Base Construction
```bash
# Run ISRU-focused pipeline
rake lunar_base:isru_focused

# Standard multi-mission pipeline
rake lunar_base:multi_mission
```

## Usage Workflow

### 1. Initial Setup
1. Ensure celestial body has required spheres initialized
2. Navigate to `/admin/celestial_bodies/:id/monitor`
3. Verify sphere data loads correctly in right panel

### 2. Running AI Tests
1. Select test type from AI Mission Control panel
2. Click corresponding test button
3. Monitor console for test progress
4. View results in console panel
5. Check updated mission status in Active Missions section

### 3. Monitoring Live Data
1. Data automatically updates every 5 seconds
2. Progress bars show biodiversity and habitability in real-time
3. Console logs all state changes and events
4. Click map tiles to inspect specific locations

### 4. Layer Visualization
1. Toggle layers in View Layers section
2. Active layers highlighted in green
3. Map updates to show selected data layers
4. Useful for analyzing terrain, water distribution, resources

## Technical Details

### Color Scheme (SimEarth Aesthetic)
- Background: `#000` (black)
- Secondary Background: `#1a1a1a`, `#16213e`
- Primary Text: `#0f0` (green)
- Accent Text: `#0ff` (cyan)
- Borders: `#0f0` (green)
- Console Info: `#0ff` (cyan)
- Console Success: `#0f0` (green)
- Console Warning: `#ff0` (yellow)
- Console Error: `#f00` (red)

### Font
- `'Courier New', monospace` - Terminal-style aesthetic

### Grid Layout
```css
grid-template-columns: 250px 1fr 300px;
grid-template-rows: 60px 1fr 200px;
```

- Left: 250px (Mission Control)
- Center: Flexible (Map Canvas)
- Right: 300px (Sphere Data)
- Top: 60px (Header)
- Bottom: 200px (Console)

### Data Polling
- Interval: 5000ms (5 seconds)
- Endpoint: `/admin/celestial_bodies/:id/sphere_data`
- Automatic cleanup on page unload

## Testing the Interface

### RSpec Tests
Run the admin controller specs:

```bash
# In Docker container
docker-compose -f docker-compose.dev.yml exec web bundle exec rspec spec/controllers/admin/celestial_bodies_controller_spec.rb

# Or from host (runs in container)
cd galaxy_game
docker-compose -f docker-compose.dev.yml exec web bundle exec rspec spec/controllers/admin/
```

### Manual Testing Checklist
- [ ] Navigate to admin monitor page
- [ ] Verify sphere data displays correctly
- [ ] Toggle view layers - check map updates
- [ ] Run resource extraction test - verify console output
- [ ] Run base construction test - check progress updates
- [ ] Run ISRU pipeline test - verify results
- [ ] Check real-time data polling (wait 5-10 seconds)
- [ ] Inspect mission list updates
- [ ] Verify console auto-scroll and message limit

## Future Enhancements

### Planned Features
1. **Live AI Mission Tracking**: Real AI Manager mission integration
2. **Historical Data Charts**: Visualize sphere data over time
3. **Mission Comparison**: Compare multiple test runs
4. **Automated Test Suites**: Schedule and run batch tests
5. **Export Functionality**: Export test results to JSON/CSV
6. **WebSocket Integration**: Real-time updates without polling
7. **Multi-Planet Monitoring**: Monitor multiple celestial bodies simultaneously
8. **Performance Metrics**: Track AI decision speed, efficiency, success rates
9. **Scenario Editor**: Create custom AI test scenarios
10. **Integration with Terra Sim**: Real-time planetary simulation updates

### Integration Points
- **AI Manager Service**: Direct integration when AI Manager is fully implemented
- **PlanetMap System**: Enhanced map rendering with geological features
- **Terra Sim**: Live planetary physics simulation
- **Mission System**: Real mission tracking and management
- **Settlement System**: Monitor actual settlement construction progress

## Troubleshooting

### Issue: Data not updating
**Solution**: Check browser console for JavaScript errors. Verify `/admin/celestial_bodies/:id/sphere_data` endpoint returns valid JSON.

### Issue: Map not displaying
**Solution**: Ensure `PlanetMap` model exists for the celestial body. Run map generation if needed.

### Issue: Tests not running
**Solution**: Verify CSRF token is present. Check Rails logs for controller errors.

### Issue: Styling broken
**Solution**: Ensure `admin/monitor.css` is loaded. Check asset pipeline configuration.

## Security Considerations

**Note**: This is an admin interface for testing and development. In production:
1. Add authentication (e.g., Devise, custom auth)
2. Add authorization (e.g., ensure only admins can access)
3. Rate limit AI test endpoints
4. Log all admin actions
5. Restrict to internal IP ranges if possible

Example authentication (add to controller):
```ruby
before_action :authenticate_admin!

def authenticate_admin!
  # Implement your authentication logic
  redirect_to root_path unless current_user&.admin?
end
```

## Related Documentation
- [AI Manager System](ai_manager/README.md)
- [Multi-Mission Lunar Base Pipeline](../developer/multi_mission_pipeline.md)
- [PlanetMap System](../developer/planet_map_system.md)
- [Geological Features Lookup Service](../developer/geological_features.md)
