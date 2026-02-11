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

**COMMAND FOR IMPLEMENTATION AGENT:**
```ruby
# File: [path/to/file.rb]
# Method: [method_name]

[code changes here]
```

**TESTING SEQUENCE:**
1. [Step 1 with command]
2. [Step 2 with command]
3. [Verification command]

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
- **Protocol Document**: All tasks defined in LLM_AGENT_TASK_PROTOCOL.md
- **Status Updates**: Real-time status in task tracking tables
- **Clarification Requests**: Comments on specific task sections

### Progress Reporting
- **Daily Updates**: Status changes in tracking tables
- **Blocker Alerts**: Immediate notification with resolution plans
- **Completion Confirmation**: Acceptance criteria verification

### Issue Escalation
- **Technical Blockers**: Document in blocked tasks table
- **Scope Changes**: New task creation required
- **Constraint Violations**: Immediate stop and protocol review

## Task Queue Management

### Priority Assignment
1. **Critical Issues**: Address immediately (system down, data loss)
2. **High Priority**: Next available agent (blocking other work)
3. **Medium Priority**: Schedule based on resource availability
4. **Low Priority**: Backlog for when higher priorities clear

### Queue Optimization
- **Batch Similar Tasks**: Group related changes together
- **Parallel Execution**: Independent tasks run simultaneously
- **Resource Balancing**: Distribute work across available agents
- **Dependency Resolution**: Ensure prerequisite tasks complete first

### Queue Monitoring
- **Burndown Tracking**: Monitor completion velocity
- **Bottleneck Identification**: Track resource constraints
- **Capacity Planning**: Adjust assignments based on agent availability
- **Quality Gates**: Ensure completed tasks meet standards before new assignments

## Documentation Update Requirements

### Code Documentation
- **Inline Comments**: Complex logic explanations
- **Method Documentation**: Purpose, parameters, return values
- **Class Documentation**: Responsibilities and usage patterns
- **Architecture Decisions**: Design rationale and trade-offs

### System Documentation
- **GUARDRAILS.md**: Update for new architectural decisions
- **CONTRIBUTOR_TASK_PLAYBOOK.md**: New protocols or procedures
- **API Documentation**: Interface changes and contracts
- **User Guides**: Feature usage instructions

### Task Documentation
- **Completion Records**: What was done and why
- **Lessons Learned**: What worked/didn't work
- **Future Considerations**: Related improvements identified
- **Knowledge Transfer**: Important context for future tasks

## Integration Testing Protocols

### Unit Integration
- **Component Testing**: Individual units work together
- **Interface Validation**: APIs and contracts function correctly
- **Data Flow**: Information passes correctly between components
- **Error Handling**: Graceful failure modes work

### System Integration
- **End-to-End Testing**: Complete user workflows
- **Performance Validation**: System handles expected loads
- **Compatibility Testing**: Works with existing features
- **Regression Prevention**: Existing functionality preserved

### Cross-System Integration
- **Service Dependencies**: External services work correctly
- **Data Consistency**: Shared data remains valid
- **Security Validation**: No new vulnerabilities introduced
- **Monitoring Integration**: Observability systems updated

## Knowledge Transfer & Learning Capture

### Task Learnings
- **What Worked**: Successful approaches and techniques
- **What Didn't**: Problems encountered and solutions
- **Unexpected Discoveries**: Insights gained during implementation
- **Best Practices**: New patterns or standards identified

### Process Improvements
- **Protocol Updates**: Changes needed to task management
- **Tool Improvements**: Better ways to accomplish tasks
- **Communication Enhancements**: More effective coordination
- **Quality Improvements**: Better ways to ensure reliability

### Future Considerations
- **Related Tasks**: Other work identified during implementation
- **Scalability Notes**: How solution handles future growth
- **Maintenance Items**: Ongoing care requirements
- **Evolution Path**: How feature might develop further

## Task Status Tracking

### Analysis Documents Created
| Date | Document | Purpose | Location |
|------|----------|---------|----------|
| 2026-02-10 | ANALYSIS_SEEDING_FAILURES.md | Complete root cause analysis of seeding failures | data/claude-fix/ANALYSIS_SEEDING_FAILURES.md |
| 2026-02-10 | GROK_FIX_SEEDING.md | Implementation commands for seeding fix | data/claude-fix/GROK_FIX_SEEDING.md |

