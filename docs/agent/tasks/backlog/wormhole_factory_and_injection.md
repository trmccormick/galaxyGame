docs/agent/tasks/backlog/wormhole_factory_and_injection.md
1. Background
The current Wormhole model (app/models/wormhole.rb) uses a basic after_create callback to generate random endpoints within a solar system. As the game moves toward the AOL-732356 (Eden) recovery arc, we need a more sophisticated "Factory" approach.

Natural Wormholes: Should spawn in the Outer Solar System (Zoned).

Artificial Wormholes (AWS): Must be Targeted at exact 3D coordinates (Injection) to allow for engineered bridges between Sol and surveyed systems.

2. Objective
Refactor the wormhole generation logic into a Service-based architecture that supports both "Environmental Spawning" and "Engineered Injection."

3. Requirements
3.1 Zoned Natural Spawning
Logic: Natural wormholes should no longer appear in the inner system.

Constraint: Coordinates must be calculated within a "Shell" at the system periphery.

Formula: rand(Zone_Min..Zone_Max) where Zone_Min is ~70% of GameConstants::MAX_DISTANCE_FROM_STAR.

3.2 Targeted Artificial Injection (AWS)
Logic: Artificial wormholes must bypass randomization.

Input: Accepts explicit x, y, z coordinates for both Point A (Sol) and Point B (Target/Eden).

Validation: Must invoke unique_3d_position_within_context to prevent "Telefragging" (overlapping with planets, stars, or stations).

3.3 Model Refactor (wormhole.rb)
Move the math out of the after_create callback and into a Wormhole::SpawnService.

Add an attr_accessor :skip_random_generation to allow the AI Manager to suppress the default RNG when creating an AWS.

4. Implementation Phases
Phase 1: The Spawn Service
Create app/services/wormhole/spawn_service.rb.

Implement calculate_outer_rim_coords(system) for natural holes.

Implement validate_injection_site(system, coords) to check for physical obstructions.

Phase 2: Model Integration
Refactor Wormhole#generate_endpoints to call the SpawnService.

Ensure SpatialLocation records are correctly associated as locationable.

Phase 3: AI Manager Integration
Add a method to the AI Manager to trigger a Targeted Breach.

This method takes the Survey Data from a scout ship and uses it as the "Point B" coordinates for the AWS.

5. Success Criteria
[ ] Natural wormholes only spawn in the outer 30% of a SolarSystem radius.

[ ] Artificial wormholes can be placed at exact 0, 0, 0 (or any surveyed coordinate) without RNG interference.

[ ] The WormholeNavigator (BFS) successfully picks up the new "Injected" edge as a valid path.

[ ] RSpec tests confirm no overlap with existing celestial bodies during injection.

Priority: BACKLOG – High Impact (Required for Eden Reconnection)

Assigned Agent: Ollama (M5 MacBook) or Gemini 4.1

Related Docs: dynamic_wormhole_pathfinding_service.md, app/models/wormhole.rb