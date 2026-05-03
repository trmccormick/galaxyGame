
# 2026-04-17-ADVANCED-CLAUDE-DEFINE-GGMAP-FORMAT.md

## Task Title
Define and Document the .ggmap Map Format (Advanced/Research)

## Task Overview
Design, specify, and document the .ggmap file format for Galaxy Game map data storage, exchange, and interoperability. This must support scientific, strategic, terraforming, and gameplay layers, and be extensible for future needs. This is advanced/research work requiring deep analysis and cross-domain knowledge. Assign to Claude or equivalent advanced agent.

## Background & Context
- Galaxy Game requires a next-generation map format beyond FreeCiv/Civ4, supporting scientific, strategic, terraforming, and scenario layers.
- Format must enable non-destructive, hierarchical editing and support large, high-resolution datasets.
- No current format meets these needs; this is a foundational task for future terrain and gameplay systems.

## Actionable Steps
1. **Format Specification**
	- Define header structure (magic number, version, metadata fields).
	- Specify data sections: terrain grid, elevation, biome, and all required metadata.
	- Select/justify compression algorithm for large datasets.
	- Document planetary parameters, creation date, author info, and extensibility hooks.
2. **Hierarchical Layer System**
	- Design base (terrain/elevation), scientific, strategic, terraforming, and scenario layers.
	- Specify coordinate system, resolution options, and data integrity rules.
	- Ensure each layer builds non-destructively on previous layers.
3. **Data Schema Design**
	- Create a hierarchical JSON schema with metadata, dimensions, and layered data.
	- Define validation rules and extensibility mechanisms.
4. **Implementation Planning**
	- Design Ruby reader/writer classes for .ggmap files.
	- Identify integration points in terrain service, monitor interface, and map editors.
	- Plan for tool support (map editor, conversion utilities).
	- Draft comprehensive format specification document.
5. **Research & Reference**
	- Review existing map formats (FreeCiv, Civ4, NASA, GIS) for best practices and pitfalls.
	- Document rationale for all design decisions.

## STOP/REVIEW Conditions
- STOP if architectural or data model blockers are found; escalate to planning.
- STOP if a suitable open standard is found that meets all requirements; document and propose adoption.

## Acceptance Criteria
- [ ] Complete .ggmap format specification document with all layer definitions
- [ ] Data structures support scientific, strategic, and gameplay data
- [ ] Hierarchical, non-destructive layer system
- [ ] Ruby classes designed for reading/writing/validation
- [ ] Integration points identified in terrain service and monitor interface
- [ ] Format supports all current and planned terrain/map features
- [ ] All design decisions and research are documented

## Agent Assignment
- **Agent:** Claude (or equivalent advanced AI/ML agent)

## Files to Create/Modify
- docs/architecture/ggmap_format.md (new)
- galaxy_game/lib/ggmap.rb
- galaxy_game/app/services/map_export_service.rb
- galaxy_game/app/services/terrain_service.rb

## Estimated Time
2-4 hours (advanced/research)

## Priority
ADVANCED / HIGH

## Audit/Verification
- Confirm no duplicate or superseding task exists.
- Verify requirements with stakeholders before implementation.
- Reference commit or PR in task file upon completion.

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