# Task: Fix LifeForm Growth Specs to Use Biosphere Integration

**Priority:** MEDIUM  
**Time Estimate:** 45 min  
**Agent:** Implementation Agent (GPT-4.1/Local)

---

## Problem

Specs for `LifeForm` and `LifeFormLibrary` currently test direct growth logic, bypassing the intended simulation path. This leads to incorrect results under Mars-like conditions (expected: 1300, got: 1002) because the biosphere context and environmental integration are skipped.

**Root Cause:**
- Tests call growth methods directly instead of using the canonical simulation path:
  - `Biosphere#simulate_tick` → `life_forms.simulate_growth(biome_conditions)`

---

## Solution: Use Biosphere Integration Path

### 1. Earth-like Setup
- Create a biosphere and associated `planet_biome` with Earth-like conditions:
  - Temperature: **288K**
  - Oxygen: **21%**
  - CO₂: **0.04%**

### 2. LifeForm Creation
- Use `LifeFormLibrary.create_via_biosphere` to instantiate the life form within the biosphere context.

### 3. Simulate Growth
- Call `biosphere.simulate_tick` to trigger growth for all life forms, using the correct environmental context.
- Verify that the resulting population matches the canonical value (**1300**) for Earth-like conditions.

### 4. Update Specs
- Update both `life_form_spec.rb` and `life_form_library_spec.rb` (see line 63 in each) to:
  - Use the above integration path
  - Remove/replace any direct growth calls
  - Assert the correct population result

---

## References
- [Biology Models Overview](../../architecture/biology/biology_models.md)
- [Biome Model Intent](../../architecture/biology/biome_model.md)
- [TerraSim Service Intent](../../architecture/biology/terrasim_service.md)

---

## Handoff Command

```sh
# For Implementation Agent (GPT-4.1/Local):
# Fix LifeForm specs to use biosphere integration path as described in docs/agent/tasks/active/biology_growth_via_biosphere.md
```

---

## Acceptance Criteria
- [ ] Both specs use biosphere integration path
- [ ] Earth-like conditions are set via planet_biome
- [ ] LifeFormLibrary is used for creation
- [ ] biosphere.simulate_tick is called
- [ ] Population result is 1300
- [ ] No direct growth calls remain in the specs
