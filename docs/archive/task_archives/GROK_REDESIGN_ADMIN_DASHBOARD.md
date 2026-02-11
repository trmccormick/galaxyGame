# TASK: Redesign Admin Dashboard - System-Centric Navigation

## Current Problems

1. **Inline CSS** - 132 lines of styles embedded in ERB (bad practice)
2. **Flat navigation** - Shows list of celestial bodies without system hierarchy
3. **Missing context** - No breadcrumbs or hierarchical navigation
4. **Underutilized structure** - Already have `admin/solar_systems/` but not integrated with dashboard
5. **Poor scalability** - Can't browse hundreds/thousands of bodies efficiently

## New Dashboard Architecture

### Concept: System-Centric Entry Point

The dashboard should be the **galaxy command center** - showing star systems as the primary navigation unit, not individual bodies.

```
DASHBOARD VIEW
├── Galaxy Overview Stats
├── Star Systems Grid (primary navigation)
│   ├── Sol System Card
│   │   ├── Quick stats: 1 star, 8 planets, 200+ moons
│   │   ├── Preview: Sun, Earth, Mars, Jupiter...
│   │   └── Actions: [View System] [Monitor All] [Generate Report]
│   ├── AOL-732356 Card
│   │   ├── Quick stats: 2 stars, 5 planets, 12 moons
│   │   └── Actions: [View System] [Monitor All]
│   └── ATJD-566085 Card
├── System Alerts/Notifications
├── AI Manager Status (condensed)
└── Quick Actions Panel
```

### User Flow
1. **Dashboard** → See all star systems at a glance
2. **Click system card** → Go to `/admin/solar_systems/:id` (hierarchical view)
3. **Browse system** → See all bodies organized by type (stars → planets → moons → minor bodies)
4. **Select body** → Go to body detail/monitor view
5. **Breadcrumbs everywhere** → Admin → Milky Way → Sol → Earth → Monitor

## Implementation

### Step 1: Extract CSS to Separate File

**Create:** `app/assets/stylesheets/admin/dashboard.css`

