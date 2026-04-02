# Blueprint Polymorphic Ownership (0x Task)

**Target**: app/models/blueprint.rb

**Issue**: Blueprint model does not support polymorphic ownership, limiting flexibility for future features.

**Diagnostic**:
```bash
grep -n 'blueprint' app/models/
```

**Tasks**:
1. Synthesis Report (current state analysis) → STOP
2. Implement polymorphic ownership for blueprints
3. RSpec: expect(Blueprint.new(owner: Player.first)).to be_valid
4. Commit: "feat: polymorphic ownership for blueprints"

Priority: HIGH | 45min
