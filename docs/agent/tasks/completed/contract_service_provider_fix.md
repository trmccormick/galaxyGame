# 2026-03-14 - ⚠️ HIGH: Fix Contract Service — Seed Logistics Providers + Assign Provider to NPC Contracts

==============================================================================

**AGENT ROLE:** Executor (Implementation)

**CONTEXT:** `Logistics::ContractService.create_internal_transfer` creates
contracts between NPC settlements. `Logistics::Contract` requires a provider
(`belongs_to :provider`). `Logistics::Provider` records represent logistics
corporations (AstroLift, Zenith Orbital, Vector Hauling) — the operational
interface for moving cargo. These organizations are seeded in `db/seeds.rb`
but their corresponding `Logistics::Provider` records have never been created.

Additionally, `create_internal_transfer` calls `PlayerContractService` which
does not exist yet (Act 2 feature). This call must be guarded so it fails
gracefully rather than raising `NameError`.

Read before implementing:
- `docs/architecture/LOGISTICS_PROVIDER_INTENT.md`
- `docs/architecture/DUAL_ECONOMY_INTENT.md`

**ISSUE:** 1 failure:
```
rspec ./spec/services/logistics/contract_service_spec.rb:18
ActiveRecord::RecordInvalid: Validation failed: Provider must exist
```

**ROOT CAUSE:** Three related issues:
1. `db/seeds.rb` creates AstroLift/Zenith/Vector as organizations but never
   creates their `Logistics::Provider` records
2. `create_internal_transfer` never assigns a provider to the fallback contract
3. `create_player_contract` calls `PlayerContractService` which does not exist,
   will raise `NameError` at runtime

**REQUIRED FIX:** Three changes across three files.

---

**IMPLEMENTATION DETAILS:**

### Change 1 — `db/seeds.rb`

**First check the schema to confirm field names:**
```bash
docker exec -it web bash -c 'grep -A 30 "create_table \"logistics_providers\"" /home/galaxy_game/db/schema.rb'
```

After creating each logistics corporation, create its `Logistics::Provider`
record linked to the organization. Add this AFTER the existing organization
creation blocks:

```ruby
# Create Logistics::Provider records for each logistics corporation
# These link the operational capability layer to the economic/legal entity layer
# base_fee_per_kg reflects EAP-era pricing — will decrease as infrastructure matures
# See docs/architecture/LOGISTICS_PROVIDER_INTENT.md for full intent
puts "Creating Logistics::Provider records..."

Logistics::Provider.find_or_create_by!(name: 'AstroLift Operations') do |p|
  p.organization = astrolift
  p.reliability_rating = 4.8
  p.base_fee_per_kg = 150.0
  p.speed_multiplier = 1.0
  p.capabilities = ['orbital_transfer', 'surface_conveyance']
  p.cost_modifiers = {
    'bulk_discount_thresholds' => [
      { 'quantity' => 10000, 'multiplier' => 0.95 },
      { 'quantity' => 100000, 'multiplier' => 0.90 }
    ],
    'orbital_transfer_discount' => 0.9
  }
  p.time_modifiers = { 'orbital_transfer_speedup' => 0.8 }
end
puts "  ✓ AstroLift provider record created"

Logistics::Provider.find_or_create_by!(name: 'Zenith Orbital Operations') do |p|
  p.organization = zenith
  p.reliability_rating = 4.5
  p.base_fee_per_kg = 175.0
  p.speed_multiplier = 0.9
  p.capabilities = ['orbital_transfer']
  p.cost_modifiers = {
    'bulk_discount_thresholds' => [],
    'orbital_transfer_discount' => 0.85
  }
  p.time_modifiers = { 'orbital_transfer_speedup' => 0.75 }
end
puts "  ✓ Zenith Orbital provider record created"

Logistics::Provider.find_or_create_by!(name: 'Vector Hauling Operations') do |p|
  p.organization = vector
  p.reliability_rating = 4.2
  p.base_fee_per_kg = 120.0
  p.speed_multiplier = 1.1
  p.capabilities = ['orbital_transfer', 'surface_conveyance', 'drone_delivery']
  p.cost_modifiers = {
    'bulk_discount_thresholds' => [
      { 'quantity' => 50000, 'multiplier' => 0.92 },
      { 'quantity' => 500000, 'multiplier' => 0.85 }
    ],
    'orbital_transfer_discount' => 0.88
  }
  p.time_modifiers = { 'orbital_transfer_speedup' => 0.85 }
end
puts "  ✓ Vector Hauling provider record created"
```

