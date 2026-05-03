# TASK: Refactor PrecursorCapabilityService — Chemical Formula Consistency
**Status**: ACTIVE
**Priority**: HIGH
**Type**: refactor
**Created**: 2026-05-02
**Last Updated**: 2026-05-02

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Service logic refactor, multiple methods, needs RSpec
confirmation. Well-scoped with exact fix directions.
**Supervision Level**: 🟡 Standard — Synthesis Report required before changes

---

## Context

`PrecursorCapabilityService` was written mixing chemical formulas and
common names inconsistently. The game architecture requires chemical
formulas in all backend code — common names are reserved for UI display
only. This causes incorrect matching against `stored_volatiles` keys
(H2O, CO2, CH4, N2, He3), `crust_composition` keys, and
`atmosphere.composition` keys which all use chemical formulas.

Additionally the service has overly loose substring matching in
`can_produce_locally?` which causes false positives (methane_ice
matching methane), and `can_extract_metals?` hardcodes common mineral
names instead of reading actual crust composition data.

This refactor fixes 4 confirmed spec failures and corrects the
underlying architectural issues causing them.

**Confirmed failures before fix:**
- `can_produce_locally?('regolith')` → false (should be true)
- `can_produce_locally?('oxygen')` → false (should be true)
- `can_produce_locally?('methane')` → true (should be false)
- `precursor_enables?(:metals)` → false (should be true)

---

## Architecture Rules — Read Before Touching Anything

1. **Chemical formulas in all backend code** — H2O, CO2, CH4, N2,
   O2, Ar, He3, Fe2O3, Al2O3, SiO2, TiO2, FeO, MgO etc.
2. **Common names reserved for UI only** — never use nitrogen,
   methane, oxygen, water, argon in service logic
3. **Non-chemical terms acceptable** — regolith, psr_deposits,
   clathrates are storage mechanism descriptors not compound names
4. **Data driven** — service reads actual body data, never hardcodes
   world-specific values or mineral names
5. **Exact matching only** — no substring matching between resource
   identifiers. A resource either matches or it doesn't.

---

## Files Involved

### Primary — edit
- `app/services/ai_manager/precursor_capability_service.rb`

### Reference — read but do not edit
- `app/models/celestial_bodies/spheres/atmosphere.rb`
- `app/models/celestial_bodies/spheres/geosphere.rb`
- `app/models/celestial_body.rb` — confirm `has_solid_surface?` exists
- `spec/services/ai_manager/precursor_capability_service_spec.rb`
- `docs/reference/CELESTIAL_BODY_DATA_CONVENTIONS.md`

---

## Diagnostic Steps — Run Before Writing Synthesis Report

```bash
# Confirm has_solid_surface? exists on CelestialBody
docker exec -it web bash -c "bundle exec rails runner \
  \"puts CelestialBody.instance_methods.include?(:has_solid_surface?)\""

# Confirm Luna's geosphere crust_composition keys
docker exec -it web bash -c "bundle exec rails runner \
  \"luna = CelestialBody.find_by(identifier: 'LUNA-01'); \
  puts luna.geosphere.crust_composition.keys\""

# Confirm Luna's geosphere stored_volatiles keys  
docker exec -it web bash -c "bundle exec rails runner \
  \"luna = CelestialBody.find_by(identifier: 'LUNA-01'); \
  puts luna.geosphere.stored_volatiles.keys\""

# Confirm Luna's atmosphere composition
docker exec -it web bash -c "bundle exec rails runner \
  \"luna = CelestialBody.find_by(identifier: 'LUNA-01'); \
  puts luna.atmosphere.inspect\""

# Run failing specs before any changes
docker exec -it web bash -c "bundle exec rspec \
  spec/services/ai_manager/precursor_capability_service_spec.rb \
  2>&1 | tail -20"
```

---

## Implementation — Exact Changes Required

### 1. Fix `can_produce_locally?` — exact matching only

