# Construction System Refactoring & Development Plan

## Current Architecture Overview

### Settlement Types
- **BaseSettlement** - Parent model for all planetary settlements
  - `settlement_type` enum: `base` (0-9 pop), `outpost` (10-99), `settlement` (100+)
  - Has many structures (worldhouses, domes, habitats, etc.)
  - Can span multiple geological features (surface + underground + enclosed areas)
  - Location is emergent from structures built, not a fixed type

- **SpaceStation** - Separate class for orbital settlements
  - Fundamentally different: shell-based construction, orbital mechanics
  - Has docking, pressurization, module systems
  - Not part of population-based progression

**Decision: No "SurfaceSettlement" type needed** - settlements naturally span multiple locations through their structures.

---

## Geological Features System

### Feature Models (Natural Things)
Located in `app/models/celestial_bodies/features/`

- **BaseFeature** - Parent for all geological features
  - Statuses: `natural`, `surveyed`, `enclosed`, `pressurized`, `settlement_established`
  - Can have worldhouse structure built on it
  - Can be discovered, surveyed, enclosed, pressurized

- **LavaTube** - Underground cave system
  - Has natural skylights (roof openings)
  - Has natural access points (side/end openings)
  - Can be converted to worldhouse habitat

- **Crater** - Impact crater
  - Can have crater dome built over it
  - May contain water ice resources

- **Valley** - Surface depression
  - Can have worldhouse built over it
  - May have predefined segments for construction

- **Canyon** - Deep surface cut
  - Similar to valley for worldhouse purposes

- **Skylight** - Natural opening in roof of feature
  - Belongs to parent feature (lava tube, cave, etc.)
  - Can be covered with transparent or structural panels
  - Circular geometry (diameter-based)

- **AccessPoint** - Natural opening in side/end of feature
  - Belongs to parent feature
  - Can be: sealed permanently, converted to airlock, converted to hangar, or connector tunnel
  - Size types: small, medium, large

---

## Structure Models (Built Things)
Located in `app/models/structures/`

### Current Structures

- **Worldhouse** - Structure built on geological feature
  - Built on LavaTube, Valley, or Canyon
  - Divided into WorldhouseSegments for construction
  - Encloses the natural feature to make it habitable

- **WorldhouseSegment** - Buildable portion of worldhouse
  - Tracks construction progress
  - Can contain skylight (uses transparent panels)
  - Regular segments use structural panels
  - Built using SegmentCoveringService

- **CraterDome** - Dome structure over crater
  - Built on Crater feature
  - Single large structure (not segmented like worldhouse)
  - **Needs refactoring** to add `geological_feature_id` like Worldhouse

- **BaseStructure** - Parent for all structures
  - Belongs to settlement
  - Has operational_data (jsonb)

### Old Structure Files (Migration Context - 2026-01-18)

**Important: These represent the Worldhouse Evolution**

- `app/models/structures/skylight.rb` - **LEGACY TABLE REFERENCE**
  - Uses `self.table_name = 'skylights'` to maintain compatibility with 'skylights' table
  - Originally: Natural lava tube skylights that could be covered
  - Evolution: Generic worldhouse enclosure system for ANY feature opening
  - **Architecture Shift**: Separated into two concerns:
    - `CelestialBodies::Features::Skylight` - Natural planetary features (actual roof openings)
    - `Structures::Skylight` - Worldhouse enclosure records (construction status for covering)
  - **Why Both Exist**: Natural features (discovery) vs construction status (enclosure process)
  - Related to regolith I-beam + panel construction methodology (see Worldhouse Construction below)

- `app/models/structures/access_point.rb` - LEGACY
  - Being replaced by CelestialBodies::Features::AccessPoint
  - Natural openings in feature sides/ends

---

## Worldhouse Construction Methodology

### Generic Regolith I-Beam + Panel System

**Design Philosophy**: Lowest-cost construction using in-situ resources

**Construction Materials**:
1. **3D Printed I-Beams**
   - Source: Depleted planetary regolith
   - Enhancement: Possibly enhanced for structural strength on-world
   - Process: ISRU (In-Situ Resource Utilization)
   - Function: Structural framework for enclosures

