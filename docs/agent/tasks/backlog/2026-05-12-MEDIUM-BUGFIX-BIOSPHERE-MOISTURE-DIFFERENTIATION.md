# TASK: BiosphereSimulationService — balance_biomes Not Differentiating Moisture
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: bug-fix
**Created**: 2026-05-12
**Last Updated**: 2026-05-12

---

## Agent Assignment
**Assigned To**: GPT-4.1 (0.75x)
**Why This Agent**: Straightforward climate-based branching logic in single method with clear spec expectations
**Supervision Level**: 🟢 Light oversight

---

## Context
`TerraSim::BiosphereSimulationService#balance_biomes` adjusts biome moisture
levels. The spec expects tropical biomes to have higher moisture than arid biomes
after balancing. Currently both get identical moisture levels — the method is not
differentiating by climate type.

---

## Problem Statement
**Error:**
```
expected: tropical_biome.moisture_level > arid_biome.moisture_level
     got: tropical: 1, arid: 1 (identical)
spec/services/terra_sim/biosphere_simulation_service_spec.rb:178
```
**Current behavior**: `balance_biomes` sets identical moisture regardless of climate type
**Expected behavior**: Tropical biome moisture > arid biome moisture after balancing

---

## Files Involved

### Primary Files
| File | Purpose |
|---|---|
| `app/services/terra_sim/biosphere_simulation_service.rb` | Fix `balance_biomes` to differentiate by climate type |

### Reference Files
| File | Why |
|---|---|
| `spec/services/terra_sim/biosphere_simulation_service_spec.rb` lines 155-185 | Exact expectations |
| `app/models/biome.rb` or equivalent | Understand moisture_level and climate_type fields |

---

## Implementation Steps

### Step 1 — Read spec and service
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && sed -n "155,185p" spec/services/terra_sim/biosphere_simulation_service_spec.rb'
```
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && grep -n "balance_biomes\|moisture_level\|climate_type" app/services/terra_sim/biosphere_simulation_service.rb'
```

### Step 2 — Run failing spec
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/terra_sim/biosphere_simulation_service_spec.rb:158 2>&1 | tail -20'
```

### Step 3 — Understand the biome model
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && grep -n "moisture_level\|climate_type" app/models/*.rb app/models/**/*.rb 2>/dev/null | head -20'
```

### Step 4 — Produce Synthesis Report and STOP
```
SYNTHESIS REPORT
balance_biomes current logic: [describe]
moisture_level field: [column or operational_data]
climate_type field: [column or operational_data]
Does method check climate_type: [YES/NO]
Proposed fix: [show before/after]
Risk: [other specs using balance_biomes]
```
Wait for approval before changing anything.

### Step 5 — Apply fix
Add climate_type check to `balance_biomes` so tropical moisture > arid moisture.
Keep the fix minimal — only what the spec requires.

### Step 6 — Verify
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/terra_sim/biosphere_simulation_service_spec.rb 2>&1 | tail -10'
```

### Step 7 — Check for regressions
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/terra_sim/ 2>&1 | tail -10'
```

### Step 8 — Commit from host
```bash
git add app/services/terra_sim/biosphere_simulation_service.rb
git commit -m "fix: biosphere_simulation_service — balance_biomes differentiates moisture by climate type"
git push
```

---

## Acceptance Criteria
- [ ] Spec line 158 passes
- [ ] tropical moisture > arid moisture after balance_biomes
- [ ] No regressions in terra_sim specs

## Stop Conditions
- moisture_level or climate_type not a simple field — escalate
- Fix requires changes to biome model or migrations — escalate
- More than 3 other specs use balance_biomes — escalate

## Completion Report
**Completed by**:
**Completion date**:
**Final test result**:
### What was changed
### Issues discovered
### Follow-up tasks needed
