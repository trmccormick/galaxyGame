# Portal Technology

**Status:** Design documentation --- not implemented\
**Purpose:** Consolidate established portal design from existing
GalaxyGame documentation and developer clarifications.\
**Authority note:** This draft is based on the portal-context handoff
supplied for the current work. The original primary source, Gemini
brainstorming package, and repository wiki files still need direct
verification before this is treated as canonical.

## 1. Overview

Portal technology provides rapid personnel transportation between
connected settlements within a star system.

A portal connection consists of a paired set of endpoints linking two
specific locations. Multiple portal connections can be combined into a
network, allowing personnel to travel between settlements through
designated hubs.

Portals complement conventional transportation infrastructure. They do
not replace cyclers, local resource production, or the movement of bulk
freight.

This document describes intended design. It does not imply that portal
functionality has been implemented in the codebase.

## 2. Technology and network scope

### 2.1 System-local portal networks

Portal connections operate between locations within the same star
system.

A system may develop multiple portal connections linking settlements
into a larger network. The network can include hubs where travelers
transfer between connections.

"System-local" does not mean "Sol-only." The supplied design allows
other star systems to develop independent, system-local portal networks.

### 2.2 Inter-system transportation

Inter-system travel is documented separately from system-local portal
transportation.

The existing design describes travel between star systems using
spacecraft and Wormhole Station (WS) or Artificial Wormhole Station
(AWS) infrastructure. A destination system may provide access to its
local portal network if one exists.

Gemini proposed a later inter-system portal-gate capability at AWS
stations (sometimes described as Level 4b). This proposal potentially
changes the earlier boundary between system-local portals and
craft-based wormhole travel. It is not treated here as an approved rule.

## 3. Paired endpoints and deployment

Portal connections use matching endpoints.

**Developer clarification:** Portals are generally built together as a
pair. Both endpoints most likely need to be physically transported to
their respective deployment locations.

The current deployment concept is:

1.  Construct the paired endpoints.
2.  Transport the endpoints to their intended locations.
3.  Deploy the endpoints at those locations.
4.  Establish the portal connection.
5.  Make the connection available for transportation.

The exact transportation arrangement remains unresolved. In particular,
existing material available in the handoff does not establish whether: -
both endpoints travel on one mission or separate missions; - each
endpoint requires a dedicated deployment mission; - an endpoint may be
installed at an existing station while the other is delivered to a new
settlement; - deployment activates the connection automatically or
requires another operation.

Do not assume that one endpoint automatically appears at the
destination. Do not turn the likely transport of both endpoints into a
more detailed confirmed procedure without source evidence.

## 4. Portal networks and hubs

Each portal pair provides a specific connection.

A hub can contain multiple portal connections. Travelers may arrive
through one connection and transfer to another to reach a different
settlement.

The supplied primary-source summary says any major settlement can become
a hub if its EM budget permits.

The previously documented Earth/L1, Mercury, Mars, Ceres, Jupiter,
Saturn, and Pluto arrangement is an example of a possible network. It is
not established as mandatory topology. Do not impose a fixed hub list or
hard link cap unless a stronger source establishes it.

Network expansion is constrained by available Exotic Matter (EM).

## 5. Transportation and logistics

Portals primarily provide rapid personnel movement and settlement
access.

Documented player uses include: - visiting and participating in multiple
settlements; - tourism and exploration; - trade coordination; - research
collaboration; - emergency response.

Cyclers and other freight infrastructure continue to transport bulk
cargo, resources, equipment, and terraforming supplies.

Portal technology does not eliminate distance-based bulk transportation
economics or the need for local resource production and infrastructure.
Settlements still require local ISRU and resource networks.

The primary source clearly supports personnel movement and the continued
role of bulk freight. Additional categories such as data or high-value
small cargo appear in Gemini brainstorming and should be marked proposed
unless independently confirmed.

## 6. Exotic Matter and operation

Portal pairs use Exotic Matter harvested from natural wormholes.

The supplied primary-source summary states that operating portal pairs
continuously consume EM. Portal operation and wormhole stabilization
compete for the available EM supply. EM availability limits how many
portal pairs can operate simultaneously.

The available summary does not establish finalized numerical operating
rates or a complete idle, standby, closure, and shutdown model.

Electrical power is recorded as a developer-attributed clarification in
the prior synthesis, but its exact relationship to EM consumption is not
proven by the primary source available here. Preserve that distinction
until the original note is recovered.

## 7. Relationship to wormhole infrastructure

Wormhole Stations (WS) provide access to natural wormhole
transportation.

Artificial Wormhole Stations (AWS) provide artificial wormhole
infrastructure.

The existing transportation model uses spacecraft to travel between star
systems through wormhole infrastructure. Local portal networks can
provide rapid transportation within a destination system.

