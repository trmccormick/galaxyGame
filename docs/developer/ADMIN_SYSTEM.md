# Admin Monitoring System

## Overview

The Admin Monitoring System provides real-time monitoring and control interfaces for game systems using a SimEarth-inspired aesthetic. Built with a modular architecture, each admin section focuses on specific game subsystems.

## Architecture

### Design Pattern

All admin interfaces follow a consistent three-panel layout:
- **Left Panel (250px)**: Navigation, filters, or control lists
- **Main Panel (flex 1fr)**: Primary data display with data tables or visualizations
- **Right Panel (300px)**: Activity logs, console output, or statistics

### Visual Style (SimEarth Aesthetic)

```css
Background: #000 (black)
Text: #0f0 (green terminal)
Accent: #0ff (cyan)
Font: Courier New, monospace
Headers: 80px height, border-bottom: 2px solid #0f0
```

## Sections

### 1. AI Manager (`/admin/ai_manager`)

#### Mission Tracker (`/admin/ai_manager/missions`)

Monitors active AI missions with TaskExecutionEngine integration.

**Features:**
- Mission list separated by status (active/completed/failed)
- Progress tracking with percentage bars
- Real-time mission statistics
- Activity log console

**Controller:** `Admin::AiManagerController#missions`

```ruby
# Loads all missions with status separation
@missions = Mission.includes(:settlement).order(created_at: :desc)
@active_missions = @missions.where(status: [:in_progress])
@completed_missions = @missions.where(status: [:completed])
@failed_missions = @missions.where(status: [:failed, :stalled])
```

#### Mission Detail (`/admin/ai_manager/missions/:id`)

Displays detailed task breakdown for a specific mission.

**Features:**
- Complete task list with current/completed/pending indicators
- Task details: type, resource requirements, quantities, dependencies
- Mission controls: Advance Phase, Reset Mission
- Execution console with operational data
- Manifest data display (target location, objectives)

**Controller:** `Admin::AiManagerController#show_mission`

```ruby
# Integrates with TaskExecutionEngine
@engine = ::AIManager::TaskExecutionEngine.new(@mission.identifier)
@task_list = @engine.instance_variable_get(:@task_list)
@current_task_index = @engine.instance_variable_get(:@current_task_index)
@manifest = @engine.instance_variable_get(:@manifest)
```

**Testing Controls:**
- `POST /admin/ai_manager/advance_phase/:id` - Execute next task in mission
- `POST /admin/ai_manager/reset_mission/:id` - Reset mission to beginning

#### Mission Planner (`/admin/ai_manager/planner`)

What-if mission planning simulator with economic forecasting.

**Features:**
- **Configuration Panel**: Select mission pattern, tech level, timeline, budget, priority
- **Simulation Results**: Timeline breakdown, cost analysis, resource requirements, planetary changes
- **Economic Forecast**: GCC distribution analysis, demand forecasting, bottleneck identification, opportunity identification
- **Export Functionality**: Download complete simulation plan as JSON
- **Three-Panel Layout**: Config | Results | Forecast

**Controller:** `Admin::AiManagerController#planner`

```ruby
# Run simulation with parameters
@planner = AIManager::MissionPlannerService.new(
  params[:pattern],
  {
    tech_level: params[:tech_level] || 'standard',
    timeline_years: params[:timeline_years]&.to_i || 10,
    budget_gcc: params[:budget_gcc]&.to_i || 1_000_000,
    priority: params[:priority] || 'balanced'
  }
)

@simulation_result = @planner.simulate
@forecaster = AIManager::EconomicForecasterService.new(@simulation_result)
@forecast = @forecaster.analyze
```

**Available Mission Patterns:**
- `mars-terraforming` - Long-term atmospheric transformation
- `venus-industrial` - Cloud layer resource extraction
- `titan-fuel` - Methane harvesting and refining
- `asteroid-mining` - Resource extraction operations
- `europa-water` - Ice mining and water processing

**Simulation Results Include:**
- **Timeline**: Total duration, phase breakdown, key milestones
- **Costs**: Base cost, contingency (15%), grand total
- **Player Revenue**: Total contract opportunities, estimated contract count, average value
- **Resources**: Year-by-year requirements, peak demand period, total quantities
- **Planetary Changes**: Pattern-specific environmental changes

