# Blueprint Polymorphic Ownership Implementation

## Context
Blueprint model currently only supports player ownership, limiting flexibility for future features like organization-owned blueprints, consortium blueprints, or NPC faction blueprints.

## Problem
- Blueprint belongs_to :player only
- Cannot support organization or consortium ownership
- Limits blueprint sharing and licensing models
- Not extensible for future ownership types

## Solution
Implement polymorphic ownership for blueprints to allow ownership by players, organizations, consortiums, or other entities.

## Files to Modify
- `app/models/blueprint.rb` - Change ownership to polymorphic
- `db/migrate/[timestamp]_add_polymorphic_owner_to_blueprints.rb` - Database migration
- `spec/models/blueprint_spec.rb` - Update tests for polymorphic ownership

## Implementation Steps
1. Change belongs_to :player to belongs_to :owner, polymorphic: true
2. Create database migration to add owner_type and owner_id columns
3. Update existing blueprints to set owner_type: 'Player'
4. Add validation for owner presence
5. Update any code that assumes player ownership
6. Test that Blueprint.new(owner: Player.first) is valid
7. Test with different owner types (Organization, Consortium, etc.)

## Acceptance Criteria
- Blueprint supports polymorphic ownership
- Migration updates existing data correctly
- Blueprint.new(owner: Player.first).valid? returns true
- RSpec tests pass for polymorphic ownership
- Backward compatibility maintained

## Agent Assignment
0.33x - Model design and polymorphic associations specialist

## Priority
HIGH

## Stop Condition
Blueprint model supports polymorphic ownership with tests passing

## Commit Message
feat: implement polymorphic ownership for blueprints</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/new_agent/tasks/backlog/2026-02/2026-02-11-HIGH-FEATURE-BLUEPRINT-POLYMORPHIC-OWNERSHIP.md