Portal networks and wormhole transportation therefore serve different
roles in the established design.

## 8. Design status and source qualifications

### Established by the primary-source summary

-   Matching portal pairs connect specific locations within one system.
-   Portals provide instantaneous personnel travel.
-   Portal pairs use EM harvested from natural wormholes.
-   Multiple pairs can form settlement networks.
-   Travelers may transfer between pairs at hubs.
-   EM availability constrains network growth and concurrent operation.
-   Cyclers retain the bulk freight role.
-   Inter-system travel is described separately through spacecraft and
    WS/AWS infrastructure.
-   Other star systems may develop their own system-local portal
    networks.

### Developer-attributed clarifications from prior synthesis

The prior synthesis records, but does not reproduce the original
developer wording, that: - portal operation requires electrical power as
well as EM; - ownership arrangements were partially addressed; - either
endpoint can initiate operation.

These are retained as attributed notes, not independently verified
primary-source rules.

### Proposals not adopted as requirements

Gemini brainstorming included: - inter-system Level 4b gates at AWS
stations; - specific hull, station, or mobile-base mounting
requirements; - airlock vestibules, pressure isolation, sensors,
interlocks, emergency bulkheads, and gas recovery; - detailed cargo/data
transport categories; - precise dimensions, mass, power, EM rates,
throughput, costs, crew, pressure bands, telemetry, and maintenance
values; - a "Three-Link" constraint.

These are not approved requirements merely because they appear in the
brainstorming package or sample JSON. The sample schema claims and
values were not validated against repository schemas.

## 9. Unresolved questions

Record these as open issues; they do not block this initial
documentation:

-   Exact endpoint transportation and installation procedure.
-   Whether endpoints travel together or on separate missions.
-   Whether deployment activates the link or requires another operation.
-   Exact EM consumption and electrical-power requirements.
-   Idle, standby, closure, and shutdown behavior.
-   Ownership and access rules.
-   Endpoint destruction, repair, replacement, and re-pairing.
-   Numerical network capacity and any per-hub hardware limit.
-   Whether inter-system portal gates will be introduced.
-   Whether proposed safety and mounting practices are mandatory or
    recommended.

## 10. Known source inconsistencies and cleanup

-   **Old phase placement:** Portal phase references reflect an outdated
    late-game plan. Do not copy those phase numbers as current
    requirements. Documentation and preplanning are not restricted by
    implementation phase.
-   **Inter-system boundary:** The primary source describes system-local
    portals and craft-based inter-system travel. Gemini's Level 4b gates
    are a potential extension requiring a decision.
-   **Three-Link constraint:** Gemini mentions it, but the
    primary-source summary establishes an EM-limited network, not a hard
    link cap.
-   **EM allocation example:** The source's example starts with six
    operating pairs but then asks whether to add a "6th" or "7th" pair.
    Treat it as illustrative and flag the ordinal inconsistency.
-   **Numerical EM inconsistency:** Gemini material reportedly uses
    `0.0125 kg/hr` in narrative/operational inputs and `12.5 mg/hr` in
    blueprint data, a factor-of-1,000 discrepancy. Omit the rate from
    canonical rules until reconciled.
-   **Terminology:** Replacing "wormhole portal" with "wormhole link"
    was a synthesis recommendation, not a confirmed terminology
    decision.
-   **Authority:** The older intra-system portal document was classified
    as reference/possibly outdated in prior wiki planning. Verify
    current repository authority before merging it.
-   **Implementation:** No portal wiki page creation, confirmed wiki
    edits, or portal code implementation is established by the supplied
    handoff.

## 11. Wiki scope

This page should explain: - portal purpose and system-local scope; -
paired endpoints and deployment at a high level; - network and hub
behavior; - personnel travel versus bulk logistics; - EM operating
constraints; - relationship to WS/AWS and inter-system travel; -
unresolved questions and source qualifications.

It should not: - introduce implementation code; - publish production
blueprint or operational JSON; - treat Gemini sample values as approved
balance; - impose old phase numbers; - establish a mandatory named hub
topology; - resolve inter-system gates without a developer decision; -
claim that portal technology is implemented.

## 12. Next documentation workflow

1.  Verify this proposed target against the current wiki and canonical
    document index.
2.  Read the full primary portal section and Gemini package directly.
3.  Compare source statements with this draft and correct omissions or
    attribution.
4.  Have one reviewer (Qwen or another agent) review the bounded wiki
    proposal.
5.  Populate the correct wiki file(s) in small, sequential tasks.
6.  Preserve open questions and avoid code or unrelated wiki
    restructuring.

**Acceptance criteria:** The wiki accurately distinguishes established
design, developer-attributed clarifications, proposals, conflicts, and
open questions; preserves the portal/cycler/wormhole transport
boundaries; and does not imply implementation or approval of speculative
Gemini details.
