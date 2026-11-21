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

**WORKING DESIGN DIRECTION — OWNER EXPECTATION, 2026-11-14**

The physical scale of a natural wormhole may be related to both the power required to sustain it and the amount/rate of mass it can pass. Treat aperture size, available transit power, instantaneous or rate-based throughput, and cumulative per-aperture mass endurance as related but distinct quantities. Do not collapse them into one unexplained mass-limit number or assume a linear relationship before the model is worked out.

The initial Sol–Eden natural connection must have enough practical capacity and endurance to remain usable through the establishment of several Eden settlements and construction of the wormhole station. This is a scenario-level calibration requirement for the emergent history: the connection must support the necessary people, equipment, construction materials, and repeated logistics traffic before the historical Eden Snap occurs. The Snap should still emerge from modeled traffic, stabilization, and wormhole conditions rather than from a fixed narrative timer or a deliberately scheduled event.

The exact aperture dimensions, power requirements, throughput rates, cumulative mass limits, settlement count, construction tonnage, and elapsed time are not yet specified. The initial scenario should be tested against a plausible logistics/buildout load once those requirements and the relevant cargo/structure masses are available.

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

The legacy storyline documents conflict on institutional chronology and membership. They variously describe the WTC as founded by AstroLift, Zenith Orbital, Vector Hauling, MDC, and Eden Development Corporations; as a post-Snap Sol-side rescue coalition led by MDC and Eden DC parent companies; or as a body formed by stranded Eden residents after the Snap. They also describe TerraGen as a post-Snap joint venture between MDC and Eden DCs, despite the owner-confirmed context above that Terragen is an established pre-existing organization whose expertise comes from the Mars and Venus experiments. Additional legacy references—including `docs/architecture/simulation/organizations_system.md`, `docs/mission_profiles/00_complete_profile_library.md`, and `docs/storyline/04_terra_gen_consortium.md`—explicitly label a "TerraGen Terraforming Consortium" as a consortium formed after the Snap. This creates an unresolved identity/naming question: whether those references describe a proposed later coordinating body distinct from the pre-existing owner-confirmed Terragen organization, or are simply an obsolete and conflicting account of the same entity. Do not merge the identities or adopt the post-Snap origin without owner clarification. The 2026-07-20 corporate-logo inventory lists WTC and the Development Corporation/logistics logos but does not list a Terragen/TerraGen logo; that inventory is approximate and is not proof that no such asset exists. The current organization-membership implementation also rejects government organizations as direct consortium members: `ConsortiumMembership#member_must_be_corporation` delegates to `BaseOrganization#corporation?`, which returns true for standard corporations, Development Corporations, and insurance corporations, but not governments. This is compatible with a possible distinction between governmental sponsorship/oversight and direct WTC membership, but it does not establish the intended governance model. The architecture document's wording that only standard corporations qualify is narrower than the actual model predicate and should not be treated as exact implementation behavior. These accounts are retained as historical source material only; they do not override the owner-confirmed organizational context or establish the WTC's exact founding roster or formation sequence.


**Additional legacy network-governance proposals — NOT ESTABLISHED DESIGN**

A further review of the older network and expansion references found proposals for the WTC to own AWS, L1 stations, and depots; fund major construction through member investment and route-proposal votes; distribute transit-fee dividends; and grant voting or board privileges based on capital contribution. A separate network-intent document lists public, private, cooperative, and open-access governance as alternative ownership/regulatory models. A separate legacy voting-engine sketch specifies a 66% quorum and weighted shares for LDC, AstroLift, Mars, Venus, and Titan interests (30/25/25/15/5 respectively). Those weights, stakeholder identities, and voting mechanics are also unconfirmed proposals, not an approved WTC constitution. Other lore/summary documents simplify the founder story to AstroLift plus LDC, adding another variation to the unresolved historical roster. These are source-recorded proposals and alternatives, not confirmed decisions. The active design does not currently establish WTC asset ownership, financing, voting, dividends, fees, regulatory powers, or membership rights.

