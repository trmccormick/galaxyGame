# TASK: Mission Planner — No-Magic Sourcing Logic & Orphaned System Support
**Status**: BACKLOG
**Priority**: HIGH
**Type**: feature
**Created**: 2026-03-26
**Last Updated**: 2026-03-26

---

## Agent Assignment

**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Multi-file feature requiring architectural reasoning across service, controller, view, and documentation layers. Inventory system integration and physics formula implementation require judgment.
**Supervision Level**: 🟢 Autonomous OK — but must stop at Synthesis Report before applying anything

---

## Context
The Mission Planner (`/admin/ai_manager/planner`) is a diagnostic tool that evaluates whether a mission is physically possible given current settlement state. It must never assume resources exist that aren't in inventory. This task implements the "No-Magic Protocol" — a 3-tier sourcing hierarchy that checks local ISRU, intra-system trade, and network import in order, with hard blocks when tiers fail. Orphaned systems (no wormhole connection) permanently lose access to Tier 3. All physics values come from `GameConstants` and operational_data JSON — no hardcoded magic numbers.

**Relevant Architecture Docs** — read before starting:
- `docs/architecture/systems/asteroid_conversion_physics.md` — conversion physics and orphaned system constraints
- `docs/architecture/systems/survey_and_handshake_protocol.md` — survey result handshake format
- `docs/developer/WORMHOLE_SCOUTING_INTEGRATION.md` — scouting service integration patterns
- `config/initializers/game_constants.rb` — canonical source for all physics and life support constants

> Do not create documentation during implementation steps.
> Create `docs/architecture/ai_manager_planner.md` only in the documentation step at the end.

---

## Problem Statement
The Mission Planner currently has no sourcing hierarchy, no orphaned system awareness, no tug dependency check, and no life support runway gate. It cannot determine whether a mission is physically possible. This task implements all four systems.

**Current behavior**: Planner displays missions without checking resource availability, connectivity, or life support runway.
**Expected behavior**: Planner runs the full No-Magic sourcing check before approving any mission, gates on life support runway, blocks on missing tug, and disables Tier 3 for orphaned systems.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/services/ai_manager/mission_planner_service.rb` | Core planning logic | locate main planning method |
| `app/controllers/admin/ai_manager_controller.rb` | Planner controller action | `#planner` line 84 |
| `app/views/admin/ai_manager/planner.html.erb` | Planner UI | orphaned alert + import toggle |

### New Files — you will create these
| File | Purpose |
|---|---|
| `app/views/admin/ai_manager/_orphaned_connection_alert.html.erb` | Orphaned system warning banner |
| `docs/architecture/ai_manager_planner.md` | No-Magic protocol documentation |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `config/initializers/game_constants.rb` | `HUMAN_LIFE_SUPPORT` oxygen constants, `AI_PRIORITIES` |
| `app/models/solar_system.rb` | `connectivity_status` enum — must exist before this task runs |
| `app/models/craft/base_craft.rb` | Craft operational_data patterns for thrust calculation |
| `app/models/units/base_unit.rb` | Unit operational_data patterns |
| `app/models/settlement/base_settlement.rb` | Inventory query patterns |

---

## Implementation Steps

> Read all reference files before touching any implementation file.
> Produce Synthesis Report after research, before writing any code.

### Step 1 — Research phase (read only, no changes)

Run these diagnostics to understand current state:
```bash
docker exec -it web bash -c 'grep -n "def planner" app/controllers/admin/ai_manager_controller.rb'
docker exec -it web bash -c 'sed -n "80,120p" app/controllers/admin/ai_manager_controller.rb'
docker exec -it web bash -c 'wc -l app/services/ai_manager/mission_planner_service.rb'
docker exec -it web bash -c 'grep -n "def " app/services/ai_manager/mission_planner_service.rb'
docker exec -it web bash -c 'grep -n "inventory\|connectivity\|orphan\|tier" app/services/ai_manager/mission_planner_service.rb | head -20'
docker exec -it web bash -c 'grep -n "def inventory\|has_many.*inventor" app/models/settlement/base_settlement.rb | head -10'
docker exec -it web bash -c 'grep -n "operational_data.*thrust\|nominal_thrust\|category.*propuls" app/models/craft/base_craft.rb | head -10'
```

### Step 2 — Produce Synthesis Report and STOP

After research, produce the report (format below) and wait for approval before writing any code.

