---
title: Interstellar Communications
category: Engineering
status: DESIGN INTENT — owner-confirmed; not yet implemented
last_updated: 2026-11-09
---

# Interstellar Communications
> **Code Alignment Status:** `DESIGN INTENT`
> *Last Audited:* 2026-11-01
> *Audit Summary:* Design intent specification. Code implementation pending or unverified as of audit baseline.

> **Page status:** `DESIGN INTENT` — owner-confirmed, not implemented in code. The overall communications model is established; engineering values, routing details, and implementation choices remain open.
>
> **Correction note:** An older frozen architecture document (`docs/architecture/intent/WORMHOLE_NETWORK_INTENT.md`, cited as plain text) lists "Instant Communication: FTL communication through wormholes" as a future development. That was never the owner's intent. This page holds the correct intent.

---

## ESTABLISHED INTENT (owner-confirmed, 2026-11-09)

**There is no faster-than-light (FTL) communication in Galaxy Game.** Information moves through ordinary light-speed electromagnetic transmission and physical store-and-forward transport. Portals and wormholes shorten physical carrier journeys; they do not make electromagnetic messages travel faster than light.

The purpose of this system is to give remote commands and their responses believable delivery times. It is not intended to become an unnecessarily detailed network simulator.

### Light-speed electromagnetic communication

- Radio and laser signals travel at light speed. Distance and the relative positions of communicating assets determine propagation delay.
- Stations, settlements, ships, and other suitably equipped craft can act as powered communication relays.
- Relay infrastructure receives, stores, regenerates or retransmits data, extending useful coverage and improving link availability and capacity. Relays do **not** increase the speed of light.
- Communication capability depends on available power and suitable transmitting / receiving equipment. Exact effects on range, bandwidth, and reliability remain open.
- Local RF links can deliver a packet to a relay, which can forward it toward another relay or the destination.

### Store-and-forward nodes and physical carriers

A common store-and-forward model applies across settlements, stations, ships, and robotic couriers. A node capable of participating maintains outgoing data until delivery is confirmed and can retain and forward received data when a suitable onward link or carrier becomes available.

- A command or message is queued at its origin.
- It can be transmitted over an available electromagnetic link or copied to a suitable passing craft, human traveler, or robotic courier.
- The physical carrier transports the data to another communications node, where it is transferred into the local network and forwarded onward.
- The origin retains its packet until an acknowledgment confirms delivery (and, where relevant, command execution). A carrier receiving a copy does not take exclusive ownership of the origin's packet.
- Nodes and carriers have different capabilities. Storage, local RF transmission, long-range relay, and physical carriage are distinct capabilities; not every node performs all of them.

This allows the network to use whatever infrastructure and traffic is available rather than relying on a fixed route or a dedicated courier for every message.

### Intra-system portals

Intra-system portals can shorten a data carrier's physical journey between their connected locations.

- The portal does not transmit the message as an electromagnetic signal through the aperture.
- A robotic courier or human traveler carrying a personal communications device can pass through the portal.
- The carrier transfers queued data into the destination endpoint's local network, where it can be relayed onward by RF or another physical carrier.
- A route may combine ordinary RF links, portal transfers, and conventional ship or robotic-courier legs.

Portal operation and physical constraints are documented on the Portals & AWS wiki page. The communications design does not change the portal's low-mass transport role.

### Natural wormholes and AWS / WS infrastructure

The same store-and-forward principle applies between star systems.

- A passing craft can carry queued data through a natural wormhole or an operational AWS connection.
- A wormhole station (WS) or AWS on the receiving side can ingest the data and retransmit it across that system using local electromagnetic relays and available carriers.
- Passing ships can exchange packets with stations or other craft. A fast shuttle / robotic courier can be dispatched when waiting for normal traffic would take too long.
- Data can continue through additional systems using the same process until it reaches its destination.
- Wormholes and AWS provide physical transportation shortcuts for carriers. They do not provide FTL messaging.

The normal inter-system method is store-and-forward through craft and stations. A direct low-bandwidth data burst through a wormhole is not the typical communications path and remains an open technical possibility, not an assumed capability.

### Dynamic route and delivery-time calculation

The communications service should evaluate the infrastructure and transport opportunities available when a command is sent. It should choose a feasible route and estimate delivery time without requiring a permanently fixed network topology or a high-fidelity standalone network simulator.

Relevant factors include:

- Available RF links and relay capability.
- Active portal connections and operational wormhole / AWS links.
- Settlements and stations able to receive, queue, and forward data.
- Suitable passing ships, travelers, and robotic couriers, including their destinations and expected availability.
- Relay capacity, queueing, and temporary operating constraints. For example, a Mars dust storm may reduce a settlement's ability to receive or forward traffic.
- Relevant distances and predicted positions of planets, stations, and craft at the times a link or carrier transfer is expected to occur.

