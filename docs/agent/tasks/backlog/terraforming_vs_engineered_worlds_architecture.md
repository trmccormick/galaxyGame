# Backlog Task: Terraforming vs Engineered Worlds Architecture

## Core Distinction
Two fundamentally different approaches to colonization:

**Terraforming Candidates** — worlds where humans change the environment:
- Must be in or near the habitable zone
- Examples: Mars, Venus
- Long timescale simulation — atmosphere, biosphere, temperature
- TerraformingManager applies full simulation
- True terraforming possible over centuries

**Engineered Worlds** — worlds where humans adapt to the environment:
- Outside habitable zone or too extreme to terraform
- Examples: Titan, Europa, Ganymede, Callisto
- Environment stays hostile permanently
- Settlements require specialized technology and engineering
- Not terraformed — "engineered" is the correct term
- TerraformingManager does NOT apply

## Design Implications

### CelestialBody Model
Add a colonization_approach field:
- terraformable — habitable zone, full simulation applies
- engineered — hostile environment, technology-driven
- uninhabitable — no settlement possible (gas giant cores, stellar bodies)

### TerraformingManager
- Check colonization_approach before running any simulation
- Skip terraforming logic entirely for engineered worlds
- Log clearly when a body is flagged as engineered vs terraformable

### AI Manager
- Different strategy trees per colonization approach
- Engineered worlds prioritize: pressure vessels, radiation shielding,
  enclosed habitats, power generation, resource extraction
- Terraforming worlds prioritize: atmosphere processors, biosphere
  seeding, temperature regulation, water cycle management

### Technology Requirements
Engineered worlds require specialized tech:
- hardened_landers
- pressure_vessels
- radiation_shielding
- subsurface_drilling
- enclosed_habitat_systems

### Simulation Depth
- Terraforming candidates: full temperature/pressure/atmosphere/
  biosphere simulation
- Engineered worlds: simplified hazard modeling, technology 
  requirements, resource extraction only
- Exotic states (supercritical fluids etc): flagged in material JSON
  as future enhancement, not simulated now

### Layer Architecture
- Terraforming candidates: crust/mantle/core sufficient for now
- Engineered worlds: more exotic layer configurations needed
  (Titan: hydrosphere, ice shell, sub-ocean, etc.)
- Layer definitions should be data-driven per body type,
  not hardcoded enums
- Temperature + pressure drives material state within each layer

## Connection to Existing Backlog
- refactor_terraforming_manager_identify_available_resources.md
  — TerraformingManager should check colonization_approach first
- layer_architecture_exotic_bodies.md (new task needed)
  — Free string layers, data-driven per body type

## Acceptance Criteria
- CelestialBody has colonization_approach field
- TerraformingManager skips engineered worlds
- AI Manager has distinct strategy trees per approach
- Engineered world technology requirements defined in data
- Documentation clearly distinguishes terraforming vs engineered

## Technical Notes
- Venus is a special case: technically terraformable but extremely
  hostile, requires most advanced terraforming technology
- Supercritical fluid modeling (Venus atmosphere) deferred —
  represented as extreme hazard level, not physically simulated
- Titan is the canonical engineered world example

## Human Presence Levels

A key gameplay dimension is how many humans are present and why.
Robots do most of the work — human presence is a strategic choice not a necessity.

### Presence Tiers

**Full Automation**
- 100% robot workforce
- No habitability required
- Lowest operational cost
- Limited capabilities — no research bonuses, no human decision making
- Example: automated mining outpost on an asteroid

**Oversight Presence**
- Small human team — researchers, supervisors, specialists
- One or few sealed habitable modules required
- Research bonuses, oversight capabilities, specialist skills
- Rest of infrastructure operates in ambient environment
- Example: Titan research station overseeing robot mining operations

**Full Colony**
- Significant permanent human population
- Broad habitability infrastructure required
- Most capable — full research, governance, reproduction, culture
- Highest cost and complexity
- Example: terraformed Mars surface settlement

### Design Implications
- Most settlements do NOT need to be habitable — robots operate in
  vacuum, extreme temps, toxic atmospheres without issue
- Habitable conditions are rare and valuable — reduce life support
  overhead, enable human surface operations
- Terraforming is a luxury/strategic choice — you terraform because
  it unlocks human presence levels, not because you have to
- `habitable?` answers: can we reduce life support costs to zero?

### AI Manager Strategy
- Should evaluate human presence level as part of site selection
- Cost/benefit of habitability infrastructure vs robot-only operation
- Research value of human presence may justify habitability investment
- Connects to strategy_selector scoring for expansion decisions

### Gameplay Example — Titan
- 95% robot workforce — mining, processing, construction
- Small human research/oversight team
- One sealed habitable module for humans
- Remainder of infrastructure operates in Titan's atmosphere
- Lower cost than full colony, higher capability than full automation

---
Created: 2026-03-20
Priority: MEDIUM (Architecture, gameplay)
Estimated Effort: 1-2 sessions
Dependencies: 
  - refactor_terraforming_manager_identify_available_resources.md
  - layer_architecture_exotic_bodies.md
Agent Assignment: Claude Sonnet (architecture reasoning)