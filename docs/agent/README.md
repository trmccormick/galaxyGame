## Monitor View Layer Data Requirements

# Tileset System Pivot: FreeCiv → JSON-Based Tiles

**2026 Update:** GalaxyGame has pivoted away from FreeCiv tilespec parsing and legacy asset pipelines. All map rendering now uses a unified JSON-based tileset system for surface and monitor views.

### JSON Tileset Format Example

All new tilesets are defined in JSON. Example:

```json
{
  "name": "galaxy_game_base_terrain",
  "description": "Default base terrain tileset for GalaxyGame surface and monitor views.",
  "tile_size": 32,
  "sheets": {
    "base": {
      "file": "base_terrain.png",
      "tiles": {
        "ocean": { "x": 0, "y": 0 },
        "plains": { "x": 32, "y": 0 },
        "desert": { "x": 64, "y": 0 },
        "forest": { "x": 96, "y": 0 },
        "mountains": { "x": 128, "y": 0 },
        "tundra": { "x": 160, "y": 0 },
        "grasslands": { "x": 192, "y": 0 },
        "swamp": { "x": 224, "y": 0 },
        "jungle": { "x": 256, "y": 0 }
      }
    }
  }
}
```

See `data/galaxy_game_tileset.json` for the current template. Sprite sheets must match the tile size and layout defined in the JSON.

**Migration Status:**
- Loader logic (`simple_tileset_loader.js`) and rendering code are ready for JSON tilesets.
- Default backup colors are used until new sprite sheets are created and applied.
- Next: Create and integrate new sprite sheets for each terrain type.

### New Map Layer Data Requirements

- **Terrain:** Height map (2D elevation grid, width, height). No biomes or features unless biosphere is present.
- **Hydrosphere:** Bathtub fill logic, guided by hydrosphere mass and coverage percentage. Only for worlds with liquid coverage.
- **Biomes:** Only present for Earth or worlds with biosphere. Omitted for bare/airless worlds.
- **Features:** Major geological features only (craters, mountains, etc.), conditionally included for clarity.
- **Temp:** Surface temperature grid or average value.
- **Resources:** Resource placement from real data, AI generation, or artistic maps. Only if relevant.
- **Civilization:** Settlements, technology, or artificial structures. Only if present.

**Best Practice:**
- Backend must filter and send only the data needed for each layer, based on planet properties.
- Frontend (monitor.js, surface_view_optimized.js) checks for layer presence and only renders if data is available and relevant.
- Biomes and features are conditionally included, never defaulted.

**Tileset System:**
- All tilesets are defined in JSON (see `galaxy_game_tileset.json`).
- Sprite sheets are referenced directly; no .spec or tilespec parsing.
- Loader logic is handled by `simple_tileset_loader.js`.
- Rendering is optimized via viewport culling in `surface_view_optimized.js`.

**Migration Notes:**
- Legacy FreeCiv tilespec and .spec files are deprecated.
- All new worlds and surface views use the JSON tileset system for performance, maintainability, and extensibility.

This ensures the monitor view is efficient, accurate, and scientifically robust, avoiding unnecessary or misleading data for each world.
# Agent & Development Workflow Documentation

This directory contains unified documentation for AI agent management and development workflow, organized by status and purpose. All new map and surface rendering tasks must use the JSON-based tileset system.

## 📁 Directory Structure

### Root Files
- **[CURRENT_STATUS.md](CURRENT_STATUS.md)** - Real-time project status, recent fixes, next steps
- **[GROK_CURRENT_WORK.md](GROK_CURRENT_WORK.md)** - Current agent work tracking
- **[GROK_RULES.md](GROK_RULES.md)** - Agent operating protocols
- **[TASK_PROTOCOL.md](TASK_PROTOCOL.md)** - Task execution standards

### `/rules/` - Agent Operating Rules
Core protocols and guidelines for AI agent operation.

**Files:**
- **[GROK_RULES.md](rules/GROK_RULES.md)** - Complete agent operating protocols
- **[TASK_PROTOCOL.md](rules/TASK_PROTOCOL.md)** - Task execution and completion standards

**Purpose**: Defines how agents operate and complete work

### `/tasks/` - Agent Task Management
Executable tasks for AI agents with status tracking.

**Subfolders:**
- **`/active/`** - Currently executing tasks
- **`/backlog/`** - Queued tasks awaiting assignment
- **`/critial/`** - Critical priority tasks requiring immediate attention
- **`/completed/`** - Finished tasks for reference

**Files:**
- **[TASK_OVERVIEW.md](tasks/TASK_OVERVIEW.md)** - Centralized task tracking log

**Purpose**: Task assignment, progress tracking, and completion validation

### `/planning/` - Future Roadmaps
Strategic planning documents for upcoming development phases.

