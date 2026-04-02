# AI Autonomous Expansion MVP Focus (0x Task)

**Target**: app/services/ai_manager/expansion_service.rb

**Issue**: AI Manager lacks fully autonomous expansion logic for independent colony establishment and network-aware planning.

**Diagnostic**:
```bash
grep -n 'autonomous\|expansion' app/services/ai_manager/
unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/expansion_service_spec.rb -v
```

**Tasks**:
1. Synthesis Report (current state analysis) → STOP
2. Implement autonomous expansion logic (discovery, decision, network, foothold, adaptation)
3. RSpec: expect(service.autonomous_expansion?).to be true
4. Commit: "feat: AI Manager autonomous expansion MVP"

Priority: HIGH | 1hr
