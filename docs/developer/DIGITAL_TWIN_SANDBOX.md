# Digital Twin Sandbox

## Overview

The Digital Twin Sandbox is an isolated testing environment for planetary terraforming scenarios, inspired by SimEarth's intervention-based gameplay. It allows administrators to create "what-if" simulations of celestial body development without affecting the live game state.

## Architecture

### Core Components

**Digital Twins Controller** (`app/controllers/admin/digital_twins_controller.rb`)
- Manages creation and intervention application for isolated planetary simulations
- Integrates with TerraSim for physics-based validation
- Uses transient data storage to avoid live game impact

**Intervention Framework**
- 20+ terraforming actions across atmospheric, settlement, and life augmentation categories
- Physics-validated outcomes through TerraSim integration
- Scenario templates generated from FreeCiv/Civ4 map analysis

### Key Features

**Isolated Testing Environment:**
- Creates independent copies of celestial bodies
- Changes don't affect live game database
- Transient data storage with automatic cleanup

**SimEarth-Style Interventions:**
- Atmospheric modifications (thickening, greenhouse gases, ice melting)
- Settlement establishment (outposts, infrastructure)
- Life augmentation (microbes, ecosystem seeding)

**TerraSim Integration:**
- Physics validation of intervention outcomes
- Realistic planetary evolution simulation
- Multi-sphere interaction (atmosphere, hydrosphere, geosphere, biosphere)

## FreeCiv/Civ4 Integration

### Role in Digital Twin Testing

**FreeCiv/Civ4 maps serve as ARTISTIC TERRAFORMING SCENARIO TEMPLATES:**

**Map Analysis for Scenario Generation:**
- **Terraformed Mars Maps**: Show lush, habitable worlds after successful terraforming - artistic visions of what could be possible
- **Tamed Venus Maps**: Depict controlled volcanic planets with breathable atmospheres - creative interpretations
- **Pattern Extraction**: AI learns terraforming success patterns from these artistic representations
- **Scenario Templates**: Converted into Digital Twin terraforming objectives and intervention sequences

**Key Distinction - Artistic vs Factual:**
- **FreeCiv/Civ4 Maps**: Represent terraformed ENDPOINTS - lush, habitable worlds that could exist after centuries of successful terraforming
- **NASA Data**: Represents CURRENT conditions - barren, hostile environments requiring terraforming
- **Digital Twin Role**: Bridges the gap by simulating the terraforming journey from current NASA conditions to artistic FreeCiv/Civ4 visions

**Scenario Template Workflow:**
1. **Map Selection**: Choose FreeCiv/Civ4 terraformed world maps as "target states"
2. **AI Analysis**: Extract terraforming patterns and success indicators
3. **Template Generation**: Create intervention sequences to achieve similar outcomes
4. **Digital Twin Testing**: Apply templates to barren planets, validate with TerraSim physics
5. **Projection Results**: Determine if artistic visions are physically achievable

**Map Selection Interface** (`select_maps_for_analysis`)
- Admin interface for choosing FreeCiv/Civ4 terraformed world maps
- Displays available maps with metadata and AI learning stats
- Bulk selection controls for efficient analysis

**AI Analysis Workflow:**
1. Maps processed for strategic patterns and terrain features
2. Patterns extracted and stored as reusable scenario templates
3. Templates applied to digital twins as terraforming targets
4. TerraSim validates physical viability of scenarios

**Scenario Template Generation:**
- Terrain patterns converted to terraforming objectives
- Strategic markers become settlement targets
- Resource distributions guide development priorities
- **Geographical patterns inspire fictional world generation**

## Usage Workflow

### 1. Map Selection
```
Admin → Celestial Bodies → Select Maps for Analysis
```
- Browse available FreeCiv/Civ4 maps
- Select maps for AI analysis
- Configure analysis options

### 2. Scenario Generation
```
Admin → Celestial Bodies → [Planet] → Generate Earth Map
```
- AI analyzes selected maps
- Creates scenario templates
- Updates learning database

### 3. Digital Twin Testing
```
Admin → Digital Twins → Create New Twin
```
- Select planetary base and scenario template
- Apply terraforming interventions
- Monitor TerraSim validation results

## Intervention Types

### Atmospheric Interventions
- `atmo_thickening`: Increase atmospheric density
- `greenhouse_gases`: Enhance greenhouse effect
- `ice_melting`: Reduce polar ice caps

### Settlement Interventions
- `establish_outpost`: Create initial settlement
- `build_infrastructure`: Expand settlement capabilities
- `resource_extraction`: Enable resource harvesting

### Life Augmentation Interventions
- `introduce_microbes`: Seed basic life forms
- `seed_ecosystem`: Establish complex ecosystems
- `biosphere_enhancement`: Accelerate biosphere development

## TerraSim Validation

### Physics-Based Validation
- Atmospheric pressure and composition changes
- Hydrosphere water distribution and state changes
- Geosphere geological activity and crustal evolution
- Biosphere habitability and biodiversity metrics

### Multi-Sphere Interactions
- Atmospheric changes affect temperature and weather
- Hydrosphere modifications impact biosphere viability
- Geological activity influences surface conditions
- Life development creates feedback loops

## Benefits

### For Development
- **Isolated Testing**: Safe experimentation without live game risk
- **Physics Validation**: Realistic outcome prediction
- **Scenario Reusability**: Templates for multiple test cases

### For Game Balance
- **Terraforming Validation**: Ensure realistic development paths
- **Resource Balance**: Test economic viability of interventions
- **Difficulty Tuning**: Validate challenge progression

### For AI Learning
- **Pattern Validation**: Test AI-suggested terraforming approaches
- **Outcome Prediction**: Improve AI decision-making
- **Scenario Optimization**: Refine intervention strategies

## Technical Implementation

### Data Storage
- Transient digital twin data (not persisted)
- Scenario templates stored in AI learning database
- TerraSim state cached during simulation runs

### Performance Considerations
- Isolated simulations prevent performance impact on live game
- TerraSim physics calculations run asynchronously
- Resource cleanup ensures no memory leaks

### Error Handling
- Intervention validation prevents impossible scenarios
- TerraSim error recovery maintains simulation stability
- Automatic cleanup on twin destruction

## Future Enhancements

### Phase 1: Enhanced Interventions
- More granular intervention controls
- Custom intervention combinations
- Real-time intervention effects

### Phase 2: Multi-Planet Scenarios
- Inter-planetary terraforming dependencies
- Solar system-wide simulation effects
- Cross-body resource utilization

### Phase 3: Player Integration
- Player-accessible digital twin testing
- Community scenario sharing
- Achievement system for successful terraforming

## Integration Points

- **AI Manager**: Provides scenario templates and learning data
- **TerraSim**: Validates physics and multi-sphere interactions
- **Admin Interface**: Provides twin management and monitoring
- **Map Processors**: Convert FreeCiv/Civ4 data to scenario templates

## Troubleshooting

### Twin Creation Fails
- Verify TerraSim service availability
- Check planetary data integrity
- Ensure sufficient system resources

### Intervention Errors
- Validate intervention parameters
- Check TerraSim physics constraints
- Review scenario template compatibility

### Performance Issues
- Monitor TerraSim calculation times
- Check for resource conflicts
- Consider twin cleanup procedures

This system enables comprehensive testing of planetary development strategies while maintaining game stability and providing valuable data for AI learning and game balance improvements.</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/developer/DIGITAL_TWIN_SANDBOX.md