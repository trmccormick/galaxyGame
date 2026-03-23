# Task: Fix Units::BaseUnit spec "processes material based on composition"

## Exact Symptom
- `expected: 100, got: nil` for `base_unit.operational_data.dig('storage', 'gas_buffer', 'capacity')`
- Despite mock on Lookup::UnitLookupService.new and operational_data: nil in create

## Suspected Root Cause
- load_unit_info calls save! after setting operational_data, re-triggering factory :after_create or unmocked service
- Mock timing issue during callback recursion

## Diagnostic Commands (run these first)
docker exec -it web bash -c "
grep -n 'load_unit_info\|save!\|operational_data' app/models/units/base_unit.rb &&
grep -A5 -B5 'processes material' spec/models/units/base_unit_spec.rb &&
rspec spec/models/units/base_unit_spec.rb:LINE_NUMBER --format documentation
"

## What NOT to Do
- Don't change factory defaults broadly
- Don't remove save! without checking downstream effects
- Don't assume mocking issue — confirm with debug first

## Stop Condition
Produce Synthesis Report after diagnostics (include output). STOP. Await approval before any code changes.

## Relevant Files
- app/models/units/base_unit.rb
- spec/models/units/base_unit_spec.rb
- spec/factories/units/units.rb [file:11]
Handoff Command (Copy-paste to GPT-4.1)
text
Read docs/agent/README.md first, then your task file at:
docs/agent/tasks/active/base_unit_callback_mock_fix.md

[CRITICAL] ISSUE: BaseUnit spec fails on operational_data despite mock + nil override

The issue:
- expected: 100, got: nil in processes material based on composition
- load_unit_info callback's save! likely re-triggers factory or unmocked service [file:11]

Your tasks:
1. Read the task file completely before touching anything
2. Run the diagnostic commands in the task file
3. Produce a Synthesis Report and STOP — wait for approval
4. Apply the approved fix only
5. Run: rspec spec/models/units/base_unit_spec.rb — confirm 0 failures
6. Run: rspec spec/models/units/ — confirm no regressions
7. Commit from host with descriptive message
8. Report back with test results and any issues discovered

Priority: CRITICAL
Estimated time: 45-90 minutes
Agent: Mid-tier implementation agent — callback debugging, some inference on Rails lifecycle needed [file:11]