**Economic Forecast Provides:**
- **GCC Distribution**: DC vs player earnings, economic velocity (GCC/year)
- **Demand Forecast**: Resource trend (increasing/steady/declining), critical resources
- **Bottlenecks**: Resource spikes, concentrated demand periods with severity levels
- **Opportunities**: High-revenue years, bulk discount opportunities
- **Risk Assessment**: Financial (contingency), schedule (timeline), logistics (demand spikes)

**Export Action:**
- `POST /admin/ai_manager/export_plan` - Download JSON with full simulation data
- Includes pattern, parameters, results, timestamp, version

**Services:**
- `AIManager::MissionPlannerService` - Runs accelerated simulations
- `AIManager::EconomicForecasterService` - Analyzes economic implications

#### Decision Log (`/admin/ai_manager/decisions`)

Tracks AI decision-making processes and operational choices.

**Features:**
- Real-time decision log with filtering by type
- Decision outcomes (success/failure/pending)
- Decision categories: Resource Allocation, Contract Negotiation, Mission Planning, Settlement Ops
- Statistics dashboard with success rates and response times
- Auto-refresh capability for live monitoring

**Controller:** `Admin::AiManagerController#decisions`

```ruby
# Decision tracking (currently stub implementation)
@decisions = []
```

#### Pattern Library (`/admin/ai_manager/patterns`)

Mission pattern testing and management interface.

**Features:**
- Pattern library with activation/deactivation controls
- Testing interface for pattern validation
- Pattern metadata: target bodies, complexity, success rates
- Configuration testing with tech level and budget parameters
- Pattern status indicators (active/inactive)

**Controller:** `Admin::AiManagerController#patterns`

```ruby
# Pattern management (currently stub implementation)
@patterns = []
```

#### Performance Metrics (`/admin/ai_manager/performance`)

AI system performance monitoring and optimization controls.

**Features:**
- Key performance indicators: Success rate, timeline efficiency, resource utilization
- System health monitoring with status indicators
- Performance controls: Decision timeouts, concurrent mission limits, resource thresholds
- Mission performance table with detailed breakdowns
- Trend analysis and bottleneck identification

**Controller:** `Admin::AiManagerController#performance`

```ruby
# Performance metrics (currently stub implementation)
@metrics = {
  success_rate: 0,
  average_timeline: 0,
  resource_efficiency: 0
}
```

### 1.5. AI Map Generation Studio (`/admin/map_studio`)

AI-powered planetary map generation studio for creating procedural terrain maps from FreeCiv/Civ4 sources.

#### Overview

The Map Studio provides an integrated interface for generating planetary maps using AI analysis of existing map sources. It combines FreeCiv terrain maps with Civ4 biome data to create comprehensive planetary terrain representations.

**Key Features:**
- **AI-Powered Generation**: Uses `AIManager::PlanetaryMapGenerator` for intelligent map synthesis
- **Multi-Source Integration**: Combines terrain, water, and biome data from multiple map formats
- **Real-time Preview**: Interactive map visualization with FreeCiv-style rendering
- **Batch Processing**: Generate maps for multiple celestial bodies simultaneously
- **Quality Analysis**: Automated map quality assessment and statistics
- **Export Capabilities**: Save generated maps in JSON format for game integration

#### Generate (`/admin/map_studio/generate`)

Main map generation interface with planet selection and parameter configuration.

**Features:**
- **Planet Selection**: Dropdown of all available celestial bodies with type indicators
- **Source Map Browser**: Interactive selection of FreeCiv/Civ4 map files from data directories
- **Generation Parameters**: Map name, size settings, quality options
- **Real-time Validation**: Immediate feedback on parameter combinations
- **Generation Progress**: Live progress tracking during AI processing

**Controller:** `Admin::MapStudioController#generate`

```ruby
# Load available planets and source maps
@target_planets = CelestialBodies::CelestialBody.order(:name)
@available_source_maps = GalaxyGame::Paths.list_source_maps
@recent_generations = find_recent_generations
```

**Generation Process:**
1. **Planet Selection**: Choose target celestial body for map generation
2. **Source Selection**: Select FreeCiv terrain maps and Civ4 biome maps
3. **Parameter Configuration**: Set map name and generation options
4. **AI Processing**: `AIManager::PlanetaryMapGenerator` analyzes sources and creates procedural map
5. **Quality Validation**: Automated checks for map completeness and terrain distribution
6. **Storage**: Map saved to `GalaxyGame::Paths.generated_maps_path` as JSON

#### Browse (`/admin/map_studio/browse`)

Generated maps catalog with filtering, sorting, and management tools.

