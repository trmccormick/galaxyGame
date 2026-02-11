# Define .ggmap Format

## Task Overview
Define the .ggmap file format specification for Galaxy Game map data storage, exchange, and interoperability based on detailed analysis of game-specific requirements.

## Background
Galaxy Game needs a standardized map format for terrain data that goes beyond FreeCiv/Civ4 capabilities. The format must support scientific layers (geology, lava tubes, aquifers), strategic layers (AI settlement guidance, infrastructure corridors), terraforming layers (worldhouse locations, biosphere seeds), and gameplay layers (missions, discoveries).

## Requirements

### Phase 1: Format Specification (Priority: High)
- **Header Structure**: Define magic number, version, metadata fields
- **Data Sections**: Specify terrain grid, elevation data, biome information
- **Compression**: Choose appropriate compression algorithm for large datasets
- **Metadata**: Include planetary parameters, creation date, author info

### Phase 2: Hierarchical Layer System (Priority: High)
**Base Layer (Terrain/Elevation)**: From AI/NASA data
- Elevation grids with proper planetary ranges
- Coordinate system (equirectangular)
- Resolution options (standard, high, ultra)

**Scientific Layer (Geology/Features)**: Generated from planetary params
- Lava tube locations (natural habitats)
- Aquifer sites (water extraction)
- Stable bedrock zones (megastructure foundations)
- Seismic activity zones

**Strategic Layer (AI Guidance)**: AI Manager analysis
- Optimal settlement locations (flat + resources + safety)
- Expansion priority zones
- Resource extraction sites (ore deposits, ice)
- Infrastructure corridors (transport networks)

**Terraforming Layer (Long-term targets)**: Worldhouse locations, orbital mirror positions, ocean basin zones, biosphere seed regions

**Scenario Layer (Custom Content)**: Map Studio edits, points of interest, danger zones, mission objectives

### Phase 3: Data Schema Design (Priority: High)
- **JSON Structure**: Hierarchical format with metadata, dimensions, and layered data
- **Validation Rules**: Data integrity checks and bounds validation
- **Extensibility**: Design for future feature additions
- **Non-Destructive**: Each layer builds on previous without overwriting

### Phase 4: Implementation Planning (Priority: Medium)
- **Reader/Writer Classes**: Design Ruby classes for format handling
- **Integration Points**: Identify where .ggmap files will be used
- **Tool Support**: Plan for map editor and conversion utilities
- **Documentation**: Create comprehensive format specification document

## Success Criteria
- [ ] Complete .ggmap format specification document with all layer definitions
- [ ] Defined data structures supporting scientific, strategic, and gameplay data
- [ ] Hierarchical layer system allowing non-destructive editing
- [ ] Ruby classes designed for reading/writing with validation
- [ ] Integration points identified in terrain service and monitor interface
- [ ] Format supports all current and planned terrain/map features

## Files to Create/Modify
- `docs/architecture/ggmap_format.md` - New comprehensive format specification
- `galaxy_game/lib/ggmap.rb` - New format handler class with layer support
- `galaxy_game/app/services/map_export_service.rb` - Export functionality
- `galaxy_game/app/services/terrain_service.rb` - Integration with existing terrain loading

## Estimated Time
2 hours

## Priority
HIGH