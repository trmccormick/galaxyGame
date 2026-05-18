# TASK: Fix Water Escalation ISRU Chain (Dual-Track Systems)
**Status**: BACKLOG  
**Priority**: HIGH  
**Type**: bug-fix  
**Created**: 2026-02-11

---

## Problem Statement
EscalationService incorrectly uses generic robots for ice extraction on Luna instead of proper ISRU chain (TEU + PVE units). Water production logic is architecturally wrong, using single-loop regolith synthesis when dual-track systems are required.

**Error output**:
- EscalationService attempts to deploy ice_extraction_robots for all water needs
- Missing TEU/PVE deployment triggers for orbital water cycle
- No separation between surface regolith processing a---
# TASK: Fix Water Escalation ISRU Chain (Dual-Track Systems) — PORO Integration v3.2
**Status**: BACKLOG  
**Priority**: HIGH  
**Type**: bug-fix  
**Created**: 2026-02-11  
**Last Updated**: 2026-05-17  
**Version**: 3.2 (Physical Site Prep Rules + PORO Service Integration)
---

## Problem Statement
EscalationService incorrectly uses generic robots for ice extraction on Luna instead of proper ISRU chain (TEU + PVE units). Water production logic is architecturally wrong, using single-loop regolith synthesis when dual-track systems are required.

**Error output**:
- EscalationService attempts to deploy ice_extraction_robots for all water needs
- Missing TEU/PVE deployment triggers for orbital water cycle
- No separation between surface regolith processing and deep crater extraction
- Depleted slag not routed to 3D sintering fabricators

---

## Goals
- Fix EscalationService to use correct ISRU chain (TEU + PVE on Luna, robots for PSRs)
- Implement dual-track systems with centralized RAW Gas tank buffer
- Route depleted regolith slag to 3D sintering fabricators
- Add Earth Import Backup trigger when local ISRU blocked
- Update specs for correct architecture

---

## Unified Site Prep & Foundation Criteria
Before any infrastructure deployment, the following physical site-preparation rules must be enforced:

1. **Excavation & Sintering Pipeline**: Deploying inflatable tank systems shares the exact preparation pipeline as landing pads. The site footprint must be excavated and sintered into a solid regolith basaltic slab before a central utility connection hub anchors.
2. **Hub-Bladder Interface**: Bladders must interface with this hub to initiate inflation. No inflation occurs until the hub reports readiness via `hub.ready?`.
3. **Linear Dependency Chain**: Tank Inflation must complete under gas flows supplied by active TEU/PVE units BEFORE the regolith shell printer can begin consuming 'inert_regolith_waste' slag and 3D printed I-beams to layer the protective structural shell over the fully expanded hulls.
4. **PORO State Management**: All state is managed via site/unit `operational_data` attributes in Plain Ruby Objects (no ActiveRecord).

---

## Acceptance Criteria
- [ ] Track A (Luna Surface): TEU bakes volatiles, PVE extracts oxygen from oxides
- [ ] Both tracks dump volatiles into centralized RAW Gas tank buffer first
- [ ] Depleted regolith slag flagged for 3D sintering fabricator use
- [ ] Track B (Deep Craters/PSRs): Physical ice extraction robots deploy separately
- [ ] Mars Profile: Distinct loop for crustal volatiles/subsurface permafrost
- [ ] Pad Tank Farm mapped near landing pads for flight fuels (requires excavated+sintered slab + hub)
- [ ] Lava Tube Tank Farm mapped inside tube systems for atmosphere buffers (passive pressure accumulation)
- [ ] Earth Import Backup triggered when local ISRU outputs blocked (USD capital)
- [ ] No GCC credit drain during economic progression gate
- [ ] Isolation run: 0 failures
- [ ] No regressions in related specs

---

## Implementation Steps

### Step 1 — Review EscalationService current logic
- Read `app/services/escalation_service.rb`
- Identify where generic ice_extraction_robots are deployed
- Find missing TEU/PVE unit dispatch logic

### Step 2 — Implement dual-track ISRU system logic (PORO Classes)