The same older references variously place Consortium formation immediately after the Snap, describe AWS development as a post-Snap LDC/AstroLift collaboration, and describe TerraGen as a post-Snap Development Corporation consortium. These chronology claims conflict with the owner-confirmed pre-existing Sol organizations and remain unadopted. Older technical documents also contain controlled-Snap/Hammer trigger mechanics and numerical EM, stability, maintenance, and mass values; those are not authority for the historical Eden Snap, whose timing remains an emergent outcome, or for current quantitative design.

**OWNER-CONFIRMED WTC NETWORK ROLE; OWNERSHIP AND COMMERCIAL ARRANGEMENTS OPEN — 2026-11-20**

The WTC is responsible for maintaining and coordinating the artificial-wormhole and portal networks, including AWS, WS, and intra-system portal infrastructure. This network responsibility does **not** establish that the WTC owns those stations, portals, or facilities, nor that it must directly operate every individual facility.

Use the distinction between transport operators and transport infrastructure familiar from aviation and maritime shipping: spacecraft and their player/corporate operators use the network in the way aircraft and ships use airports and seaports; facilities may have separate owners and operators, while a network organization coordinates and maintains shared network services. Multiple independent entities may own portals and other network facilities. An owner may operate its own facility or arrange for another entity to operate it; the WTC's network maintenance role remains distinct from both ownership and local operation.

The WTC's exact maintenance arrangements, service contracts, funding, ownership distribution, access rules, transit charges, revenue flows, and any regulatory authority remain **OPEN**. Do not infer centralized WTC ownership from its network-maintenance responsibility, and do not assign the WTC authority to set fees or funding policy unless separately established.


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

## 4. EM stabilization and per-aperture mass-limit restoration

**OWNER-CONFIRMED DESIGN INTENT — 2026-11-14**

A natural wormhole is one paired occurrence with two connected apertures. The apertures are mechanically independent for mass accumulation and stabilization, but they are not separate, unrelated wormholes. Each side's counterbalance-relevant properties and local conditions affect that side's stability and mass-transfer outcome; the two sides must therefore be evaluated separately rather than treated as physically interchangeable.

- Each aperture maintains its own accumulated mass-transfer usage against its own mass limit.
- Stabilization technology operates independently on each aperture.
- The technology captures EM ejected into local space, contains and directs captured EM back toward the corresponding aperture, and pushes the EM back into that side.
- Successful EM pushback restores/resets the accumulated mass-limit usage for that aperture. It does not reset the other aperture's counter.
- The two apertures remain parts of the same paired wormhole occurrence throughout these independent operations. Counterbalance is also endpoint-sensitive: the relevant mass properties and arrangement on each side influence its own counterbalance state and therefore the side's ability to withstand accumulated transfer. The Sol–Eden asymmetry follows from this distinction: Jupiter's substantial mass provides the Sol-side counterbalance described above, while the less-stable Eden side reaches failure conditions. The Eden aperture snaps; the Sol aperture does not. This is not a single shared pair-wide counterbalance value or a rule that failure must occur symmetrically.

In other words, stabilization is an active EM-return/recovery process, not merely a passive shield that prevents an aperture from shifting after it reaches its limit. The Eden/Sol historical asymmetry is consistent with this model: the Eden aperture was not effectively stabilized when it reached its relevant threshold and shifted/snapped, while the Sol aperture was stabilized and did not undergo the same event.

This creates a feedback loop: transit through each aperture contributes to EM ejection and consumes that side's available mass-limit capacity; EM captured and returned to that aperture restores its capacity and improves its relative stability.

The exact numerical mass limit is **not yet determined**. The equations governing EM production, capture and return efficiency, the exact reset/restore operation, required station/satellite arrangement, buffer capacity, power demand, and operating thresholds also remain OPEN. Do not imply that stabilization makes a natural wormhole permanently stable or invulnerable.

An AWS pair or other counterbalance infrastructure may support stabilization and network operations as described in [Portals & AWS](portals_and_aws.md); detailed placement and performance rules remain OPEN.

## 5. Shifting, snapping, and the Hammer Protocol

