# Biology Models Overview

This document summarizes the models in `app/models/biology` and their intent within the simulation:

## 1. BaseLifeForm
- **Purpose:** Abstract base class for all life forms (natural or engineered).
- **Associations:**
  - `belongs_to :origin_planet` (optional)
  - `belongs_to :biosphere`
  - `has_many :parents` and `has_many :children` (via LifeFormParent)
- **Key Features:**
  - Stores biological and simulation properties (diet, ecological role, terraforming rates, etc.)
  - Growth and biomass calculation methods

## 2. LifeForm
- **Purpose:** Represents a natural life form in a biosphere.
- **Inherits:** `BaseLifeForm`
- **Key Features:**
  - Adapts to environmental changes
  - Calculates food availability and environmental impact

## 3. HybridLifeForm
- **Purpose:** Represents engineered or hybrid life forms.
- **Inherits:** `BaseLifeForm`
- **Key Features:**
  - Stores engineered traits and creator species
  - Custom growth and environmental impact logic

## 4. LifeFormParent
- **Purpose:** Join model for parent/child relationships between life forms (evolutionary tree).
- **Associations:**
  - `belongs_to :parent` (BaseLifeForm)
  - `belongs_to :child` (BaseLifeForm)

## 5. LifeFormDeployment
- **Purpose:** Tracks deployment and status of a life form on a specific world.
- **Associations:**
  - `belongs_to :biosphere`
  - `belongs_to :life_form`
- **Key Features:**
  - Tracks coverage, status (thriving, stable, struggling, dying, extinct)
  - Stores limiting factors and adaptation progress

## 6. LifeFormLibrary
- **Purpose:** Factory/service for creating standard terraforming organisms (e.g., cyanobacteria, nitrogen fixers).
- **Key Features:**
  - Provides methods to instantiate canonical life forms with correct properties for simulation and terraforming.

---

See also: [Biome Model Intent](./biome_model.md) and [TerraSim Service Intent](./terrasim_service.md) for integration with planetary simulation.