**Note:** If `Logistics::Provider` validates `identifier` as required, add it
to each block. Check the model validations:
```bash
docker exec -it web bash -c 'grep -n "validates" /home/galaxy_game/app/models/logistics/provider.rb'
```

### Change 2 — `app/services/logistics/contract_service.rb`

**2a.** Add `find_provider` private method. Add this inside the `private`
section of the class:
```ruby
def self.find_provider(transport_method)
  # Find best available provider by capability and reliability rating.
  # Provider base_fee_per_kg reflects current infrastructure maturity —
  # rates decrease as LEO depot, L1 shipyard, and cyclers come online.
  # See docs/architecture/LOGISTICS_PROVIDER_INTENT.md
  Logistics::Provider.all.select { |p|
    Array(p.capabilities).include?(transport_method.to_s)
  }.max_by(&:reliability_rating)
end
```

**2b.** In `create_internal_transfer`, find provider and assign to fallback
contract. Locate the `Logistics::Contract.create!` block and update:
```ruby
# Find provider before creating contract
provider = find_provider(transport_method)
return nil unless provider

contract = Logistics::Contract.create!(
  from_settlement: from_settlement,
  to_settlement: to_settlement,
  material: material,
  quantity: quantity,
  transport_method: transport_method,
  status: :pending,
  provider: provider,
  scheduled_at: calculate_delivery_time(from_settlement, to_settlement, transport_method),
  operational_data: {
    purpose: 'internal_b2b_transfer',
    created_by: 'ai_manager'
  }
)
```

**2c.** Guard the `create_player_contract` call — `PlayerContractService`
is an Act 2 feature that does not exist yet. Find the call and wrap it:
```ruby
# BEFORE:
player_contract = create_player_contract(from_settlement, to_settlement, material, quantity, transport_method)

# AFTER:
# TODO: Act 2 — PlayerContractService will handle player-visible contract posting
# Players get first opportunity to fill logistics contracts and earn GCC
# For now (Act 1), fall through directly to NPC provider fallback
player_contract = nil
if defined?(PlayerContractService)
  player_contract = create_player_contract(from_settlement, to_settlement, material, quantity, transport_method)
end
```

### Change 3 — `spec/services/logistics/contract_service_spec.rb`

Add a logistics provider to the spec setup. The service queries the DB for
providers, so one must exist before the test runs:

```ruby
# Add after the settlement let declarations:
let(:logistics_provider) do
  create(:logistics_provider,
    capabilities: ['orbital_transfer', 'surface_conveyance'],
    reliability_rating: 4.8,
    base_fee_per_kg: 150.0
  )
end
```

Reference it in the `before` block to ensure it's created before service runs:
```ruby
before do
  logistics_provider  # ensure provider exists in DB
  allow(from_settlement).to receive_message_chain(:inventory, :current_storage_of)
    .with(material).and_return(2000)
  allow(to_settlement).to receive_message_chain(:inventory, :current_storage_of)
    .with(material).and_return(100)
end
```

---

**TESTING SEQUENCE:**

1. Check schema and model validations before editing seeds:
```bash
docker exec -it web bash -c 'grep -A 30 "create_table \"logistics_providers\"" /home/galaxy_game/db/schema.rb && echo "===" && grep -n "validates" /home/galaxy_game/app/models/logistics/provider.rb'
```

2. Apply all three changes.

