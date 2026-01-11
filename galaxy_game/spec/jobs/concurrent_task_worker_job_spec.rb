require 'rails_helper'

RSpec.describe ConcurrentTaskWorkerJob, type: :job do
  let!(:player) { create(:player) }
  let!(:celestial_body) { create(:celestial_body, name: 'Luna') }
  let!(:location) { create(:celestial_location, celestial_body: celestial_body) }
  let!(:settlement) { create(:base_settlement, location: location, owner: player) }
  let!(:mission) { create(:mission, identifier: 'test_mission', settlement: settlement) }
  
  let(:task) do
    {
      'task_id' => 'print_ibeams',
      'description' => 'Print I-beam structure',
      'type' => 'manufacture'
    }
  end
  
  describe '#perform' do
    let(:engine) { instance_double(AIManager::TaskExecutionEngine) }
    
    before do
      allow(AIManager::TaskExecutionEngine).to receive(:new).and_return(engine)
      allow(engine).to receive(:execute_task).and_return(true)
      allow(engine).to receive(:mark_concurrent_task_completed)
      allow(engine).to receive(:settlement).and_return(settlement)
    end
    
    context 'with manufacturing task during daylight' do
      before do
        allow(location).to receive(:solar_output_factor).and_return(1.0)
        allow(settlement.inventory).to receive(:add_item)
      end
      
      it 'executes the task successfully' do
        expect(engine).to receive(:execute_task).with(task).and_return(true)
        expect(engine).to receive(:mark_concurrent_task_completed).with(task)
        
        ConcurrentTaskWorkerJob.perform_now('test_mission', task, 0)
      end
      
      it 'generates manufacturing byproducts' do
        expect(settlement.inventory).to receive(:add_item).with('O2', 0.001)
        expect(settlement.inventory).to receive(:add_item).with('H2O', 0.0005)
        
        ConcurrentTaskWorkerJob.perform_now('test_mission', task, 0)
      end
    end
    
    context 'with manufacturing task during low light' do
      before do
        allow(location).to receive(:solar_output_factor).and_return(0.05) # Below 0.1 threshold
      end
      
      it 'does not generate byproducts' do
        expect(settlement.inventory).not_to receive(:add_item)
        
        ConcurrentTaskWorkerJob.perform_now('test_mission', task, 0)
      end
    end
    
    context 'with non-manufacturing task' do
      let(:logistics_task) do
        {
          'task_id' => 'unload_n2',
          'description' => 'Unload nitrogen tanks',
          'type' => 'transfer'
        }
      end
      
      it 'does not attempt byproduct generation' do
        expect(settlement.inventory).not_to receive(:add_item)
        
        ConcurrentTaskWorkerJob.perform_now('test_mission', logistics_task, 0)
      end
    end
    
    context 'when task execution fails' do
      before do
        allow(engine).to receive(:execute_task).and_return(false)
        allow(engine).to receive(:mark_concurrent_task_completed).never
      end
      
      it 'does not mark task as completed' do
        expect(engine).not_to receive(:mark_concurrent_task_completed)
        
        ConcurrentTaskWorkerJob.perform_now('test_mission', task, 0)
      end
    end
  end
end