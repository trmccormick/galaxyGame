# AI Resource Allocation Engine (0x Task)

**Target**: app/services/ai_manager/resource_allocation_engine.rb

**Issue**: No automated engine for bootstrap logistics, ISRU priority, and economic startup planning for new colonies.

**Diagnostic**:
```bash
grep -n 'resource_allocation\|isru' app/services/ai_manager/
unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/resource_allocation_engine_spec.rb -v
```

**Tasks**:
1. Synthesis Report (current state analysis) → STOP
2. Implement resource allocation, ISRU priority, and economic startup logic
3. RSpec: expect(service.bootstrap_complete?).to be true
4. Commit: "feat: AI resource allocation engine for colony bootstrap"

Priority: HIGH | 1hr