### Key Findings from Analysis
- **Original Issue Misidentified**: Celestial bodies interface appeared empty due to seeding failure, not solar system naming
- **Root Cause**: SystemBuilderService missing `size` attribute mapping from JSON to model
- **Impact**: All planet creation fails validation ("Size can't be blank"), resulting in 0 celestial bodies
- **Secondary Issue**: Duplicate JSON loading (sol.json + sol-complete.json) causing system conflicts
- **Blocker Status**: This seeding failure blocks ALL planetary work (terrain generation, monitor views, AI training)

### Completed Tasks
| Date | Task | Status | Implementation Agent | Notes |
|------|------|--------|---------------------|-------|
| 2026-02-10 | Create LLM Task Creation Protocol | COMPLETED | Documentation Agent | Established standardized agent task format |
| 2026-02-10 | Fix Terrain Generation Grid Artifacts | COMPLETED | Implementation Agent | Replaced sine wave procedural generation with NASA GeoTIFF pattern-based approach using Earth landmass shapes |
| 2026-02-10 | Fix Database Seeding System Lookup | COMPLETED | Implementation Agent | Fixed StarSystemLookupService to include solar_system identifier checks for both generated and curated systems |
| 2026-02-10 | Add StarSystemLookupService Test Coverage | COMPLETED | Implementation Agent | Created comprehensive RSpec spec file with 7 passing tests covering all lookup scenarios |

### Active Tasks
| Date | Task | Status | Assigned Agent | Next Steps |
|------|------|--------|----------------|------------|
| 2026-02-10 | Fix System Seeding - Missing Size Attribute | BLOCKED | N/A | Waiting on seeding fix - interface shows empty because no celestial bodies exist in database |

### Blocked Tasks
| Date | Task | Blocker | Resolution Plan |
|------|------|---------|-----------------|
| N/A | N/A | N/A | N/A |

### Backlog Tasks
| Date | Task | Priority | Estimated Effort | Dependencies |
|------|------|----------|------------------|--------------|
| TBD | AI Manager Mission Patterns Audit | HIGH | 4-6 hours | GUARDRAILS.md compliance check |
| TBD | Documentation Completeness Review | LOW | 1-2 hours | Doc inventory and gaps analysis |

## Agent Behavior Validation Checklist

### Pre-Task Assignment
- [ ] Agent role clearly defined (Documentation vs Implementation)
- [ ] All mandatory references included
- [ ] Task follows established template format
- [ ] No role overlap (planning agents don't execute, implementation agents don't plan)
- [ ] Clear acceptance criteria defined

### During Task Execution
- [ ] Agent acknowledges and follows all referenced constraints
- [ ] Implementation agents request clarification rather than making assumptions
- [ ] Documentation agents prepare complete commands without executing them
- [ ] All communication goes through this protocol document

### Post-Task Validation
- [ ] Task completion verified against acceptance criteria
- [ ] Documentation updated as specified
- [ ] Status tracking updated
- [ ] No constraint violations occurred
- [ ] Clear handoff to next task/agent if needed

## Emergency Protocols

### Constraint Violation Detected
1. **IMMEDIATE STOP**: Agent halts all operations
2. **REPORT**: Document violation in task status
3. **REVIEW**: Documentation agent reviews and corrects task format
4. **REASSIGN**: Only proceed with corrected task format

### Communication Breakdown
1. **CLARIFY**: Request specific clarification through protocol channels
2. **DOCUMENT**: Log communication issues in task status
3. **ESCALATE**: If unclear, mark task as blocked with resolution plan

### Scope Creep Prevention
1. **STICK TO ROLE**: Agents only perform tasks within their defined role
2. **REDIRECT**: Out-of-scope requests routed to appropriate agent type
3. **DOCUMENT**: Scope changes require new task creation following template

## Integration with Existing Systems

### Reference Document Updates
When creating tasks, ensure commands reference current versions of:
- **GUARDRAILS.md**: Current AI Manager rules and economic boundaries
- **CONTRIBUTOR_TASK_PLAYBOOK.md**: Current testing and git protocols
- **ENVIRONMENT_BOUNDARIES.md**: Current container and safety boundaries

### Task Dependencies
- **Sequential Tasks**: Later tasks depend on earlier task completion
- **Parallel Tasks**: Independent tasks that can run simultaneously
- **Blocked Tasks**: Tasks waiting on external factors or other task completion

