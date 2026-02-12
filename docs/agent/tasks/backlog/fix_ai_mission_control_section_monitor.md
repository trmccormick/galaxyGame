# Fix AI Mission Control Section in Admin Celestial Bodies Monitor

## Problem
The "AI MISSION CONTROL" section in the left taskbar of `/admin/celestial_bodies/:id/monitor` contains misplaced and non-functional elements:

1. **Non-AI buttons mixed with AI testing tools**: "View Public Page" and "Edit Celestial Body" buttons are general navigation/admin tools that don't belong in an AI testing section
2. **Duplicate buttons**: "View Public Page" and "Edit Celestial Body" appear both in AI MISSION CONTROL and ADMIN TOOLS sections
3. **Non-functional AI test buttons**: The first 4 buttons (Resource Extraction, Base Construction, ISRU Pipeline, GCC Bootstrap) have `data-test` attributes but no JavaScript handlers or functionality

## Current State
- AI MISSION CONTROL section contains 6 buttons: 4 AI test placeholders + 2 general navigation buttons
- ADMIN TOOLS section duplicates 2 of those buttons
- AI test buttons have `data-test` attributes but no event handlers in `monitor.js`
- Route `POST /admin/celestial_bodies/:id/run_ai_test` exists but isn't used by the buttons

## Required Changes
1. **Clean up AI MISSION CONTROL section**: Remove "View Public Page" and "Edit Celestial Body" buttons from this section
2. **Relocate AI testing tools**: Move the AI test buttons to `/admin/simulation` page under TIME CONTROLS or TESTING TOOLS
3. **Remove AI MISSION CONTROL section**: Remove the entire section from monitor page since AI testing belongs in simulation controls
4. **Remove duplication**: Ensure ADMIN TOOLS section doesn't duplicate functionality

## Implementation Plan (Option B Selected)
- Move AI test buttons (Resource Extraction, Base Construction, ISRU Pipeline, GCC Bootstrap) to `/admin/simulation/index.html.erb`
- Add them to the existing TESTING TOOLS section alongside TIME CONTROLS
- Remove the entire "AI MISSION CONTROL" section from monitor page
- Keep only monitoring and admin tools in the monitor left panel

## Testing
- Verify no duplicate buttons between sections
- Verify AI test buttons either work or are moved to appropriate location
- Verify admin navigation still works correctly

## Priority
Medium - UI organization issue affecting admin workflow clarity</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/active/fix_ai_mission_control_section_monitor.md