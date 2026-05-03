# Task: Remove UnitLookupService Monkey-Patch from has_units_spec

## Assignee: GPT-4.1
## Priority: High (causes ~14 failures in unit_lookup_service_spec in full suite)
## Branch: regional-view-phase2

---

## Problem

`spec/models/concerns/has_units_spec.rb` contains a class reopening block
at lines 20-48 that permanently monkey-patches `Lookup::UnitLookupService`
for the entire test suite run:

```ruby
module Lookup
  class UnitLookupService
    def find_unit(blueprint_id)
      case blueprint_id.to_s
      when 'computer'
        { ... }
      when 'robot'
        { ... }
      ...
      else
        nil
      end
    end
  end
end
```

This block is outside any `before` block — it executes at file load time and
permanently replaces `find_unit` on the real service class. It never resets.
As a result, when `unit_lookup_service_spec.rb` runs later in the suite,
`find_unit` returns `nil` for any unit ID not in the case statement
(`basic_engine`, `fuel_tank_s` etc), causing ~14 failures.

The spec already has properly scoped `allow_any_instance_of` stubs in the
`before(:each)` block at line 254 that handle the same unit IDs. The
monkey-patch is completely redundant and harmful.

---

## Fix

**Remove lines 20-48 entirely** — the entire `module Lookup / class
UnitLookupService` block. Do not modify anything else in the file.

The `before(:each)` stubs at line 254 onwards already cover the same
unit IDs correctly and will continue to work after the removal.

---

## Do NOT

- Modify the `before(:each)` block at line 254 or the `allow_any_instance_of`
  stubs within it — these are correct and must stay
- Modify any other spec file
- Modify any application code
- Add any new stubs or mocks to replace the removed block

---

## Verify

Run the spec in isolation first to confirm it still passes:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/concerns/has_units_spec.rb > /home/galaxy_game/log/rspec_has_units_$(date +%s).log 2>&1'
```

Then run the unit lookup spec to confirm the pollution is cleared:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/lookup/unit_lookup_service_spec.rb > /home/galaxy_game/log/rspec_unit_lookup_$(date +%s).log 2>&1'
```

Both must be green before committing. Commit atomically — only
`spec/models/concerns/has_units_spec.rb` should be in the diff.
