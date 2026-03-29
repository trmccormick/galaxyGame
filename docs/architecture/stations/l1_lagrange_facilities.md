# L1 Lagrange Point Facilities System

> **This file has been superseded.**
> For all L1 facility, orbital depot, and mega-station construction logic, see:
> 
> **architecture/stations/SYNTHETIC_MEGA_STATIONS.md**

## Overview

The L1 Lagrange Point Facilities represent the primary Earth-Moon system infrastructure hub for Sol system operations. Located at the Earth-Moon L1 point (approximately 326,000 km from Earth), these facilities serve as the central staging area for interplanetary missions, resource processing, and spacecraft construction.

**Key Principle**: Two specialized facilities with distinct roles and build sequencing to ensure operational efficiency.

## Facility Architecture

### 1. Orbital Depot (Logistics & Refueling Hub)
**Build Priority**: First facility constructed
**Primary Function**: Resource processing, storage, and transfer operations
**Structure Type**: `refueling_station`
**Blueprint**: `orbital_depot_mk1_bp`

#### Operational Characteristics
- **Automation Level**: High (98% efficiency, autonomous operations)
- **Power Consumption**: 500 kW (efficient cryo-storage systems)
- **Specialization**: Volatiles handling and zero-boil-off cryo-storage
- **Capacity**: 12 cryogenic tank modules, 5 volatiles processing units
- **Crew Requirements**: Minimal (1 habitat module for maintenance crews)

#### Key Capabilities
- Cryogenic propellant storage and transfer
- Automated refueling operations for spacecraft
- Resource processing and packaging for interplanetary transport
- Material unloading from lunar cyclers and Earth transports
- Logistics coordination between Earth, Moon, and outer planets

### 2. Planetary Staging Hub (Manufacturing Mega-Station)
**Build Priority**: Second facility constructed (after depot operational)
**Primary Function**: Heavy manufacturing and spacecraft construction
**Structure Type**: `mega_station`
**Blueprint**: `planetary_staging_hub_mk1_bp`
