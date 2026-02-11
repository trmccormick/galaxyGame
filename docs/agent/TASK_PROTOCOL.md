# LLM Agent Task Creation Protocol
**Galaxy Game Development - Agent Task Management**

## Purpose
This document provides the standardized protocol for creating new LLM agent tasks. All agent assignments must follow this format to ensure proper behavior, constraint compliance, and clear deliverables.

## Core Principles

### 1. Agent Role Separation
- **Documentation & Planning Agents**: Analysis, code review, documentation updates, task preparation
- **Implementation Agents**: Code changes, testing, commits (following prepared commands)
- **Never overlap roles** - documentation agents prepare commands, implementation agents execute them

### 2. Mandatory References
All agent tasks MUST include explicit references to:

#### Core Constraint Documents
- **GUARDRAILS.md**: AI Manager behavior rules, economic boundaries, architectural integrity
- **CONTRIBUTOR_TASK_PLAYBOOK.md**: Git rules, testing protocols, environment safety
- **ENVIRONMENT_BOUNDARIES.md**: Container operations, prohibited actions, safety protocols

#### Format Requirements
- **MANDATORY_LOGGING**: All RSpec runs must use `> ./log/rspec_full_$(date +%s).log 2>&1`
- **DATABASE_URL**: All test commands must use `unset DATABASE_URL && RAILS_ENV=test`
- **PATH_CONSTANTS**: Use `GalaxyGame::Paths::CONSTANT` never hardcoded paths
- **NAMESPACE_PRESERVATION**: Use fully qualified class names (e.g., `Location::SpatialLocation`)

## Task Creation Template

### [DATE] - [PRIORITY_LEVEL]: [TASK_TITLE]
==============================================================================

**AGENT ROLE:** [Documentation/Implementation]

**CONTEXT:** [Brief system/component description]

**ISSUE:** [Clear problem statement with symptoms]

**ROOT CAUSE:** [Technical analysis of underlying issue]

**IMPACT:** [What breaks if not fixed, who is affected]

**REQUIRED FIX:** [High-level solution approach]

**IMPLEMENTATION DETAILS:**
[Specific code changes, file locations, method modifications]

**TESTING SEQUENCE:**
1. [Step 1 with exact command]
2. [Step 2 with exact command]
3. [Verification command with expected output]

**EXPECTED RESULT:**
- [Specific measurable outcomes]
- [Interface/behavior changes]
- [Performance improvements]

**CRITICAL CONSTRAINTS:**
- All operations must stay inside the web docker container for all rspec testing
- All tests must pass before proceeding
- Create/Update Docs: [specific docs to update]
- Commit only changed files on host, not inside docker container
- Follow CONTRIBUTOR_TASK_PLAYBOOK.md git rules
- Reference GUARDRAILS.md for architectural decisions

**MANDATORY REFERENCES:**
- GUARDRAILS.md: [relevant sections]
- CONTRIBUTOR_TASK_PLAYBOOK.md: [relevant protocols]
- ENVIRONMENT_BOUNDARIES.md: [safety boundaries]

**REMINDER:** [Role-specific reminder about scope and limitations]

==============================================================================

## Task Priority Levels

### 🔥 CRITICAL
- System-breaking issues (e.g., admin interfaces not loading)
- Security vulnerabilities
- Data loss prevention
- Core functionality failures

### ⚠️ HIGH
- Feature completion blocking other work
- Performance issues affecting user experience
- API/contract breakages
- Testing infrastructure failures

### 📋 MEDIUM
- Feature enhancements
- Code quality improvements
- Documentation updates
- Non-blocking UI improvements

### 🔧 LOW
- Code cleanup
- Minor optimizations
- Future-proofing
- Nice-to-have features

## Task Categories & Types

### Bug Fixes
- **Symptom-based**: "Interface shows X but should show Y"
- **Root cause**: "Function Z fails because of W"
- **Regression**: "Previously working feature now broken"

### Feature Development
- **New Components**: Complete feature implementation
- **Enhancements**: Extend existing functionality
- **Integrations**: Connect existing systems

### Infrastructure & Maintenance
- **Testing**: Add/update test coverage
- **Documentation**: Update guides and references
- **Performance**: Optimize slow operations
- **Security**: Address vulnerabilities

### Research & Planning
- **Architecture**: Design system changes
- **Analysis**: Investigate complex issues
- **Prototyping**: Test approaches before implementation

