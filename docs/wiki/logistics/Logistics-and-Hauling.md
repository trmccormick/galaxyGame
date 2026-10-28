> **Wiki section:** Player · **Status:** structure fix — previous body was mis-filed financial/tax content (see Financial Engine); this page is a thin logistics stub pending compare-to-game and harvest

# Logistics and Hauling

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

## Next compare / harvest steps

1. Confirm which transport/contract services exist in code today (names and behavior).  
2. Pull durable intent from logistics-related task files into **Open options** and a short “Current leaning” note.  
3. Add player-facing “how a haul works” once the live loop is stable enough to describe without lying.