**Features:**
- **Map Gallery**: Thumbnail grid view of all generated maps
- **Filtering Options**: By planet type, generation date, quality score
- **Statistics Dashboard**: Generation counts, success rates, storage usage
- **Map Management**: Delete, rename, export operations
- **Quality Metrics**: Terrain distribution, feature counts, validation scores

**Controller:** `Admin::MapStudioController#browse`

```ruby
# Load and organize generated maps
@generated_maps = find_generated_maps.group_by { |m| m[:planet_type] }
@map_stats = calculate_map_stats
```

**Map Statistics Include:**
- **Generation Count**: Total maps, maps by planet type
- **Storage Usage**: File sizes, disk space consumption
- **Quality Scores**: Average quality, quality distribution
- **Recent Activity**: Last 24 hours generation count

#### Analyze (`/admin/map_studio/analyze/:id`)

Detailed map analysis and quality assessment interface.

**Features:**
- **Terrain Analysis**: Distribution of terrain types, elevation ranges
- **Feature Mapping**: Rivers, mountains, forests, cities location analysis
- **Quality Metrics**: Completeness score, terrain balance, feature density
- **Visualization**: Interactive map viewer with zoom and layer controls
- **Export Options**: Download analysis data, map images, or raw JSON

**Controller:** `Admin::MapStudioController#analyze`

```ruby
# Load map and perform analysis
@map = load_generated_map(params[:id])
@analysis = analyze_map_quality(@map)
@terrain_stats = calculate_terrain_statistics(@map)
```

#### Apply Map (`/admin/map_studio/apply_map/:id`)

Apply generated map to celestial body geosphere for game integration.

**Features:**
- **Validation Checks**: Ensure map compatibility with target planet
- **Geosphere Integration**: Update `CelestialBodies::Spheres::Geosphere#terrain_map`
- **Backup Creation**: Automatic backup of existing terrain data
- **Rollback Support**: Ability to revert map application
- **Integration Testing**: Validate map works with game systems

**Controller:** `Admin::MapStudioController#apply_map`

```ruby
# Apply map to celestial body
@map = load_generated_map(params[:id])
@planet = CelestialBodies::CelestialBody.find(@map[:planet_id])

# Update geosphere with new terrain map
@planet.geosphere.update!(terrain_map: @map[:data])
```

**Integration Process:**
1. **Compatibility Check**: Validate map dimensions and data structure
2. **Backup Creation**: Save current terrain_map to backup location
3. **Geosphere Update**: Apply new terrain data to planet's geosphere
4. **Validation**: Run integration tests to ensure map works in game
5. **Notification**: Alert admin of successful application

#### Technical Implementation

**AI Map Generator (`AIManager::PlanetaryMapGenerator`):**
```ruby
class AIManager::PlanetaryMapGenerator
  def generate_planetary_map(planet:, sources:, options: {})
    # Analyze source maps
    terrain_data = extract_terrain_from_sources(sources)
    biome_data = extract_biomes_from_sources(sources)
    
    # AI synthesis
    synthesized_map = ai_synthesis(terrain_data, biome_data, planet)
    
    # Quality validation
    quality_score = validate_map_quality(synthesized_map)
    
    # Return structured map data
    {
      filename: "#{planet.name.downcase}_#{Time.now.to_i}.json",
      data: synthesized_map,
      quality_score: quality_score,
      metadata: {
        planet_id: planet.id,
        sources_used: sources.map(&:filename),
        generation_time: Time.now
      }
    }
  end
end
```

**Map Data Structure:**
```json
{
  "planet_id": 123,
  "terrain_grid": [
    ["t", "f", "g", "h", "m"],
    ["t", "f", "g", "d", "m"],
    ...
  ],
  "biome_overlay": {
    "forests": [[10, 15], [12, 16]],
    "mountains": [[5, 8], [7, 9]],
    "rivers": [{"start": [0, 10], "end": [20, 10]}]
  },
  "metadata": {
    "size": "180x90",
    "quality_score": 0.95,
    "generation_timestamp": "2024-01-15T10:30:00Z"
  }
}
```

**File Organization:**
- **Source Maps**: `data/freeCiv Maps/`, `data/freeCiv\ Maps/`
- **Generated Maps**: `data/generated_maps/` (auto-created)
- **Map Backups**: `data/map_backups/` (for rollback support)

