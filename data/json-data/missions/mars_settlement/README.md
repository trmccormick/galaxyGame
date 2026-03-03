# Mars Settlement Missions

This folder contains the mission files for Mars colonization and terraforming operations.

## Mission Structure

**Note:** Mars settlement includes parallel phase execution capabilities, allowing advanced infrastructure projects (like CNT foundry establishment) to run concurrently with main settlement phases for accelerated development.

### Phase 0: Mars Orbital Establishment - Moons Conversion & Infrastructure
- **mars_orbital_establishment_manifest_v1.json** (Mission manifest - Cycler Mars Constructor)
- **mars_orbital_establishment_profile_v1.json** (Task-runnable mission profile)
- **mars_genesis_phase0_phobos_deimos_conversion.json** (Moons assessment and strategic planning)
- **mars_genesis_phase0_phobos_station_construction.json** (Phobos hybrid manufacturing station)
- **mars_genesis_phase0_deimos_depot_construction.json** (Deimos fuel depot and crew staging)
- **mars_genesis_phase0_orbital_infrastructure_integration.json** (Dual-station network establishment)
- Phobos conversion to hybrid manufacturing/resource processing station
- Deimos conversion to specialized fuel depot and crew logistics hub
- Orbital infrastructure integration with cycler networks

### Phase 1: Surface Outposts & Resource Mining
- **mars_genesis_phase1_surface_outposts.json** (Implemented - lava tube habitats and ISRU)
- Precursor missions for lava tube assessment and validation
- Underground habitat construction in radiation-shielded lava tubes
- Regolith processing for oxygen and water extraction
- Nuclear reactor deployment for power
- Initial interplanetary trade routes with orbital stations
- Automated base deployment using npc-base-deploy framework
- Strategic resource stockpiling for Phase 2 expansion

### Phase 2: Resource Infrastructure & Tank Farm Development
- **mars_genesis_phase2_resource_infrastructure.json** (Implemented - industrial ISRU and tank farms)
- Industrial-scale ISRU network establishment
- Oxygen liquefaction and storage infrastructure
- Tank farm development for Worldhouse pressurization
- Mining operations expansion for construction materials
- Automated resource processing and distribution systems

### Phase 3: Advanced Mining & Material Stockpiling
- **mars_genesis_phase3_advanced_mining.json** (Implemented - mega-scale mining and stockpiling)
- Large-scale silica mining for Worldhouse glass panels
- Iron ore extraction and steel production for I-beam structures
- Rare earth mineral mining for advanced systems
- Underground mining network development
- Mega-scale stockpile facilities with quality control
- Material preservation and automated logistics systems

### Phase 1: Surface Outposts (Enhanced)
- **mars_genesis_phase1_surface_outposts.json** (Enhanced - integrated CNT foundry)
- Noctis Labyrinthus lava tube habitat construction
- Nuclear power infrastructure deployment
- ISRU oxygen, water, and fuel production systems
- **Mars CNT Foundry Establishment** (integrated into Phase 1)
  - Surface CNT production facility using Martian CO2 atmosphere
  - Titanium alloy processing from regolith metal oxides
  - Advanced composites manufacturing for Worldhouse components
  - Interplanetary export logistics for CNT, titanium, and composites
- Initial interplanetary trade routes establishment
- Worldhouse construction preparation and monitoring networks

### Phase 4: Gateway Shielding & Planetary Protection
- **mars_genesis_phase4_gateway_shielding.json** (Moved from Phase 7 - prerequisite for terraforming)
- Initial artificial magnetosphere deployment at L1
- Magnetic shield establishment for atmospheric protection
- Phobos/Deimos station network integration
- Interplanetary hub development preparation

### Phase 5: Worldhouse Construction
- **mars_genesis_phase5_worldhouse_construction.json** (Moved from Phase 4)
- I-beam rib framework construction across Valles Marineris
- Aerogel dual-panel sealing system deployment
- Maintenance bot railway network installation
- Worldhouse pressurization and life support integration
- Initial habitat zoning and human access establishment

### Phase 6: Atmospheric Enrichment & Magnetosphere Expansion
- **mars_genesis_phase6_atmospheric_enrichment.json** (Moved from Phase 5)
- Large-scale CO2 import from Venus (primary) and gas giants (Saturn H2, Jupiter N2)
- Dynamic gas balancing: CO2 → N2/O2 as pressure increases for life support
- Advanced magnetosphere shielding expansion
- Ceres development trigger for water/oxygen supply
- Multi-source import network (Venus, Titan, Saturn, Jupiter systems)

