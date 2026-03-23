# 2026-03-13 - ⚠️ HIGH: Fix Pressurization Spec — Remove Duplicate Depot Tank Block

==============================================================================

**AGENT ROLE:** Executor (Implementation)

**CONTEXT:** `Pressurization::StructurePressurizationService` was refactored this
session to source gases from `settlement.inventory.items` instead of legacy
`depot_tank` structures with `operational_data['gas_storage']`. The spec was
rewritten to match, but the old depot_tank block was appended instead of
replacing the file — leaving two complete `RSpec.describe` blocks in the same
file.

**ISSUE:** 4 spec failures at lines 74, 130, 162, 211:
```
rspec ./spec/services/pressurization/structure_pressurization_service_spec.rb:74
rspec ./spec/services/pressurization/structure_pressurization_service_spec.rb:130
rspec ./spec/services/pressurization/structure_pressurization_service_spec.rb:162
rspec ./spec/services/pressurization/structure_pressurization_service_spec.rb:211
```
All 4 are in the second (old) `RSpec.describe` block which still uses
`create(:depot_tank)` and `operational_data['gas_storage']` — both of which
no longer match the service implementation.

**ROOT CAUSE:** The file contains two `RSpec.describe` blocks and a duplicate
`require 'rails_helper'`. The first block (lines ~1–100) is correct and
inventory-based. The second block (lines ~101–end) is the old depot_tank
version that was appended instead of replaced.

**IMPACT:** 4 false failures in the current cluster run. These tests will never
pass because the service no longer reads from `operational_data['gas_storage']`.

**REQUIRED FIX:** Replace the entire file with only the correct inventory-based
block. No service changes needed — the service method names
(`pressurize_structure`, `source_gases_from_depot_tanks`) are unchanged.

**IMPLEMENTATION DETAILS:**

Replace `spec/services/pressurization/structure_pressurization_service_spec.rb`
with the following content exactly — one `require 'rails_helper'`, one
`RSpec.describe` block:

```ruby
require 'rails_helper'

RSpec.describe Pressurization::StructurePressurizationService, type: :service do
  let(:player) { create(:player) }
  let(:settlement) { create(:base_settlement, :station, owner: player) }
  let(:structure) { create(:base_structure, settlement: settlement) }

  describe '.pressurize_structure' do
    context 'when gases are available in inventory' do
      before do
        create(:item, name: 'O2', material_type: :gas, amount: 800,
               inventory: settlement.inventory, owner: player)
        create(:item, name: 'N2', material_type: :gas, amount: 1800,
               inventory: settlement.inventory, owner: player)
      end

      it 'sources gases from settlement inventory' do
        expect(described_class).to receive(:source_gases_from_depot_tanks)
          .with(settlement).and_call_original
        described_class.pressurize_structure(structure)
      end

      it 'uses inventory gases for pressurization' do
        result = described_class.pressurize_structure(structure)
        expect(result[:available_gases]).to include(:oxygen, :nitrogen)
        expect(result[:available_gases][:oxygen]).to eq(800)
        expect(result[:available_gases][:nitrogen]).to eq(1800)
      end
    end

    context 'when no gases are available' do
      it 'falls back to standard pressurization logic' do
        expect(described_class).to receive(:source_gases_from_depot_tanks)
          .with(settlement).and_return({})
        described_class.pressurize_structure(structure)
      end
    end
  end

  describe '.source_gases_from_depot_tanks' do
    context 'when settlement has gas items in inventory' do
      before do
        create(:item, name: 'O2', material_type: :gas, amount: 500,
               inventory: settlement.inventory, owner: player)
        create(:item, name: 'N2', material_type: :gas, amount: 1000,
               inventory: settlement.inventory, owner: player)
        create(:item, name: 'O2', material_type: :gas, amount: 300,
               inventory: settlement.inventory, owner: player)
        create(:item, name: 'N2', material_type: :gas, amount: 800,
               inventory: settlement.inventory, owner: player)
      end

      it 'aggregates gases from inventory' do
        result = described_class.send(:source_gases_from_depot_tanks, settlement)
        expect(result[:oxygen]).to eq(800)  # 500 + 300
        expect(result[:nitrogen]).to eq(1800) # 1000 + 800
      end
    end

    context 'when settlement has no gas items' do
      it 'returns empty hash' do
        result = described_class.send(:source_gases_from_depot_tanks, settlement)
        expect(result).to eq({})
      end
    end

    context 'when inventory has only non-gas items' do
      before do
        create(:item, name: 'ibeam', material_type: :solid, amount: 500,
               inventory: settlement.inventory, owner: player)
      end

      it 'returns empty hash' do
        result = described_class.send(:source_gases_from_depot_tanks, settlement)
        expect(result).to eq({})
      end
    end
  end

  describe 'mining byproduct integration' do
    before do
      create(:item, name: 'O2', material_type: :gas, amount: 100,
             inventory: settlement.inventory, owner: player)
      create(:item, name: 'N2', material_type: :gas, amount: 200,
             inventory: settlement.inventory, owner: player)
    end

    context 'when mining Si produces O2 byproduct' do
      it 'increases available gases from inventory for pressurization' do
        initial_gases = described_class.send(:source_gases_from_depot_tanks, settlement)
        initial_o2 = initial_gases[:oxygen]

        Manufacturing::ByproductManufacturingService.process_mining_byproducts(
          settlement, 'Si', 1000
        )

        updated_gases = described_class.send(:source_gases_from_depot_tanks, settlement)
        updated_o2 = updated_gases[:oxygen]

        expect(updated_o2).to eq(initial_o2 + 500)
      end
    end
  end
end
```

