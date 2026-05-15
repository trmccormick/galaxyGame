# 2026-03-24-MEDIUM-FEATURE-SCOUT-SEISMIC-SURVEY-IMPLEMENTATION

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Medium priority feature for scout seismic survey implementation
**Supervision Level**: 🔴 Watched carefully

## Context
Scout ships need seismic survey capability for asteroid conversion strategy. AI Manager requires structural integrity data before approving asteroids as Eden AWS Anchor candidates. StationCostBenefitAnalyzer needs to reject low-integrity asteroids.

## Problem Statement
Scout ships have no seismic survey capability. Asteroids lack structural_integrity_score and surveyed_at fields. StationCostBenefitAnalyzer cannot filter on integrity for Eden AWS Anchor placement.

**Expected**: Seismic survey mode classifies asteroid structural integrity and thermal risk. Analyzer rejects asteroids with integrity_score < 0.5 for Eden AWS Anchor placement.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/models/asteroid.rb` | Asteroid model | Add structural_integrity_score and surveyed_at fields |
| `app/services/ai_manager/wormhole_scouting_service.rb` | Scouting service | Add seismic mode to execute_scouting_mission method |
| `app/services/ai_manager/station_cost_benefit_analyzer.rb` | Cost-benefit analyzer | Add integrity gate for Eden AWS Anchor evaluation |

### Primary Files — you will create
| File | Purpose | Action |
|---|---|---|
| `db/migrate/[timestamp]_add_seismic_fields_to_asteroids.rb` | Migration | Add surveyed_at datetime and structural_integrity_score float columns |

## Implementation Steps
1. **Generate migration**: Create migration for surveyed_at datetime and structural_integrity_score float columns
2. **Run migration**: Execute migration in development and test environments
3. **Update asteroid model**: Add validations and scopes for new seismic fields
4. **Add seismic mode**: Implement seismic survey logic in WormholeScoutingService execute_scouting_mission method
5. **Add integrity gate**: Update StationCostBenefitAnalyzer to reject low-integrity asteroids for Eden AWS placement

## Acceptance Criteria
- [ ] Asteroid model has structural_integrity_score and surveyed_at fields
- [ ] Seismic survey mode classifies asteroids as Rubble Piles or Solid Anchors
- [ ] StationCostBenefitAnalyzer rejects asteroids with integrity_score < 0.5
- [ ] Migration runs successfully in dev and test environments

## Stop Conditions
- Breaking existing scouting or cost-benefit analysis functionality
- Changes beyond seismic survey implementation

## Commit Instructions
```bash
git add db/migrate/[timestamp]_add_seismic_fields_to_asteroids.rb
git add app/models/asteroid.rb
git add app/services/ai_manager/wormhole_scouting_service.rb
git add app/services/ai_manager/station_cost_benefit_analyzer.rb
git commit -m "feat: implement seismic survey logic for scout ships and asteroid integrity classification"
```