### Step 3 — Controller update
In `Admin::AiManagerController#planner` (line 84), add connectivity detection:
```ruby
def planner
  @settlement = current_settlement # or however settlement is currently resolved
  @solar_system = @settlement.solar_system
  @is_orphaned = @solar_system.connectivity_status == 'orphaned'
  @planner_result = AIManager::MissionPlannerService.new(@settlement).evaluate
end
```

Match the existing pattern in the controller — do not invent a new settlement resolution pattern.

### Step 4 — Service: 3-Tier Sourcing Hierarchy
In `MissionPlannerService`, implement sourcing check in this exact order. If a tier returns results, do not check lower tiers. If all fail, return `HARD_BLOCKED`.
```ruby
def check_resource_availability(resource_id, quantity_needed)
  # Tier 1 — Local ISRU
  local = check_local_isru(resource_id, quantity_needed)
  return { tier: 1, source: :local_isru, result: local } if local[:available]

  # Tier 2 — Intra-System Trade (requires Tug)
  if tug_available?
    intra = check_intra_system_trade(resource_id, quantity_needed)
    return { tier: 2, source: :intra_system, result: intra } if intra[:available]
  end

  # Tier 3 — Network Import (blocked if orphaned)
  unless @settlement.solar_system.connectivity_orphaned?
    network = check_network_import(resource_id, quantity_needed)
    return { tier: 3, source: :network_import, result: network } if network[:available]
  end

  { tier: nil, source: :none, result: { available: false, status: :HARD_BLOCKED } }
end
```

### Step 5 — Service: Tug Detection
Tugs are `Craft::BaseCraft` instances with propulsion units installed. Thrust is read from operational_data:
```ruby
def tug_available?
  # Query crafts in this solar system
  system_crafts = @settlement.solar_system.crafts # verify association name in research phase
  system_crafts.any? do |craft|
    total_thrust(craft) > 0
  end
end

def total_thrust(craft)
  craft.base_units
    .where(unit_type: 'methane_engine') # verify propulsion unit_types in research phase
    .sum do |unit|
      unit.operational_data&.dig('performance', 'nominal_thrust_kn').to_f
    end
end
```

> ⚠️ During research phase, verify the exact `unit_type` string for propulsion units and the association name for crafts on solar_system. Adjust these methods accordingly.

### Step 6 — Service: Life Support Runway Gate
Before approving any construction mission, calculate runway using `GameConstants`:
```ruby
def life_support_runway_hours(mission_duration_hours)
  oxygen_per_person_day = GameConstants::HUMAN_LIFE_SUPPORT['oxygen_per_person_day'] # 0.84 kg
  oxygen_per_person_hour = oxygen_per_person_day / 24.0

  current_oxygen = @settlement.inventory.count('oxygen') # verify inventory query in research phase
  population = @settlement.population
  consumption_per_hour = population * oxygen_per_person_hour

  return Float::INFINITY if consumption_per_hour.zero?

  hours_remaining = current_oxygen / consumption_per_hour
  ratio = hours_remaining / mission_duration_hours

  {
    hours_remaining: hours_remaining,
    ratio: ratio,
    status: ratio < 1.2 ? :CRITICAL_RISK : :SAFE
  }
end
```

If `status == :CRITICAL_RISK`, the planner must flag the mission and prioritize an ISRU Survival mission instead. Use `AI_PRIORITIES[:critical][:life_support]` = 1000 as the priority value.

### Step 7 — Service: Towing Phase Formula
When a tug is available and asteroid conversion is planned, calculate towing time in SI units, return hours for UI:
```ruby
def towing_time_hours(distance_m, thrust_n, total_mass_kg)
  # Formula: t = sqrt(2 * d / (F / m))
  # All inputs in SI: meters, newtons, kilograms
  # Returns seconds, converted to hours for timeline
  acceleration = thrust_n / total_mass_kg.to_f
  time_seconds = Math.sqrt(2.0 * distance_m / acceleration)
  time_seconds / 3600.0
end
```

### Step 8 — Service: Cannibalization Suggestions (Read-Only)
If a project is `HARD_BLOCKED`, scan local settlement inventory for installed units that contain the missing component tags:
```ruby
def cannibalization_suggestions(missing_resource_id)
  candidates = @settlement.base_units.select do |unit|
    unit.operational_data&.dig('resource_management', 'output_resources')
      &.any? { |r| r['id'] == missing_resource_id }
  end

  candidates.map do |unit|
    {
      suggestion: "Deconstruct #{unit.name} to recover #{missing_resource_id}",
      unit_id: unit.id,
      unit_type: unit.unit_type,
      action: :manual_player_decision
    }
  end
end
```

