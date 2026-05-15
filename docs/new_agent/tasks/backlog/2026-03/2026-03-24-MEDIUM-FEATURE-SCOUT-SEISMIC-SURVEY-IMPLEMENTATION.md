# 2026-03-24-MEDIUM-FEATURE-SCOUT-SEISMIC-SURVEY-IMPLEMENTATION.md

**Agent**: 0.33x
**Priority**: MEDIUM
**Type**: FEATURE
**Name**: Implement Seismic Survey Logic for Scout Ships

## Context
Scout-class ships perform scouting missions via WormholeScoutingService. The AI Manager uses scouting results to evaluate asteroid conversion candidates via StationCostBenefitAnalyzer. This task adds a seismic survey mode that classifies asteroids as Rubble Piles or Solid Anchors.

## Problem
AI Manager's Asteroid Conversion strategy requires seismic survey classification of asteroids as Rubble Piles or Solid Anchors. Without this classification, the cost-benefit analyzer cannot safely approve Eden AWS Anchor placement.

## Files
- Target: WormholeScoutingService, StationCostBenefitAnalyzer
- Related: docs/architecture/systems/asteroid_conversion_physics.md, docs/architecture/systems/survey_and_handshake_protocol.md, docs/developer/WORMHOLE_SCOUTING_INTEGRATION.md

## Steps
1. Add seismic survey mode to WormholeScoutingService
2. Implement asteroid classification logic (Rubble Piles vs Solid Anchors)
3. Wire seismic results into AI Manager's StationCostBenefitAnalyzer
4. Update survey result handshake format
5. Test seismic survey integration with asteroid conversion strategy

## Acceptance Criteria
- Scout ships can perform seismic surveys
- Asteroids classified as Rubble Piles or Solid Anchors
- AI Manager can safely approve Eden AWS Anchor placement
- Seismic survey results integrated into cost-benefit analysis

## Stop Condition
- Seismic survey logic implemented and tested
- Asteroid classification working correctly
- AI Manager can use seismic data for conversion decisions

## Commit
`feat: implement seismic survey logic for scout ship asteroid classification`