A natural exit can shift as part of the natural wormhole lifecycle. A snap is a failure event when accumulated mass throughput reaches the wormhole's modeled limit without adequate counterbalance/stabilization. The historical Eden-side Snap happened before the later EM stabilization technology existed. Its timing is driven by traffic history and modeled conditions, including AI Manager decisions that affect system development; it is not an operator-scheduled event.

**Hammer Protocol — ESTABLISHED STRATEGIC INTENT, 2026-11-13**

Hammer Protocol is part of the human expansion strategy using Sol as the current staging/scouting system. It is broader than simply forcing a snap and should not be described only as a controlled-closure mechanism.

**WORKING DESIGN DIRECTION — OWNER-PROPOSED LIKELY FRONTIER-EXPANSION CYCLE, 2026-11-20**

The intended repeating pattern is:

1. A natural wormhole may shift through its lifecycle, potentially in response to reaching a mass limit, or through deliberate use of the Hammer Protocol. A shift changes the exit/connection; it is distinct from an uncontrolled snap. **Reconciliation required:** this proposed mass-limit-driven shift needs to be compared with the current physics statement above that an unstabilized aperture reaching its limit snaps. Determine whether the modeled outcome depends on stabilization/state, whether the shift and snap are separate thresholds, or whether the earlier wording needs correction.
2. The AI Manager identifies the newly available survey opportunity and announces survey missions to players.
3. Players explore the newly accessible system and return survey information about celestial bodies, resources, EM, and terraforming/settlement targets. The AI Manager evaluates whether the system is a strategically valuable “prize system”; discovery alone does not guarantee that it is.
4. If the system is valuable, the AI Manager determines the best location for the required AWS infrastructure. Depending on the geometry and network plan, it may call for one station or two stations in the new system. Exact placement and pairing rules remain subject to the AWS design.
5. The AI Manager can build/coordinate that infrastructure while the natural wormhole remains active, using the temporary natural connection for construction and deployment logistics.
6. Once the frontier AWS endpoint is ready, an active Sol-side AWS route serving another system can be disconnected and reassigned to the new station, connecting Sol to the prize system through the artificial network. The displaced route can then be retargeted elsewhere, allowing the existing network to be reorganized rather than merely accumulating fixed links.
7. With the prize system now connected through the artificial network, operators use the Hammer Protocol to force the natural exit to shift to a new location. That creates the next survey opportunity and begins the cycle again.

This proposed pattern uses natural wormholes as temporary discovery and construction access, while the artificial network carries the durable logistics connection to Sol. It links frontier resources and settlement opportunities to Sol's mature industrial capacity. The AI Manager's decisions should weigh survey evidence, resource and terraforming value, construction cost, route priorities, and the consequences of leaving or shifting the natural connection.

The AI Manager may still choose to harvest, stabilize, or continue using a natural connection rather than immediately integrate every discovered system. This is a strategic expansion pattern, not a rule that every shift reveals a prize system or every survey results in AWS construction. Do not conflate a deliberate Hammer Protocol shift with an uncontrolled snap.

## 6. Known and unknown systems

A system discovered through an open natural wormhole and surveyed under the Hammer Protocol is known to the operators and has a harvestable EM field under the current design.

Unvisited systems in the local bubble remain unknown. Do not assume that they have a known, accessible, or harvestable EM field before discovery and survey. Do not assign resource or EM knowledge to a system merely because it is nearby in astronomical space.

### Active-system lifecycle and JSON archival

**OWNER-CONFIRMED DESIGN INTENT — 2026-10-31; clarified 2026-11-20.** A system's continued existence as retained game data does not require it to remain loaded and processed continuously.

- A system with an active player presence or an active connection through the AWS network or a live natural wormhole remains active in the database/simulation. A natural wormhole kept open by stabilization satellites therefore maintains an active access path for ongoing harvesting.
- When there is no active player presence and no active artificial-network or live natural-wormhole connection, the system can be exported to JSON and unloaded from the active database/simulation. An explored but unsettled system whose natural exit has been shifted away is a representative case.
- The JSON export preserves the system's current state and relevant information to the practical extent possible. This avoids continuing to process an inaccessible system while retaining its state for future use.
- If a route is later established or the system is selected for settlement, the archived JSON can be reloaded into the database and active simulation resumed. Restoring the system record is distinct from creating the wormhole connection that makes it reachable.