## Task Dependencies & Sequencing

### Sequential Dependencies
Tasks that must complete before others can start:
```
Task A → Task B → Task C
```

### Parallel Dependencies
Tasks that can run simultaneously:
```
     ┌─ Task B ─┐
Task A          Task D
     └─ Task C ─┘
```

### Resource Dependencies
- **Agent Availability**: Specific agent skills required
- **System Access**: Database, file system, external services
- **Testing Resources**: Test data, environments, tools

## Resource Requirements

### Agent Capabilities
- **Documentation Agent**: Code review, analysis, task preparation
- **Implementation Agent**: Code changes, testing, commits
- **Research Agent**: Investigation, prototyping, architecture design
- **Testing Agent**: Test execution, validation, quality assurance

### System Resources
- **Database Access**: Read/write permissions, test data
- **File System**: Code editing, documentation updates
- **External Services**: API access, third-party integrations
- **Development Tools**: IDE, testing frameworks, build tools

## Timeline Estimation Guidelines

### Task Complexity Levels
- **🐛 Simple Bug Fix**: 30-60 minutes (single file, obvious issue)
- **🔧 Medium Feature**: 2-4 hours (multiple files, some testing)
- **🏗️ Complex Feature**: 4-8 hours (architecture changes, extensive testing)
- **🔬 Research Task**: 1-2 hours (investigation, no implementation)
- **📚 Documentation**: 30-90 minutes (analysis + writing)

### Time Multipliers
- **First-time task**: ×1.5 (learning curve)
- **High-risk changes**: ×2.0 (rollback planning, extensive testing)
- **Cross-system impact**: ×1.8 (coordination overhead)
- **Documentation required**: ×1.3 (analysis + writing time)

## Success Metrics & Acceptance Criteria

### Quantitative Metrics
- **Test Coverage**: All new code has X% test coverage
- **Performance**: Operations complete within Y seconds
- **Reliability**: Feature works in Z% of test scenarios
- **Code Quality**: Passes all linting and style checks

### Qualitative Metrics
- **User Experience**: Interface is intuitive and responsive
- **Maintainability**: Code is readable and well-documented
- **Scalability**: Solution handles expected load increases
- **Security**: No new vulnerabilities introduced

### Completion Checklist
- [ ] Code changes implemented
- [ ] Tests pass (logged with timestamps)
- [ ] Documentation updated
- [ ] Peer review completed
- [ ] Integration testing passed
- [ ] No regressions introduced

## Rollback Procedures

### Immediate Rollback (Task Failure)
1. **Stop Operations**: Halt all related processes
2. **Revert Changes**: `git revert` or manual rollback
3. **Restore Data**: Database dumps, file backups
4. **Verify Recovery**: Confirm system returns to pre-task state
5. **Document Failure**: Update task status with root cause

### Partial Rollback (Issues Discovered)
1. **Isolate Issues**: Identify which changes caused problems
2. **Selective Revert**: Rollback only problematic components
3. **Alternative Fix**: Implement corrected solution
4. **Full Testing**: Verify all scenarios work
5. **Update Documentation**: Reflect corrected approach

### Emergency Rollback (System Impact)
1. **Alert Team**: Notify all affected parties
2. **Full System Restore**: Complete environment rollback
3. **Impact Assessment**: Document affected users/features
4. **Recovery Plan**: Step-by-step restoration process
5. **Prevention Measures**: Update protocols to prevent recurrence

## Communication Channels

### Task Assignment
- **Protocol Document**: All tasks defined following this protocol
- **Status Updates**: Real-time status in task tracking tables
- **Clarification Requests**: Comments on specific task sections

### Progress Reporting
- **Status Changes**: Update tracking tables as work progresses
- **Blocker Alerts**: Immediate notification with resolution plans
- **Completion Reports**: Summary of changes, test results, documentation updates

### Issue Escalation
- **Technical Blockers**: Escalate to planning agent for redesign
- **Resource Constraints**: Request additional tools or access
- **Timeline Impact**: Notify of delays with revised estimates

## Quality Assurance

### Code Review Requirements
- **Self-Review**: Agent reviews own changes before committing
- **Automated Checks**: Linters, formatters, static analysis
- **Test Coverage**: Minimum 80% for new code
- **Integration Testing**: Verify changes don't break existing features

