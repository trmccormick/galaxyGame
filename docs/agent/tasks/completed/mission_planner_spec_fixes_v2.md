# Task: Fix mission_planner_service_spec.rb — 4 Remaining Failures

## Context
`spec/services/ai_manager/mission_planner_service_spec.rb` has 4 remaining failures
after previous fixes. All are spec bugs, not service bugs. Do NOT modify any
service files — only fix the spec.

## Background
- The codebase uses `create(:celestial_body)` — there is NO `:terrestrial_planet` factory
- Atmosphere gases are seeded manually via `atmosphere.gases.find_or_create_by` 
- See `priority_heuristic_spec.rb` for the established pattern of setting up Mars atmosphere

---

## Fix 1: 'data-driven local production' describe block (failure at line 154)

### Problem
Uses `create(:terrestrial_planet, :mars)` which does not exist.
Also missing CO2 atmosphere setup so `gas_percentage('CO2')` returns 0.

### Find this block (around line 145):
```ruby
describe 'data-driven local production' do
  let(:solar_system) { create(:solar_system) }
  let!(:mars) { create(:terrestrial_planet, :mars, solar_system: solar_system) }
  let(:planner) { described_class.new('mars-terraforming') }
  
  before do
    allow(AIManager::PatternTargetMapper).to receive(:target_location).and_return(mars)
  end
```

### Replace with:
```ruby
describe 'data-driven local production' do
  let(:solar_system) { create(:solar_system) }
  let!(:mars) { create(:celestial_body, name: 'Mars', solar_system: solar_system) }
  let(:planner) { described_class.new('mars-terraforming') }

  before do
    allow(AIManager::PatternTargetMapper).to receive(:target_location).and_return(mars)
    mars.atmosphere.update!(composition: { "CO2" => 95.97, "Ar" => 1.93, "N2" => 1.89 })
    co2_gas = mars.atmosphere.gases.find_or_create_by(name: 'CO2')
    co2_gas.update!(percentage: 95.97)
    ar_gas = mars.atmosphere.gases.find_or_create_by(name: 'Ar')
    ar_gas.update!(percentage: 1.93)
  end
```

---

## Fix 2: 'MaterialLookupService integration' describe block (failures at lines 186, 200)

### Problem
Uses `create(:terrestrial_planet, :mars)` which does not exist.

### Find this block (around line 179):
```ruby
describe 'MaterialLookupService integration' do
  let(:planner) { described_class.new('mars-terraforming') }
  let(:solar_system) { create(:solar_system) }
  let(:mars) { create(:terrestrial_planet, :mars, solar_system: solar_system) }
```

### Replace with:
```ruby
describe 'MaterialLookupService integration' do
  let(:solar_system) { create(:solar_system) }
  let(:mars) { create(:celestial_body, name: 'Mars', solar_system: solar_system) }
  let(:planner) { described_class.new('mars-terraforming') }
```

NOTE: If this block already has `let(:solar_system)` and `let(:mars)` from a
previous fix that resolved a NameError, update those existing lines rather than
adding duplicates.

---

## Verification

Run the three target failures:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/mission_planner_service_spec.rb:154 spec/services/ai_manager/mission_planner_service_spec.rb:186 spec/services/ai_manager/mission_planner_service_spec.rb:200 --format progress 2>&1 | tail -3'
```
Expected: 3 examples, 0 failures

Run the full mission_planner spec:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/mission_planner_service_spec.rb --format progress 2>&1 | tail -3'
```
Expected: 0 failures

Run full ai_manager suite to confirm no regressions:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/ --format progress 2>&1 | grep "examples,"'
```
Expected: 709 examples, 2 failures (only strategy_selector:233 and strategy_selector:381)