### Quality Assurance
- **Template Compliance**: All tasks must follow the exact template format
- **Reference Completeness**: All mandatory references must be included
- **Clarity Check**: Tasks must be unambiguous and executable by agents
- **Scope Control**: Tasks must fit within agent role boundaries

This protocol ensures clean separation of concerns, prevents constraint violations, and maintains development velocity through structured agent task management.

---

## 02/10/2026 - CRITICAL: Fix Admin Celestial Bodies Interface
==============================================================================

**AGENT ROLE:** Implementation Agent

**CONTEXT:** Admin interface `/admin/celestial_bodies` for monitoring planetary systems and terrain generation

**ISSUE:** Admin interface shows "4 total bodies" but "No celestial bodies found in the database" after seeding

**ROOT CAUSE:** SystemBuilderService.create_solar_system() looks for @system_data[:solar_system] but sol-complete.json has solar system data at root level, causing SolarSystem to be named "sol-complete" instead of "Sol"

**IMPACT:** Cannot monitor Sol system planets (Earth, Mars, etc.), terrain generation may fail due to missing celestial body records

**REQUIRED FIX:** Modify SystemBuilderService to use root-level solar system data from sol-complete.json

**COMMAND FOR IMPLEMENTATION AGENT:**
```ruby
# Fix SystemBuilderService solar system data handling
# File: app/services/star_sim/system_builder_service.rb
# Method: create_solar_system

def create_solar_system
  # FIX: Use root level data for sol-complete.json, fallback to nested solar_system key
  solar_data = @system_data[:solar_system] || @system_data
  
  system_name = solar_data[:name] || @system_data[:name] || name
  system_identifier = solar_data[:identifier] || @system_data[:identifier] || system_name.parameterize.upcase
  
  @solar_system = SolarSystem.find_or_create_by!(identifier: system_identifier) do |sys|
    sys.name = system_name
    sys.galaxy = @galaxy
    puts "Creating solar system: #{system_name} (#{system_identifier})" if @debug_mode
  end
end
```

**TESTING SEQUENCE:**
1. Clear existing data: `SolarSystem.destroy_all; CelestialBodies::Star.destroy_all; CelestialBodies::CelestialBody.destroy_all`
2. Run seeds.rb to recreate data
3. Verify Sol system creation: `SolarSystem.find_by(name: 'Sol')&.celestial_bodies&.count == 44`
4. Check admin interface displays celestial bodies list

**EXPECTED RESULT:**
- Admin /celestial_bodies shows populated list of Sol system bodies
- Earth, Mars, Venus, Mercury appear with correct attributes
- Terrain generation works for terrestrial worlds
- Development monitoring functional

**CRITICAL CONSTRAINTS:**
- All operations must stay inside the web docker container for all rspec testing
- All tests must pass before proceeding
- Create/Update Docs: Update docs/developer/TERRAFORMING_SIMULATION.md with fix details
- Commit only changed files on host, not inside docker container
- Follow CONTRIBUTOR_TASK_PLAYBOOK.md git rules (no `git add .`, atomic commits)
- Reference GUARDRAILS.md for architectural integrity (namespace preservation, path constants)

**MANDATORY REFERENCES:**
- GUARDRAILS.md: Section 6 (Architectural Integrity), Section 7 (Path Configuration Standards)
- CONTRIBUTOR_TASK_PLAYBOOK.md: ANGP (logging), IQFP (synthesis reports), LEC (cleanup)
- ENVIRONMENT_BOUNDARIES.md: Container operations protocol, prohibited actions
- ANALYSIS_SEEDING_FAILURES.md: Complete root cause analysis and testing strategy
- GROK_FIX_SEEDING.md: Detailed implementation commands and testing steps

---

## 02/10/2026 - CRITICAL: Fix System Seeding - Missing Size Attribute
==============================================================================

**AGENT ROLE:** Implementation Agent

**CONTEXT:** System seeding process for planetary data from JSON files to database

**ISSUE:** All celestial body creation fails with "Size can't be blank" validation error, resulting in 0 planets in database and empty admin interface

**ROOT CAUSE:** SystemBuilderService.create_celestial_body() does not map the 'size' field from JSON data to ActiveRecord attributes, causing model validation to fail

**IMPACT:** Complete system seeding failure - no planets created, admin interface shows empty systems, blocks all planetary work (terrain generation, monitor views, AI training)

