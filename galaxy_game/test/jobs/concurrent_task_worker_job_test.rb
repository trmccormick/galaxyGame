require "test_helper"

class ConcurrentTaskWorkerJobTest < ActiveJob::TestCase
  def test_perform_with_manufacturing_task
    # Create test data
    player = create(:player)
    celestial_body = create(:celestial_body, name: 'Luna')
    location = create(:celestial_location, celestial_body: celestial_body)
    settlement = create(:base_settlement, location: location, owner: player)
    mission = create(:mission, identifier: 'test_mission', settlement: settlement)
    
    task = {
      'task_id' => 'print_ibeams',
      'description' => 'Print I-beam structure',
      'type' => 'manufacture'
    }
    
    # Mock the task execution
    AIManager::TaskExecutionEngine.any_instance.expects(:execute_task).returns(true)
    AIManager::TaskExecutionEngine.any_instance.expects(:mark_concurrent_task_completed)
    
    # Perform the job
    ConcurrentTaskWorkerJob.perform_now('test_mission', task, 0)
    
    # Verify byproduct generation occurred (would need to check settlement resources)
    # This is a basic test - more detailed testing would require setting up resource tracking
  end
end
