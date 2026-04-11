# TASK: Implement OrbitalStructure + OrbitalSettlement — Additive Implementation
**Status**: ACTIVE
**Priority**: HIGH
**Type**: feature
**Created**: 2026-04-08
**Last Updated**: 2026-04-08

---

## Agent Assignment

**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Multiple new models, concerns, and specs. Requires 
reasoning about STI patterns, existing concern integration, and 
spec design. No destructive changes — purely additive.
**Supervision Level**: 🟡 Standard

---

## Context

`Settlement::SpaceStation` currently conflates settlement and structure 
concerns. The long-term refactor is blocked until <10 failures. However 
we can add the new model layer now without touching `SpaceStation` at all.

This task adds:
- `Structures::OrbitalStructure` — fabricated orbital pressure vessel
- `Structures::ConvertedBase` — geological body made habitable (Phobos, asteroids)
- `Settlement::OrbitalSettlement` — pure settlement, aggregates from structures
- `SpinGravity` concern — rotation physics for microgravity bodies
- `ExcavatedCavity` feature — cavity in asteroid/small moon
- Factories and specs for all of the above

`Settlement::SpaceStation` is NOT touched in this task.

---

## Architecture

### STI — No Migration Needed
All structures use the existing `structures` table via STI on `structure_type`.
`Worldhouse` already uses this pattern — follow it exactly.
structures table
├── Structures::Worldhouse        (structure_type: 'worldhouse')
├── Structures::ConvertedBase     (structure_type: 'converted_base')
└── Structures::OrbitalStructure  (structure_type: 'orbital_structure')

### Full Hierarchy
Structures::BaseStructure
└── Structures::OrbitalStructure
├── include Structures::Shell  ← existing concern, already on SpaceStation
├── include Docking            ← existing concern
├── include SpinGravity        ← new concern
├── include EnergyManagement   ← existing concern
├── include Housing            ← existing concern
└── include AtmosphericProcessing ← existing concern
Structures::Worldhouse
└── Structures::ConvertedBase
├── include SpinGravity        ← orbital rotation physics
├── include HasNaturalOpenings ← airlocks/shafts
├── docking_capable?           ← true if host_body.gravity_g < 0.01
└── host_body physics          ← composition, shielding, stress
NOTE: While a craft is docking it matches the rotation of the host body.
No simulation needed — docking_capable? is the only gate.
Settlement::BaseSettlement
└── Settlement::OrbitalSettlement
└── aggregates capacity from structures
└── no structural concerns

### Key Design Decisions
- `OrbitalStructure` uses existing `Structures::Shell` concern — same as 
  `SpaceStation`. Do not reinvent shell logic.
- `ConvertedBase` does NOT include `Structures::Shell` — rock is the shell.
- `ConvertedBase` conditionally enables docking based on host body gravity.
- Gas storage methods (`add_gas`, `remove_gas`, `get_gas`) belong on 
  `BaseSettlement` — not implemented in this task, flagged for follow-up.
- `OrbitalSettlement#location` must use a stable primary structure 
  designation, not `structures.first` — see implementation notes.

---

## Reference Files — Read Before Starting

| File | Why |
|---|---|
| `app/models/structures/worldhouse.rb` | STI pattern to follow exactly |
| `app/models/concerns/structures/shell.rb` | Already implemented — include as-is |
| `app/models/concerns/docking.rb` | Already implemented — include as-is |
| `app/models/settlement/space_station.rb` | Reference only — do not modify |
| `app/models/settlement/base_settlement.rb` | Parent for OrbitalSettlement |
| `app/models/structures/base_structure.rb` | Parent for OrbitalStructure |
| `app/models/celestial_bodies/features/lava_tube.rb` | Pattern for ExcavatedCavity |
| `db/schema.rb` | Confirm structures table columns before writing anything |

---

## Files to Create

### 1. `app/models/concerns/spin_gravity.rb`
```ruby
module SpinGravity
  extend ActiveSupport::Concern

  included do
    attribute :rotation_rpm, :float, default: 0.0
  end

  def artificial_gravity_g
    return 0 unless needs_spin_gravity? && rotation_rpm.present?
    omega = rotation_rpm * Math::PI / 30
    (omega**2 * (diameter_m / 2)) / 9.81
  end

  def needs_spin_gravity?
    location&.gravity_g.to_f < 0.01
  end

  def spin_for_gravity(target_g: 0.95)
    return unless needs_spin_gravity?
    self.rotation_rpm = target_rotation_rpm(target_g)
    save!
  end

  private

  def target_rotation_rpm(target_g)
    return 0 unless diameter_m.to_f > 0
    omega = Math.sqrt((target_g * 9.81) / (diameter_m / 2))
    (omega * 30 / Math::PI).round(2)
  end
end
```

