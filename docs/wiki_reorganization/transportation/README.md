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
