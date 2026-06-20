# AI_MANAGER_EVENT_FLOW.md

## AI Manager: Event-Driven Physics Handler

### Domain: Reacts to Game Physics & Player Events
- **Does NOT**: Generate worlds, place wormholes, or invent rules
- **Does**: React to events, enforce physics, optimize within constraints

---

## Event → Reaction → Action Flow

### 1. Natural Wormhole Detected
- **Event:** TerraSim/StarSim spawns a new natural wormhole
- **AI Manager:**
  - Scout system (probe deployment)
  - Assess EM yield (em_yield_analysis)
  - Run consortium_vote (EM-path ROI)
  - If approved: Deploy stabilization (AWS, satellites)

### 2. EM Buffer Saturation
- **Event:** EM buffer at wormhole station/satellites is full
- **AI Manager:**
  - Trigger Hammer Protocol (controlled Snap)
  - Discover new system (post-Snap)
  - Repeat scouting and assessment

### 3. Player Arrival in System
- **Event:** Player enters/claims a system
- **AI Manager:**
  - Switch to advisory mode (reduced autonomy)
  - Suggest optimal actions (e.g., "Recommend AWS at L3 Brown Dwarf")
  - Provide EM, path, and ROI analysis on request

### 4. Multi-Wormhole Crisis
- **Event:** Multiple wormholes destabilize or Snap in rapid succession
- **AI Manager:**
  - Activate multi_wormhole_event_handler
  - Apply learned crisis patterns (10+)
  - Rebalance network, update priorities

---

*This flow codifies the AI Manager as a supreme event reactor—servant to physics, architect of the galactic empire.*
