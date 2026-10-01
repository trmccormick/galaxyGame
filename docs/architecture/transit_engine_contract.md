# Transit Engine & Contract Architecture

## 1. Core Principle
Dynamic orbital calculation is the universal canonical behavior for all known trade and transit routes in *Galaxy Game*. Hardcoded Sol-centric lookup tables (e.g., `EARTH_MARS`, `EARTH_LUNA`) are permanently retired. Transit duration must derive from a declared calculation model and current simulation state, never from a static route-name table.

## 2. The Procedural Fallback
When precise orbital data or ephemeris elements are missing for newly generated or unmapped bodies, the system must not use silent static constants. Instead, it falls back to a deterministic procedural estimation model that returns explicit metadata:
- `calculation_mode: :procedural_estimate`
- `confidence: :approximate`
- `data_quality: :missing_orbital_elements`

This ensures gameplay systems can evaluate whether approximate route plans are acceptable or require scouting.

## 3. Planner vs. Execution Authority Separation
To ensure save-game determinism and prevent historical arrival drift:
- **`TransitEngine` (Planner / Estimator):** Evaluates ephemeris snapshots, applies vessel propulsion profiles, and outputs an immutable `TransitPlan`.
- **`Mission` / Execution Record (Authority):** Persists the finalized snapshot (`departure_sim_time`, `arrival_time`, `flight_duration`) at scheduling time. Helpers like `has_arrived?` and `days_remaining` must operate strictly on the persisted schedule rather than recomputing live ephemeris.

## 4. Typed Route Architecture
To future-proof interstellar expansion without forcing engine rewrites, transit is modeled as a composition of typed route legs:
- `OrbitalTransferLeg` (intra-system orbital mechanics via Hohmann/dynamic estimation)
- `WormholeTransitLeg` / `InterstellarCruiseLeg` (inter-system network traversal)