3. Run contract service spec:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/logistics/contract_service_spec.rb > /home/galaxy_game/log/rspec_logistics_$(date +%s).log 2>&1'
```
```bash
tail -10 $(ls -t /home/galaxy_game/log/rspec_logistics_*.log | head -1)
```
Expected: `X examples, 0 failures`

4. Run full logistics cluster:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/logistics/ > /home/galaxy_game/log/rspec_logistics_$(date +%s).log 2>&1'
```
```bash
tail -5 $(ls -t /home/galaxy_game/log/rspec_logistics_*.log | head -1)
```

5. Run full cluster regression check:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/ spec/services/pressurization/ spec/services/logistics/ spec/services/terra_sim/ --format progress 2>&1 | grep "examples,"'
```

6. Copy architecture docs to proper location (they will be in active tasks):
```bash
cp docs/agent/tasks/active/LOGISTICS_PROVIDER_INTENT.md docs/architecture/LOGISTICS_PROVIDER_INTENT.md
cp docs/agent/tasks/active/PRICE_DISCOVERY_LIFECYCLE.md docs/architecture/PRICE_DISCOVERY_LIFECYCLE.md
```

7. Four atomic commits from host:
```bash
# Commit 1: Seeds
git add db/seeds.rb
git commit -m "[Seeds] Add Logistics::Provider records for AstroLift, Zenith, Vector

- Provider records link organization economic layer to contract operational layer
- base_fee_per_kg set at EAP-era baseline (decreases as infrastructure matures)
- Capabilities reflect each corp specialization per LOGISTICS_PROVIDER_INTENT.md"

# Commit 2: Service fix
git add app/services/logistics/contract_service.rb
git commit -m "[Logistics] Fix contract creation — assign provider, guard PlayerContractService

- Added find_provider: selects by capability + highest reliability rating
- Fallback NPC contract now assigns provider before create!
- Guarded PlayerContractService call with defined? check (Act 2 feature)
- Returns nil gracefully if no capable provider found"

# Commit 3: Spec fix
git add spec/services/logistics/contract_service_spec.rb
git commit -m "[Logistics] Fix contract_service_spec — add logistics_provider to test setup

- Provider must exist in DB for find_provider to return a result
- Creates provider with orbital_transfer capability matching test transport method"

# Commit 4: Architecture docs
git add docs/architecture/LOGISTICS_PROVIDER_INTENT.md
git add docs/architecture/PRICE_DISCOVERY_LIFECYCLE.md
git commit -m "[Docs] Add logistics provider and price discovery architecture docs

- LOGISTICS_PROVIDER_INTENT.md: two-layer model, provider selection, price phases
- PRICE_DISCOVERY_LIFECYCLE.md: EAP baseline, infrastructure progression, player opportunities"
```

8. Move task to completed and update CURRENT_STATUS.md.

---

**EXPECTED RESULT:**
- `Logistics::Provider` records exist for all three logistics corps after seed
- `create_internal_transfer` finds provider by capability and creates contract
- `PlayerContractService` absence no longer causes runtime errors
- `contract_service_spec` passes fully
- No regressions in cluster

**CRITICAL CONSTRAINTS:**
- All RSpec runs via `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec ...'`
- Never use docker-compose exec
- Do NOT make provider optional on `Logistics::Contract` model
- Do NOT implement `PlayerContractService` — Act 2 scope
- Do NOT hardcode provider names — always query by capability
- Check schema BEFORE editing seeds
- Four atomic commits as specified
- Git commits from host only, specific files only

**MANDATORY REFERENCES:**
- GUARDRAILS.md: NPC architecture, DC corporation model
- CONTRIBUTOR_TASK_PLAYBOOK.md: Git commit format, test logging
- ENVIRONMENT_BOUNDARIES.md: docker exec form only
- docs/architecture/LOGISTICS_PROVIDER_INTENT.md: Provider architecture
- docs/architecture/DUAL_ECONOMY_INTENT.md: Full economic model

**REMINDER:** Executor role only. Check schema first, three code changes,
four atomic commits, archive task. Do not implement PlayerContractService
or dynamic TransportCostService pricing — separate backlog items.

==============================================================================
