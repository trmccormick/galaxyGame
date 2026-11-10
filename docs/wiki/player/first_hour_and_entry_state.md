# First Hour and Entry State

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-04  
> *Audit Summary:* Short player-facing summary of what the owner stated on 2026-11-04 about when players enter and what they first see. Not implemented as described. Not yet verified against code.

This page distills the 2026-11-04 owner and Gemini brainstorm into what a new player meets at the start. The goal is to improve the setup for players entering the game.

---

## ESTABLISHED INTENT (owner, 2026-11-04)

### When players arrive
- Players enter once **AWS technology is online**. Eden is reconnected through the new AWS. System B, reached through the natural wormhole, is unsettled. Eden's state is unknown, including whether its first settlements survived.
- The first players pick a location that is **active**. They do not start at the unknown old Eden stations.
- At entry, **Sol is active, Eden is unknown, and System B is empty** (owner, 2026-11-05).
- Eden's condition at the disconnect is **emergent**, not pre-scripted. See [Eden Disconnect and Emergent History](eden_disconnect_and_emergent_history.md).

### Where a player starts
- The AI Manager, working through NPC corporations, runs the foothold bases and stations that let players travel the universe. A new player starts at one of them and gets basic equipment that depends on where they land: Luna, Mars or a space station.
- Starting on a station gives access to space-based work such as harvesting atmospherics, logistics runs and exploration. Starting on the surface gives surface work.
- The starts aren't exclusive. A player on a station can portal to a surface settlement, and doesn't need to stay where they began.

### What the game is about
- Surface play includes exploring, mining, and building and managing a settlement (like SimCity). Station play is a different level of the same game. Neither is about combat. It is closer to managing automated harvesters and logistics ships.
- A player on a base has a **dashboard** to manage assets such as robotic harvesters and deployed ships, and to track things and their market listings.

### Distance and time
- Because the game spans several systems, it includes **data lag**. See [Interstellar Communications](../engineering/interstellar_communications.md).
- Getting somewhere takes time. Even portals take time between settlements in one system, and the next system takes longer. The owner compared it to airline travel, where a direct route isn't always available and layovers happen. This pushes a player to decide where to base their operations.
- Portals are built in pairs and carry low mass only. See [Portals and AWS](../technical/portals_and_aws.md).

### Early bases
- The first outposts are basic, and the first settlements would be in lava tubes. See [Settlement Progression and Footholds](settlement_progression_and_footholds.md).

### Economy at entry
- Local trade on Luna starts at 80% EAP for the AI Manager's buy price and 90% EAP for its sell price. The AI Manager doesn't compete with players. If players beat the import price or fill its buy orders, it stops its own harvesting and imports. See [AI Manager Economic Loops](../logistics/ai_manager_economic_loops.md).
- When a base starts up there may be no players. The base runs by itself, so a player enters whatever state it has reached.

---

## DIRECTION (not decided)

- **Sol is not expected to settle System B until it has a handle on the wormholes** (owner's assumption, 2026-11-05). Apart from a few scouts, Sol studies them. Whether the AI Manager sends scouts, and what the study produces, is OPEN.
- A basic dashboard-first UI (tables, status cards) before richer visual views of base building. Gemini suggested this phasing. The owner said the UI is still being worked out with ChatGPT.

---

## OPEN

| Question | Notes |
|----------|-------|
| Exactly what equipment does a new player get at each start (Luna, Mars, station)? | |
| Which locations count as "active" at entry? | |
| What does the first hour look like on the dashboard? | Waiting on the UI work. |
| How does a player first choose a start? | |