> ⚠️ `diameter_m` must exist on any model that includes `SpinGravity`.
> Confirm it is defined in `OrbitalStructure` via `operational_data` 
> before including this concern.

### 2. `app/models/structures/orbital_structure.rb`
Follow the prototype in the task notes. Key points:
- STI: `self.table_name = 'structures'` (inherited from BaseStructure — confirm)
- Include: `Structures::Shell`, `Docking`, `SpinGravity`, `EnergyManagement`, 
  `Housing`, `AtmosphericProcessing`
- `diameter_m` — read from `operational_data['dimensions']['diameter_m']`
- `total_storage_capacity` — sum from base_units with storage capacity > 0
- `habitat_capacity` — delegate to `Housing` concern via `current_housing_capacity`
- Blueprint lookup via public method, not private delegate

### 3. `app/models/structures/converted_base.rb`
Follow the prototype. Key points:
- Inherits from `Structures::Worldhouse`
- Include: `SpinGravity`, `HasNaturalOpenings`, `EnergyManagement`, `Housing`
- Do NOT include `Structures::Shell` — rock is the shell
- `docking_capable?` — `host_body.respond_to?(:gravity_g) && host_body.gravity_g.to_f < 0.01`
- `host_body` — polymorphic, links to `Asteroid` or `SmallMoon`
- Check `Worldhouse` for `habitat_capacity` method conflict before defining it

### 4. `app/models/celestial_bodies/features/excavated_cavity.rb`
Follow the prototype. Key points:
- Inherits from `BaseFeature` — confirm parent class from `lava_tube.rb`
- `belongs_to :host_body, polymorphic: true`
- `structural_stress_factor` — rotation period based
- `can_pressurize?` — enclosed? && all_openings_sealed?
- Add to `Worldhouse#feature_must_be_suitable` — already done per session notes

### 5. `app/models/settlement/orbital_settlement.rb`
Follow the prototype. Key points:
- Inherits from `BaseSettlement`
- No structural concerns
- `total_storage_capacity` — `structures.sum(&:total_storage_capacity)`
- `population_capacity` — `structures.sum(&:habitat_capacity)`
- `location` — do NOT use `structures.first`. Use:
```ruby
  def location
    structures.order(:created_at).first&.celestial_location
  end
```
  Flag this for future primary structure designation improvement.
- `celestial_body` — delegate through location
- `add_specialized_structure!` — creates structure from blueprint_id

---

## Prototype Reference Files
The following prototype files were designed this session and are the 
intended implementation. Read them before writing any code:
- `orbital_structure.rb` (prototype)
- `converted_base.rb` (prototype)
- `spin_gravity.rb` (prototype)
- `excavated_cavity.rb` (prototype)
- `orbital_settlement.rb` (prototype)

---

## Factories — Already Written
`spec/factories/settlement/orbital_settlement.rb` is complete with traits:
- `:earth_luna_l1`
- `:mars_phobos_demios`
- `:venus_artificial_moons`

Write factories for structures as needed during spec development.

---

## Specs to Write

### `spec/models/structures/orbital_structure_spec.rb`
```ruby
RSpec.describe Structures::OrbitalStructure do
  describe 'structure basics' do
    it 'is a BaseStructure'
    it 'has correct structure_type'
    it 'includes Shell concern'
    it 'includes Docking concern'
    it 'includes SpinGravity concern'
  end

  describe '#habitat_capacity' do
    it 'sums capacity from habitat units'
    it 'returns 0 with no units'
  end

  describe '#total_storage_capacity' do
    it 'sums storage from storage units'
  end

  describe '#artificial_gravity_g' do
    it 'calculates gravity from rotation_rpm and diameter_m'
    it 'returns 0 if not microgravity location'
  end

  describe '#shell_status' do
    it 'defaults to planned'
    it 'transitions through shell lifecycle'
  end
end
```

### `spec/models/settlement/orbital_settlement_spec.rb`
```ruby
RSpec.describe Settlement::OrbitalSettlement do
  describe 'settlement basics' do
    it 'is a BaseSettlement'
    it 'has many structures'
  end

  describe '#total_storage_capacity' do
    it 'aggregates from all structures'
    it 'returns 0 with no structures'
  end

  describe '#population_capacity' do
    it 'aggregates habitat capacity from all structures'
  end

  describe 'traits' do
    it 'creates earth_luna_l1 settlement with operational_data'
    it 'creates mars_phobos_demios settlement with conversion data'
    it 'creates venus_artificial_moons settlement with relocation data'
  end
end
```

