# Eden Disconnect and Emergent History

**Status**: OPEN  
**Last Updated**: 2026-11-05  
**Related**: [settlement_progression_and_footholds.md](settlement_progression_and_footholds.md), [ai_manager_economic_loops.md](../logistics/ai_manager_economic_loops.md), [portals_and_aws.md](../technical/portals_and_aws.md), existing snap-event and post-snap reconnection material

This page is the wiki home for the state of the Eden system after the Snap / disconnect event. Prior documentation covers the Snap itself and reconnection protocols. This page records the emergent post-isolation outcome space and ties it to the actual wormhole physics that caused the Snap.

**Important timeline constraints**:
- Portal technology is derived from later AWS research. At the time of the Snap, portals do not exist.
- EM harvesting / redirection technology is also a product of AWS research. Eden does **not** possess it during the isolation period.

The state of Eden when players first reach it is **not pre-scripted**. It emerges from the same AI Manager survival loops that run everywhere else, applied under the physical conditions created by the Snap.

---

## Why the Snap Occurs (Physics Ground Truth)

Eden’s natural wormhole (NWH) aperture was never properly mass-anchored. Unlike the Sol side (stabilized by Jupiter-scale mass), Eden lacked an equivalent large mass body at the aperture.

Consequences:
- Chronic instability.
- Continuous ejection of Exotic Matter (EM) into local space while the aperture was still present.
- No mass-limit reset, because the technology to harvest and redirect that EM does not yet exist.
- Incoming and outgoing ship traffic further increases instability by adding mass through the unbalanced aperture.

The Snap is the moment the aperture destabilizes catastrophically and **shifts**. It is no longer present in Eden. The natural connection becomes Sol ↔ System B. Eden is left with no wormhole mouth at all.

The Snap is therefore a physical consequence of the unbalanced aperture + traffic load, not an arbitrary story beat. The exact moment it occurs can vary with traffic history and local conditions; the underlying cause does not.

---

## Isolation Conditions

- No external imports from Sol.
- No LDC bailout capability.
- No portals (technology does not exist yet).
- No EM harvesting (technology does not exist yet).
- No remaining natural wormhole mouth in Eden (the aperture has shifted away).
- Population movement limited to whatever physical transport remains operational inside the system.
- AI Manager survival loops (stockpiles → harvest / export attempts → debt / austerity → population morale) continue to run with external options removed.

Because the same deterministic loops operate under these constraints, different settlements (and different playthroughs) can produce very different results.

---

## Residual EM Field

**DIRECTION / OPEN**

While the Eden-side NWH mouth was still present and unstable, it ejected Exotic Matter into the surrounding region. After the Snap the aperture itself is gone, so there is no further ejection.

What remains is whatever EM concentration was deposited in the local volume **before** the aperture shifted away. That residual field is unharvested (the technology does not exist during isolation) and becomes a strategic asset only after EM harvesting technology — derived from later AWS research — reaches Eden.

Exact field strength, spatial extent, and harvesting difficulty remain OPEN.

---

## Emergent Regional Archetypes

Eden is **not uniform**. Local volatile richness, starting infrastructure quality, and minor variations in AI pragmatism produce a mosaic of outcomes across the system.

### 1. Autarkic Survivors
- Resource-rich sites + disciplined early austerity.
- Human population remains intact (or even grows modestly).
- Habitats stay pressurized and functional.
- Local markets and civic systems continue under isolation rules.
- On reconnection: cautious or opportunistic trade partners; may have local laws, currencies, or cultural distrust of “Sol central planners.”

### 2. Ghost Shells
- Population declined or was concentrated into a smaller number of viable sites using only the physical transport available at the time.
- Secondary or resource-poor habitats were abandoned in an orderly or semi-orderly fashion.
- Automated systems (PVEs, TEUs, fabricators, power) at the abandoned sites continued running on residual programming and local power.
- Physical plant is largely intact and often well-stocked with raw or semi-processed materials.
- On reconnection: high-value, low-resistance reclamation targets. Clear any residual ledger debt and the site can be re-powered and re-colonized.

### 3. Feral / Fragmented Pockets
- Central authority or main AI Manager failed or was rejected.
- Small groups sealed themselves into reinforced subsections or deep lava-tube segments using local bulkheads and whatever life-support they could maintain.
- Survival is low-tech, scavenged, and highly local. No rapid relocation technology existed.
- On reconnection: high-tension first contact. Groups may view incoming Sol/player ships as raiders or hostile corporations. Diplomacy, hacking, or force may be required.

### 4. Silent Tombs
- Cascading life-support or power failure with no successful relocation or concentration of population.
- Habitats are cold, depressurized, and time-frozen.
- Automated systems may be completely dead or in deep safe mode.
- On reconnection: archaeological / salvage sites. Environmental hazards, lost data cores, rare pre-collapse blueprints, and structural components.

Mixed outcomes within a single system are expected and desirable.

---

## Reconnection Sequence

**ESTABLISHED INTENT (owner, 2026-11-05)** — this corrects an earlier draft of this page.

The natural wormhole snapped and is gone, which is why Eden can only be reconnected through an Artificial Wormhole Station (AWS) link. When Sol first opens that link toward Eden:

1. The Sol-side station opens the rift. It is under significant strain supporting the open rift alone.
2. The **tug** and the **EM harvesters** cross over.
3. The tug deploys the **stabilization sats**. The sats capture EM and focus it back into the rift to help stabilize it.
4. The tug and the EM harvesters go to the location where the natural wormhole used to be. The wormhole is gone. All that remains there is the abandoned Wormhole Station (WS) and an EM field.
5. The tug connects to the WS and starts moving it into position.
6. While the WS is being moved, the tug's crew starts early conversion work on it. They convert its storage so the EM harvesters can dock and dump EM into it.
7. The EM harvesters continue to harvest EM in the area.
8. Once the WS is in position, a **cycler** should have arrived carrying the upgrade package. The WS is converted into a full AWS.
9. The EM harvesters dock and stay with the WS, now an AWS. The EM they hold fuels the large-scale stabilization technology.
10. The pair is now a true AWS link, and the strain on the Sol station is relieved.

The owner has deliberately not defined where the natural wormhole appeared in Eden or exactly where the new rift opens. Travel times, such as the tug's trip to the abandoned WS, are calculated in game from the actual positions, so no fixed durations are defined. Durations in other pages (for example `engineering/01_post_snap_reconnection_protocol.md`) were written by agents and are unconfirmed placeholders.

**DIRECTION** (not confirmed since the 2026-11-05 correction):

- No other traffic is allowed during the strain and conversion phase. Only the tug, the EM harvesters, the stabilization sats and the cycler carrying the upgrade package transit.
- General cargo, colonists and unrestricted player traffic become possible only after the Eden-side station is converted and operational.

**OPEN**:

| Question | Notes |
|----------|-------|
| Where does the tug move the WS to? | The owner said "into position" and has left exact positions undefined on purpose (see above). `engineering/01_post_snap_reconnection_protocol.md` describes pre-calculated exit coordinates opposite a large planetary body; not confirmed. |
| What condition is the abandoned WS in, and what does the tug crew's early conversion work involve? | |
| How does the cycler cross during the strain phase? | |
| How do the sats capture and focus EM, and what does stabilization need? | No numbers. |
| Exact power, EM and structural requirements for the strain phase and the conversion | |
| Do stabilization sats stay deployed or get stored after the link is stable? | `01_post_snap_reconnection_protocol.md` stores them; the owner has not said. |

---

## Simulation Levers (for later implementation)

**OPEN** — parameters that can drive the archetypes without hand-authored lore:

- Local resource abundance coefficient (volatile / ice / mineral richness).
- AI pragmatism weight (how quickly the manager cuts amenities and enters hard austerity).
- Abandonment / concentration threshold (life-support buffer percentage that triggers orderly shutdown of secondary habitats).
- Infrastructure decay rate when power or maintenance drops.
- Population loss ratio and residual “feral” fraction if concentration is only partial.
- How long physical intra-system transport remains functional and how that affects concentration vs. abandonment.

These levers let the same code produce autarkic, ghost, feral, or tomb results depending on seed and local conditions. Isolation length itself is a consequence of when Sol develops AWS reconnection capability, not an independent free parameter.

---

## Player Entry and First Contact

**OPEN**

- First-wave players are expected to start in **active, solvent systems** (Sol core, established LDC hubs, or System B extraction frontiers). Dropping directly into an unknown Eden state is high-risk.
- Once logistics and capital are established, player corporations can mount expeditions through the new AWS gate.
- **No other traffic is allowed** until the Eden-side WS is converted and operational. Only the tug, EM harvesters, stabilization sats and the cycler carrying the upgrade package may transit during the strain and conversion phase (DIRECTION).
- Reclamation, salvage, diplomacy with survivor pockets, or pure archaeological recovery become distinct play styles depending on the archetype encountered.
- Ghost shells and tombs leave physical assets intact; the economic and narrative value is in recovery and restart.
- The residual pre-Snap EM field becomes a high-value objective once the harvesters are docked and operating from the new AWS.

---

## Relationship to Broader Systems

- The AI Manager loops described in the economic loops page continue to run during isolation. There is no special “Eden mode” code path required beyond removing external import options and letting the existing state machine operate.
- Portal technology and EM harvesting both appear only after AWS research matures; neither is available during the isolation period itself.
- Any residual Virtual Ledger balances from the pre-Snap era become relevant again the moment the link is restored.

Existing orphaned-system economics and survey/handshake protocol material can be referenced for discovery and re-contact procedures; this page focuses on the internal state that those procedures discover.

---

## Open Questions

- Precise relationship between pre-Snap traffic history and the exact moment of the Snap.
- Spatial extent and intensity of the residual pre-Snap EM field left in Eden.
- Power, EM, and structural requirements for the temporary Sol-side strain phase and the Eden-side WS conversion.
- First-contact protocols, standing modifiers, and possible hostility mechanics for feral pockets.
- Whether pre-Snap LDC or corporate branding / ownership claims survive and how they interact with player reclamation.
- Data and blueprint recovery rules for silent tombs.
- How much physical intra-system transport (ships, cyclers, surface vehicles) remains functional during long isolation and how that affects concentration vs. abandonment outcomes.
- Political and economic consequences when the residual EM field is being actively harvested from the new AWS.

This entire topic remains **OPEN** until the remaining physics and first-contact rules are decided and any remaining storyline notes are reconciled into the wiki.
