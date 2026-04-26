# TASK: Manufacturing Service Specs — Update UnitAssemblyJob Expectations to Job Model
**Status**: COMPLETED
#
## Completion Report
**Completed by**: GPT-4.1
**Completion date**: 2026-04-25
**Superseded by**: 2026-04-25-HIGH-BUG-FIX-BASE-SETTLEMENT-FACTORY-IDENTIFIER-UNIQUENESS.md

### What was changed
Nothing. Task was superseded before execution.

### Issues discovered
Full diagnostic session on 2026-04-25 revealed the manufacturing spec failures
were caused by a celestial_body identifier collision with preserved seed data in
the DatabaseCleaner except list — not stale UnitAssemblyJob references as
originally diagnosed. The specs never reached the service under test.
The collision source was not fully isolated. A full factory graph audit is
required. See backlog task: 2026-04-25-HIGH-BUGFIX-MANUFACTURING-SPEC-CELESTIAL-BODY-FACTORY-AUDIT.md

### Follow-up tasks needed
- Factory graph audit for celestial body identifier hardcoding
- Review DatabaseCleaner except list — celestial_bodies preservation may be
  causing broader spec interference

### Lessons learned
Always run a single spec with full error output before diagnosing spec 
assertions. Factory setup failures mask the real failure completely.
Preserved tables in DatabaseCleaner create invisible collision sources.
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-23
**Last Updated**: 2026-04-23

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Spec updates only — no application code changes. Fully specified pattern.
**Supervision Level**: 🔴 Watched carefully

> ⚠️ This task updates SPECS ONLY. Do not touch any service or model files.
> The services are correct — the specs have stale expectations.

---

## Context

Tasks 2-6 migrated manufacturing services from legacy job models to the unified
`Job` model. The specs for these services were not updated — they still expect
`UnitAssemblyJob`, `ComponentProductionJob` etc. to be created.

The service now creates `Job` records with `job_type` enum values instead.

**Read before starting:**
- `docs/architecture/systems/job_system_mechanics_spec.md`

---

## Problem Statement

**Error pattern:**
```
Failure/Error: expect(result[:success]).to be true
  expected true
       got false
```

Services return `false` because specs set up stale mocks or expectations against
legacy job models that no longer exist. The service tries to create a `Job` record
but the spec may be intercepting or not setting up factories correctly.

**Secondary error:**
```
NoMethodError: undefined method 'specifications' for nil
```
`job` is nil because the spec expected `UnitAssemblyJob.last` but service
created `Job.last`.

---

## Files Involved

### Primary Files — you will edit these (specs only)
| File | Failures |
|---|---|
| `galaxy_game/spec/services/manufacturing/service_spec.rb` | 5 failures |
| `galaxy_game/spec/services/manufacturing/assembly_service_spec.rb` | 1 failure (line 203) |
| `galaxy_game/spec/services/manufacturing/component_production_service_spec.rb` | 3 failures |
| `galaxy_game/spec/services/manufacturing/material_processing_service_spec.rb` | 1 failure |
| `galaxy_game/spec/services/manfacturing_service_spec.rb` | 3 failures (note typo in filename) |
| `galaxy_game/spec/services/manufacturing/shell_printing_service_spec.rb` | 3 failures |

### Do Not Touch
- Any file in `app/` — services are correct

---

## Implementation Steps

### Step 1 — Read each failing spec section

For each file, grep for the legacy job model references:
```bash
grep -n "UnitAssemblyJob\|ComponentProductionJob\|ShellPrintingJob\|MaterialProcessingJob\|process_tick" \
  galaxy_game/spec/services/manufacturing/service_spec.rb \
  galaxy_game/spec/services/manufacturing/assembly_service_spec.rb \
  galaxy_game/spec/services/manufacturing/component_production_service_spec.rb \
  galaxy_game/spec/services/manufacturing/material_processing_service_spec.rb \
  galaxy_game/spec/services/manfacturing_service_spec.rb \
  galaxy_game/spec/services/manufacturing/shell_printing_service_spec.rb
```

Paste output in Synthesis Report.

