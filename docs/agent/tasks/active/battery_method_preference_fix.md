# Task: Fix battery_spec "prefers specialized methods over concern methods"

## Exact Symptom
- Line 101: expect(battery).to receive(:charge_battery).with(20.0) — 0 calls received
- Context: "interaction with BatteryManagement concern"

## Suspected Root Cause
- BatteryManagement concern defines generic charge method
- Specialized charge_battery method exists but not called due to method lookup order
- Test verifies method resolution preference (specialized > concern)

## Diagnostic Commands
docker exec -it web bash -c "
grep -n 'charge_battery\|def charge' app/models/units/battery.rb &&
grep -n 'BatteryManagement\|charge' app/models/concerns/battery_management.rb &&
grep -A10 -B5 'prefers specialized' spec/models/units/battery_spec.rb
"

## What NOT to Do
- Don't remove concern method (used elsewhere)
- Don't change test expectation (verifies correct architecture)
- Don't add method_missing (wrong solution)

## Stop Condition
Produce Synthesis Report after diagnostics. STOP. Await approval.

## Relevant Files
- app/models/units/battery.rb
- app/models/concerns/battery_management.rb
- spec/models/units/battery_spec.rb
Handoff Command (Copy-Paste to GPT-4.1)
text
Read docs/agent/README.md first, then your task file at:
docs/agent/tasks/active/battery_method_preference_fix.md

[HIGH] ISSUE: battery_spec expects charge_battery(20.0) called, received 0

The issue:
- expect(battery).to receive(:charge_battery).with(20.0) — line 101
- Test verifies specialized method preferred over BatteryManagement concern
- Method resolution failing

Your tasks:
1. Read task file completely before touching anything
2. Run diagnostic commands in task file
3. Produce Synthesis Report and STOP — wait for approval
4. Apply approved fix only
5. rspec spec/models/units/battery_spec.rb — confirm 0 failures
6. rspec spec/models/units/ — confirm no regressions
7. Commit from host: "Fix battery_spec method resolution preference"
8. Report results

Priority: HIGH
Estimated time: 20-30 minutes
Agent: Mid-tier — method lookup analysis across concern + model