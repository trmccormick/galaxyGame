# frozen_string_literal: true

module Admin
  # Admin dashboard controller
  # Main control center for game administration and AI testing
  class DashboardController < ApplicationController
    def index
      @celestial_bodies = CelestialBody.includes(:solar_system)
                                       .order('solar_systems.name, celestial_bodies.name')
                                       .limit(50)
      
      @system_stats = calculate_system_stats
      @recent_activity = load_recent_activity
    end

    private

    def calculate_system_stats
      {
        total_bodies: CelestialBody.count,
        total_systems: SolarSystem.count,
        habitable_bodies: count_habitable_bodies,
        active_simulations: 0, # TODO: Implement simulation tracking
        ai_missions_running: 0, # TODO: Integrate with AI Manager
        uptime: calculate_uptime
      }
    end

    def count_habitable_bodies
      # Count bodies with atmosphere and acceptable temperature
      CelestialBody.joins(:atmosphere)
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
  end
end
