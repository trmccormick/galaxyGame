module Admin
  class AiManagerController < ApplicationController
        def testing_validation
          # Stub action for validation suite
          render plain: 'Validation suite stub - implementation pending.'
        end
    def testing
      @test_bodies = ::CelestialBodies::CelestialBody.where.not(type: 'star').order(:name).limit(20)
      @test_stats = { total_runs: 0, passed: 0, failed: 0 }
      render 'admin/ai_manager/testing/index'
    end
    
    def index
      # System status overview
      @system_status = {
        active_missions: Mission.where(status: [:in_progress]).count,
        completed_missions: Mission.where(status: [:completed]).count,
        failed_missions: Mission.where(status: [:failed, :stalled]).count,
        total_missions: Mission.count,
        ai_services_status: check_ai_services_status,
        last_activity: Mission.order(updated_at: :desc).first&.updated_at
      }
      
      # Active missions summary
      @active_missions = Mission.where(status: [:in_progress]).includes(:settlement).limit(5)
      
      # Performance metrics
      @performance_metrics = calculate_performance_metrics
      
      # System alerts
      @system_alerts = collect_system_alerts
      
      # Quick action data
      @quick_actions = {
        planner: { path: admin_ai_manager_planner_path, title: 'Mission Planner', description: 'Plan and simulate new missions' },
        decisions: { path: admin_ai_manager_decisions_path, title: 'Decision Log', description: 'Review AI decision history' },
        patterns: { path: admin_ai_manager_patterns_path, title: 'Pattern Analysis', description: 'Analyze and test AI patterns' },
        performance: { path: admin_ai_manager_performance_path, title: 'Performance Metrics', description: 'Monitor AI system performance' },
        testing: { path: '/admin/ai_manager/testing', title: 'Testing & Validation', description: 'Run AI system tests, validations, and bootstrap operations' }
      }
    end
    
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
    
    private
    
    def check_ai_services_status
      # Check if key AI services are operational
      services = {}
      
      # Check if AI Manager services can be instantiated
      begin
        AIManager::MissionPlannerService.new('test', {})
        services[:mission_planner] = :operational
      rescue => e
        services[:mission_planner] = :error
      end
      
      begin
        AIManager::EconomicForecasterService.new({})
        services[:economic_forecaster] = :operational
      rescue => e
        services[:economic_forecaster] = :error
      end
      
      begin
        AIManager::StationConstructionStrategy.new({})
        services[:station_construction] = :operational
      rescue => e
        services[:station_construction] = :error
      end
      
      services
    end
    
    def calculate_performance_metrics
      total_missions = Mission.count
      return { success_rate: 0, average_timeline: 0, resource_efficiency: 0 } if total_missions.zero?
      
      completed_missions = Mission.where(status: :completed).count
      success_rate = (completed_missions.to_f / total_missions * 100).round(1)
      
      # Calculate average timeline (simplified)
      avg_timeline = Mission.where(status: :completed).average('EXTRACT(EPOCH FROM (updated_at - created_at))/86400')&.round(1) || 0
      
      # Resource efficiency (simplified metric)
      resource_efficiency = [success_rate * 0.8, 100].min.round(1)
      
      {
        success_rate: success_rate,
        average_timeline: avg_timeline,
        resource_efficiency: resource_efficiency
      }
    end
    
    def collect_system_alerts
      alerts = []
      
      # Check for failed missions
      failed_count = Mission.where(status: [:failed, :stalled]).count
      if failed_count > 0
        alerts << {
          type: :warning,
          message: "#{failed_count} mission(s) have failed or stalled",
          action: admin_ai_manager_missions_path,
          action_text: 'Review Missions'
        }
      end
      
      # Check AI service status
      ai_status = check_ai_services_status
      ai_status.each do |service, status|
        if status == :error
          alerts << {
            type: :error,
            message: "#{service.to_s.humanize} service is experiencing errors",
            action: admin_ai_manager_performance_path,
            action_text: 'Check Performance'
          }
        end
      end
      
      # Check for old missions without updates
      stale_missions = Mission.where(status: :in_progress).where('updated_at < ?', 7.days.ago).count
      if stale_missions > 0
        alerts << {
          type: :info,
          message: "#{stale_missions} mission(s) haven't been updated in over a week",
          action: admin_ai_manager_missions_path,
          action_text: 'Review Stale Missions'
        }
      end
      
      alerts
    end
    
    # Maps simplified UI pattern names to actual JSON pattern identifiers
    def available_mission_patterns
      {
        'mars-terraforming' => 'mars_pattern',
        'venus-industrial' => 'venus_pattern', 
        'titan-fuel' => 'titan_pattern',
        'asteroid-mining' => 'gcc_mining_satellite_01_pattern',
        'europa-water' => 'europa_subsurface_exploration_pattern'
      }
    end
  end
end
