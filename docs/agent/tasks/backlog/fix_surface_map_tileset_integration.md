# Fix Surface Map Tileset Integration

## Task Overview
Implement functional Civilization-style strategic surface map view using FreeCiv tilesets with proper terrain-to-tile mapping and layer system.

## Background
Surface maps should display as tile-based strategic views using Civ4-style tilesets but currently don't work. Need to create the surface_map view with FreeCiv Trident tilesets, proper grid sizing, and functional layer toggles.

## Requirements

### Phase 1: Surface Map Infrastructure (Priority: Medium)
- **Route Creation**: Add surface_map route to celestial_bodies controller
- **View Template**: Create surface_map.html.erb with canvas and controls
- **Controller Action**: Implement surface_map action with data preparation
- **Tileset Loading**: Set up FreeCiv tileset asset loading (Trident 64x64)

### Phase 2: Grid and Coordinate System (Priority: Medium)
- **Grid Sizing**: Implement body diameter-based grid with 2:1 aspect ratio
- **Coordinate Mapping**: Set up tile-based coordinate system
- **Canvas Setup**: Configure canvas dimensions and tile rendering
- **Zoom/Navigation**: Add basic zoom and pan functionality

### Phase 3: Terrain to Tile Mapping (Priority: Medium)
- **Tile Type Mapping**: Convert terrain types to FreeCiv tile types
- **Sprite Rendering**: Implement tile sprite rendering system
- **Terrain Base Layer**: Display terrain as tile grid (always visible)
- **Performance Optimization**: Efficient tile rendering for large grids

### Phase 4: Layer System Implementation (Priority: Medium)
- **Water Layer**: Blue transparency overlays for water terrain
- **Biomes Layer**: Green vegetation overlays for forest/jungle
- **Features Layer**: Geological features (lava tubes, craters, volcanoes)
- **Resources Layer**: Mineral deposits and ice resource markers
- **Layer Toggles**: UI controls for showing/hiding layers

### Phase 5: Advanced Features (Priority: Low)
- **Civilization Layer**: Future settlements and unit overlays
- **Interactive Elements**: Clickable tiles for detailed information
- **Export Functionality**: Save surface maps as images
- **Customization**: Allow tileset selection (Trident, BigTrident, etc.)

## Tileset Specifications
- **Primary Tileset**: FreeCiv Trident (64x64 pixels per tile)
- **Alternative**: BigTrident (60x60) or Engels (45x45)
- **Grid Formula**: width = (180 * scale_factor).round, height = (width / 2).round
- **Layer Rendering**: Base terrain + additive overlays with transparency

## Success Criteria
- [ ] Surface map route loads without errors
- [ ] Tile-based grid displays with correct sizing
- [ ] Terrain properly mapped to FreeCiv tile sprites
- [ ] Layer toggles work for water, biomes, features, resources
- [ ] Canvas renders efficiently for planetary-scale grids
- [ ] Zoom and navigation controls functional

## Files to Create/Modify
- `galaxy_game/app/controllers/admin/celestial_bodies_controller.rb` - Add surface_map action
- `galaxy_game/app/views/admin/celestial_bodies/surface_map.html.erb` - New surface map view
- `galaxy_game/app/javascript/admin/surface_map.js` - Tile rendering and layer logic
- `galaxy_game/app/assets/images/tilesets/` - Ensure tileset assets available
- `config/routes.rb` - Add surface_map route

## Estimated Time
4-6 hours

## Priority
MEDIUM