```css
/* Admin Dashboard Styles */

/* System Cards Grid */
.systems-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
}

.system-card {
    background: linear-gradient(135deg, #1a1a1a 0%, #0a0a0a 100%);
    border: 2px solid #0f0;
    border-radius: 8px;
    padding: 20px;
    transition: all 0.3s;
    cursor: pointer;
    position: relative;
    overflow: hidden;
}

.system-card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 4px;
    background: linear-gradient(90deg, #0f0, #0ff);
    opacity: 0;
    transition: opacity 0.3s;
}

.system-card:hover {
    border-color: #0ff;
    transform: translateY(-4px);
    box-shadow: 0 8px 20px rgba(0, 255, 255, 0.3);
}

.system-card:hover::before {
    opacity: 1;
}

.system-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
}

.system-name {
    font-size: 24px;
    color: #0ff;
    font-weight: bold;
    text-transform: uppercase;
}

.system-identifier {
    font-size: 11px;
    color: #666;
    background: #0a0a0a;
    padding: 4px 8px;
    border-radius: 3px;
    font-family: monospace;
}

.system-stats {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 10px;
    margin: 15px 0;
    padding: 15px;
    background: rgba(0, 0, 0, 0.5);
    border-radius: 5px;
}

.system-stat {
    text-align: center;
}

.system-stat-value {
    font-size: 20px;
    color: #0f0;
    font-weight: bold;
    display: block;
}

.system-stat-label {
    font-size: 10px;
    color: #888;
    text-transform: uppercase;
    margin-top: 2px;
}

.system-preview {
    margin: 15px 0;
    padding: 10px;
    background: rgba(0, 255, 0, 0.05);
    border-left: 3px solid #0f0;
    border-radius: 3px;
}

.system-preview-label {
    font-size: 10px;
    color: #888;
    text-transform: uppercase;
    margin-bottom: 5px;
}

.system-bodies-list {
    display: flex;
    flex-wrap: wrap;
    gap: 5px;
}

.body-pill {
    font-size: 11px;
    padding: 3px 8px;
    background: #1a1a1a;
    border: 1px solid #333;
    border-radius: 12px;
    color: #0ff;
}

.body-pill.star { border-color: #ffd700; color: #ffd700; }
.body-pill.planet { border-color: #0f0; color: #0f0; }
.body-pill.moon { border-color: #ff0; color: #ff0; }

.system-actions {
    display: flex;
    gap: 10px;
    margin-top: 15px;
}

.system-action-btn {
    flex: 1;
    padding: 10px;
    background: #222;
    border: 1px solid #0f0;
    color: #0f0;
    text-align: center;
    text-decoration: none;
    border-radius: 5px;
    font-size: 12px;
    font-weight: bold;
    transition: all 0.2s;
    cursor: pointer;
}

.system-action-btn:hover {
    background: #0f0;
    color: #000;
}

.system-action-btn.primary {
    background: #0f0;
    color: #000;
}

.system-action-btn.primary:hover {
    background: #0ff;
}

/* Dashboard Stats */
.dashboard-stats {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 15px;
    margin-bottom: 30px;
}

.dashboard-stat-card {
    background: #1a1a1a;
    border: 1px solid #333;
    border-radius: 5px;
    padding: 20px;
    text-align: center;
    transition: all 0.2s;
}

.dashboard-stat-card:hover {
    border-color: #0f0;
    background: #222;
}

.dashboard-stat-value {
    font-size: 36px;
    color: #0ff;
    font-weight: bold;
    margin: 10px 0;
}

.dashboard-stat-label {
    font-size: 12px;
    color: #888;
    text-transform: uppercase;
    letter-spacing: 1px;
}

.dashboard-stat-change {
    font-size: 11px;
    margin-top: 5px;
}

.dashboard-stat-change.positive {
    color: #0f0;
}

.dashboard-stat-change.negative {
    color: #f00;
}

/* Alerts Section */
.alerts-section {
    background: #1a1a1a;
    border: 2px solid #f90;
    border-radius: 8px;
    padding: 20px;
    margin-bottom: 30px;
}

.alerts-section.warning {
    border-color: #f90;
}

.alerts-section.error {
    border-color: #f00;
}

.alerts-section.info {
    border-color: #0ff;
}

.alert-item {
    padding: 10px;
    margin: 5px 0;
    background: rgba(255, 153, 0, 0.1);
    border-left: 3px solid #f90;
    border-radius: 3px;
    font-size: 13px;
}

.alert-item .alert-time {
    color: #666;
    font-size: 11px;
    margin-right: 10px;
}

.alert-item .alert-message {
    color: #f90;
}

/* Condensed Activity Feed */
.activity-feed-condensed {
    max-height: 250px;
    overflow-y: auto;
    background: #0a0a0a;
    border: 1px solid #333;
    border-radius: 5px;
    padding: 10px;
}

.activity-feed-item {
    padding: 8px;
    margin: 5px 0;
    border-bottom: 1px solid #1a1a1a;
    font-size: 12px;
}

.activity-feed-item:last-child {
    border-bottom: none;
}

.activity-feed-time {
    color: #666;
    font-size: 10px;
}

.activity-feed-message {
    color: #0ff;
    margin-top: 3px;
}

/* Quick Actions Panel */
.quick-actions-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 15px;
    margin-bottom: 20px;
}

.quick-action-card {
    background: #1a1a1a;
    border: 1px solid #333;
    border-radius: 5px;
    padding: 20px;
    text-align: center;
    cursor: pointer;
    transition: all 0.2s;
}

.quick-action-card:hover {
    border-color: #0f0;
    background: #222;
    transform: translateY(-2px);
}

.quick-action-icon {
    font-size: 32px;
    margin-bottom: 10px;
}

.quick-action-label {
    font-size: 13px;
    color: #0ff;
    font-weight: bold;
}

.quick-action-description {
    font-size: 11px;
    color: #666;
    margin-top: 5px;
}

/* Responsive Design */
@media (max-width: 1200px) {
    .systems-grid {
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    }
}

@media (max-width: 768px) {
    .systems-grid {
        grid-template-columns: 1fr;
    }
    
    .dashboard-stats {
        grid-template-columns: repeat(2, 1fr);
    }
}
```

### Step 2: Update Dashboard Controller

**File:** `app/controllers/admin/dashboard_controller.rb`

