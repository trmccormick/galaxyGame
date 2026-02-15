# Easter Egg System Architecture and Data Separation

## Problem Description
The current easter egg system mixes sci-fi narrative elements with real astronomical data in core planetary setup files. Easter egg references are embedded in base JSON metadata, creating data purity issues and making it difficult to maintain clean separation between scientific data and game narrative.

## Current Issue
- `easter_egg` fields exist in base system JSON files (sol.json, star_systems/*.json)
- Real geological features are being mixed with sci-fi overlays
- No clear separation between astronomical data and narrative content
- Easter egg application is tied to base data modifications

## Required Changes

### 1. Audit Current Easter Egg Implementations
Review all existing easter egg JSON files and base system files to identify:
- All locations where `easter_egg` fields are embedded
- Geological features that have been modified with sci-fi content
- Dependencies between base data and easter egg overlays

### 2. Design Clean Overlay Architecture
Create a system where:
- Base astronomical files contain only scientific data
- Easter eggs are applied dynamically as overlays
- Target feature system allows precise sci-fi enhancement of real features
- Random triggers based on system identifiers, not data markers

### 3. Implement Target Feature Referencing
Enhance easter egg JSON structure with:
- `target_feature` field for specific geological feature IDs
- Overlay mechanics for adding citadels, mysteries, artifacts to real features
- Dynamic application without modifying base data

### 4. Remove Easter Egg Fields from Base Files
Clean up all base JSON files:
- Remove `easter_egg` metadata fields
- Ensure geological feature files contain only real data
- Maintain pure scientific content in core system files

### 5. Update Easter Egg Application Logic
Modify the easter egg system to:
- Trigger based on system analysis and random chance
- Apply overlays dynamically at runtime
- Support feature-specific enhancements
- Maintain backward compatibility

## Success Criteria
- Base astronomical JSON files contain only real scientific data
- Easter egg content stored separately and applied as overlays
- Target feature system enables precise sci-fi enhancement
- System maintains compatibility with existing implementations
- Clear documentation of overlay mechanism

## Files to Modify
- `data/json-data/easter_eggs/*.json` - Update with target_feature fields
- `data/json-data/star_systems/*.json` - Remove easter_egg metadata
- `data/json-data/star_systems/sol/*.json` - Clean separation
- `galaxy_game/app/models/easter_egg.rb` - Update application logic
- `galaxy_game/app/services/easter_egg_applicator.rb` - New overlay service

## Estimated Time
16 hours across 4 subtasks

## Priority
High - Critical for maintaining data integrity and system architecture