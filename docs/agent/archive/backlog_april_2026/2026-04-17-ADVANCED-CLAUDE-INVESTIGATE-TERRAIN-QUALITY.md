
# 2026-04-17-ADVANCED-CLAUDE-INVESTIGATE-TERRAIN-QUALITY.md

## Task Title
Investigate and Resolve Terrain Quality Issues (Earth & Exoplanet)

## Task Overview
Audit, diagnose, and document all current terrain quality issues for both Earth (NASA GeoTIFF) and exoplanet procedural generation. Establish a clear baseline, root cause analysis, and actionable recommendations for improvement. This is advanced work requiring deep code, data, and AI pattern analysis. Assign to Claude or equivalent advanced agent.

## Background & Context
- Terrain rendering quality directly impacts gameplay, admin monitoring, and scientific realism.
- Known issues: Exoplanet terrain appears visually odd (too uniform/random), Earth terrain may have data or rendering fidelity problems.
- Current system uses NASA GeoTIFF for Sol bodies, learned patterns for exoplanets, with fallback to sine wave if pattern fails.
- No recent work has addressed these issues; RSpec/test failures have been prioritized.

## Actionable Steps
1. **Earth Terrain Audit**
	- Verify NASA GeoTIFF elevation data loads and renders correctly.
	- Visually inspect Earth terrain for continental accuracy and hydrosphere integration.
	- Benchmark loading speed and memory usage.
2. **Exoplanet Terrain Investigation**
	- Check metadata for 'learned_from_nasa_data' vs 'sine_wave_fallback'.
	- Confirm NASA pattern files are loaded and applied.
	- Verify Civ4 Earth reference is accessible and used for pattern learning.
	- Analyze elevation scaling, smoothing, and planet-type matching.
3. **Visual Quality Assessment**
	- Identify specific visual issues (uniformity, randomness, feature mismatch).
	- Compare exoplanet vs Earth terrain quality.
	- Ensure planet-type matching and gas giant handling are correct.
4. **Root Cause Documentation**
	- Catalog all terrain quality problems with evidence (screenshots, metadata, code refs).
	- Trace code/data flow from seed to render.
	- Distinguish between code bugs and parameter/model tuning issues.
	- Provide detailed, actionable recommendations for fixes.
5. **Reporting**
	- Create docs/testing/terrain_quality_audit.md with findings, evidence, and recommendations.
	- Reference all relevant code, data, and patterns.

## STOP/REVIEW Conditions
- STOP if root cause is architectural or requires major refactor; escalate to planning.
- STOP if similar bug is already fixed in a newer commit; archive this task with reference.

## Acceptance Criteria
- [ ] Earth NASA terrain loads and displays accurately
- [ ] Exoplanet terrain generation issues are identified and documented
- [ ] Root causes are evidenced with metadata/code/screenshots
- [ ] Clear distinction between code bugs and parameter/model issues
- [ ] Actionable recommendations for improvement are provided
- [ ] Performance benchmarks are established
- [ ] All findings are documented in terrain_quality_audit.md

## Agent Assignment
- **Agent:** Claude (or equivalent advanced AI/ML agent)

## Files to Create/Modify
- docs/testing/terrain_quality_audit.md (new)
- galaxy_game/app/javascript/admin/monitor.js
- galaxy_game/app/services/terra_sim/terrain_service.rb
- galaxy_game/app/services/star_sim/system_builder_service.rb

## Estimated Time
2-4 hours (advanced/AI/ML analysis)

## Priority
ADVANCED / HIGH

## Audit/Verification
- Confirm no duplicate or superseding task exists.
- Verify bug is still present before starting work.
- Reference commit or PR in task file upon completion.

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