### `spec/models/structures/converted_base_spec.rb`
```ruby
RSpec.describe Structures::ConvertedBase do
  describe '#docking_capable?' do
    it 'returns true for microgravity host body'
    it 'returns false for normal gravity host body'
  end

  describe '#construction_materials' do
    it 'returns metallic materials for metallic asteroid'
    it 'returns carbonaceous materials for carbonaceous asteroid'
  end

  describe '#shielding_rating' do
    it 'calculates from host body mineral value'
  end

  describe '#rotation_stress_factor' do
    it 'returns high stress for fast rotation'
    it 'returns 1.0 for stable rotation'
  end
end
```

### `spec/models/concerns/spin_gravity_spec.rb`
```ruby
RSpec.describe SpinGravity do
  describe '#artificial_gravity_g' do
    it 'calculates correct gravity from rpm and diameter'
    it 'returns 0 for non-microgravity location'
  end

  describe '#needs_spin_gravity?' do
    it 'returns true for gravity_g < 0.01'
    it 'returns false for surface gravity'
  end
end
```

---

## Synthesis Report Format
MODELS REVIEWED
Worldhouse STI pattern: [confirmed/differs — describe]
Shell concern interface: [methods available]
BaseFeature parent: [confirmed class name]
diameter_m availability: [where it lives in OrbitalStructure]
IMPLEMENTATION PLAN
[any deviations from task file with reasoning]
RISK
[any shared code affected]
READY TO APPLY? — waiting for approval

---

## Testing Sequence
1. Run existing worldhouse specs first — confirm green before starting:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/structures/worldhouse_segment_spec.rb'
```
2. Implement models one at a time
3. Run new specs in isolation after each model
4. Run full structures suite — confirm no regressions:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/structures/'
```
5. Run full settlement suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/settlement/'
```

---

## Acceptance Criteria
- [ ] `Structures::OrbitalStructure` — persists via STI, Shell concern works
- [ ] `Structures::ConvertedBase` — inherits Worldhouse, docking_capable? correct
- [ ] `Settlement::OrbitalSettlement` — aggregates from structures correctly
- [ ] `SpinGravity` — calculates correctly for microgravity locations
- [ ] `ExcavatedCavity` — accepted by Worldhouse feature validation
- [ ] All new specs green
- [ ] `worldhouse_segment_spec.rb` stays 100% green
- [ ] No regressions in structures or settlement suites

---

## Stop Conditions
- `Structures::Shell` concern requires changes to work with `OrbitalStructure` — stop and report
- STI pattern differs from `Worldhouse` in unexpected ways — stop and report
- `ConvertedBase < Worldhouse` causes method conflicts — stop and report, list conflicts
- Any regression in `worldhouse_segment_spec.rb` — stop immediately

---

## Commit Instructions
```bash
git add app/models/structures/orbital_structure.rb \
        app/models/structures/converted_base.rb \
        app/models/settlement/orbital_settlement.rb \
        app/models/concerns/spin_gravity.rb \
        app/models/celestial_bodies/features/excavated_cavity.rb \
        spec/models/structures/orbital_structure_spec.rb \
        spec/models/settlement/orbital_settlement_spec.rb \
        spec/models/structures/converted_base_spec.rb \
        spec/models/concerns/spin_gravity_spec.rb \
        spec/factories/settlement/orbital_settlement.rb
git commit -m "feature: add OrbitalStructure, OrbitalSettlement, ConvertedBase, SpinGravity — additive, SpaceStation untouched"
git push
```

---

## Dependencies
**Blocked by**: nothing — purely additive
**Blocks**: Full orbital refactor (2026-03-31-HIGH-REFACTOR-ORBITAL-SETTLEMENT-ARCHITECTURE.md)
**Related tasks**:
- `2026-03-31-HIGH-REFACTOR-ORBITAL-SETTLEMENT-ARCHITECTURE.md` — update after this lands
- `2026-04-07-HIGH-DATA-AI-MANAGER-MISSION-PROFILE-TRAINING-REFRESH.md` — train after models exist

---

## Follow-up Tasks Needed
- Gas storage methods (`add_gas`, `remove_gas`, `get_gas`) on `BaseSettlement`
- Primary structure designation on `OrbitalSettlement` (replace `order(:created_at).first`)
- `SurfaceDocking` surface dock associations on `ConvertedBase`
- Update AI Manager training data once models exist

---

## Completion Report
*Filled in by agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned