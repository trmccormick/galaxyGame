# Galaxy Game Courier Network Implementation Plan

## Overview
This document outlines the tasks for implementing the "Courier Network" data transmission system in Galaxy Game. The system enables asynchronous, ship-based data propagation between systems, with integrity via HashChain and ACK confirmations. Missions will leverage this for player engagement.

## Data Flow Architecture
The system functions as a distributed, eventual-consistency ledger where ships act as the physical transport layer for data packets.

**Storage Strategy**: Utilize existing `BaseCraft#operational_data` JSONB (GIN indexed) for storing courier manifests without schema changes. Structure:
```
BaseCraft#operational_data (existing JSONB)
├── manifests: [
|   {
|     manifest_id: "uuid",
|     prev_hash: "sha256",
|     payload: {market_prices: {...}},
|     idempotency_key: "unique-per-delivery",
|     destination_station_id: 123
|   }
| ]
├── ack_receipts: [...]  ← Return trip payloads
└── data_transit_state: {next_hop: "wormhole_42", eta: "2026-03-15"}
```

**Key Implementation Logic**:
- **HashChain (Integrity)**: Every Manifest record must store a `prev_hash` column. When a new manifest is created, the system calculates SHA256(current_payload + prev_hash). This ensures that even if a ship's database is partially corrupted or tampered with, the chain break is immediately detectable upon arrival at a station.
- **ACK Confirmation (Loop Closure)**: 
  1. Station A generates a Manifest with a unique ID and hash.
  2. Ship carries the Manifest.
  3. Station B validates the hash. If valid, it generates an AckReceipt (containing the original ManifestID + a station-signed confirmation_hash).
  4. Ship returns the AckReceipt to Station A.
  5. Station A marks the manifest as Confirmed. This is your "Documentation Mandate" in action.

