module Admin
  class AiManagerController < ApplicationController
    # Ensure AIManager module is loaded
    require_dependency 'ai_manager/task_execution_engine' if Rails.env.test?
    
    def missions
      # Load all missions from database
      @missions = Mission.includes(:settlement).order(created_at: :desc)
      @active_missions = @missions.where(status: [:in_progress])
      @completed_missions = @missions.where(status: [:completed])
      @failed_missions = @missions.where(status: [:failed, :stalled])
      
      @active_missions_count = @active_missions.count
      @completed_missions_count = @completed_missions.count
      @failed_missions_count = @failed_missions.count
    end
    
    def show_mission
      # Load specific mission with task data
      @mission = Mission.find(params[:id])
      @engine = ::AIManager::TaskExecutionEngine.new(@mission.identifier)
      @task_list = @engine.instance_variable_get(:@task_list)
      @current_task_index = @engine.instance_variable_get(:@current_task_index)
      @manifest = @engine.instance_variable_get(:@manifest)
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_ai_manager_missions_path, alert: "Mission not found"
    end
    
    def advance_phase
      @mission = Mission.find(params[:id])
      engine = ::AIManager::TaskExecutionEngine.new(@mission.identifier)
      
      if engine.execute_next_task
        redirect_to admin_ai_manager_mission_path(@mission), notice: "Phase advanced successfully"
      else
        redirect_to admin_ai_manager_mission_path(@mission), alert: "Failed to advance phase"
      end
    end
    
    def reset_mission
      @mission = Mission.find(params[:id])
      @mission.update(progress: 0, status: :in_progress)
      redirect_to admin_ai_manager_mission_path(@mission), notice: "Mission reset to beginning"
    end
    
    def planner
      # Mission planning simulator
      @available_patterns = ['mars-terraforming', 'venus-industrial', 'titan-fuel', 'asteroid-mining', 'europa-water']
      @simulation_result = nil
      @forecast = nil
      
      if params[:pattern].present?
        # Run simulation
        @planner = AIManager::MissionPlannerService.new(
          params[:pattern],
          {
            tech_level: params[:tech_level] || 'standard',
            timeline_years: params[:timeline_years]&.to_i || 10,
            budget_gcc: params[:budget_gcc]&.to_i || 1_000_000,
            priority: params[:priority] || 'balanced'
          }
        )
        
        @simulation_result = @planner.simulate
        @forecaster = AIManager::EconomicForecasterService.new(@simulation_result)
        @forecast = @forecaster.analyze
      end
    end
    
    def export_plan
      planner = AIManager::MissionPlannerService.new(
        params[:pattern],
        JSON.parse(params[:parameters] || '{}')
      )
      planner.simulate
      
      send_data planner.export_plan, 
        filename: "mission_plan_#{params[:pattern]}_#{Time.current.to_i}.json",
        type: 'application/json'
    end
    
    def decisions
      # TODO: Load AI decision log
      @decisions = []
    end
    
    def patterns
      # TODO: Load AI patterns for testing
      @patterns = []
    end
    
    def performance
      # TODO: Load AI performance metrics
      @metrics = {
        success_rate: 0,
        average_timeline: 0,
        resource_efficiency: 0
      }
    end
  end
end
