# Fix Terrain Quality (0x Task)

**Target**: app/services/terrain/terrain_quality_service.rb

**Issue**: Terrain quality issues reduce visual fidelity, data accuracy, and rendering performance for planetary surfaces.

**Diagnostic**:
```bash
grep -n 'terrain_quality' app/services/terrain/
unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/terrain/terrain_quality_service_spec.rb -v
```

**Tasks**:
1. Synthesis Report (current state analysis) → STOP
2. Implement fixes for pattern loading, parameter tuning, and visual quality
3. RSpec: expect(service.quality_score).to be > 0.9
4. Commit: "fix: improve terrain quality and rendering"

Priority: HIGH | 1hr
