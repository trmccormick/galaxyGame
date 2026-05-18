# 2026-04-17-HIGH-IMPLEMENT-GGMAP-SCIENTIFIC-LAYER

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — High priority feature implementation for GGMap scientific layer
**Supervision Level**: 🔴 Watched carefully

## Context
.ggmap scientific layer generates geological features like lava tubes, aquifers, resource deposits for planetary maps. AI and players use these for colonization. Must comply with canonical .ggmap format specification.

## Problem Statement
No scientific layer implementation in .ggmap format. Geological features not generated for gameplay.

**Expected**: Scientific layer with lava tubes, aquifers, stable bedrock, seismic zones, resource deposits integrated into .ggmap format.

## Files Involved
### Primary Files — you will create
| File | Purpose | Action |
|---|---|---|
| `galaxy_game/app/services/ggmap_scientific_generator.rb` | Feature generation | Create lava tubes, aquifers, deposits |
| `galaxy_game/app/services/geological_analysis_service.rb` | Analysis logic | Implement geological analysis |
| `galaxy_game/lib/ggmap.rb` | Format integration | Add scientific layer support |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `galaxy_game/app/models/celestial_bodies/spheres/geosphere.rb` | Geosphere model |
| `docs/architecture/ggmap_format.md` | Canonical format specification |

## Implementation Steps
1. **BLOCKED**: Wait for canonical .ggmap format task completion and approval
2. **Review format**: Confirm layer structure, schema, integration requirements
3. **Implement features**: Lava tube generation, aquifer detection, stable bedrock mapping, seismic analysis
4. **Resource deposits**: Mineral deposits, ice formations, volcanic features, cave systems
5. **Integration**: Planetary parameters, realism constraints, .ggmap JSON format
6. **Validation**: Scientific plausibility, gameplay balance, export/import support

## Acceptance Criteria
- [ ] Lava tubes generate in appropriate geological conditions
- [ ] Aquifers detected based on planetary water content
- [ ] Resource deposits placed realistically across terrain
- [ ] Scientific layer integrates properly with .ggmap format
- [ ] Features provide meaningful gameplay advantages

## Stop Conditions
- Canonical .ggmap format task not complete
- Scientific layer requirements conflict with canonical format

## Commit Instructions
```bash
git add galaxy_game/app/services/ggmap_scientific_generator.rb
git add galaxy_game/app/services/geological_analysis_service.rb
git add galaxy_game/lib/ggmap.rb
git commit -m "feat: GGMap scientific layer — implement geological feature generation for planetary maps"
```