2. **Generic Panel Technology**
   - Types: Structural panels (opaque) or transparent panels (for skylights)
   - Purpose: Sealing enclosed areas for pressurization
   - Manufacturing: On-site fabrication from local materials

**First Implementation: Luna Settlement**
- Target: First habitable settlement on Luna (Moon)
- Method: Seal natural lava tube using I-beam framework + panels
- Goal: Lowest cost option for initial human habitation
- Progression: Proves concept for all subsequent construction

**Expansion Path**:
1. **Luna → L1 Station**
   - Apply same I-beam + panel tech to L1 station construction
   - Built at Earth-Moon L1 Lagrange point
   - Enables shipyard capabilities

2. **L1 → Depot**
   - Construct warehouse and refueling depot using proven methodology
   - Supports logistics for deeper space operations

3. **L1 Shipyard → Tug & Cycler Construction**
   - Repair station + shipyard facilities
   - Enables construction of:
     - **Tugs**: Short-range cargo/crew transfer craft
     - **Cyclers**: Long-range efficient transport (Mars cycler orbits)

**Worldhouse Enclosure Process**:
- Survey natural feature (lava tube, valley, crater, etc.)
- Design segment layout for enclosure
- 3D print I-beams from local regolith
- Fabricate panels (structural or transparent)
- Assemble framework and seal
- Pressurize and make habitable

---

## Construction Services System

### Current Services
Located in `app/services/construction/`

#### Working Services

1. **CoveringService** (Base Class)
   - Abstract service for covering openings/segments
   - Calculates materials using CoveringCalculator
   - Creates ConstructionJob
   - Manages material requests and equipment requests
   - Updates coverable status through phases

2. **SegmentCoveringService** (extends CoveringService)
   - Covers WorldhouseSegments
   - Handles both transparent panels (for skylights) and structural panels
   - Complexity factor for large segments (>1000 km²)
   - Creates construction phases for massive segments
   - **This should handle skylight covering too!**

3. **HangarService**
   - Converts large AccessPoint to hangar structure
   - Creates Hangar structure connected to access point
   - Updates access point conversion_status through phases
   - Handles material/equipment requirements

4. **StationConstructionService**
   - Builds space station components (airlocks, docking ports, utilities)
   - Handles station shell construction workflow
   - Uses source constraint tags (e.g., lunar-derived materials)

#### Shell Construction Lifecycle

**Construction Date Tracking:**
When `schedule_shell_construction!` is called on any structure with shell capability:
- Sets `construction_date` to `Time.current` - marks when construction scheduling began
- Sets `panel_type` (structural_cover_panel, transparent_panel, etc.)
- Updates `shell_status` from 'planned' → 'framework_construction'
- Creates ConstructionJob with material/equipment requests via MaterialRequestService
- Creates equipment requests via Manufacturing::EquipmentRequest

**Shell Status Progression:**
- `planned` - Shell design complete, awaiting construction scheduling
- `framework_construction` - Construction scheduled, materials/equipment requested
- `panels_installed` - Panel installation in progress
- `sealed` - Shell complete and pressure-ready

**Key Fields:**
- `construction_date` - Timestamp when construction was scheduled (not completion)
- `panel_type` - Type of panels used (structural, transparent, etc.)
- `shell_status` - Current construction phase

5. **CoveringCalculator**
   - Material calculations for panels and I-beams
   - Handles different panel sizes and types
   - Printer requirement calculations
   - Works for both rectangular and circular openings

#### Services That May Be Redundant

- **SkylightService** (extends CoveringService)
  - Might be redundant - skylights are just segments that need transparent panels
  - **Decision needed**: Keep or remove in favor of SegmentCoveringService?

---

## Pressurization System

### Current Pressurization Services
Located in `app/services/pressurization/`

1. **PressurizationService** - Main service
   - Takes any enclosed environment with atmosphere
   - Calculates gas needs using PV=nRT
   - Adapts atmospheric mix based on celestial body
     - Mars: Detects abundant Ar, adjusts mix to use more argon
     - Moon: Standard Earth-like mix
   - Consumes gases from settlement inventory
   - Updates atmosphere composition and pressure
   - Works for: lava tubes, domes, habitats, crafts, any enclosed structure

