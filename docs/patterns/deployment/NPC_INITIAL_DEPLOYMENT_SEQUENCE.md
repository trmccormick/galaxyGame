# NPC Initial Deployment Sequence

## Phase 1: Orbital Station Deployment
- Deploy Station Node A (Orbital Station)
- Achieve Initial Operational Capability (IOC): Telemetry, refueling, and emergency extraction systems online
- Only Station-Building and Scout-Probe configurations are permitted (VariantManager.rb restriction)
- Surface-Descent variants are locked until Phase 2

### Precedence Gate (Hard-Lock)
**No surface assets (Habs, ISRU, Foundries) may be de-orbited until the Orbital Station provides telemetry, refueling, and emergency extraction coverage.**

## Phase 2: Surface Deployment
- Prerequisite: Station Node A: IOC Status = True
- Unlock Surface-Descent variants in VariantManager.rb
- Begin de-orbit and deployment of surface assets (Habs, ISRU, Foundries)

## Refined Phase List
1. Phase 1: Orbital Station Deployment
   - Station Node A deployed and achieves IOC
   - VariantManager.rb: Only Station-Building and Scout-Probe variants enabled
   - Precedence Gate: Surface assets locked
2. Phase 2: Surface Deployment
   - Prerequisite: Station Node A IOC = True
   - VariantManager.rb: Surface-Descent variants unlocked
   - Surface assets (Habs, ISRU, Foundries) deployed