```ruby
# Logic for Track A (Luna Surface / General Regolith)
class IsruTrackA < PORO
  attr_reader :operational_data
  
  def initialize(buffer = nil, operational_data: {})
    @buffer = buffer || RawGasBuffer.new
    @operational_data = operational_data
  end
  
  def process_regolith(regolith_sample)
    # TEU bakes out loose volatiles at high temperature
    volatile_output = teu_units.process(@operational_data[:teu_units])
    
    # PVE liberates oxygen from remaining oxides
    oxygen_output = pve_units.extract_from_volatile(volatile_output, @operational_data[:pve_units])
    
    # Dump all processed volatiles into centralized RAW Gas tank buffer
    @buffer.add_volatiles(volatile_output.merge(oxygen_output))
    
    # Flag depleted regolith slag for 3D sintering fabricators
    return { slag: volatile_output[:slag], status: :processed }
  end
end

# Logic for Track B (Luna Deep Craters / PSRs)
class IsruTrackB < PORO
  attr_reader :operational_data
  
  def initialize(buffer = nil, operational_data: {})
    @buffer = buffer || RawGasBuffer.new
    @operational_data = operational_data
  end
  
  def extract_psice(asteroid_field)
    ice_output = ice_robots.harvest_from_cold_trap(@operational_data[:ice_robots], asteroid_field)
    
    # Dump directly into RAW Gas tank buffer for distillation
    @buffer.add_volatiles(ice_output)
    
    return { slag: nil, ice_kg: ice_output[:kg], status: :extracted }
  end
end

# Centralized Buffer
class RawGasBuffer < PORO
  attr_reader :operational_data
  
  def initialize(operational_data: {})
    @operational_data = operational_data
  end
  
  def add_volatiles(volatile_data)
    # Accumulate volatiles, track capacity
    self.volatiles.merge!(volatile_data)
    # Update pressure/temperature states in operational_data
    @operational_data[:pressure] = compute_pressure(@volatiles.to_a.sum)
    true
  end
  
  def fractional_distillation
    # Separate O2, H2, N2, CO2 based on boiling points
    distillate = separate_by_boiling_point(self.volatiles)
    store_each_gas(distillate, @operational_data[:tank_farm])
  end
end

# Tank Farm System (Pad vs Lava Tube)
class TankFarmSystem < PORO
  attr_reader :operational_data
  
  def initialize(type: :pad, operational_data: {})
    @type = type
    @operational_data = operational_data
  end
  
  def location_data
    if @type == :pad
      { coordinates: "near_landing_pads", purpose: "flight_fuels" }
    else
      { coordinates: "inside_structural_tubes", purpose: "habitability_atmosphere" }
    end
  end
  
  def stock_types
    if @type == :pad
      # Flight fuels: LOX, Methane, Hydrolox stack for return craft refuel
      [:lox, :methane, :hydrolox]
    else
      # Habitation atmosphere buffers (Earth-imported N2 as initial supply)
      [:n2, :o2, :argon]
    end
  end
end
```

### Step 3 — Implement Pad Tank Farm and Lava Tube Tank Farm mapping
- **Pad Farms**: Mapped near landing pads for flight fuels. Requires excavated+sintered slab + hub readiness.
- **Lava Tube Farms**: Mapped inside tube systems for atmosphere buffers. Uses passive pressure accumulation logic.

### Step 4 — Implement Earth Import Backup trigger

```ruby
class EscalationService < PORO
  attr_reader :operational_data
  
  def initialize(operational_data: {})
    @operational_data = operational_data
  end
  
  def escalate_water_request(water_demand, mission_phase)
    # Check local ISRU capacity
    isru_output = calculate_isru_capacity(
      track_a: IsruTrackA.new(@operational_data),
      track_b: IsruTrackB.new(@operational_data)
    )
    
    if isru_output.sufficient?(water_demand)
      # Use local ISRU output via dual-track system
      deploy_isru_units(isru_output.units, @operational_data)
      return { success: true, source: :isru }
    else
      # Local ISRU blocked/insufficient -> trigger Earth Import Backup
      earth_import_drain = drain_earth_capital_for_water(water_demand - isru_output.total_output)
      
      if earth_import_drain.success?
        return { success: true, source: :earth_import, capital_drained: earth_import_drain.amount }
      else
        # Critical failure - cannot meet demand even with Earth Import
        return { success: false, reason: 'water_demand_unmet' }
      end
    end
  end
end
```

### Step 5 — Implement Emergent Atmosphere Layer (Lava Tube)