### Phase 7: Human Settlement & Civilization
- **mars_genesis_phase7_human_settlement.json** (Moved from Phase 6)
- Large-scale population centers within Worldhouse
- Advanced manufacturing and industry development
- Cultural and governmental development
- Economic expansion with GCC-based systems

### Phase 8: Planetary Warming & Complete Terraforming
- **mars_genesis_phase8_great_warming.json** (Moved from Phase 8)
- Orbital solar mirror arrays for temperature increase
- Atmospheric aerosol dispersal for greenhouse effect
- Surface albedo modification with silica aerogel blankets
- Integration of Venus atmospheric imports

## Shield Upgrade Paths & EM Power Integration

### Shield Technology Progression
As energy systems advance through the tech tree, the Mars magnetic shield can be upgraded for improved efficiency and protection:

**Tier 1: Fusion-Powered Shield (Initial Deployment)**
- Power Source: Nuclear fusion reactors (1-2 GW initial charge, MW maintenance)
- Protection: 60-80% atmospheric retention
- Prerequisites: Fusion power tech
- Vulnerabilities: High maintenance, heat dissipation issues

**Tier 2: EM-Core Retrofit (Mid-Game Upgrade)**
- Power Source: Exotic Matter (EM) cores harvested from wormhole stations
- Protection: 95%+ atmospheric retention, near-zero maintenance
- Prerequisites: Wormhole stabilization tech, EM-core synthesis
- Benefits: Eliminates power grid dependency, reduces loss rates by 500%

**Tier 3: Wormhole-Stabilized Shield (End-Game)**
- Power Source: Direct wormhole EM channeling
- Protection: 100% atmospheric retention, self-sustaining
- Prerequisites: Advanced wormhole tech, EM refinement
- Benefits: Enables full terraforming acceleration

### Upgrade Events & Transition Logic
- **Trigger**: Shield upgrades are prompted when relevant energy tech is unlocked
- **Transition Window**: 48-72 game hours of vulnerability during retrofit
- **Risks**: Atmospheric loss spikes, market price volatility for imported gases
- **Sabotage Opportunities**: Traitors can disrupt upgrades for economic gain

### EM Power Transition Notes
- EM power shifts from "grid management" to "logistics and stability" gameplay
- Fusion remains for local power; EM powers "big science" (shields, portals)
- Traitor mechanics expand to include EM theft and wormhole sabotage

## Task-Runnable Mission Format

Phase 0 has been converted to the new task-runnable format with:
- **Mission Profile**: Defines overall mission structure and phases
- **Mission Manifest**: Specifies required craft, units, and inventory
- **Phase Task Files**: Detailed, executable tasks with dependencies and completion criteria

## Key Features

- **Parallel Phase Execution**: Advanced infrastructure projects can run concurrently with settlement phases for accelerated development
- **CNT Foundry Integration**: Surface-based carbon nanotube production utilizing Martian CO2 atmosphere and regolith resources
- **Worldhouse Megastructure**: Canyon-spanning pressurized habitat over Valles Marineris using I-beam and aerogel panel construction
- **Consumer-Focused Development**: Mars is primarily a resource consumer, importing gases and materials for terraforming
- **Ceres Resource Dependency**: Triggers Ceres Development Corporation for water ice and oxygen supply
- **Multi-Source Gas Imports**: Venus (CO2 primary), Titan (N2), Saturn (H2), Jupiter systems (N2 alternatives)
- **Dynamic Gas Balancing**: AI Manager adjusts imports based on pressure thresholds and life requirements
- **Nuclear Power Dominance**: Mars distance requires nuclear systems (43% Earth solar intensity)
- **Dual-Moon Architecture**: Unique hybrid stations on Phobos and Deimos
- **Terraforming Focus**: Full planetary transformation to Earth-like conditions

## Integration Notes

- Receives atmospheric components from Venus terraforming (CO2 primary)
- Triggers Ceres development for water ice and oxygen supply
- Imports N2 from Titan and gas giant alternatives (Saturn H2, Jupiter N2)
- Supplies rare earth minerals and advanced manufacturing
- Enables cycler-based interplanetary trade networks
- Dual-moon stations create unique gameplay opportunities