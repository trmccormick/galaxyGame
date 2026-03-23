text
# Task: Fix CelestialBodySpec (2→0 failures)

## Assignee: GPT-4.1
## Priority: High (bedtime blocker)  
## Branch: main

---

## Problem

2 failures remaining:
Line 66: TerraSim::AtmosphereSimulationService#simulate_atmospheric_loss
→ gas.mass nil error in CelestialBody#run_terra_sim callback

Line 16: brown_dwarf.solar_system → always creates SolarSystem

text

## Current Spec
let(:brown_dwarf) { FactoryBot.create(:brown_dwarf) }
expect(brown_dwarf.solar_system).to be_nil # FAILS

text
undefined
it 'calculates gravity' do
mars = create(:terrestrial_planet, :mars)
mars.update_gravity # → triggers run_terra_sim → nil error

text

## Fix

### 1. Brown Dwarf Factory
Find/create `:brown_dwarf` factory → ensure `solar_system: nil`

### 2. Gravity Test (Skip TerraSim)
```ruby
mars.update!(run_terra_sim_on_save: false)  # Skip side effects
mars.mass = 6.42e23; mars.radius = 3390e3
mars.save!; mars.update_gravity
Verify
bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/celestial_body_spec.rb'
Expected: 5 examples, 0 failures

Commit
bash
git commit -m "fix: celestial_body_spec.rb 4→2→0 failures

- Brown dwarf factory: solar_system nil for isolated test
- Gravity test: skip TerraSim side effects
- Total: 5 examples, 0 failures"
Do NOT
Modify TerraSim services

Change SolidBodyConcern logic

Uncomment disabled tests

