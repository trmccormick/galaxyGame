# frozen_string_literal: true

require 'celestial_bodies/celestial_body'

module Admin
  # Admin dashboard controller
  # Main control center for game administration and AI testing
  class DashboardController < ApplicationController
    def index
      # Load galaxies for selection
      @galaxies = Galaxy.includes(:solar_systems).order(:name)
      
      # Default to Milky Way, fallback to first galaxy
      @selected_galaxy = params[:galaxy_id] ? 
        Galaxy.find(params[:galaxy_id]) : 
        Galaxy.find_by(name: 'Milky Way') || @galaxies.first
      
      # Load systems for selected galaxy, prioritize Sol
      if @selected_galaxy
        @star_systems = @selected_galaxy.solar_systems
          .includes(:celestial_bodies)
          .order(Arel.sql("CASE WHEN name = 'Sol' THEN 0 ELSE 1 END, name"))
          .limit(50) # Limit for performance
        
        # Find Sol system for quick access
        @sol_system = @selected_galaxy.solar_systems.find_by(name: 'Sol') if @selected_galaxy.name == 'Milky Way'
        
        # Load celestial bodies for backward compatibility (used by GCC Bootstrap Test)
        @celestial_bodies = @selected_galaxy.solar_systems
          .includes(:celestial_bodies)
          .flat_map(&:celestial_bodies)
          .uniq
          .sort_by(&:name)
          .first(50) # Limit for performance
      else
        @star_systems = []
        @sol_system = nil
        @celestial_bodies = []
      end
      
      # Keep existing AI and activity data
      @ai_status = load_ai_status
      @ai_activity_feed = load_ai_activity_feed
      @economic_indicators = load_economic_indicators
      
      @galaxy_stats = calculate_galaxy_stats(@selected_galaxy)
      @system_stats = calculate_global_system_stats
      @recent_activity = load_recent_activity
    end

    private

    def calculate_global_system_stats
      {
        total_bodies: ::CelestialBodies::CelestialBody.count,
        total_systems: SolarSystem.count,
        total_galaxies: Galaxy.count,
        habitable_bodies: count_habitable_bodies,
        active_simulations: 0, # TODO: Implement simulation tracking
        ai_missions_running: @ai_status[:active_missions],
        uptime: calculate_uptime,
        ai_status: @ai_status[:manager_status],
        gcc_generation: @ai_status[:gcc_generation] ? 'Active' : 'None',
        economic_autonomy: @ai_status[:economic_autonomy] ? 'Yes' : 'No'
      }
    end

    def calculate_galaxy_stats(galaxy)
      return {} unless galaxy
      
      total_bodies = galaxy.solar_systems.joins(:celestial_bodies).count
      total_systems = galaxy.solar_systems.count
      
      {
        total_galaxy_bodies: total_bodies,
        total_galaxy_systems: total_systems,
        habitable_bodies: count_habitable_bodies_in_galaxy(galaxy),
        active_simulations: 0, # TODO: Implement simulation tracking
        ai_missions_running: @ai_status[:active_missions],
        uptime: calculate_uptime,
        ai_status: @ai_status[:manager_status],
        gcc_generation: @ai_status[:gcc_generation] ? 'Active' : 'None',
        economic_autonomy: @ai_status[:economic_autonomy] ? 'Yes' : 'No'
      }
    end

    def count_habitable_bodies
      # Count bodies with atmosphere and acceptable temperature globally
      ::CelestialBodies::CelestialBody.joins(:atmosphere)
                   .where('surface_temperature > ? AND surface_temperature < ?', 250, 350)
                   .count
    rescue StandardError
      0
    end

    def count_habitable_bodies_in_galaxy(galaxy)
      # Count bodies with atmosphere and acceptable temperature in this galaxy
      galaxy.solar_systems.joins(celestial_bodies: :atmosphere)
             .where('surface_temperature > ? AND surface_temperature < ?', 250, 350)
             .count
    rescue StandardError
      0
    end

    def calculate_uptime
      # Get Rails application uptime
      if defined?(Rails::Info)
        started_at = File.mtime(Rails.root.join('tmp', 'pids', 'server.pid'))
        seconds = Time.now - started_at
        
        days = (seconds / 86400).floor
        hours = ((seconds % 86400) / 3600).floor
        minutes = ((seconds % 3600) / 60).floor
        
        "#{days}d #{hours}h #{minutes}m"
      else
        "Unknown"
      end
    rescue StandardError
      "Unknown"
    end

    def load_recent_activity
      # Placeholder for activity log
      # TODO: Implement proper activity tracking
      [
        { 
          timestamp: 5.minutes.ago, 
          type: 'system', 
          message: 'Database connection healthy',
          level: 'info'
        },
        { 
          timestamp: 10.minutes.ago, 
          type: 'simulation', 
          message: 'Background simulation tick completed',
          level: 'success'
        },
        { 
          timestamp: 15.minutes.ago, 
          type: 'ai', 
          message: 'AI Manager ready for testing',
          level: 'info'
        }
      ]
    end

    def load_ai_status
      # AI Manager status and capabilities
      {
        manager_status: 'online',
        bootstrap_capable: true,
        active_missions: 0,
        learned_patterns: 42, # TODO: Get actual count from AI Manager
        last_decision: 2.minutes.ago,
        gcc_generation: check_gcc_generation,
        economic_autonomy: check_economic_autonomy
      }
    end

    def load_ai_activity_feed
      # Recent AI decisions and actions
      [
        {
          timestamp: 1.minute.ago,
          type: 'analysis',
          message: 'Analyzing system for GCC generation opportunities',
          level: 'info',
          details: 'AI Manager scanning for missing cryptocurrency infrastructure'
        },
        {
          timestamp: 5.minutes.ago,
          type: 'decision',
          message: 'Decision: Deploy mining satellite for GCC bootstrap',
          level: 'success',
          details: 'AI determined mining satellite deployment as highest priority action'
        },
        {
          timestamp: 10.minutes.ago,
          type: 'planning',
          message: 'Planning: Resource acquisition for satellite construction',
          level: 'info',
          details: 'Calculating material requirements and launch costs'
        }
      ]
    end

    def load_economic_indicators
      # Economic status and AI-driven activities
      {
        total_gcc: 0, # TODO: Get from actual economy
        usd_balance: 1000000, # TODO: Get from actual accounts
        active_trades: 0,
        resource_flows: 0,
        ai_initiated_transactions: 0,
        bootstrap_progress: 0 # 0-100%
      }
    end

    def check_gcc_generation
      # Check if GCC is being generated anywhere in the system
      # TODO: Implement actual GCC generation check
      false
    end

    def check_economic_autonomy
      # Check if AI can operate independently
      # TODO: Implement actual autonomy check
      false
    end
  end
end
