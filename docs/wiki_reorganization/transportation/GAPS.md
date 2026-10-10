# Transportation Documentation Gaps — Tracking File

**Status**: Active  
**Created**: 2026-09-15  
**Last Updated**: 2026-09-15  
**Purpose**: Track discrepancies between Transportation documentation, implementation, and backlog coverage

---

## Gap A: GCC Mining Issuance-Routing Alignment — UNRESOLVED

**Description**: GCC's canonical policy is LDC-controlled simulated-compute issuance with newly issued GCC intended for the existing LDC GCC account. Inspected mining source paths show inconsistent recipient routing and lack a demonstrated LDC authorization guard.

**Evidence**:
- `transportation/02-gcc-mining-satellite.md` verified evidence: "Current mining source paths show inconsistent recipient routing and lack a demonstrated LDC authorization guard."
- Economy doc `economy/02-currencies-and-accounts.md` Section 9: GCC policy states newly issued GCC is intended for the existing LDC GCC account.
- No source-level audit confirmed an LDC authorization guard exists in any mining path.

**Impact**: Documentation cannot claim that LDC-only GCC recipient routing is currently enforced at runtime. Any future implementation must add and verify an authorization guard before canonical adoption.

**Backlog Coverage**: None — no active or backlog task addresses the authorization guard implementation or verification.

---

## Gap B: Mining Cadence and Rate Semantics — UNRESOLVED

**Description**: Satellite-level `*_per_hour` mining-rate fields and configured cap/halving/difficulty/block-reward values exist in operational data but no verified active consumer is shown. Tick, scheduled-job, and mission mining triggers coexist; their timing and settlement semantics remain under alignment.

**Evidence**:
- `transportation/02-gcc-mining-satellite.md` verified evidence: "Satellite-level `*_per_hour` mining-rate fields and configured cap/halving/difficulty/block-reward values must not be represented as active runtime controls without verified source evidence."
- Economy doc `economy/02-currencies-and-accounts.md`: References 1,000 GCC/hour per satellite and 6-hour cycle intervals but no active consumer of these fields was identified.
- No service-level verification confirms any mining rate field is consumed at runtime.

**Impact**: Numeric mining rates, caps, halving schedules, and difficulty values cannot be documented as active runtime controls. Any future documentation must await verified source evidence before representing these as operational parameters.

**Backlog Coverage**: None — no active or backlog task addresses mining cadence unification or rate-field consumer verification.

---

## Gap C: Craft Lifecycle Coverage — UNRESOLVED

**Description**: Maintenance, repair, and lifecycle decommissioning are not established as implemented craft behavior by the current evidence. A craft undergoing construction, repair, upgrade, or refit is not in normal operations, but this constraint is not currently runtime-enforced.

**Evidence**:
- `transportation/01-craft-taxonomy.md` explicit exclusions: "Maintenance, repair, and lifecycle decommissioning are not established as implemented craft behavior by the current evidence."
- `transportation/02-gcc-mining-satellite.md` what cannot be claimed yet: "Maintenance, repair, and lifecycle decommissioning" is listed as unestablished.
- No source-level audit confirmed craft lifecycle enforcement in any service or model.

**Impact**: Craft lifecycle behavior (maintenance, repair, decommissioning) cannot be documented as implemented gameplay. Any future documentation must await source evidence before representing these as operational systems.

**Backlog Coverage**: None — no active or backlog task addresses craft lifecycle implementation or verification.

---

## Gap D: TransitEngine Topology Containment — Phase 1 Verified Gaps (UNRESOLVED)

**Description**: `Mission::TransitEngine.calculate_transfer_window` includes a Phase 1 topology containment proxy guard. Several gaps remain between that guard and a correct route-planning system. Items 1–5 are residual limits of the Phase 1 design; items 6–8 are observed pre-existing behavior that this work did not fix. Nothing here is a claim of physical correctness.

**Evidence** (paths under `galaxy_game/`):
- `app/services/mission/transit_engine.rb`: the guard accepts only `CelestialBodies::Planets::Planet` bodies with `parent_celestial_body_id.nil?`, a present `solar_system_id`, and a resolving `solar_system`; when both endpoints resolve they must share a `solar_system_id`. Otherwise it raises `Mission::UnsupportedTransferError` (one raise for a failing resolved endpoint, one for a different-system pair). Unresolvable identifiers keep the legacy fallback when every resolved endpoint passes.
- `app/services/mission/unsupported_transfer_error.rb`: `class Mission::UnsupportedTransferError < StandardError; end`.
- Legacy route-table helpers (`earth_to_venus_transit_days`, `luna_to_venus_transit_days`, etc.) remain unguarded and directly callable.
- `calculate_transfer_window` defaults `launch_date` to `Time.current.to_date`.
- `orbit_radius_km` reads `orbitals[:semi_major_axis]` (symbol key) while `orbital_data` returns string keys. Read-only check for EARTH-01 in the test DB: string key = 149597870700.0, symbol key = nil, `orbit_radius_km` = 0.0. `fallback_transit_days` returns 0 when both radii are zero. Not yet checked outside the test DB.
- `lib/tasks/lunar_precursor_mission_validation.rake`: the `luna_mission:phase_timing` Earth→Luna precursor uses an explicitly labeled static 7-game-day duration; Earth→Venus remains on the engine path.
- Spec run of `spec/services/mission/transit_engine_spec.rb` after this change: 51 examples, 45 passed, 6 failed (see item 7).

**Gaps Recorded**:
1. No governing-primary or reference-frame association for any resolved body.
2. No per-primary gravitational parameter (`mu`); fixed `MU_SUN` applies to every pair that passes the proxy.
3. Direct legacy helpers remain unguarded, including `luna_to_venus_transit_days`.
4. `calculate_transfer_window` keeps its `Time.current.to_date` default.
5. Same-system eligibility is a topology containment check only; it does not establish multi-star, non-Sol, generated-system, or physical transfer correctness.
6. (Observed) `orbit_radius_km` reads a symbol key from a string-keyed hash, yielding a 0.0 radius for the checked seeded body; eligible routes then return `transit_days = 0` via the nested fallback. Confirmed for EARTH-01 in the test DB only.
7. (Observed) Six pre-existing failing examples in `transit_engine_spec.rb` (Earth→Venus, Earth→Mars, `schedule_departure` structure, `has_arrived?`, two `days_remaining`) are caused by item 6.
8. (Observed) `luna_mission:phase_timing` prints "Landing Pads Complete" and "Tank Farm Ready" on different days in its body output than in its TIMELINE SUMMARY (pre-existing).

**Impact**: The Phase 1 proxy is temporary containment, not a route-planning system. Future work needs reference-frame metadata, central-body association, per-body `mu`, parent/SOI transitions, and multi-leg routing; this is human-filed follow-up work, not something the implementer creates or dispatches.

**Backlog Coverage**: None. No active or backlog task addresses these gaps.