**Files:**
- **[RESTORATION_AND_ENHANCEMENT_PLAN.md](planning/RESTORATION_AND_ENHANCEMENT_PLAN.md)** - 6-phase roadmap
  - Phase 1-3: Test restoration (surgical fixes)
  - Phase 4: UI Enhancement (SimEarth admin + Eve mission builder)
  - Phase 5: AI Pattern Learning (autonomous wormhole expansion)
  - Phase 6: Documentation cleanup

**Purpose**: Long-term vision and phase-by-phase execution plans

### `/completed/` - Historical Records
Documentation of completed work for reference and learning.

**Files:**
- **[CONSTRUCTION_REFACTOR.md](completed/CONSTRUCTION_REFACTOR.md)** - Manufacturing pipeline implementation

**Purpose**: Preserve institutional knowledge, reference for similar future work

### `/reference/` - Technical Guides
Essential technical documentation for daily development.

**Files:**
- **[grok_notes.md](reference/grok_notes.md)** - Agent-specific technical notes

**Purpose**: Essential development and agent references

## Workflow Integration

**Agent-Driven Development**: Most work flows through the `/tasks/` system where planning documents are converted into executable agent tasks.

**Status Tracking**: Use `CURRENT_STATUS.md` for real-time updates, `/tasks/TASK_OVERVIEW.md` for detailed task logs.

**Planning → Execution**: Documents in `/planning/` are broken down into tasks in `/tasks/backlog/` for agent assignment.

**Task Completion Workflow**: 
1. Complete all task requirements and testing
2. Move task file from source directory (`/active/`, `/critial/`, `/backlog/`) to `/completed/`
3. Remove empty source directories to maintain clean structure
4. Update `CURRENT_STATUS.md` with completion details
5. Commit changes following mandatory pre-commit testing protocol
  - RSpec ALWAYS in container
  - Command validation patterns
  
- **[grok_notes.md](reference/grok_notes.md)** - Workflow templates
  - Task 1: Nightly Grinder (autonomous 4-hour cycles)
  - Task 2: Quick-Fix (interactive, surgical approach)
  - Task 3: Continued Development (vision alignment)

**Purpose**: Quick reference for correct development practices

---

## 🎯 Usage Patterns

### Simulation & Map Data Intent
- **FreeCiv/Civ4 tilespec and biome data are no longer used for map rendering.**
- All surface and monitor views use the new JSON-based tileset system for both scientific and artistic worlds.
- Biome data is only included for worlds with biosphere or active terraforming.
- Terrain/elevation data is always present; biomes/features/resources/civilization layers are conditionally included based on world properties.

