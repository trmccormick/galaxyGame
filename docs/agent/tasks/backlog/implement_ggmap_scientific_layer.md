# Implement GGMap Scientific Layer

## Task Overview
Implement the scientific layer generation for .ggmap format, creating geological features like lava tubes, aquifers, and resource deposits for planetary maps.

## Background
The .ggmap scientific layer generates gameplay-relevant geological features that AI and players can use for colonization. This includes natural habitats (lava tubes), water sources (aquifers), and stable construction sites.

## Requirements

### Phase 1: Feature Generation Logic (Priority: High)
- **Lava Tube Generation**: Create natural tunnel systems on Mars/Luna based on geological parameters
- **Aquifer Detection**: Identify subsurface water deposits using planetary composition data
- **Stable Bedrock Mapping**: Locate areas suitable for megastructure foundations
- **Seismic Zone Analysis**: Map areas to avoid for critical infrastructure

### Phase 2: Resource Deposit Generation (Priority: High)
- **Mineral Deposits**: Generate ore concentrations based on planetary geology
- **Ice Formations**: Create polar/permafrost water ice deposits
- **Volcanic Features**: Map volcanic areas for geothermal energy potential
- **Cave Systems**: Generate natural shelter locations

### Phase 3: Data Integration (Priority: Medium)
- **Planetary Parameters**: Use body composition, temperature, and geological age
- **Realism Constraints**: Apply scientific accuracy to feature placement
- **Density Controls**: Balance feature frequency for gameplay
- **Validation**: Ensure generated features are scientifically plausible

### Phase 4: GGMap Integration (Priority: Medium)
- **Layer Structure**: Implement scientific layer in .ggmap JSON format
- **Metadata**: Include feature properties (stability, size, accessibility)
- **Non-Destructive**: Allow layer regeneration without affecting other layers
- **Export/Import**: Support scientific layer in map saving/loading

## Scientific Layer JSON Structure
```json
"scientific_layer": {
  "geological_features": [
    {
      "type": "lava_tube",
      "location": { "x": 45, "y": 23 },
      "properties": {
        "stability": 0.85,
        "length_km": 12.5,
        "suitable_for": ["habitat", "greenhouse", "mining"]
      }
    }
  ],
  "resource_deposits": [
    {
      "type": "water_ice",
      "location": { "x": 78, "y": 156 },
      "properties": {
        "volume_m3": 5000000,
        "accessibility": 0.7,
        "extraction_difficulty": "moderate"
      }
    }
  ]
}
```

## Success Criteria
- [ ] Lava tubes generate in appropriate geological conditions
- [ ] Aquifers detected based on planetary water content
- [ ] Resource deposits placed realistically across terrain
- [ ] Scientific layer integrates properly with .ggmap format
- [ ] Features provide meaningful gameplay advantages

## Files to Create/Modify
- `galaxy_game/app/services/ggmap_scientific_generator.rb` - Feature generation logic
- `galaxy_game/app/services/geological_analysis_service.rb` - Planetary geology analysis
- `galaxy_game/lib/ggmap.rb` - Add scientific layer support
- `galaxy_game/app/models/celestial_bodies/spheres/geosphere.rb` - Geology data integration

## Estimated Time
4 hours

## Priority
HIGH