---
title: Settlement Infrastructure
category: Infrastructure
status: LIVE (design intent + code-verified note + draft direction + open items)
last_updated: 2026-11-03
---

# Settlement Infrastructure

> **Code Alignment Status:** `PARTIALLY IMPLEMENTED`  
> *Code facts checked at:* commit `c5f0d9e` (2026-10-29), see the table below.  
> *Summary:* The settlement models, `Settlement::OrbitalSettlement` and the structure types listed under *Verified against code* exist. The `Settlement::SpaceStation` and `Settlement::OrbitalDepot` classes are retired in code; stations and depots remain part of the game as `Structures::OrbitalStructure`. A structure can be part of an orbital settlement, but a depot with no residents is not necessarily a settlement. The tier rules, governance, sphere of influence, absorption and life support requirements under *Direction* are not implemented.

> **How to read this page.** *Design Intent* is the agreed design. *Verified against code* records what the codebase does today (checked at commit `c5f0d9e`, 2026-10-29); where the two differ, the code section is current behavior and the intent stands until the owner changes it. **Terminology:** *Settlement* (capital S) is the unit that exists at every tier (the game model); *settlement tier* is one of its tiers. *Direction under discussion* is the owner's working thinking on tiers, not yet final. *OPEN* lists items with no source in the docs or the code; they are not decisions.

---

## Design Intent

A **Settlement** is the core administrative, economic, and population unit in Galaxy Game. It manages population, economy, contracts, and jurisdiction, and can encompass multiple physical structures, both natural and artificial. Settlements can exist on planetary surfaces, within natural features (lava tubes, craters), or in orbit (e.g., the L1 Gateway).

### Key Principles

| Principle | Intent |
|-----------|--------|
| Separation of concerns | Settlements are administrative entities, not structures. They contain, or are hosted within, one or more structures. |
| Structures as assets | Structures (natural or artificial) are physical assets that provide shelter, storage, or operational capacity to a settlement. |
| Blueprint-driven expansion | Artificial structures are built from blueprints and added to a settlement as it grows. |
| Natural features | A settlement can be hosted in a natural feature (lava tube, crater) or an artificial structure (worldhouse, station, depot). |

### Natural vs. Artificial Structures

- **Natural:** lava tubes, craters, canyons (worldhouse pattern).
- **Artificial:** space stations, depots, worldhouses.
- Both attach to a settlement through its structures.

### Orbital Settlements

An orbital settlement (e.g., the L1 Gateway) is **one settlement containing several peer structures**, for example a shipyard/repair structure and a cargo/refueling structure. It is not a single station object.

**ESTABLISHED INTENT (owner, 2026-11-03):** Space stations and orbital depots are part of the game, but they are represented as `Structures::OrbitalStructure`, not as separate settlement classes. The reason for the change: a space station is just a structure, and treating it that way keeps the organization simple, because an orbital settlement then has many structures in the same way a surface settlement does. **Not every orbital structure is part of a settlement:** the Earth LEO depot is an orbital structure that is not in a settlement. It works like a gas station: outgoing craft refuel there, and incoming craft dock and unload their extra fuel there instead of carrying it back to Earth. The exchange happens through the market: craft buy and sell items while docked, and fuel is one of those items. This part of the design is still being refined and is untested in places.

**DIRECTION (owner, 2026-11-03):** The structures of an orbital settlement are not physically connected to each other, unlike the buildings of a surface settlement. The market system may need to change so that a market works **per structure** when the structures are not connected. This is a known gap in the current code, where a market belongs to a settlement.

Related design: [Station Construction Options](../engineering/station_construction_options.md) (how stations are built), [ISRU Fabrication Chain](../technical/isru_fabrication_chain.md) (in-situ production), [Atmospheric Harvesting](atmospheric_harvesting.md)

---

## Verified against code (commit `c5f0d9e`, 2026-10-29)

| Topic | What the code does |
|-------|--------------------|
| Settlement types | `settlement_type` enum: `base`, `outpost`, `settlement`, `city`, `station`. |
| How the type is set | On every change to `current_population` the type is reassigned from population: **0–9 → base, 10–99 → outpost, 100–999 → settlement, 1000+ → city**. A `population_requirements` method defines the same minimums (base ≥ 1, outpost ≥ 10, settlement ≥ 100, city ≥ 1000) but is not registered as a validation in the settlement model files. This rule never assigns `station`. |
| What a settlement has | Owner (optional), colony (optional), accounts, inventory, missions, marketplace, location, docked crafts, base units, orbital construction projects, jobs, construction jobs, and `structures` (all `Structures::BaseStructure`, linked by `settlement_id`). |
| Orbital settlement | `Settlement::OrbitalSettlement` exists and is active. It shares the settlements table; its location comes from its first structure, and its population capacity and storage are summed over its structures. |
| `SpaceStation`, `OrbitalDepot` | Both `Settlement::` classes are marked **RETIRED 2026-04-10** in code ("kept for git history only. Do not use this class."). Replacement: `Settlement::OrbitalSettlement` with `Structures::OrbitalStructure`. Stations and depots still exist in the game as structures: the construction service reads space station blueprints from a `structures/space_stations` data path, and the AI foothold planner has an `orbital_depot` pattern. A structure's `settlement` link is optional in the model, so a structure can exist without belonging to a settlement. |
| Structure types | Under `Structures::BaseStructure`: `CraterDome`, `HabitationFacility`, `Hangar`, `ManufacturingFacility`, `OrbitalStructure`, `PowerStation`, `SolarArray`, `StorageFacility`, `Worldhouse` (`ConvertedBase` extends `Worldhouse`). There is no `Structures::SpaceStation` or `Structures::OrbitalDepot`. |