```ruby
class Admin::DashboardController < ApplicationController
  def index
    # Load all star systems with their celestial bodies
    @star_systems = StarSystem.includes(:celestial_bodies)
                              .order(:name)
    
    # Calculate galaxy-wide statistics
    @galaxy_stats = calculate_galaxy_stats
    
    # Get recent system alerts
    @system_alerts = get_recent_alerts
    
    # AI Manager status (condensed)
    @ai_status = {
      manager_status: 'online',
      active_missions: AIManager::Mission.active.count,
      last_decision: AIManager::Decision.order(created_at: :desc).first&.created_at || 1.hour.ago
    }
    
    # Recent activity (condensed - last 10 items)
    @recent_activity = ActivityLog.order(created_at: :desc).limit(10)
  end
  
  private
  
  def calculate_galaxy_stats
    total_bodies = CelestialBodies::CelestialBody.count
    total_systems = StarSystem.count
    
    {
      total_systems: total_systems,
      total_bodies: total_bodies,
      total_stars: CelestialBodies::CelestialBody.where("body_category LIKE '%star%'").count,
      total_planets: CelestialBodies::CelestialBody.where("body_category LIKE '%planet%'").count,
      total_moons: CelestialBodies::CelestialBody.where("body_category LIKE '%moon%'").count,
      habitable_worlds: CelestialBodies::CelestialBody.where(
        "surface_temperature > ? AND surface_temperature < ?", 273, 373
      ).count,
      active_settlements: Settlement::BaseSettlement.count,
      total_population: Settlement::BaseSettlement.sum(:population) || 0
    }
  end
  
  def get_recent_alerts
    alerts = []
    
    # Check for systems needing attention
    StarSystem.includes(:celestial_bodies).each do |system|
      # Example: Systems with no habitable worlds
      if system.celestial_bodies.none? { |b| b.surface_temperature&.between?(273, 373) }
        alerts << {
          level: 'warning',
          system: system.name,
          message: "No habitable worlds detected in system",
          timestamp: system.updated_at
        }
      end
      
      # Example: New systems
      if system.created_at > 24.hours.ago
        alerts << {
          level: 'info',
          system: system.name,
          message: "New system discovered",
          timestamp: system.created_at
        }
      end
    end
    
    alerts.sort_by { |a| a[:timestamp] }.reverse.take(5)
  end
end
```

### Step 3: Create New Dashboard View

**File:** `app/views/admin/dashboard/index.html.erb`

