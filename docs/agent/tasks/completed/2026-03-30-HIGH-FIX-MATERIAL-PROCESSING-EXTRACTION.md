TASK: MaterialProcessingService extraction job failures (6 specs)
Status: ACTIVE
Priority: HIGH
Type: bug-fix
Created: 2026-03-30
Last Updated: 2026-03-30

Agent Assignment
Assigned To: GPT-4.1 0x
Why This Agent: 6 related extraction specs, shared job/inventory logic, diagnostic-driven
Supervision Level: 🔴 Watched carefully

Context
MaterialProcessingService handles ISRU thermal/volatiles extraction creating MaterialProcessingJob records and updating inventory. 6 specs fail on job creation (46,62), inventory updates (62,110), and insufficient material checks (73,125). Likely shared issue with job record creation, inventory quantity handling, or material composition.

Relevant Architecture Docs:

docs/architecture/manufacturing.md — ISRU job patterns

docs/developer/practical_testing_guide.md — service spec patterns

Problem Statement
6 specs fail across thermal/volatiles extraction workflow:

Lines 46,94: Job record creation fails

Lines 62,110: Inventory not updated correctly after completion

Lines 73,125: Insufficient material error handling broken

Current behavior: Jobs not created, inventory unchanged, error conditions fail
Expected behavior: Jobs created → inventory processed → correct error returns

Files Involved
Primary Files — you will edit these
File	Purpose	Key Methods
app/services/manufacturing/material_processing_service.rb	Extraction logic	#thermal_extraction, #volatiles_extraction
spec/services/manufacturing/material_processing_service_spec.rb	Failing specs	lines 46,62,73,94,110,125
Reference Files — read but do not edit
File	Why You Need It
app/models/material_processing_job.rb	Job validations
spec/factories/materials.rb	Material factory structure
app/services/manufacturing/inventory_service.rb	Inventory update pattern
Migration (if needed)
No migration needed

Implementation Steps
Step 1 — Diagnostics (run ALL exactly)
bash
docker exec -it web bash -c 'grep -n "thermal_extraction\\|volatiles_extraction\\|create.*job" app/services/manufacturing/material_processing_service.rb'
docker exec -it web bash -c 'grep -A15 -B5 "46\\|62\\|73\\|94\\|110\\|125" spec/services/manufacturing/material_processing_service_spec.rb'
docker exec -it web bash -c 'grep -n "inventory\\|quantity\\|material_type" app/models/material_processing_job.rb 2>/dev/null || echo "No job model found"'
docker exec -it web bash -c 'grep -n "update\\|decrement\\|increment.*inventory" app/services/manufacturing/material_processing_service.rb'
Step 2 — Produce Synthesis Report and STOP
Step 3 — Common Fix Patterns
Pattern A: Job creation missing required fields

ruby
# BEFORE
MaterialProcessingJob.create!(params)

# AFTER
MaterialProcessingJob.create!(
  params.merge(
    status: 'pending',
    settlement_id: @settlement.id,
    material_type: input_material.material_type
  )
)
Pattern B: Inventory update after job completion

ruby
# AFTER job completion
def complete_job(job)
  inventory_service.decrement_raw_materials(job.settlement, job.input_requirements)
  inventory_service.increment_processed_materials(job.settlement, job.output_composition)
  job.update(status: 'completed')
end
Pattern C: Insufficient material error handling

ruby
# BEFORE
job = MaterialProcessingJob.create!(params)

# AFTER
unless settlement.inventory.has_sufficient?(input_material, quantity)
  return { error: "Insufficient #{input_material.material_type}" }
end
job = MaterialProcessingJob.create!(params)
Synthesis Report Format
text
THE FAILURE
Specs: material_processing_service_spec.rb:[46,62,73,94,110,125]
Errors: [paste exact job creation/inventory errors]

ROOT CAUSE
[shared job creation failure, inventory update missing, etc]

PROPOSED FIX
1. [app/services/...rb] — [exact change]
2. [if needed] [file] — [change]

FILES AFFECTED
[list files + purpose]

RISK
[factory/service impact assessment]

READY TO APPLY?
Testing Sequence
Isolation:

bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/material_processing_service_spec.rb'
Manufacturing services:

bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/'
Acceptance Criteria
Isolation spec: 0 failures (was 6)

Manufacturing services: no regressions

thermal_extraction creates job + updates inventory ✓

volatiles_extraction creates job + correct composition ✓

Insufficient material returns error ✓

Stop Conditions
Job model requires migration

Inventory service interface changed

Material factory missing required composition

Commit Instructions
bash
git add app/services/manufacturing/material_processing_service.rb
git add spec/services/manufacturing/material_processing_service_spec.rb  # if needed
git commit -m "fix: MaterialProcessingService extraction — job creation + inventory (6 specs)"
git push
Documentation
No doc changes needed

Dependencies
Blocked by: none
Blocks: none
Related tasks: none

Completion Report
Filled by implementing agent