**Dependencies:**
- `GalaxyGame::Paths` - Path management for map files
- `AIManager::PlanetaryMapGenerator` - Core AI generation service
- `CelestialBodies::CelestialBody` - Target planet data
- `CelestialBodies::Spheres::Geosphere` - Terrain map storage

### 2. Celestial Bodies (`/admin/celestial_bodies`)

**Data Source**: Celestial bodies are created from authoritative data sources (JSON data files, StarSim generation) and cannot be manually created through the admin interface. The admin interface provides monitoring and limited metadata editing capabilities only.

#### Index (`/admin/celestial_bodies`)

Global celestial body catalog showing all bodies in the game database for monitoring selection.

**Features:**
- Complete celestial body catalog with comprehensive type classification
- Statistics dashboard showing counts for all major categories (Stars, Planets, Moons, Minor Bodies, Other)
- Grouped display by celestial body category (star, planet types, moon types, minor bodies, etc.)
- Direct links to individual body monitors
- Body details: mass, radius, temperature, atmosphere status

**Controller:** `Admin::CelestialBodiesController#index`

```ruby
# Load ALL celestial bodies from the game database for monitoring selection
@celestial_bodies = CelestialBodies::CelestialBody.all.order(:name)
@total_bodies = @celestial_bodies.count
@bodies_by_category = @celestial_bodies.group_by(&:body_category)

# Calculate statistics for major categories
@category_stats = {
  stars: @bodies_by_category['star']&.count || 0,
  brown_dwarfs: @bodies_by_category['brown_dwarf']&.count || 0,
  planets: count_planet_types,  # terrestrial, gas giants, ice giants, etc.
  moons: count_moon_types,      # various moon types
  minor_bodies: count_minor_body_types,  # asteroids, comets, etc.
  other: count_other_types      # alien life forms, materials
}
```

**Supported Celestial Body Categories:**
- **Stars**: Main sequence stars, brown dwarfs
- **Planets**: Terrestrial planets, gas giants, ice giants, carbon planets, lava worlds, super earths, ocean planets, etc.
- **Moons/Satellites**: Various moon types (large, small, ice moons)
- **Minor Bodies**: Asteroids, comets, dwarf planets, Kuiper belt objects
- **Other**: Alien life forms, materials

#### Monitor (`/admin/celestial_bodies/:id/monitor`)

Real-time planetary monitoring with sphere-based data visualization and terrain rendering.

**Features:**
- Live planetary sphere data (atmosphere, hydrosphere, geosphere, biosphere)
- Interactive terrain map with FreeCiv-style rendering (180x90 grid, 8px tiles)
- Data-driven atmospheric rendering based on planetary conditions (temperature, pressure, composition)
- Planet-specific visual effects (Mars red tint, Venus volcanic haze)
- Layer toggles for terrain, water, biomes, temperature, rainfall, and resources
- AI mission log for planet-specific missions
- AI testing console with predefined test scenarios
- Geological features tracking

**Controller:** `Admin::CelestialBodiesController#monitor`

**Terrain Rendering System:**
- **Canvas Size**: 180x90 grid with 8px tiles (1440x720px total)
- **Atmospheric Analysis**: JavaScript functions analyze planetary temperature, pressure, and composition for realistic rendering
- **Planet-Specific Rendering**: Conditional logic for Mars (red-tinted terrain), Venus (volcanic colors), and generic planets
- **Climate Calculations**: TerraSim-style temperature/pressure analysis for ice coverage and habitable zones
- **Desert Coloring**: Latitude-based temperature variation (yellow near equator, beige near poles)
- **Layer System**: Toggle-able overlays for different terrain aspects
- **Data Source**: PostgreSQL JSONB terrain data from FreeCiv SAV file imports
- **Terrain Code Mapping**: FreeCiv single-character terrain codes ('a', 't', 'f', 'g', etc.) are mapped to full terrain type names for proper color rendering
- **Multi-Map Layer Extraction**: FreeCiv maps for terrain/water, Civ4 maps for biomes/resources

**Multi-Map Layer Extraction System:**
- **FreeCiv Maps**: Used for terrain and water layer extraction (physical geography)
- **Civ4 Maps**: Used for biome and resource layer extraction (ecological/climatic features)
- **Layer Separation**: Terrain (bare earth), Water (hydrosphere), Biomes (biosphere), Resources (geological)
- **Automatic Processing**: Maps are automatically processed to extract relevant layers
- **Fallback Support**: Single map sources work with appropriate layer extraction