**Strategic Adjustments**:
- **Idempotency Keys**: For every network broadcast, ensure the Ship includes an `idempotency_key` in its `data_payloads`. This prevents the "double-processing" bug where a ship might accidentally deliver the same manifest to the same station twice.
- **Versioning for Stale Data**: Since this is asynchronous, you will receive data out of order. Add a `version_timestamp` or `sequence_number` to every Manifest. If a station receives a manifest with a sequence_number lower than its current record, the station should ignore the update (but perhaps still process the ACK if it's a later, higher-level confirmation).
- **Taint Propagation**: If a manifest fails hash validation, the system should recursively flag all subsequent manifests in that chain as "Tainted." This creates a "blast radius" for spoofing, making it much harder for traitors to inject "just one" fake data point.

## Core Components
- **Manifest Model**: JSON-based documentation_manifest with HashChain for integrity.
- **Station Relay Logic**: AWS stations broadcast data to passing ships.
- **Ship Data Storage**: Ships carry manifests and ACKs.
- **ACK Confirmation Loop**: Receipts carried back to origins.
- **Spoofing Detection**: HashChain validation and reputation penalties.
- **EM Leakage Mechanics**: Temporary energy harvesting during shifts.

## Task Breakdown

### Phase 1: Core Data Models and Logic (Foundation)
1. **Create Manifest Model**
   - Add `Manifest` model (new table) with fields: `sequence_number`, `version_timestamp`, `prev_hash`, `hash_chain`, `payload` (JSONB), `idempotency_key`, `origin_station_id`, `destination_station_id`, `status` (enum: pending, transmitted, confirmed, tainted).
   - Implement HashChain generation: SHA256(current_payload + prev_hash) for integrity.
   - Validation: Ensure sequence numbers prevent stale data overwrites; handle taint propagation for broken chains.

2. **Implement Station Relay Broadcasting**
   - Update `AwsStation` model with `broadcast_range` and `data_buffer`.
   - Add method `broadcast_to_craft(craft)`: Transmit latest manifests to crafts within range (simulate via transit events).
   - Trigger on craft transit through wormhole.

3. **BaseCraft Data Handling**
   - Utilize existing `BaseCraft#operational_data` JSONB (GIN indexed) for storage.
   - Create `BaseCraftService` (new PORO): `store_manifest(craft, manifest)`, `validate_idempotency(craft, key)`, `clear_delivered_payloads(craft)`.
   - Structure: manifests array, ack_receipts array, data_transit_state hash.

### Phase 2: Confirmation and Integrity (Security)
4. **ACK Confirmation System**
   - Create `AckReceipt` model: `manifest_id`, `confirmation_hash`, `carrier_ship_id`.
   - On delivery: Station generates ACK, ships carry back.
   - Origin station verifies ACK and updates manifest status to `confirmed`.

5. **HashChain Validation**
   - Add `ManifestVerifier` service class.
   - Methods: `validate_chain(manifests)`, `detect_spoofing(hash_chain)`.
   - On receipt: Check for broken chains; flag tainted data.

6. **Spoofing Mechanics and Penalties**
   - Add `reputation` field to `Player`/`Corporation` model.
   - On spoof detection: Deduct reputation, log incident.
   - Allow "Key Heist" missions: Temporary access to station keys for forging.

### Phase 3: Gameplay Integration (Missions and Events)
7. **Mission Templates**
   - Create `Mission` model with types: courier, auditor, heist, snap_response.
   - JSON templates for each: objectives, rewards, risks.
   - AI Manager integration: Generate missions based on network state.

8. **EM Leakage Harvesting**
   - During AWS shifts: Add temporary `em_leak` field to systems.
   - Panels harvest: Update `SolarPanel` model with `leak_efficiency` (e.g., 20-60%).
   - Boost local energy production until station stabilizes.

9. **Snap Event Integration**
   - Trigger on system maturity: Broadcast instability manifests.
   - Missions: Deploy arrays, transmit telemetry.
   - Update wormhole stability based on EM capture.

### Phase 4: Balancing and Testing (Polish)
10. **Asynchronous Conflict Resolution**
    - Logic: If incoming manifest sequence < current, discard; else update.
    - UI indicators: Show data age/confidence in market views.

11. **UI/Frontend Updates**
    - Add data age meters in JS market displays.
    - Alerts for tainted data or spoofing attempts.

12. **Testing and Balancing**
    - RSpec tests for all models/services.
    - Balance mission rewards vs. risks; ensure EM leakage doesn't break economy.

## Dependencies
- Requires existing `Ship`, `AwsStation`, `System` models.
- Leverage `BaseCraft#operational_data` JSONB (GIN indexed) - no schema changes needed.
- Integrate with AI Manager for mission generation.
- Documentation Mandate: Auto-log all changes to manifests.
- **System Integration**: Manifest model must inject into existing mission files (e.g., mars_genesis_phase0_orbital_infrastructure_integration.json) as the mechanism for CommunicationSystems tasks.
- **AI Manager Synergy**: Link mission generation to network state; dynamically generate "Auditor" missions for tainted routes.
- **EM Leakage Scaling**: Account for existing power bonuses in Mars specs (e.g., mars_cnt_foundry_establishment.json, mars_genesis_phase1_surface_outposts.json).

## Risks
- Performance: Large manifests could slow craft transit; GIN index on operational_data enables fast lookups.
- Exploitation: Spoofing could disrupt markets; strong validation needed.
- Complexity: Ensure ACK loops don't create infinite loops in busy networks.
- **Mitigation**: No migrations during manufacturing_pipeline stabilization; pure app-layer implementation.

## Next Steps
Prioritize Phase 1 for MVP. Assign to dev team; estimate 4-6 weeks per phase.

**Recommended Handoff Priorities**:
- **Priority 1**: The Manifest model + HashChain validation. Without this, the rest of the system is insecure.
- **Priority 2**: The broadcast logic (AWS Station → Ship).
- **Priority 3**: The ACK receipt mechanism.

**Post-Approval Tasks**:
- **Generate Jira/GitHub Tasks**: Create specific backlog items from Phase 1–4 breakdown.
- **Schema Definition**: Formalize Manifest model migration (Rails/SQL) with JSONB performance optimizations.
- **Security Protocol Doc**: Define "Spoofing/Taint" logic for recursive chain failure.