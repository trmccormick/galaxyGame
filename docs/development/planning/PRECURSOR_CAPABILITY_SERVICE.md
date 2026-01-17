# Precursor Capability Service

**Date:** 2026-01-15  
**Status:** ✅ IMPLEMENTED (2026-01-16)  
**Implementation:** `galaxy_game/app/services/ai_manager/precursor_capability_service.rb`

## Overview

Precursor missions establish local ISRU capacity and core infrastructure before major missions begin. The mission planner should assume local-first sourcing for basic resources once precursor phases are complete.

**Problem Solved:** Replaced hardcoded world identifiers in `MissionPlannerService.can_produce_locally?` with data-driven queries against actual celestial body sphere data (geosphere, atmosphere, hydrosphere).

## Implementation

### PrecursorCapabilityService

**Location:** `app/services/ai_manager/precursor_capability_service.rb`

**Key Methods:**
- `can_produce_locally?(resource)` - Check if resource available via ISRU
- `local_resources` - List all extractable resources from celestial body data
- `production_capabilities` - Capabilities by resource type (atmosphere, surface, subsurface, regolith)
- `precursor_enables?(capability)` - Check if precursor phase enables specific capability (:oxygen, :water, :fuel, :metals)

**Data Sources:**
- `CelestialBody.atmosphere.composition` - Atmospheric resources (CO2, N2, CH4, O2)
- `CelestialBody.geosphere.surface_composition` - Surface minerals (iron_oxide, silicon, aluminum)
- `CelestialBody.geosphere.volatile_reservoirs` - Frozen volatiles (H2O, CO2, CH4)
- `CelestialBody.hydrosphere` - Water resources (oceans, ice caps, subsurface)

**Usage:**
```ruby
# In MissionPlannerService
capability_service = AIManager::PrecursorCapabilityService.new(celestial_body)
can_produce = capability_service.can_produce_locally?('water_ice')
```

## Precursor Phases

- **Phase 1: Initial Setup**
  - Power systems online (solar/nuclear depending on environment)
  - Communications and monitoring
  - Basic surface preparation
- **Phase 2: Habitat & Advanced ISRU**
  - Pressurization infrastructure
  - Water extraction and processing
  - Atmospheric processing (where applicable)
  - Regolith mining and materials preparation

## Environment-Aware Capabilities

### Luna (luna/moon)
- **Resources:** oxygen, water (polar ice/recycling), regolith, silicon, aluminum, helium-3
- **Extraction:** regolith processing, electrolysis, surface mining
- **Notes:** Lava tube sites preferred for settlement entrances and coverage

### Mars (mars)
- **Resources:** oxygen, water (polar/subsurface), CO2 (atmospheric), regolith, iron, nitrogen
- **Extraction:** atmospheric processing (MOXIE-like), subsurface ice, regolith mining
- **Notes:** Precursor enables on-site O2/H2O production

### Titan (titan)
- **Resources:** methane, ethane, nitrogen, water_ice
- **Extraction:** lakes and atmospheric processing
- **Notes:** Fuel hub for outer system operations

### Europa (europa)
- **Resources:** water, oxygen, hydrogen
- **Extraction:** water electrolysis, subsurface liquid handling
- **Notes:** Cryogenic and contamination control considerations

### Ceres (ceres/asteroid)
- **Resources:** water_ice, regolith, carbonates/salts
- **Extraction:** surface mining and ice processing
- **Notes:** Supports depot and belt operations

## Local-First Sourcing Policy

- **Rule:** After precursor completion, source O2, H2O, regolith, and common ISRU metals locally whenever technically feasible.
- **Rationale:** Transport fuel costs dominate; local production is cheaper and more reliable.
- **Planner Behavior:** Mark these resources as `source_type: local` unless a specific facility is offline.

## Economic Implications

- **Transport Reduction:** Significant drop in transport cost ratio when local ISRU is active.
- **NPC Market Response:** Regional suppliers price slightly below Earth import (EAP) for items not locally produced.
- **Infrastructure ROI:** Investments in local production facilities yield strong savings when imports dominate.

## Site Selection Guidance

- **Lava Tube Preference:** Favor lava tube settlement sites on Luna/Mars for natural shielding and scalable coverage (see sealed lava tube cover blueprint).
- **Blueprint Integration:** Use structural/regolith panel blueprints for coverage and pressurization infrastructure; rely on local materials.

## Planner Integration

**Completed:**
- ✅ Created `AIManager::PrecursorCapabilityService` 
- ✅ Replaced hardcoded case statements in `MissionPlannerService.can_produce_locally?`
- ✅ Data-driven resource queries from celestial body spheres
- ✅ Comprehensive spec coverage

**Next Steps:**
- Integrate precursor phase completion tracking in settlement data
- Add "with precursor vs without" cost comparisons to planner output
- Create admin UI for precursor mission status

## References

- **Service:** `galaxy_game/app/services/ai_manager/precursor_capability_service.rb`
- **Spec:** `galaxy_game/spec/services/ai_manager/precursor_capability_service_spec.rb`
- **Integration:** `galaxy_game/app/services/ai_manager/mission_planner_service.rb` (line ~349)
- Mission Profiles: `data/json-data/missions/tasks/planetary-precursor-1/`
- Economic Parameters: `galaxy_game/config/economic_parameters.yml`
- Blueprints: `data/json-data/blueprints/components/structural/`
