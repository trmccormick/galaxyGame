# Natural Wormholes & Exotic Matter (EM)

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-14  
> *Audit Summary:* Owner design intent reviewed against the current `Wormhole` model, related discovery/expansion/consortium services, migration, and model specs. Existing code contains basic per-endpoint mass-limit, stability, traversal, and endpoint-shift mechanics, but does not implement the full natural-wormhole/EM/Snap model described here.

**Status:** DIRECTION / OPEN  
**Last Updated:** 2026-11-14  
**Related:** [Portals & AWS](portals_and_aws.md), [Sol System Reference](../astronomy/sol_system_reference.md), [Eden disconnect and emergent history](../player/eden_disconnect_and_emergent_history.md)

This page is the wiki home for natural wormhole behavior, relative stability, mass throughput and limits, EM ejection and harvesting, EM stabilization, shifting/snapping, and the Hammer Protocol.

## 1. Natural wormholes are not permanently stable

**ESTABLISHED DESIGN INTENT — 2026-11-13**

No natural wormhole should be described as simply “stable” or permanently safe. Natural wormholes have different degrees of relative stability, and all remain subject to mass throughput, EM ejection, changing conditions, and the possibility of a shift or snap unless the scenario or available technology changes that outcome.

- A comparatively more stable wormhole still ejects some excess EM into local space.
- A less stable or increasingly stressed wormhole ejects much larger amounts of EM.
- The amount of mass pushed through contributes to the EM ejected; greater mass throughput produces greater ejection.
- As a wormhole approaches its mass limit, ejection and instability increase.
- Without suitable stabilization technology and an effective counterbalance, reaching the mass limit causes it to snap.
- A shift changes the natural exit/connection. A snap is the failure event described in the historical Eden case. Do not use “shift” and “snap” as interchangeable terms without regard to the event being described.

Exact physical equations, mass thresholds, stability curves, yields, and time windows remain OPEN.

## 2. Sol's natural wormhole and the Eden historical event

**ESTABLISHED SCENARIO INTENT — 2026-11-13**

Sol's natural wormhole is located at the Jupiter–Sun L3 point, 180° opposite Jupiter. Jupiter's mass provides the significant gravitational counterbalance that makes the Sol-side mouth comparatively more stable. This does not make the wormhole intrinsically or permanently stable, and it still has natural EM ejection and mass-throughput behavior.

For the current human-expansion gameplay scenario, Sol's natural wormhole remains present and does not shift or snap. The narrative is also currently planned around Sol's wormhole continuing to exist. This is a scenario/narrative treatment, not a permanent limitation on the underlying simulation: future scenarios or design changes may allow different outcomes. Keep the special treatment configurable or otherwise separable from general natural-wormhole mechanics.

The Eden-side wormhole was less stable and snapped before EM stabilization technology was developed. The Snap occurs because too much mass is sent through the natural connection over time without the required stabilization technology. It is an emergent physical consequence of accumulated traffic and the wormhole's modeled state, not a scheduled or deliberately triggered milestone. The exact timing and resulting Eden state depend on the AI Manager's activity and decisions as it develops the system. The underlying mechanism, thresholds, and outcome must be produced by the wormhole model and the relevant simulation code, not by a fixed narrative timer.

The Snap becomes the catalyst for Sol corporations and the AI Manager to pursue wormhole research more aggressively. That research ultimately develops artificial wormhole technology, enabling a new artificial connection from Sol to the already-established settlements in Eden. The later opening of that artificial connection is separate from the Snap itself and is the point after which player access can begin. See [Eden Disconnect and Emergent History](../player/eden_disconnect_and_emergent_history.md) and [Portals & AWS](portals_and_aws.md).

### Sol organizations and the origins of the WTC

**OWNER-CONFIRMED ORGANIZATIONAL CONTEXT — 2026-11-14**

The Wormhole Transit Consortium (WTC) grows out of cooperation among established Sol organizations; it should not be described as an institution created from nothing after the Eden Snap. Its participants include established logistics/infrastructure corporations and the pre-existing Terragen terraforming organization. Terragen's expertise comes from the Mars and Venus terraforming experiments and is already established by the time the natural Sol–Eden wormhole opens.

The organizational roles already confirmed are:

- **LDC — Lunar Development Corporation:** the founding Development Corporation. LDC sponsors the other Development Corporations and also serves as the GCC mint.
- **Terragen:** an established terraforming organization, not to be relabeled as a corporation or treated as a post-Snap creation. It brings the experience and technology developed through the Mars and Venus terraforming experiments.
- **AstroLift, Zenith Orbital, and Vector Hauling:** established logistics corporations whose transportation and network expertise are relevant to the WTC's inter-system infrastructure.
- **Other Development Corporations:** participate in the broader development/corporate collaboration; LDC's role as their founding sponsor must be preserved.

