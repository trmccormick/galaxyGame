# 2026-04-17-HIGH-MESO-WORLDHOUSE-CONSTRUCTION

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — High priority meso feature for worldhouse construction implementation
**Supervision Level**: 🔴 Watched carefully

## Context
Worldhouse construction is foundation for enclosed valley terraforming, planetary habitat prototyping, asteroid/moon conversion to orbital stations/depots. Built on suitable features (valley, crater, lava tube, excavated cavity) divided into segments using I-beam and panel technology.

## Problem Statement
No segment-based worldhouse construction logic implemented. No progress tracking, enclosure metrics, integration with maintenance/failure systems.

**Expected**: Segment-based construction with status tracking, enclosure calculations, orchestration via WorldhouseConstructionService, geological feature integration.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/models/structures/worldhouse.rb` | Worldhouse model | Add construction status, enclosure logic |
| `app/models/structures/worldhouse_segment.rb` | Segment model | Add segment status tracking |
| `app/services/construction/worldhouse_construction_service.rb` | Orchestration service | Implement feature conversion, job scheduling |
| `app/services/covering/segment_covering_service.rb` | Covering service | Integrate with component/material systems |
| `app/models/structures/segment_component.rb` | Component model | Add material requirements |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `docs/worldhouse_progression_system.md` | Progression system |
| `docs/architecture/construction_system.md` | Construction methodology |
| `data/json-data/missions/mars_settlement/phases/mars_genesis_phase0_phobos_deimos_conversion.json` | Use case example |

## Implementation Steps
1. **Segment logic**: Construction status, area, enclosure logic in worldhouse models
2. **Orchestration**: WorldhouseConstructionService for feature conversion, segment generation, job scheduling
3. **Covering & materials**: Integration with SegmentCoveringService and component/material systems
4. **Progress tracking**: recalculate_progress! and enclosure metrics updates
5. **Testing**: RSpec for construction completion, segment status, enclosure metrics, orchestration

## Acceptance Criteria
- [ ] Construction status tracked per segment (planned, materials_requested, under_construction, enclosed, operational)
- [ ] Enclosure and coverage metrics calculated and updated on progress
- [ ] Orchestration logic schedules segment jobs, aligns skylights, updates feature status
- [ ] Material/component requirements calculated and requested per segment
- [ ] RSpec: construction completion, segment status, enclosure metrics, orchestration edge cases

## Stop Conditions
- Duplicate or obsolete worldhouse construction logic exists in other tasks/docs

## Commit Instructions
```bash
git add app/models/structures/worldhouse.rb
git add app/models/structures/worldhouse_segment.rb
git add app/services/construction/worldhouse_construction_service.rb
git add app/services/covering/segment_covering_service.rb
git add app/models/structures/segment_component.rb
git add spec/models/structures/worldhouse_spec.rb
git add spec/models/structures/worldhouse_segment_spec.rb
git add spec/services/construction/worldhouse_construction_service_spec.rb
git commit -m "feat: worldhouse construction — implement segment-based construction and orchestration"
```