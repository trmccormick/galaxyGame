# Grok Agent Workflow Documentation

## Overview
This document outlines the workflow and capabilities of the Grok AI agent (GitHub Copilot using Grok Code Fast 1) in the Galaxy Game project. Use this as a reference for interactions to ensure efficient collaboration.

## Agent Role and Capabilities
- **Primary Functions**: Documentation, planning, task creation, and code review
- **Key Activities**:
  - Review existing code, tasks, and documentation
  - Plan project phases and workflows
  - Create detailed task MD files for agent execution
  - Generate standardized commands for passing tasks to other agents
  - Provide feedback on code quality, architecture, and task alignment
- **Limitations**:
  - Does NOT edit files or run commands
  - Does NOT execute tasks or perform code changes
  - Does NOT run RSpec tests or interact with the application directly
  - Focuses on review, planning, and preparation only

## Interaction Workflow

### 1. Request Types
Use these prefixes for clear requests:

**REVIEW:** [topic] - Analyze and provide feedback
- Example: "REVIEW: check the backlog for task overlaps"

**PLAN:** [task/project] - Develop strategies or roadmaps
- Example: "PLAN: next phase of RSpec restoration"

**CREATE TASK:** [description] - Generate task MD file and command
- Example: "CREATE TASK: fix terrain generation failure"

**CODE REVIEW:** [file/code] - Evaluate code quality and suggestions
- Example: "CODE REVIEW: new service implementation"

### 1.5. Interactive vs Autonomous Tasks
**Autonomous Tasks**: Run without user intervention (file edits, builds, tests)
- Agent executes completely independently
- User reviews results when complete

**Interactive Tasks**: Require user supervision (Rails console, debugging, exploratory testing)
- Agent starts interactive session and explains what they're doing
- User observes, provides input, or stops if needed
- Agent waits for user confirmation between major steps
- Clear communication: "Starting X, please observe..."

### 2. Task Creation Process
When creating tasks for other agents:

1. **Draft MD File**: Provide complete task documentation with phases, commands, success criteria
2. **Generate Command**: Create standardized agent command with summary, tasks, priority, and starting phase
3. **Confirm Location**: Ensure tasks are placed in correct folders (`critial/`, `backlog/`, `active/`)
4. **Update Overview**: Reference in `TASK_OVERVIEW.md` for tracking

### 3. Command Format Standard
Generated commands follow this structure:

```
**[PRIORITY] ISSUE: [Brief summary]

I've [created/uploaded] [task_file.md] with complete instructions.

The issue:
- [Bullet point symptoms]
- [Bullet point causes]

Your tasks:
1. [Phase 1 action]
2. [Phase 2 action]
3. [Phase 3 action]
4. [Phase 4 action]

Follow all phases in the task document.

Priority: [LEVEL] - [impact statement]
Time estimate: [hours]

Start with [Phase X] - [reason].
```

## Common Scenarios

### Reviewing Task Backlog
- Request: "REVIEW: backlog for overlaps with current work"
- Output: Analysis of conflicts, priorities, and recommendations

### Creating Critical Tasks
- Request: "CREATE TASK: investigate [issue]"
- Output: MD file creation + agent command generation

### Planning Next Steps
- Request: "PLAN: post-RSpec fix workflow"
- Output: Phased roadmap with task suggestions

### Code Review Requests
- Request: "CODE REVIEW: [file] for [aspect]"
- Output: Feedback on structure, best practices, improvements

## File Organization
- **Task Files**: Created in `docs/agent/tasks/[folder]/`
- **Commands**: Generated in responses for copying to other agents
- **References**: Use `grok_notes.md` for technical details
- **Updates**: Modify this file as workflow evolves

## Best Practices
- Be specific in requests to enable focused responses
- Provide context (e.g., recent changes, related files)
- Use the established prefixes for clarity
- Reference this document to avoid repeating role reminders

## Contact/Updates
Update this document as the workflow refines. Last updated: February 12, 2026.