### Step 2 — Identify the pattern for each failure

Common patterns to fix:

**Pattern A — Expects legacy job class:**
```ruby
# Before
expect(UnitAssemblyJob.count).to eq(1)
job = UnitAssemblyJob.last

# After
expect(Job.where(job_type: :unit_assembly).count).to eq(1)
job = Job.where(job_type: :unit_assembly).last
```

**Pattern B — Creates legacy job in setup:**
```ruby
# Before
let(:job) { create(:unit_assembly_job) }

# After
let(:job) { create(:job, job_type: :unit_assembly) }
```

**Pattern C — Expects specific class returned:**
```ruby
# Before
expect(result[:job]).to be_a(UnitAssemblyJob)

# After
expect(result[:job]).to be_a(Job)
expect(result[:job].job_type).to eq('unit_assembly')
```

**Pattern D — job_type mapping:**
| Legacy Model | job_type value |
|---|---|
| `UnitAssemblyJob` | `:unit_assembly` |
| `ComponentProductionJob` | `:component_production` |
| `MaterialProcessingJob` | `:material_processing` |
| `ShellPrintingJob` | Use `ConstructionJob` with `job_type: :shell_printing` |

### Step 3 — Fix shell_printing_service_spec separately

`ShellPrintingService` now creates `ConstructionJob` records not `ShellPrintingJob`.
The spec needs to expect `ConstructionJob` with `job_type: :shell_printing`:

```ruby
# Before
expect(ShellPrintingJob.count).to eq(1)

# After
expect(ConstructionJob.where(job_type: :shell_printing).count).to eq(1)
```

### Step 4 — Fix the nil job issue in service_spec.rb:278

The spec at line 278 does:
```ruby
expect(job.specifications['name']).to eq(blueprint['name'])
```

`job` is nil because the previous assertion `result[:success]` failed and
`result[:job]` was never set. Fix the upstream failure first — if
`result[:success]` returns true after the factory fix, `result[:job]` will
be present and `specifications` will work.

Do not patch line 278 in isolation — fix the root cause first.

---

## Synthesis Report Format
```
LEGACY REFERENCES FOUND:
[file] line [N] — [legacy model] — [pattern type A/B/C/D]

SHELL PRINTING SPEC:
Expects ShellPrintingJob: YES/NO — lines: [N]

PROPOSED CHANGES:
[file] line [N] — [before] → [after]

RISK:
Any spec that tests behavior that no longer exists in the service?
(Flag for removal, not fix)

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

After each file fixed, run it in isolation:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/service_spec.rb 2>&1 | tail -5'
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/assembly_service_spec.rb 2>&1 | tail -5'
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/component_production_service_spec.rb 2>&1 | tail -5'
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/material_processing_service_spec.rb 2>&1 | tail -5'
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manfacturing_service_spec.rb 2>&1 | tail -5'
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/shell_printing_service_spec.rb 2>&1 | tail -5'
```

Then full manufacturing batch:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/ spec/services/manfacturing_service_spec.rb 2>&1 | tail -10'
```

---

## Acceptance Criteria
- [ ] Zero legacy job model references in all 6 spec files
- [ ] All manufacturing service specs green
- [ ] `shell_printing_service_spec` expects `ConstructionJob`
- [ ] No regressions in other service specs

---

## Stop Conditions
- A spec tests behavior the service no longer has — flag for removal, do not rewrite
- Fixing one spec causes another to fail — stop, report
- `result[:success]` still false after factory fix — stop, need service investigation

---

## Commit Instructions
```bash
git add galaxy_game/spec/services/manufacturing/ \
        galaxy_game/spec/services/manfacturing_service_spec.rb
git commit -m "fix: manufacturing service specs — update UnitAssemblyJob/legacy expectations to unified Job model"
```

---

## Dependencies
**Blocked by**: Nothing — spec-only changes
**Blocks**: Nothing
**Parallel safe**: Yes — run alongside logistics task
**Note**: Fix logistics factory task first if `create(:logistics_contract)` is
used in any manufacturing spec setup — unlikely but check.
