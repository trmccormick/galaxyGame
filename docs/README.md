# Galaxy Game Documentation

A SimEarth-inspired Rails game featuring realistic space colonization, manufacturing chains, and AI-driven mission planning.

**Tech Stack**: Rails 7.0.8.4 • Ruby 3.2 • PostgreSQL 16

---

## 📋 Quick Navigation

### 👤 For Players
- [Game Mechanics](gameplay/mechanics.md) - Core gameplay loops
- [Terraforming Guide](gameplay/terraforming.md) - Planet transformation
- [User Documentation](user/) - How to play

### 💻 For Developers

#### Getting Started
- [Setup Guide](developer/setup.md) - Development environment
- [Architecture Overview](architecture/overview.md) - System design
- **[Current Status](development/active/CURRENT_STATUS.md)** ⭐ - Active work tracker

#### Active Development (NEW)
- **[Restoration Plan](development/planning/RESTORATION_AND_ENHANCEMENT_PLAN.md)** - 6-phase roadmap
- [Environment Boundaries](development/reference/ENVIRONMENT_BOUNDARIES.md) - Docker/Git rules
- [Grok Task Templates](development/reference/grok_notes.md) - Workflow patterns

#### Completed Work (NEW)
- [Construction Refactor](development/completed/CONSTRUCTION_REFACTOR.md) - Manufacturing pipeline history
- [Admin Dashboard Redesign](developer/ADMIN_DASHBOARD_REDESIGN.md) - Multi-galaxy support with hierarchical navigation

#### Technical Reference
- [Data-Driven Systems](developer/DATA_DRIVEN_SYSTEMS.md) - JSON configuration patterns
- [Blueprint Cost Schema](developer/BLUEPRINT_COST_SCHEMA_GUIDE.md) - Crafting system
- [Testing Framework](developer/ai_testing_framework.md) - AI simulation testing

---

## 🏗️ Core Systems

### Industry & Manufacturing
- [Construction System](architecture/construction_system.md) - Building infrastructure
- [Industrial Chains](architecture/SYSTEM_INDUSTRIAL_CHAINS.md) - Production pipelines
- [Foundry & Lunar Elevator](architecture/foundry_logic_and_lunar_elevator.md) - Heavy industry

