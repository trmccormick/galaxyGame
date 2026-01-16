# Precursor Infrastructure Capabilities

**Date:** 2026-01-15

## Overview

Precursor missions establish local ISRU capacity and core infrastructure before major missions begin. The mission planner should assume local-first sourcing for basic resources once precursor phases are complete.

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

## Planner Integration Notes

- Add environment capability checks to `can_produce_locally?` or a dedicated service.
- Reflect precursor phase completion in sourcing decisions and transport analysis.
- Present "with precursor vs without" cost comparisons to highlight savings.

## References

- Mission Profiles: `data/json-data/missions/tasks/planetary-precursor-1/` (environmental adaptations)
- Planner: `galaxy_game/app/services/ai_manager/mission_planner_service.rb`
- Economic Parameters: `galaxy_game/config/economic_parameters.yml`
- Blueprints: `data/json-data/blueprints/components/structural/` (regolith panels, sealed lava tube cover)
