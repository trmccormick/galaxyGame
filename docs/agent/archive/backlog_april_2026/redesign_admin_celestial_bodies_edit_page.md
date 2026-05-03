# Redesign Admin Celestial Bodies Edit Page

## Problem
The current edit page (`/admin/celestial_bodies/:id/edit`) is overcomplicated and incorrectly designed. It mixes basic property editing with complex AI terrain generation features, forcing manual terrain generation instead of automatic loading. The page should be simplified to focus on basic properties with optional terrain regeneration.

## Current State
- Edit page includes complex AI map selection and generation UI
- Manual terrain generation required instead of automatic GeoTIFF loading
- Poor separation between property editing and terrain operations
- "Generate Earth Map with AI" features clutter the interface
- Map Studio access is indirect and confusing

## Required Changes

### Phase 1: Simplify Edit Page Interface
Remove complex AI features and streamline to essential functions:
- Keep only name and alias editing fields
- Remove AI map selection and generation UI
- Remove complex terrain analysis features
- Clean up navigation and button layout

### Phase 2: Add Terrain Regeneration
Implement optional terrain regeneration for admin override:
- Add "🔄 Regenerate Terrain" button for manual regeneration
- Button should trigger automatic terrain generation (GeoTIFF or procedural)
- Include confirmation dialog to prevent accidental regeneration
- Show regeneration status/progress

### Phase 3: Improve Navigation
Enhance access to related features:
- Add clear "🗺️ Map Studio" button for terrain editing
- Add "👁️ Monitor" button for viewing current terrain
- Ensure buttons are prominently placed and clearly labeled
- Remove confusing AI-related navigation

### Phase 4: Implement Automatic Terrain Loading
Ensure terrain loads automatically during creation:
- Sol worlds automatically use available GeoTIFF data
- Generated worlds use procedural generation based on type
- Remove manual generation as primary workflow
- Terrain regeneration becomes admin override option

## Success Criteria
- Edit page shows only name/alias fields and regeneration button
- Terrain loads automatically for all worlds (GeoTIFF for Sol, procedural for others)
- Clear navigation to Map Studio and Monitor views
- No complex AI features cluttering the interface
- Admins can easily rename worlds and regenerate terrain when needed

## Dependencies
- Access to `app/views/admin/celestial_bodies/edit.html.erb`
- Terrain generation service integration
- GeoTIFF automatic loading implementation
- Map Studio interface for terrain editing

## Risk Assessment
- Low risk: Simplification reduces complexity and potential errors
- User impact: Improved UX with clearer workflows
- Backwards compatibility: Maintains existing data editing capabilities

## Priority
Medium-High - Improves admin usability and corrects fundamental workflow design issues affecting daily operations.</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/redesign_admin_celestial_bodies_edit_page.md