**Atmospheric Condition Analysis:**
- **Temperature**: Retrieved from `celestial_body.temperature` (surface temperature with fallbacks)
- **Pressure**: Retrieved from `celestial_body.pressure` (atmospheric pressure with fallbacks)
- **Composition**: Retrieved from `celestial_body.atmosphere_composition` (gas ratios and concentrations)
- **analyzeAtmosphericConditions()**: JavaScript function that analyzes temperature, pressure, and composition to determine:
  - Atmospheric presence (>0.01 bar pressure threshold)
  - Planetary habitability (oxygen levels 19.5-23.5% in nitrogen atmosphere)
  - Dominant gas identification (CO2, N2, O2, CH4, etc.)
  - Visual effects (haze levels, color tinting, aurora potential)
- **Elevation Calculation**: Dynamic terrain elevation based on biome type, latitude, and planetary conditions
- **Color Blending**: Multi-layer color application with opacity controls for realistic atmospheric effects

- **Terrain Layer**: Shows bare topographic colors (browns, grays, tans) representing physical terrain types, not biomes or vegetation
- **Biome Layer**: Separate overlay showing vegetation/climate zones (green grasslands, white arctic, etc.)
- **Water Layer**: Ocean and freshwater visualization
- **Temperature Layer**: Thermal visualization overlay
- **Rainfall Layer**: Precipitation pattern overlay
- **Resources Layer**: Mineral deposit highlighting

**Terrain Color Mapping (Bare Earth):**
- **Ocean**: Blue (`#0066cc`) - Water bodies
- **Deep Sea**: Dark blue (`#003366`) - Ocean trenches
- **Arctic**: Light gray (`#e8e8e8`) - Ice/snow surface
- **Tundra**: Medium gray (`#b8b8b8`) - Permafrost/gravel
- **Grasslands**: Brown (`#8b7355`) - Soil/dirt
- **Plains**: Tan (`#a08050`) - Dry plains
- **Forest**: Dark brown (`#654321`) - Tree trunks/soil
- **Jungle**: Very dark brown (`#4a3c28`) - Dense vegetation soil
- **Desert**: Sandy brown (`#c4a484`) - Sand/dunes
- **Mountains**: Dim gray (`#696969`) - Rock
- **Rock**: Gray (`#808080`) - Bare rock
- **Boreal**: Brown (`#8b7355`) - Coniferous forest soil
- **Swamp**: Dark brown (`#654321`) - Wet soil/mud

**Layer System:**

**Data Endpoints:**
- `GET /admin/celestial_bodies/:id/sphere_data.json` - Live sphere metrics
- `GET /admin/celestial_bodies/:id/mission_log.json` - Mission activity
- `POST /admin/celestial_bodies/:id/run_ai_test` - Execute AI tests

**AI Test Types:**
- `resource_extraction` - Test resource gathering capabilities
- `base_construction` - Test base building procedures
- `isru_pipeline` - Test in-situ resource utilization

#### Edit (`/admin/celestial_bodies/:id/edit`)

Admin-only interface for editing celestial body names and aliases, plus terrain import capabilities.

**Features:**
- Name editing with validation
- Alias management (add/remove alternative names)
- FreeCiv SAV file import for terraformed terrain
- Civ4 WBS file import for elevation-based terrain
- Clear warnings about protected properties
- Restricted to admin users only

**Controller:** `Admin::CelestialBodiesController#edit`, `Admin::CelestialBodiesController#update`

**Permitted Parameters:**
- `name` - Primary celestial body name
- `aliases` - Array of alternative names

**Terrain Import Features:**

**FreeCiv Import:**
- Upload FreeCiv SAV files containing terraformed terrain
- Generates barren terrain for gameplay with terraformed areas as target zones
- Route: `POST /admin/celestial_bodies/:id/import_freeciv_for_body`
- Controller: `Admin::CelestialBodiesController#import_freeciv_for_body`

**Civ4 Import:**
- Upload Civ4 World Builder Save (WBS) files
- Imports dual terrain system (elevation + biome) for realistic planetary generation
- Supports .Civ4WorldBuilderSave, .CivBeyondSwordWBSave, .CivWarlordsWBSave formats
- Route: `POST /admin/celestial_bodies/:id/import_civ4_for_body`
- Controller: `Admin::CelestialBodiesController#import_civ4_for_body`

**Services Used:**
- `Import::FreecivSavImportService` - Parses FreeCiv SAV files
- `Import::FreecivToGalaxyConverter` - Converts FreeCiv data to Galaxy format
- `Import::Civ4WbsImportService` - Parses Civ4 WBS files
- `Import::Civ4ToGalaxyConverter` - Converts Civ4 data to Galaxy format

