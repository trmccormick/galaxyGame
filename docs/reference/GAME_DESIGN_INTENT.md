# GAME DESIGN INTENT - REFERENCE
**Purpose**: Help Grok understand what this game is about and why we make certain decisions.

---

## What is This Game?

### High-Level Concept
A **space exploration and colonization strategy game** where players:
1. **Explore** star systems and planets
2. **Analyze** planetary conditions and resources
3. **Establish** colonies and habitats
4. **Extract** resources and build infrastructure
5. **Expand** across multiple systems

### Think: Civilization + Kerbal Space Program + SimCity
- **Civilization**: Strategic planning, resource management, tech trees
- **Kerbal**: Realistic orbital mechanics and planetary science
- **SimCity**: Building and managing colonies/infrastructure

---

## Core Gameplay Pillars

### 1. Scientific Accuracy
**Intent**: Planets should feel REAL, not fantasy
- Use actual NASA data where possible (Earth, Mars, Luna, etc.)
- Procedural generation based on real planetary science
- Realistic terrain, atmospheres, temperatures, gravity

**Why this matters for Grok**:
- When adding features, check: "Is this scientifically plausible?"
- Use NASA GeoTIFF data for Sol system bodies
- Use learned patterns for exoplanets (not random generation)

### 2. Strategic Resource Management
**Intent**: Players make meaningful choices about resources
- Resources are finite (planets don't have infinite iron)
- Extraction has costs (energy, equipment, time)
- Trade-offs exist (mine here vs. there, this vs. that)

**Why this matters for Grok**:
- Don't create infinite resource generation
- Resource locations should be strategic (not everywhere)
- Economic systems have limits (see GUARDRAILS.md)

### 3. Exploration and Discovery
**Intent**: Finding new things should be exciting
- Each planet is unique (not copy-paste)
- Procedural generation creates variety
- Civilization layers add historical context

**Why this matters for Grok**:
- Terrain should look different between planets
- Use variety in generation (not same patterns everywhere)
- Add details that make places feel lived-in

### 4. Long-Term Planning
**Intent**: Players think multiple turns ahead
- Colonies take time to build
- Tech research has prerequisites
- Expansion requires infrastructure

**Why this matters for Grok**:
- Systems should connect logically (can't build X without Y)
- Time matters (things don't happen instantly)
- Dependencies should be clear and enforced

---

## Key Systems (What They're For)

### Star Systems & Celestial Bodies
**Purpose**: The "map" - where everything happens

**What players do**:
- Scan systems to find planets
- Analyze planet conditions (gravity, temp, atmosphere)
- Decide which planets to colonize

**What Grok should know**:
- Each planet needs unique, realistic data
- Monitor view = player's main planetary analysis tool
- Terrain visualization helps player understand planet surface

### Terrain Generation
**Purpose**: Show what the planet's surface looks like

**What players do**:
- Scout landing sites (flat areas near resources)
- Plan colony locations (avoid harsh terrain)
- Identify strategic features (mountains, valleys, water)

**What Grok should know**:
- Terrain should be realistic (NASA data for Sol, patterns for exoplanets)
- Visual quality matters (players will stare at these maps)
- Different planet types have different terrain (Mars ≠ Earth)

### Resource Systems
**Purpose**: Give players things to extract and trade

**What players do**:
- Survey planets for resources (minerals, water, rare elements)
- Build extractors at resource sites
- Transport resources between colonies

**What Grok should know**:
- Resources have real-world basis (iron exists, "unobtanium" doesn't)
- Resource locations should be strategic (not uniform distribution)
- Extraction costs energy/equipment (not free)

### Colony Management
**Purpose**: Let players build and grow settlements

**What players do**:
- Choose colony sites (balance terrain, resources, conditions)
- Build habitats, power plants, farms
- Manage population and happiness

**What Grok should know**:
- Colonies need life support (oxygen, water, food)
- Harsh planets are harder to colonize (Venus harder than Earth)
- Infrastructure unlocks more options (power → factories)

### AI Manager
**Purpose**: Make NPCs and automation feel intelligent

**What players do**:
- Delegate tasks to AI managers ("mine this region")
- Set policies (focus on energy vs. food)
- Review AI decisions and adjust

**What Grok should know**:
- AI should help, not replace player decisions
- Economic boundaries prevent AI from cheating (see GUARDRAILS.md)
- AI learns patterns from real data (NASA, not random)

---

## What This Game is NOT

### ❌ Not a Fantasy Game
- No magic or impossible physics
- Terraforming takes centuries (not instant)
- Can't create resources from nothing

### ❌ Not a Click-Fest
- Automation exists for repetitive tasks
- Strategic choices > micro-management
- Players plan, AI executes

### ❌ Not Hyper-Realistic Simulation
- Simplified where needed for gameplay
- Some compression of time/scale
- But always plausible, never arbitrary

---

## Design Principles for Development

### 1. Real Data First
**Principle**: When real data exists, use it
- Earth terrain = NASA GeoTIFF (not procedural)
- Mars terrain = MOLA data (not random)
- Exoplanet terrain = learned patterns (not sine waves)

### 2. Procedural with Purpose
**Principle**: Random generation should follow rules
- Use patterns learned from real planets
- Apply planetary science (hot planets ≠ ice caps)
- Variety within constraints (not pure chaos)

### 3. Gameplay Over Purity
**Principle**: Science is guide, not prison
- Simplify where it improves gameplay
- But never break believability
- Player should feel smart, not confused

### 4. Progressive Complexity
**Principle**: Start simple, add depth
- Core mechanics work without advanced features
- Advanced features enhance, don't replace basics
- New players aren't overwhelmed

---

## Common Questions Answered

### Q: Why do we use NASA GeoTIFF data?
**A**: Because it makes Sol system planets look REAL. Players recognize Earth, Mars, etc. This builds trust in the simulation.

### Q: Why not just make all terrain procedural?
**A**: Hybrid approach is best. Real data for known planets (quality baseline), procedural for exoplanets (infinite variety).

### Q: Why does terrain generation matter so much?
**A**: It's the player's PRIMARY VIEW of planets. If terrain looks fake, the whole game feels fake.

### Q: Why do we have so many validation rules?
**A**: Because the game has interconnected systems. Breaking one (e.g., infinite resources) breaks others (economy, strategy).

### Q: Why follow namespaces so strictly?
**A**: Large codebase needs organization. Namespaces prevent conflicts and make code maintainable.

---

## How to Use This Document

### When Adding Features:
Ask yourself:
1. Does this fit the game's intent?
2. Is this scientifically plausible?
3. Does this create meaningful player choices?
4. Does this connect to existing systems logically?

### When Fixing Bugs:
Ask yourself:
1. Does the fix maintain realism?
2. Does it preserve strategic balance?
3. Does it follow the design principles?

### When Confused:
Ask the user:
- "I see two ways to implement this. Option A is more realistic but complex. Option B is simpler but less accurate. Which fits the game intent better?"

---

**REMEMBER**: 
This game is about **strategic space colonization with scientific grounding**.
When in doubt, ask: "Would this make sense in a realistic space program?"