**Current (wrong):**
```ruby
def can_produce_locally?(resource)
  return false unless celestial_body
  resource_normalized = resource.to_s.downcase
  local_resources.any? do |available_resource|
    resource_normalized.include?(available_resource.downcase) ||
      available_resource.downcase.include?(resource_normalized)
  end
end
```

**Replace with:**
```ruby
def can_produce_locally?(resource)
  return false unless celestial_body
  local_resources.any? do |available_resource|
    available_resource.to_s.downcase == resource.to_s.downcase
  end
end
```

### 2. Fix `atmospheric_resources` — use chemical formulas

**Current (wrong):**
```ruby
resources << 'co2' if atmo.gas_percentage('CO2') > 0.01
resources << 'nitrogen' if atmo.gas_percentage('N2') > 0.01
resources << 'methane' if atmo.gas_percentage('CH4') > 0.01
resources << 'oxygen' if atmo.gas_percentage('O2') > 0.01
resources << 'argon' if atmo.gas_percentage('Ar') > 0.001
```

**Replace with:**
```ruby
resources << 'CO2' if atmo.gas_percentage('CO2') > 0.01
resources << 'N2'  if atmo.gas_percentage('N2') > 0.01
resources << 'CH4' if atmo.gas_percentage('CH4') > 0.01
resources << 'O2'  if atmo.gas_percentage('O2') > 0.01
resources << 'Ar'  if atmo.gas_percentage('Ar') > 0.001
```

### 3. Fix `surface_resources` — use chemical formulas

**Current (wrong):**
```ruby
resources << 'water_ice' if volatile_amount(reservoirs['H2O']) > 0
resources << 'frozen_co2' if volatile_amount(reservoirs['CO2']) > 0
resources << 'methane_ice' if volatile_amount(reservoirs['CH4']) > 0
```

**Replace with:**
```ruby
resources << 'H2O' if volatile_amount(reservoirs['H2O']) > 0
resources << 'CO2' if volatile_amount(reservoirs['CO2']) > 0
resources << 'CH4' if volatile_amount(reservoirs['CH4']) > 0
```

Also add all stored_volatiles keys dynamically — don't hardcode which
compounds to check:
```ruby
if geo.stored_volatiles.present?
  geo.stored_volatiles.each do |compound, storage|
    resources << compound if volatile_amount(storage) > 0
  end
end
```

### 4. Fix `extract_local_resources` — add O2 from regolith pathway

After the regolith line add:
```ruby
if celestial_body.has_solid_surface?
  resources << 'regolith'
  # O2 extractable from metal oxides in regolith via PVE on any
  # solid body with significant crust composition
  resources << 'O2' if celestial_body.geosphere&.crust_composition&.present?
end
```

### 5. Fix `subsurface_resources` — use string key not symbol

**Current (wrong):**
```ruby
if geo.stored_volatiles.is_a?(Hash) && geo.stored_volatiles.key?(:H2O)
```

**Replace with:**
```ruby
if geo.stored_volatiles.is_a?(Hash) && geo.stored_volatiles.key?('H2O')
```

### 6. Fix `regolith_composition` — use chemical formulas

**Current (wrong):**
```ruby
resources << 'he3' if volatile_amount(composition['he3']) > 0.00001
resources << 'rare_earth_elements' if volatile_amount(composition['rare_earths']) > 0.01
```

**Replace with — read He3 from stored_volatiles not crust_composition:**
```ruby
def regolith_composition
  return [] unless celestial_body.geosphere
  geo = celestial_body.geosphere
  resources = ['regolith']

  # He3 is stored in regolith as a volatile — read from stored_volatiles
  if geo.stored_volatiles.present?
    he3 = geo.stored_volatiles['He3']
    resources << 'He3' if volatile_amount(he3) > 0
  end

  resources
end
```

### 7. Fix `can_extract_metals?` — read crust composition data

