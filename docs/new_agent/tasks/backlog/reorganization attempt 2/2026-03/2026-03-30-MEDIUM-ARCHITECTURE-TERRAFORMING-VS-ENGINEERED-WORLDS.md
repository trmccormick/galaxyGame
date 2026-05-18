# 2026-03-30-MEDIUM-ARCHITECTURE-TERRAFORMING-VS-ENGINEERED-WORLDS

**Agent:** GPT-4.1 (0.33x)
**Priority:** MEDIUM
**Type:** ARCHITECTURE
**Status:** BACKLOG

## Context
Define core architectural distinction between terraforming candidates and engineered worlds for colonization strategies.

## Problem
- System doesn't distinguish between terraformable and engineered worlds
- TerraformingManager doesn't skip simulation for permanently hostile environments
- AI strategies don't account for different colonization approaches

## Files
- CelestialBody model (add colonization_approach field)
- TerraformingManager
- AI Manager strategy trees

## Steps
1. Add colonization_approach field to CelestialBody: terraformable, engineered, uninhabitable
2. Update TerraformingManager to check colonization_approach before running simulation
3. Skip terraforming logic for engineered worlds
4. Create different AI strategy trees per colonization approach
5. Document colonization strategies: engineered worlds prioritize technology (pressure vessels, radiation shielding); terraforming worlds prioritize atmosphere and biosphere management

## Acceptance Criteria
- CelestialBody has colonization_approach field with proper values
- TerraformingManager skips simulation for engineered worlds
- AI strategies differentiate between terraforming and engineered approaches
- Clear logging when bodies flagged as engineered vs terraformable

## Stop Condition
- TerraformingManager processes engineered worlds same as terraformable

## Commit Instructions
```
git add app/models/celestial_bodies/celestial_body.rb app/services/terraforming_manager.rb app/services/ai_manager/
git commit -m "arch: distinguish terraforming vs engineered worlds colonization approaches"
```