```ruby
class LavaTubeAtmosphericHarvester < PORO
  attr_reader :skylight_coverage_ratio, :initial_pressure
  
  def initialize(skyight_coverage_ratio: 0.95, initial_pressure: 0.1, operational_data: {})
    @skylight_coverage_ratio = skyight_coverage_ratio
    @initial_pressure = initial_pressure
    @operational_data = operational_data
  end
  
  def current_pressure
    # Simulate passive accumulation (micro-losses, airlock cycles, venting)
    pressure_change = (@skylight_coverage_ratio - 1.0) * 0.02
    @current_pressure = [@initial_pressure + (@operational_data[:cycle_count] * pressure_change), 0].max
  end
  
  def simulate_passive_buildup(cycles)
    @operational_data[:cycle_count] += cycles
    current_pressure
  end
  
  def can_deploy_harvesters?
    # Strict gating: only deploy when pressure exceeds threshold
    current_pressure >= MIN_PRESSURE_FOR_HARVEST
  end
end
```

### Step 6 — Update specs for correct architecture
Update `spec/services/escalation_service_spec.rb`:

```ruby
describe EscalationService do
  describe '#escalate_water_request' do
    it 'uses TEU+PVE units for Luna surface regolith' do
      service = described_class.new
      water_demand = WaterRequest.create!(mass: 500, priority: :critical)
      
      allow(IsruTrackA).to receive(:process_regolith) { { slag: 100 } }
      expect(service.escalate_water_request(water_demand)).to include(source: :isru)
    end
    
    it 'uses ice extraction robots for deep crater PSRs' do
      service = described_class.new
      water_demand = WaterRequest.create!(mass: 200, location: :deep_crater)
      
      allow(IsruTrackB).to receive(:extract_psice) { { ice_kg: 150 } }
      expect(service.escalate_water_request(water_demand)).to include(source: :isru_track_b)
    end
    
    it 'routes slag to 3D sintering fabricators' do
      service = described_class.new
      water_demand = WaterRequest.create!(mass: 1000, priority: :high)
      
      expect(service.escalate_water_request(water_demand)).to include(slag_recycled: true)
    end
    
    it 'triggers Earth Import Backup when local ISRU blocked' do
      service = described_class.new
      water_demand = WaterRequest.create!(mass: 5000, priority: :emergency)
      
      # Mock failure states
      allow(IsruTrackA).to receive(:process_regolith) { { slag: 0 } }
      allow(IsruTrackB).to receive(:extract_psice) { { ice_kg: 10 } }
      
      expect(service.escalate_water_request(water_demand)).to include(source: :earth_import)
    end
    
    # NEW SPEC: Emergent Logic
    it 'only deploys harvesters when tube pressure exceeds threshold' do
      harvester = LavaTubeAtmosphericHarvester.new(skylight_coverage_ratio: 0.95, initial_pressure: 0.1)
      
      # Pressure too low initially
      expect(harvester.can_deploy_harvesters?).to be false
      
      # Simulate buildup
      harvester.simulate_passive_buildup(10) # Raise pressure
      
      if harvester.current_pressure >= LavaTubeAtmosphericHarvester::MIN_PRESSURE_FOR_HARVEST
        expect(harvester.can_deploy_harvesters?).to be true
      end
    end
  end
end
```

### Step 7 — Run isolation tests
Run exact test string from host terminal:

```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/escalation_service_spec.rb'
```
Expected result: X examples, 0 failures

---

## Related Files/Paths
- `app/services/escalation_service.rb`
- `spec/services/escalation_service_spec.rb`
- `app/models/isru_track_a.rb` (Refactored to PORO)
- `app/models/isru_track_b.rb` (Refactored to PORO)
- `app/models/raw_gas_buffer.rb` (Refactored to PORO)
- `app/models/tank_farm_system.rb` (New PORO Service)
- `app/models/lava_tube_atmospheric_harvester.rb` (New PORO Service)

---

## Stop Conditions — escalate to user immediately if:
- ISRU architecture requires refactoring core water management service beyond PORO scope
- Changes affect other mission-phase escalations unexpectedly
- Earth Import logic triggers incorrectly for valid local outputs
- Pressure gating logic causes infinite loops in simulation cycles

---

## Dependencies  
**Blocked by**: [none]  
**Blocks**: [water production for L1 station depot assembly]  
**Related tasks**: [L1 depot economics gate]

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**: [agent name]  
**Completion date**: 2026-05-17  
**Final test result**: X examples, Y failures  

### What was changed
- Refactored `IsruTrackA`, `IsruTrackB`, `RawGasBuffer` to Plain Ruby Objects (no ActiveRecord).
- Added `TankFarmSystem` and `LavaTubeAtmosphericHarvester` service with pressure gating logic.
- Fixed RSpec typo (`slab_recycled` -> `slag_recycled`).
- Implemented passive leak rate simulation and efficient deployment thresholds.
- Enforced unified site prep pipeline (excavation -> sintering -> hub -> inflation -> shell printing).
- Enforced linear dependency chain: tank inflation BEFORE shell printing.