```erb
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="<%= form_authenticity_token %>">
    <title>Galaxy Game - Command Center</title>
    <%= stylesheet_link_tag 'admin/monitor', media: 'all' %>
    <%= stylesheet_link_tag 'admin/dashboard', media: 'all' %>
</head>
<body>
    <div id="mainContainer" style="grid-template-columns: 250px 1fr; grid-template-rows: 80px 1fr;">
        <!-- Header -->
        <div id="header" style="grid-column: 1 / -1;">
            <h1>🌌 GALAXY COMMAND CENTER</h1>
            <div id="planetInfo">
                <span style="color: #0ff;"><%= @galaxy_stats[:total_systems] %> Systems</span> |
                <span style="color: #0ff;"><%= @galaxy_stats[:total_bodies] %> Bodies</span> |
                <span style="color: #0f0;"><%= @galaxy_stats[:habitable_worlds] %> Habitable</span> |
                Status: <span style="color: #0f0;">OPERATIONAL</span>
            </div>
        </div>

        <!-- Left Panel: Navigation -->
        <div id="toolPanel">
            <div class="tool-section">
                <h3>🎯 ADMIN SECTIONS</h3>
                <button class="tool-button" onclick="window.location.href='/admin/dashboard'">
                    🏠 Dashboard
                </button>
                <button class="tool-button" onclick="window.location.href='/admin/galaxies'">
                    🌌 Galaxies
                </button>
                <button class="tool-button" onclick="window.location.href='/admin/solar_systems'">
                    ☀️ Star Systems
                </button>
                <button class="tool-button" onclick="window.location.href='/admin/celestial_bodies'">
                    🌍 All Bodies
                </button>
                <button class="tool-button" onclick="window.location.href='/admin/ai_manager/missions'">
                    🤖 AI Manager
                </button>
                <button class="tool-button" onclick="window.location.href='/admin/map_studio'">
                    🗺️ Map Studio
                </button>
                <button class="tool-button" onclick="window.location.href='/admin/settlements'">
                    🏗️ Settlements
                </button>
                <button class="tool-button" onclick="window.location.href='/admin/organizations'">
                    🏢 Organizations
                </button>
            </div>

            <div class="tool-section">
                <h3>🎮 QUICK ACTIONS</h3>
                <button class="tool-button" onclick="window.location.href='/'">
                    🏠 Main Game
                </button>
                <button class="tool-button" onclick="window.location.href='/sidekiq'">
                    📊 Background Jobs
                </button>
                <button class="tool-button" onclick="window.location.reload()">
                    🔄 Refresh
                </button>
            </div>

            <!-- Condensed AI Status -->
            <div class="tool-section">
                <h3>🤖 AI STATUS</h3>
                <div style="font-size: 12px; color: #888;">
                    <div style="margin: 5px 0;">
                        Status: <span style="color: #0f0;"><%= @ai_status[:manager_status].upcase %></span>
                    </div>
                    <div style="margin: 5px 0;">
                        Active Missions: <span style="color: #0ff;"><%= @ai_status[:active_missions] %></span>
                    </div>
                    <div style="margin: 5px 0;">
                        Last Decision: <span style="color: #0ff;"><%= time_ago_in_words(@ai_status[:last_decision]) %> ago</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Main Content -->
        <div id="mainContent">
            <!-- Galaxy Statistics -->
            <div class="dashboard-stats">
                <div class="dashboard-stat-card">
                    <div class="dashboard-stat-label">Star Systems</div>
                    <div class="dashboard-stat-value"><%= @galaxy_stats[:total_systems] %></div>
                </div>
                <div class="dashboard-stat-card">
                    <div class="dashboard-stat-label">Celestial Bodies</div>
                    <div class="dashboard-stat-value"><%= @galaxy_stats[:total_bodies] %></div>
                </div>
                <div class="dashboard-stat-card">
                    <div class="dashboard-stat-label">Habitable Worlds</div>
                    <div class="dashboard-stat-value"><%= @galaxy_stats[:habitable_worlds] %></div>
                </div>
                <div class="dashboard-stat-card">
                    <div class="dashboard-stat-label">Total Population</div>
                    <div class="dashboard-stat-value"><%= number_to_human(@galaxy_stats[:total_population]) %></div>
                </div>
                <div class="dashboard-stat-card">
                    <div class="dashboard-stat-label">Settlements</div>
                    <div class="dashboard-stat-value"><%= @galaxy_stats[:active_settlements] %></div>
                </div>
            </div>

            <!-- System Alerts (if any) -->
            <% if @system_alerts.any? %>
                <div class="alerts-section warning">
                    <h3 style="margin: 0 0 15px 0; color: #f90;">⚠️ SYSTEM ALERTS</h3>
                    <% @system_alerts.each do |alert| %>
                        <div class="alert-item">
                            <span class="alert-time"><%= time_ago_in_words(alert[:timestamp]) %> ago</span>
                            <span class="alert-message">
                                [<%= alert[:system] %>] <%= alert[:message] %>
                            </span>
                        </div>
                    <% end %>
                </div>
            <% end %>

            <!-- Star Systems Grid -->
            <h2 style="color: #0ff; margin-bottom: 20px;">☀️ STAR SYSTEMS</h2>
            
            <% if @star_systems.empty? %>
                <div style="text-align: center; padding: 60px; color: #666;">
                    <div style="font-size: 64px; margin-bottom: 20px;">🌌</div>
                    <div style="font-size: 18px; margin-bottom: 10px;">No star systems found</div>
                    <div style="font-size: 13px; color: #888;">
                        Initialize the simulation or load system data to get started.
                    </div>
                    <button class="tool-button" style="margin-top: 20px;" onclick="window.location.href='/admin/solar_systems/new'">
                        ➕ Create System
                    </button>
                </div>
            <% else %>
                <div class="systems-grid">
                    <% @star_systems.each do |system| %>
                        <% 
                          bodies = system.celestial_bodies
                          stars = bodies.select { |b| b.body_category.to_s.include?('star') }
                          planets = bodies.select { |b| b.body_category.to_s.include?('planet') && !b.body_category.to_s.include?('dwarf') }
                          moons = bodies.select { |b| b.body_category.to_s.include?('moon') }
                          minor = bodies - stars - planets - moons
                        %>
                        
                        <div class="system-card" onclick="window.location.href='/admin/solar_systems/<%= system.id %>'">
                            <div class="system-header">
                                <div class="system-name"><%= system.name %></div>
                                <div class="system-identifier"><%= system.identifier || "SYS-#{system.id}" %></div>
                            </div>

                            <div class="system-stats">
                                <div class="system-stat">
                                    <span class="system-stat-value"><%= stars.count %></span>
                                    <span class="system-stat-label">Stars</span>
                                </div>
                                <div class="system-stat">
                                    <span class="system-stat-value"><%= planets.count %></span>
                                    <span class="system-stat-label">Planets</span>
                                </div>
                                <div class="system-stat">
                                    <span class="system-stat-value"><%= moons.count %></span>
                                    <span class="system-stat-label">Moons</span>
                                </div>
                                <div class="system-stat">
                                    <span class="system-stat-value"><%= minor.count %></span>
                                    <span class="system-stat-label">Minor</span>
                                </div>
                            </div>

                            <div class="system-preview">
                                <div class="system-preview-label">Key Bodies</div>
                                <div class="system-bodies-list">
                                    <% (stars + planets).take(6).each do |body| %>
                                        <span class="body-pill <%= body.body_category.to_s.include?('star') ? 'star' : 'planet' %>">
                                            <%= body.name %>
                                        </span>
                                    <% end %>
                                    <% if bodies.count > 6 %>
                                        <span class="body-pill">+<%= bodies.count - 6 %> more</span>
                                    <% end %>
                                </div>
                            </div>

                            <div class="system-actions" onclick="event.stopPropagation()">
                                <a href="<%= admin_solar_system_path(system) %>" class="system-action-btn primary">
                                    📊 View System
                                </a>
                                <a href="<%= admin_celestial_bodies_path(system_id: system.id) %>" class="system-action-btn">
                                    🌍 Browse Bodies
                                </a>
                            </div>
                        </div>
                    <% end %>
                </div>
            <% end %>

            <!-- Recent Activity (Condensed) -->
            <div style="margin-top: 30px;">
                <h3 style="color: #0ff; margin-bottom: 15px;">📜 RECENT ACTIVITY</h3>
                <div class="activity-feed-condensed">
                    <% if @recent_activity.any? %>
                        <% @recent_activity.each do |activity| %>
                            <div class="activity-feed-item">
                                <div class="activity-feed-time">
                                    <%= time_ago_in_words(activity.created_at) %> ago
                                </div>
                                <div class="activity-feed-message">
                                    <%= activity.message %>
                                </div>
                            </div>
                        <% end %>
                    <% else %>
                        <div style="text-align: center; padding: 20px; color: #666;">
                            No recent activity
                        </div>
                    <% end %>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Auto-refresh dashboard every 30 seconds
        setInterval(() => {
            fetch('/admin/dashboard')
                .then(response => response.text())
                .then(() => console.log('Dashboard data refreshed'))
                .catch(error => console.error('Refresh failed:', error));
        }, 30000);
    </script>
</body>
</html>
```

