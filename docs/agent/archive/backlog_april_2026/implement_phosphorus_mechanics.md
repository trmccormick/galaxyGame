# Implement Phosphorus Resource Mechanics

## Problem
Game lacks phosphorus (P) as a strategic resource despite its critical role in biological systems. Recent research shows P availability determines habitability for both natural and engineered biospheres, creating gameplay opportunities for resource management and terraforming strategy.

## Current State
- Material system exists but doesn't distinguish P availability
- Terraforming phases lack P requirements
- AI Manager scouting doesn't evaluate P-rich vs. P-poor worlds
- No P logistics or supply chain mechanics

## Required Changes

### Phase 1: Data Model Updates
Add P-related fields to celestial bodies and materials:
- `phosphorus_availability` metric for planets/moons
- `core_oxygen_index` for formation chemistry assessment
- P content in asteroid/material types (apatite vs. schreibersite)

### Phase 2: Terraforming Logic
Implement P requirements for biological phases:
- Atmospheric terraforming: P-independent (N2/O2 focus)
- Biological terraforming: P-dependent (DNA/food chains)
- Worldhouse seeding: Concentrated P imports for initial biosphere
- Population scaling: P-budget caps colony growth

### Phase 3: AI Manager Enhancements
Update scouting and decision logic:
- P-triage protocol for system evaluation
- Prioritize P-rich anomalies in Local Bubble
- Logistics planning for P supply chains (Ceres-to-colony)
- Risk assessment for P-dependent biospheres

### Phase 4: Resource Processing
Add P refining mechanics:
- Phobos/Deimos stations: Convert Martian apatite to bio-available P
- Ceres processing: Apatite fertilizer production
- Psyche mining: Metallic P extraction for industrial/tech use
- Supply chain integrity monitoring

## Success Criteria
- P availability affects terraforming feasibility
- AI Manager optimizes for P-rich systems
- Resource hierarchy supports strategic decision-making
- Worldhouse concepts include P-focused implementation
- No performance impact on current systems

## Dependencies
- Material and celestial body models
- AI Manager service classes
- Terraforming phase logic
- Existing resource processing infrastructure

## Risk Assessment
- Low risk: Additive mechanics, doesn't break existing functionality
- Scope: Focus on data models and logic, defer UI until Phase 4
- Testing: RSpec coverage for new P-related calculations

## Priority
Medium-High - Adds valuable strategic depth to terraforming and resource management, aligns with Phase 5 AI pattern learning goals.</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/implement_phosphorus_mechanics.md