# Wormhole Easter Egg Integration

**Priority:** HIGH (Enables legendary discoveries and special events)
**Estimated Time:** 4-6 hours
**Risk Level:** MEDIUM (New systems integration)
**Dependencies:** Easter egg system cleanup complete

## 🎯 Objective
Update wormhole generation jobs to support easter egg integration, special event triggering, and anomaly reporting for discoveries not revealed by initial AI Manager scouting.

## 📋 Requirements
- DS9 easter egg can spawn DJEW-716790 + FR-488530 systems with permanent wormhole pair
- Three wormhole types: standard natural, stabilizable natural, permanent stable pairs
- Anomaly reporting system for background-discovered wormholes
- AI Manager scouting limitations respected (doesn't reveal everything immediately)
- Legendary events (0.5% spawn rate) trigger special system generation
- Campaign uniqueness enforced for DS9 systems

## 🔍 Analysis Phase
**Time: 30 minutes**

### Tasks:
1. Review current wormhole generation job logic
2. Identify integration points for easter egg triggers
3. Map anomaly reporting requirements
4. Confirm DS9 system templates exist and are valid

### Commands:
```bash
# Check current job structure
find app/jobs -name "*wormhole*" -type f

# Verify DS9 system templates
ls data/json-data/generated_star_systems/ | grep -E "(djew-716790|fr-488530)"

# Review easter egg loading
docker-compose -f docker-compose.dev.yml exec -T web bundle exec rails runner -e development "
class AIManager::WorldKnowledgeService
  public :load_easter_eggs
end
service = AIManager::WorldKnowledgeService.new
ds9_egg = service.load_easter_eggs.find { |e| e['easter_egg_id'] == 'terok_nor_legacy' }
puts 'DS9 Config:'
puts JSON.pretty_generate(ds9_egg['trigger_conditions'])
"
```

### Success Criteria:
- Current wormhole jobs documented
- DS9 system templates confirmed present
- Easter egg loading verified
- Integration points identified

## 🛠️ Core Implementation Phase
**Time: 2-3 hours**

### Tasks:
1. Add easter egg trigger logic to WormholeGenerationJob
2. Implement legendary wormhole spawning (DS9 systems)
3. Create anomaly reporting system
4. Add wormhole type differentiation

### Code Changes:

**wormhole_generation_job.rb:**
```ruby
def perform
  # PRIORITY: Check for legendary easter eggs first
  if should_trigger_ds9_easter_egg?
    spawn_ds9_wormhole_systems
    return  # Skip normal generation this cycle
  end
  
  # Normal generation with enhanced logic
  eligible_systems = find_eligible_systems
  eligible_systems.each do |system|
    generate_enhanced_wormhole(system)
  end
end

private

def should_trigger_ds9_easter_egg?
  rand < 0.005 && !ds9_systems_exist?
end

def spawn_ds9_wormhole_systems
  # Load and spawn DJEW-716790 and FR-488530
  bhavael = load_system_template('djew-716790.json')
  aetherian = load_system_template('fr-488530.json')
  
  # Create permanent wormhole pair
  create_permanent_wormhole(bhavael, aetherian)
  
  # Create discovery anomalies
  create_ds9_anomaly(bhavael)
  create_ds9_anomaly(aetherian)
end

def generate_enhanced_wormhole(system)
  wormhole_type = determine_wormhole_type
  
  case wormhole_type
  when :stabilizable
    create_stabilizable_wormhole(system)
  when :permanent_pair
    create_permanent_wormhole_pair(system)
  else
    create_standard_wormhole(system)
  end
  
  # Always create anomaly report
  create_wormhole_anomaly(system, wormhole_type)
end

def determine_wormhole_type
  roll = rand
  if roll < 0.005    # 0.5%
    :permanent_pair
  elsif roll < 0.05  # 4.5%
    :stabilizable
  else               # 95%
    :standard
  end
end
```

**New: system_anomalies.rb (model):**
```ruby
class SystemAnomaly < ApplicationRecord
  belongs_to :solar_system
  
  enum anomaly_type: {
    wormhole_discovery: 'wormhole_discovery',
    ds9_easter_egg: 'ds9_easter_egg',
    stabilizable_wormhole: 'stabilizable_wormhole'
  }
  
  enum status: {
    undetected: 'undetected',
    detected: 'detected',
    investigated: 'investigated'
  }
end
```

### Commands:
```bash
# Create anomaly migration
docker-compose -f docker-compose.dev.yml exec web bundle exec rails generate migration CreateSystemAnomalies solar_system:references anomaly_type:string status:string details:json discovered_by:string discovery_date:datetime

# Run migration
docker-compose -f docker-compose.dev.yml exec web bundle exec rails db:migrate

# Test DS9 spawning
docker-compose -f docker-compose.dev.yml exec web bundle exec rails runner -e development "
# Test legendary trigger
WormholeGenerationJob.new.should_trigger_ds9_easter_egg?
"
```

### Success Criteria:
- WormholeGenerationJob enhanced with easter egg logic
- SystemAnomaly model created and migrated
- DS9 spawning logic implemented
- Anomaly reporting functional

## 🔗 AI Manager Integration Phase
**Time: 1 hour**

### Tasks:
1. Connect anomaly reports to AI Manager scouting
2. Ensure discoveries revealed appropriately
3. Add easter egg overlay logic

### Code Changes:

**world_knowledge_service.rb:**
```ruby
def generate_system_report(system)
  report = super(system)  # Existing logic
  
  # Add anomaly information
  anomalies = system.system_anomalies.undetected
  if anomalies.any?
    report[:anomalies] = anomalies.map do |anomaly|
      {
        type: anomaly.anomaly_type,
        hint: anomaly_hint(anomaly),
        requires_investigation: true
      }
    end
  end
  
  # Apply easter egg overlays
  apply_easter_egg_overlays(system, report)
  
  report
end

private

def anomaly_hint(anomaly)
  case anomaly.anomaly_type
  when 'wormhole_discovery'
    "Unexplained energy signature detected"
  when 'ds9_easter_egg'
    "Ancient wormhole terminus with unusual stability"
  when 'stabilizable_wormhole'
    "Fluctuating wormhole with stabilization potential"
  end
end
```

### Commands:
```bash
# Test AI Manager integration
docker-compose -f docker-compose.dev.yml exec web bundle exec rails runner -e development "
system = SolarSystem.first
service = AIManager::WorldKnowledgeService.new
report = service.generate_system_report(system)
puts 'Anomalies in report:'
puts report[:anomalies] || 'None'
"
```

### Success Criteria:
- Anomalies appear in AI Manager reports
- Easter egg overlays applied
- Discovery flow functional

## 🧪 Testing & Validation Phase
**Time: 1 hour**

### Tasks:
1. Test DS9 easter egg spawning
2. Verify anomaly reporting
3. Test wormhole type distribution
4. Validate uniqueness constraints

### Commands:
```bash
# Test DS9 trigger
docker-compose -f docker-compose.dev.yml exec -T web bundle exec rails runner -e development "
job = WormholeGenerationJob.new
puts 'DS9 Trigger Test:'
5.times { puts job.send(:should_trigger_ds9_easter_egg?) }
"

# Test anomaly creation
docker-compose -f docker-compose.dev.yml exec web bundle exec rails runner -e development "
system = SolarSystem.first
anomaly = SystemAnomaly.create!(
  solar_system: system,
  anomaly_type: :wormhole_discovery,
  status: :undetected,
  details: {wormhole_stability: 'fluctuating'},
  discovered_by: 'background_job'
)
puts 'Anomaly created: #{anomaly.id}'
"

# Test wormhole type distribution
docker-compose -f docker-compose.dev.yml exec web bundle exec rails runner -e development "
job = WormholeGenerationJob.new
types = []
100.times { types << job.send(:determine_wormhole_type) }
puts 'Distribution:'
puts 'Standard: #{types.count(:standard)}'
puts 'Stabilizable: #{types.count(:stabilizable)}'  
puts 'Permanent: #{types.count(:permanent_pair)}'
"
```

### Success Criteria:
- DS9 systems spawn correctly (once per campaign)
- Anomalies created and reported properly
- Wormhole types distribute as expected
- No duplicate system spawning

## 📝 Documentation Phase
**Time: 30 minutes**

### Tasks:
1. Update wormhole system documentation
2. Document easter egg integration
3. Add anomaly reporting guide

### Files to Update:
- docs/architecture/wormhole_system.md
- docs/agent/README.md (wormhole mechanics)
- Add anomaly reporting section

### Success Criteria:
- Documentation updated
- Integration points documented
- Future maintenance guide created

## 🎯 Success Metrics
- ✅ DS9 easter egg spawns DJEW-716790 + FR-488530 systems
- ✅ Permanent wormhole pair created between them
- ✅ Anomaly reports generated for background discoveries
- ✅ AI Manager reveals anomalies during scouting
- ✅ Wormhole types distribute correctly (95% standard, 4.5% stabilizable, 0.5% permanent)
- ✅ Campaign uniqueness enforced
- ✅ No interference with existing wormhole mechanics

## 🔄 Rollback Plan
If issues arise:
1. Revert WormholeGenerationJob changes
2. Drop SystemAnomalies table
3. Restore original wormhole logic
4. DS9 easter egg falls back to current trigger system

## 📈 Future Enhancements
- Stabilizable wormhole mechanics (AWS requirements)
- Consortium voting on wormhole access
- Community-shared discoveries
- Easter egg wiki integration