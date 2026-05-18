# 2026-04-24-HIGH-TEST-MANAGER TASK2 PERFORMANCE DATA

**Agent:** GPT-4.1 (0.25x)
**Priority:** HIGH
**Type:** TEST
**Status:** BACKLOG

## Context
Migrated from backlog_april_2026 archive.

## Summary
# Task 2: Wire AI Manager Performance Page to Real Data

**Priority:** HIGH  
**Estimated Time:** 1 hour  
**Risk Level:** LOW (view + controller only, no model changes)

---

## Original Content

# Task 2: Wire AI Manager Performance Page to Real Data

**Priority:** HIGH  
**Estimated Time:** 1 hour  
**Risk Level:** LOW (view + controller only, no model changes)  
**Agent:** GPT-4.1 (Copilot)  
**Dependencies:** Task 1 (SCSS + layout) must be complete first  

---

## 🎯 Objective

Replace all hardcoded placeholder data in `performance.html.erb` with real data from the database. Update the controller `performance` action to pass real mission data. Remove non-functional UI controls.

---

## 📁 Files to Modify

- `app/controllers/admin/ai_manager_controller.rb` — update `performance` action
- `app/views/admin/ai_manager/performance.html.erb` — replace hardcoded content

---

## 🛠️ Step 1: Update Controller `performance` Action

In `app/controllers/admin/ai_manager_controller.rb` find the `performance` action:

```ruby
def performance
  # TODO: Load AI performance metrics
  @metrics = {
    success_rate: 0,
    average_timeline: 0,
    resource_efficiency: 0
  }
end
```

Replace it with:

```ruby
def performance
  total_missions = Mission.count
  completed = Mission.where(status: :completed).count
  failed = Mission.where(status: [:failed, :stalled]).count
  active = Mission.where(status: :in_progress).count

  success_rate = total_missions > 0 ? (completed.to_f / total_missions * 100).round(1) : 0
  avg_timeline = Mission.where(status: :completed)
                        .average('EXTRACT(EPOCH FROM (updated_at - created_at))/86400')
                        &.round(1) || 0
  resource_efficiency = [success_rate * 0.8, 100].min.round(1)

  @metrics = {
    success_rate: success_rate,
    average_timeline: avg_timeline,
    resource_efficiency: resource_efficiency,
    active_missions: active,
    completed_missions: completed,
    failed_missions: failed,
    total_missions: total_missions
  }

  @recent_missions = Mission.includes(:settlement)
                            .order(updated_at: :desc)
                            .limit(10)

  @ai_services = check_ai_services_status
end
```

---

## 🛠️ Step 2: Replace `performance.html.erb` Content

Replace the entire file content with the following. This uses the Task 1 layout classes (`ai-manager-layout`, `ai-manager-sidebar`, etc.):

