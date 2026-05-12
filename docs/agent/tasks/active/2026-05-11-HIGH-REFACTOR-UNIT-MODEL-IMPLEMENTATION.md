# TASK: Unit Model Architecture Refactor — Implementation
**Status**: READY — Grok synthesis approved 2026-05-11
**Priority**: HIGH
**Type**: refactor
**Created**: 2026-05-06
**Last Updated**: 2026-05-11

---

## Agent Assignment
**Assigned To**: GPT-4.1 (0x)
**Why This Agent**: Patterns fully specified, zero inference needed, Grok confirmed safe
**Supervision Level**: 🔴 Watched carefully — BaseUnit used everywhere

---

## Locked Decisions (do not deviate)

These were approved by human on 2026-05-11. Read before touching anything.

**Habitat unit has one job**: expose `population_capacity` from `operational_data`.
- Remove ALL `Resource.consume` / `Resource.produce` calls — dead code
- Remove ALL population management logic — belongs on Settlement/Craft concern
- No inventory adjustment in Habitat — services do that

**`.old` files**: `lunar_regolith_processor.rb.old` and `moxie_unit.rb.old` are
mid-refactor placeholders. Restore them as `.rb`, rewrite to Robot/Battery pattern,
then delete the `.old` files after specs pass.

**Hardcoded unit type methods**: Zero call sites confirmed by grep.
Safe to remove immediately.

**Reference pattern**: Follow `robot.rb` and `battery.rb` exactly.
Read them first. Every decision flows from that pattern.

---

## Handoff Command

```
Read docs/agent/README.md first, then this task file.

BEFORE DOING ANYTHING ELSE — prove you read the README.
Your first response must contain ONLY this confirmation block:

  README READ CONFIRMATION
  Rule 1 (Docker): [paste verbatim]
  Rule 7 (RSpec Output): [paste verbatim]
  Rule 10 (Host vs Docker paths): [paste verbatim]

Do not proceed until confirmed.

---

HIGH: Unit Model Architecture Refactor — Implementation

Context: Grok synthesis completed 2026-05-11. Patterns confirmed. Safe for 0x execution.

Step 1 — Read reference patterns first (do not edit):
  app/models/units/robot.rb
  app/models/units/battery.rb

Step 2 — Remove hardcoded methods from base_unit.rb
  Remove lines 609-617 (atmospheric_unit_types, geosphere_unit_types, extraction_unit_types)
  Replacement methods already exist at lines 41-51 — do not add them again.
  Confirm with grep before removing:
  grep -n "atmospheric_unit_types\|geosphere_unit_types\|extraction_unit_types" app/models/units/base_unit.rb

Step 3 — Rewrite habitat.rb
  Habitat has ONE job: expose population_capacity from operational_data.
  
  Final habitat.rb must contain:
  - population_capacity reads from operational_data
  - Nothing else except what the Robot/Battery pattern requires
  - NO Resource.consume or Resource.produce calls
  - NO population management logic
  - NO save without bang (use save!)
  - NO overlap with PopulationManagement concern
  
  ```ruby
  module Units
    class Habitat < BaseUnit
      def population_capacity
        operational_data&.dig('habitat_systems', 'capacity') || 0
      end
    end
  end
  ```
  Keep only what operational_data supports. Do not add methods not in the pattern.

Step 4 — Restore and rewrite lunar_regolith_processor.rb
  cp app/models/units/lunar_regolith_processor.rb.old \
     app/models/units/lunar_regolith_processor.rb
  
  Rewrite to Robot/Battery pattern:
  - energy_consumption reads from operational_data
  - process_regolith uses store_resource (same as Robot pattern)
  - No direct operational_data modification
  - No attr_accessor, no initialize override
  
  ```ruby
  module Units
    class LunarRegolithProcessor < BaseUnit
      def energy_consumption
        operational_data&.dig('operational_properties', 'power_consumption_kw') || 200
      end

      def process_regolith(amount)
        return false if amount <= 0
        oxygen_produced = (amount / 2.0).floor
        store_resource('O2', oxygen_produced)
      end
    end
  end
  ```

Step 5 — Restore and rewrite moxie_unit.rb
  cp app/models/units/moxie_unit.rb.old \
     app/models/units/moxie_unit.rb
  
  Rewrite to Robot/Battery pattern:
  - energy_consumption reads from operational_data
  - oxygen_output reads from operational_data output_resources
  - No direct operational_data modification
  
  ```ruby
  module Units
    class MoxieUnit < BaseUnit
      def energy_consumption
        operational_data&.dig('operational_properties', 'power_consumption_kw') || 100
      end

      def oxygen_output
        operational_data&.dig('output_resources')
          &.find { |r| r['id'] == 'O2' }
          &.dig('amount') || 10
      end

      def activate
        store_resource('O2', oxygen_output)
      end
    end
  end
  ```

Step 6 — Run unit specs
  docker compose exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/units/ 2>&1 | tail -20'
  Report results. Flag any new failures before continuing.

Step 7 — Run full model specs
  docker compose exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/ 2>&1 | tail -20'
  Report results. Flag any regressions.

Step 8 — Delete .old files (only after specs pass)
  rm app/models/units/lunar_regolith_processor.rb.old
  rm app/models/units/moxie_unit.rb.old

Step 9 — Commit from host
  git add app/models/units/base_unit.rb
  git add app/models/units/habitat.rb
  git add app/models/units/lunar_regolith_processor.rb
  git add app/models/units/moxie_unit.rb
  git rm app/models/units/lunar_regolith_processor.rb.old
  git rm app/models/units/moxie_unit.rb.old
  git commit -m "refactor: unit models — rewrite habitat/processor/moxie to operational_data pattern, remove hardcoded BaseUnit type lists"

Step 10 — Report back
  - Before/after failure count
  - Any issues found
  - Any follow-up tasks identified

Priority: HIGH
Estimated time: 2-3 hours
Safe for 0x: YES (confirmed by Grok synthesis 2026-05-11)

Stop conditions:
- Any currently passing spec breaks — stop and report before continuing
- store_resource method not found on BaseUnit — stop and ask
- operational_data structure differs from expected — stop and report actual structure
```

---

## Acceptance Criteria
- [ ] Hardcoded unit type methods removed from base_unit.rb
- [ ] habitat.rb — reads population_capacity from operational_data only
- [ ] lunar_regolith_processor.rb — restored and rewritten
- [ ] moxie_unit.rb — restored and rewritten
- [ ] All .old files deleted after specs pass
- [ ] No new spec failures introduced
- [ ] Committed from host

---

## Completion Report
**Completed by**:
**Completion date**:
**Final test result**:
### What was changed
### Issues discovered
### Follow-up tasks needed