The export/unload and reload workflow is an intended Admin/dashboard performance capability and is not yet fully implemented. Exact serialization coverage, trigger conditions, consistency checks, and restoration behavior remain open for code review.



### Networked discoveries, preservation, and assessment

**OWNER-CONFIRMED STRATEGIC DESIGN DIRECTION — 2026-11-20**

Natural wormhole generation and system generation are separate capabilities. A natural wormhole pair does not inherently create a new star system, and a destination need not be newly generated:

- A natural connection may lead to a previously scouted system that is currently archived/inactive; that system should be reloaded from its retained JSON state rather than generated again.
- It may lead to another already-known system, including one in the local bubble. The discovery is the connection, not the system itself.
- It may lead from an accessible/known system to a genuinely unknown system, creating a new survey opportunity.
- Natural wormhole pairs are not inherently Sol-originating; they may occur elsewhere in the galaxy. However, generating a pair between two completely unknown, isolated systems has no immediate operational or simulation value if neither endpoint can be reached by players or the AI Manager. Natural-pair generation for active gameplay should provide at least one reachable endpoint, or otherwise have a defined path by which the pair becomes reachable.

Natural-wormhole exploration can also act as the entry point for on-demand frontier generation. When a connection leads to a genuinely unknown destination, that discovery may trigger StarSim to create a new system as a fresh survey, exploration, and harvesting opportunity. If the destination is already known but archived, restore its retained JSON state instead; do not generate a replacement. Thus wormhole discovery, system generation, and system reactivation are separate operations.

This approach can keep exploration supplied with new destinations without requiring a permanently huge active galaxy. Systems with no active player presence or live network access can be archived with their state retained, while newly revealed frontiers can be generated when needed. The active simulation population can therefore remain smaller than the total set of systems encountered or retained over the life of the game. This is not a commitment to infinite generation or to generating a new system for every natural wormhole; known destinations and new destinations are both valid outcomes.

A system may contain or be associated with multiple active natural wormhole connections. Each active natural-wormhole aperture is a distinct local EM harvesting opportunity. Thus, a system with two active natural wormholes can have two separate aperture locations from which EM is ejected and harvested. The value of a system can include its own resources, its position in the network, access to further systems, and the EM production opportunities at each active aperture.

**Preserve first, assess second — OWNER-CONFIRMED OPERATIONAL DIRECTION, 2026-11-20**

When a newly discovered natural connection may be valuable, the AI Manager need not immediately commit to permanent stations or decide to abandon it. A useful initial response is to stabilize and assess:

1. Deploy stabilization satellites at both apertures as an early preservation measure, so the connection is less likely to shift while players and scouting craft are operating through it. This is an initial protective deployment, not a decision to build permanent stations at both ends.
2. Send players on scouting missions to inspect both sides and gather the information needed to compare relative stability, local conditions, and counterbalance opportunities.
3. Apply the counterbalance rules to determine which side is the better location for permanent station infrastructure. The intended strategy may be to build a Wormhole Station (WS) on the more suitable/stable side, then build an AWS there to connect that system to the main artificial network.
4. Retain the stabilized natural connection after the AWS link is established when it remains valuable. The AWS provides access to the main network while the natural route remains available as a gateway for additional scouting into the next system.
5. Continue harvesting and evaluating EM at each active aperture. Players may potentially harvest excess EM for sale on the market, but EM needed for stabilization, restoration, reserves, and planned infrastructure must be accounted for before treating any captured amount as surplus.

This is an example strategy, not a mandatory construction sequence for every natural wormhole. Stabilize-and-assess can be the best decision when information is incomplete: it preserves options and buys time to gather evidence before a larger investment or an irreversible network decision.

### AI Manager choices, learning, and escalation

