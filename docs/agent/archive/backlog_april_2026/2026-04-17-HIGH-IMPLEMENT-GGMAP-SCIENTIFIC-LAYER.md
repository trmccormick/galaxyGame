# 2026-04-17-HIGH-IMPLEMENT-GGMAP-SCIENTIFIC-LAYER.md

# Implement GGMap Scientific Layer

## Task Title
Implement GGMap Scientific Layer

## Task Overview
Implement the scientific layer generation for .ggmap format, creating geological features like lava tubes, aquifers, and resource deposits for planetary maps.

## Background & Context
The .ggmap scientific layer generates gameplay-relevant geological features that AI and players can use for colonization. This includes natural habitats (lava tubes), water sources (aquifers), and stable construction sites. All schema, layer structure, and integration must strictly comply with the canonical .ggmap format task (2026-04-17-ADVANCED-CLAUDE-DEFINE-GGMAP-FORMAT.md).

## Actionable Steps
1. BLOCKED: Do not begin implementation until the canonical .ggmap format/specification task is complete and approved.
2. Review the canonical .ggmap format for layer structure, schema, and integration requirements.
3. Implement feature generation logic:
   - Lava tube generation (Mars/Luna)
   - Aquifer detection
   - Stable bedrock mapping
   - Seismic zone analysis
4. Implement resource deposit generation:
   - Mineral deposits
   - Ice formations
   - Volcanic features
   - Cave systems
5. Integrate planetary parameters and realism constraints.
6. Implement scientific layer in .ggmap JSON format, with metadata and non-destructive regeneration.
7. Validate scientific plausibility and gameplay balance.
8. Support export/import of the scientific layer.

## STOP/REVIEW Conditions
- STOP if the canonical .ggmap format task is not complete or changes.
- STOP if scientific layer requirements conflict with the canonical format; escalate for review.

## Acceptance Criteria
- [ ] Lava tubes generate in appropriate geological conditions
- [ ] Aquifers detected based on planetary water content
- [ ] Resource deposits placed realistically across terrain
- [ ] Scientific layer integrates properly with .ggmap format
- [ ] Features provide meaningful gameplay advantages

## Agent Assignment
- Agent: Senior Ruby developer or advanced AI agent (Claude)

## Files to Create/Modify
- galaxy_game/app/services/ggmap_scientific_generator.rb
- galaxy_game/app/services/geological_analysis_service.rb
- galaxy_game/lib/ggmap.rb
- galaxy_game/app/models/celestial_bodies/spheres/geosphere.rb

## Blockers / Dependencies
- BLOCKED: Do not begin implementation until 2026-04-17-ADVANCED-CLAUDE-DEFINE-GGMAP-FORMAT.md (.ggmap format/specification) is complete and approved.
- All schema, layer structure, and integration must strictly comply with the canonical .ggmap format task.
- Any changes to .ggmap format must be proposed and approved in the canonical task before implementation.

## Notes
- This task implements the scientific layer only. For format/schema, see the canonical .ggmap format task.
- Remove or update any redundant schema details if the canonical task changes.