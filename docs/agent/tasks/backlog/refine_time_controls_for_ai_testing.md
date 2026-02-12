# Refine TIME CONTROLS for AI Testing

## Problem Description
The TIME CONTROLS section in admin simulation is intended for AI testing scenarios but uses confusing "tick" terminology and may be better placed under AI Manager rather than simulation controls.

## Current Issues
- "Advance 1 Tick/10 Ticks/100 Ticks" terminology doesn't match space colonization timescales
- Located under "SIMULATION CONTROLS" but primarily for AI testing
- No clear indication this is development-only tool
- Lacks integration with AI manager state

## Proposed Changes

### 1. **Relocate to AI Manager**
Move TIME CONTROLS from `/admin/simulation` to `/admin/ai_manager` as it's primarily for testing AI-driven colony development over time.

### 2. **Rename and Improve Controls**
Replace tick-based controls with time-appropriate actions:
- "Skip 1 Day" (test daily AI decisions)
- "Skip 1 Week" (test weekly economic cycles)
- "Skip 1 Month" (test monthly colony growth)
- "Skip to Date" (jump to specific future date)

### 3. **Add AI Integration**
- Show current AI manager status (running/paused)
- Pause AI during time jumps to prevent conflicts
- Log AI decisions during accelerated periods
- Display accelerated time indicator

### 4. **Add Safety Warnings**
- Clear "DEVELOPMENT ONLY" warnings
- Confirmation dialogs for large time jumps
- Visual indicators when time acceleration is active

## Implementation Steps

### Phase 1: Move to AI Manager
- Remove TIME CONTROLS from `admin/simulation/index.html.erb`
- Add TIME CONTROLS to `admin/ai_manager/index.html.erb` (create if needed)
- Update any related JavaScript functions

### Phase 2: Improve Time Controls
- Change button labels from ticks to time periods
- Add date picker for "Skip to Date" functionality
- Implement time jumping logic in controller

### Phase 3: AI Integration
- Check AI manager status before allowing time jumps
- Add time acceleration indicators
- Log accelerated time periods for debugging

### Phase 4: Safety Features
- Add confirmation modals for time jumps
- Display current game date and acceleration status
- Add emergency stop functionality

## Files to Modify
- `galaxy_game/app/views/admin/simulation/index.html.erb` (remove TIME CONTROLS)
- `galaxy_game/app/views/admin/ai_manager/index.html.erb` (add TIME CONTROLS)
- `galaxy_game/app/controllers/admin/ai_manager_controller.rb` (add time control actions)
- `galaxy_game/app/assets/javascripts/admin/` (update time control functions)

## Acceptance Criteria
- TIME CONTROLS moved to AI Manager section
- Controls use appropriate time units (days/weeks/months)
- Clear development-only warnings
- AI manager integration working
- Safe time jumping with confirmations

## Priority
Medium - Improves AI testing workflow

## Estimated Effort
3-4 hours (relocation + UI improvements + AI integration)