require 'rails_helper'

RSpec.describe 'Luna Settlement Integration (MVP)', type: :integration do
  before(:each) do
    @luna = CelestialBodies::CelestialBody.find_by(identifier: "LUNA-01")
    skip "Luna celestial body not found in test database" unless @luna
    @settlement = create(:settlement, celestial_body: @luna, name: "Luna Base")
  end

  let(:profile_path) { "luna_base_establishment/luna_settlement_profile_v1.json" }

  it "world assessment reads real DB data" do
    capabilities = AIManager::PrecursorCapabilityService.new(@luna).production_capabilities
    expect(capabilities[:has_regolith]).to be true
    expect(capabilities[:isru_capable]).to be true
  end

  it "engine loads Luna profile and builds task plan" do
    engine = AIManager::TaskExecutionEngineV2.new(@luna.identifier, profile_path)
    engine.plan_tasks
    expect(engine.task_plan.keys).to include("power_comms", "isru_deployment", "gas_processing")
  end

  it "MaterialProcessingService creates TEU job" do
    service = Manufacturing::MaterialProcessingService.new(@settlement)
    job = service.create_processing_job(
      job_type: "material_processing", 
      unit_type: "thermal_extraction_unit_mk1"
    )
    expect(job.job_type).to eq "material_processing"
    expect(job.settlement).to eq @settlement
    expect(job.output_type).to eq "processed_regolith"
  end

  it "engine uses world properties, not hardcoded values" do
    engine = AIManager::TaskExecutionEngineV2.new(@luna.identifier, profile_path)
    expect(engine.environment["identifier"]).to eq "LUNA-01"
    expect(engine.environment["has_regolith"]).to be true
    expect(engine.environment["atmosphere"]).to be false
  end
end
