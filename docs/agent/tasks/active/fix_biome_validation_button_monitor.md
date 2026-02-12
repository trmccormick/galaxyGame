# Implement Biome Validation for Digital Twin Sandbox

## Problem
The "BIOME VALIDATION" section in `/admin/celestial_bodies/:id/monitor` contains a non-functional "Validate Biomes" button that should be a valuable admin tool for digital twin sandbox and terraforming planning.

## Current State
- Button calls `runBiomeValidation()` function which doesn't exist in `monitor.js`
- Button lacks proper CSS class (should be `tool-button` for consistent styling)
- UI structure exists but functionality is missing
- Feature is intended for TerraSim integration and biome stability testing

## Context from User
"These controls could be used in the digital twin sandbox and terraforming planning by the admin to test what appropriate biomes could survive. Currently Terraforming is a AI manager task with limited admin control proposed."

## Required Changes
**Implement Digital Twin Sandbox Biome Validation**
1. **Fix button styling**: Add `tool-button` class for consistent appearance
2. **Implement JavaScript handler**: Create `runBiomeValidation()` function in `monitor.js`
3. **Add validation logic**: Connect to TerraSim for biome stability testing
4. **Display results**: Show validation results in the `#validation-details` div
5. **Integration with existing systems**: Use existing sphere data endpoints

## Implementation Plan
- **UI**: Add proper styling and show/hide validation results panel
- **JavaScript**: Implement `runBiomeValidation()` to call validation endpoint
- **Backend**: Create validation logic using TerraSim digital twin
- **Results**: Display biome stability scores, survival predictions, terraforming recommendations

## Use Cases
- **Admin terraforming planning**: Test biome survival under different conditions
- **Digital twin sandbox**: Validate biome placement stability
- **Environmental simulation**: Check how biomes adapt to changing conditions
- **Terraforming assessment**: Evaluate terraforming success probabilities

## Dependencies
- TerraSim integration for biome simulation
- Existing sphere data endpoints (`sphere_data`)
- Terrain and climate data availability

## Priority
Medium-High - Valuable admin tool for terraforming and environmental planning</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/active/fix_biome_validation_button_monitor.md