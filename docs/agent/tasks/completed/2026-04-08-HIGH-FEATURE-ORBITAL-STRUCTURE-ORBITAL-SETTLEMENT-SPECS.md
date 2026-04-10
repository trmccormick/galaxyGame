# TASK: Write Specs — OrbitalStructure, OrbitalSettlement, ConvertedBase
**Status**: ACTIVE
**Priority**: HIGH
**Type**: feature
**Created**: 2026-04-08
**Last Updated**: 2026-04-10

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: All models exist on disk. Spec outlines are provided.
Read the actual model code, write conformant specs, run them green.
**Supervision Level**: 🔴 Watched carefully

> ⚠️ All five model files already exist. Do NOT rewrite or modify any
> model file unless a stop condition is hit. Your job is specs only.

---

## Context

The following models were implemented as prework and exist on disk:
- `app/models/structures/orbital_structure.rb`
- `app/models/structures/converted_base.rb`
- `app/models/settlement/orbital_settlement.rb`
- `app/models/concerns/spin_gravity.rb` — already has a passing spec (do not touch)
- `app/models/celestial_bodies/features/excavated_cavity.rb`
- `spec/factories/settlement/orbital_settlement.rb` — already written

Your task is to write specs for the first three models only.
`spin_gravity_spec.rb` is already green — do not modify it.
`excavated_cavity` spec is out of scope for this task.

---

## Read These Files Before Writing Anything

| File | Why |
|---|---|
| `app/models/structures/orbital_structure.rb` | Primary subject — read every method |
| `app/models/structures/converted_base.rb` | Primary subject — read every method |
| `app/models/settlement/orbital_settlement.rb` | Primary subject — read every method |
| `app/models/structures/worldhouse.rb` | Parent of ConvertedBase — understand inherited methods |
| `app/models/structures/base_structure.rb` | Parent of OrbitalStructure — understand inherited methods |
| `app/models/settlement/base_settlement.rb` | Parent of OrbitalSettlement — understand inherited methods |
| `spec/factories/settlement/orbital_settlement.rb` | Already written — use these traits |
| `spec/models/structures/worldhouse_segment_spec.rb` | Green baseline — do not regress this |
| `db/schema.rb` | Confirm table columns before writing any let blocks |

---

## Baseline Check — Run This First

Before writing any specs, confirm worldhouse is green:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/structures/worldhouse_segment_spec.rb'
```
Expected: 0 failures. If this fails, stop and report before proceeding.

---

## Files to Create

### 1. `spec/models/structures/orbital_structure_spec.rb`

```ruby
RSpec.describe Structures::OrbitalStructure, type: :model do
  describe 'structure basics' do
    it 'is a BaseStructure'
    it 'has correct STI type'
    it 'includes Shell concern'
    it 'includes Docking concern'
    it 'includes SpinGravity concern'
    it 'includes Housing concern'
    it 'includes EnergyManagement concern'
    it 'includes AtmosphericProcessing concern'
  end

  describe '#habitat_capacity' do
    it 'delegates to current_housing_capacity'
    it 'returns 0 with no housing units'
  end

  describe '#total_storage_capacity' do
    it 'sums storage from storage units'
    it 'returns 0 with no storage units'
  end

  describe '#total_mass' do
    it 'returns a numeric value'
  end

  describe 'associations' do
    it 'has one celestial_location'
    it 'has one atmosphere'
  end
end
```

> Read the actual model before filling in the examples. Write tests
> against what the code does, not what the task file originally planned.
> If a method does not exist on the model, do not test it.

### 2. `spec/models/settlement/orbital_settlement_spec.rb`

```ruby
RSpec.describe Settlement::OrbitalSettlement, type: :model do
  describe 'settlement basics' do
    it 'is a BaseSettlement'
    it 'has many structures'
  end

  describe '#total_storage_capacity' do
    it 'aggregates from all structures'
    it 'returns 0 with no structures'
  end

  describe '#population_capacity' do
    it 'aggregates habitat_capacity from all structures'
    it 'returns 0 with no structures'
  end

  describe '#location' do
    it 'returns celestial_location of first structure'
    it 'returns nil with no structures'
  end

  describe '#celestial_body' do
    it 'delegates through location'
  end

  describe '#add_specialized_structure!' do
    it 'creates a new structure with planned shell_status'
  end

  describe 'factories' do
    it 'creates a valid orbital settlement with :earth_luna_l1 trait'
    it 'creates a valid orbital settlement with :mars_phobos_deimos trait'
  end
