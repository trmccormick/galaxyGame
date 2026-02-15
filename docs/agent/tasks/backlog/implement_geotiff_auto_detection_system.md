# Implement GeoTIFF Auto-Detection and Update System

## Problem
Currently, adding new GeoTIFF files requires manual intervention to regenerate terrain. The system doesn't automatically detect when new NASA data files are added or when existing files are updated.

## Current State
- **Manual Process**: Adding `titan_1800x900.tif` requires manual terrain regeneration
- **No Change Detection**: System doesn't check if GeoTIFF files are newer than stored terrain
- **No Validation**: No checks for corrupted or invalid GeoTIFF data
- **Limited Feedback**: No logging when new data sources become available

## Required Changes

### Task 1.1: Implement GeoTIFF Change Detection
- Add file modification time checking in `nasa_geotiff_available?()`
- Compare GeoTIFF file timestamps vs terrain generation metadata
- Return data freshness information for decision making

### Task 1.2: Create Terrain Update Triggers
- Modify `generate_terrain_for_body()` to check for data updates
- Add `force_update` parameter for manual regeneration
- Implement selective regeneration (only updated bodies)

### Task 1.3: Add Data Validation and Error Handling
- Validate GeoTIFF file integrity before use
- Add fallback to procedural generation on data errors
- Log data quality issues for monitoring

### Task 1.4: Enhance Logging and Monitoring
- Log when new GeoTIFF data is detected
- Track data source usage statistics
- Add admin interface indicators for data freshness

## Success Criteria
- Adding new GeoTIFF file automatically triggers terrain regeneration
- System detects and uses updated NASA data without manual intervention
- Invalid/corrupted GeoTIFF files gracefully fall back to procedural generation
- Clear logging of data source detection and usage

## Files to Modify
- `galaxy_game/app/services/star_sim/automatic_terrain_generator.rb`
- `galaxy_game/app/controllers/admin/celestial_bodies_controller.rb` (for manual triggers)

## Testing Requirements
- Add GeoTIFF file and verify automatic regeneration
- Update existing GeoTIFF and verify terrain updates
- Test with corrupted file (fallback behavior)
- Verify logging of data source changes

## Dependencies
- Requires working GeoTIFF processing pipeline
- Assumes basic Sol world terrain generation is functional</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/implement_geotiff_auto_detection_system.md