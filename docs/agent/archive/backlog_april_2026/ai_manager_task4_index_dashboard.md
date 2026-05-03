# Task 4: Fix AI Manager Index Dashboard

**Priority:** MEDIUM  
**Estimated Time:** 45 minutes  
**Risk Level:** LOW (view changes only, controller already has real data)  
**Agent:** GPT-4.1 (Copilot)  
**Dependencies:** Task 1 (SCSS + layout) must be complete first  

---

## 🎯 Objective

The `index.html.erb` dashboard already has real data from the controller (`@system_status`, `@active_missions`, `@performance_metrics`, `@system_alerts`, `@quick_actions`). The only problems are:

1. Uses wrong stylesheet (`celestial_bodies`) instead of `ai_manager`
2. Uses old layout classes instead of Task 1 layout classes
3. Missing system alerts display
4. Missing Testing link in sidebar nav

This is purely a layout and styling update — no controller changes needed.

---

## 📁 Files to Modify

- `app/views/admin/ai_manager/index.html.erb` — layout + alerts section only

---

## 🛠️ Replace `index.html.erb`

Replace entire file with:

```erb
<div class="ai-manager-layout">

  <aside class="ai-manager-sidebar">
    <h3>🤖 AI Manager</h3>
    <%= link_to "📊 Dashboard",   admin_ai_manager_path,             class: "ai-manager-nav-link active" %>
    <%= link_to "🚀 Missions",    admin_ai_manager_missions_path,    class: "ai-manager-nav-link" %>
    <%= link_to "🧠 Decisions",   admin_ai_manager_decisions_path,   class: "ai-manager-nav-link" %>
    <%= link_to "📋 Planner",     admin_ai_manager_planner_path,     class: "ai-manager-nav-link" %>
    <%= link_to "🎯 Patterns",    admin_ai_manager_patterns_path,    class: "ai-manager-nav-link" %>
    <%= link_to "📈 Performance", admin_ai_manager_performance_path, class: "ai-manager-nav-link" %>
    <%= link_to "🧪 Testing",     "/admin/ai_manager/testing",       class: "ai-manager-nav-link" %>
    <h3>Admin</h3>
    <%= link_to "← Dashboard", admin_dashboard_path, class: "ai-manager-nav-link" %>
  </aside>

  <header class="ai-manager-header">
    <h1>🤖 AI MANAGER</h1>
    <div class="header-meta">
      Comprehensive AI system monitoring, mission control, and analytics |
      Last Activity:
      <span class="status-ok">
        <%= @system_status[:last_activity]&.strftime('%Y-%m-%d %H:%M') || 'No activity yet' %>
      </span>
    </div>
  </header>

  <main class="ai-manager-main">

    <%# ── System Alerts ── %>
    <% if @system_alerts.any? %>
      <% @system_alerts.each do |alert| %>
        <div class="ai-alert ai-alert--<%= alert[:type] %>">
          <%= alert[:message] %>
          <%= link_to alert[:action_text], alert[:action], class: "ai-btn ai-btn--secondary ai-btn--small", style: "margin-left: auto;" %>
        </div>
      <% end %>
    <% end %>

    <%# ── Mission Stats ── %>
    <div class="ai-metrics-grid">
      <div class="ai-metric-card">
        <div class="metric-label">Active Missions</div>
        <div class="metric-value"><%= @system_status[:active_missions] %></div>
        <div class="metric-trend neutral">in progress</div>
      </div>
      <div class="ai-metric-card">
        <div class="metric-label">Completed</div>
        <div class="metric-value"><%= @system_status[:completed_missions] %></div>
        <div class="metric-trend positive">missions</div>
      </div>
      <div class="ai-metric-card">
        <div class="metric-label">Failed / Stalled</div>
        <div class="metric-value"><%= @system_status[:failed_missions] %></div>
        <div class="metric-trend <%= @system_status[:failed_missions] > 0 ? 'negative' : 'neutral' %>">
          missions
        </div>
      </div>
      <div class="ai-metric-card">
        <div class="metric-label">Success Rate</div>
        <div class="metric-value"><%= @performance_metrics[:success_rate] %>%</div>
        <div class="metric-trend <%= @performance_metrics[:success_rate] >= 70 ? 'positive' : 'negative' %>">
          overall
        </div>
      </div>
    </div>

    <%# ── Quick Actions ── %>
    <div class="ai-card">
      <h2>🧠 Quick Actions</h2>
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem;">
        <% @quick_actions.each do |key, action| %>
          <div class="ai-card" style="margin-bottom: 0;">
            <h3 style="margin-top: 0; font-size: 1rem;"><%= action[:title] %></h3>
            <p style="color: #6aa0cc; font-size: 0.8rem; margin-bottom: 1rem;"><%= action[:description] %></p>
            <%= link_to "Open →", action[:path], class: "ai-btn ai-btn--primary ai-btn--small" %>
          </div>
        <% end %>
      </div>
    </div>

    <%# ── Recent Activity ── %>
    <div class="ai-card">
      <h2>📋 Recent Active Missions</h2>
      <% if @active_missions.any? %>
        <table class="ai-table">
          <thead>
            <tr>
              <th>Mission</th>
              <th>Settlement</th>
              <th>Progress</th>
              <th>Started</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <% @active_missions.each do |mission| %>
              <tr>
                <td><%= mission.identifier %></td>
                <td><%= mission.settlement&.name || '—' %></td>
                <td><%= mission.progress %>%</td>
                <td><%= mission.created_at.strftime('%Y-%m-%d %H:%M') %></td>
                <td>
                  <%= link_to "Details", admin_ai_manager_mission_path(mission), class: "ai-btn ai-btn--secondary ai-btn--small" %>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      <% else %>
        <div class="ai-placeholder">No active missions. Start a new mission via the Mission Planner.</div>
      <% end %>
    </div>

    <%# ── AI Services Status ── %>
    <div class="ai-card">
      <h2>⚙️ AI Services Status</h2>
      <div style="display: flex; gap: 1rem; flex-wrap: wrap;">
        <% @system_status[:ai_services_status].each do |service, status| %>
          <div>
            <span class="ai-badge ai-badge--<%= status == :operational ? 'success' : 'error' %>">
              <%= status.to_s.upcase %>
            </span>
            &nbsp;<span style="font-size: 0.875rem;"><%= service.to_s.humanize %></span>
          </div>
        <% end %>
      </div>
    </div>

  </main>
</div>
```

---

## ✅ Verification

1. Visit `http://localhost:3000/admin/ai_manager`
2. Confirm real mission counts in metric cards
3. Confirm system alerts appear if any failed/stalled missions exist
4. Confirm quick action cards link to correct pages
5. Confirm active missions table shows real data or empty state
6. Confirm AI Services Status shows real service health
7. Confirm no `stylesheet_link_tag 'admin/celestial_bodies'` in page source

---

## 🚫 Out of Scope
- Controller changes
- Adding new data to `@system_status`
- Charts or graphs
- Model changes