This records confirmed identities and roles without assuming that every organization listed in older source material was a formally named WTC founding member at the same moment. The exact legal founding roster, governance arrangements, and formation sequence remain OPEN.

Earth-based representatives are also likely to be part of the broader WTC coalition, given the sponsorship and technology-support roles expected from Earth-side organizations. Their specific organizations, contributions, and formal membership status have not yet been identified, so this remains a likely participation context rather than a confirmed founding roster.

**Development Corporation sponsorship and Earth-side logistics context — OWNER-CONFIRMED, 2026-11-14**

Development Corporations are **non-profit corporations sponsored by Earth-side governments and their partners** to pursue strategic development objectives, such as establishing a lunar settlement or base. For example, the United States and partner governments may sponsor a lunar development effort because they want a sustained settlement or operational base on the Moon. LDC is the founding Development Corporation and sponsors the other Development Corporations.

Keep this sponsorship model distinct from the logistics companies' role. **AstroLift, Zenith Orbital, and Vector Hauling are established Earth-based logistics companies** that provide initial equipment and logistical support for the LDC lunar base. The older consortium framework describes logistics firms more broadly as contributing transportation, ship operations, and network-management expertise, while Development Corporations contribute construction capabilities. These are complementary roles, not interchangeable organization types.

Earth-based governmental participation, potentially including coordination through the United Nations, is a likely oversight context for some WTC activities, but the exact authority and institutional arrangement have not been defined. Do not treat UN governance or a specific government roster as settled.

**Legacy source harvest — role details and unresolved conflicts, 2026-11-14**

The reviewed legacy consortium framework adds the following useful role-level context: logistics corporations bring transportation, ship-operation, and network-management expertise; Development Corporations bring construction capabilities; and LDC was described as having mature large-scale space-construction experience relevant to network infrastructure. The broad division of capabilities is retained here, while specific WTC asset ownership, voting rights, dividends, transit-fee economics, and formal member privileges are not adopted as established design.

The legacy storyline documents conflict on institutional chronology and membership. They variously describe the WTC as founded by AstroLift, Zenith Orbital, Vector Hauling, MDC, and Eden Development Corporations; as a post-Snap Sol-side rescue coalition led by MDC and Eden DC parent companies; or as a body formed by stranded Eden residents after the Snap. They also describe TerraGen as a post-Snap joint venture between MDC and Eden DCs, despite the owner-confirmed context above that Terragen is an established pre-existing organization whose expertise comes from the Mars and Venus experiments. Additional legacy references—including `docs/architecture/simulation/organizations_system.md`, `docs/mission_profiles/00_complete_profile_library.md`, and `docs/storyline/04_terra_gen_consortium.md`—explicitly label a "TerraGen Terraforming Consortium" as a consortium formed after the Snap. This creates an unresolved identity/naming question: whether those references describe a proposed later coordinating body distinct from the pre-existing owner-confirmed Terragen organization, or are simply an obsolete and conflicting account of the same entity. Do not merge the identities or adopt the post-Snap origin without owner clarification. The 2026-07-20 corporate-logo inventory lists WTC and the Development Corporation/logistics logos but does not list a Terragen/TerraGen logo; that inventory is approximate and is not proof that no such asset exists. These accounts are retained as historical source material only; they do not override the owner-confirmed organizational context or establish the WTC's exact founding roster or formation sequence.


**Additional legacy network-governance proposals — NOT ESTABLISHED DESIGN**

A further review of the older network and expansion references found proposals for the WTC to own AWS, L1 stations, and depots; fund major construction through member investment and route-proposal votes; distribute transit-fee dividends; and grant voting or board privileges based on capital contribution. A separate network-intent document lists public, private, cooperative, and open-access governance as alternative ownership/regulatory models. A separate legacy voting-engine sketch specifies a 66% quorum and weighted shares for LDC, AstroLift, Mars, Venus, and Titan interests (30/25/25/15/5 respectively). Those weights, stakeholder identities, and voting mechanics are also unconfirmed proposals, not an approved WTC constitution. Other lore/summary documents simplify the founder story to AstroLift plus LDC, adding another variation to the unresolved historical roster. These are source-recorded proposals and alternatives, not confirmed decisions. The active design does not currently establish WTC asset ownership, financing, voting, dividends, fees, regulatory powers, or membership rights.