```erb
<div class="ai-manager-layout">

  <aside class="ai-manager-sidebar">
    <h3>🤖 AI Manager</h3>
    <%= link_to "📊 Dashboard",   admin_ai_manager_path,             class: "ai-manager-nav-link" %>
    <%= link_to "🚀 Missions",    admin_ai_manager_missions_path,    class: "ai-manager-nav-link" %>
    <%= link_to "🧠 Decisions",   admin_ai_manager_decisions_path,   class: "ai-manager-nav-link" %>
    <%= link_to "📋 Planner",     admin_ai_manager_planner_path,     class: "ai-manager-nav-link" %>
    <%= link_to "🎯 Patterns",    admin_ai_manager_patterns_path,    class: "ai-manager-nav-link" %>
    <%= link_to "📈 Performance", admin_ai_manager_performance_path, class: "ai-manager-nav-link active" %>
    <%= link_to "🧪 Testing",     "/admin/ai_manager/testing",       class: "ai-manager-nav-link" %>
    <h3>Admin</h3>
    <%= link_to "← Dashboard", admin_dashboard_path, class: "ai-manager-nav-link" %>
  </aside>

  <header class="ai-manager-header">
    <h1>AI MANAGER — PERFORMANCE</h1>
    <div class="header-meta">
      System: <span class="status-ok">OPERATIONAL</span> |
      Total Missions: <span class="status-ok"><%= @metrics[:total_missions] %></span>
    </div>
  </header>

  <main class="ai-manager-main">

    <%# ── Metrics ── %>
    <div class="ai-metrics-grid">
      <div class="ai-metric-card">
        <div class="metric-label">Success Rate</div>
        <div class="metric-value"><%= @metrics[:success_rate] %>%</div>
        <div class="metric-trend <%= @metrics[:success_rate] >= 70 ? 'positive' : 'negative' %>">
          <%= @metrics[:completed_missions] %> completed
        </div>
      </div>
      <div class="ai-metric-card">
        <div class="metric-label">Avg Timeline</div>
        <div class="metric-value"><%= @metrics[:average_timeline] %></div>
        <div class="metric-trend neutral">days</div>
      </div>
      <div class="ai-metric-card">
        <div class="metric-label">Resource Efficiency</div>
        <div class="metric-value"><%= @metrics[:resource_efficiency] %>%</div>
        <div class="metric-trend <%= @metrics[:resource_efficiency] >= 70 ? 'positive' : 'negative' %>">
          estimated
        </div>
      </div>
      <div class="ai-metric-card">
        <div class="metric-label">Active Missions</div>
        <div class="metric-value"><%= @metrics[:active_missions] %></div>
        <div class="metric-trend neutral"><%= @metrics[:failed_missions] %> failed/stalled</div>
      </div>
    </div>

    <%# ── Recent Missions ── %>
    <div class="ai-card">
      <h2>🚀 Recent Mission Activity</h2>
      <% if @recent_missions.any? %>
        <table class="ai-table">
          <thead>
            <tr>
              <th>Mission</th>
              <th>Settlement</th>
              <th>Status</th>
              <th>Progress</th>
              <th>Last Updated</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <% @recent_missions.each do |mission| %>
              <tr>
                <td><%= mission.identifier %></td>
                <td><%= mission.settlement&.name || '—' %></td>
                <td>
                  <% badge_class = case mission.status.to_sym
                     when :completed then 'success'
                     when :in_progress then 'info'
                     when :failed, :stalled then 'error'
                     else 'neutral'
                     end %>
                  <span class="ai-badge ai-badge--<%= badge_class %>">
                    <%= mission.status.humanize %>
                  </span>
                </td>
                <td><%= mission.progress %>%</td>
                <td><%= mission.updated_at.strftime('%Y-%m-%d %H:%M') %></td>
                <td>
                  <%= link_to "Details", admin_ai_manager_mission_path(mission), class: "ai-btn ai-btn--secondary ai-btn--small" %>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      <% else %>
        <div class="ai-placeholder">No missions recorded yet.</div>
      <% end %>
    </div>

    <%# ── AI Services Health ── %>
    <div class="ai-card">
      <h2>⚙️ AI Services Health</h2>
      <% @ai_services.each do |service, status| %>
        <div style="margin-bottom: 0.5rem;">
          <span class="ai-badge ai-badge--<%= status == :operational ? 'success' : 'error' %>">
            <%= status.to_s.upcase %>
          </span>
          &nbsp;<strong><%= service.to_s.humanize %></strong>
        </div>
      <% end %>
    </div>

  </main>
</div>
```

---

## ✅ Verification

1. Visit `http://localhost:3000/admin/ai_manager/performance`
2. Confirm metrics show real numbers (not 0% or --)
3. Confirm mission table shows real missions from the database
4. Confirm AI Services Health shows real service status
5. Confirm no hardcoded "Mars Colony Alpha" or "Venus Industrial Hub" text remains

---

## 🚫 Out of Scope
- Adding charts or graphs
- Changing controller private methods
- Modifying any model files

