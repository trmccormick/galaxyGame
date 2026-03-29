# Covering System Worldhouse Workflow Fix
**Target**: 3 failures  
**Files**: spec/integration/covering_system_integration_spec.rb:43,155,176

**Failures**:
43: Lava tube worldhouse covering seals skylights when worldhouse completes
155: Worldhouse segment covering handles massive scale  
176: Multi-scale comparison uses same system

**Issue**: 
Worldhouse construction completion → skylight sealing failure
Massive scale covering coordinate/scale mismatch
Multi-scale system consistency

**Diagnostic Commands**:
```bash
grep -n "skylight\|worldhouse\|covering\|scale" app/models/structures/worldhouse.rb app/services/covering_system.rb
sed -n '30,60p;140,170p;160,190p' spec/integration/covering_system_integration_spec.rb
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec rails runner 'puts Structures::Worldhouse.first.inspect' > log/worldhouse_state.log 2>&1"