The same older references variously place Consortium formation immediately after the Snap, describe AWS development as a post-Snap LDC/AstroLift collaboration, and describe TerraGen as a post-Snap Development Corporation consortium. These chronology claims conflict with the owner-confirmed pre-existing Sol organizations and remain unadopted. Older technical documents also contain controlled-Snap/Hammer trigger mechanics and numerical EM, stability, maintenance, and mass values; those are not authority for the historical Eden Snap, whose timing remains an emergent outcome, or for current quantitative design.


The Snap and the resulting Sol-side research response are covered in [Eden Disconnect and Emergent History](../player/eden_disconnect_and_emergent_history.md). The WTC's artificial-wormhole technology, inter-system network role, and derived intra-system portal technology are covered in [Portals & AWS](portals_and_aws.md). The Snap is the catalyst for the later research and network development; it does not create the participating organizations or Terragen's pre-existing capabilities.

## 3. EM ejection and harvesting

Natural wormholes produce excess EM in local space through their behavior:
- A comparatively more stable natural wormhole produces a smaller amount of excess EM.
- An unstable or heavily stressed wormhole ejects much more EM.
- Greater mass pushed through increases the amount of EM ejected.
- Ejected EM can be captured by suitable harvesting/containment equipment; ordinary mining equipment should not be assumed sufficient.

Distinguish the following quantities in simulation and AI Manager displays:
1. **EM ejected/locally available** — released by the wormhole.
2. **EM captured/harvested** — actually collected by equipment.
3. **EM stored** — captured EM retained in usable reserves.
4. **EM returned for stabilization** — captured EM directed back toward the wormhole.
5. **EM consumed elsewhere** — used by AWS, portals, and other supported systems.

These quantities are related but not interchangeable. Exact yield curves, capture efficiency, losses, storage limits, and units remain OPEN.

## 4. EM stabilization and mass-limit restoration

**ESTABLISHED DESIGN INTENT — 2026-11-13**

EM stabilization technology is developed after the Eden-side snap. The technology:
1. captures EM ejected into local space;
2. contains and directs captured EM back toward the wormhole;
3. counteracts the destabilizing effects associated with mass throughput;
4. restores/resets available mass-limit capacity; and
5. improves the wormhole's relative stability.

This creates a feedback loop: mass transit contributes to EM ejection; stabilization infrastructure captures that EM and returns it to the wormhole to restore capacity and improve stability.

The exact mechanism, required station/satellite arrangement, efficiency, buffer capacity, power demand, and operating thresholds remain OPEN. Do not imply that stabilization makes a natural wormhole permanently stable or invulnerable.

An AWS pair or other counterbalance infrastructure may support stabilization and network operations as described in [Portals & AWS](portals_and_aws.md); detailed placement and performance rules remain OPEN.

## 5. Shifting, snapping, and the Hammer Protocol

A natural exit can shift as part of the natural wormhole lifecycle. A snap is a failure event when accumulated mass throughput reaches the wormhole's modeled limit without adequate counterbalance/stabilization. The historical Eden-side Snap happened before the later EM stabilization technology existed. Its timing is driven by traffic history and modeled conditions, including AI Manager decisions that affect system development; it is not an operator-scheduled event.

**Hammer Protocol — ESTABLISHED STRATEGIC INTENT, 2026-11-13**

Hammer Protocol is part of the human expansion strategy using Sol as the current staging/scouting system. It is broader than simply forcing a snap and should not be described only as a controlled-closure mechanism.

The strategic workflow is:
1. Use Sol as the staging point for opening/exploiting a natural wormhole to a candidate system.
2. Survey the newly accessible system: its celestial bodies, EM field, resources, and settlement potential.
3. Treat a system discovered through this natural-wormhole scouting process as having a harvestable EM field.
4. Harvest EM and other available resources while the natural connection remains open, subject to capacity, logistics, and risk.
5. Decide whether to continue harvesting, invest in stabilization, establish an AWS connection, plan settlement, or complete the harvesting opportunity and hammer the natural exit to force a shift and begin scouting elsewhere.

Discovery does not automatically require an AWS pair or settlement. The AI Manager may use the natural connection while it remains open and defer the AWS decision.

If the system is selected for settlement or continuing network integration, the likely strategy is to build an AWS pair while the natural wormhole is still open. This creates a Sol connection and a logistics corridor for people, equipment, construction materials, and supplies. The connection can use a stabilized natural wormhole or an artificial connection as appropriate. Whether and when a connection is later moved is a strategic network decision, not an automatic consequence of discovery.

The Hammer Protocol may include a deliberate final mass transit to force a natural exit to shift when the system is to be abandoned. This is a strategic option, not a mandatory step for every discovered system. Do not conflate the deliberate hammer/shift operation with an uncontrolled snap.

