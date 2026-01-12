class TaskExecutionWorker
  include Sidekiq::Worker

  def perform(mission_id, task_index)
    # Find the mission and execute the next task
    engine = AIManager::TaskExecutionEngine.new(mission_id)
    engine.execute_next_task
  end
end