**TESTING SEQUENCE:**

1. Verify the file currently has 2 describe blocks (expected output: `2`):
```bash
docker exec -it web bash -c 'grep -c "RSpec.describe" /home/galaxy_game/spec/services/pressurization/structure_pressurization_service_spec.rb'
```

2. Replace the file with the correct content above.

3. Verify the file now has exactly 1 describe block (expected output: `1`):
```bash
docker exec -it web bash -c 'grep -c "RSpec.describe" /home/galaxy_game/spec/services/pressurization/structure_pressurization_service_spec.rb'
```

4. Run the pressurization spec and confirm 0 failures:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/pressurization/structure_pressurization_service_spec.rb > ./log/rspec_full_$(date +%s).log 2>&1'
```
Check result:
```bash
tail -5 $(ls -t /home/galaxy_game/log/rspec_full_*.log | head -1)
```
Expected: `X examples, 0 failures`

5. Run the full cluster to confirm no regressions:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/ spec/services/pressurization/ spec/services/logistics/ spec/services/terra_sim/ --format progress 2>&1 | grep "examples,"'
```
Expected: `327 examples, 9 failures` (down from 13 — pressurization 4 resolved)

6. Commit from host only:
```bash
git add spec/services/pressurization/structure_pressurization_service_spec.rb
git commit -m "[Pressurization] Remove duplicate depot_tank RSpec block from spec

- File had two RSpec.describe blocks: correct inventory-based block + old depot_tank block
- Removed old block that referenced create(:depot_tank) and operational_data['gas_storage']
- Service implementation already uses inventory; spec now matches
- Resolves 4 failures at lines 74, 130, 162, 211"
```

**EXPECTED RESULT:**
- `grep -c "RSpec.describe"` returns `1`
- Pressurization spec: 0 failures
- Full cluster: 9 failures remaining (down from 13)
- No service files modified

**CRITICAL CONSTRAINTS:**
- All RSpec runs via `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec ...'` — never bare, never docker-compose exec
- Do NOT modify any service files — this is a spec-only fix
- Do NOT rename any methods — `source_gases_from_depot_tanks` is the correct method name on the service and must remain
- Fix-test loop on the spec only until green
- Git commit from host only (never inside a docker exec call)

**MANDATORY REFERENCES:**
- GUARDRAILS.md: Inventory system rules — gas quantities always from `inventory.items.where(material_type: :gas)`, never `operational_data`
- CONTRIBUTOR_TASK_PLAYBOOK.md: Git commit format, test logging requirements
- ENVIRONMENT_BOUNDARIES.md: docker exec form only, no docker-compose exec

**REMINDER:** Executor role only — make the spec file change, run tests, commit.
No architectural decisions, no service rewrites, no scope creep.

==============================================================================