## 6. Known and unknown systems

A system discovered through an open natural wormhole and surveyed under the Hammer Protocol is known to the operators and has a harvestable EM field under the current design.

Unvisited systems in the local bubble remain unknown. Do not assume that they have a known, accessible, or harvestable EM field before discovery and survey. Do not assign resource or EM knowledge to a system merely because it is nearby in astronomical space.

## 7. AI Manager responsibilities

AI Manager must monitor:
- natural wormhole relative stability and current state;
- mass throughput and remaining mass-limit capacity;
- EM ejection rate and locally available EM;
- harvesting/capture rate and captured reserves;
- EM returned for stabilization and stabilization effectiveness;
- EM consumption and projected reserves;
- candidate system resource/settlement value;
- AWS construction and operating cost;
- transit time, fuel, construction logistics, and supply access;
- the consequences of continuing, stabilizing, integrating, or leaving a system.

Its objective is to balance sustainable expansion, resource access, network value, and the risk/cost of losing a natural connection. It should not simply maximize the number of connected or occupied systems.

## 8. Current implementation snapshot

**SOURCE INSPECTION — 2026-11-14; NOT PHYSICAL VALIDATION**

The following observations are from the current application source. They describe existing code, not confirmation that the model matches the established design intent.

- `Wormhole` stores two connected solar systems, a `natural` flag, a stability enum, a mass limit, separate `mass_transferred_a` / `mass_transferred_b` counters, and per-endpoint stabilized flags.
- Traversal is allowed only when the wormhole is marked stable, is traversable, has the configured minimum number of operational stabilizers, and the requested transit mass fits within the remaining counter for that endpoint.
- When an endpoint is not marked stabilized and its transferred-mass counter reaches the mass limit, the model randomizes that endpoint's coordinates and resets that endpoint's counter. A stabilized endpoint does not shift or reset through this path.
- The model can find deployed craft named `Wormhole Stabilization Satellite` near either endpoint and combines these with directly assigned stabilizers when checking operational stabilizer count.
- The model specs exercise associations, validation, endpoint creation, stabilizer lookup, travel gating, and endpoint shifting/reset. Some tests stub travel-safety or satellite behavior; these tests do not validate wormhole physics.

**Important gaps against established intent**

The inspected `Wormhole` model does not currently calculate a time-dependent or historical cumulative mass-throughput/stabilization-deficit process. It does not calculate EM ejection, local EM fields, capture/harvesting, storage, EM return, or mass-limit restoration from returned EM. It does not calculate gravitational counterbalance from Jupiter or other bodies, and it does not connect AI Manager decisions to the Eden Snap's physical timing/outcome. The current endpoint-shift implementation is not, by itself, the full historical Eden Snap.

Related source paths inspected:
- `galaxy_game/app/models/wormhole.rb`
- `galaxy_game/app/services/ai_manager/wormhole_coordinator.rb`
- `galaxy_game/app/services/ai_manager/wormhole_scouting_service.rb`
- `galaxy_game/app/services/wormhole_expansion_service.rb`
- `galaxy_game/app/services/star_sim/wormholes/discovery_service.rb`
- `galaxy_game/spec/models/wormhole_spec.rb`
- `galaxy_game/db/migrate/20250127144534_create_wormholes.rb`

This is a focused source snapshot, not a complete audit of every wormhole-related class, job, seed, or integration. The broader physical model and AI Manager integration still require a dedicated implementation review and tuning. Do not treat the current endpoint-shift behavior or passing model specs as evidence that the historical Snap model is implemented or scientifically validated.

## 9. Open questions

- Exact mass-threshold units, accumulation window, and reset behavior.
- Quantitative relation between mass throughput and EM ejection.
- Relative stability calculation and the influence of mass placement/orbital geometry.
- EM capture efficiency, storage/buffer limits, return efficiency, and stabilization power demand.
- Exact physical distinction and transition rules between a shift and a snap.
- How a deliberate Hammer operation forces a shift and what happens to transit, harvesters, and equipment.
- Which natural connections can be stabilized, and how AWS pairing/counterbalance affects them.
- Ownership, licensing, and player access to EM harvesting.
- Exact AWS construction, commissioning, and relocation sequence.
- How AI Manager scores survey, harvesting, stabilization, AWS investment, and settlement opportunities.
- How the wormhole simulation represents cumulative mass throughput, stabilization deficit, and the conditions that cause the historical Eden Snap; exact equations and thresholds remain OPEN.
- Which AI Manager actions and Sol corporate research/operations influence the timing and modeled consequences of the Snap.

All numerical values and unverified implementation details remain OPEN.
