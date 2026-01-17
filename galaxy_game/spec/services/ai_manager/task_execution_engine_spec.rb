require 'rails_helper'
require_relative '../../../app/services/ai_manager'


RSpec.describe AIManager::TaskExecutionEngine, type: :service do
  let!(:solar_system) { create(:solar_system) }
  let!(:planet) { create(:terrestrial_planet, solar_system: solar_system) }
  let!(:location) { create(:celestial_location, celestial_body: planet) }
  let!(:owner) { create(:player) }
  let!(:settlement) { create(:base_settlement, location: location, owner: owner) }
  
  let(:mission_id) { 'test_mission_001' }
  let!(:mission) do
    create(:mission,
      identifier: mission_id,
      settlement: settlement,
      status: 'in_progress',
      operational_data: {}
    )
  end
  
  let(:task_list) do
    [
      {
        'task_id' => 'deploy_solar',
        'description' => 'Deploy solar panels',
        'effects' => [
          {
            'action' => 'deploy_unit',
            'unit' => 'Solar Panel',
            'count' => 2
          }
        ]
      },
      {
        'task_id' => 'build_dome',
        'description' => 'Build dome',
        'type' => 'construct',
        'structure_type' => 'crater_dome',
        'name' => 'Dome Alpha',
        'diameter' => 100.0,
        'depth' => 20.0
      }
    ]
  end
  
  let(:manifest) do
    {
      'template' => 'mission_manifest',
      'manifest_id' => 'test_manifest',
      'craft' => { 'id' => 'test_craft', 'name' => 'Test Craft' },
      'inventory' => { 
        'units' => [
          { 'name' => 'Solar Panel', 'id' => 'solar_panel', 'count' => 10 }
        ]
      },
      'metadata' => { 'version' => '1.0' }
    }
  end
  
  let(:profile) do
    {
      'template' => 'mission_profile',
      'profile_id' => 'test_profile',
      'phases' => [
        {
          'phase_id' => 'phase_1',
          'task_list_file' => 'test_mission_001_phase_1.json'
        }
      ]
    }
  end
  
  before do
    # Mock file loading for profile-based mission structure
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:exist?).and_call_original
    allow(Dir).to receive(:glob).and_call_original
    
    # Mock profile file
    profile_path = GalaxyGame::Paths::MISSIONS_PATH.join('test-mission-001', 'test_mission_001_profile_v1.json')
    allow(Dir).to receive(:glob).with(GalaxyGame::Paths::MISSIONS_PATH.join("**", "test_mission_001_profile_v1.json")).and_return([profile_path])
    allow(File).to receive(:exist?).with(profile_path).and_return(true)
    allow(File).to receive(:read).with(profile_path).and_return(profile.to_json)
    
    # Mock phase tasks file
    phase_path = GalaxyGame::Paths::MISSIONS_PATH.join('test-mission-001', 'test_mission_001_phase_1.json')
    allow(File).to receive(:exist?).with(phase_path.to_s).and_return(true)
    allow(File).to receive(:read).with(phase_path.to_s).and_return({ 'tasks' => task_list }.to_json)
    
    # Mock manifest file
    manifest_path = GalaxyGame::Paths::MISSIONS_PATH.join('test-mission-001', 'test_mission_001_manifest_v1.json')
    allow(Dir).to receive(:glob).with(GalaxyGame::Paths::MISSIONS_PATH.join("**", "test_mission_001_manifest_v1.json")).and_return([manifest_path])
    allow(File).to receive(:exist?).with(manifest_path).and_return(true)
    allow(File).to receive(:read).with(manifest_path).and_return(manifest.to_json)
  end
  
  describe '#initialize' do
    it 'loads mission and settlement' do
      engine = AIManager::TaskExecutionEngine.new(mission_id)
      
      expect(engine.instance_variable_get(:@mission)).to eq(mission)
      expect(engine.instance_variable_get(:@settlement)).to eq(settlement)
    end
    
    it 'loads task list from profile-based structure' do
      engine = AIManager::TaskExecutionEngine.new(mission_id)
      
      loaded_tasks = engine.instance_variable_get(:@task_list)
      expect(loaded_tasks).to eq(task_list)
    end
    
    it 'initializes current task index to 0' do
      engine = AIManager::TaskExecutionEngine.new(mission_id)
      
      expect(engine.instance_variable_get(:@current_task_index)).to eq(0)
    end
    
    it 'initializes material tracking hashes' do
      engine = AIManager::TaskExecutionEngine.new(mission_id)
      
      expect(engine.instance_variable_get(:@produced_materials)).to eq({})
      expect(engine.instance_variable_get(:@consumed_materials)).to eq({})
    end
  end
  
  describe '#start' do
    it 'executes all tasks synchronously' do
      engine = AIManager::TaskExecutionEngine.new(mission_id)
      
      expect(engine).to receive(:execute_next_task).twice.and_return(true, false)
      expect(engine).to receive(:complete_mission)
      
      engine.start
    end
  end
  
  describe '#execute_next_task' do
    let(:engine) { AIManager::TaskExecutionEngine.new(mission_id) }
    
    context 'when all tasks are complete' do
      before do
        engine.instance_variable_set(:@current_task_index, task_list.length)
      end
      
      it 'returns false' do
        expect(engine.send(:execute_next_task)).to be false
      end
    end
    
    context 'when task execution succeeds' do
      before do
        allow(engine).to receive(:execute_task).and_return(true)
      end
      
      it 'increments the task index' do
        expect {
          engine.send(:execute_next_task)
        }.to change { engine.instance_variable_get(:@current_task_index) }.by(1)
      end
      
      it 'updates mission progress' do
        expect(engine).to receive(:update_mission_progress)
        engine.send(:execute_next_task)
      end
      
      it 'returns true' do
        expect(engine.send(:execute_next_task)).to be true
      end
    end
    
    context 'when task execution fails' do
      before do
        allow(engine).to receive(:execute_task).and_return(false)
      end
      
      it 'logs error' do
        expect(Rails.logger).to receive(:error).with(/Task \d+ failed/)
        engine.send(:execute_next_task)
      end
      
      it 'returns false' do
        expect(engine.send(:execute_next_task)).to be false
      end
    end
  end
  
  describe '#execute_task' do
    let(:engine) { AIManager::TaskExecutionEngine.new(mission_id) }
    
    context 'with effects-based task' do
      let(:task) do
        {
          'task_id' => 'test_deploy',
          'effects' => [
            {
              'action' => 'deploy_unit',
              'unit' => 'Test Unit',
              'count' => 1
            }
          ]
        }
      end
      
      it 'executes each effect' do
        expect(engine).to receive(:execute_effect).with(task['effects'][0], task)
        engine.send(:execute_task, task)
      end
    end
    
    context 'with legacy task type' do
      let(:task) do
        {
          'type' => 'construct',
          'structure_type' => 'crater_dome'
        }
      end
      
      it 'calls legacy handler' do
        expect(engine).to receive(:initiate_construction).with(task)
        engine.send(:execute_task, task)
      end
    end
  end
  
  describe '#execute_effect' do
    let(:engine) { AIManager::TaskExecutionEngine.new(mission_id) }
    let(:task) { { 'task_id' => 'test_task' } }
    
    context 'with deploy_unit effect' do
      let(:effect) { { 'action' => 'deploy_unit', 'unit' => 'Test Unit' } }
      
      it 'calls deploy_unit_from_effect' do
        expect(engine).to receive(:deploy_unit_from_effect).with(effect)
        engine.send(:execute_effect, effect, task)
      end
    end
    
    context 'with set_unit_state effect' do
      let(:effect) { { 'action' => 'set_unit_state', 'unit' => 'Test Unit', 'state' => 'active' } }
      
      it 'calls set_unit_state' do
        expect(engine).to receive(:set_unit_state).with(effect)
        engine.send(:execute_effect, effect, task)
      end
    end
    
    context 'with connect_units effect' do
      let(:effect) { { 'action' => 'connect_units', 'unit1' => 'Unit A', 'unit2' => 'Unit B' } }
      
      it 'calls connect_units_from_effect' do
        expect(engine).to receive(:connect_units_from_effect).with(effect)
        engine.send(:execute_effect, effect, task)
      end
    end
    
    context 'with manufacture effect' do
      let(:effect) { { 'action' => 'manufacture', 'unit' => 'Printer', 'output' => 'ibeam' } }
      
      it 'calls manufacture_from_effect' do
        expect(engine).to receive(:manufacture_from_effect).with(effect, task)
        engine.send(:execute_effect, effect, task)
      end
    end
    
    context 'with check_unit_state effect' do
      let(:effect) { { 'action' => 'check_unit_state', 'unit' => 'Test Unit', 'state' => 'ready' } }
      
      it 'calls check_unit_state_from_effect' do
        expect(engine).to receive(:check_unit_state_from_effect).with(effect)
        engine.send(:execute_effect, effect, task)
      end
    end
    
    context 'with check_unit_connected effect' do
      let(:effect) { { 'action' => 'check_unit_connected', 'unit' => 'Test Unit', 'port' => 'input' } }
      
      it 'calls check_unit_connected_from_effect' do
        expect(engine).to receive(:check_unit_connected_from_effect).with(effect)
        engine.send(:execute_effect, effect, task)
      end
    end
    
    context 'with transfer_resource effect' do
      let(:effect) { { 'action' => 'transfer_resource', 'source_unit' => 'Tank A', 'target_unit' => 'Tank B', 'resource' => 'water' } }
      
      it 'calls transfer_resource_from_effect' do
        expect(engine).to receive(:transfer_resource_from_effect).with(effect)
        engine.send(:execute_effect, effect, task)
      end
    end
    
    context 'with unknown effect' do
      let(:effect) { { 'action' => 'unknown_action' } }
      
      it 'returns false' do
        expect(engine.send(:execute_effect, effect, task)).to be false
      end
    end
  end
  
  describe '#deploy_unit_from_effect' do
    let(:engine) { AIManager::TaskExecutionEngine.new(mission_id) }
    let(:effect) { { 'unit' => 'Solar Panel', 'count' => 2 } }
    let(:blueprint) { { 'id' => 'solar_panel', 'name' => 'Solar Panel' } }
    
    before do
      allow(engine).to receive(:find_unit_blueprint).with('Solar Panel').and_return(blueprint)
      allow_any_instance_of(Lookup::BlueprintLookupService).to receive(:find_blueprint).and_return(blueprint)
    end
    
    it 'creates multiple units when count > 1' do
      expect {
        engine.send(:deploy_unit_from_effect, effect)
      }.to change { Units::BaseUnit.count }.by(2)
      
      units = Units::BaseUnit.last(2)
      expect(units[0].name).to eq('Solar Panel 1')
      expect(units[1].name).to eq('Solar Panel 2')
    end
    
    it 'returns true on success' do
      expect(engine.send(:deploy_unit_from_effect, effect)).to be true
    end
    
    context 'when blueprint not found' do
      before do
        allow(engine).to receive(:find_unit_blueprint).and_return(nil)
      end
      
      it 'returns false' do
        expect(engine.send(:deploy_unit_from_effect, effect)).to be false
      end
    end
  end
  
  describe '#set_unit_state' do
    let(:engine) { AIManager::TaskExecutionEngine.new(mission_id) }
    let!(:unit1) { create(:base_unit, name: 'Test Unit 1', owner: settlement, operational_data: { 'state' => 'idle' }) }
    let!(:unit2) { create(:base_unit, name: 'Test Unit 2', owner: settlement, operational_data: { 'state' => 'idle' }) }
    let(:effect) { { 'unit' => 'Test Unit', 'state' => 'active' } }
    
    it 'updates state for all matching units' do
      engine.send(:set_unit_state, effect)
      
      unit1.reload
      unit2.reload
      expect(unit1.operational_data['state']).to eq('active')
      expect(unit2.operational_data['state']).to eq('active')
    end
    
    it 'returns true even if no units found' do
      effect = { 'unit' => 'Nonexistent Unit', 'state' => 'active' }
      expect(engine.send(:set_unit_state, effect)).to be true
    end
  end
  
  describe '#connect_units_from_effect' do
    let(:engine) { AIManager::TaskExecutionEngine.new(mission_id) }
    let!(:unit1) { create(:base_unit, name: 'Power Hub', owner: settlement) }
    let!(:unit2) { create(:base_unit, name: 'Solar Panel', owner: settlement) }
    let(:effect) { { 'unit1' => 'Power Hub', 'unit2' => 'Solar Panel', 'port1' => 'input', 'port2' => 'output' } }
    
    it 'connects units successfully' do
      expect(engine.send(:connect_units_from_effect, effect)).to be true
    end
    
    it 'returns true even if units not found (AI simulation)' do
      effect = { 'unit1' => 'Missing Unit', 'unit2' => 'Solar Panel', 'port1' => 'input', 'port2' => 'output' }
      expect(engine.send(:connect_units_from_effect, effect)).to be true
    end
  end
  
  describe '#manufacture_from_effect' do
    let(:engine) { AIManager::TaskExecutionEngine.new(mission_id) }
    let(:task) { { 'task_id' => 'print_beams' } }
    let(:effect) do
      {
        'unit' => 'I-Beam Printer',
        'output' => 'ibeam',
        'quantity' => 10,
        'inputs' => [
          { 'material' => 'depleted_regolith', 'quantity' => 50 }
        ]
      }
    end
    
    before do
      allow(ResourceTrackingService).to receive(:track_procurement)
      allow(settlement.inventory).to receive(:remove_item)
      allow(settlement.inventory).to receive(:add_item)
    end
    
    it 'tracks input materials as consumed' do
      engine.send(:manufacture_from_effect, effect, task)
      
      consumed = engine.instance_variable_get(:@consumed_materials)
      expect(consumed['depleted_regolith']).to eq(500) # 50 * 10
    end
    
    it 'tracks output materials as produced' do
      engine.send(:manufacture_from_effect, effect, task)
      
      produced = engine.instance_variable_get(:@produced_materials)
      expect(produced['ibeam']).to eq(10)
    end
    
    it 'calls ResourceTrackingService with correct parameters' do
      expect(ResourceTrackingService).to receive(:track_procurement).with(
        settlement,
        'depleted_regolith',
        500,
        :local_isru,
        hash_including(task_type: 'manufacturing')
      )
      
      expect(ResourceTrackingService).to receive(:track_procurement).with(
        settlement,
        'ibeam',
        10,
        :local_production,
        hash_including(task_type: 'manufacturing')
      )
      
      engine.send(:manufacture_from_effect, effect, task)
    end
    
    it 'returns true on success' do
      expect(engine.send(:manufacture_from_effect, effect, task)).to be true
    end
  end
  
  describe '#check_unit_state_from_effect' do
    let(:engine) { AIManager::TaskExecutionEngine.new(mission_id) }
    let!(:unit) { create(:base_unit, name: 'Test Unit', owner: settlement, operational_data: { 'state' => 'ready' }) }
    
    context 'when unit is in expected state' do
      let(:effect) { { 'unit' => 'Test Unit', 'state' => 'ready' } }
      
      it 'returns true' do
        expect(engine.send(:check_unit_state_from_effect, effect)).to be true
      end
    end
    
    context 'when unit is in different state' do
      let(:effect) { { 'unit' => 'Test Unit', 'state' => 'active' } }
      
      it 'returns true (soft check for AI simulation)' do
        expect(engine.send(:check_unit_state_from_effect, effect)).to be true
      end
    end
    
    context 'when unit not found' do
      let(:effect) { { 'unit' => 'Missing Unit', 'state' => 'ready' } }
      
      it 'returns true (soft check for AI simulation)' do
        expect(engine.send(:check_unit_state_from_effect, effect)).to be true
      end
    end
  end
  
  describe '#check_unit_connected_from_effect' do
    let(:engine) { AIManager::TaskExecutionEngine.new(mission_id) }
    let!(:unit) { create(:base_unit, name: 'Test Unit', owner: settlement) }
    let(:effect) { { 'unit' => 'Test Unit', 'port' => 'input' } }
    
    it 'returns true when unit exists' do
      expect(engine.send(:check_unit_connected_from_effect, effect)).to be true
    end
    
    it 'returns true even when unit not found (soft check)' do
      effect = { 'unit' => 'Missing Unit', 'port' => 'input' }
      expect(engine.send(:check_unit_connected_from_effect, effect)).to be true
    end
  end
  
  describe '#transfer_resource_from_effect' do
    let(:engine) { AIManager::TaskExecutionEngine.new(mission_id) }
    
    context 'with continuous transfer' do
      let(:effect) { { 'source_unit' => 'Tank A', 'target_unit' => 'Tank B', 'resource' => 'water', 'continuous' => true } }
      
      it 'returns true' do
        expect(engine.send(:transfer_resource_from_effect, effect)).to be true
      end
    end
    
    context 'with one-time transfer' do
      let(:effect) { { 'source_unit' => 'Tank A', 'target_unit' => 'Tank B', 'resource' => 'water' } }
      
      it 'returns true' do
        expect(engine.send(:transfer_resource_from_effect, effect)).to be true
      end
    end
  end
  
  describe '#initiate_construction' do
    let(:engine) { AIManager::TaskExecutionEngine.new(mission_id) }
    
    context 'with crater_dome structure' do
      let(:task) do
        {
          'structure_type' => 'crater_dome',
          'name' => 'Test Dome',
          'diameter' => 150.0,
          'depth' => 30.0
        }
      end
      
      let(:mock_material_requests) { double('material_requests', update_all: true) }
      let(:mock_equipment_requests) { double('equipment_requests', update_all: true, any?: false) }
      let(:mock_job) { instance_double(ConstructionJob, material_requests: mock_material_requests, equipment_requests: mock_equipment_requests) }
      
      before do
        allow(ConstructionJobService).to receive(:create_job).and_return(mock_job)
        allow(ConstructionJobService).to receive(:start_construction).and_return(true)
        allow(engine).to receive(:track_construction_resources)
      end
      
      it 'creates a crater dome structure' do
        expect {
          engine.send(:initiate_construction, task)
        }.to change { Structures::CraterDome.count }.by(1)
        
        dome = Structures::CraterDome.last
        expect(dome.name).to include('Test Dome')
      end
      
      it 'uses ConstructionJobService' do
        expect(ConstructionJobService).to receive(:create_job)
        expect(ConstructionJobService).to receive(:start_construction)
        engine.send(:initiate_construction, task)
      end
    end
    
    context 'with skylight_cover structure' do
      let(:task) { { 'structure_type' => 'skylight_cover' } }
      
      it 'skips skylight for AI simulation' do
        expect(engine.send(:initiate_construction, task)).to be true
      end
    end
  end
  
  describe '#update_mission_progress' do
    let(:engine) { AIManager::TaskExecutionEngine.new(mission_id) }
    
    before do
      engine.instance_variable_set(:@current_task_index, 1)
    end
    
    it 'calculates and updates progress percentage' do
      engine.send(:update_mission_progress)
      
      mission.reload
      expected_progress = ((1.0 / task_list.length) * 100).round
      expect(mission.progress).to eq(expected_progress)
    end
    
    it 'updates operational_data with task counts' do
      engine.send(:update_mission_progress)
      
      mission.reload
      expect(mission.operational_data['current_task']).to eq(1)
      expect(mission.operational_data['total_tasks']).to eq(task_list.length)
    end
  end
  
  describe '#complete_mission' do
    let(:engine) { AIManager::TaskExecutionEngine.new(mission_id) }
    
    before do
      allow(ResourceTrackingService).to receive(:track_inventory_snapshot)
    end
    
    it 'updates mission status to completed' do
      engine.send(:complete_mission)
      
      mission.reload
      expect(mission.status).to eq('completed')
    end
    
    it 'sets progress to 100' do
      engine.send(:complete_mission)
      
      mission.reload
      expect(mission.progress).to eq(100)
    end
    
    it 'sets completion_date' do
      engine.send(:complete_mission)
      
      mission.reload
      expect(mission.completion_date).to be_present
    end
    
    it 'calls ResourceTrackingService' do
      expect(ResourceTrackingService).to receive(:track_inventory_snapshot).with(settlement)
      engine.send(:complete_mission)
    end
  end
  
  describe '#production_summary' do
    let(:engine) { AIManager::TaskExecutionEngine.new(mission_id) }
    
    before do
      engine.instance_variable_set(:@produced_materials, { 'ibeam' => 100, 'O2' => 5 })
      engine.instance_variable_set(:@consumed_materials, { 'depleted_regolith' => 5000, 'regolith' => 2000 })
    end
    
    it 'generates summary of production' do
      summary = engine.send(:production_summary)
      
      expect(summary).to include('MATERIALS PRODUCED')
      expect(summary).to include('ibeam: 100')
      expect(summary).to include('O2: 5')
    end
    
    it 'generates summary of consumption' do
      summary = engine.send(:production_summary)
      
      expect(summary).to include('MATERIALS CONSUMED')
      expect(summary).to include('depleted_regolith: 5000')
      expect(summary).to include('regolith: 2000')
    end
  end
  
  describe '.orbital_resupply_cycle' do
    let(:player) { create(:player) }
    let!(:project) { create(:orbital_construction_project, status: 'in_progress') }

    before do
      @l1_station = create(:base_settlement, name: 'L1 Depot', owner: player, settlement_type: :station)
      @lunar_settlement = create(:base_settlement, name: 'Lunar Base', owner: player)
      @hlt_craft = create(:base_craft, docked_at: @lunar_settlement, status: 'operational', craft_type: 'heavy_lift_transport')
      @l1_station.save!
      @lunar_settlement.save!
      @hlt_craft.save!
      project.update!(station: @l1_station)
      
      allow(described_class).to receive(:check_material_surplus).with(anything, 'ibeam').and_return(500)
      allow(described_class).to receive(:check_material_surplus).with(anything, 'modular_structural_panel_base').and_return(300)
      allow(Logistics::InventoryManager).to receive(:transfer_item).and_return(true)
      allow(described_class).to receive(:process_project_payment)
    end

    context 'when conditions are met for resupply' do
      it 'schedules a material ferry mission' do
        expect {
          described_class.orbital_resupply_cycle
        }.to change { Mission.count }.by(1)
      end

      it 'updates craft status' do
        described_class.orbital_resupply_cycle
        @hlt_craft.reload
        expect(@hlt_craft.status).to eq('operational')
      end
    end

    context 'when no active projects' do
      before do
        project.update!(status: 'completed')
      end

      it 'does not schedule missions' do
        expect {
          described_class.orbital_resupply_cycle
        }.not_to change { Mission.count }
      end
    end
  end
  
  describe '.check_material_surplus' do
    let(:settlement) { create(:base_settlement) }

    before do
      allow(settlement.inventory).to receive(:current_storage_of).with('ibeam').and_return(500)
    end

    it 'returns surplus above threshold' do
      surplus = described_class.send(:check_material_surplus, settlement, 'ibeam')
      expect(surplus).to eq(400) # 500 - 100
    end

    context 'when below threshold' do
      before do
        allow(settlement.inventory).to receive(:current_storage_of).with('ibeam').and_return(50)
      end

      it 'returns 0' do
        surplus = described_class.send(:check_material_surplus, settlement, 'ibeam')
        expect(surplus).to eq(0)
      end
    end
  end
end