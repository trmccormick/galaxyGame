# Backlog Audit Verification Strategy

**Purpose**: Ensure audited/reclassified tasks remain relevant to current codebase and game mechanics.

---

## Verification Layers (Per File)

### Layer 1: File Artifacts Exist
- [ ] Primary service/model file exists (`app/services/*.rb`, `app/models/*.rb`)
- [ ] Primary spec file exists (`spec/services/*_spec.rb`, `spec/models/*_spec.rb`)
- [ ] Referenced documentation files still exist (doc paths may have moved)

**Action if failed**: Mark as **incomplete-concept** with note "Primary codebase artifacts missing"

### Layer 2: Referenced Documentation Paths Are Correct
- [ ] Linked docs in task exist at documented paths
- [ ] Docs haven't been moved/renamed since task creation
- [ ] Cross-references between docs still valid

**Examples of path changes to check**:
- `docs/wormhole_expansion/` → `docs/architecture/planning/`
- `docs/services/` → `docs/architecture/services/`
- Old reference style vs new path structure

**Action if failed**: Update all doc links in task to current paths before rewriting to TASK_TEMPLATE

### Layer 3: Game Mechanics Haven't Changed
- [ ] Feature described in task still works (run tests)
- [ ] Underlying models/attributes referenced still exist
- [ ] Service logic hasn't been superseded by newer code
- [ ] Acceptance criteria are still valid

**Examples of mechanic changes**:
- Model renamed or merged (`Settler` → `ColonyMember`)
- Attribute removed or renamed (`settlement.production` → `settlement.output_rate`)
- Service replaced by newer version (`FittingService v1` → `FittingService v2`)
- Method signature changed (`fit!(target, fit_data)` → `fit!(target, fit_data, options = {})`)

**Action if failed**: 
- If minor change: Flag and note the fix
- If major change: Mark as **silently-resolved** or **incomplete-concept**

### Layer 4: Codebase Still Supports Task Intent
- [ ] Services referenced still exist and are called
- [ ] Models referenced still have required associations
- [ ] Database tables/columns referenced still exist
- [ ] Tests still fail (for bug fixes) or still pass (for features already implemented)

**Action if failed**: 
- Bug fix where tests pass → **silently-resolved**
- Feature where code already implemented → **silently-resolved**
- Unclear integration → **incomplete-concept**

### Layer 5: Classification Decision

After all 4 layers:

| Layer 1 | Layer 2 | Layer 3 | Layer 4 | Classification |
|---------|---------|---------|---------|-----------------|
| ✅ | ✅ | ✅ | Tests pass | **silently-resolved** |
| ✅ | ✅ | ✅ | Tests fail | **correct-but-format-stale** → Rewrite to TASK_TEMPLATE |
| ✅ | ❌ | ✅ | Tests pass | **correct-but-format-stale** → Fix doc paths + rewrite |
| ✅ | ❌ | ✅ | Tests fail | **correct-but-format-stale** → Fix doc paths + rewrite |
| ✅ | ✅ | ❌ | Mechanic changed | **incomplete-concept** → Flag for decision |
| ❌ | - | - | - | **incomplete-concept** → Mark artifacts missing |

---

## Verification Checklist Template

For each file:

```
FILE: [filename]
DATE CREATED: [from file]
CLASSIFICATION: [TBD]

LAYER 1 — Artifacts:
  [ ] Primary service/model: [path] ✅/❌
  [ ] Primary spec: [path] ✅/❌
  [ ] Issue: [none / describe]

LAYER 2 — Doc Paths:
  [ ] Referenced docs exist: ✅/❌
  [ ] Path changes needed: [yes / no]
  [ ] Updated paths: [list changes]

LAYER 3 — Game Mechanics:
  [ ] Tests run: ✅/❌
  [ ] Tests pass/fail: [pass / fail / error]
  [ ] Mechanics changed: [yes / no]
  [ ] Description: [observations]

LAYER 4 — Codebase Support:
  [ ] Service logic current: ✅/❌
  [ ] Models have required attrs: ✅/❌
  [ ] Integration clear: ✅/❌
  [ ] Description: [observations]

FINAL CLASSIFICATION:
  → [silently-resolved / incomplete-concept / correct-but-format-stale]
  → Action: [Archive / Flag / Rewrite to TASK_TEMPLATE for phaseX]
```

---

## Current Backlog Progress

| # | File | Status | Classification | Action |
|---|------|--------|-----------------|--------|
| 1 | lunar_orbit_control | ✅ | silently-resolved | Archived |
| 2 | solstorm_lunar_surface | ✅ | silently-resolved | Archived |
| 3 | large_solar_array_deployment | ✅ | silently-resolved | Archived |
| 4 | solstorm_water_sourcing | ✅ | correct-but-format-stale | Rewritten phase6+ |
| 5 | wormhole_expansion_service | ✅ | correct-but-format-stale | Rewritten phase15+ |
| 6 | fitting_service_inventory | ⏳ | TBD | [Verifying...] |

---

## Notes for Future Auditors

- When task references "docs/wormhole_expansion/", check if it moved to "docs/architecture/planning/"
- When task references service methods, verify the method signature hasn't changed
- Always run tests for bug fixes to confirm current status
- Check git history for related commits that might have already fixed the issue
