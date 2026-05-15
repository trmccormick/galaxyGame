# TASK: Fix Luna Settlement Integration Spec — API Usage Corrections
**Status**: COMPLETED
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-05-12
**Last Updated**: 2026-05-14
**MVP Gate**: YES — fixes 3 Luna settlement spec failures
**Supersedes**: 2026-05-01-HIGH-SPEC-LUNA-SETTLEMENT-INTEGRATION-MVP-ACCEPTANCE.md

---

## Agent Assignment
**Assigned To**: GPT-4.1 (0x)
**Why This Agent**: Mechanical API corrections in existing spec file. No inference needed, exact fixes specified.
**Supervision Level**: 🔴 Watched carefully

---

## Context
The Luna settlement integration spec exists but has API usage issues that cause 3 test failures. The spec was created but doesn't properly initialize services or use correct method signatures.

---

## Problem Statement
**Current failures:**
```
rspec ./spec/services/ai_manager/luna_settlement_integration_spec.rb:12 # Luna Settlement Integration (MVP) world assessment reads real DB data
rspec ./spec/services/ai_manager/luna_settlement_integration_spec.rb:18 # Luna Settlement Integration (MVP) engine loads Luna profile and builds task plan
rspec ./spec/services/ai_manager/luna_settlement_integration_spec.rb:34 # Luna Settlement Integration (MVP) engine uses world properties, not hardcoded values
```

**Root causes:**
1. `TaskExecutionEngineV2` expects manifest hash, but spec passes file path string
2. `MaterialProcessingService` API usage doesn't match actual service methods
3. Missing JSON file loading for profile data

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose |
|---|---|
| `spec/services/ai_manager/luna_settlement_integration_spec.rb` | Fix API calls and data loading |

### Reference Files — read but do not edit
| File | Why |
|---|---|
| `app/services/ai_manager/task_execution_engine_v2.rb` | Understand manifest parameter requirements |
| `app/services/manufacturing/material_processing_service.rb` | Check correct API methods |
| `data/json-data/missions/luna_base_establishment/luna_settlement_profile_v1.json` | Profile structure for loading |

---

## Implementation Steps

### Step 1 — Load profile JSON data
Replace file path usage with actual JSON loading:

```ruby
# BEFORE (broken)
let(:profile_path) { "data/json-data/missions/luna_base_establishment/luna_settlement_profile_v1.json" }
engine = AIManager::TaskExecutionEngineV2.new(@luna.identifier, profile_path)

# AFTER (fixed)
let(:profile_data) { JSON.parse(File.read("data/json-data/missions/luna_base_establishment/luna_settlement_profile_v1.json")) }
engine = AIManager::TaskExecutionEngineV2.new(@luna.identifier, profile_data)
```

### Step 2 — Fix MaterialProcessingService API
Update to use correct service methods:

```ruby
# BEFORE (wrong API)
service = Manufacturing::MaterialProcessingService.new(@settlement)
job = service.process(unit, "regolith", 1000)

# AFTER (correct API - check service for exact method names)
service = Manufacturing::MaterialProcessingService.new(@settlement)
job = service.create_processing_job(job_type: "thermal_extraction", unit_type: "teu")
```

### Step 3 — Verify all tests pass
Run: `docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/luna_settlement_integration_spec.rb'`

Expected: 4 examples, 0 failures

---

## Acceptance Criteria
- [ ] All 4 Luna settlement spec examples pass
- [ ] No NameError or NoMethodError exceptions
- [ ] TaskExecutionEngineV2 receives proper manifest hash
- [ ] MaterialProcessingService uses correct API
- [ ] Profile JSON loads correctly

---

## Stop Conditions — escalate to user immediately if:
- Service APIs have changed and don't match documentation
- Profile JSON file is malformed or missing
- Database seeding issues prevent Luna lookup

---

## Commit Instructions
Run git commands on **host**, not inside container:
```bash
git add spec/services/ai_manager/luna_settlement_integration_spec.rb
git commit -m "fix: luna_settlement_integration_spec — correct API usage for TaskExecutionEngineV2 and MaterialProcessingService"
git push
```

---

## Documentation
- [ ] No doc changes needed

---

## Dependencies
**Blocked by**: None
**Blocks**: Luna settlement MVP completion
**Related tasks**: 2026-05-01-HIGH-SPEC-LUNA-SETTLEMENT-INTEGRATION-MVP-ACCEPTANCE.md (superseded)</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/2026-05-12-HIGH-BUGFIX-LUNA-SETTLEMENT-INTEGRATION-SPEC-API-FIXES.md