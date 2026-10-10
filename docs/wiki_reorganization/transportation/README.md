# Transportation Documentation Hub

**Status**: Canonical entry point for all transportation/craft documentation  
**Last Updated**: 2026-09-15  
**Related**: All pages under `transportation/`

---

## Architecture Overview

This hub organizes all craft, satellite, and logistics documentation for Galaxy Game. Transportation covers manufactured mobile assets (craft), their attachments (units, modules, rigs), orbital infrastructure (stations, depots), and the logistics network connecting them.

> **Terminology note**: Craft are manufactured mobile or independently operating vehicles/assets. Natural satellites belong to the Universe Generation domain (`CelestialBody` hierarchy). GCC mining satellites are manufactured satellites with a specific role in GCC issuance.

---

## Documentation Map

### Canonical Pages

- **[01-craft-taxonomy.md](./01-craft-taxonomy)** — Craft taxonomy, entity boundaries (craft vs unit/module/rig/station/structure), natural vs manufactured satellite terminology, attachment roles, currency governance models
- **[02-gcc-mining-satellite.md](./02-gcc-mining-satellite)** — GCC mining satellite entry: terminology, classification, issuance vs extraction boundary, implementation-alignment notes

### Gap Tracking

- **[GAPS.md](./GAPS)** — Implementation-alignment gaps for Transportation domain

### Future Pages (Deferred)

- Stations documentation
- Depots documentation
- Shipyard infrastructure
- Cycler routes
- Cargo types and handling
- Docking mechanics
- Logistics network overview

---

## Key Models & Services

| Model/Service | Location | Purpose |
|--------------|----------|---------|
| `Craft::BaseCraft` | `app/models/craft/base_craft.rb` | Active reported craft base class |
| `Craft::Satellite::BaseSatellite` | `app/models/craft/satellite/base_satellite.rb` | Manufactured satellite class |
| `CelestialBodies::Satellites::Satellite` | `app/models/celestial_bodies/satellites/satellite.rb` | Natural satellite class hierarchy |
| `Settlement::SpaceStation` | `app/models/settlement/space_station.rb` | Settlement type, not a craft |
| `Rigs::BaseRig` | `app/models/rigs/base_rig.rb` | Rig attachment/effect concerns |

---

## Cross-Domain References

- [Currency Governance](../economy/02-currencies-and-accounts#currency-governance) — Multi-currency architecture and per-currency policy
- [GCC Issuance vs Physical Extraction](../economy/04-bonds-and-financing#gcc-mining) — GCC mining bond financing

---

## Change History

- **2026-09-15**: Created hub page; linked craft taxonomy and GCC mining satellite entries (Phase 4).
- **2026-09-15**: Normalized to Economy hub pattern: architecture overview, doc map grouped by purpose, Key Models & Services table, cross-domain references (Transportation normalization).

---

## TransitEngine Topology Containment — Phase 1 Notes

**Gap tracking**: see [GAPS.md — Gap D](./GAPS.md#gap-d-transitengine-topology-containment--phase-1-verified-gaps-unresolved).

- The retained legacy dynamic path in `Mission::TransitEngine.calculate_transfer_window` is reachable only for the same-system, parentless planet-lineage topology proxy; passing the proxy is not a claim of support or physical correctness.
- Moon/satellite, parented, non-planet, dwarf/minor-body, and otherwise nonconforming resolved bodies raise `Mission::UnsupportedTransferError` in this path. Unresolvable identifiers keep the legacy fallback when every resolved endpoint passes.
- The precursor Earth→Luna scenario in `luna_mission:phase_timing` uses an explicitly labeled static 7-game-day duration. Earth→Venus remains on the engine path.
- The proxy is temporary containment, not a route-planning system. Future work (reference-frame metadata, central-body association, per-body `mu`, parent/SOI transitions, multi-leg routing) is human-filed follow-up work, not something the implementer creates or dispatches.
