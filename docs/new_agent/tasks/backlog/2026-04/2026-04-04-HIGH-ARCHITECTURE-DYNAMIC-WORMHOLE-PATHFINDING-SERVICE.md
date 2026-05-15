# 2026-04-04-HIGH-ARCHITECTURE-DYNAMIC WORMHOLE PATHFINDING SERVICE

**Agent:** GPT-4.1 (0.25x)
**Priority:** HIGH
**Type:** ARCHITECTURE
**Status:** BACKLOG

## Context
Migrated from backlog_april_2026 archive.

## Summary
# LEGACY: Tracy's 1995 Turbo Pascal BFS → Dynamic Wormhole Pathfinding Service

## Background

Galaxy Game's wormhole network is **dynamic**: artificial and natural wormholes can be created or removed...

---

## Original Content

# LEGACY: Tracy's 1995 Turbo Pascal BFS → Dynamic Wormhole Pathfinding Service

## Background

Galaxy Game's wormhole network is **dynamic**: artificial and natural wormholes can be created or removed at runtime, and rare "easter egg" connections may appear. Pathfinding must always reflect the current, live state of the galaxy's wormhole network.

Tracy McCormick’s 1995 Turbo Pascal `Paths.pas` implements Breadth-First Search (BFS) for shortest pathfinding in a graph. This task adapts that logic for a dynamic, system-level wormhole network in Rails, as outlined in Perplexity's mapping and the current game architecture.

---

## Objective

Implement a BFS-based shortest path finder for star systems, using the **current, live set of wormhole connections** (not a static map). The new service will enable efficient, up-to-date route proposals between any two systems, mirroring the original Pascal logic but in Ruby/Rails.

---

## Requirements

- **Nodes:** Star systems (system IDs)
- **Edges:** Wormhole connections (artificial, natural, or special)
- **Graph:** Must be queried live from the database or in-memory structures each time a path is requested
- **Dynamic:** Must handle addition/removal of systems and wormholes at runtime
- **Integration:** Must work with WormholeScoutingService and AI Manager, supporting on-demand system discovery and network changes

---

## Phases

### Phase 1: Service Implementation
- Create `app/services/wormhole_navigator.rb`.
- Implement `find_shortest_path(from_system_id, to_system_id)` using BFS.
  - Use a Ruby array as the queue.
  - Use hashes for `visited`, `distance`, and `pred` (predecessor) tracking.
  - Traverse **current** `WormholeConnection` edges (ActiveRecord or in-memory).
  - Reconstruct the path using the `pred` hash.
  - **Do not cache paths**; always use the current network.

#### Sample Code (from Perplexity, adapted):
```ruby
class WormholeNavigator
  def find_shortest_path(from_system_id, to_system_id)
    queue = []
    visited = {}
    distance = {}
    pred = {}

    queue << from_system_id
    visited[from_system_id] = true
    distance[from_system_id] = 0

    while queue.any?
      current = queue.shift
      WormholeConnection.where(from_system_id: current).each do |wc|
        neighbor = wc.to_system_id
        next if visited[neighbor]

        visited[neighbor] = true
        pred[neighbor] = current
        distance[neighbor] = distance[current] + 1
        queue << neighbor
      end
    end
    reconstruct_path(pred, to_system_id)
  end
end
```
- `reconstruct_path` should return an array of system IDs or names, or `nil` if no path exists.

### Phase 2: Integration & Delegation
- Add delegation from `RouteProposal` to `WormholeNavigator`.
- Ensure `RouteProposal.find_shortest_wormhole_path(alpha_centauri_id, proxima_centauri_id)` returns the correct path as an array of system names or IDs.

### Phase 3: Spec Coverage
- Create `spec/services/wormhole_navigator_spec.rb`.
- Test:
  - Simple direct connections.
  - Multi-hop paths.
  - Disconnected graphs (no path).
  - Path reconstruction accuracy.
  - **Dynamic changes:** Add/remove wormholes and verify pathfinding updates.

### Phase 4: Documentation & UI Output
- Document the new service and its usage.
- (Optional) Add a UI helper to display the reconstructed path in a user-friendly format.

---

## Verification

- All specs in `wormhole_navigator_spec.rb` pass, including tests for dynamic network changes.
- Manual test: `RouteProposal.find_shortest_wormhole_path(alpha_centauri_id, proxima_centauri_id)` returns the expected route, reflecting the current wormhole network.
- Code is idiomatic, documented, and matches the BFS logic from `Paths.pas`.
- No caching of paths; always reflects live network.

---

## References

- Legacy code: `docs/legacy/PATHS.PAS`
- Planner review: See `WORKFLOW_README.md` for agent boundaries and task protocol.
- Perplexity mapping: See chat log for direct Pascal→Ruby mapping.
- Wormhole network architecture:  
  - `docs/developer/WORMHOLE_SCOUTING_INTEGRATION.md`
  - `docs/wormhole_expansion/00_executive_summary.md`
  - `docs/architecture/wormhole_system.md`

---

## Agent Assignment

**Ollama (M5 MacBook)** — Fast, reliable for spec-driven Rails implementation.  
If unavailable, fallback to Gemini 2.5 Flash.

---

## Handoff Command

**[BACKLOG] ISSUE: Implement Dynamic BFS-based WormholeNavigator for system-to-system pathfinding**

I've created `docs/agent/tasks/backlog/legacy_tracy_bfs_pathfinding.md` with complete instructions.

**IMPORTANT:** Start by reviewing `docs/agent/WORKFLOW_README.md` and follow all rules regarding git commits, documentation, RSpec testing.

The issue:
- Galaxy navigation needs efficient, dynamic shortest-path routing between star systems.
- Legacy BFS logic from Turbo Pascal is proven and should be adapted to Rails.
- The wormhole network is mutable and must be queried live for every pathfinding request.

Your tasks:
1. Implement `WormholeNavigator` service with BFS logic.
2. Integrate with `RouteProposal` for pathfinding delegation.
3. Write and pass comprehensive specs, including dynamic network changes.
4. Document the service and (optionally) add UI output.

Follow all phases in the task document.

Priority: BACKLOG – High impact, not urgent  
Time estimate: 3-5 hours

Start with Phase 1 – Service Implementation.

**Agent Assignment:** Ollama (M5 MacBook) (best for spec-driven Rails implementation)