2. **BasePressurizationService** - Low-level calculations
   - Ideal gas law calculations
   - Gas mixture ratios
   - Breathability checks
   - Molar mass lookups

3. **HabitatPressurizationService** (extends Base)
   - Volume calculations for different habitat types
   - Sealing verification before pressurization
   - Updates habitat atmosphere status

4. **LavatubePressurizationService** (extends Base)
   - Cylindrical volume calculations
   - Section-by-section pressurization
   - Seal verification at section boundaries

### Atmosphere Model
- Polymorphic: belongs to celestial_body, craft, or structure
- Tracks: pressure, temperature, composition, sealing_status
- Has target_pressure and target_composition for goals
- Methods: habitable?, stable?, seal!/unseal!

---

## Mission Flow - Lunar Precursor (Current)

### Robotic Phase (No Crew)
1. Heavy Lift Transport lands with robots and equipment
2. Deploy power systems (RTG, solar panels, PPMU)
3. Deploy surveyor robots to map lava tube
4. Deploy harvester robots to collect regolith
5. Deploy volatiles extractor to get O2 from regolith
6. Deploy I-beam printer and shell printer
7. Prepare lava tube entrance
8. **Seal lava tube** with airlocks
9. **Cover skylights** with transparent panels
10. **Pressurize** using shipped N2 + extracted O2

### Gas Sources (Lunar)
- **N2**: Shipped from Earth (2000kg in cryogenic storage)
- **O2**: Extracted from regolith via volatiles extractor
- **Mix**: Standard Earth-like (78% N2, 21% O2, 1% Ar)

### Crew Phase
- Habitat already sealed and pressurized
- Crew arrives and moves in

---

## Future Mission Flow - Mars Precursor (Not Yet Designed)

### Key Differences from Lunar

