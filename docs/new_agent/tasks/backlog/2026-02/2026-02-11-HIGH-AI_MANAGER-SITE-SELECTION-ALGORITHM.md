---
status: backlog
priority: HIGH
type: feature
system_domain: AI_MANAGER
mvp_alignment: AI_MANAGER_LUNA_SETTLEMENT
local_worker_safe: true
---

# TASK: Implement the AI Manager Site Selection Algorithm
**Status**: BACKLOG
**Priority**: HIGH
**Type**: feature
**Created**: 2026-02-11
**Last Updated**: 2026-05-16

---

## Local Worker Triage Report
- **Template Conformance**: PASS
- **Docker Wrapper Check**: PASS
- **MVP Alignment**: VALID
- **MVP Impact Note**: Essential logic to programmatically identify resource concentrations and select space coordinate grids to drop initial i-beams, modular storage depots, and integrated power panels.
- **Action Line**: READY FOR CLOUD HANDOFF / SPRINT FORWARD

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x / GitHub Copilot
**Why This Agent**: Requires robust geospatial or structural coordinate indexing arrays mapped against standard ActiveRecord objects.
**Supervision Level**: Autonomous OK

> Local Ollama agents: you cannot execute terminal commands, Docker, RSpec, or git.
> You can read files provided to you and create/edit files via Continue.

---

## Context
The AI Manager module requires a programmatic method to evaluate coordinates on a lunar surface map grid. Instead of manual positioning, the backend must mathematically score coordinates based on regolith/ore concentrations, verifying that selected coordinates have adequate spatial clearance to lay down a standard i-beam framework support system for modular panels.

**Relevant Architecture Docs**:
- `docs/new_agent/rules/DECISIONS.md`
- `docs/new_agent/rules/GUARDRAILS.md`
- `docs/architecture/ai_manager/ai_manager.md`

---

## Problem Statement
Current behavior: The system lacks an explicit scoring matrix service to rank optimal coordinate nodes on an active map grid, causing automation jobs to default to static positions.

Expected behavior: A service class that consumes a map grid layer, evaluates resource concentration values, and exposes ranked candidate coordinates matching the footprint of an industrial base layout.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/services/ai_manager/site_selection_service.rb` | Core algorithm scoring and coordinate ranking | `def calculate_scores`, `def optimal_node` |
| `spec/services/ai_manager/site_selection_service_spec.rb` | Complete RSpec coverage for selection calculations | Validation logic and score ranking matrices |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/models/galaxy_system.rb` | Underlying astronomical context structures |
| `app/models/lunar_map.rb` | Grid representation data model |
| `spec/factories/lunar_map.rb` | Factory for generating map mock objects |

---

## Implementation Steps

### Step 1 — Build the SiteSelectionService Grid Evaluator
Create the core service object file. The scoring function must accept concentration vectors and verify grid boundary clearance rules for base structure setups.

```ruby
class SiteSelectionService
  def initialize(lunar_map)
    @lunar_map = lunar_map
  end

  # Returns a hash of coordinates sorted by highest resource density score
  def score_grid_nodes
    # Scoring algorithm logic mapping regolith density inputs
  end
end