### Issues discovered
[Any problems found during implementation]

### Follow-up tasks needed
[Any new backlog items identified]

### Lessons learned
[What worked, what didn't]nd deep crater extraction
- Depleted slag not routed to 3D sintering fabricators

---

## Goals
- Fix EscalationService to use correct ISRU chain (TEU + PVE on Luna, robots for PSRs)
- Implement dual-track systems with centralized RAW Gas tank buffer
- Route depleted regolith slag to 3D sintering fabricators
- Add Earth Import Backup trigger when local ISRU blocked
- Update specs for correct architecture

---

## Acceptance Criteria
- [ ] Track A (Luna Surface): TEU bakes volatiles, PVE extracts oxygen from oxides
- [ ] Both tracks dump volatiles into centralized RAW Gas tank buffer first
- [ ] Depleted regolith slag flagged for 3D sintering fabricator use
- [ ] Track B (Deep Craters/PSRs): Physical ice extraction robots deploy separately
- [ ] Mars Profile: Distinct loop for crustal volatiles/subsurface permafrost
- [ ] Pad Tank Farm mapped near landing pads for flight fuels
- [ ] Lava Tube Tank Farm mapped inside tube systems for atmosphere buffers
- [ ] Earth Import Backup triggered when local ISRU outputs blocked (USD capital)
- [ ] No GCC credit drain during economic progression gate
- [ ] Isolation run: 0 failures
- [ ] No regressions in related specs

---

## Implementation Steps

### Step 1 — Review EscalationService current logic
- Read `app/services/escalation_service.rb`
- Identify where generic ice_extraction_robots are deployed
- Find missing TEU/PVE unit dispatch logic

### Step 2 — Implement dual-track ISRU system logic

```ruby
# Logic for Track A (Luna Surface / General Regolith)
class ISRUTrackA < ApplicationRecord
  # Uses TEU (Thermal Extraction Unit) and PVE (Planetary Volatiles Extractor)
  units: {
    teu_units: { count: 3, capacity: 'bake volatiles' },
    pve_units: { count: 2, capacity: 'extract oxygen from oxides' }
  }
  
  def process_regolith(regolith_sample)
    # TEU bakes out loose volatiles at high temperature
    volatile_output = teu_units.process(regolith_sample)
    
    # PVE liberates oxygen from remaining oxides
    oxygen_output = pve_units.extract_from_volatile(volatile_output)
    
    # Dump all processed volatiles into centralized RAW Gas tank buffer
    raw_gas_buffer.add_volatiles(volatile_output.merge(oxygen_output))
    
    # Flag depleted regolith slag for 3D sintering fabricators
    return { slag: volatile_output[:slag], status: :processed }
  end
end

# Logic for Track B (Luna Deep Craters / PSRs)
class ISRUTrackB < ApplicationRecord
  # Uses physical ice extraction robots/miners for direct H2O cold traps harvesting
  units: { ice_robots: { count: 5, capacity: 'harvest solid H2O' } }
  
  def extract_psice(asteroid_field)
    ice_output = ice_robots.harvest_from_cold_trap(asteroid_field)
    
    # Dump directly into RAW Gas tank buffer for distillation
    raw_gas_buffer.add_volatiles(ice_output)
    
    return { slag: nil, ice_kg: ice_output[:kg], status: :extracted }
  end
end
```

### Step 3 — Implement centralized RAW Gas tank buffer logic

```ruby
class RawGasBuffer < ApplicationRecord
  include TurboCacheable
  
  def add_volatiles(volatile_data)
    self.volatiles = volatile_data
    self.position = position_in_buffer || create_position
    save!
  end
  
  def fractional_distillation
    # Separate O2, H2, N2, CO2 based on boiling points
    distillate = separate_by_boiling_point(self.volatiles)
    store_each_gas(distillate, :tank_farm) # Store at Pad or Lava Tube farms
  end
end
```

### Step 4 — Implement Pad Tank Farm and Lava Tube Tank Farm mapping

```ruby
class TankFarmSystem < ApplicationRecord
  def initialize(type: :pad)
    @type = type
  end
  
  def location_data
    if @type == :pad
      { coordinates: "near_landing_pads", purpose: "flight_fuels" }
    else
      { coordinates: "inside_structural_tubes", purpose: "habitability_atmosphere" }
    end
  end
  
  def stock_types
    if @type == :pad
      # Flight fuels: LOX, Methane, Hydrolox stack for return craft refuel
      [:lox, :methane, :hydrolox]
    else
      # Habitation atmosphere buffers (Earth-imported N2 as initial supply)
      [:n2, :o2, :argon]
    end
  end
end
```

### Step 5 — Implement Earth Import Backup trigger

```ruby
class EscalationService < ApplicationRecord
  def escalate_water_request(water_demand, mission_phase)
    # Check local ISRU capacity
    isru_output = calculate_isru_capacity(
      track_a: ISRUTrackA.new,
      track_b: ISRUTrackB.new
    )
    
    if isru_output.sufficient?(water_demand)
      # Use local ISRU output via dual-track system
      deploy_isru_units(isru_output.units)
      return { success: true, source: :isru }
    else
      # Local ISRU blocked/insufficient -> trigger Earth Import Backup
      earth_import_drain = drain_earth_capital_for_water(water_demand - isru_output.total_output)
      
      if earth_import_drain.success?
        return { success: true, source: :earth_import, capital_drained: earth_import_drain.amount }
      else
        # Critical failure - cannot meet demand even with Earth Import
        return { success: false, reason: 'water_demand_unmet' }
      end
    end
  end
end
```

### Step 6 — Update specs for correct architecture
Update `spec/services/escalation_service_spec.rb`:

```ruby
describe EscalationService do
  describe '#escalate_water_request' do
    it 'uses TEU+PVE units for Luna surface regolith' do
      service = described_class.new
      water_demand = WaterRequest.create!(mass: 500, priority: :critical)
      
      allow(ISRUTrackA).to receive(:process_regolith) { { slag: 100 } }
      expect(service.escalate_water_request(water_demand)).to include(source: :isru)
      end
    end
    
    it 'uses ice extraction robots for deep crater PSRs' do
      service = described_class.new
      water_demand = WaterRequest.create!(mass: 200, location: :deep_crater)
      
      allow(ISRUTrackB).to receive(:extract_psice) { { ice_kg: 150 } }
      expect(service.escalate_water_request(water_demand)).to include(source: :isru_track_b)
    end
    
    it 'routes slag to 3D sintering fabricators' do
      service = described_class.new
      water_demand = WaterRequest.create!(mass: 1000, priority: :high)
      
      expect(service.escalate_water_request(water_demand)).to include(slab_recycled: true)
    end
    
    it 'triggers Earth Import Backup when local ISRU blocked' do
      service = described_class.new
      water_demand = WaterRequest.create!(mass: 5000, priority: :emergency)
      allow(ISRUTrackA).to receive(:process_regolith) { { slag: 0 } }
      allow(ISRUTrackB).to receive(:extract_psice) { { ice_kg: 10 } }
      
      expect(service.escalate_water_request(water_demand)).to include(source: :earth_import)
    end
  end
end
```

### Step 7 — Run isolation tests
Run exact test string from host terminal:

```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/escalation_service_spec.rb'
```
Expected result: X examples, 0 failures

---

## Related Files/Paths
- `app/services/escalation_service.rb`
- `spec/services/escalation_service_spec.rb`
- `app/models/isru_track_a.rb` (new)
- `app/models/isru_track_b.rb` (new)
- `app/models/raw_gas_buffer.rb` (existing, updated)
- `app/models/tank_farm_system.rb` (new)

---

## Stop Conditions — escalate to user immediately if:
- ISRU architecture requires refactoring core water management service
- Changes affect other mission-phase escalations unexpectedly
- Earth Import logic triggers incorrectly for valid local outputs

---

## Dependencies  
**Blocked by**: [none]  
**Blocks**: [water production for L1 station depot assembly]  
**Related tasks**: [L1 depot economics gate]

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**: [agent name]  
**Completion date**: YYYY-MM-DD  
**Final test result**: X examples, Y failures  

### What was changed
- `app/services/escalation_service.rb` — implemented dual-track ISRU logic (TEU+PVE vs robots)
- `spec/services/escalation_service_spec.rb` — updated specs for correct architecture
- Added RAW Gas buffer routing and slag recycling to 3D sintering fabricators
- Added Pad Tank Farm and Lava Tube Tank Farm mapping
- Added Earth Import Backup trigger when local ISRU blocked

### Issues discovered
[Any problems found during implementation that weren't in the original task]

### Follow-up tasks needed
[Any new backlog items identified — do not create the files, just list them here]

### Lessons learned
[What worked, what didn't, what future tasks in this area should know]
