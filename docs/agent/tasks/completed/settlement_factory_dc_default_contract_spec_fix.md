# 2026-03-14 - ⚠️ HIGH: Fix Settlement Factory Default Owner + Contract Spec

==============================================================================

**AGENT ROLE:** Executor (Implementation)

**CONTEXT:** The Galaxy Game economic model is built around Development
Corporations (DCs) as the primary settlement owners. DCs are non-profit NPC
entities (LDC, MDC, TDC etc.) that bootstrap world colonization through the
Virtual Ledger system. In practice, virtually every settlement in the early game
is DC-owned. The base settlement factory currently defaults to a player owner
which is architecturally wrong — DC corporation is the correct default.

Additionally, the `:independent` trait on `base_settlement` was recently
incorrectly modified to nullify the owner association. `:independent` means
"not a colony member" (colony_id: nil) — it has nothing to do with ownership.
A remote DC mining outpost is independent. A player-owned station is independent.
Independent simply means no colony membership.

**ISSUE:** 1 failure:
```
rspec ./spec/services/logistics/contract_service_spec.rb:18
# Logistics::ContractService.create_internal_transfer with valid settlements
# creates a logistics contract for internal transfer
```
`valid_settlement_pair?` correctly requires NPC ownership for internal B2B
transfers (LDC-to-AstroLift style contracts via Virtual Ledger). The spec fails
because settlements are created with player owners due to the wrong factory
default.

**ROOT CAUSE:** Three related issues:
1. `base_settlement` factory defaults to `association :owner, factory: :player`
   — should default to a DC corporation
2. `:independent` trait was modified to set `owner: nil` — wrong, it should
   only set `colony: nil`
3. Contract spec uses `:independent` expecting ownerless settlements — wrong
   mental model, spec needs two NPC-owned settlements

**ARCHITECTURAL INTENT — READ BEFORE IMPLEMENTING:**
- DC corporations are NPC entities (`is_npc?` returns true for
  `development_corporation` organization_type)
- Internal B2B contracts move assets between NPC-owned settlements outside
  the public market, using GCC or Virtual Ledger
- `valid_settlement_pair?` NPC ownership check is correct and must not be changed
- `:independent` = no colony membership only, owner is always present
- Settlements always have an owner — player, NPC corporation, or eventually colony

**REQUIRED FIX:** Three changes across two factory files and one spec file.

**IMPLEMENTATION DETAILS:**

### Change 1 — `spec/factories/organizations.rb`
Add a `:development_corporation` trait to the existing `:organization` factory:

```ruby
trait :development_corporation do
  organization_type { 'development_corporation' }
  operational_data { { 'is_npc' => true, 'status' => 'Active' } }
end
```

Also add a top-level factory alias for convenience:
```ruby
factory :development_corporation, parent: :organization do
  organization_type { 'development_corporation' }
  operational_data { { 'is_npc' => true, 'status' => 'Active' } }
end
```

### Change 2 — `spec/factories/settlement/base_settlement.rb`
Two changes in this file:

**2a.** Change the default owner from player to DC corporation:
```ruby
# BEFORE
association :owner, factory: :player

# AFTER
association :owner, factory: :development_corporation
```

**2b.** Restore `:independent` trait to colony-only — remove the owner
nullification that was incorrectly added:
```ruby
# BEFORE
trait :independent do
  owner { nil }
  owner_type { nil }
  owner_id { nil }
  colony { nil }
end

# AFTER
trait :independent do
  colony { nil }
end
```

Note: also fix the `:independent` trait on the `:settlement` factory lower
in the same file — it also incorrectly sets `owner { nil }`:
```ruby
# BEFORE
trait :independent do
  owner { nil }
end

# AFTER  
trait :independent do
  colony { nil }
end
```

### Change 3 — `spec/services/logistics/contract_service_spec.rb`
Remove `:independent` from the settlement creation. The default DC owner
is correct for this spec — two DC-owned settlements transferring resources
via internal contract is exactly the intended use case:

```ruby
# BEFORE
let(:from_settlement) { create(:base_settlement, :independent, name: 'Supplier Base') }
let(:to_settlement)   { create(:base_settlement, :independent, name: 'Consumer Base') }

# AFTER
let(:from_settlement) { create(:base_settlement, name: 'Supplier Base') }
let(:to_settlement)   { create(:base_settlement, name: 'Consumer Base') }
```

**TESTING SEQUENCE:**

1. Apply all three changes.

2. Verify DC corporation `is_npc?` returns true:
```bash
docker exec -it web bash -c 'bundle exec rails runner "
  org = Organizations::BaseOrganization.new(organization_type: :development_corporation)
  puts \"is_npc?: #{org.is_npc?}\"
"'
```
Expected: `is_npc?: true`

3. Run contract service spec:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/logistics/contract_service_spec.rb > ./log/rspec_full_$(date +%s).log 2>&1'
```
```bash
tail -5 $(ls -t /home/galaxy_game/log/rspec_full_*.log | head -1)
```
Expected: `X examples, 0 failures`

4. Run the full cluster to check for regressions from the factory default change:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/ spec/services/pressurization/ spec/services/logistics/ spec/services/terra_sim/ --format progress 2>&1 | grep "examples,"'
```

5. If regressions appear, check if the failing spec explicitly needs a player
owner — if so, add `owner: create(:player)` to that specific test. Do not
revert the factory default.

6. Commit from host — three files, one commit:
```bash
git add spec/factories/organizations.rb
git add spec/factories/settlement/base_settlement.rb
git add spec/services/logistics/contract_service_spec.rb
git commit -m "[Factories] Default settlement owner to DC corporation, fix :independent trait

- base_settlement factory default owner changed from player to development_corporation
- DC corporations are the primary settlement owners in the early game (Act 1)
- :independent trait restored to colony: nil only — independent means no colony
  membership, not no owner. Settlements always have an owner.
- Added :development_corporation factory trait and alias to organizations factory
- Fixed contract_service_spec to use default DC-owned settlements
- valid_settlement_pair? NPC ownership check is correct and unchanged
- Fixes contract_service_spec:18"
```

**EXPECTED RESULT:**
- `create(:base_settlement)` defaults to DC corporation owner
- `create(:base_settlement, :independent)` creates DC-owned settlement with no colony
- `contract_service_spec` passes fully
- No regressions in cluster (specs needing player owner already pass owner explicitly)

**CRITICAL CONSTRAINTS:**
- All RSpec runs via `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec ...'`
- Do NOT change `valid_settlement_pair?` — the NPC ownership check is correct
- Do NOT add `owner: nil` anywhere in the independent traits
- If regressions appear, fix them by adding explicit `owner: create(:player)` 
  to those specific tests — do not revert the factory default
- Fix-test loop until green
- Git commit from host only, specific files only

**MANDATORY REFERENCES:**
- GUARDRAILS.md: Settlement ownership rules, DC corporation architecture
- CONTRIBUTOR_TASK_PLAYBOOK.md: Git commit format, test logging
- ENVIRONMENT_BOUNDARIES.md: docker exec form only, no docker-compose exec
- docs/architecture/DUAL_ECONOMY_INTENT.md: DC corporation economic model

**REMINDER:** Executor role only. Three files, one commit. Do not change
service logic. The factory default change is intentional and architecturally
correct — do not second-guess it.

==============================================================================