**Protected Properties:**
All physical and astronomical properties (mass, radius, temperature, atmosphere, etc.) are read-only and sourced from authoritative data (JSON/StarSim generation). Only metadata (names/aliases) and terrain data can be edited through this interface.

### 3. Solar Systems (`/admin/solar_systems`)

#### Index (`/admin/solar_systems`)

Hierarchical solar system catalog organized by galaxy membership.

**Features:**
- Complete solar system catalog grouped by galaxy
- Statistics dashboard: total systems, systems with stars, habitable systems, average bodies per system
- Galaxy-based organization with separate section for ungrouped systems
- System details: star count, body count, central star information
- Links to individual system detail views and public solar system views

**Controller:** `Admin::SolarSystemsController#index`

```ruby
# Load solar systems with galaxy associations
@solar_systems = SolarSystem.includes(:galaxy, :stars, :celestial_bodies)
                           .order('galaxies.name, solar_systems.name')
                           .limit(100)

@galaxies = Galaxy.includes(:solar_systems).order(:name)

@system_stats = calculate_system_stats
```

**System Statistics:**
- **Total Systems**: Count of all solar systems
- **Systems with Stars**: Systems containing at least one star
- **Habitable Systems**: Systems with terrestrial planets in habitable temperature range
- **Average Bodies/System**: Mean celestial bodies per solar system

#### Show (`/admin/solar_systems/:id`)

Detailed solar system monitoring and celestial body overview.

**Features:**
- System header with galaxy context and creation metadata
- Central star information (if present): type, temperature, luminosity, age
- Complete celestial body listing with physical properties
- Navigation links to galaxy view and public solar system interface
- Body classification statistics (terrestrial planets, gas giants, etc.)

**Controller:** `Admin::SolarSystemsController#show`

```ruby
# Load system with full associations
@solar_system = SolarSystem.includes(:galaxy, :stars, :celestial_bodies)
                          .find(params[:id])

@celestial_bodies = @solar_system.celestial_bodies
                                .includes(:atmosphere)
                                .order(:name)
```

## Public Solar Systems Interface

The public solar systems interface provides read-only access to solar system information for players.

**Routes:** `resources :solar_systems, only: [:index, :show]`
**Controller:** `SolarSystemsController`
**Views:** Interactive solar system visualization with celestial body details

**Controller Implementation:**

```ruby
class SolarSystemsController < ApplicationController
  def index
    @solar_systems = SolarSystem.includes(:stars, :celestial_bodies).order(:name)
  end

  def show
    @solar_system = SolarSystem.includes(:galaxy, :stars, :celestial_bodies).find(params[:id])
    @celestial_bodies = @solar_system.celestial_bodies.includes(:atmosphere).order(:name) if @solar_system
  end
end
```

**View Features:**
- Interactive canvas-based solar system visualization with orbital mechanics
- Celestial body data passed as JSON with parent_body relationships for satellites
- Safe handling of missing body_type properties with fallback to class name
- Three-panel SimEarth aesthetic layout matching admin interface
- Left navigation panel with system links and admin shortcuts
- Center canvas visualization with system statistics header
- Right details panel with comprehensive star information and celestial bodies table

### 4. Galaxies (`/admin/galaxies`)

#### Index (`/admin/galaxies`)

Galaxy overview with type distribution and system counts.

**Features:**
- Complete galaxy catalog with type classification
- Statistics dashboard: total galaxies, total systems, average systems per galaxy
- Galaxy type breakdown visualization
- Individual galaxy cards with system counts and mass information
- Links to detailed galaxy views

**Controller:** `Admin::GalaxiesController#index`

```ruby
# Load all galaxies with system counts
@galaxies = Galaxy.includes(:solar_systems)
                  .order(:name)

@galaxy_stats = calculate_galaxy_stats
```

**Galaxy Statistics:**
- **Total Galaxies**: Count of all galaxies
- **Total Systems**: Sum of all solar systems across galaxies
- **Avg Systems/Galaxy**: Mean solar systems per galaxy
- **Type Breakdown**: Count by galaxy type (spiral, elliptical, irregular, etc.)

#### Show (`/admin/galaxies/:id`)

Galaxy detail view with complete solar system listing.