**Current (wrong — hardcoded mineral names):**
```ruby
def can_extract_metals?
  surface_resources.any? do |r|
    ['iron_oxide', 'aluminum', 'titanium', 'silicon'].include?(r)
  end
end
```

**Replace with — data driven from crust composition:**
```ruby
# Metal oxide formulas extractable via PVE
METAL_OXIDE_FORMULAS = %w[Fe2O3 FeO Al2O3 TiO2 MgO SiO2 CaO].freeze

def can_extract_metals?
  return false unless celestial_body.geosphere
  geo = celestial_body.geosphere
  return false unless geo.crust_composition.present?

  # Check if crust contains known metal oxides
  has_metal_oxides = geo.crust_composition.keys.any? do |mineral|
    METAL_OXIDE_FORMULAS.include?(mineral)
  end
  return true if has_metal_oxides

  # Any significant crust composition on a solid body implies
  # metal extraction potential — anorthosite, norite, troctolite
  # all contain extractable metals via PVE
  geo.crust_composition.values.any? { |v| volatile_amount(v) > 1.0 }
end
```

### 8. Fix `can_extract_oxygen?` — use chemical formulas

**Current (wrong):**
```ruby
return true if atmospheric_resources.include?('co2')
return true if surface_resources.include?('iron_oxide')
```

**Replace with:**
```ruby
def can_extract_oxygen?
  # From atmosphere via MOXIE-style CO2 processing
  return true if atmospheric_resources.include?('CO2')
  # From water electrolysis
  return true if can_extract_water?
  # From regolith metal oxide processing via PVE
  return true if can_extract_metals?
  false
end
```

### 9. Fix `can_extract_water?` — use chemical formulas

**Current (wrong):**
```ruby
surface_resources.include?('water_ice')
```

**Replace with:**
```ruby
def can_extract_water?
  water_resources.any? ||
    subsurface_resources.include?('H2O') ||
    surface_resources.include?('H2O')
end
```

---

## Synthesis Report Format

Before touching any file produce this report:
PRECURSOR CAPABILITY SERVICE SYNTHESIS REPORT
DIAGNOSTIC RESULTS:

has_solid_surface? exists: [yes/no]
Luna crust_composition keys: [list]
Luna stored_volatiles keys: [list]
Luna atmosphere: [present/nil]
Current spec failures: [N]

PROPOSED CHANGES SUMMARY:
[list each method being changed and why]
RISK ASSESSMENT:
[any methods where the change might break passing specs]
QUESTIONS FOR HUMAN:
[anything unclear before proceeding]

STOP after Synthesis Report. Do not edit any file until approved.

---

## Acceptance Criteria
- [ ] All 4 confirmed failures pass
- [ ] `can_produce_locally?` uses exact matching only
- [ ] All resource identifiers use chemical formulas (H2O, CO2,
      CH4, N2, O2, Ar, He3) not common names
- [ ] `can_extract_metals?` reads actual crust composition data
- [ ] No hardcoded world identifiers or mineral names in service logic
- [ ] Full precursor spec passes: 18 examples, 0 failures
- [ ] No regressions in related specs:
      `rspec spec/services/ai_manager/ 2>&1 | tail -10`

---

## Stop Conditions — escalate immediately if:
- `has_solid_surface?` does not exist on CelestialBody
- Luna's crust_composition keys are not what the task expects
- Any passing spec breaks after changes
- The spec tests something architecturally different from what
  this task assumes

---

## Commit Instructions

From host after all specs pass:
```bash
git add app/services/ai_manager/precursor_capability_service.rb
git commit -m "refactor: PrecursorCapabilityService — chemical formula consistency, exact matching, data-driven metal extraction"
```

---

## Dependencies
**Blocked by**: nothing
**Blocks**: Task 2 (TaskExecutionEngineV2) — engine wires to this service
**Related**: CELESTIAL_BODY_DATA_CONVENTIONS.md

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned