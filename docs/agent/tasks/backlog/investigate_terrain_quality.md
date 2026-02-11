# Investigate Terrain Quality

## Task Overview
Investigate and document current terrain quality issues, data sources, and rendering problems for both Earth (NASA data) and generated exoplanet terrain to establish baseline for improvements.

## Background
Terrain rendering quality affects gameplay experience and administrative monitoring. Current implementation may have issues with data accuracy, visual fidelity, or performance. Specifically, procedurally generated exoplanet terrain "looks a little odd" compared to Earth.

## Requirements

### Phase 1: Earth Terrain Audit (Priority: High)
- **NASA Data Verification**: Confirm GeoTIFF elevation data loading correctly
- **Visual Inspection**: Compare rendered Earth terrain with expected continental shapes
- **Hydrosphere Integration**: Verify water layer displays properly
- **Performance Check**: Test loading speed and memory usage

### Phase 2: Exoplanet Terrain Investigation (Priority: High)
- **Generation Method Check**: Verify metadata shows 'learned_from_nasa_data' not 'sine_wave_fallback'
- **Pattern Loading**: Confirm NASA pattern files are being loaded and applied
- **Landmass Reference**: Check if Civ4 Earth reference is accessible and used
- **Parameter Analysis**: Review elevation scaling, smoothing, and planet-type matching

### Phase 3: Visual Quality Assessment (Priority: High)
- **Specific Issues**: Identify what looks odd (too uniform, too random, wrong features)
- **Comparison Analysis**: Compare exoplanet vs Earth terrain quality
- **Planet-Type Matching**: Verify hot/cold planets get appropriate terrain patterns
- **Gas Giant Handling**: Ensure gas giants don't show surface terrain

### Phase 4: Root Cause Documentation (Priority: High)
- **Issue Catalog**: List specific terrain quality problems with evidence
- **Code Path Analysis**: Trace terrain generation from seed to render
- **Data Flow Verification**: Check pattern loading, parameter application, rendering pipeline
- **Recommendations**: Clear plan for fixes (code bug vs parameter tuning)

## Investigation Commands
```ruby
# Check exoplanet terrain metadata
planet = CelestialBodies::CelestialBody.find_by(identifier: 'AOL-732356')
terrain = planet.geosphere.terrain_map
puts terrain['metadata']
# Should show: generation_method, patterns_used, landmass_source
```

## Success Criteria
- [ ] Complete audit of Earth NASA terrain loading and display
- [ ] Identified specific problems with exoplanet terrain generation
- [ ] Documented root causes with evidence from metadata and code
- [ ] Clear distinction between code bugs and parameter tuning issues
- [ ] Detailed recommendations for terrain quality improvements
- [ ] Performance benchmarks established for comparison

## Files to Create/Modify
- `docs/testing/terrain_quality_audit.md` - New detailed audit document
- `galaxy_game/app/javascript/admin/monitor.js` - Review rendering code
- `galaxy_game/app/services/terra_sim/terrain_service.rb` - Check generation logic
- `galaxy_game/app/services/star_sim/system_builder_service.rb` - Verify seed processing

## Estimated Time
1-2 hours

## Priority
HIGH