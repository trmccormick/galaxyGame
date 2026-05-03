# LEGACY: Tracy's 1995 Turbo Pascal BFS → Dynamic Wormhole Pathfinding Service

## Background

Galaxy Game's wormhole network is **dynamic**: artificial and natural wormholes can be created or removed at runtime, and rare "easter egg" connections may appear. Pathfinding must always reflect the current, live state of the galaxy's wormhole network.

Tracy McCormick’s 1995 Turbo Pascal `Paths.pas` implements Breadth-First Search (BFS) for shortest pathfinding in a graph. This task adapts that logic for a dynamic, system-level wormhole network in Rails, as outlined in Perplexity's mapping and the current game architecture.


## Objective

## Phase 2: Integration & Validation

- **ActiveRecord Filter:** Implement neighbors lookup to respect both stability and mass_limit from the live DB/JSON. Only traverse edges (wormholes/portals) that are currently stable and within the ship's mass limit.
- **RSpec Coverage:** Create `spec/services/navigation/wormhole_navigator_spec.rb` to test dynamic path recalculation, including stability and mass-limited edges.
- **Result Wrapper:** Ensure the service returns a `RouteProposal` object containing EM costs and jump counts for the path.
- **Logging:** Implement a Trace log that mirrors the 1995 Print_Output for developer debugging, showing the pathfinding steps and decisions.

---

## Phase 1: Tracy McCormick (1995) Translation
- Create `app/services/wormhole_navigator.rb`.
- Implement `find_shortest_path(from_system_id, to_system_id, ship)` using BFS, explicitly mirroring Tracy's predecessor (`pred`) array logic for path reconstruction (see `Get_Path_Info` in `PATHS.PAS`).
  - Use a Ruby array as the queue.
  - Use hashes for `visited`, `distance`, and `pred` (predecessor) tracking.
  - For each neighbor, check the wormhole's mass limit: **IF (ship.mass > wormhole.mass_limit) THEN skip_edge.**
  - Traverse **current** `WormholeConnection` edges (ActiveRecord or in-memory).
  - Reconstruct the path using the `pred` hash, as in the original Pascal.
  - **Do not cache paths**; always use the current network.
- `reconstruct_path` should return an array of system IDs or names, or `nil` if no path exists.

---

## Phase 2: Integration & Delegation
- Add delegation from `RouteProposal` to `WormholeNavigator`.
- Ensure `RouteProposal.find_shortest_wormhole_path(alpha_centauri_id, proxima_centauri_id, ship)` returns the correct path as an array of system names or IDs, using the live network and mass constraints.

---

## Phase 3: Spec Coverage
- Create `spec/services/wormhole_navigator_spec.rb`.
- Test:
  - Simple direct connections.
  - Multi-hop paths.
  - Disconnected graphs (no path).
  - Path reconstruction accuracy (pred array logic).
  - **Dynamic changes:** Add/remove wormholes and verify pathfinding updates.
  - **Mass-limited edges:** Ensure ships over mass limit cannot traverse restricted wormholes.

---

## Phase 4: Documentation & UI Output
- Document the new service and its usage.
- (Optional) Add a UI helper to display the reconstructed path in a user-friendly format.

---

## Verification

- All specs in `wormhole_navigator_spec.rb` pass, including tests for dynamic network changes and mass-limited edges.
- Manual test: `RouteProposal.find_shortest_wormhole_path(alpha_centauri_id, proxima_centauri_id, ship)` returns the expected route, reflecting the current wormhole network and mass constraints.
- Code is idiomatic, documented, and matches the BFS logic from `Paths.pas` (Tracy 1995).
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
1. Implement `WormholeNavigator` service with BFS logic (Tracy 1995, pred array for path reconstruction, mass-limited edges).
2. Integrate with `RouteProposal` for pathfinding delegation.
3. Write and pass comprehensive specs, including dynamic network changes and mass-limited edges.
4. Document the service and (optionally) add UI output.

Follow all phases in the task document.

Priority: BACKLOG – High impact, not urgent  
Time estimate: 3-5 hours