**REQUIRED FIX:** Add size attribute mapping in SystemBuilderService and fix JSON file loading to prevent duplicates

**COMMAND FOR IMPLEMENTATION AGENT:**
```ruby
# File: app/services/star_sim/system_builder_service.rb
# Method: create_celestial_body_record (or similar attribute mapping method)

# ADD size mapping to attribute hash
attributes[:size] = body_data['size']

# Also check for other missing attributes:
# - albedo, insolation, orbital_period may also be missing
```

**TESTING SEQUENCE:**
1. Test attribute mapping in Rails console: `planet_data['size']` should map to `attributes[:size]`
2. Create test planet: `CelestialBodies::CelestialBody.new(attributes).valid?` should return true
3. Run seeding: `rails db:seed` should create 50+ celestial bodies
4. Verify dashboard: Admin interface should show populated systems with planet counts

**EXPECTED RESULT:**
- CelestialBodies::CelestialBody.count > 0 (currently 0)
- Sol system has 8+ planets (Earth, Mars, Venus, etc.)
- Admin /celestial_bodies shows populated list instead of "No celestial bodies found"
- No duplicate systems from loading both sol.json and sol-complete.json

**CRITICAL CONSTRAINTS:**
- All operations must stay inside the web docker container for all testing
- Test in Rails console before running full seeding
- Create/Update Docs: Update ANALYSIS_SEEDING_FAILURES.md with resolution details
- Commit only changed files on host, not inside docker container
- Follow CONTRIBUTOR_TASK_PLAYBOOK.md git rules (no `git add .`, atomic commits)

**MANDATORY REFERENCES:**
- GUARDRAILS.md: Section 6 (Architectural Integrity), Section 7 (Path Configuration Standards)
- CONTRIBUTOR_TASK_PLAYBOOK.md: ANGP (logging), IQFP (synthesis reports), LEC (cleanup)
- ENVIRONMENT_BOUNDARIES.md: Container operations protocol, prohibited actions
- ANALYSIS_SEEDING_FAILURES.md: Complete root cause analysis and testing strategy
- GROK_FIX_SEEDING.md: Detailed implementation commands and testing steps

## 02/10/2026 - HIGH: Fix Sol GeoTIFF Terrain Generation - Planet-Specific Elevation Data
==============================================================================

**AGENT ROLE:** Implementation Agent

**CONTEXT:** Planetary terrain generation for Sol system planets using NASA GeoTIFF elevation data

**ISSUE:** All Sol planets show identical, pixilated terrain because PlanetaryMapGenerator uses generic Earth landmass reference for all planets instead of planet-specific GeoTIFF elevation data

**ROOT CAUSE:** generate_planetary_map_with_patterns() method calls load_earth_landmass_reference() for all planets, ignoring available planet-specific elevation data in data/geotiff/processed/ (earth_1800x900.asc.gz, mars_1800x900.asc.gz, luna_1800x900.asc.gz, etc.)

**IMPACT:** Eden worlds appear identical and artificial, terrain generation doesn't reflect real planetary geography, poor user experience for planetary monitoring

**REQUIRED FIX:** Modify PlanetaryMapGenerator to load planet-specific elevation data from GeoTIFF files instead of generic Earth reference

