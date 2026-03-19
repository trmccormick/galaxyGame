# Task: Fix Geosphere Composition Percentage Calculation (1→0 failures)

## Assignee: GPT-4.1  
## Priority: High (blocking geosphere_spec.rb completion)
## Branch: main

---

## Problem

`spec/models/celestial_bodies/spheres/geosphere_spec.rb:192` fails:

expect(geosphere.crust_composition['Si']).to be_within(0.001).of(50)
expected 100.0 ← WRONG

text

**LOG EVIDENCE** (line 586 `update_layer_composition`):
Si CREATE: amount=2000.0 ❌ (double amount)
Si UPDATE: amount=1000.0 ✅
crust_composition: {"Fe":50.0,"Si":100.0} ❌

text

**Root cause**: Line 586 in `GeosphereConcern#update_layer_composition`:
```ruby
layer_materials.each do |material|
  next if material.amount.to_f <= 0
  percentage = (material.amount.to_f / total_mass) * 100  # total_mass STALE
  new_composition[material.name] = percentage
end
total_mass calculated before second material added → Si gets 100% instead of 50%.

Fix
Replace line 586 block exactly:

ruby
# WRONG (line 586):
layer_materials.each do |material|
  next if material.amount.to_f <= 0
  percentage = (material.amount.to_f / total_mass) * 100
  new_composition[material.name] = percentage
end

# CORRECT:
total_amount = layer_materials.sum(&:amount)  # FRESH total after both materials
layer_materials.each do |material|
  next if material.amount.to_f <= 0
  percentage = (material.amount.to_f / total_amount) * 100
  new_composition[material.name] = percentage.round(3)
end
File: app/models/concerns/geosphere_concern.rb (~line 586)

Do NOT
Touch migration files

Modify add_material or update_material_records

Change any other composition calculation blocks

Modify the spec file

Run full suite - test isolation only

Verify
1. Isolation test:

bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/celestial_bodies/spheres/geosphere_spec.rb:192 --format documentation'
2. Full geosphere verification:

bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/celestial_bodies/spheres/geosphere_spec.rb --format progress'
Expected: 30 examples, 0 failures, 3 pending

3. Commit atomic:

bash
git add app/models/concerns/geosphere_concern.rb
git commit -m "fix: geosphere composition normalization (1→0 failures)

- Line 586: use layer_materials.sum(&:amount) vs stale total_mass
- geosphere_spec.rb:192 now passes (Fe=50%, Si=50%)
- Full geosphere: 30 examples, 0 failures, 3 pending"
SUCCESS CRITERIA
text
✅ rspec spec/models/celestial_bodies/spheres/geosphere_spec.rb:192 [GREEN]
✅ rspec spec/models/celestial_bodies/spheres/geosphere_spec.rb [30/0/3]
✅ git diff shows ONLY geosphere_concern.rb line 586 block