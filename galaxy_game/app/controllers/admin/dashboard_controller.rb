class Admin::DashboardController < ApplicationController
  def index
    @system_stats  = build_system_stats
    @galaxy_stats  = build_galaxy_stats
    @ai_status     = build_ai_status
    @economic_indicators = build_economic_indicators
    @network_stats = build_network_stats
    @recent_activity    = build_recent_activity
    @ai_activity_feed   = build_ai_activity_feed
    @celestial_bodies   = ::CelestialBodies::CelestialBody.all
  end

  private

  # ---------------------------------------------------------------------------
  # System
  # ---------------------------------------------------------------------------

  def build_system_stats
    {
      uptime: calculate_uptime
    }
  end

  # ---------------------------------------------------------------------------
  # Galaxy
  # ---------------------------------------------------------------------------

  def build_galaxy_stats
    {
      total_systems:    SolarSystem.count,
      total_bodies:     ::CelestialBodies::CelestialBody.count,
      habitable_bodies: ::CelestialBodies::CelestialBody
                          .where('tei_score >= ?', 0.4)
                          .count,
      settlements:      Settlement.count
    }
  rescue StandardError => e
    Rails.logger.error("DashboardController#build_galaxy_stats failed: #{e.message}")
    { total_systems: 0, total_bodies: 0, habitable_bodies: 0, settlements: 0 }
  end

  # ---------------------------------------------------------------------------
  # AI Manager
  # ---------------------------------------------------------------------------

  def build_ai_status
    {
      manager_status:     'online',
      bootstrap_capable:  true,
      learned_patterns:   ::AiDecision.count,
      last_decision:      ::AiDecision.recent.first&.timestamp || 1.hour.ago,
      active_simulations: sidekiq_simulation_count
    }
  rescue StandardError => e
    Rails.logger.error("DashboardController#build_ai_status failed: #{e.message}")
    {
      manager_status:     'offline',
      bootstrap_capable:  false,
      learned_patterns:   0,
      last_decision:      1.hour.ago,
      active_simulations: 0
    }
  end

  # ---------------------------------------------------------------------------
  # Economy
  # Note: USD Balance removed - it is an NPC corp metric, not a game-wide stat
  # ---------------------------------------------------------------------------

  def build_economic_indicators
    {
      total_gcc:    calculate_total_gcc,
      minting_rate: 1200,  # GCC/day - TODO: derive from active mining satellites
      active_trades: 0,    # TODO: Market::Order.active.count
      daily_volume:  0     # TODO: Market::Order.where('created_at >= ?', 24.hours.ago).sum(:amount)
    }
  rescue StandardError => e
    Rails.logger.error("DashboardController#build_economic_indicators failed: #{e.message}")
    { total_gcc: 0, minting_rate: 0, active_trades: 0, daily_volume: 0 }
  end

  # ---------------------------------------------------------------------------
  # Network
  # ---------------------------------------------------------------------------

  def build_network_stats
    {
      wormholes:          Wormhole.count,
      connected_systems:  calculate_connected_systems,
      isolated_systems:   calculate_isolated_systems
    }
  rescue StandardError => e
    Rails.logger.error("DashboardController#build_network_stats failed: #{e.message}")
    { wormholes: 0, connected_systems: 0, isolated_systems: 0 }
  end

  # ---------------------------------------------------------------------------
  # Activity feeds
  # These will be replaced with real model queries once ActivityLog exists
  # ---------------------------------------------------------------------------

  def build_recent_activity
    # TODO: Replace with ActivityLog.order(created_at: :desc).limit(10).map { ... }
    [
      { type: 'info', message: 'System initialized',  timestamp: 1.hour.ago },
      { type: 'ai',   message: 'AI decision made',    timestamp: 30.minutes.ago }
    ]
  end

  def build_ai_activity_feed
    # TODO: Replace with AiActivityLog.order(created_at: :desc).limit(10).map { ... }
    [
      { type: 'analysis', message: 'AI started',    details: 'AI system booted',              timestamp: 1.hour.ago },
      { type: 'decision', message: 'Decision made', details: 'Allocated resources to Mars',   timestamp: 30.minutes.ago },
      { type: 'idle',     message: 'AI idle',       details: 'No recent activity',            timestamp: 10.minutes.ago }
    ]
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  def calculate_uptime
    # TODO: Track real game start time in GameState or similar
    'N/A'
  end

  def calculate_total_gcc
    # TODO: Sum all GCC balances across players, NPCs, AI Manager
    # e.g. Account.sum(:gcc_balance)
    0
  end

  def calculate_connected_systems
    # TODO: Traverse wormhole graph to count reachable systems
    SolarSystem.count
  rescue StandardError
    0
  end

  def calculate_isolated_systems
    # TODO: Systems with no wormhole connections
    0
  end

  def sidekiq_simulation_count
    Sidekiq::Queue.new('simulations').size
  rescue StandardError
    0
  end
end
