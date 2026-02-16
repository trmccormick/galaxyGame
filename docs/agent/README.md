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