The existing orbital simulation should provide positions and movement predictions when needed; communications routing should not create a separate orbital mechanics model. The route can be reevaluated at handoffs or when a material availability change invalidates the estimate. The calculation should remain proportionate to the gameplay purpose.

The service should provide at least:
1. Estimated time for the command to reach its target.
2. Estimated time for an acknowledgment to return to the origin, when it can be estimated.

A command's delivery time, the time needed for the target to execute it, and the return time for confirmation are separate intervals. A command may execute well before its origin learns that it succeeded.

### Packet retention and acknowledgment

- The origin retains an outgoing packet until an acknowledgment returns; forwarding a copy to a carrier does not delete the origin's copy.
- The destination records receipt and, for an actionable command, can separately report execution.
- An acknowledgment is itself data and follows the same communications network back to the origin.
- Duplicate copies may arrive by different routes. Delivery handling must avoid executing the same command more than once; the exact transactional and ordering rules remain an implementation detail.
- Packet expiration, stale-command handling, retry policy, and detailed delivery guarantees remain open.

---

## DIRECTION — implementation and balancing details remain open

- Power, antenna / receiver capability, bandwidth, range, and reliability need practical game abstractions and balancing values.
- Relay infrastructure should improve useful coverage and capacity without implying that signals exceed light speed.
- Routing should use available infrastructure and traffic opportunistically. A dedicated courier is an option, not a requirement for every message.
- The route visualization is a UI presentation of routing results, not the routing authority itself.
- The database needs delivery lifecycle and scheduling information, including an expected arrival time. A calculated route may also be retained for diagnostics or history, but a permanent route record is not required for the design to work.
- Exact route scoring (fastest, most reliable, cost-aware, or other priorities) is not yet decided.

---

## UI / observability intent

The same underlying routing and delivery information can support both administration and the eventual player interface.

- **Player view:** Preview the proposed route and show the expected command arrival and acknowledgment return. After dispatch, show progress and delivery / execution / acknowledgment state.
- **Admin view:** Expose the full relay and carrier path, availability constraints, handoffs, queueing, routing decisions, and actual versus estimated times.
- **Route map:** A JavaScript visualization can show nodes and the selected path. Different segment colors or line styles can distinguish RF transmission, portal-carried transfers, and conventional physical carriers. Portal and wormhole crossings should be identifiable.
- The visualization is illustrative feedback. The communications service calculates the route and times; the UI does not independently determine them.

The prototype may use mock or harvested JSON data until live routing and delivery services exist. UI colors, map layout, animation, and exact interaction patterns are design experiments rather than locked implementation requirements.

---

## OPEN — needs owner confirmation or engineering definition

| Question | Notes |
|----------|-------|
| What counts as urgent, and who may authorize a dedicated courier (player, AI Manager, or both)? | |
| Who pays for a dedicated courier? | |
| How does a node learn which craft are expected to pass through or arrive? | Schedule / traffic prediction detail. |
| How do power, antenna size, receiver capability, range, bandwidth, and reliability interact? | Direction only; no numbers. |
| What can a craft with insufficient power still do, including emergency signaling? | |
| How much relay-pass timing detail should be simulated? | Prefer a useful estimate over an unnecessarily detailed network simulator. |
| What capacity reductions should environmental conditions cause? | Mars dust storms are an example; thresholds are open. |
| Are low-bandwidth direct data bursts through wormholes possible, and what limits them? | Not the normal inter-system method. |
| What are the packet retry, expiration, stale-command, ordering, and duplicate-execution rules? | |
| What does the system store for route history and diagnostics beyond expected / actual delivery times? | A permanent route record is not required by the design. |
| What does WS stand for, and what does AWS stand for? | The wiki uses both for wormhole-related stations; definitions are not confirmed here. |
| What is the minimum relay spacing for useful coverage? | |
| Does the AI Manager coordinate across systems, or is coordination bounded by local autonomy and delayed messages? | |
| How do player messaging and chat behave across the same network? | |
| Are relays and couriers buildable / ownable assets, or primarily institutional infrastructure and services? | |
| What are the exact command and acknowledgment state transitions exposed to the UI? | Delivery, execution, and acknowledgment must remain distinct. |

---

## Related Pages

| Page | Relationship |
|------|--------------|
| [Portals & AWS](../technical/portals_and_aws.md) | Intra-system portal infrastructure and Artificial Wormhole Stations |
| [Natural Wormholes & EM](../technical/natural_wormholes_and_em.md) | Natural wormhole physics, stabilization, and physical inter-system connections |
| [AI Manager](../services/ai_manager.md) | Autonomous operation while commands and information are delayed |
| [Logistics and hauling](../logistics/logistics_and_hauling.md) | Physical carriers and transport availability |