AI Manager should weigh the long-term value and cost of preserving each natural connection. Relevant considerations include exploration access and the value of systems beyond the connection; existing and potential AWS network routes; relative stability and counterbalance; aperture mass throughput and remaining capacity; EM ejection, capture, return, storage, and surplus; possible player market income from surplus EM; stabilization and station construction/operating costs; logistics and player safety; and competing network or settlement priorities.

Available strategic responses include:
- **Stabilize and assess:** preserve both apertures while players gather information and the AI Manager improves its assessment.
- **Retain and operate:** continue using a natural route for exploration, harvesting, settlement logistics, or access to further systems.
- **Integrate and retain:** connect a gateway system to the main network through AWS while keeping the natural connection stabilized for further scouting.
- **Harvest surplus:** make EM genuinely surplus to stabilization and operational requirements available for player harvesting and potential market sale.
- **Shift deliberately:** use the Hammer Protocol when the current connection no longer justifies retention or a better frontier opportunity warrants moving the natural exit.
- **Allow natural degradation or failure:** remove stabilization when continued access is no longer worthwhile, with the resulting behavior governed by the physical model. A deliberate Hammer shift, natural shift, and uncontrolled snap must remain distinct outcomes.

AI Manager should not assume that the highest immediate EM sale value or fastest AWS expansion is always the best choice. It should compare short-term income with the option value of preserving a route, future scouting access, multiple EM harvesting sites, and the risk/cost of losing the connection.

When the situation is unfamiliar, evidence conflicts, the consequences are unusually large, or the AI Manager cannot confidently determine an appropriate next action, it should be able to request Admin guidance rather than invent certainty. An escalation should present the observed state, relevant evidence and uncertainty, available options, likely consequences/costs, and the AI Manager's provisional recommendation. Admin guidance and subsequent outcomes should be retained as learning/training evidence so the AI Manager can handle similar situations more independently later. This is intended behavior; the confidence model, escalation thresholds, decision-record schema, and learning implementation remain OPEN.

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
- When an endpoint is not marked stabilized and its transferred-mass counter reaches the mass limit, the model randomizes that endpoint's coordinates and resets that endpoint's counter. A stabilized endpoint does not shift or reset through this path. This is the current code path, not the complete intended stabilization mechanic: the inspected model has no EM pushback process that independently restores the stabilized aperture's accumulated mass-limit usage.
- The model can find deployed craft named `Wormhole Stabilization Satellite` near either endpoint and combines these with directly assigned stabilizers when checking operational stabilizer count.
- The model specs exercise associations, validation, endpoint creation, stabilizer lookup, travel gating, and endpoint shifting/reset. Some tests stub travel-safety or satellite behavior; these tests do not validate wormhole physics.

**Important gaps against established intent**

The inspected `Wormhole` model does not currently calculate a time-dependent or historical cumulative mass-throughput/stabilization-deficit process. It does not calculate EM ejection, local EM fields, capture/harvesting, storage, EM return, or the owner-confirmed per-aperture mass-limit restoration resulting from returned EM. The model's two directional counters and stabilized flags represent part of the intended data shape, but do not implement the full independent EM recovery loop for each aperture within one paired occurrence. It does not calculate gravitational counterbalance from Jupiter or other bodies, and it does not connect AI Manager decisions to the Eden Snap's physical timing/outcome. The current endpoint-shift implementation is not, by itself, the full historical Eden Snap.

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

- Numerical aperture size, sustaining-power requirements, and the relationship between aperture scale/power and mass throughput.
- Exact counterbalance calculations for each endpoint, including which local mass properties and geometric arrangements contribute and how they affect the side-specific mass limit/stability outcome.
- The numerical cumulative mass-limit value for each aperture, its units, and the quantitative accumulation/EM-restoration rules. The conceptual rule is established: EM pushback resets the accumulated usage for the aperture receiving it, independently of the paired aperture.
- The initial Sol–Eden connection's required logistics endurance: enough aggregate throughput for several Eden settlements and construction of the wormhole station before the emergent historical Snap. Exact settlement count, cargo/build tonnage, and time window are not yet specified.
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