### Step 4: Add Breadcrumb Navigation Component

**Create:** `app/views/shared/_admin_breadcrumbs.html.erb`

```erb
<div class="breadcrumbs">
    <a href="/admin/dashboard" class="breadcrumb-item">
        🏠 Admin
    </a>
    <% if @galaxy %>
        <span class="breadcrumb-separator">→</span>
        <a href="/admin/galaxies/<%= @galaxy.id %>" class="breadcrumb-item">
            🌌 <%= @galaxy.name %>
        </a>
    <% end %>
    <% if @star_system %>
        <span class="breadcrumb-separator">→</span>
        <a href="/admin/solar_systems/<%= @star_system.id %>" class="breadcrumb-item">
            ☀️ <%= @star_system.name %>
        </a>
    <% end %>
    <% if @celestial_body %>
        <span class="breadcrumb-separator">→</span>
        <a href="/admin/celestial_bodies/<%= @celestial_body.id %>" class="breadcrumb-item">
            🌍 <%= @celestial_body.name %>
        </a>
    <% end %>
    <% if @current_view %>
        <span class="breadcrumb-separator">→</span>
        <span class="breadcrumb-current">
            <%= @current_view %>
        </span>
    <% end %>
</div>

<style>
.breadcrumbs {
    background: #0a0a0a;
    padding: 10px 15px;
    margin-bottom: 20px;
    border-left: 3px solid #0f0;
    font-size: 13px;
}

.breadcrumb-item {
    color: #0ff;
    text-decoration: none;
    transition: color 0.2s;
}

.breadcrumb-item:hover {
    color: #0f0;
}

.breadcrumb-separator {
    color: #666;
    margin: 0 8px;
}

.breadcrumb-current {
    color: #0f0;
    font-weight: bold;
}
</style>
```

## Success Criteria

- [ ] All inline CSS extracted to `admin/dashboard.css`
- [ ] Dashboard shows star systems as primary navigation (not flat body list)
- [ ] System cards show quick stats (stars, planets, moons counts)
- [ ] System cards preview key bodies
- [ ] Click system card → goes to `/admin/solar_systems/:id`
- [ ] Galaxy-wide statistics displayed
- [ ] System alerts shown (if any)
- [ ] Breadcrumbs component created (reusable)
- [ ] Recent activity condensed
- [ ] AI status condensed
- [ ] No duplicate CSS
- [ ] Clean ERB markup

## Time Estimate

- Extract CSS: 1 hour
- Update controller logic: 1.5 hours
- Create new dashboard view: 2 hours
- Breadcrumbs component: 30 minutes
- Testing: 1 hour
- Total: 6 hours

This creates a professional, hierarchical navigation structure that scales to hundreds of systems and thousands of bodies!
