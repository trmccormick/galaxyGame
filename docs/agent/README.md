# Agent & Development Workflow Documentation

This directory contains unified documentation for AI agent management and development workflow, organized by status and purpose.

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
1. Read [CURRENT_STATUS.md](CURRENT_STATUS.md) to see latest progress
2. Check [ENVIRONMENT_BOUNDARIES.md](reference/ENVIRONMENT_BOUNDARIES.md) if running commands
3. Reference [RESTORATION_AND_ENHANCEMENT_PLAN.md](planning/RESTORATION_AND_ENHANCEMENT_PLAN.md) for phase context

### Planning New Features
1. Review [RESTORATION_AND_ENHANCEMENT_PLAN.md](planning/RESTORATION_AND_ENHANCEMENT_PLAN.md) phases
2. Check [CONSTRUCTION_REFACTOR.md](completed/CONSTRUCTION_REFACTOR.md) for implementation patterns
3. Update [CURRENT_STATUS.md](CURRENT_STATUS.md) when starting work

### Running Tests or Git Operations
1. **ALWAYS** consult [ENVIRONMENT_BOUNDARIES.md](reference/ENVIRONMENT_BOUNDARIES.md) first
2. Use [grok_notes.md](reference/grok_notes.md) task templates for workflow guidance
3. Never run bare commands without docker-compose prefix (container) or on host (git)

---

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

**Last Updated**: January 16, 2026  
**Maintainer**: Development team  
**Status**: Active organization (v2.0)