### Economic Systems
- [Financial System](architecture/financial_system.md) - Currency and banking
- [Organizations](architecture/organizations_system.md) - Corporations and consortiums
- [Economic Baseline](market/economic_baseline.md) - Market fundamentals
- [Trading & Logistics](../README.md#trading--logistics-system) - Player contracts & insurance

### Planetary Systems
- [Solar System](architecture/solar_system.md) - Sol system generation
- [Geosphere](architecture/geosphere_system.md) - Planetary geology
- [Hydrosphere](architecture/hydrosphere_system.md) - Water systems
- [Biosphere](architecture/biosphere_system.md) - Life and ecosystems
- [Hycean Planets](architecture/hycean_planet_system.md) - Ocean worlds

### Transportation
- [Cycler System](architecture/ai_manager/CYCLER_SYSTEM_ARCHITECTURE.md) - Orbital logistics
- [Wormhole System](architecture/wormhole_system.md) - FTL travel
- [Asteroid Relocation](crafts/asteroid_relocation_tug.md) - Resource transport

### AI & Automation
- [AI Manager Overview](ai_manager/00_architecture_overview.md) - AI decision framework
- [Probe System](ai_manager/01_probe_system.md) - Autonomous exploration
- [Settlement Planning](ai_manager/02_settlement_planning.md) - Colony optimization
- [Precursor Infrastructure](ai_manager/PRECURSOR_INFRASTRUCTURE_CAPABILITIES.md) - System bootstrapping

---

## 📖 Storyline & Lore

### Main Arc
1. [Story Arc](storyline/01_story_arc.md) - Campaign narrative
2. [Crisis Mechanics](storyline/02_crisis_mechanics.md) - Events and challenges
3. [Consortium Framework](storyline/03_consortium_framework.md) - Faction system
4. [Physics & Topology](storyline/04_physics_topology.md) - Universe rules

### Game Design
5. [Deployment Hierarchy](storyline/05_deployment_hierarchy.md) - Settlement expansion
6. [Procedural Generation](storyline/05_procedural_generation.md) - Content creation
7. [AI Intelligence](storyline/06_ai_intelligence.md) - NPC behavior
8. [Economic Systems](storyline/07_economic_systems.md) - Market simulation
9. [Implementation Phases](storyline/08_implementation_phases.md) - Development roadmap
10. [Lore Canon](storyline/09_lore_canon.md) - Universe background

---

## 🎯 Development Phases

### Current: Phase 3 - Integration & Restoration
**Goal**: Reduce test failures from 401 → <50  
**Status**: ~393 failures remaining  
**Approach**: Surgical fixes preserving post-Jan-8 improvements

**Recent Progress**:
- ✅ shell_spec.rb - 66/66 passing
- ✅ consortium_membership_spec.rb - 5/5 passing
- ✅ covering_service_spec.rb - 23/24 passing
- ✅ protoplanet_spec.rb - 10/10 passing (new protoplanet model)
- ✅ terrain generation - Titan GeoTIFF support, protoplanet terrain
- 🔄 financial/account_spec.rb - in progress

### Next: Phase 4 - UI Enhancement
**Prerequisite**: <50 test failures  
**Vision**: SimEarth admin panel + Eve Online mission builder

**Planned Features**:
- System economic projection dashboard
- D3.js resource flow visualization
- Mission profile builder interface
- AI pattern library viewer

### Future: Phase 5 - AI Pattern Learning
**Goal**: Autonomous wormhole expansion  
**Components**:
- Pattern extraction from missions
- Success metric calculation
- Autonomous deployment decisions
- Local resource adaptation

---

## 🔧 Common Development Tasks

### Run Tests
```bash
# Full suite (in container)
docker-compose -f docker-compose.dev.yml exec web bundle exec rspec

# Specific file
docker-compose -f docker-compose.dev.yml exec web bundle exec rspec spec/models/shell_spec.rb

# Check failures
docker-compose -f docker-compose.dev.yml exec web bundle exec rspec --format documentation --dry-run 2>&1 | grep "failed"
```

### Git Workflow (Host Only - NEVER in container)
```bash
git status
git diff galaxy_game/path/to/file.rb
git add galaxy_game/path/to/file.rb
git commit -m "fix: descriptive commit message"
```

### Database Operations
```bash
# Migrate (in container)
docker-compose -f docker-compose.dev.yml exec web bundle exec rails db:migrate

# Seed data
docker-compose -f docker-compose.dev.yml exec web bundle exec rails db:seed
```

---

## 📚 Additional Resources

### Mission Profiles
- [Complete Profile Library](mission_profiles/00_complete_profile_library.md) - All mission templates
- Mission categories: Bootstrapping, Mining, Manufacturing, Exploration

### API Documentation
- [Materials API](api/materials.md) - Material lookup and properties

### System Guides
- [Systems Documentation](systems/) - Detailed subsystem docs
- [Tutorials](tutorials/) - Step-by-step guides

### Wormhole Expansion
- [Wormhole Integration](developer/WORMHOLE_SCOUTING_INTEGRATION.md) - Scouting implementation
- [Expansion Documentation](wormhole_expansion/) - Network mechanics

---

## 🎮 Game Philosophy

**SimEarth Inspiration**: Planetary projection systems showing economic forecasts, resource flows, and terraforming progress

**Eve Online Inspiration**: Complex player-driven economics, mission generation systems, and admin tools for managing universe state

**Realistic Science**: Grounded in real physics and chemistry while maintaining playability

**Player Agency**: Players control logistics, markets, and expansion - NPCs fill gaps but don't dominate

---

## 📝 Documentation Standards

### File Organization
- **development/active/** - Current work tracking
- **development/planning/** - Future roadmaps
- **development/completed/** - Historical records
- **development/reference/** - Technical guides

### Commit Messages
```
fix: restore construction_date tracking in Shell model
feat: add D3.js resource flow visualization
docs: update manufacturing pipeline documentation
test: add E2E integration test for ISRU chain
```

### Documentation Mandate
Every code change must update corresponding .md files to maintain accuracy.

---

**Last Updated**: February 9, 2026  
**Documentation Version**: 2.0 (Reorganized structure)

- [Project README](../README.md) - Project setup and overview
- [Planning Documents](architecture/planning/) - Future development plans
- [Legacy Documentation](../Documentation/) - Original documentation (being migrated)

---

*This documentation is a work in progress. Please report issues or suggest improvements.*