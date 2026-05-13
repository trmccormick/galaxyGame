# Code Patterns
**Last Updated**: 2026-05-12
**Maintained By**: Session Strategist (Claude)

> These patterns are locked. Do not deviate without explicit human approval.
> When in doubt, read the reference files listed — do not infer.

---

## The Robot/Battery Pattern (Unit Subclasses)

This is the correct pattern for ALL unit subclasses. Established by
`app/models/units/robot.rb` and `app/models/units/battery.rb`.

### Rules
- Inherit from `Units::BaseUnit`
- Include concerns for shared behaviors
- All state and config accessed via `operational_data`
- No `attr_accessor` for config values
- No `initialize` override
- No hardcoded values — everything from `operational_data`
- All persistence uses `save!` (bang method)
- No population or inventory logic in unit classes

### Correct Pattern
```ruby
module Units
  class ExampleUnit < BaseUnit
    # Include concerns for shared behaviors
    include SomeConcern

    # All getters read from operational_data
    def some_value
      operational_data&.dig('section', 'key') || default_value
    end

    def another_value
      operational_data&.dig('other_section', 'key') || 0
    end

    # Actions use store_resource for output
    def do_work(amount)
      return false if amount <= 0
      output = calculate_output(amount)
      store_resource('RESOURCE_ID', output)
    end

    private

    def calculate_output(amount)
      (amount * efficiency).floor
    end

    def efficiency
      operational_data&.dig('operational_properties', 'efficiency') || 1.0
    end
  end
end
```

### Wrong Patterns — Never Do These
```ruby
# WRONG — attr_accessor for config
attr_accessor :capacity, :power_consumption

# WRONG — initialize override
def initialize(attrs = {})
  super
  @capacity = attrs[:capacity] || 100
end

# WRONG — hardcoded values
def capacity
  100
end

# WRONG — resource logic in unit
def consume_food
  Resource.consume('food', food_needed)
end

# WRONG — inventory adjustment in unit
def produce_oxygen
  inventory.add('O2', oxygen_output)
end
```

### Reference Files (read before writing any unit subclass)
- `app/models/units/robot.rb` — primary reference
- `app/models/units/battery.rb` — secondary reference
- `app/models/units/base_unit.rb` — base class, understand before touching

---

## Habitat Unit Pattern (Special Case)

Habitat has ONE job: expose `population_capacity` from `operational_data`.
Nothing else. This is locked in DECISIONS.md.

```ruby
module Units
  class Habitat < BaseUnit
    def population_capacity
      operational_data&.dig('habitat_systems', 'capacity') || 0
    end
  end
end
```

**PopulationManagement belongs on Settlement and Craft — not Habitat.**
Life support calculations happen in services, not unit classes.

---

## Job Lifecycle Pattern

```
Created     → status: :pending, start_date: nil, completes_at: nil
              Materials removed from inventory at submission

Slot opens  → status: :in_progress
              start_date: Time.current
              completes_at: start_date + production_time

Completes   → output added to inventory
              status: :ready_to_claim

Cancelled   → materials returned if before start
              status: :cancelled
```

### Job vs ConstructionJob
- `Job` = manufacturing (ISRU, smelting, components) — timer-based
- `ConstructionJob` = surface construction (crater domes, shell printing)
- These are permanently separate models — job unification is CANCELLED

### output_type
- Nullable column on Job — not required
- Derived from blueprint when needed
- Never require it in service code

---

## operational_data Pattern

All unit-specific config lives in JSON files under `data/json-data/`.
Loaded into the `operational_data` column on the unit record.

### Accessing operational_data
```ruby
# Safe access with nil guard and default
def some_value
  operational_data&.dig('section', 'key') || default
end

# Nested access
def nested_value
  operational_data&.dig('section', 'subsection', 'key') || default
end

# Array access
def resource_amount
  operational_data&.dig('output_resources')
    &.find { |r| r['id'] == 'O2' }
    &.dig('amount') || 0
end
```

### job_types (BaseUnit)
```ruby
# These methods exist on BaseUnit — do not redefine in subclasses
unit.job_types          # → ['mining', 'processing']
unit.supports_job_type?('mining')  # → true/false
unit.max_concurrent_jobs           # → 1
unit.processing_type               # → 'extractor'
```

---

## Data Paths Pattern

```ruby
# CORRECT — always use GalaxyGame::Paths constants
GalaxyGame::Paths.operational_data
GalaxyGame::Paths.star_systems
GalaxyGame::Paths.generated_star_systems

# WRONG — never use Rails.root.join directly
Rails.root.join('data', 'json-data', 'something.json')
```

---

## Sphere Data Separation

Geosphere `stored_volatiles` contains ONLY ground-accessible volatiles:
- Polar ice deposits ✅
- Regolith-trapped volatiles ✅
- Subsurface clathrates ✅
- He3 in regolith ✅

Never in geosphere stored_volatiles:
- Atmospheric gases ❌ → belongs in atmosphere.composition
- Ocean/liquid water bodies ❌ → belongs in hydrosphere
- Physically impossible deposits for that body ❌

---

## .old File Convention

Files renamed to `.old` are mid-refactor placeholders.
When `.old` exists without a corresponding `.rb`:
1. Check references: `grep -rn "ClassName" app/ spec/`
2. If zero references → delete the `.old` file, do not restore
3. If references exist → restore from `.old`, rewrite to Robot/Battery pattern,
   delete `.old` after specs pass

---

## RSpec Patterns

### Spy mismatch (common failure)
If `expect(obj).to have_received(:method)` gets 0 calls:
- The spy is on a different object instance than the one called
- Fix: memoize the association in the model OR reload in spec before asserting

### Factory bypasses callback
If callback-set field is nil after factory create:
- Factory sequence sets field before callback runs
- Fix: remove sequence from factory, use `read_attribute` in guard clause

### Mock arrives too late
If mock set up after `create` and real lookup runs instead:
- `after_initialize` fires during `create` before mock is in place
- Fix: move `allow_any_instance_of` before the `create` call