> This is read-only. Do not trigger any state change on the unit. Display suggestions only.

### Step 9 — View updates
In `planner.html.erb`:
- Render `_orphaned_connection_alert` partial if `@is_orphaned`
- Gray out or disable Earth Import toggles if `@is_orphaned`
- Display CRITICAL_RISK banner if life support runway ratio < 1.2
- Display cannibalization suggestions if project is HARD_BLOCKED

Match existing view patterns — do not introduce new CSS frameworks or JS dependencies.

### Step 10 — Create orphaned alert partial
Create `app/views/admin/ai_manager/_orphaned_connection_alert.html.erb`:
```erb
<div class="alert alert-warning">
  <strong>Orphaned System:</strong>
  This solar system has no active wormhole connection.
  Network imports (Tier 3) are unavailable.
  All missions must be resourced from local ISRU or intra-system trade only.
</div>
```

Match existing alert styling in the admin views.

### Step 11 — Create documentation
Create `docs/architecture/ai_manager_planner.md` covering:
- The No-Magic Protocol (3-tier sourcing hierarchy)
- Tug dependency and towing formula with units
- Life support runway gate (formula, threshold, constants source)
- Orphaned system rules
- Cannibalization suggestion logic (read-only, player decision required)

This doc must be created before the PR is considered complete.

---

## Synthesis Report Format
```
RESEARCH FINDINGS
Controller#planner current state: [summary]
MissionPlannerService current methods: [list]
Inventory query pattern: [exact method]
Craft association on SolarSystem: [name or 'not found']
Propulsion unit_type strings found: [list]
Settlement population attribute: [name]

PROPOSED IMPLEMENTATION PLAN
[bullet list of each change with file and method]

RISKS
[shared code, factory impacts, view pattern deviations]

OPEN QUESTIONS
[anything not resolved by research that needs human input]

READY TO APPLY? — waiting for approval
```

Do not write any code until approval is received.

---

## Testing Sequence

1. **Service spec isolation**:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/mission_planner_service_spec.rb'
```

2. **AI manager specs**:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/'
```

3. **Controller specs**:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/controllers/admin/'
```

4. **Full suite**:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

---

## Acceptance Criteria
- [ ] 3-tier sourcing hierarchy implemented in correct order
- [ ] Tier 3 returns 0 results when `connectivity_status == 'orphaned'`
- [ ] Tug detection reads `nominal_thrust_kn` from operational_data
- [ ] Life support runway uses `GameConstants::HUMAN_LIFE_SUPPORT['oxygen_per_person_day']`
- [ ] CRITICAL_RISK flagged when runway ratio < 1.2
- [ ] Towing formula uses SI units internally, returns hours for UI
- [ ] Cannibalization suggestions are read-only — no state changes
- [ ] Orphaned alert banner renders correctly
- [ ] Earth Import UI disabled when orphaned
- [ ] `docs/architecture/ai_manager_planner.md` created and complete
- [ ] All spec runs pass with 0 failures
- [ ] No regressions in related specs

---

## Stop Conditions — escalate to user immediately if:
- Inventory query pattern differs from `settlement.inventory.count('oxygen')`
- `SolarSystem` has no craft association — tug detection needs different query
- `MissionPlannerService` already has conflicting sourcing logic
- Life support data is not in inventory system — stored elsewhere
- View patterns require new dependencies
- Any architectural decision beyond what reference docs cover

---

## Commit Instructions
```bash
git add app/services/ai_manager/mission_planner_service.rb
git add app/controllers/admin/ai_manager_controller.rb
git add app/views/admin/ai_manager/planner.html.erb
git add app/views/admin/ai_manager/_orphaned_connection_alert.html.erb
git add docs/architecture/ai_manager_planner.md
git commit -m "feature: mission planner — no-magic 3-tier sourcing, orphaned system support, life support gate"
git push
```

---

## Documentation
- [ ] Create `docs/architecture/ai_manager_planner.md` — No-Magic Protocol, all rules codified

---

## Dependencies
**Blocked by**: `2026-03-26-HIGH-DATA-FOUNDATION-MISSION-PLANNER.md` — must be complete and merged first
**Blocks**: AI Manager Asteroid Conversion strategy tasks
**Related tasks**: `2026-03-26-MEDIUM-FEATURE-SEISMIC-SURVEY-SCOUT-SHIPS.md`

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned