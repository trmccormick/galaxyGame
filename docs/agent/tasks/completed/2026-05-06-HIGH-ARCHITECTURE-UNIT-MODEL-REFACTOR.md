# TASK: Unit Model Architecture Refactor
**Status**: ACTIVE
**Priority**: HIGH
**Type**: architecture
**Created**: 2026-05-06
**Last Updated**: 2026-05-06

---

## Agent Assignment
**Assigned To**: Claude 1x (architecture decisions) + GPT-4.1 0x (implementation)
**Why This Agent**: Core model refactor touching many files, needs careful
judgment before any code changes
**Supervision Level**: 🔴 Watched carefully — units used everywhere

---

## Context

`Units::BaseUnit` is the foundation for all unit types in the game.
Currently it is bloated with concerns that belong in subclasses, and
several legacy stub subclasses exist that use the wrong patterns
(attr_accessor, hardcoded values, wrong abstractions).

The correct pattern is established by `Units::Robot` and `Units::Battery`:
- Read everything unit-specific from `operational_data`
- Database columns only for querying/indexing
- Concerns for shared behaviors
- Subclasses only when behavior is genuinely different

Units are installed in settlements and structures. They determine what
jobs a settlement can run. Getting this right is prerequisite to the
job queue system working correctly.

---

## Problem Statement

**Current issues:**
1. `BaseUnit` has hardcoded unit type lists (lines 590-600) that should
   be data-driven from `operational_data`
2. Legacy stub subclasses use wrong patterns:
   - `AutomatedFactory` — wrong abstraction (factory is a structure not a unit)
   - `Smelter` — wrong abstraction, has_many :smelting_jobs is wrong model
   - `Habitat` — uses attr_accessor and hardcoded values, pre-architecture
   - `LunarRegolithProcessor` — uses attr_accessor and initialize override
   - `MoxieUnit` — uses attr_accessor and initialize override
3. No `job_types` capability in `BaseUnit` or operational_data
4. No way for job queue to know what jobs a unit can run

**Correct pattern (follow Robot and Battery):**
- Subclass reads from `operational_data` not attr_accessor
- No initialize override — use `operational_data` loaded by BaseUnit
- No hardcoded values — all from `operational_data`
- Concerns for shared behaviors

---

## Files Involved

### Delete entirely (wrong abstractions):
- `app/models/units/automated_factory.rb`
- `app/models/units/smelter.rb`

### Rewrite to follow Robot/Battery pattern:
- `app/models/units/habitat.rb`
- `app/models/units/lunar_regolith_processor.rb`
- `app/models/units/moxie_unit.rb`

### Update:
- `app/models/units/base_unit.rb`

### Reference (do not edit — follow these patterns):
- `app/models/units/robot.rb`
- `app/models/units/battery.rb`

---

## Implementation Steps

### Step 1 — Read and understand before touching anything

Read these files completely:
- `app/models/units/base_unit.rb`
- `app/models/units/robot.rb`
- `app/models/units/battery.rb`
- `app/models/units/automated_factory.rb`
- `app/models/units/smelter.rb`
- `app/models/units/habitat.rb`
- `app/models/units/lunar_regolith_processor.rb`
- `app/models/units/moxie_unit.rb`

Then produce a Synthesis Report (see format below) and STOP.

### Step 2 — Delete wrong abstractions

Delete these files:
- `app/models/units/automated_factory.rb`
- `app/models/units/smelter.rb`

These are wrong abstractions:
- A factory is a STRUCTURE fitted with units, not a unit itself
- Smelter has_many :smelting_jobs — wrong model, jobs belong to settlements

After deletion run:
```bash
docker exec -it web bash -c "bundle exec rspec spec/models/ 2>&1 | tail -20"
```
Confirm no new failures from deletion.

### Step 3 — Remove hardcoded unit type lists from BaseUnit

Remove these methods from `base_unit.rb` (lines ~590-600):
```ruby
def atmospheric_unit_types
  %w[co2_oxygen_production_unit oxygen_production_unit gas_separator]
end

def geosphere_unit_types
  %w[planetary_volatiles_extractor thermal_extraction_unit
     lunar_oxygen_extractor mining_drill]
end

def extraction_unit_types
  %w[mining_drone resource_extractor]
end
```

Replace with data-driven methods that read from `operational_data`:
```ruby
def job_types
  operational_data&.dig('job_types', 'supported') || []
end

def max_concurrent_jobs
  operational_data&.dig('job_types', 'max_concurrent') || 1
end

def supports_job_type?(job_type)
  job_types.include?(job_type.to_s)
end

def processing_type
  operational_data&.dig('processing_type')
end
```

