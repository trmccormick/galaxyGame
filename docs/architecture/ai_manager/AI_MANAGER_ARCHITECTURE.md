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

## Reference
- [89→8_SURGICAL_MAP.md](89→8_SURGICAL_MAP.md): Canonical file structure and refactor plan
- [CONSORTIUM_VOTING_ENGINE.md](CONSORTIUM_VOTING_ENGINE.md): Voting and ROI logic
- EM physics, BFS, and Hammer Protocol docs for supporting details

---

*This architecture is the foundation for all AI Manager logic, expansion, and governance. All code and documentation must align with this orchestration.*
