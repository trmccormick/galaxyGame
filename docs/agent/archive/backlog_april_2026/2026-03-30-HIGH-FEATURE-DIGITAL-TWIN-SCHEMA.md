# TASK: Implement Digital Twin Sandbox — AI Manager Planning Engine
**Status**: BACKLOG
**Priority**: HIGH
**Type**: feature
**Created**: 2026-03-30
**Last Updated**: 2026-03-30

---

## Agent Assignment
**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Requires architectural reasoning across TerraSim, 
market system, economic models, and AI Manager integration
**Supervision Level**: 🔴 Watched carefully

---

## Context
The Digital Twin Sandbox is the SimEarth-inspired planning layer of Galaxy 
Game. It provides a consequence-free projection environment where TerraSim 
physics simulations can be run against a cloned planetary state without 
affecting the live world.

It serves two primary users working together toward the best path forward 
for each world:

**AI Manager (primary)** — uses projections to make long-range planning 
decisions:
- Which terraforming interventions to fund and when
- Whether to invest in worldhouses now vs aggressive terraforming later
- When to place market buy orders for required resources based on price trends
- How to phase investment as the local GCC tax base grows over time

**Admins (secondary)** — use projections to validate game balance and tune 
terraforming parameters before applying to live worlds.

**The core planning loop:**
1. AI Manager identifies a terraforming or development opportunity
2. Creates Digital Twin — clones current planetary sphere state
3. Runs multiple TerraSim scenarios with different resource allocations
4. Checks market cost history — are required resources cheap or expensive now?
5. Models economic phases — can current GCC tax base support this intervention?
6. Compares projected outcomes across scenarios
7. Selects optimal strategy and timing
8. Posts real contracts or places market buy orders accordingly
9. Digital Twin expires and is cleaned up

**Market intelligence integration:**
The AI Manager cross-references Digital Twin projections with market cost 
history. If projected gas requirements are large and current prices are 
trending down, it may place early buy orders to stockpile. If prices are 
high due to low supply, it may wait or invest in local ISRU capacity instead. 
This creates emergent market behavior driven by AI planning cycles.

**Multi-phase economic planning:**
Early settlements have low GCC tax bases. The AI Manager uses Digital Twin 
projections to determine when aggressive terraforming becomes financially 
viable — investing in worldhouses and population growth first to build the 
tax base, then transitioning to large-scale terraforming when the economics 
support it. Import costs (e.g. gases for Mars) change over time as local 
manufacturing capacity grows, and the AI Manager models these cost curves 
in its projections.

**Explicit Blocker**: Do not implement until the test suite is under 
10 failures.

**Relevant Architecture Docs** — read before starting:
- `docs/architecture/simulation/SIMULATION_SANDBOX.md` — architectural anchor
- `docs/architecture/simulation/DIGITAL_TWIN_SANDBOX.md` — full feature spec
- `docs/agent/tasks/backlog/phase_4_digital_twin_schema.md` — original schema 
  (superseded — for reference only)
- `PHASE_4_DATABASE_SCHEMA.md` — schema requirements
- `PHASE_4_PREPARATION_PLAN.md` — deliverables and readiness checklist
- `docs/ai_manager/` — AI Manager architecture and strategy docs
- `docs/market/` — market system and cost history docs

---

## Problem Statement
The Digital Twin Sandbox has no backend implementation — only stubbed admin 
views exist. No models, migrations, or service implementation are in place.

Without this feature the AI Manager cannot plan ahead — it can only react 
to current world state. With it, the AI Manager becomes a genuine sovereign 
NPC government capable of long-range investment planning.

**Current behavior**: Stubbed admin views only, no backend  
**Expected behavior**: Full model layer, TerraSim integration, market-aware 
projection engine enabling AI Manager long-range planning

---

## Files Involved

### Primary Files — you will create these
| File | Purpose |
|------|---------|
| `app/models/digital_twin.rb` | DigitalTwin model + associations |
| `app/models/simulation_run.rb` | SimulationRun model + associations |
| `app/models/simulation_result.rb` | SimulationResult model + associations |
| `db/migrate/[timestamp]_create_digital_twin_tables.rb` | Migration for all three tables |
| `app/services/digital_twin_service.rb` | Core service — clone, run, compare |

