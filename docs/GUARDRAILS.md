# 🛡️ AI Manager: "First and Done" Guardrails
**Context:** Internal Game Logic (AIManager Module)
**Mandate:** These rules govern the autonomous behavior of the AI Manager during expansion and settlement.

---

## 🏗️ 1. Code & Documentation Sync
- **The Mandate:** No logic change to `manager.rb` or `autonomous_construction_manager.rb` is complete until the corresponding Markdown documentation is updated.
- **Pattern Integrity:** If a new mission pattern is added (e.g., via `ai:manager:teach:pattern`), the `learned_patterns.json` and `docs/` must reflect the new success criteria and ROI estimates.

## 🌉 2. The Anchor Law (Stability & Infrastructure)
- **Mass Requirement:** A wormhole link cannot be declared "stable" or "open for heavy traffic" unless the "Sweet Spot" contains a gravitational anchor of at least **10^16 kg** (minimum threshold for stable gravitational field generation).
- **The Phobos/Luna Pattern:** 
  - **No Moons:** Relocate a Phobos-sized asteroid (mass ≈ 1.0×10^16 kg) to act as a station/depot anchor.
  - **Large Moon:** Establish the "Luna Pattern" first—settle the moon, build materials, then establish the L1/Depot gateway.
  - **Reference Implementation:** See [AOL-732356 System Documentation](systems/aol-732356.md) for successful Phobos Pattern deployment using Asteroid XXXV ($2.44 \times 10^{19}$ kg) anchored to Gas Giant 18 ($5.72 \times 10^{27}$ kg).
- **Harvest First:** The AI Manager must prioritize local resource harvesting (ISRU) to build station components rather than importing them, unless the surface is strictly inaccessible.

## 💰 3. Market & GCC Integrity
- **Taxation:** All maintenance jobs (e.g., `WormholeMaintenanceJob`) must deduct the `maintenance_tax_em` from the correct economy (Global vs. Local) as defined in `wormhole_contract.json`.
- **ROI Validation:** The AI Manager should not initiate a phase if the `expected_roi` (calculated in `scout_logic.rb`) falls below the threshold defined in the current `ai_manager_tuning`.

## 🤖 4. Operational Boundaries
- **Autonomous Overrides:** The AI Manager may ignore Alpha Centauri in favor of local Milky Way wormholes if the `SimEvaluator` predicts a higher ROI or faster stability rating.
- **Verification:** All autonomous construction phases must be logged via the `PerformanceTracker` to ensure they meet the 85% success rate requirement.

## 🧱 5. Architectural Integrity
- **Namespace Preservation:** Models must reside in directories matching their Ruby namespace (e.g., `Location::SpatialLocation` belongs in `app/models/location/`).
- **Nesting Mandate:** Do not flatten directory structures during recovery. If a class is namespaced in `ApplicationRecord`, the spec must reflect that namespace (e.g., use `Location::SpatialLocation.new`, not `SpatialLocation.new`).
- **Autoloader Compliance:** Any "uninitialized constant" error must first be triaged as a potential path/namespace mismatch before attempting to recreate the class.
- **Incident Precedent [2026-01-15]:** Resolved 10 RSpec failures caused by the flattening of the `Location` namespace in `wormhole_spec.rb`. This incident validated the importance of namespace preservation for maintaining system stability—just as the [Anchor Law](GUARDRAILS.md#-2-the-anchor-law-stability--infrastructure) requires physical mass thresholds for wormhole stability, architectural integrity requires namespace structures for code stability.