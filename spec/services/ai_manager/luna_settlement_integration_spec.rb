require 'rails_helper'

RSpec.describe 'Luna Settlement Integration (MVP)', type: :integration do
  before(:each) do
    @luna = CelestialBodies::CelestialBody.find_by(identifier: "LUNA-01")
    skip "Luna celestial body not found in test database" unless @luna
    @settlement = create(:settlement, celestial_body: @luna, name: "Luna Base")
  end

  let(:profile_path) { "data/json-data/missions/luna_base_establishment/luna_settlement_profile_v1.json" }

  xit "world assessment reads real DB data" do
    capabilities = PrecursorCapabilityService.new(@luna).production_capabilities
    expect(capabilities[:has_regolith]).to be true
    expect(capabilities[:isru_capable]).to be true
  end

  xit "engine loads Luna profile and builds task plan" do
    engine = TaskExecutionEngineV2.new(@luna.identifier, profile_path)
    engine.plan_tasks
    expect(engine.task_plan.keys).to include("power_comms", "isru_deployment", "gas_processing")
  end

  it "MaterialProcessingService creates TEU job" do
    allow(@settlement.inventory).to receive(:has_item?).with("regolith", 1000).and_return(true)
    service = Manufacturing::MaterialProcessingService.new(@settlement)
    unit = Lookup::UnitLookupService.new.find_unit("thermal_extraction_unit_mk1")
    job = service.process(unit, "regolith", 1000)
    expect(job.job_type).to eq "material_processing"
    expect(job.settlement).to eq @settlement
    expect(job.output_type).to eq "processed_regolith"
  end

  xit "engine uses world properties, not hardcoded values" do
    engine = TaskExecutionEngineV2.new(@luna.identifier, profile_path)
    expect(engine.environment["identifier"]).to eq "LUNA-01"
    expect(engine.environment["has_regolith"]).to be true
    expect(engine.environment["atmosphere"]).to be false
  end
end
