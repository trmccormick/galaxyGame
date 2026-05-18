# 2026-04-03-HIGH-ARCHITECTURE-POPULATION MORALE WELLBEING SYSTEM

**Agent:** GPT-4.1 (0.25x)
**Priority:** HIGH
**Type:** ARCHITECTURE
**Status:** BACKLOG

## Context
Migrated from backlog_april_2026 archive.

## Summary
# Task: Population Morale & Wellbeing System
## Priority: Medium (gameplay feature — not spec stabilization)
## Branch: TBD — new feature branch recommended

---

---

## Original Content

# Task: Population Morale & Wellbeing System
## Priority: Medium (gameplay feature — not spec stabilization)
## Branch: TBD — new feature branch recommended

---

## Overview

Extend `PopulationManagement` concern to include morale/wellbeing tracking and
population retention mechanics. Currently the concern handles headcount and
basic resource requirements (food, water, energy) but has no psychological
wellbeing model.

---

## Background & Design Decisions (March 15, 2026)

### Why Morale Matters
Based on Antarctic research station data (EDEN ISS, South Korean station
studies), isolation without access to green plant life, sensory variety, and
routine causes measurable psychological decline. On a colonial settlement:
- Unhappy population doesn't stay — they request transfer or leave
- Population loss degrades settlement capacity and DC revenue
- Early settlements are most vulnerable — small crews, high isolation

### Wellbeing Contributors
- **Greenhouse access** — biophilia effect, green life, warmth, humidity,
  fresh food. `inflatable_greenhouse_data.json` v1.3 models this via
  `wellbeing_output.biophilia_rating` and `morale_contribution_per_visit`
- **Food variety** — fresh produce vs stored rations only
- **Habitat quality** — crowding, privacy, thermal comfort
- **Workload** — overworked population degrades faster
- **Isolation duration** — morale decays over time without social variety
- **Communication** — contact with Earth/other settlements

### Retention Mechanic
If morale drops below a threshold, population starts leaving:
- First: requests for transfer (AI Manager handles logistics)
- Then: productivity decline before leaving

This creates a real cost for neglecting wellbeing — not just a stat.

---

## Implementation Plan

### Phase 1 — PopulationManagement concern additions

Add:
```ruby
RETENTION_THRESHOLD = 40  # Morale below this triggers attrition
MORALE_MAX = 100

def morale_score
def wellbeing_requirements
  {
    food_variety_score: current_population > 0 ? 3 : 0,  # Min 3 food types
    habitat_crowding_ratio: current_population.to_f / population_capacity
end

def at_risk_population

private

  # Scales with how far below threshold morale is
  deficit = RETENTION_THRESHOLD - morale_score
  [deficit / 100.0, 0.5].min  # Max 50% at-risk at any time
end
```

### Phase 2 — Morale calculation service
New file: `app/services/ai_manager/morale_calculator.rb`

Aggregates wellbeing contributions from:
- Active greenhouse units (`wellbeing_output.morale_contribution_per_visit`)
- Food variety (fresh vs stored ration ratio)
- Habitat capacity utilization
- Days since last resupply/contact
- Workload intensity

### Phase 3 — AI Manager priority integration
Add to `AIManager::PriorityHeuristic`:
```ruby
def morale_critical?
  settlement.morale_score < PopulationManagement::RETENTION_THRESHOLD
end
```

Add `wellbeing_intervention` to priority list:
- Triggered when `morale_critical?` returns true
- Actions: schedule greenhouse visits, check food variety, assess crowding
- Higher priority than expansion, lower than life support

### Phase 4 — Population attrition simulation
When morale stays below threshold for sustained period:
- AI Manager schedules transfer requests
- Population count decrements over time
- DC revenue model reflects population loss

---

## Data Schema

### operational_data morale block (on BaseSettlement)
```json
{
  "morale": {
    "score": 75,
    "last_calculated": "2026-03-15T00:00:00Z",
      "isolation_days": -8,
      "communication": 5
    },
    "at_risk_count": 0,
    "trend": "stable"
  }
}
```

---

## Related Files
- `app/models/concerns/population_management.rb` — extend this
- `data/json-data/operational_data/units/life_support/inflatable_greenhouse_data.json`
  v1.3 — `wellbeing_output` block is the data source for greenhouse contribution
- `docs/architecture/ai_manager/AI_PRIORITY_SYSTEM.md` — add morale_critical?
  priority tier when this is implemented
- `docs/architecture/GREENHOUSE_AND_AGRICULTURAL_SYSTEMS.md` — planned doc
  that covers the full greenhouse/wellbeing model

---

## Dependencies
- `inflatable_greenhouse_data.json` v1.3 must be deployed first
- `AI_PRIORITY_SYSTEM.md` rewrite should note this as a planned priority tier
- Does NOT affect current spec stabilization work

## Do NOT implement until
- Spec stabilization target reached (~150 failures)
- Greenhouse unit operational in game
- Basic settlement lifecycle working end-to-end