### Reference Files — read but do not edit
| File | Why You Need It |
|------|----------------|
| `docs/architecture/simulation/SIMULATION_SANDBOX.md` | Architectural anchor |
| `docs/architecture/simulation/DIGITAL_TWIN_SANDBOX.md` | Full feature spec |
| `PHASE_4_DATABASE_SCHEMA.md` | Schema requirements |
| `PHASE_4_PREPARATION_PLAN.md` | Deliverables and readiness |
| `app/services/ai_manager/` | AI Manager service patterns |
| Market cost history model | Price trend data for resource planning |

### Existing Stubs — locate before starting
```bash
find app/views/admin -type f | grep -v spec
find app/controllers -name "*digital_twin*" -o -name "*simulation*"
find app/services -name "*digital_twin*" -o -name "*simulation*"
```

### Migration
- [ ] Migration needed: create `digital_twins`, `simulation_runs`, 
      and `simulation_results` tables
```bash
docker exec -it web bash -c 'unset DATABASE_URL && bundle exec rails generate migration CreateDigitalTwinTables'
```

---

## Schema Reference

### digital_twins
```ruby
create_table :digital_twins do |t|
  t.references :celestial_body, null: false
  t.references :corporation, null: false        # access control
  t.string :simulation_type, null: false        # 'terraforming', 'industrial',
                                                # 'economic', 'worldhouse'
  t.jsonb :cloned_data, null: false             # atmosphere, hydrosphere,
                                                # geosphere, biosphere clone
  t.jsonb :market_snapshot, null: false         # market prices at time of clone
  t.jsonb :economic_snapshot, null: false       # GCC tax base, local capacity,
                                                # import costs at time of clone
  t.datetime :expires_at, null: false
  t.timestamps
end
```

### simulation_runs
```ruby
create_table :simulation_runs do |t|
  t.references :digital_twin, null: false
  t.string :pattern_name, null: false           # 'worldhouse-first',
                                                # 'aggressive-terraform',
                                                # 'isru-buildup'
  t.integer :duration_years, null: false
  t.jsonb :parameters, null: false              # budget, tech level,
                                                # resource allocation,
                                                # market timing strategy
  t.string :status, null: false, default: 'running'
  t.datetime :started_at, null: false
  t.datetime :completed_at
  t.jsonb :results
  t.timestamps
end
```

### simulation_results
```ruby
create_table :simulation_results do |t|
  t.references :simulation_run, null: false
  t.string :result_type, null: false            # 'physical', 'economic',
                                                # 'market_timing', 'timeline'
  t.jsonb :data, null: false                    # structured metrics:
                                                # habitability_score,
                                                # time_to_threshold,
                                                # resource_cost,
                                                # gcc_tax_revenue_projected,
                                                # import_cost_curve,
                                                # break_even_point,
                                                # market_buy_recommendation
  t.integer :year, null: false
  t.timestamps
end
```

---

## Implementation Steps

> Read ALL reference docs before touching anything.

### Step 1 — Locate existing stubs
```bash
find app/views/admin -type f | grep -v spec
find app/controllers -name "*digital_twin*" -o -name "*simulation*"
find app/services -name "*digital_twin*" -o -name "*simulation*"
```

### Step 2 — Create migration
Populate with schema above. Include indexes on `corporation_id`, 
`celestial_body_id`, `expires_at`, `status`.

### Step 3 — Run migration
```bash
docker exec -it web bash -c 'unset DATABASE_URL && bundle exec rails db:migrate'
```

### Step 4 — Create models
Implement all three models with:
- Correct associations
- Corporation scope for access control
- Validations matching schema
- Auto-cleanup scopes:
```ruby
scope :active, -> { where('expires_at > ?', Time.current) }
scope :expired, -> { where('expires_at <= ?', Time.current) }
```

