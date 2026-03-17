# Task: Modernize BiomassRecycler to BaseUnit (3→0 failures + architecture upgrade)

## Assignee: GPT-4.1
## Priority: Medium (legacy → modern unit pattern)  
## Branch: main

---

## Problem

**Legacy plain Ruby object** (spec/models/biomass_recycler_spec.rb):
```ruby
BiomassRecycler.new(material_list: { 'biomass' => 50, ... }, energy_cost: 20)
3 failures from obsolete pattern. Needs conversion to:

text
Units::BiomassRecycler < Units::BaseUnit
├── operational_data blueprint
├── EnergyManagement concern  
└── #operate(inventory) → inventory.consume/produce
Current Intent (Extract from Spec)
text
operate(available_resources):
- Consume: biomass=50, energy=20
- Produce: fertilizer=10, biofuel=5  
- Return: true/false based on sufficiency
Fix Pattern (Follow Other Units)
text
1. app/models/units/biomass_recycler.rb → inherit BaseUnit
2. operational_data: { inputs: { biomass: 50 }, energy_cost: 20, outputs: { fertilizer: 10, biofuel: 5 } }
3. def operate(inventory)
     return false unless inventory.consume_materials(operational_data[:inputs]) && sufficient_energy?
     inventory.produce_materials(operational_data[:outputs])
     true
   end
4. Update spec → create(:biomass_recycler).operate(inventory)
Verify
bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/biomass_recycler_spec.rb'
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/composting_unit_spec.rb'  # Bonus
Expected: 3+3=6 examples, 0 failures

Files to Change
text
✅ app/models/units/biomass_recycler.rb (NEW)
✅ spec/models/biomass_recycler_spec.rb  
✅ spec/factories/units.rb (add biomass_recycler factory)
❌ NO: composting_unit_spec.rb (separate task)
Commit
bash
git commit -m "refactor: BiomassRecycler → BaseUnit pattern (3→0 failures)

- Legacy plain object → Units::BiomassRecycler < BaseUnit
- operational_data blueprint + EnergyManagement integration
- spec: create(:biomass_recycler).operate(inventory)
- biomass_recycler_spec.rb: 3 examples, 0 failures"
Do NOT
Touch composting_unit_spec.rb (separate task)

Modify BaseUnit or EnergyManagement concerns

Add database migrations