---

## ESTABLISHED INTENT — NPC footholds and player businesses without private settlements (2026-11-02)

**Intent:** Players may establish and operate businesses (harvesting, manufacturing, trading, logistics) at existing NPC foothold locations — such as Development Corporation bases or AI Manager-established depots — without first constructing their own private settlement infrastructure. A player could remain at an NPC foothold indefinitely, running a business that supports other settlements.

**Design implications:**
- Reduces early-game friction: players don't need to bootstrap full settlement infrastructure before participating economically.
- Creates natural entry points for new or casual players who want to contribute without the commitment of building a colony.
- NPC footholds become economic hubs where player businesses can coexist with AI Manager operations.
- Players remain at an NPC foothold indefinitely — no requirement to expand or build private infrastructure.

**Undecided implementation details:**
- Which NPC foothold types are eligible? (All Development Corporation bases? Only operational depots?)
- Does the player "lease" space, pay a fee, or operate freely?
- Can multiple players operate businesses at the same foothold, or is it exclusive?
- What happens if the AI Manager abandons or relocates the foothold?

> **Cross-reference:** See also [Player Independence: Staying Put Is Valid Play](../player/getting_started.md#established-intent--player-independence-staying-put-is-valid-play) in the getting-started page for the broader principle that staying at one location is valid play.

---

## Direction under discussion (owner, 2026-10-29) — DRAFT, not final

This is the owner's working direction for what makes a settlement a base, outpost, settlement, or city. **None of it is implemented**; the code (see above) still decides the tier by population alone. Items are marked **DIRECTION** (the owner's stated thinking) or **OPEN** (not decided).

### Why population alone is not enough (real-world reasoning)

These examples come from the owner's own region. They show how the ideas work in one place; other places define the same words differently.

- A community of roughly 700 to 1,000 people (a census count and a later survey estimate of the same place differ) with one elementary school, a few churches, one post office, a couple of clubs, and a volunteer fire department is a small community, not a city.
- An unincorporated community of about 5,700 people, with its own fire department, school, and churches, is still not a town. It is taxed by its county only, not by a city, and its mail goes to the nearby city.
- A city of about 30,000 has several providers of the same service (two hospitals, two malls), a wide variety of services (specialist care, shopping, entertainment, a university), and the services that smaller places around it depend on. It grew partly by absorbing smaller areas nearby.
- A fort or trading post can grow into a small town as people settle around it and services arrive. Many towns and cities began this way.
- What counts as a town or a city differs by jurisdiction; headcount does not settle it.

Under the current code rule, the first community would be a *settlement* by the census count (about 700) but a *city* by the survey estimate (about 1,066), because the two figures fall on either side of the 1,000 cutoff. The second (about 5,700) would be a city. Two official counts of one place give different tiers, which shows how fragile a population-only rule is.

### DIRECTION — three separate ideas

| Idea | Meaning |
|------|---------|
| **Development** | How developed a settlement is, driven by its services: *breadth* (how many kinds), *depth* (how many providers of each, so choice and backup), and *specialization* (services only a few places have). Size supports it but does not define it. |
| **Governance** | Who governs and taxes the settlement. It is independent of development: a settlement can be well developed yet not self-governing, or small yet self-governing. |
| **Sphere of influence** | Which hub a settlement is tied to for supply, trade, schools, health care, and mail, whoever governs it. Smaller settlements rely on services in a larger one nearby. |

Interdependence applies at every tier: almost no place is self-sufficient. Each makes some things and trades for the rest, and a city in particular relies on the region around it while serving that region. A tier therefore says what a place makes and provides, not how little it needs from others.

### DIRECTION — draft tier picture (for correction)

| Tier | Real-world anchor | What defines it |
|------|-------------------|-----------------|
| Base | Precursor site or remote research station | Built for a purpose; often automated with few or no residents. If crewed, it must produce oxygen. |
| Outpost | Small remote presence | Narrow purpose, small crew, relies on supply from elsewhere. |
| Settlement | Small community of several hundred to about 1,000 | People live there permanently; produces oxygen; everyday services; shares regional services with neighbors in its colony. |
| City | Regional hub | Many services with competing providers, specialized services, and it serves the settlements around it; depends on its surrounding region for materials. |

