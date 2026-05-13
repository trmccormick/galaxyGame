# TASK: Luna Settlement Integration Spec — MVP Acceptance Test (Seed Data)

**Status**: ACTIVE
**Priority**: HIGH
**Type**: spec
**Created**: 2026-05-01 (updated 2026-05-11 for sol.json seed data)
**MVP Gate**: YES — this is the definition of "Luna settlement works"
**Depends On**: luna_settlement_profile_v1.json exists ✓

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why**: Spec structure + 4 examples fully outlined. Seed data setup explicit.
**Supervision Level**: 🔴 Watched carefully

---

## Spec to Create
**File**: `spec/services/ai_manager/luna_settlement_integration_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe 'Luna Settlement Integration (MVP)', type: :integration do
  before(:each) do
    CelestialBody.seed_from_json("data/json-data/sol.json")
    @luna = CelestialBody.find_by(identifier: "LUNA-01")
    @settlement = create(:settlement, celestial_body: @luna, name: "Luna Base")
  end

  let(:profile_path) { "data/json-data/missions/luna_base_establishment/luna_settlement_profile_v1.json" }

  it "world assessment reads real DB data" do
    capabilities = PrecursorCapabilityService.new(@luna).production_capabilities
    expect(capabilities[:has_regolith]).to be true
    expect(capabilities[:isru_capable]).to be true
  end

  it "engine loads Luna profile and builds task plan" do
    engine = TaskExecutionEngineV2.new(@luna.identifier, profile_path)
    engine.plan_tasks
    expect(engine.task_plan.keys).to include("power_comms", "isru_deployment", "gas_processing")
  end

  it "MaterialProcessingService creates TEU job" do
    service = MaterialProcessingService.new(@settlement)
    job = service.create_processing_job(
      job_type: "thermal_extraction", 
      unit_type: "teu"
    )
    expect(job.job_type).to eq "thermal_extraction"
    expect(job.settlement).to eq @settlement
    expect(job.output_type).to be_present
  end

  it "engine uses world properties, not hardcoded values" do
    engine = TaskExecutionEngineV2.new(@luna.identifier, profile_path)
    expect(engine.environment["identifier"]).to eq "LUNA-01"
    expect(engine.environment["has_regolith"]).to be true
    expect(engine.environment["atmosphere"]).to be false
  end
end
```

---

## Acceptance Criteria
- All 4 examples pass: `rspec spec/services/ai_manager/luna_settlement_integration_spec.rb`
- No hardcoded LUNA-01 in service code
- Runs <5s
- Added to critical/smoke tag

## Progress
**Not stale** — profile exists, seed data confirmed, spec missing.