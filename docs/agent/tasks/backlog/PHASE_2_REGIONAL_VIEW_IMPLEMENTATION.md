# Mar 1, 2026 - HIGH: Phase 2 Regional View Implementation

==============================================================================

**AGENT ROLE:** Implementation

**CONTEXT:** Galaxy Game planetary rendering system transitioning from Phase 1 planetary overview (4K canvas) to Phase 2 regional gameplay view (16K canvas) with sprite-based terrain rendering.

**ISSUE:** Current planetary view is static overview only. Need Civ4-style regional view with:
- 16K canvas resolution (100m/pixel)
- NASA biome to sprite mapping
- Unit movement layer preview
- City placement zones
- Performance optimizations

**ROOT CAUSE:** Phase 1 focused on planetary overview with color-based rendering. Phase 2 requires sprite atlas system and higher resolution for gameplay.

**IMPACT:** Blocks regional gameplay features, unit movement visualization, and city placement mechanics.

**REQUIRED FIX:** Implement 16K regional view with sprite-based terrain rendering and gameplay layers.

**IMPLEMENTATION DETAILS:**

1. **Canvas Scaling (16384x8192)**
   - Update canvas dimensions in regional view JavaScript
   - Adjust viewport calculations for 100m/pixel resolution
   - Modify coordinate systems for regional scale

2. **Sprite Atlas Integration**
   - Create galaxy_surface.png (288x32, 9 terrain sprites)
   - Update JSON tileset configuration for regional view
   - Implement NASA biome → sprite coordinate mapping logic

3. **Layer System Enhancement**
   - Add unit movement preview layer
   - Implement city placement zone visualization (worldhouses)
   - Ensure layer toggling works at regional scale

4. **Performance Optimization**
   - Implement viewport culling for 16K canvas
   - Optimize sprite rendering for large areas
   - Add level-of-detail rendering if needed

## ⚠️ CRITICAL DATABASE SAFETY WARNING
**ALL RSpec commands must unset DATABASE_URL to prevent catastrophic development database corruption.**  
**Correct:** `docker-compose -f docker-compose.dev.yml exec -T web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec ...'`  
**Incorrect:** `docker-compose -f docker-compose.dev.yml exec -T web bundle exec rspec ...` (will wipe dev database!)  

**TESTING SEQUENCE:**
1. `docker-compose -f docker-compose.dev.yml exec -T web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/features/regional_view_spec.rb'` (create new spec)
2. Manual testing: Load regional view, verify 16K canvas renders
3. Performance testing: 60fps at regional scale
4. Integration testing: Unit movement and city zones visible

**EXPECTED RESULT:**
- Regional view renders 16384x8192 canvas smoothly
- NASA biomes map correctly to 32x32 sprites
- Unit movement paths display over terrain
- City placement zones highlight available areas
- No performance degradation at 16K resolution

**CRITICAL CONSTRAINTS:**
- All operations must stay inside the web docker container for testing
- All tests must pass before proceeding
- Create/Update Docs: Update TILESET_README.md and PLANETARY_VIEW_INTENT.md
- Commit only changed files on host, not inside docker container
- Follow CONTRIBUTOR_TASK_PLAYBOOK.md git rules
- Reference GUARDRAILS.md for architectural decisions

**MANDATORY REFERENCES:**
- GUARDRAILS.md: [Layer rendering constraints, performance boundaries]
- CONTRIBUTOR_TASK_PLAYBOOK.md: [Git workflow, testing protocols]
- ENVIRONMENT_BOUNDARIES.md: [Docker container operations]

**REMINDER:** This is implementation role - execute code changes, run tests, commit changes following prepared documentation protocols.

==============================================================================