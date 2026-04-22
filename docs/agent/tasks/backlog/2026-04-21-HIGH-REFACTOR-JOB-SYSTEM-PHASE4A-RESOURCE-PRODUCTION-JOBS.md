# TASK: Job System Phase 4a — Migrate Resource Production Jobs to Unified Job Model
**Status**: BACKLOG
**Priority**: HIGH
**Type**: refactor
**Created**: 2026-04-21
**Last Updated**: 2026-04-21

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Targeted extraction of production job call sites only. Logistics call sites are explicitly out of scope and listed below — do not touch them.
**Supervision Level**: 🔴 Watched carefully

> ⚠️ This task handles ONLY production job call sites in resource services.
> Import/logistics call sites (earth_import, scheduled_import, contracted_harvesting)
> are handled in Task 4b. Do not touch them here.
> If you are unsure whether a call site is production or logistics — STOP and ask.

---

## Context

Task 1 must be complete. `resource/acquisition.rb` and related files conflate
two different concepts that are being separated:

- **Production jobs** (`resource_processing`, `environment_processing`) → `Job` model
- **Logistics/imports** (`earth_import`, `scheduled_import`, `contracted_harvesting`) → `ImportOrder` model (Task 4b)

This task handles production jobs only.

**Read before starting:**
- `docs/architecture/systems/job_system_mechanics_spec.md`
- `docs/architecture/logistics/logistics_architecture.md` — understand the boundary
- `galaxy_game/app/models/job.rb` — confirm exists

---

## The Boundary — Production vs Logistics

| Call site type | This task | Task 4b |
|---|---|---|
| `ResourceJob.create!` where job runs locally at a facility | ✅ migrate to `Job` | ❌ |
| `ResourceJob.create!` where `job_type: 'earth_import'` | ❌ leave alone | ✅ |
| `ResourceJob.create!` where `job_type: 'scheduled_import'` | ❌ leave alone | ✅ |
| `ResourceJob.create!` where `job_type: 'contracted_harvesting'` | ❌ leave alone | ✅ |
| `ResourceJob.where(job_type: 'earth_import')` queries | ❌ leave alone | ✅ |

If a call site is ambiguous — stop and report. Do not guess.

---

## Files Involved

### Primary Files — you will edit these
| File | Notes |
|---|---|
| `galaxy_game/app/services/resource/acquisition.rb` | Mixed — production AND logistics call sites. Extract production only. |
| `galaxy_game/app/services/resource/job_processor.rb` | Evaluate — may be partially superseded by JobProcessorWorker |
| `galaxy_game/app/services/ai_manager/resource_planner.rb` | Remove NameError rescue guard, update production job queries only |

---

## Implementation Steps

### Step 1 — Confirm Job model exists
```bash
cat galaxy_game/app/models/job.rb | head -20
```
If missing — stop.

### Step 2 — Read all three files in full
```bash
cat galaxy_game/app/services/resource/acquisition.rb
cat galaxy_game/app/services/resource/job_processor.rb
cat galaxy_game/app/services/ai_manager/resource_planner.rb
```

For each `ResourceJob` call site, classify it:
- Production (local facility job) → migrate to `Job` in this task
- Logistics (import/transit) → leave completely alone, note in Synthesis Report

### Step 3 — Evaluate resource/job_processor.rb
Compare with `JobProcessorWorker`:
```bash
cat galaxy_game/app/workers/job_processor_worker.rb
```

Does `job_processor.rb` duplicate logic now in `JobProcessorWorker`?
- If fully superseded → flag for removal in Task 7, leave file alone for now
- If contains unique logic → update production job queries, leave logistics alone

### Step 4 — Update production call sites only
```ruby
# Before — local production job
job = ResourceJob.create!(
  settlement: settlement,
  owner: owner,
  completes_at: Time.current + duration,
  # no job_type: 'earth_import' or 'scheduled_import'
)

# After
job = Job.create!(
  job_type: :resource_processing,
  settlement: settlement,
  owner: owner,
  completes_at: Time.current + duration,
)
```

### Step 5 — Update resource_planner.rb production queries
Remove NameError rescue guard, update production queries:
```ruby
# Before
begin
  jobs = ResourceJob.where(settlement: @settlement).active
rescue NameError
  { status: "ResourceJob model missing." }
end

# After — production jobs only
jobs = Job.where(
  settlement: @settlement,
  job_type: :resource_processing,
  status: :in_progress
)
```

Leave any logistics queries (`earth_import`, `scheduled_import`) completely alone.

### Step 6 — Verify only production references changed
```bash
grep -n "ResourceJob" \
  galaxy_game/app/services/resource/acquisition.rb \
  galaxy_game/app/services/resource/job_processor.rb \
  galaxy_game/app/services/ai_manager/resource_planner.rb
```
Remaining `ResourceJob` references should be logistics call sites only.
Note them in completion report for Task 4b.

---

## Synthesis Report Format
```
CURRENT STATE
Job model exists: YES/NO

CALL SITE CLASSIFICATION
acquisition.rb:
  Line [N] — [production/logistics] — [description]
  ... one line per call site

job_processor.rb:
  Superseded by JobProcessorWorker: YES/NO/PARTIAL
  Unique logic worth preserving: [describe or NONE]

resource_planner.rb:
  Production queries: [lines]
  Logistics queries: [lines — leave alone]

PROPOSED CHANGES — production call sites only
[file] line [N] — [change]

LOGISTICS CALL SITES — NOT TOUCHING (Task 4b)
[file] line [N] — [job_type] — leaving alone

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence
1. Resource specs:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/resource/'
```

2. AI manager specs:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/'
```

3. Full services:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/'
```

4. Full suite:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

---

## Acceptance Criteria
- [ ] Job model confirmed present
- [ ] All production call sites migrated to `Job`
- [ ] Logistics call sites untouched — confirmed in grep output
- [ ] NameError rescue guard removed from resource_planner.rb
- [ ] job_processor.rb evaluated and flagged if superseded
- [ ] Resource and AI manager specs green
- [ ] No regressions

---

## Stop Conditions
- Job model missing — stop
- Cannot determine if a call site is production or logistics — stop, report
- Any unrelated spec failure — stop immediately

---

## Commit Instructions
```bash
git add galaxy_game/app/services/resource/acquisition.rb \
        galaxy_game/app/services/resource/job_processor.rb \
        galaxy_game/app/services/ai_manager/resource_planner.rb
git commit -m "refactor: resource services — migrate production ResourceJob calls to unified Job model"
```

---

## Dependencies
**Blocked by**: Task 1
**Blocks**: Task 4b (logistics migration), Task 7 (legacy retirement)
**Related**: Tasks 2, 3, 5, 6 (parallel)
**Read**: `docs/architecture/logistics/logistics_architecture.md`