**COMMAND FOR IMPLEMENTATION AGENT:**
```ruby
# File: app/services/ai_manager/planetary_map_generator.rb
# Method: generate_planetary_map_with_patterns

def generate_planetary_map_with_patterns(planet:, sources:, options: {})
  Rails.logger.info "[PlanetaryMapGenerator] Generating pattern-based map for #{planet.name}"

  width = options[:width] || 80
  height = options[:height] || 50

  # FIX: Load planet-specific elevation data instead of generic Earth reference
  elevation_grid = load_planet_specific_elevation(planet, width, height)
  
  # If no planet-specific data, fall back to pattern-based generation
  if elevation_grid.nil?
    # Step 1: Get landmass reference (where continents should be)
    landmass_mask = load_earth_landmass_reference(target_width: width, target_height: height)

    # Step 2: Get NASA patterns for this planet type
    nasa_patterns = select_nasa_patterns_for_planet(planet)

    # Step 3: Generate elevation grid using patterns + landmass
    elevation_grid = generate_elevation_from_patterns(
      landmass_mask: landmass_mask,
      patterns: nasa_patterns,
      width: width,
      height: height
    )
  end

  # Step 4: Generate biomes (barren by default, can be terraformed later)
  biome_grid = generate_barren_biomes(
    elevation_grid: elevation_grid,
    planet: planet
  )

  # Step 5: Add resource markers and strategic locations
  resources = generate_resource_locations(elevation_grid, planet)
  strategic_markers = generate_strategic_markers_from_elevation(elevation_grid)

  # Step 6: Count biomes
  biome_counts = Hash.new(0)
  biome_grid.flatten.each { |biome| biome_counts[biome] += 1 }

  {
    terrain_grid: biome_grid,
    biome_counts: biome_counts,
    elevation_data: elevation_grid,
    strategic_markers: strategic_markers,
    planet_name: planet.name,
    planet_type: planet.type,
    metadata: {
      generated_at: Time.current.iso8601,
      source_maps: [],
      generation_options: options,
      width: width,
      height: height,
      quality: elevation_grid.nil? ? 'pattern_based_realistic' : 'geotiff_based_realistic',
      patterns_used: nasa_patterns&.keys || [],
      landmass_source: elevation_grid.nil? ? 'earth_reference' : "#{planet.name.downcase}_geotiff"
    }
  }
end

# ADD new method to load planet-specific elevation data
def load_planet_specific_elevation(planet, target_width, target_height)
  planet_name = planet.name.downcase
  
  # Map planet names to GeoTIFF filenames
  geotiff_files = {
    'earth' => 'earth_1800x900.asc.gz',
    'mars' => 'mars_1800x900.asc.gz', 
    'luna' => 'luna_1800x900.asc.gz',
    'venus' => 'venus_1800x900.asc.gz',
    'mercury' => 'mercury_1800x900.asc.gz',
    'titan' => 'titan_1800x900_final.asc.gz'
  }
  
  filename = geotiff_files[planet_name]
  return nil unless filename
  
  filepath = Rails.root.join('data', 'geotiff', 'processed', filename)
  return nil unless File.exist?(filepath)
  
  Rails.logger.info "[PlanetaryMapGenerator] Loading GeoTIFF elevation data for #{planet.name}"
  
  begin
    # Load and resample elevation data
    elevation_data = load_ascii_grid(filepath.to_s)
    
    # Resample to target dimensions
    resampled = resample_elevation_grid(
      elevation_data[:elevation], 
      elevation_data[:width], 
      elevation_data[:height],
      target_width, 
      target_height
    )
    
    Rails.logger.info "[PlanetaryMapGenerator] Successfully loaded #{planet.name} elevation data: #{target_width}x#{target_height}"
    resampled
  rescue => e
    Rails.logger.warn "[PlanetaryMapGenerator] Failed to load #{planet.name} GeoTIFF data: #{e.message}"
    nil
  end
end

# ADD method to resample elevation grid to target dimensions
def resample_elevation_grid(source_grid, source_width, source_height, target_width, target_height)
  return source_grid if source_width == target_width && source_height == target_height
  
  target_grid = Array.new(target_height) { Array.new(target_width, 0.0) }
  
  # Simple bilinear resampling
  scale_x = source_width.to_f / target_width
  scale_y = source_height.to_f / target_height
  
  target_height.times do |y|
    target_width.times do |x|
      # Map target coordinates to source coordinates
      src_x = x * scale_x
      src_y = y * scale_y
      
      # Bilinear interpolation
      x0 = src_x.floor
      y0 = src_y.floor
      x1 = [x0 + 1, source_width - 1].min
      y1 = [y0 + 1, source_height - 1].min
      
      # Get four surrounding pixels
      q00 = source_grid[y0][x0]
      q01 = source_grid[y0][x1] 
      q10 = source_grid[y1][x0]
      q11 = source_grid[y1][x1]
      
      # Interpolate
      target_grid[y][x] = bilinear_interpolate(q00, q01, q10, q11, src_x - x0, src_y - y0)
    end
  end
  
  target_grid
end

# ADD method to resample elevation grid to target dimensions
def resample_elevation_grid(source_grid, source_width, source_height, target_width, target_height)
  return source_grid if source_width == target_width && source_height == target_height
  
  target_grid = Array.new(target_height) { Array.new(target_width, 0.0) }
  
  # Simple bilinear resampling
  scale_x = source_width.to_f / target_width
  scale_y = source_height.to_f / target_height
  
  target_height.times do |y|
    target_width.times do |x|
      # Map target coordinates to source coordinates
      src_x = x * scale_x
      src_y = y * scale_y
      
      # Bilinear interpolation
      x0 = src_x.floor
      y0 = src_y.floor
      x1 = [x0 + 1, source_width - 1].min
      y1 = [y0 + 1, source_height - 1].min
      
      # Get four surrounding pixels
      q00 = source_grid[y0][x0]
      q01 = source_grid[y0][x1] 
      q10 = source_grid[y1][x0]
      q11 = source_grid[y1][x1]
      
      # Interpolate
      target_grid[y][x] = bilinear_interpolate(q00, q01, q10, q11, src_x - x0, src_y - y0)
    end
  end
  
  target_grid
end

# ADD bilinear interpolation helper
def bilinear_interpolate(q00, q01, q10, q11, dx, dy)
  (q00 * (1 - dx) * (1 - dy) + 
   q01 * dx * (1 - dy) + 
   q10 * (1 - dx) * dy + 
   q11 * dx * dy)
end

# ADD method to load ASCII grid elevation data
def load_ascii_grid(filepath)
  require 'zlib'
  
  lines = if filepath.end_with?('.gz')
            Zlib::GzipReader.open(filepath) { |gz| gz.read.lines }
          else
            File.readlines(filepath)
          end

  ncols = lines[0].split[1].to_i
  nrows = lines[1].split[1].to_i
  xllcorner = lines[2].split[1].to_f
  yllcorner = lines[3].split[1].to_f
  cellsize = lines[4].split[1].to_f
  nodata = lines[5].split[1].to_f

  elevation = lines[6..-1].map { |line| line.split.map(&:to_f) }

  # Normalize to 0-1 range
  flat = elevation.flatten.reject { |v| v == nodata }
  min_elev = flat.min
  max_elev = flat.max

  normalized = elevation.map do |row|
    row.map { |v| v == nodata ? 0.0 : (v - min_elev) / (max_elev - min_elev) }
  end

  {
    width: ncols,
    height: nrows,
    elevation: normalized,
    bounds: { xll: xllcorner, yll: yllcorner, cellsize: cellsize },
    original_range: { min: min_elev, max: max_elev }
  }
end
```