**Features:**
- Galaxy header with type, mass, and creation metadata
- Complete solar system listing within the galaxy
- System details: star count, body count, central star information
- Navigation links to individual system views
- Galaxy-wide statistics and system distribution

**Controller:** `Admin::GalaxiesController#show`

```ruby
# Load galaxy with all systems and their details
@galaxy = Galaxy.includes(solar_systems: [:stars, :celestial_bodies])
                .find(params[:id])

@solar_systems = @galaxy.solar_systems
                        .includes(:stars, :celestial_bodies)
                        .order(:name)
```

### 5. Organization Monitor (`/admin/organizations`)

Monitor all organizations in the game universe with proper separation by ownership type.

**Features:**
- **NPC Organizations**: AI-controlled corporations and development entities
- **Player Organizations**: Player-owned corporations and enterprises  
- **Consortiums**: Multi-corporate alliances and collaborative entities (separate from individual organizations)
- Display GCC balances for each organization
- Track active logistics contracts count
- Link to celestial body monitor for each organization base
- Statistics panel: total NPCs, players, consortiums
- Production capabilities tracking (structures and units)

**Controller:** `Admin::OrganizationsController#index`

```ruby
# Load NPC Organizations (Development Corps + NPC Service Corps)
@npc_organizations = Organizations::BaseOrganization
  .where(organization_type: [:development_corporation, :corporation])
  .includes(:accounts)
  .select(&:is_npc?)
  .sort_by(&:name)

# Load Player Organizations (Player-owned corporations only)
@player_organizations = Organizations::BaseOrganization
  .where(organization_type: :corporation)
  .includes(:accounts)
  .reject(&:is_npc?)
  .sort_by(&:name)

# Load Consortiums (separate alliance-like entities)
@consortiums = Organizations::BaseOrganization
  .where(organization_type: :consortium)
  .includes(:accounts)
  .order(:name)
```

**Organization Types:**
- **NPC Organizations**: `organization_type` in `[:development_corporation, :corporation]` where `is_npc?` returns true
- **Player Organizations**: `organization_type: :corporation` where `is_npc?` returns false
- **Consortiums**: `organization_type: :consortium` (can include both NPC and player member corporations)

**Organization Cards Display:**
- Organization name and identifier
- GCC balance with human-readable format (K/M/B)
- Settlement count and list
- Active contracts count
- Settlement locations with celestial body links
- [MONITOR] links to celestial body monitor views

### 4. Settlements (`/admin/settlements`)

Settlement status and resource monitoring (stub).

**Controller:** `Admin::SettlementsController`

### 5. Resources (`/admin/resources`)

#### Index (`/admin/resources`)

Resource management overview and navigation hub.

**Features:**
- Navigation to resource flows, supply chains, and market analysis
- System status indicators for resource management components
- Quick access to all resource monitoring tools

**Controller:** `Admin::ResourcesController#index`

```ruby
# Resource management sections navigation
@sections = [
  { name: 'Resource Flows', path: admin_resource_flows_path, description: 'Monitor resource movement and distribution' },
  { name: 'Supply Chains', path: admin_resource_supply_chains_path, description: 'Track supply chain networks and dependencies' },
  { name: 'Market & Economy', path: admin_resource_market_path, description: 'View market data, pricing, and economic indicators' }
]
```

#### Resource Flows (`/admin/resources/flows`)

Track resource flows and economic chains (stub).

**Controller:** `Admin::ResourcesController#flows`

#### Supply Chains (`/admin/resources/supply_chains`)

Supply chain analysis and dependency tracking (stub).

**Controller:** `Admin::ResourcesController#supply_chains`

#### Market (`/admin/resources/market`)

Market data and economic indicators (stub).

**Controller:** `Admin::ResourcesController#market`

### 6. Simulation (`/admin/simulation`)

Central simulation control and status monitoring (stub).

**Controller:** `Admin::SimulationController`

## Routes

