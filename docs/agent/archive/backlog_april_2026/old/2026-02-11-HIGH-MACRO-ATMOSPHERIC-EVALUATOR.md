# Atmospheric Evaluator (0x Subtask)

> **ARCHIVED:** This task is superseded by 2026-04-17-HIGH-MACRO-ATMOSPHERIC-EVALUATOR.md, which now covers all atmospheric retention and event logic as a TerraSim extension. No further action required on this file.

**Target**: app/services/ai_manager/atmospheric_evaluator.rb

**Issue**: Missing retention monitoring and seasonal/dust storm event triggers

**Diagnostic**:
```bash
grep -n "retention\|dust_storm\|seasonal" app/services/ai_manager/
docker exec -it web "RAILS_ENV=test bundle exec rspec spec/services/ai_manager/atmospheric_evaluator_spec.rb -v"
```

**Tasks**:
1. Synthesis Report (current state analysis) → STOP
2. Implement retention_rate() and trigger_events() methods
3. RSpec: expect(service.retention_rate).to be < 0.95
4. Commit: "feat: atmospheric evaluator with retention + storm triggers"

Priority: HIGH | 45min