end
```

> Use the factory traits already written in
> `spec/factories/settlement/orbital_settlement.rb`.
> Read that file before writing any let blocks.

### 3. `spec/models/structures/converted_base_spec.rb`

```ruby
RSpec.describe Structures::ConvertedBase, type: :model do
  describe 'inheritance' do
    it 'inherits from Structures::Worldhouse'
    it 'includes Housing concern'
    it 'includes EnergyManagement concern'
    it 'includes AtmosphericProcessing concern'
  end

  describe '#construction_materials' do
    it 'returns metallic materials for metallic host body'
    it 'returns carbonaceous materials for carbonaceous host body'
    it 'returns regolith default for unknown composition'
  end

  describe '#shielding_rating' do
    it 'returns 0 if host body has no estimated_mineral_value'
    it 'calculates from estimated_mineral_value'
  end

  describe '#rotation_stress_factor' do
    it 'returns 1.0 if host body has no typical_rotation_period'
    it 'returns high stress for fast rotation (period < 2 hours)'
    it 'returns 1.0 for stable rotation'
  end

  describe '#habitat_capacity' do
    it 'delegates to current_housing_capacity'
  end
end
```

> `host_body` is polymorphic — use `instance_double` for Asteroid or
> SmallMoon. Do not create real celestial body records for unit tests.

---

## Implementation Notes

### On `instance_double` usage
The session history has a confirmed fix for `instance_double` with namespaced
classes. Use the full namespaced string:
```ruby
instance_double('CelestialBodies::Asteroid', ...)
# NOT instance_double('Asteroid', ...)
```

### On `orbital_settlement.rb#location`
Current implementation uses `structures.first` — test this as-is.
Do not change it to `order(:created_at)` in this task. Flag it in
your completion report as a follow-up item.

### On concern inclusion tests
Test concern inclusion with:
```ruby
expect(described_class.ancestors).to include(SpinGravity)
```
Not by testing concern behavior — that belongs in the concern's own spec.

---

## Testing Sequence

> Run in this exact order. Do not skip steps.

### 1. Worldhouse baseline (before touching anything)
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/structures/worldhouse_segment_spec.rb'
```

### 2. Each new spec in isolation as you write it
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/structures/orbital_structure_spec.rb'
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/settlement/orbital_settlement_spec.rb'
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/structures/converted_base_spec.rb'
```

### 3. Full structures suite — after all three specs are green
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/structures/ > /home/galaxy_game/log/rspec_structures_$(date +%s).log 2>&1'
```
Report back: final summary line + any failures from the log.

### 4. Full settlement suite
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/settlement/ > /home/galaxy_game/log/rspec_settlement_$(date +%s).log 2>&1'
```
Report back: final summary line + any failures from the log.

---

## Acceptance Criteria
- [ ] Worldhouse baseline green before and after
- [ ] `orbital_structure_spec.rb` — 0 failures in isolation
- [ ] `orbital_settlement_spec.rb` — 0 failures in isolation
- [ ] `converted_base_spec.rb` — 0 failures in isolation
- [ ] No regressions in structures suite
- [ ] No regressions in settlement suite
- [ ] `spin_gravity_spec.rb` untouched and still green

---

## Stop Conditions — escalate to user immediately if:
- Worldhouse baseline fails before you start
- A model file is missing a method your spec needs — report the gap,
  do not add methods to models in this task
- Same spec failure persists after two attempts — report exact error,
  do not attempt a third fix
- Any regression in worldhouse or space_station specs
- A factory trait in `orbital_settlement.rb` references an association
  that doesn't exist — report it, do not modify the factory

---

## Commit Instructions
Run git commands on host, not inside container:
```bash
git add spec/models/structures/orbital_structure_spec.rb \
        spec/models/settlement/orbital_settlement_spec.rb \
        spec/models/structures/converted_base_spec.rb
git commit -m "feat: add specs for OrbitalStructure, OrbitalSettlement, ConvertedBase"
git push
```

---

## Dependencies
**Blocked by**: nothing
**Blocks**: `2026-03-31-HIGH-REFACTOR-ORBITAL-SETTLEMENT-ARCHITECTURE.md`
**Related tasks**:
- `2026-03-31-HIGH-REFACTOR-ORBITAL-SETTLEMENT-ARCHITECTURE.md` — update status after this lands
- `2026-04-10-MEDIUM-DATA-ACR-200-SPACE-CONSTRUCTOR-MISSING-OPERATIONAL-DATA.md` — parallel, independent

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned
