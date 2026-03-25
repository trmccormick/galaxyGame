# Biology LifeForm Growth Fix
**Target**: 4 failures  
**Files**: 
- spec/models/biology/life_form_spec.rb:51,66  
- spec/models/biology/life_form_library_spec.rb:51,66

**Issue**:
- Biology::LifeForm#simulate_growth not calling _calculate_base_growth_rate  
- Biosphere habitability factor ignored in growth calculation

**Diagnostic Commands**:
```bash
grep -n "simulate_growth\|_calculate_base_growth_rate\|habitability\|biosphere" app/models/biology/life_form*.rb
sed -n '40,80p' spec/models/biology/life_form_spec.rb
sed -n '40,80p' spec/models/biology/life_form_library_spec.rb
Success Criteria:

rspec spec/models/biology/life_form_spec.rb → 0 failures

rspec spec/models/biology/life_form_library_spec.rb → 0 failures

rspec spec/models/biology/ → biology suite clean