Check if `atmospheric_unit_types`, `geosphere_unit_types`,
`extraction_unit_types` are called anywhere before removing:
```bash
grep -rn "atmospheric_unit_types\|geosphere_unit_types\|extraction_unit_types" \
  galaxy_game/app/ galaxy_game/spec/
```

If called elsewhere, update those call sites to use
`unit.supports_job_type?` or `unit.processing_type` instead.

### Step 4 — Rewrite Habitat following Robot pattern

Current `Habitat` uses attr_accessor and initialize override.
Rewrite to read from `operational_data`:

```ruby
module Units
  class Habitat < BaseUnit
    def population_capacity
      operational_data&.dig('habitat_systems', 'capacity') || 0
    end

    def current_occupants
      operational_data&.dig('habitat_systems', 'current_occupants') || 0
    end

    def life_support_active?
      operational_data&.dig('habitat_systems', 'life_support_active') || false
    end

    def pressure_kpa
      operational_data&.dig('habitat_systems', 'pressure_kpa') || 0
    end

    def allocate_population(num_people)
      return false if current_occupants + num_people > population_capacity
      operational_data['habitat_systems']['current_occupants'] = 
        current_occupants + num_people
      save!
      true
    end
  end
end
```

### Step 5 — Rewrite LunarRegolithProcessor following Robot pattern

```ruby
module Units
  class LunarRegolithProcessor < BaseUnit
    def energy_consumption
      operational_data&.dig('operational_properties',
        'power_consumption_kw') || 200
    end

    def process_regolith(amount)
      return false if amount <= 0
      oxygen_produced = (amount / 2.0).floor
      store_resource('O2', oxygen_produced)
    end
  end
end
```

### Step 6 — Rewrite MoxieUnit following Robot pattern

```ruby
module Units
  class MoxieUnit < BaseUnit
    def energy_consumption
      operational_data&.dig('operational_properties',
        'power_consumption_kw') || 100
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

### Step 7 — Run full model spec suite

```bash
docker exec -it web bash -c "bundle exec rspec spec/models/ 2>&1 | tail -30"
```

Report results. Flag any new failures introduced by this refactor.

### Step 8 — Run targeted unit specs

```bash
docker exec -it web bash -c "bundle exec rspec spec/models/units/ 2>&1"
```

---

## Synthesis Report Format
UNIT MODEL REFACTOR SYNTHESIS REPORT
FILES REVIEWED:

base_unit.rb: [key findings]
robot.rb: [pattern confirmed]
battery.rb: [pattern confirmed]
automated_factory.rb: [why delete]
smelter.rb: [why delete]
habitat.rb: [what needs rewriting]
lunar_regolith_processor.rb: [what needs rewriting]
moxie_unit.rb: [what needs rewriting]

HARDCODED UNIT TYPE METHODS:

Called in these locations: [list]
Safe to remove: [yes/no with reasoning]

PROPOSED CHANGES SUMMARY:
[list each change]
RISKS:
[anything that could break other specs]
QUESTIONS FOR HUMAN:
[anything unclear]

STOP after Synthesis Report. Do not edit any file until approved.

---

## Acceptance Criteria
- [ ] AutomatedFactory deleted
- [ ] Smelter deleted
- [ ] Habitat rewritten — reads from operational_data
- [ ] LunarRegolithProcessor rewritten — reads from operational_data
- [ ] MoxieUnit rewritten — reads from operational_data
- [ ] BaseUnit hardcoded unit type lists removed
- [ ] BaseUnit has job_types, supports_job_type?, processing_type methods
- [ ] No new spec failures introduced
- [ ] All unit specs pass

---

## Stop Conditions
- Any currently passing spec breaks after deletion
- Hardcoded unit type methods called in more than 5 places
- Habitat, LunarRegolithProcessor, or MoxieUnit have specs
  that need updating before rewrite

---

## Commit Instructions
```bash
git add app/models/units/
git commit -m "refactor: unit models — delete wrong abstractions, \
rewrite stubs to follow operational_data pattern, \
add job_types to BaseUnit"
```

---

## Completion Report
**Completed by**: Grok Code Fast
**Completion date**: 2026-05-11
**Final test result**: Synthesis only — no code changed
### What was changed
Nothing — synthesis report produced
### Issues discovered
- automated_factory.rb and smelter.rb already deleted
- lunar_regolith_processor.rb and moxie_unit.rb exist as .old only
- Hardcoded unit type methods have zero call sites — safe to remove
- Habitat has dead Resource.consume/produce calls and overlapping population logic
### Follow-up tasks needed
- GPT-4.1 implementation task created: 2026-05-11-HIGH-REFACTOR-UNIT-MODEL-IMPLEMENTATION.md