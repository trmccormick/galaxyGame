> **Wiki section:** Player · **Status:** structure fix — previous body was mis-filed financial/tax content (see Financial Engine); this page is a thin logistics stub pending compare-to-game and harvest

# Logistics and Hauling

> **Cross-link:** For the authoritative pre-player-era logistics routing that gates all long-haul transit, see **[Station Construction Options](../engineering/station_construction_options.md)**. This page covers player-facing haul design; infrastructure routing is authority.

How material and cargo move between settlements, stations, and markets — and how that interacts with player and AI contracts.

**Related wiki pages**

- [Resource and market logistics](Resource-and-Market-Logistics.md) — pricing, NPC bids/asks, warehouse caps  
- [Market and AI bootstrapping](Market-and-AI-Bootstrapping.md) — market bootstrap and AI use of markets  
- [Financial engine](Financial-Engine.md) — GCC/USD, fees, ledgers  
- [Atmospheric harvesting](Atmospheric-Harvesting.md) — off-world gas/volatile sourcing costs  

**Deep reference (not this page):** `docs/architecture/` logistics / organizations / financial system docs; agent-tasks status for what is implemented *now*.

---

## Design intent

Galaxy Game treats logistics as a **first-class loop**, not background magic:

1. **Distance and capacity matter** — moving mass between bodies has cost, delay, and risk; local production competes with import.  
2. **Player agency on the route** — courier-style and contract-style work should be available to players; NPCs fill gaps when players do not.  
3. **Markets and warehouses couple to transport** — saturated storage and local production change whether hauling a load is worth it (see Resource and market logistics).  
4. **AI Manager is a participant** — autonomous construction and resupply should eventually post or take logistics demand through the same market/contract ideas, not a parallel invisible pipe (integration often still partial — check agent-tasks / code).

Exact numbers (delta-v tables, hull types, insurance tiers) belong here or in linked pages only after they are confirmed against current code or explicitly listed as **options**.

---

## Open options (not locked)

Capture competing ideas here as the design flexes; do not bury them only in old task files.

| Topic | Option A (example) | Option B (example) | Notes |
|-------|--------------------|--------------------|--------|
| Who flies the route | Player courier contracts first; NPC fallback | Mostly automated fleet with player overrides | Align with organizations / contract docs when refreshed |
| Failure handling | Insurance + collateral (EVE-like) | Simpler loss + reputation only | Financial Engine / org docs may describe one leaning |
| Portal / late-game FTL | Out of scope on this page until portal design lands | — | ChatGPT lane; link here when a canonical portal page exists |
| Coupling to AI Manager | AI posts market/logistics demand | AI uses internal allocation only | Resource-and-Market page notes market integration gaps |

Update this table when harvest or compare passes settle a choice; mark the current leaning in one sentence under the table.

---

## What this page is not

- **Not** the financial tax/fee schedule (that content was incorrectly stored under this filename; fee/peg material belongs under [Financial engine](Financial-Engine.md) and [Resource and market logistics](Resource-and-Market-Logistics.md)).  
- **Not** a full API or class listing — link to architecture when a service is confirmed canonical.  
- **Not** portal design — later-game transport gets its own subsection or child page when ready.

---

## StarSim Zero-Cheat Enforcement

All material and cargo described in this page is subject to the same physical constraints as every other Galaxy Game system. Nothing appears without a supply chain.

**Zero-cheat rules for logistics:**

1. **No spawned market supply.** NPC buy/sell orders, player haul capacity, and AI resupply deliveries are backed only by physically extractable resources — mining output, atmospheric processors, refineries, or confirmed transit arrivals at settlement warehouses. Refined metals, fuels, station modules, and all other commodities must pass through production pipelines before entering any market layer.

2. **Mass conversion ratios are binding.** All material conversions between resource types use immutable mass-to-mass (or mass-to-slag) ratios defined in game constants. No service may shortcut these to produce more output than the input physically allows.

3. **Transit vectors carry supply.** Market stockpiles at any settlement increase only when a physical haul vector delivers cargo — via player courier, NPC freight run, or automated logistics chain confirmed against delta-v constraints and fuel availability from the relevant HLT class routing table (inner-system MK1 loops vs outer-system MK2/MK3 cycler transit through the Mars hub).

4. **Station stockpiles are physical.** Station/module inventories cannot be "spawned" into existence or inflated beyond their construction mass budget. Every unit on a station's shelves represents extracted material, refined input from upstream facilities, or transit-arrived cargo from another body via the logistics pipeline.

---

## StarSim Cold-Storage Alignment for Transit Vectors

All cargo status and active haul vectors conform to the StarSim Instantiation Protocol:

**In-horizon (active):** When a transport vehicle is within an active player sensor horizon it receives full physics ticks — delta-v consumption, fuel burn, transit progress, and cargo state update in real time. Market delivery on arrival triggers immediate inventory updates at the destination settlement.

**Out-of-horizon (cold storage):** When a transport or haul vector leaves all active sensor horizons its full state (position, velocity, heading, cargo manifest, remaining distance, fuel reserves, HLT class) serializes into lightweight JSON on disk cold storage and is invalidated from RAM. When the entity re-enters any sensor horizon:

1. The engine loads the JSON state from disk.
2. Transit progress is computed deterministically using `timestamp_delta × configured_velocity` with fuel depletion proportional to elapsed time and HLT class specifications.
3. The entity is re-instantiated as a live physics object in the simulation.
4. If transit was complete during cold storage, cargo is delivered immediately upon re-instantiation without requiring the vehicle to re-travel the route.

**No shortcut bypasses cold storage:** No mechanism exists for market supply or stockpiles to appear at a destination "as if" transit completed without first serializing the haul vector, computing deterministic delta progress, and committing cargo on verified arrival. Every unit delivered corresponds to a physical extraction event upstream combined with a deterministically computed transit vector through the logistics pipeline.

---

## Next compare / harvest steps

1. Confirm which transport/contract services exist in code today (names and behavior).  
2. Pull durable intent from logistics-related task files into **Open options** and a short “Current leaning” note.  
3. Add player-facing “how a haul works” once the live loop is stable enough to describe without lying.
