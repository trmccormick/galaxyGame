---
title: Interstellar Communications
category: Engineering
status: ESTABLISHED INTENT — owner-confirmed design; not yet implemented
last_updated: 2026-11-02
---

# Interstellar Communications

> **Classification:** ESTABLISHED INTENT — owner-confirmed design. Not yet implemented.
>
> **Historical note:** This page originally conflicted with [`docs/architecture/intent/WORMHOLE_NETWORK_INTENT.md`](../architecture/intent/WORMHOLE_NETWORK_INTENT.md), which contained an "Instant Communication: FTL communication through wormholes" entry under Future Network Development. That entry was **never the owner's intended design**. The wiki establishes the correct intent here; the external file has not been modified (frozen documentation).

---

## Design Intent

### Light-Speed Electromagnetic Communication

All interstellar communication propagates at the speed of light via electromagnetic transmission. **There is no faster-than-light (FTL) communication in Galaxy Game.**

**Core principle:** Information between star systems experiences distance-dependent propagation delays. A message sent from Earth to a settlement 4.37 light-years away (Alpha Centauri) takes 4.37 years to arrive, regardless of the sender's or receiver's technology level.

### Store-and-Forward Relay Network

Stations and ships act as store-and-forward relays in the communication network:

| Mechanism | Description | Latency | Bandwidth |
|-----------|-------------|---------|-----------|
| **Direct EM transmission** | Laser/radio transmission between systems at light speed | Distance-dependent (light-years) | High (limited by transmitter power and receiver sensitivity) |
| **Station relays** | Communication stations in intermediate systems forward messages | Sum of hop delays | High |
| **Ship-based relays** | Cargo ships carry data storage and transmit to nearby settlements upon arrival | Transit time + EM delay | Moderate |
| **Dedicated data couriers** | Specialized vessels carrying bulk data between systems | Transit time | Very high |

**Why this matters:**
- Distance creates natural information latency — intelligence from another system is old by the time it arrives.
- Communication relays (stations, ships) are critical infrastructure that players and AI can build, defend, or disrupt.
- Data courier missions become valuable player contracts for high-bandwidth transfers where EM delay is prohibitive.
- Wormhole transit does not bypass communication physics: a wormhole shortcut for physical travel still has light-speed communication delay on the non-wormhole portions of the path.

### Wormholes Do Not Provide Instant Messaging

Wormholes and portals are **physical transportation shortcuts only**. They do not bypass communication physics:

- A ship traveling through a wormhole from Sol to Alpha Centauri arrives nearly instantly (by ship transit time).
- A light-speed message sent along the same route takes 4.37 years.
- A message forwarded via a wormhole station at each endpoint still experiences the light-speed delay between the station and its target system.

This distinction is important for game design: physical travel can be fast via wormholes, but information always propagates at light speed. This preserves interstellar tension and makes communication infrastructure meaningful.

---

## Open Questions

- What is the minimum relay station spacing for continuous inter-system communication coverage?
- Are there any wormhole-based communication channels at all, or is everything light-speed EM + physical transport?
- Does the AI Manager have any interstellar coordination capability, or is it bounded to individual systems?
- How do player communications work across wormholes (in-game chat, messaging)?
- Is there a "light delay" for non-wormhole interstellar communication (e.g., laser relay networks)?

---

## Related Pages

| Page | Relationship |
|------|--------------|
| [Station Construction Options](station_construction_options.md) | Wormhole station infrastructure that could carry data couriers |
| [AI Manager Logic](../services/ai_manager.md) | AI coordination scope across wormholes |
| [Wormhole Network Intent](../architecture/intent/WORMHOLE_NETWORK_INTENT.md) | Frozen file; contains historical entry claiming instant FTL comms that was never owner intent. Corrected intent documented here in the wiki. |
