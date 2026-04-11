# TASK: Write Spec for Structures::WorldhouseSegment
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: feature
**Created**: 2026-04-10
**Last Updated**: 2026-04-10

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Model exists, concern chain is documented, factory
exists. Fully specified — no inference needed.
**Supervision Level**: 🔴 Watched carefully

> ⚠️ Read every section before starting. Do not modify the model or
> any concern file. Specs only.

---

## Context

`Structures::WorldhouseSegment` is a segment of a worldhouse structure.
It includes `Coverable` which includes `Enclosable`. These concerns
provide area calculations, material calculations, and shell composition
tracking. The model has its own status enum, construction workflow
(`begin_construction!`, `complete!`), and material requirements methods.

A factory exists at `spec/factories/structures/worldhouse_segment.rb`.
Read it before writing any let blocks.

The integration spec at `spec/services/construction/covering_system_integration_spec.rb`
already tests the full covering workflow — do NOT duplicate that here.
This spec covers unit-level model behavior only.

---

## Files to Read Before Writing Anything

| File | Why |
|---|---|
| `app/models/structures/worldhouse_segment.rb` | Primary subject — read every method |
| `app/models/concerns/structures/coverable.rb` | Included concern — provides construction workflow |
| `app/models/concerns/structures/enclosable.rb` | Included via Coverable — provides area calculations |
| `spec/factories/structures/worldhouse_segment.rb` | Factory — use this, do not create your own |
| `spec/factories/structures/worldhouse.rb` | Parent association factory |

---

## Key Model Facts — Read Before Writing

### Validations
- `segment_index` — presence required
- `length_m` — presence AND numericality greater_than: 0
- `width_m` — presence AND numericality greater_than: 0

### Important: length_m and width_m have getter overrides
```ruby
def length_m
  self[:length_m] || 0
end
def width_m
  self[:width_m] || 0
end
```
This means `presence` validation is NOT triggered by nil — the getter
returns 0 instead. Test `numericality: greater_than: 0`, not presence.

### Enum status (string values)
```ruby
enum status: {
  planned: 'planned',
  materials_requested: 'materials_requested',
  under_construction: 'under_construction',
  enclosed: 'enclosed',
  operational: 'operational'
}
```

### segment_type attribute
```ruby
attribute :segment_type, :string, default: 'residential'
```

### Area methods (from Enclosable)
- `area_m2` — `length_m * width_m`
- `area_km2` — `area_m2 / 1_000_000.0`

### required_panel_count
- `(area_m2 / 25.0).ceil`

### required_materials
Returns hash with keys:
- `modular_structural_panel`
- `structural_support_beam`
- `pressure_seal`
- `mounting_hardware`

### begin_construction!
- Returns false unless `planned?`
- Creates `MaterialRequest` records
- Updates status to `materials_requested`

### complete!
- Returns false unless `under_construction?`
- Updates status to `enclosed`
- Calls `worldhouse.recalculate_progress!`

---

## Spec to Write

**Path**: `spec/models/structures/worldhouse_segment_spec.rb`

```ruby
RSpec.describe Structures::WorldhouseSegment, type: :model do

  describe 'validations' do
    it 'requires segment_index'
    it 'requires length_m to be greater than 0'
    it 'requires width_m to be greater than 0'
  end

  describe 'associations' do
    it 'belongs to worldhouse'
    it 'has many construction_jobs'
  end

  describe 'defaults' do
    it 'defaults segment_type to residential'
    it 'defaults status to planned'
  end

  describe 'area calculations' do
    it 'calculates area_m2 from length and width'
    it 'calculates area_km2 from area_m2'
  end

  describe '#required_panel_count' do
    it 'calculates panel count from area'
    it 'rounds up to nearest whole panel'
  end

  describe '#required_materials' do
    it 'returns a hash with required material keys'
    it 'includes modular_structural_panel'
    it 'includes structural_support_beam'
    it 'includes pressure_seal'
    it 'includes mounting_hardware'
  end

  describe '#begin_construction!' do
    it 'returns false unless planned'
    it 'updates status to materials_requested when planned'
  end

  describe '#complete!' do
    it 'returns false unless under_construction'
    it 'updates status to enclosed when under_construction'
  end

end
```

> Write tests against what the model actually does.
> If begin_construction! creates MaterialRequest records, stub
> MaterialRequest.create! to avoid real DB writes in unit tests.
> If complete! calls worldhouse.recalculate_progress!, stub that
> method on the worldhouse double.

---

## Testing Sequence

### 1. Run in isolation
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/structures/worldhouse_segment_spec.rb'
```
Expected: 0 failures.

### 2. Run full structures suite — confirm no regressions
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/structures/ > /home/galaxy_game/log/rspec_structures.log 2>&1; tail -3 /home/galaxy_game/log/rspec_structures.log'
```
Expected: 45 + new examples, 0 failures.

---

## Commit Instructions
Run from host:
```bash
git add galaxy_game/spec/models/structures/worldhouse_segment_spec.rb
git commit -m "feat: add worldhouse_segment_spec — unit tests for area, materials, construction workflow"
git push
```

---

## Acceptance Criteria
- [ ] All examples pass in isolation
- [ ] Structures suite stays green — currently 45 examples, 0 failures
- [ ] No model files modified
- [ ] Committed from host with descriptive message

---

## Stop Conditions
- Factory for WorldhouseSegment or Worldhouse is missing or broken —
  report exact error, do not create a new factory
- `begin_construction!` or `complete!` hit unexpected dependencies —
  report and stop, do not add stubs without approval
- Any regression in the structures suite — stop immediately

---

## Dependencies
**Blocked by**: nothing
**Blocks**: nothing
**Related tasks**:
- `2026-04-10-MEDIUM-ARCHITECTURE-HOUSING-CONCERN-BASECRAFT-INCLUDE-AUDIT.md`
- `covering_system_integration_spec.rb` already covers integration behavior — do not duplicate