**TESTING SEQUENCE:**
1. Regenerate terrain for Mars: `AutomaticTerrainGenerator.new.generate_terrain_for_body(CelestialBody.find_by(name: 'Mars'))`
2. Check admin interface: Visit `/admin/celestial_bodies/[mars_id]/monitor` and verify unique terrain patterns
3. Compare with Earth: Regenerate Earth terrain and verify different elevation patterns
4. Test edge cases: Verify fallback to pattern generation for planets without GeoTIFF data
5. Performance check: Ensure terrain generation completes within 30 seconds

**EXPECTED RESULT:**
- Each Sol planet shows unique, realistic terrain based on actual NASA elevation data
- Mars shows polar ice caps, Valles Marineris, Olympus Mons regions
- Earth shows familiar continental shapes and ocean basins  
- Luna shows cratered highlands and maria
- Venus shows volcanic plains and highlands
- No more identical pixilated terrains across planets
- Improved terrain quality and realism for planetary monitoring

**CRITICAL CONSTRAINTS:**
- All operations must stay inside the web docker container for all rspec testing
- All tests must pass before proceeding
- Create/Update Docs: Update docs/developer/TERRAFORMING_SIMULATION.md with GeoTIFF integration details
- Commit only changed files on host, not inside docker container
- Follow CONTRIBUTOR_TASK_PLAYBOOK.md git rules (no `git add .`, atomic commits)
- Reference GUARDRAILS.md for architectural integrity (namespace preservation, path constants)

**MANDATORY REFERENCES:**
- GUARDRAILS.md: Section 6 (Architectural Integrity), Section 7 (Path Configuration Standards)
- CONTRIBUTOR_TASK_PLAYBOOK.md: ANGP (logging), IQFP (synthesis reports), LEC (cleanup)
- ENVIRONMENT_BOUNDARIES.md: Container operations protocol, prohibited actions
- ANALYSIS_SEEDING_FAILURES.md: Complete root cause analysis and testing strategy
- GROK_FIX_SEEDING.md: Detailed implementation commands and testing steps

**REMINDER:** Implementation agents execute prepared commands only. Request clarification for any ambiguities rather than making assumptions.