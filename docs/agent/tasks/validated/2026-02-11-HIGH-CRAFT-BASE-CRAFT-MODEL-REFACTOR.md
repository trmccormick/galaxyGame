# Base Craft Model Refactor (0x Task)

**Target**: app/models/craft/base_craft.rb

**Issue**: BaseCraft model is overly complex and lacks modularity for new craft types and upgrades.

**Diagnostic**:
```bash
grep -n 'BaseCraft' app/models/craft/
```

**Tasks**:
1. Synthesis Report (current state analysis) → STOP
2. Refactor BaseCraft for modularity and extensibility
3. RSpec: expect(Craft::BaseCraft).to respond_to(:upgrade)
4. Commit: "refactor: modularize BaseCraft model"

Priority: HIGH | 1hr
