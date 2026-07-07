# AI Manager Architecture (89→8 Core)

## Overview
This document synthesizes the orchestration and logic flow of the resurrected AI Manager, built around 8 core files. All expansion, resource, and network decisions are governed by EM physics, BFS wayfinding, consortium voting, and the Hammer Protocol.

## Core Orchestration Flow

1. **ai_manager.rb** (Master Orchestration)
   - Central controller for all AI-driven expansion and logistics
   - Triggers all major services and coordinates mission flow

2. **wormhole_coordinator.rb** (BFS Wayfinding)
   - Maintains the interstellar graph of wormhole connections
   - Uses BFS to find optimal paths for expansion and logistics
   - Interfaces with EM physics for path cost calculation

3. **consortium_voting_engine.rb** (ROI Governance)
   - Implements EM-aware, path-based ROI voting logic
   - 66% quorum required for all major expansion/build decisions
   - Integrates EM windfalls and BFS distances into every vote

4. **hammer_protocol_service.rb** (EM Reset & Snap Control)
   - Manages the Hammer Protocol for controlled Snap events
   - Resets wormhole networks and enables opportunistic expansion
   - Tracks EM buffer saturation and triggers resets as needed

5. **brown_dwarf_hub_manager.rb** (L3 AWS Anchors)
   - Identifies and manages Brown Dwarf hubs as stable L3 anchors
   - Optimizes network stability and EM relay efficiency

6. **em_harvesting_service.rb** (EM Fountains)
   - Handles all EM harvesting from natural wormholes and artificial stations
   - Monitors EM recapture cycle and buffer status
   - Supplies EM for AWS construction and network expansion

7. **expansion_assessment.rb** (Scouting & System Evaluation)
   - Analyzes new systems for expansion potential
   - Integrates probe data, resource mapping, and pattern matching
   - Feeds system assessments to the voting engine

8. **multi_wormhole_event_handler.rb** (AI Learning & Adaptation)
   - Manages multi-wormhole events and AI learning patterns
   - Adapts strategies based on network changes and Snap outcomes

## Integration Logic
- All expansion begins with **expansion_assessment.rb** (scouting)
- **ai_manager.rb** triggers **wormhole_coordinator.rb** to find optimal paths
- **em_harvesting_service.rb** checks EM reserves and buffer status
- **consortium_voting_engine.rb** evaluates ROI and calls for a vote
- If EM buffers are saturated, **hammer_protocol_service.rb** triggers a Snap
- **brown_dwarf_hub_manager.rb** ensures network stability via L3 anchors
- **multi_wormhole_event_handler.rb** updates AI learning and adapts future logic

---

## Operational Constraints (from GUARDRAILS.md §5: Operational Boundaries)
- **Autonomous Overrides:** The AI Manager may ignore Alpha Centauri in favor of local Milky Way wormholes if the `SimEvaluator` predicts a higher ROI or faster stability rating.
- **Verification:** All autonomous construction phases must be logged via the `PerformanceTracker` to ensure they meet the 85% success rate requirement.

## Namespace Preservation Rules
- **Namespace Preservation:** Models must reside in directories matching their Ruby namespace (e.g., `Location::SpatialLocation` belongs in `app/models/location/`).
- **Nesting Mandate:** Do not flatten directory structures during recovery. If a class is namespaced in `ApplicationRecord`, the spec must reflect that namespace (e.g., use `Location::SpatialLocation.new`, not `SpatialLocation.new`).

## Service Namespace Integrity
- All service classes (AIManager, Ceres, Mars, etc.) must use nested module definitions:
  ```ruby
  module AIManager
    module Testing
      class PerformanceMonitor
        # ...
      end
    end
  end
  ```
- Do **not** use `module AIManager::Testing` for service classes. Zeitwerk may not resolve the parent module if not already loaded, causing `NameError`.
- Ensure there is no file named `app/services/ai_manager/testing.rb` that conflicts with the `app/services/ai_manager/testing/` directory. If a namespace file is needed, it should only define the module and not contain logic or requires.
- All specs for namespaced services must require `rails_helper` and never use `require_relative` for app/services code.
- After any namespace or structure change, run `bin/rails zeitwerk:check` and the relevant RSpec suite.

## Manager/Service Placement Rule [2026-01-15]
- All 'Manager' and 'Service' classes must reside in `app/services/` and never in `app/models/` unless they are backed by a database table (i.e., inherit from `ApplicationRecord`).
- This ensures Zeitwerk autoloading and logical separation of concerns.

## Sol Training Data (from GUARDRAILS.md §9: Sol as AI Training Data)
**Core Design Philosophy:** The Sol system serves as the primary training dataset for AI Manager autonomous decision-making in new system development. All patterns, economic dynamics, and infrastructure decisions learned from Sol must be applied to maintain consistent expansion quality and player-first economics.

### Training Data Structure
- **Mission Profiles:** JSON mission files (`l1_tug_construction_profile_v1.json`, cycler logistics manifests) provide pattern recognition templates for procurement, sequencing, and quality assurance workflows.
- **Economic Patterns:** Player-first with NPC fallback dynamics, market-based pricing, and infrastructure rental systems establish baseline ROI expectations and participation incentives.
- **Infrastructure Templates:** Orbital shipyards, cycler platforms, and development corporation foundations serve as architectural blueprints for new system deployment.

### AI Manager Learning Objectives
- **Pattern Matching:** Analyze Sol mission success rates, economic participation levels, and infrastructure ROI to identify optimal deployment strategies for new systems.
- **Adaptive Decision-Making:** When building new systems, AI Manager must evaluate local conditions against Sol-trained patterns, adapting cycler logistics, market dynamics, and construction sequencing accordingly.
- **Player Integration:** Maintain player-first economics by creating competitive opportunities in new systems, using Sol data to predict participation levels and adjust NPC fallback timing.

### Implementation Requirements
- **JSON Mission Refinement:** All Sol mission files must be structured for AI pattern recognition, including success criteria, ROI estimates, and adaptive parameters.
- **Economic Continuity:** New systems must replicate Sol's market dynamics, ensuring players can profit from infrastructure contributions and logistics operations.
- **Autonomous Expansion:** AI Manager uses Sol training data to make independent decisions about wormhole stability, resource prioritization, and development sequencing without requiring human intervention.

### Validation Metrics
- **Pattern Accuracy:** AI Manager decisions in new systems must achieve 85% success rate compared to Sol baseline performance.
- **Economic Alignment:** Player participation rates and GCC earnings in new systems should match or exceed Sol system averages.
- **Infrastructure Quality:** New system deployments must meet Sol-established standards for stability, resource availability, and expansion potential.

## Resource Allocation Engine Integration (from GUARDRAILS.md §Resource Allocation)
- All bootstrap settlement logic must use AIManager::ResourceAllocator to calculate initial supply packages (energy, water, food, construction).
- ISRU priorities (oxygen, water, metals) must be ranked and documented per engine requirements.
- ResourceAllocator interacts with ColonyManager's trade logic for supply and extraction planning.
- All integration must be validated by spec and documented in the workflow.

*This architecture is the foundation for all AI Manager logic, expansion, and governance. All code and documentation must align with this orchestration.*