### Starting Your Day
1. Read [CURRENT_STATUS.md](CURRENT_STATUS.md) to see latest progress
2. **CRITICAL**: Review [Environment Boundaries & Docker Isolation](#-critical-environment-boundaries--docker-isolation) section below
3. Check [ENVIRONMENT_BOUNDARIES.md](rules/ENVIRONMENT_BOUNDARIES.md) for command safety rules
4. Reference [RESTORATION_AND_ENHANCEMENT_PLAN.md](planning/RESTORATION_AND_ENHANCEMENT_PLAN.md) for phase context

### Planning New Features
1. Review [RESTORATION_AND_ENHANCEMENT_PLAN.md](planning/RESTORATION_AND_ENHANCEMENT_PLAN.md) phases
2. Check [CONSTRUCTION_REFACTOR.md](completed/CONSTRUCTION_REFACTOR.md) for implementation patterns
3. Update [CURRENT_STATUS.md](CURRENT_STATUS.md) when starting work

### Running Tests or Git Operations
1. **MANDATORY**: Read [Environment Boundaries & Docker Isolation](#-critical-environment-boundaries--docker-isolation) section
2. **ALWAYS** consult [ENVIRONMENT_BOUNDARIES.md](rules/ENVIRONMENT_BOUNDARIES.md) for command safety
3. Use [grok_notes.md](reference/grok_notes.md) task templates for workflow guidance
4. **NEVER** run Rails/Ruby commands on host - always use `docker-compose exec web`
5. **Tileset/Map Rendering:** All new map and surface rendering code must use the JSON-based tileset system. Legacy FreeCiv/Civ4 asset pipelines are deprecated.

## 🧪 Testing Requirements & Validation Rules

### **MANDATORY: Pre-Commit Testing Protocol**
**ALL code changes MUST pass RSpec tests before commit:**

1. **Run RSpec tests for changed code:**
   ```bash
   docker-compose -f docker-compose.dev.yml exec -T web bundle exec rspec spec/services/ai_manager/
   # OR for specific files:
   docker-compose -f docker-compose.dev.yml exec -T web bundle exec rspec spec/services/ai_manager/escalation_service_spec.rb
   ```

2. **Validation Rules (MANDATORY):**
   - ✅ **Green-before-done**: All RSpec tests must pass
   - ✅ **No regressions**: Existing tests still pass
   - ✅ **Service integration**: Related services load and interact correctly
   - ✅ **Rails runner verification**: Manual testing with `rails runner` for complex logic

3. **Testing Scope Requirements:**
   - **New/Modified Services**: Full RSpec spec file required
   - **Bug Fixes**: Tests demonstrating the fix works
   - **Integration Changes**: Tests verifying service interactions
   - **Configuration Changes**: Tests validating new behavior

### **🚫 CRITICAL: Environment Boundaries & Docker Isolation**

**ALL development work MUST occur within Docker containers. Host system isolation is mandatory:**

#### **NEVER Run Commands on Host System**
- ❌ **Do NOT run** `bundle install`, `rails server`, `rake db:migrate`, etc. on host
- ❌ **Do NOT change** Ruby versions, system packages, or host environment
- ❌ **Do NOT run** Rails commands, RSpec tests, or database operations on host
- ❌ **Do NOT modify** host Ruby, Node.js, or system-level dependencies

#### **ALWAYS Use Docker for Everything**
- ✅ **Rails Commands**: `docker-compose exec web bundle exec rails ...`
- ✅ **RSpec Tests**: `docker-compose exec web bundle exec rspec ...`
- ✅ **Database Operations**: `docker-compose exec web bundle exec rake db:...`
- ✅ **Bundle Install**: `docker-compose exec web bundle install`
- ✅ **Rails Console**: `docker-compose exec web bundle exec rails console`

#### **Ruby Version Management**
- **DO NOT change Ruby versions** in Gemfile, Dockerfile, or host system
- **Ruby version is fixed** at 3.4.3 in Docker containers - this is intentional
- **Host Ruby version is irrelevant** - all work happens in isolated containers
- **Version mismatches indicate configuration errors**, not version changes needed

#### **Service Isolation Benefits**
- **Predictable environment**: Same Ruby, gems, and dependencies every time
- **No host pollution**: Development doesn't affect or require host system changes
- **Team consistency**: All developers work in identical Docker environments
- **Clean separation**: Host system remains stable and unchanged

### **NEVER Commit Without Testing**
- **Rails runner commands are NOT sufficient** for validation
- **Manual testing is NOT sufficient** for validation  
- **Only RSpec tests provide proper regression protection**
- **All substantive changes require automated test coverage**

### **Testing Workflow**
1. Make code changes
2. Write/update RSpec tests
3. Run tests: `docker-compose -f docker-compose.dev.yml exec -T web bundle exec rspec`
4. Fix any failures
5. Re-run tests until green
6. Only then commit and push

---

## 📝 Maintenance Guidelines

### When to Update CURRENT_STATUS.md
- After fixing any spec file
- When changing active focus area
- At end of each work session
- When failures drop below thresholds (401 → 350 → 200 → 100 → 50)

### When to Add to /completed/
- After completing major refactors
- When finishing multi-week development phases
- For documenting E2E integration work
- Preserving "how we built this" context

### When to Update Planning Docs
- Adding new phases or sub-phases
- Changing success metrics or targets
- Discovering better workflow patterns
- Adjusting timeline estimates

---

## 🔗 Related Documentation

### Parent Documentation
- [Main Docs README](../README.md) - Full project documentation hub
- [Developer Setup](../developer/setup.md) - Environment configuration

### Sibling Directories
- [Architecture](../architecture/) - System design
- [Storyline](../storyline/) - Game narrative
- [AI Manager](../ai_manager/) - AI systems

---

**Last Updated**: February 15, 2026  
**Maintainer**: Development team  
**Status**: Active organization (v2.0)


## Completed Task: Admin Monitor JS Map Initialization Fix

- Fixed admin monitor view map not loading on first Turbo navigation; map now loads immediately for all planets.
- Removed stale initialization guard, ensured monitorData and terrainData reload on every view.
- Manual testing confirmed fix; no RSpec or Ruby changes, so pre-commit testing protocol is not required for this JS-only change.
- Commit protocol: Only JS changes committed, no service or backend modifications.
- Documentation updated to record fix and testing scope.

## Completed Task: Implement Live System Health Checks for AI Manager Validation Suite

- All stubbed values in the System Health section replaced with live backend integration.
- Health check endpoint implemented with AJAX JSON response.
- Backend checks: AI service status, database connection, pattern availability, performance metrics.
- Frontend auto-refresh and manual refresh added; loading/error states handled.
- RSpec and integration tests cover backend and frontend.
- Documentation updated for new endpoint and troubleshooting.
- Acceptance criteria met: live status, no stub values, auto-refresh, <2s response, error handling, full test coverage.
- Task file moved to completed: docs/agent/tasks/completed/implement_live_system_health_checks_enhanced.md

---

## Tileset & Map Asset Workflow
- For all tileset, sprite sheet, and map asset work, see [TILESET_README.md](../../data/TILESET_README.md) for full instructions, requirements, and update protocol.
- This includes asset creation, config updates, variant/expansion workflow, testing, and atomic commit rules.