### DIRECTION — life support and crewing

- **A Settlement with human residents must be able to produce oxygen.** It is the first basic life support: a place where people cannot breathe cannot be settled. By body: on Luna, oxygen from regolith; on Mars and Venus, oxygen from processing CO₂.
- **Automated, uncrewed Settlements need no life support.** A Settlement can have zero residents.
- Beyond oxygen, requirements per tier are not defined (see OPEN).

### DIRECTION — lifecycle

Precursor missions prepare a place for human settlement. Robots go first; people come after. The Luna precursor sequence in [Precursor Mission Deployment](../technical/precursor_mission_deployment.md) is the reference pattern. As technology improves the steps may change, but the intent stays the same. An automated Settlement is therefore often an early **phase** of the same Settlement, which becomes crewed once it can support people. A location that is **not human-rated** can stay robotic permanently; being automated is not always a stage on the way to being crewed.

### DIRECTION — growth

A larger settlement can grow by **absorbing** smaller settlements nearby, bringing them under its jurisdiction and services. The more a settlement depends on a hub, the more natural the absorption.

### Relationship to the code

The code already groups settlements into a `Colony` (at least two settlements; it totals their population and resource needs). It has no notion of governance status, sphere of influence, or one settlement absorbing another. All of those would be new.

---

## OPEN — needs owner confirmation

No source for these was found in the documentation or the code. They are not part of the design until confirmed.

| Item | Note |
|------|------|
| Game services behind the tiers | Which services count (e.g., supply link, storage, production, market, shipyard, research, medical, emergency response, governance) and what each tier needs. |
| Services per settlement or per colony | Does a settlement count services it has itself, or those available through its colony or hub? |
| Governance statuses | Which statuses exist (sponsor-run, dependent, self-governing, chartered) and what each changes (taxes, fees, jurisdiction, contracts). |
| Absorption rule | Automatic past a threshold, a player or AI decision (contract or takeover), or both. What happens to the absorbed settlement's identity and structures. |
| Base and outpost: stage or kind | Are base and outpost early stages on the path to settlement and city, or purpose-built installations that are a different kind of place from a community? Real-world forts have grown into towns, so a base or outpost *can* become a community when people settle and services arrive; not all do (see also *human-rated*). Owner to confirm. |
| Permanence | Should temporary versus permanent residency be its own attribute alongside development, governance, and sphere of influence? |
| Where oxygen fits in the precursor sequence | The precursor page stops at the solar farm and never mentions oxygen or when people may arrive. What must be true before humans are allowed in? |
| Oxygen from imports at the start | The Super-Mars scenario imports oxygen from Earth until local extraction is online. Is an import-only start allowed temporarily, or is local oxygen production required first? |
| Precursor sequence: all worlds or Luna pattern | The precursor page calls the sequence "world-invariant". The owner's direction is that it is the Luna reference pattern and only the intent is constant. The page may need rewording. |
| What makes a location human-rated | Which conditions (environment, radiation, temperature, pressure, available oxygen source) decide it, and whether it is a property of the body, the specific location, or the facility. The code has `habitable?` for atmospheres and says gas and ice giants are "not habitable", but nothing marks a site as human-rated. |
| Sphere of influence | Is it the existing colony, the marketplace, or a new relationship? |
| Life support beyond oxygen | Water, food, and energy requirements for crewed Settlements, and any per-tier requirements. Code only validates per-person food, water, and energy rates; `Settlement::LifeSupport` is a stub that always reports `operational`. |
| Structure-count ranges per tier | Values such as 1–2 / 3–5 / 6–10+ structures were proposed in an earlier draft of this page with no source. The code tiers by **population**, not structure count. |
| Stage-gate rule ("each tier needs the prior life-support loop online") | No source found; nothing in the code enforces it. |
| Per-tier descriptions | Earlier wording ("minimal life support", "integrated ISRU loops", etc.) has no source. |
| Per-tier construction costs and durations | Not defined anywhere found. |
| Role of the `station` type | Population-based reassignment never produces `station` and would overwrite it on the next population change. Since a space station is now a structure (see Orbital Settlements), is the `station` value still needed in `settlement_type`, or is it left over from before the change? |
| What makes a standalone structure part of a settlement? | A depot such as the Earth LEO depot is a structure that is not a settlement. Does one ever join a settlement, for example by being absorbed, or does it stay on its own? |
| How would a per-structure market work? | A market per structure is the owner's direction for structures that are not physically connected. Open: whether a standalone structure such as a depot has its own market or uses a nearby or regional one, who the counterparty is, and how an orbital settlement with several structures presents prices and orders. |
