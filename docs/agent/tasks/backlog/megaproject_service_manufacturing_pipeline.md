# Task: Megaproject Service Manufacturing Pipeline
## Priority: High (architecture, gameplay)

## Problem
Megastructure blueprints (e.g., Lunar Space Elevator) use a different cost schema and construction pipeline than unit blueprints. The current ManufacturingService and associated specs are designed for unit/craft blueprints and do not support the requirements of megastructures.

## Solution
- Design and implement a dedicated MegaProjectService for handling megastructure construction, licensing, and progress tracking.
- Support total_construction_cost, multi-phase build, and unique requirements (e.g., orbital construction yards, special materials).
- Integrate with the correct blueprint schema (do NOT retrofit cost_data for megastructures).
- Update specs to test megastructure construction via MegaProjectService, not ManufacturingService.
- Ensure clear separation of concerns between unit/craft manufacturing and megastructure projects.

## Notes
- Do NOT modify existing megastructure blueprint JSON to fit unit/craft schema.
- Mark any ManufacturingService specs for megastructures as pending with a clear reason.
- Coordinate with gameplay and UI teams for progress tracking and player feedback.
