TASK: MaterialProcessingService inventory/error handling (4 specs)
Status: ACTIVE
Priority: HIGH
Type: bug-fix
Created: 2026-03-30
Last Updated: 2026-03-30

Agent Assignment
Assigned To: GPT-4.1 0x
Why This Agent: Remaining 4 specs same service, inventory/error logic, diagnostic-driven
Supervision Level: 🔴 Watched carefully

Context
MaterialProcessingService.complete_*_extraction methods and insufficient material checks fail after job creation fix. Lines 62,110 test inventory updates post-completion; 73,125 test error handling. Likely complete_thermal_extraction/complete_volatiles_extraction missing inventory delta application or insufficient checks inverted.

Relevant Architecture Docs:

docs/architecture/manufacturing.md — inventory update patterns

docs/architecture/isru.md — extraction composition flow

Problem Statement
4 specs fail post-job-creation fix:

Lines 62,110: Inventory not updated after job completion

Lines 73,125: Insufficient material errors not triggered

Current behavior: No inventory change, errors not raised
Expected behavior: Inventory decremented/updated on completion, errors on insufficient input

Files Involved
Primary Files
File	Purpose	Key Methods
app/services/manufacturing/material_processing_service.rb	Completion/error logic	#complete_thermal_extraction, #complete_volatiles_extraction
spec/services/manufacturing/material_processing_service_spec.rb	Remaining failures	lines 62,73,110,125
Reference Files
File	Why You Need It
app/services/manufacturing/inventory_service.rb	Expected inventory delta pattern
data/json-data/units/isru_units.json	TEU/PVE output composition
Implementation Steps
Step 1 — Diagnostics (run ALL)
bash
docker exec -it web bash -c 'grep -n "complete_.*extraction\\|update.*amount\\|insufficient\\|decrement" app/services/manufacturing/material_processing_service.rb'
docker exec -it web bash -c 'grep -A15 -B5 "62\\|73\\|110\\|125" spec/services/manufacturing/material_processing_service_spec.rb'
docker exec -it web bash -c 'grep -n "input_requirements\\|output_composition" app/models/material_processing_job.rb'
docker exec -it web bash -c 'head -10 data/json-data/units/isru_units.json | grep -i "thermal\\|volatiles"'
Step 2 — Synthesis Report and STOP
Step 3 — Fix Patterns
Pattern A: Complete extraction inventory update

ruby
# BEFORE (likely)
def complete_thermal_extraction(job)
  # missing inventory delta
end

# AFTER
def complete_thermal_extraction(job)
  # decrement raw regolith
  job.settlement.inventory.decrement_material('raw_regolith', job.input_amount)
  
  # increment processed outputs per TEU_DATA
  teu_outputs = { 'processed_regolith' => job.input_amount * 0.8, 'silica' => job.input_amount * 0.15 }
  teu_outputs.each { |type, qty| job.settlement.inventory.increment_material(type, qty) }
end
Pattern B: Insufficient check

ruby
# BEFORE
MaterialProcessingJob.create!(params)

# AFTER
unless @settlement.inventory.has_sufficient?(input_material.material_type, input_amount)
  return { error: "Insufficient #{input_material.material_type}" }
end
Testing Sequence
Isolation:

bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/material_processing_service_spec.rb'
Manufacturing:

bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/'
Acceptance Criteria
Isolation: 0 failures (was 4)

Inventory updated correctly post-completion

Insufficient material returns error

No manufacturing regressions

Stop Conditions
Inventory service interface differs

JSON data composition changed

Job model output_composition missing

Commit Instructions
bash
git add app/services/manufacturing/material_processing_service.rb
git commit -m "fix: MaterialProcessingService — inventory/error handling (4 specs)"
git push