#### Mars Atmosphere Advantage
- Mars has thin atmosphere: ~0.6 kPa (vs Moon's vacuum)
- Composition: 95.3% CO2, 2.7% N2, 1.6% Ar, 0.13% O2
- **Can compress for free** instead of manufacturing everything

#### Pressurization Strategy

**Phase 1: Low-Pressure Seal Test (~40 kPa)**
1. Seal all worldhouse segments/lava tube
2. Compress Mars atmosphere to 40 kPa (~67x surface pressure)
3. Monitor for leaks over 24-48 hours
4. Fix any issues before proceeding
5. **Uses ambient atmosphere (free!) - no inventory consumption**

**Phase 2: Buffer Gas Enrichment (Maintain 40 kPa)**
1. Scrub/vent CO2 while maintaining pressure
2. Keep N2 + Ar from Mars atmosphere (~3.5 kPa of buffer gas)
3. Replace removed CO2 with manufactured N2
4. Result: 40 kPa of mostly N2+Ar buffer gas

**Phase 3: Add Oxygen (Still 40 kPa)**
1. Add manufactured O2 to reach breathable mix
2. Target: ~32 kPa N2, ~8 kPa O2, trace Ar
3. Test with crew in pressure suits (breathable but low pressure)

**Phase 4: Full Pressurization (80-101 kPa)**
1. Add more buffer gas (N2 + Ar) to increase pressure
2. Add more O2 to maintain 21% ratio
3. Reach target: 80-101 kPa Earth-like composition

#### Gas Sources (Mars)
- **Ambient Mars air**: Free compression (~4.3% becomes N2+Ar buffer)
- **CO2**: Vent or store for industrial use (greenhouses, fuel production)
- **O2**: Manufacture via CO2 processing (MOXIE-style) or water electrolysis
- **Additional N2**: May need some manufactured/imported to reach full pressure

#### Why This Matters
- **Mars worldhouses are cheaper**: Bulk gas is free, just process it
- **Energy vs Material trade-off**: Uses power to run processors instead of shipping gas
- **Phased approach is safer**: Test seals at low pressure before committing resources
- **Realistic engineering**: Gradual pressurization reduces catastrophic failure risk

---

## Refactoring Priorities

### Phase 1: Fix Current Services (HIGH PRIORITY)

#### 1.1 Update Service References
- [ ] Search codebase for `Structures::Skylight` → change to `CelestialBodies::Features::Skylight`
- [ ] Search codebase for `Structures::AccessPoint` → change to `CelestialBodies::Features::AccessPoint`
- [ ] Verify all construction services reference correct namespaces

#### 1.2 Verify SegmentCoveringService
- [ ] Test covering regular segments (structural panels)
- [ ] Test covering segments with skylights (transparent panels)
- [ ] Verify material calculations work correctly
- [ ] Test construction phase tracking

#### 1.3 Update CraterDome Model
```ruby
# Add to Structures::CraterDome
belongs_to :geological_feature, 
           class_name: 'CelestialBodies::Features::Crater',
           foreign_key: :geological_feature_id,
           optional: false

validates :geological_feature, presence: true
validate :feature_must_be_crater

# Delegate to feature
def crater_diameter_m
  geological_feature&.diameter_m
end

def crater_depth_m
  geological_feature&.depth_m
end
```

#### 1.4 Decide on SkylightService
**Option A**: Remove SkylightService (Recommended)
- Skylights are just segments that need transparent panels
- SegmentCoveringService already handles both panel types
- Reduces code duplication

**Option B**: Keep SkylightService for emergency covering
- Useful for "quick seal" before full worldhouse construction
- Separate from worldhouse construction flow
- Adds gameplay option

**Decision needed before proceeding**

#### 1.5 Delete Old Structure Files
After confirming all logic is migrated:
- [ ] Delete `app/models/structures/access_point.rb`
- [ ] Delete `app/models/structures/skylight.rb`
- [ ] Update any specs that reference these

---

### Phase 2: Worldhouse Orchestration (HIGH PRIORITY)

#### 2.1 Create WorldhouseConstructionService
```ruby
module Construction
  class WorldhouseConstructionService
    # Orchestrates conversion of geological feature to worldhouse
    
    def initialize(geological_feature, owner:, settlement:)
      @feature = geological_feature
      @owner = owner
      @settlement = settlement
    end
    
    def schedule_construction
      # 1. Validate feature is suitable
      # 2. Create Worldhouse structure
      # 3. Generate WorldhouseSegments
      # 4. Align segments with skylights
      # 5. Schedule covering jobs for each segment
      # 6. Create master construction job
    end
    
    private
    
    def generate_segments
      # Calculate segment divisions
      # Check for skylights in each segment
      # Create WorldhouseSegment records
    end
    
    def schedule_segment_covering(segment)
      # Determine panel type (transparent if has skylight)
      # Use SegmentCoveringService
    end
  end
end
```

#### 2.2 Features to Implement
- [ ] Feature suitability validation
- [ ] Worldhouse structure creation
- [ ] Segment generation algorithm
- [ ] Skylight-to-segment alignment
- [ ] Segment covering job scheduling
- [ ] Overall progress tracking
- [ ] Completion handling (mark feature as enclosed)

#### 2.3 Integration Points
- [ ] Integrate with existing SegmentCoveringService
- [ ] Use CoveringCalculator for material estimates
- [ ] Create ConstructionJobs for tracking
- [ ] Update feature status when complete

---

### Phase 3: Access Point Conversion Services (MEDIUM PRIORITY)

#### 3.1 Services to Create

**AirlockInstallationService**
- Converts AccessPoint to airlock for personnel access
- Size compatibility checks (small/medium/large)
- Creates installed_unit (airlock equipment)
- Updates conversion_status

**AccessPointSealingService**
- Permanently seals AccessPoint for atmosphere containment
- No equipment installation, just structural sealing
- Updates conversion_status to 'sealed'

**ConnectorTunnelService**
- Builds tunnel from AccessPoint to another structure
- Distance calculations and feasibility checks
- Creates tunnel structure record
- Updates conversion_status to 'connector_tunnel'

#### 3.2 Pattern to Follow
All should follow HangarService pattern:
```ruby
def schedule_conversion
  # 1. Validate compatibility
  # 2. Create connected structure (if applicable)
  # 3. Update access point conversion_status
  # 4. Create ConstructionJob
  # 5. Create material requests
  # 6. Create equipment requests
end
```

---

### Phase 4: Ambient Atmosphere Compression (MEDIUM PRIORITY - Mars Future)

#### 4.1 Add to PressurizationService

```ruby
class PressurizationService
  def pressurize(target_pressure = 80.0, options = {})
    if options[:use_ambient_compression] && can_use_ambient?
      pressurize_from_ambient(target_pressure, options)
    else
      # Existing code - use inventory gases
      pressurize_from_inventory(target_pressure)
    end
  end
  
  private
  
  def can_use_ambient?
    celestial_body.atmosphere&.pressure.to_f > 0.1 # Has usable atmosphere
  end
  
  def pressurize_from_ambient(target_pressure, options)
    # NEW: Compress ambient atmosphere without consuming inventory
    # Calculate compression ratio
    # Update atmosphere pressure
    # No inventory deduction
    # Energy cost only
  end
end
```

#### 4.2 Atmospheric Processing Service

```ruby
module Pressurization
  class AtmosphericProcessingService
    # Converts atmosphere composition over time
    # E.g., CO2 → O2 using MOXIE-style processors
    
    def schedule_processing(from_composition:, to_composition:, rate:)
      # Creates processing jobs that run over time
      # Consumes energy, not stored gases
      # Updates atmosphere composition gradually
    end
  end
end
```

#### 4.3 Phased Pressurization Protocol

```ruby
module Pressurization
  class ProtocolService
    # Orchestrates multi-phase pressurization
    
    def execute
      if has_shipped_gases?
        single_phase_pressurization # Moon approach
      elsif has_ambient_atmosphere?
        phased_pressurization_protocol # Mars approach
      else
        { success: false, error: "No gas source available" }
      end
    end
    
    private
    
    def phased_pressurization_protocol
      # Phase 1: Seal test at 40 kPa
      # Phase 2: Buffer gas enrichment
      # Phase 3: Oxygen addition
      # Phase 4: Full pressurization
    end
  end
end
```

#### 4.4 Features to Implement
- [ ] Ambient compression capability in PressurizationService
- [ ] AtmosphericProcessingService for CO2 → O2 conversion
- [ ] ProtocolService for phased pressurization
- [ ] Leak detection/monitoring jobs between phases
- [ ] Energy cost calculations for compression and processing
- [ ] Time-gated phases for gameplay progression

---

### Phase 5: Test Script Updates (MEDIUM PRIORITY)

#### 5.1 Update Existing Tests
- [ ] `construction_integration.rb` - Update to new model namespaces
- [ ] `starship_integration_precursor_mission.rb` - Verify manifest loading
- [ ] Create new end-to-end test for worldhouse construction

#### 5.2 New Test Scenarios to Create

**Lunar Lava Tube Conversion Test**
```ruby
# 1. Generate lava tube with skylights and access points
# 2. Create worldhouse structure
# 3. Cover segments (including skylight segments)
# 4. Seal access points or convert to airlocks
# 5. Pressurize using shipped N2 + extracted O2
# 6. Verify habitable status
```

**Mars Valley Worldhouse Test** (Future)
```ruby
# 1. Create valley feature on Mars
# 2. Create worldhouse structure
# 3. Cover segments
# 4. Phase 1: Compress Mars atmosphere to 40 kPa
# 5. Phase 2: Scrub CO2, enrich N2
# 6. Phase 3: Add O2
# 7. Phase 4: Full pressurization
# 8. Verify composition and habitability
```

---

## Key Architectural Decisions

### Settlement Types
- ✅ **Decided**: Keep BaseSettlement generic, no "SurfaceSettlement" type
- ✅ **Decided**: `settlement_type` enum for scale (base/outpost/settlement)
- ✅ **Decided**: SpaceStation separate for orbital-specific mechanics
- ✅ **Decided**: Settlement location is emergent from structures built

### Feature vs Structure Separation
- ✅ **Decided**: LavaTube, Crater, Valley, etc. are features (natural)
- ✅ **Decided**: Worldhouse, CraterDome are structures (built on features)
- ✅ **Decided**: Skylight and AccessPoint are features (natural openings)
- ✅ **Decided**: Construction services handle the building logic

### Covering System
- ✅ **Decided**: Universal panel system for skylights, segments, station shells
- ⏳ **Pending**: Whether to keep SkylightService or merge into SegmentCoveringService
- ✅ **Decided**: SegmentCoveringService handles both transparent and structural panels

### Pressurization System
- ✅ **Decided**: Existing PressurizationService works for inventory-based (Moon)
- ⏳ **Pending**: Need ambient compression capability for Mars
- ⏳ **Pending**: Need phased protocol system for safety/gameplay

---

## Open Questions

1. **SkylightService**: Keep for emergency covering or remove?
2. **CraterDome segmentation**: Should large craters be segmented like worldhouses?
3. **Access point hangar sizes**: How many vehicle types to support?
4. **Pressurization phases**: Should they be player-controlled or automatic?
5. **CO2 scrubbing**: New service or extend existing atmospheric processing?
6. **Energy costs**: How to track energy consumption for compression/processing?

---

## Dependencies & Blockers

### External Dependencies
- Lookup services must have complete data for all units/materials
- Blueprint system must be fully implemented
- ConstructionJob system must handle nested jobs (segments of worldhouse)

### Internal Dependencies
- Phase 2 depends on Phase 1 (services must reference correct models)
- Phase 4 depends on Phase 2 (pressurization needs worldhouse to be built)
- Test updates depend on all phases (need working systems to test)

---

## Success Criteria

### Phase 1 Success
- [ ] All construction services reference refactored models
- [ ] No references to old Structures::Skylight or Structures::AccessPoint
- [ ] SegmentCoveringService tested and working for both panel types
- [ ] CraterDome has geological_feature_id relationship

### Phase 2 Success
- [ ] Can convert LavaTube to Worldhouse via service
- [ ] Segments generated correctly and aligned with skylights
- [ ] Each segment can be covered independently
- [ ] Overall progress tracked correctly
- [ ] Feature marked as enclosed when complete

### Phase 3 Success
- [ ] Access points can be converted to airlocks
- [ ] Access points can be sealed permanently
- [ ] Large access points can become hangars
- [ ] Conversion status tracked through construction phases

### Phase 4 Success
- [ ] Can pressurize from ambient atmosphere (Mars scenario)
- [ ] Phased pressurization protocol works correctly
- [ ] Atmospheric processing converts CO2 to O2 over time
- [ ] Energy costs tracked and deducted

### Phase 5 Success
- [ ] All test scripts run without errors
- [ ] End-to-end lunar precursor mission works
- [ ] Can demonstrate complete lava tube conversion
- [ ] (Future) Can demonstrate Mars valley worldhouse

---

## Timeline Estimate

- **Phase 1**: 1-2 weeks (critical path)
- **Phase 2**: 2-3 weeks (complex orchestration)
- **Phase 3**: 1-2 weeks (follow established patterns)
- **Phase 4**: 2-3 weeks (new functionality, Mars-specific)
- **Phase 5**: 1 week (ongoing as features complete)

**Total estimated time**: 7-11 weeks for complete implementation

---

## Notes for Future Reference

### Why No "Surface Settlement" Type
A settlement is not defined by a single location type. Instead:
- It's a **complex** that can span multiple geological features
- Can have surface structures + worldhouses in lava tubes + crater domes
- Location is **emergent** from what structures have been built
- `settlement_type` represents **development scale** (base → outpost → settlement)
- SpaceStation is separate because it's **fundamentally different** (orbital, shell-based)

### Universal Panel System
The same panels are used for:
- Space station shells
- Worldhouse segment covering
- Skylight covering
- Crater dome construction

This makes the system modular and reduces code duplication.

### Mars vs Moon Economic Difference
- **Moon**: Must manufacture or ship ALL atmospheric gases → expensive
- **Mars**: Can compress ambient atmosphere → cheap bulk, just process composition
- **Titan** (future): Already 1.5 bar of N2 → only needs O2 added!

This creates interesting strategic choices for settlement location.

### Phased Pressurization Rationale
Not just realism - it's good gameplay:
1. **Risk management**: Test seals before wasting expensive gases
2. **Resource gating**: Can't rush pressurization, must plan ahead
3. **Time progression**: Phases take time, creates gameplay pacing
4. **Failure scenarios**: Leaks discovered early in low-pressure test
5. **Economic choices**: Fast (expensive shipped gases) vs slow (process local atmosphere)

---

## Last Updated
December 23, 2025

## Version
1.0 - Initial comprehensive plan based on refactoring discussions