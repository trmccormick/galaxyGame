# Logistics Provider Architecture Intent

**Date:** 2026-03-14
**Status:** Active — foundational architecture
**Author:** Planning Agent (Claude)
**Intended Audience:** All agents, developers

---

## Overview

`Logistics::Provider` is the **operational interface** of a logistics corporation
within the contract system. It bridges the economic/legal identity of an
organization (`Organizations::BaseOrganization`) with the operational capabilities
needed by `Logistics::ContractService` to move resources between settlements.

Every logistics corporation that moves cargo in the game must have a corresponding
`Logistics::Provider` record. The provider record holds the pricing, capabilities,
speed modifiers, and reliability rating that the AI Manager uses when selecting
a provider for a contract.

---

## Two-Layer Model

### Layer 1: Organization (Economic/Legal Entity)
`Organizations::BaseOrganization` — the corporate entity

- Holds GCC and USD accounts
- Participates in the Virtual Ledger (NPC-to-NPC IOU system)
- Owns assets (craft, stations, equipment)
- Issues and receives contracts
- Has operational_data with `is_npc: true` for NPC entities

### Layer 2: Provider (Operational Interface)
`Logistics::Provider` — the logistics capability record

- Defines what transport methods the org can perform
- Holds current pricing (`base_fee_per_kg`)
- Tracks reliability rating (updated by AI Manager over time)
- Linked to its parent organization via `belongs_to :organization`
- Used by `ContractService` to find and assign providers to contracts

### Why Two Layers?
A logistics corporation is both a business entity AND a service provider.
AstroLift has a bank account AND orbital transfer capabilities. Separating these
concerns allows:
- Financial operations to work through the organization layer
- Contract routing to work through the provider layer
- Provider pricing to update independently as infrastructure matures
- Future player-visible provider ratings/reputation without touching financials

---

## Seeded Providers

All three initial logistics corporations are seeded in `db/seeds.rb` and must
have corresponding `Logistics::Provider` records created at seed time.

### AstroLift (ASTROLIFT)
- **Specialization:** Orbital logistics, LEO depot operations
- **Capabilities:** `orbital_transfer`, `surface_conveyance`
- **Initial base_fee_per_kg:** 150.0 GCC (Earth Anchor Price era)
- **Reliability:** 4.8
- **Notes:** Primary provider for Luna deployment. Owns Heavy Lift Transports.
  Co-investor in L1 station/shipyard with LDC.

### Zenith Orbital (ZENITH)
- **Specialization:** Station construction and management
- **Capabilities:** `orbital_transfer`
- **Initial base_fee_per_kg:** 175.0 GCC (premium for station ops)
- **Reliability:** 4.5
- **Notes:** Focuses on orbital construction logistics. Less cargo volume,
  higher precision/reliability requirements.

### Vector Hauling (VECTOR)
- **Specialization:** Interplanetary cargo transport
- **Capabilities:** `orbital_transfer`, `surface_conveyance`, `drone_delivery`
- **Initial base_fee_per_kg:** 120.0 GCC (bulk cargo discount)
- **Reliability:** 4.2
- **Notes:** High volume, interplanetary routes. Lower reliability than AstroLift
  but cheaper for bulk cargo. Key provider for Mars/Titan routes.

---

## Provider Selection Logic

`ContractService.find_provider(transport_method)` selects providers by:
1. Capability match — provider must support the requested transport method
2. Highest reliability rating wins (ties broken by lowest base_fee_per_kg)

Future enhancements (backlog):
- Select by route (Earth-Luna vs Earth-Mars vs interplanetary)
- Factor in current provider workload/availability
- Player-visible provider ratings and competitive bidding

---

## Price Discovery — How base_fee_per_kg Changes Over Time

Provider pricing is NOT static. As infrastructure matures, the AI Manager
should update provider `base_fee_per_kg` to reflect real operational costs.

### Phase 1: Earth Anchor Price Era
All providers priced at EAP-derived rates. Everything shipped from Earth.
- AstroLift: ~150 GCC/kg (LEO depot not yet operational)

### Phase 2: LEO Depot Operational
AstroLift fills LEO depot with Luna-sourced LOX. Earth-departing craft refuel
at LEO. Ships carry more cargo, less fuel per trip.
- AstroLift rate drops: ~100 GCC/kg
- Vector Hauling rate drops: ~80 GCC/kg

### Phase 3: L1 Shipyard Operational (LDC + AstroLift joint venture)
Heavy Lift Transports built locally from Luna materials. No Earth launch costs.
- AstroLift rate drops: ~60 GCC/kg
- All providers benefit from locally-built ships

### Phase 4: Cyclers Established
Earth-Mars Cycler and Gas Giant Cycler provide permanent bulk cargo routes.
- Interplanetary bulk rates drop dramatically: ~20-30 GCC/kg
- Vector Hauling becomes dominant interplanetary provider

### Phase 5: Full Infrastructure Maturity
Multiple DCs operating, full ISRU on Luna/Mars/Titan, shipyards at multiple
locations, cyclers on all major routes.
- Commodity pricing stabilizes at local production cost + small transport margin

---

## Relationship to Virtual Ledger

When GCC reserves are low, NPC-to-NPC contracts can be settled via Virtual
Ledger (negative account balances). The provider still performs the transport
and records the obligation. Settlement occurs when GCC becomes available.

Players CANNOT use Virtual Ledger — they always pay in GCC.

---

## Player Interaction (Act 2+)

When players arrive, providers become visible in the contract board:
- Players can see available courier contracts with provider rates
- Players can undercut provider rates to win cargo contracts
- Provider reliability ratings create market differentiation
- Players earn GCC by performing logistics work

`PlayerContractService` (not yet implemented) will handle player-visible
contract posting. The current NPC fallback path in `ContractService` is the
Act 1 implementation.

---

## Code References

- `app/models/logistics/provider.rb` — Provider model
- `app/models/organizations/base_organization.rb` — Organization model
- `app/services/logistics/contract_service.rb` — Contract creation and provider selection
- `db/seeds.rb` — Organization seeding (provider records added 2026-03-14)
- `spec/factories/logistics_providers.rb` — Test factory
- `docs/architecture/DUAL_ECONOMY_INTENT.md` — Full economic model

---

## Open Questions

1. Should provider `base_fee_per_kg` be updated automatically by AI Manager
   when infrastructure milestones are reached, or manually via admin?
2. Should providers have route-specific pricing (Earth-Luna vs Earth-Mars)?
3. When should Wormhole Transit Consortium get a provider record?
   (Answer: During the Snap Event storyline — not during initial seed)
