# MVP Optimization Planning Tasks
**Status:** Planning Phase - Post-Test Suite Restoration
**Priority:** High (Performance blocks user experience)
**Context:** FreeMars comparison shows simple turn-based mechanics work well. Galaxy Game needs optimization to match that polish while maintaining AI complexity.

## Phase 1: Critical Performance Fixes (Immediate - 2-3 weeks)
**Goal:** Fix blocking performance issues before UI work

### Task 1.1: Database Query Optimization **[HIGH PRIORITY]**
**Why:** Current N+1 queries will kill performance with multiple settlements
**Scope:** Add indexes, optimize AI Manager queries, eliminate N+1 issues
**Success Criteria:**
- AI decision time <500ms per settlement
- Admin dashboard loads in <2 seconds
- No N+1 queries in AI Manager services

### Task 1.2: Terrain Loading Optimization **[HIGH PRIORITY]**
**Why:** 140MB GeoTIFF files load slowly, blocking map rendering
**Scope:** Implement terrain pattern caching, compress assets, lazy loading
**Success Criteria:**
- Terrain generation <5 seconds for Sol system
- Memory usage <500MB during normal operation
- Cached patterns reduce I/O by 90%

### Task 1.3: AI Performance Monitoring **[MEDIUM PRIORITY]**
**Why:** No visibility into AI bottlenecks
**Scope:** Add performance metrics, decision latency tracking, optimization alerts
**Success Criteria:**
- AI performance dashboard in admin interface
- Alert when decisions take >1 second
- Historical performance trends

## Phase 2: Scalability Foundations (Post-Phase 1 - 4-6 weeks)
**Goal:** Prepare for multi-settlement scenarios

### Task 2.1: Background Job Infrastructure **[MEDIUM PRIORITY]**
**Why:** AI calculations block UI, terrain generation is synchronous
**Scope:** Implement Sidekiq/Redis for async processing
**Success Criteria:**
- AI decisions run asynchronously
- Terrain generation doesn't block UI
- Job queue monitoring in admin dashboard

### Task 2.2: Memory Management **[MEDIUM PRIORITY]**
**Why:** No caching strategy for simulation state
**Scope:** Implement Redis caching for celestial body data, AI state
**Success Criteria:**
- 50% reduction in database queries
- Cached simulation state survives restarts
- Memory usage scales linearly with settlements

### Task 2.3: Container Resource Limits **[LOW PRIORITY]**
**Why:** No production deployment planning
**Scope:** Define Docker resource limits, monitoring
**Success Criteria:**
- Docker Compose prod configuration
- Resource usage monitoring
- Auto-scaling guidelines

## Phase 3: Advanced Optimization (Future - Post-MVP)
**Goal:** Performance for 10+ settlements, complex scenarios

### Task 3.1: Multi-Threaded AI **[FUTURE]**
**Why:** Single-threaded AI limits concurrent settlements
**Scope:** Parallel AI decision making, settlement coordination
**Success Criteria:**
- 10 settlements process simultaneously
- Decision quality maintained
- Coordination overhead <10%

### Task 3.2: Database Sharding **[FUTURE]**
**Why:** Single database won't scale to galaxy-wide simulation
**Scope:** Multi-database architecture for different systems
**Success Criteria:**
- Independent system simulations
- Cross-system trade performance maintained
- Migration path from single DB