```ruby
namespace :admin do
  # Dashboard
  get 'dashboard', to: 'dashboard#index'
  
  # AI Manager
  get 'ai_manager/missions', to: 'ai_manager#missions', as: 'ai_manager_missions'
  get 'ai_manager/missions/:id', to: 'ai_manager#show_mission', as: 'ai_manager_mission'
  post 'ai_manager/advance_phase/:id', to: 'ai_manager#advance_phase', as: 'ai_manager_advance_phase'
  post 'ai_manager/reset_mission/:id', to: 'ai_manager#reset_mission', as: 'ai_manager_reset_mission'
  get 'ai_manager/planner', to: 'ai_manager#planner', as: 'ai_manager_planner'
  post 'ai_manager/export_plan', to: 'ai_manager#export_plan', as: 'ai_manager_export_plan'
  
  # Celestial Bodies
  resources :celestial_bodies, only: [] do
    member do
      get :monitor
      get :sphere_data
      get :mission_log
      post :run_ai_test
    end
  end
  
  # Solar Systems
  resources :solar_systems, only: [:index, :show]
  
  # Galaxies
  resources :galaxies, only: [:index, :show]
  
  # Other sections (stub controllers)
  resources :organizations, only: [:index]
  resources :settlements, only: [:index]
  resources :resources, only: [] do
    collection do
      get :flows
    end
  end
  resources :simulation, only: [:index]
end
```

## Testing

All admin controllers have comprehensive RSpec coverage.

### Running Tests

```bash
# All admin controller tests
docker-compose exec web bundle exec rspec spec/controllers/admin/

# Specific controller
docker-compose exec web bundle exec rspec spec/controllers/admin/ai_manager_controller_spec.rb
```

### Test Coverage

- **AI Manager Controller**: 11 examples
  - Mission loading and status separation
  - Mission detail view with TaskExecutionEngine integration
  - Phase advancement controls
  - Mission reset functionality
  - Mission planner simulator configuration
  - Simulation execution with custom parameters
  - Economic forecast generation
  - Plan export as JSON
  
- **AI Manager Services**: 25 examples
  - **MissionPlannerService** (12 examples): Pattern initialization, resource calculations, cost analysis, timeline generation, planetary changes simulation, contract generation, plan export
  - **EconomicForecasterService** (13 examples): Demand forecasting, GCC distribution, bottleneck identification, opportunity detection, risk assessment, scenario comparison
  
- **Celestial Bodies Controller**: 29 examples
  - Monitor view rendering
  - Sphere data JSON endpoints
  - Mission log tracking
  - AI test execution

- **Development Corporations Controller**: 5 examples
  - DC loading with settlements and accounts
  - Settlement grouping by DC owner
  - Active contracts counting
  - Organization type separation (DCs, Service Corps, Consortiums)

**Total**: 70 examples (45 controllers + 25 services), 0 failures

## Implementation Notes

### TaskExecutionEngine Integration

The AI Manager mission tracker integrates directly with the existing `AIManager::TaskExecutionEngine` service:

1. **Module Loading**: Requires `app/services/ai_manager.rb` which loads all AIManager services
2. **Instance Variable Access**: Extracts private data using `instance_variable_get`:
   - `@task_list` - Array of mission tasks
   - `@current_task_index` - Index of current task
   - `@manifest` - Mission configuration data
3. **Task Execution**: Calls `engine.execute_next_task` to advance mission phases
4. **Data Files**: Tasks loaded from JSON files in `app/data/missions/{mission-identifier}/`

### Error Handling

Controllers implement consistent error handling:

```ruby
rescue ActiveRecord::RecordNotFound
  redirect_to admin_ai_manager_missions_path, alert: "Mission not found"
end
```

### Flash Messages

Standard flash message types:
- `notice` - Success messages (green)
- `alert` - Error/warning messages (red)

## Future Enhancements

### Phase 1 (Stub Controllers)
- Implement DC monitoring with financial metrics
- Build settlement resource tracking
- Create resource flow visualization
- Develop simulation control interface

### Phase 2 (Advanced Features)
- Real-time WebSocket updates for live data
- AI decision logging and pattern analysis
- Performance metrics dashboard
- Mission success/failure analytics
- Automated testing suite for AI scenarios

### Phase 3 (Integration)
- Cross-section data correlation
- Automated alert system
- Mission scheduling and queuing
- Comprehensive audit logging

## Contributing

When adding new admin sections:

1. **Follow the pattern**: Use three-panel layout with SimEarth aesthetic
2. **Create stub action**: Start with placeholder data
3. **Add routes**: Namespace under `admin/`
4. **Write specs**: Minimum controller action coverage
5. **Update dashboard**: Add navigation link in `app/views/admin/dashboard/index.html.erb`
6. **Document**: Add section to this file

## Resources

- **Stylesheets**: `app/assets/stylesheets/admin/monitor.css`
- **Controllers**: `app/controllers/admin/`
- **Views**: `app/views/admin/`
- **Specs**: `spec/controllers/admin/`
- **Routes**: `config/routes.rb` (admin namespace)