### Step 5 — Implement DigitalTwinService
Core interface:
```ruby
# Clone current planetary + economic + market state
def self.clone_celestial_body(celestial_body, corporation:,
                               simulation_type:, expires_in: 24.hours)
  DigitalTwin.create!(
    celestial_body: celestial_body,
    corporation: corporation,
    simulation_type: simulation_type,
    cloned_data: {
      atmosphere: celestial_body.atmosphere&.as_json,
      hydrosphere: celestial_body.hydrosphere&.as_json,
      geosphere: celestial_body.geosphere&.as_json,
      biosphere: celestial_body.biosphere&.as_json
    },
    market_snapshot: build_market_snapshot(celestial_body),
    economic_snapshot: build_economic_snapshot(celestial_body),
    expires_at: Time.current + expires_in
  )
end

# Compare simulation runs and return ranked strategies
def self.compare_runs(digital_twin)
  digital_twin.simulation_runs.completed.map do |run|
    {
      pattern: run.pattern_name,
      habitability_score: run.results['habitability_score'],
      time_to_threshold: run.results['time_to_threshold'],
      resource_cost: run.results['resource_cost'],
      gcc_revenue_projected: run.results['gcc_tax_revenue_projected'],
      break_even_point: run.results['break_even_point'],
      market_buy_recommendation: run.results['market_buy_recommendation']
    }
  end.sort_by { |r| r[:habitability_score] }.reverse
end
```

### Step 6 — Wire stubbed views
Connect existing admin view stubs to new models and service.

### Step 7 — Write model specs
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/digital_twin_spec.rb spec/models/simulation_run_spec.rb spec/models/simulation_result_spec.rb'
```

---

## Acceptance Criteria
- [ ] All three models created with correct associations and validations
- [ ] Migration runs without errors
- [ ] Corporation access controls enforced at model level
- [ ] `cloned_data` captures all four sphere states
- [ ] `market_snapshot` captures current resource prices at clone time
- [ ] `economic_snapshot` captures GCC tax base and local capacity at clone time
- [ ] `DigitalTwinService.clone_celestial_body` works correctly
- [ ] `DigitalTwinService.compare_runs` returns ranked strategy comparison
- [ ] Active/expired scopes work correctly
- [ ] Stubbed admin views wired to new models
- [ ] Model specs pass: 0 failures
- [ ] No regressions in related specs
- [ ] Full suite run logged after completion
- [ ] Test suite must be under 10 failures before work begins

---

## Stop Conditions — escalate to user immediately if:
- Test suite is at or above 10 failures — halt immediately
- Corporation model association path is unclear
- Any sphere model (atmosphere, hydrosphere, geosphere, biosphere) 
  lacks serialization — stop and report
- Market cost history model not found or incompatible
- Economic snapshot data path from celestial body unclear
- TerraSim integration requires changes beyond this task scope — 
  flag and create separate backlog task
- Fix causes new failures in specs not in scope

---

## Dependencies
**Blocked by**: Test suite must be under 10 failures  
**Blocks**: AI Manager long-range planning feature  
**Related tasks**:
- `phase_4_digital_twin_schema.md` — superseded, move to completed 
  after implementation
- `2026-03-27-MEDIUM-FEATURE-FINANCIAL-TRANSACTION-MODEL.md`
- `2026-03-29-HIGH-REFACTOR-WORMHOLE-EXPANSION-SERVICE.md`

---

## Commit Instructions
Run git commands on host, not inside container:
```bash
git add app/models/digital_twin.rb \
        app/models/simulation_run.rb \
        app/models/simulation_result.rb \
        app/services/digital_twin_service.rb \
        db/migrate/[timestamp]_create_digital_twin_tables.rb \
        spec/models/digital_twin_spec.rb \
        spec/models/simulation_run_spec.rb \
        spec/models/simulation_result_spec.rb
git commit -m "feat: implement Digital Twin sandbox — AI Manager planning engine"
git push
```

---

## Documentation
- [ ] Update `docs/architecture/simulation/SIMULATION_SANDBOX.md` 
      with implementation status
- [ ] Move `phase_4_digital_twin_schema.md` to 
      `docs/agent/tasks/completed/` after implementation
- [ ] Create `docs/architecture/ai_manager/digital_twin_planning_loop.md` 
      capturing AI Manager → Digital Twin → TerraSim → market integration

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**:  
**Completion date**:  
**Final test result**: X examples, Y failures

### What was changed
- `[file]` — [description of change]

### Issues discovered
[Any problems found during implementation that weren't in the original task]

### Follow-up tasks needed
[New backlog items identified — do not create the files, just list them here]

### Lessons learned
[What worked, what didn't, what future tasks in this area should know]