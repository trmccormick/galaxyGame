---
title: Interstellar Communications
category: Engineering
status: DESIGN INTENT — owner-confirmed; not yet implemented
last_updated: 2026-11-03
---

# Interstellar Communications
> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-01  
> *Audit Summary:* Design intent specification. Code implementation pending or unverified as of audit baseline.

> **Page status:** `DESIGN INTENT` — owner-confirmed, not implemented in code. The concept is still being refined; the details marked `DIRECTION` and `OPEN` below are not decided.
>
> **Correction note:** An older frozen architecture document (`docs/architecture/intent/WORMHOLE_NETWORK_INTENT.md`, cited as plain text) lists "Instant Communication: FTL communication through wormholes" as a future development. That was never the owner's intent. This page holds the correct intent.

---

## ESTABLISHED INTENT (owner, 2026-11-03)

**There is no faster-than-light (FTL) communication in Galaxy Game.** Information moves in two ways: as ordinary light-speed transmission inside a system, and carried by craft between systems. Between systems the model is **store-and-forward**.

### Inside a system

- Communication is standard light-speed transmission. The delay grows with distance, so an outer-system craft is hours away from the inner system.
- Stations, settlements and craft can act as **relay points**.

### Between systems

1. **Normal (non-urgent) data.** A craft stores the data and, on entering the next system, transmits it to the wormhole station there (WS or AWS). That station retransmits it onward. Data is passed between passing ships and the WS or AWS stations.
2. **Urgent data.** Players or automated craft can carry urgent communication through the wormhole. If no craft is expected to transit soon, a shuttle can be dispatched as a **data courier**.

Wormholes are physical transport shortcuts. A ship can cross from Sol to Alpha Centauri nearly instantly by ship transit time, but a light-speed message along the same route takes 4.37 years. Nothing replaces the ships, which is why the relay and courier model matters.

---

## DIRECTION (owner's working thinking, 2026-11-03 — not final)

- **Power-dependent communication.** Whether and how far a craft, station or settlement can send or receive depends on the power it has available. An unpowered craft cannot communicate.
- **Real-world model.** The design is grounded in how NASA relays data on Mars. Surface rovers send to an orbiting satellite, which holds the data and forwards it to Earth through the Deep Space Network. The Mars Relay Network is the reference example (cited as plain text). Relay availability there depends on which orbiter is overhead, and the orbiters are scheduled because they share frequencies.
- **Low-bandwidth data bursts through a wormhole are possible, but are not the typical method.** Store-and-forward by craft is the normal way.

---

## OPEN — needs owner confirmation

| Question | Notes |
|----------|-------|
| What counts as "urgent", and who decides to dispatch a courier shuttle (player, AI Manager, or both)? | |
| Who pays for a courier shuttle? | |
| How does a craft or station know whether another craft is expected to transit soon? | Needed to decide when a shuttle is dispatched. |
| How does power affect communication (range, strength, bandwidth)? Does antenna size or the receiving end matter? | Direction only; no numbers. |
| What happens to a craft that has lost power? Can it send an emergency message? | |
| Does the game model relay pass timing, such as an orbiter being overhead only at certain times? | |
| What limits a data burst through a wormhole (size, cost, frequency)? | Possible but not typical. |
| Are relays and couriers targets that players can build, defend or disrupt, or sources of contracts? | Earlier versions of this page said so; not owner-confirmed. |
| What does WS stand for, and what does AWS stand for? | The wiki uses both for wormhole-related stations; definitions are not confirmed. |
| What is the minimum relay spacing for continuous coverage inside a system or between systems? | |
| Does the AI Manager have any interstellar coordination, or is it limited to individual systems? | |
| How do player communications (messaging, chat) work across wormholes? | |

---

## Related Pages

| Page | Relationship |
|------|--------------|
| [Station Construction Options](station_construction_options.md) | Wormhole station infrastructure that relays and couriers would use |
| [AI Manager](../services/ai_manager.md) | Coordination scope across wormholes; expansion scouting |
