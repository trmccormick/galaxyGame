# TASK: Create Luna Settlement Mission Profile JSON

**Status**: BACKLOG
**Priority**: HIGH
**Type**: data
**Created**: 2026-05-01
**MVP Gate**: YES — this is the AI training artifact for Luna; without it the engine has nothing to execute
**Depends On**: None (pure data, no code dependencies)

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: JSON file creation following the exact schema and folder structure defined in this task. Copy npc_base_deploy_profile_v1.json pattern, substitute Luna parameters as shown.
**Supervision Level**: 🟡 Standard — check that task references use full `tasks_v2/` paths and `world_requirements` block is present

---

## Context and Design Principle

**This is the one acceptable Luna-specific file.** Everything else should be world-agnostic.
The profile is how we train the AI Manager on Luna's ISRU sequence. When the AI Manager
encounters a new body, it uses `PrecursorCapabilityService` to assess world properties and
selects the closest matching profile pattern from the library.

Luna is special only because it's first — not because it needs special Ruby code.

**Anti-patterns to avoid:**
- No hardcoded Luna logic in Ruby services
- No `if body.identifier == 'LUNA-01'` conditionals anywhere
- All phase tasks must reference generic `tasks_v2/` entries by path
- Parameters (not task rewrites) handle Luna-specific values

---

## What to Create

### Directory structure:
```
data/json-data/missions/luna_base_establishment/
  luna_settlement_profile_v1.json        ← mission profile (orchestrator)
  phases/
    phase_1_power_comms.json             ← initial power + comms tasks
    phase_2_isru_deployment.json         ← TEU + PVE deployment
    phase_3_gas_processing.json          ← gas separator + cryo storage
```

### Profile schema (follow npc_base_deploy_profile_v1.json pattern):
```json
{
  "template": "mission_profile",
  "mission_id": "luna_base_establishment",
  "name": "Luna Base Establishment",
  "description": "Bootstrap ISRU production on Luna. TEU extracts regolith volatiles during lunar day. PVE extracts oxygen. Gas Separator and cryo tanks store outputs overnight.",
  "manifest_file": "luna_base_establishment_manifest_v2.json",
  "world_requirements": {
    "body_type": "airless_rocky",
    "has_regolith": true,
    "gravity_range": [0.1, 0.3],
    "notes": "Pattern applies to any airless rocky body with regolith. Luna is the reference implementation."
  },
  "phases": [
    {
      "phase_id": "power_comms",
      "name": "Initial Power and Comms",
      "task_list_file": "phases/phase_1_power_comms.json"
    },
    {
      "phase_id": "isru_deployment",
      "name": "ISRU Unit Deployment",
      "task_list_file": "phases/phase_2_isru_deployment.json"
    },
    {
      "phase_id": "gas_processing",
      "name": "Gas Separation and Cryo Storage",
      "task_list_file": "phases/phase_3_gas_processing.json"
    }
  ],
  "parameters": {
    "target_body": "LUNA-01",
    "isru_mode": "regolith_teu_pve",
    "day_night_cycle_hours": 708,
    "early_isru_outputs": ["O2", "H2", "He3"],
    "mid_tier_outputs": ["H2O"],
    "import_dependencies": ["CH4", "N2"]
  },
  "success_conditions": {
    "complete_phases": ["power_comms", "isru_deployment", "gas_processing"],
    "isru_producing": true
  },
  "metadata": {
    "version": "1.0",
    "type": "mission_profile",
    "template_compliance": "mission_profile",
    "pattern_class": "airless_rocky_isru",
    "reference_body": "LUNA-01"
  }
}
```

### Phase files:
Each phase file must reference tasks using `tasks_v2/` paths (per missions/README.md convention).
Phase tasks must map to actual units in the ISRU flow:
- Phase 1: solar panels, comms, PUH/PPMU (power grid)
- Phase 2: TEU (thermal_extraction_unit), PVE (planetary_volatiles_extractor), inflatable pressure tank
- Phase 3: gas_separator, cryogenic_storage_tanks (daytime fill → nighttime separation cycle)

Also create `luna_base_establishment_manifest_v2.json` in the mission folder (replaces the
mis-placed root-level `luna_base_establishment_manifest_v1.json`).

---

## Acceptance Criteria
- Profile, 3 phase files, and manifest v2 created in correct folder structure
- All task references use `tasks_v2/task_name.json` path format (not bare names)
- `world_requirements` block present so AI Manager can pattern-match this profile to similar bodies
- `TaskExecutionEngineV2` can load and parse the profile without errors
- ✅ Root-level `luna_base_establishment_manifest_v1.json` already moved to `archived_missions/` (done 2026-05-02)
- `task_deploy_gas_separator.json` exists in `tasks_v2/` ✅ (created 2026-05-02) — Phase 3 can reference it

## Architecture Notes (established 2026-05-02)
- early_isru_outputs = O2, H2, He3 (regolith TEU/PVE, no specialized location)
- mid_tier_outputs = H2O (PSR ice mining, requires dedicated infrastructure)
- CO is NOT a Luna product — not in the hierarchy
- H2O is rationed for human consumption, NOT for fuel electrolysis
- Fuel strategy: LH2/LOX from regolith (H2 + O2 from TEU/PVE)
- See: docs/reference/CELESTIAL_BODY_DATA_CONVENTIONS.md
- See: docs/mission_profiles/LUNA_BASE_ESTABLISHMENT.md