### Documentation Standards
- **Inline Comments**: Explain complex logic and decisions
- **API Documentation**: Update for any public interface changes
- **User Guides**: Update for user-facing feature changes
- **Architecture Docs**: Update for structural changes

### Testing Standards
- **Unit Tests**: Test individual methods and components
- **Integration Tests**: Test component interactions
- **System Tests**: Test end-to-end workflows
- **Performance Tests**: Verify response times and resource usage

## Version Control Best Practices

### Commit Guidelines
- **Atomic Commits**: One logical change per commit
- **Clear Messages**: Descriptive commit messages following format:
  ```
  [COMPONENT] Brief description
  
  - Detailed change 1
  - Detailed change 2
  - Testing performed
  ```
- **No Mass Commits**: Never `git add .` - commit specific files only
- **Branch Strategy**: Feature branches for development, merge to main when complete

### Code Organization
- **File Structure**: Follow Rails conventions and namespace structure
- **Naming Conventions**: Clear, descriptive names for files, classes, methods
- **Dependency Management**: Minimize coupling between components
- **Configuration**: Use environment variables and path constants

## Common Pitfalls & Solutions

### Pitfall: Hardcoded Paths
**Problem**: Paths break across environments
**Solution**: Use `GalaxyGame::Paths::CONSTANT` for all file paths

### Pitfall: Missing Test Logs
**Problem**: Test failures not captured
**Solution**: Always use `> ./log/rspec_full_$(date +%s).log 2>&1`

### Pitfall: Wrong Database
**Problem**: Tests modify development database
**Solution**: Always `unset DATABASE_URL && RAILS_ENV=test`

### Pitfall: Namespace Collisions
**Problem**: Class names conflict across modules
**Solution**: Use fully qualified names (e.g., `Location::SpatialLocation`)

### Pitfall: Container/Host Confusion
**Problem**: Git operations fail in container
**Solution**: Test in container, commit from host

## Task Template Examples

### Example 1: Bug Fix Task
```markdown
### 2026-02-11 - 🔥 CRITICAL: Fix STI Type Mapping in SystemBuilder

**AGENT ROLE:** Implementation

**CONTEXT:** SystemBuilderService creates celestial bodies from JSON

**ISSUE:** Planets created with wrong STI type, dashboard shows 0 planets

**ROOT CAUSE:** JSON uses "terrestrial_planet" but code matches "terrestrial"

**IMPLEMENTATION DETAILS:**
File: app/services/star_sim/system_builder_service.rb
Line: ~318
Change: when "terrestrial" → when "terrestrial", "terrestrial_planet"

**TESTING SEQUENCE:**
1. `rails db:reset && rails db:seed`
2. `rails c` → `CelestialBodies::Planets::Rocky::TerrestrialPlanet.count`
3. Verify dashboard shows 4 terrestrial planets

**CRITICAL CONSTRAINTS:**
- Test in Docker container
- Commit from host after verification
```

### Example 2: Feature Development Task
```markdown
### 2026-02-11 - 📋 MEDIUM: Add Terrain Quality Indicator

**AGENT ROLE:** Implementation

**CONTEXT:** Monitor view shows terrain but quality varies

**ISSUE:** No visual indicator of terrain generation method used

**IMPLEMENTATION DETAILS:**
Add metadata badge showing:
- "NASA GeoTIFF" (green)
- "Pattern-based" (yellow)
- "Fallback" (red)

**TESTING SEQUENCE:**
1. Load Earth monitor → should show green "NASA GeoTIFF"
2. Load AOL-732356 → should show yellow "Pattern-based"
3. Test with mock planet → should show red "Fallback"
```

## Appendix: Reference Documents

### Core Constraints
- **GUARDRAILS.md**: System-wide architectural and behavioral rules
- **CONTRIBUTOR_TASK_PLAYBOOK.md**: Development workflow and testing protocols
- **ENVIRONMENT_BOUNDARIES.md**: Container safety and prohibited actions

### Technical Documentation
- **docs/developer/**: Component-specific technical guides
- **docs/architecture/**: System design and decision records
- **README.md**: Project setup and overview

### Task Archives
- **tasks/completed/**: Historical task records
- **tasks/active/**: Currently in-progress tasks
- **tasks/backlog/**: Planned future work

---

**Document Version**: 2.0
**Last Updated**: 2026-02-11
**Maintained By**: Planning Agent
