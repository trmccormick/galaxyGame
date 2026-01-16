# Development Documentation Organization

This directory contains all development-related documentation organized by status and purpose.

## 📁 Directory Structure

### `/active/` - Current Work
Documentation for work currently in progress.

**Files:**
- **[CURRENT_STATUS.md](active/CURRENT_STATUS.md)** - Real-time project status, recent fixes, next steps

**Purpose**: Single source of truth for "what we're doing right now"

---

### `/planning/` - Future Roadmaps
Strategic planning documents for upcoming development phases.

**Files:**
- **[RESTORATION_AND_ENHANCEMENT_PLAN.md](planning/RESTORATION_AND_ENHANCEMENT_PLAN.md)** - 6-phase roadmap
  - Phase 1-3: Test restoration (surgical fixes)
  - Phase 4: UI Enhancement (SimEarth admin + Eve mission builder)
  - Phase 5: AI Pattern Learning (autonomous wormhole expansion)
  - Phase 6: Documentation cleanup

**Purpose**: Long-term vision and phase-by-phase execution plans

---

### `/completed/` - Historical Records
Documentation of completed work for reference and learning.

**Files:**
- **[CONSTRUCTION_REFACTOR.md](completed/CONSTRUCTION_REFACTOR.md)** - Manufacturing pipeline implementation
  - E2E integration tests
  - Material processing chains
  - Component production & shell printing
  - Service organization

**Purpose**: Preserve institutional knowledge, reference for similar future work

---

### `/reference/` - Technical Guides
Essential technical documentation for daily development.

**Files:**
- **[ENVIRONMENT_BOUNDARIES.md](reference/ENVIRONMENT_BOUNDARIES.md)** - Critical rules
  - Git ALWAYS on host (NEVER in container)
  - RSpec ALWAYS in container
  - Command validation patterns
  
- **[grok_notes.md](reference/grok_notes.md)** - Workflow templates
  - Task 1: Nightly Grinder (autonomous 4-hour cycles)
  - Task 2: Quick-Fix (interactive, surgical approach)
  - Task 3: Continued Development (vision alignment)

**Purpose**: Quick reference for correct development practices

---

## 🎯 Usage Patterns

### Starting Your Day
1. Read [CURRENT_STATUS.md](active/CURRENT_STATUS.md) to see latest progress
2. Check [ENVIRONMENT_BOUNDARIES.md](reference/ENVIRONMENT_BOUNDARIES.md) if running commands
3. Reference [RESTORATION_AND_ENHANCEMENT_PLAN.md](planning/RESTORATION_AND_ENHANCEMENT_PLAN.md) for phase context

### Planning New Features
1. Review [RESTORATION_AND_ENHANCEMENT_PLAN.md](planning/RESTORATION_AND_ENHANCEMENT_PLAN.md) phases
2. Check [CONSTRUCTION_REFACTOR.md](completed/CONSTRUCTION_REFACTOR.md) for implementation patterns
3. Update [CURRENT_STATUS.md](active/CURRENT_STATUS.md) when starting work

### Running Tests or Git Operations
1. **ALWAYS** consult [ENVIRONMENT_BOUNDARIES.md](reference/ENVIRONMENT_BOUNDARIES.md) first
2. Use [grok_notes.md](reference/grok_notes.md) task templates for workflow guidance
3. Never run bare commands without docker-compose prefix (container) or on host (git)

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

**Last Updated**: January 16, 2026  
**Maintainer**: Development team  
**Status**: Active organization (v2.0)
