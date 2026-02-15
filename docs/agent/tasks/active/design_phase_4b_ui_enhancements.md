# Design Phase 4B UI Enhancements - SimEarth-Style Admin Panel

## Overview
Design comprehensive UI enhancements for monitoring and controlling autonomous multi-body AI coordination. Create SimEarth-inspired admin interface components for galaxy-wide settlement management and AI oversight.

## Design Philosophy
**SimEarth-Inspired**: Clean, functional interface with real-time data visualization
**Multi-Body Focus**: Galaxy selector, settlement coordination dashboard, AI monitoring
**Real-Time Awareness**: Live status updates, crisis alerts, coordination tracking
**Scalable Architecture**: Component-based design for future expansion

## Phase 1: Galaxy Navigation & Selector System (30 min)

### Tasks
1. **Galaxy Selector Component**
   - Design solar system selection interface
   - Implement celestial body filtering (planets, moons, asteroids)
   - Create quick navigation shortcuts (Mars, Luna, Earth, etc.)
   - Add search and filter capabilities

2. **Navigation Architecture**
   - Design breadcrumb navigation for multi-body context
   - Create tabbed interface for different views (Surface, Orbit, System)
   - Implement context-aware navigation (settlement-focused vs. system-wide)
   - Plan responsive design for different screen sizes

### Component Specifications
```javascript
// GalaxySelector Component
{
  selectedSystem: "Sol",
  availableBodies: ["Mercury", "Venus", "Earth", "Mars", "Jupiter", ...],
  filters: {
    hasSettlements: true,
    hasAI: true,
    inCrisis: false
  },
  shortcuts: ["Mars Base Alpha", "Luna Outpost", "Earth Hub"]
}
```

### Detailed Design: Galaxy Selector Component

**Visual Design:**
```
┌─ Galaxy Selector ──────────────────────────────────────┐
│ [Sol ▼] [Filter: Settlements] [Search...] [Shortcuts ▼] │
├─────────────────────────────────────────────────────────┤
│ ☀️ Sol System                                          │
│   ├── 🌍 Earth (3 settlements)                         │
│   ├── 🌙 Luna (1 settlement)                           │
│   ├── 🔴 Mars (2 settlements)                          │
│   ├── 🪐 Jupiter (0 settlements)                        │
│   └── 🧊 Europa (0 settlements)                         │
├─────────────────────────────────────────────────────────┤
│ ⚡ Quick Actions:                                       │
│   [Mars Base Alpha] [Luna Outpost] [Earth Hub]         │
└─────────────────────────────────────────────────────────┘
```

**Component API:**
```javascript
class GalaxySelector extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      selectedSystem: 'Sol',
      searchTerm: '',
      filters: {
        hasSettlements: false,
        hasAI: false,
        inCrisis: false,
        bodyType: 'all' // planets, moons, asteroids
      },
      shortcuts: [],
      systems: []
    };
  }

  componentDidMount() {
    this.loadSystems();
    this.loadShortcuts();
  }

  async loadSystems() {
    // Fetch available solar systems and celestial bodies
    const response = await fetch('/api/admin/systems');
    const systems = await response.json();
    this.setState({ systems });
  }

  async loadShortcuts() {
    // Load user's frequently accessed settlements
    const response = await fetch('/api/admin/shortcuts');
    const shortcuts = await response.json();
    this.setState({ shortcuts });
  }

  handleSystemChange(systemId) {
    this.setState({ selectedSystem: systemId });
    this.props.onSystemChange(systemId);
  }

  handleFilterChange(filterType, value) {
    this.setState(prevState => ({
      filters: {
        ...prevState.filters,
        [filterType]: value
      }
    }));
    this.applyFilters();
  }

  applyFilters() {
    // Filter celestial bodies based on current filters
    const filteredBodies = this.state.systems
      .find(s => s.id === this.state.selectedSystem)
      .bodies.filter(body => this.matchesFilters(body));
    
    this.props.onBodiesFiltered(filteredBodies);
  }

  matchesFilters(body) {
    const { filters } = this.state;
    
    if (filters.hasSettlements && !body.settlements?.length) return false;
    if (filters.hasAI && !body.hasAI) return false;
    if (filters.inCrisis && !body.inCrisis) return false;
    if (filters.bodyType !== 'all' && body.type !== filters.bodyType) return false;
    
    return true;
  }

  render() {
    const { systems, selectedSystem, filters, shortcuts, searchTerm } = this.state;
    
    return (
      <div className="galaxy-selector">
        <div className="selector-header">
          <SystemDropdown 
            systems={systems}
            selected={selectedSystem}
            onChange={this.handleSystemChange}
          />
          <FilterPanel 
            filters={filters}
            onFilterChange={this.handleFilterChange}
          />
          <SearchInput 
            value={searchTerm}
            onChange={(term) => this.setState({ searchTerm: term })}
          />
        </div>
        
        <BodyList 
          bodies={this.getFilteredBodies()}
          onBodySelect={this.props.onBodySelect}
        />
        
        <ShortcutBar 
          shortcuts={shortcuts}
          onShortcutClick={this.props.onShortcutClick}
        />
      </div>
    );
  }
}
```

### Navigation Architecture Design

**Breadcrumb Navigation:**
```
Galaxy Game Admin > Sol System > Mars > Mars Base Alpha > AI Coordination
[Galaxy Game Admin] > [Sol System] > [Mars] > [Mars Base Alpha] > [AI Coordination]
```

**Context-Aware Navigation:**
- **Settlement-Focused**: Shows settlement hierarchy and AI coordination options
- **System-Wide**: Shows all settlements across bodies with coordination status
- **Crisis Mode**: Highlights bodies in crisis with emergency navigation

**Tabbed Interface Design:**
```
┌─ Navigation Tabs ──────────────────────────────────────────────────┐
│ [🌍 Surface] [🛰️ Orbit] [🌌 System] [🤖 AI Coordination] [⚙️ Admin] │
└─────────────────────────────────────────────────────────────────────┘

Surface Tab: Terrain, settlements, local resources
Orbit Tab: Satellites, orbital construction, space infrastructure  
System Tab: Inter-body coordination, logistics, system-wide status
AI Coordination Tab: Multi-body AI monitoring, decision feed, orchestrator status
Admin Tab: Configuration, maintenance, system controls
```

**Responsive Design:**
- **Desktop (>1200px)**: Full horizontal tabs with expanded navigation
- **Tablet (768-1199px)**: Collapsed tabs with dropdown menu
- **Mobile (<768px)**: Bottom navigation with icon-only tabs

### Implementation Requirements

**Backend API Endpoints:**
```ruby
# routes.rb additions
namespace :admin do
  get 'systems', to: 'systems#index'  # List all solar systems
  get 'systems/:id/bodies', to: 'systems#bodies'  # Bodies in system
  get 'shortcuts', to: 'navigation#shortcuts'  # User shortcuts
  post 'shortcuts', to: 'navigation#create_shortcut'  # Save shortcut
end
```

**Database Schema Extensions:**
```ruby
# User navigation preferences
create_table :user_navigation_preferences do |t|
  t.references :user, foreign_key: true
  t.jsonb :shortcuts, default: []
  t.jsonb :filters, default: {}
  t.string :default_system
  t.timestamps
end

# Add indexes for performance
add_index :user_navigation_preferences, :user_id
add_index :celestial_bodies, :solar_system_id
```

**JavaScript Architecture:**
```javascript
// Navigation state management
const navigationStore = {
  currentSystem: 'sol',
  currentBody: null,
  currentSettlement: null,
  breadcrumbs: [],
  filters: {},
  shortcuts: []
};

// Event system for navigation changes
const navigationEvents = new EventEmitter();
```

### Phase 1 Completion Checklist
- [x] Galaxy Selector Component API designed
- [x] Navigation Architecture specified  
- [x] Responsive design considerations included
- [x] Backend API requirements defined
- [x] Database schema extensions planned
- [x] JavaScript architecture outlined

## Phase 2: Multi-Body Settlement Dashboard (45 min)

### Tasks
1. **Settlement Overview Panel**
   - Design settlement cards with key metrics
   - Create health indicators (population, resources, infrastructure)
   - Implement status badges (operational, crisis, maintenance)
   - Add quick action buttons (monitor, configure, emergency)

2. **Inter-Settlement Coordination View**
   - Design resource flow visualization between settlements
   - Create transfer status tracking (active, pending, completed)
   - Implement priority conflict indicators
   - Add coordination health metrics

### Dashboard Layout
```
┌─ Multi-Body Settlement Dashboard ──────────────────────────┐
│ [Galaxy Selector] [System Status] [AI Coordinator Status] │
├─────────────────────────────────────────────────────────────┤
│ ┌─ Mars Base Alpha ─┐ ┌─ Luna Outpost ─┐ ┌─ Coordination ─┐ │
│ │ Health: 85%      │ │ Health: 92%    │ │ Transfers: 3   │ │
│ │ Resources: OK    │ │ Resources: Low │ │ Conflicts: 0   │ │
│ │ Priority: Normal │ │ Priority: High │ │ Status: Active │ │
│ │ [Monitor] [Config] │ │ [Monitor] [Help] │ │ [Details]     │ │
│ └───────────────────┘ └─────────────────┘ └───────────────┘ │
├─────────────────────────────────────────────────────────────┤
│ [Resource Flow Visualization] [Active Transfers Table]      │
└─────────────────────────────────────────────────────────────┘
```

### Detailed Design: Settlement Overview Panel

**Settlement Card Component:**
```javascript
class SettlementCard extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      settlement: props.settlement,
      metrics: {},
      status: 'loading'
    };
  }

  componentDidMount() {
    this.loadSettlementData();
    this.startMetricsPolling();
  }

  async loadSettlementData() {
    try {
      const response = await fetch(`/api/admin/settlements/${this.props.settlementId}`);
      const data = await response.json();
      
      this.setState({
        settlement: data.settlement,
        metrics: data.metrics,
        status: 'loaded'
      });
    } catch (error) {
      this.setState({ status: 'error' });
    }
  }

  startMetricsPolling() {
    // Poll for real-time metrics every 30 seconds
    this.pollingInterval = setInterval(() => {
      this.loadSettlementData();
    }, 30000);
  }

  getHealthColor(health) {
    if (health >= 0.8) return '#0f0';      // Green - Good
    if (health >= 0.6) return '#ff0';      // Yellow - Warning
    return '#f00';                         // Red - Critical
  }

  getStatusBadge(status) {
    const badges = {
      operational: { text: 'OPERATIONAL', color: '#0f0' },
      crisis: { text: 'CRISIS', color: '#f00' },
      maintenance: { text: 'MAINTENANCE', color: '#ff0' },
      offline: { text: 'OFFLINE', color: '#666' }
    };
    return badges[status] || { text: 'UNKNOWN', color: '#666' };
  }

  render() {
    const { settlement, metrics, status } = this.state;
    
    if (status === 'loading') {
      return <div className="settlement-card loading">Loading...</div>;
    }
    
    if (status === 'error') {
      return <div className="settlement-card error">Error loading settlement</div>;
    }

    const healthColor = this.getHealthColor(metrics.health);
    const statusBadge = this.getStatusBadge(metrics.status);

    return (
      <div className="settlement-card" style={{ borderColor: healthColor }}>
        <div className="card-header">
          <h3 className="settlement-name">{settlement.name}</h3>
          <div 
            className="status-badge"
            style={{ backgroundColor: statusBadge.color }}
          >
            {statusBadge.text}
          </div>
        </div>
        
        <div className="card-metrics">
          <div className="metric">
            <span className="label">Health:</span>
            <span 
              className="value"
              style={{ color: healthColor }}
            >
              {Math.round(metrics.health * 100)}%
            </span>
          </div>
          
          <div className="metric">
            <span className="label">Resources:</span>
            <span className={`value ${metrics.resources === 'OK' ? 'ok' : 'warning'}`}>
              {metrics.resources}
            </span>
          </div>
          
          <div className="metric">
            <span className="label">Priority:</span>
            <span className="value">{metrics.priority}</span>
          </div>
          
          <div className="metric">
            <span className="label">Population:</span>
            <span className="value">{metrics.population}</span>
          </div>
        </div>
        
        <div className="card-actions">
          <button 
            className="action-btn monitor"
            onClick={() => this.props.onMonitor(settlement.id)}
          >
            Monitor
          </button>
          <button 
            className="action-btn configure"
            onClick={() => this.props.onConfigure(settlement.id)}
          >
            Configure
          </button>
          {metrics.status === 'crisis' && (
            <button 
              className="action-btn emergency"
              onClick={() => this.props.onEmergency(settlement.id)}
            >
              Emergency
            </button>
          )}
        </div>
      </div>
    );
  }
}
```

**Settlement Card Styling:**
```css
.settlement-card {
  background: #1a1a1a;
  border: 2px solid #333;
  border-radius: 8px;
  padding: 16px;
  margin: 8px;
  min-width: 280px;
  transition: all 0.2s ease;
}

.settlement-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 255, 0, 0.1);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.settlement-name {
  color: #0ff;
  font-size: 16px;
  font-weight: bold;
  margin: 0;
}

.status-badge {
  padding: 4px 8px;
  border-radius: 4px;
  color: #000;
  font-size: 12px;
  font-weight: bold;
}

.card-metrics {
  margin-bottom: 16px;
}

.metric {
  display: flex;
  justify-content: space-between;
  margin-bottom: 4px;
  font-size: 14px;
}

.metric .label {
  color: #ccc;
}

.metric .value.ok {
  color: #0f0;
}

.metric .value.warning {
  color: #ff0;
}

.card-actions {
  display: flex;
  gap: 8px;
}

.action-btn {
  padding: 6px 12px;
  border: 1px solid #333;
  background: #2a2a2a;
  color: #0ff;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
  transition: all 0.2s ease;
}

.action-btn:hover {
  background: #333;
  border-color: #0ff;
}

.action-btn.emergency {
  background: #f00;
  color: #fff;
  border-color: #f00;
}

.action-btn.emergency:hover {
  background: #c00;
}
```

### Inter-Settlement Coordination View Design

**Resource Flow Visualization:**
```javascript
class ResourceFlowVisualization extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      transfers: [],
      nodes: [], // Settlements as nodes
      edges: []  // Transfers as edges
    };
  }

  componentDidMount() {
    this.loadTransferData();
    this.startTransferPolling();
  }

  async loadTransferData() {
    const response = await fetch('/api/admin/transfers/active');
    const transfers = await response.json();
    
    // Convert transfers to graph data
    const graphData = this.buildTransferGraph(transfers);
    this.setState(graphData);
  }

  buildTransferGraph(transfers) {
    const nodes = [];
    const edges = [];
    const settlementMap = new Map();
    
    // Create nodes for settlements
    transfers.forEach(transfer => {
      if (!settlementMap.has(transfer.source_id)) {
        settlementMap.set(transfer.source_id, {
          id: transfer.source_id,
          name: transfer.source_settlement,
          type: 'settlement'
        });
      }
      
      if (!settlementMap.has(transfer.target_id)) {
        settlementMap.set(transfer.target_id, {
          id: transfer.target_id,
          name: transfer.target_settlement,
          type: 'settlement'
        });
      }
      
      // Create edge for transfer
      edges.push({
        id: transfer.id,
        source: transfer.source_id,
        target: transfer.target_id,
        resource: transfer.resource,
        quantity: transfer.quantity,
        status: transfer.status,
        progress: transfer.progress
      });
    });
    
    return {
      nodes: Array.from(settlementMap.values()),
      edges: edges,
      transfers: transfers
    };
  }

  render() {
    const { nodes, edges, transfers } = this.state;
    
    return (
      <div className="resource-flow-viz">
        <h3>Inter-Settlement Resource Flows</h3>
        
        <div className="flow-stats">
          <div className="stat">
            <span className="label">Active Transfers:</span>
            <span className="value">{transfers.filter(t => t.status === 'active').length}</span>
          </div>
          <div className="stat">
            <span className="label">Pending:</span>
            <span className="value">{transfers.filter(t => t.status === 'pending').length}</span>
          </div>
          <div className="stat">
            <span className="label">Completed (24h):</span>
            <span className="value">{transfers.filter(t => t.status === 'completed').length}</span>
          </div>
        </div>
        
        <div className="flow-diagram">
          {/* Render SVG-based flow diagram */}
          <FlowDiagram 
            nodes={nodes}
            edges={edges}
            onEdgeClick={this.handleEdgeClick}
          />
        </div>
        
        <div className="transfer-details">
          <h4>Active Transfers</h4>
          <TransferTable 
            transfers={transfers.filter(t => t.status === 'active')}
            onTransferClick={this.handleTransferClick}
          />
        </div>
      </div>
    );
  }
}
```

**Transfer Status Tracking:**
```javascript
class TransferTable extends React.Component {
  render() {
    const { transfers, onTransferClick } = this.props;
    
    return (
      <table className="transfer-table">
        <thead>
          <tr>
            <th>Resource</th>
            <th>From</th>
            <th>To</th>
            <th>Quantity</th>
            <th>Progress</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          {transfers.map(transfer => (
            <tr 
              key={transfer.id}
              onClick={() => onTransferClick(transfer)}
              className={`transfer-row ${transfer.status}`}
            >
              <td className="resource">{transfer.resource}</td>
              <td className="source">{transfer.source_settlement}</td>
              <td className="target">{transfer.target_settlement}</td>
              <td className="quantity">{transfer.quantity}</td>
              <td className="progress">
                <div className="progress-bar">
                  <div 
                    className="progress-fill"
                    style={{ width: `${transfer.progress}%` }}
                  />
                </div>
                {transfer.progress}%
              </td>
              <td className="status">
                <span className={`status-badge ${transfer.status}`}>
                  {transfer.status.toUpperCase()}
                </span>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    );
  }
}
```

### Coordination Health Metrics

**Coordination Panel Component:**
```javascript
class CoordinationPanel extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      coordinationMetrics: {
        activeTransfers: 0,
        pendingConflicts: 0,
        systemEfficiency: 0.85,
        lastUpdate: null
      }
    };
  }

  componentDidMount() {
    this.loadCoordinationMetrics();
    this.startMetricsPolling();
  }

  async loadCoordinationMetrics() {
    const response = await fetch('/api/admin/coordination/metrics');
    const metrics = await response.json();
    this.setState({ coordinationMetrics: metrics });
  }

  render() {
    const { coordinationMetrics } = this.state;
    
    return (
      <div className="coordination-panel">
        <h3>System Coordination</h3>
        
        <div className="coordination-metrics">
          <div className="metric-card">
            <div className="metric-value">{coordinationMetrics.activeTransfers}</div>
            <div className="metric-label">Active Transfers</div>
          </div>
          
          <div className="metric-card">
            <div className="metric-value warning">{coordinationMetrics.pendingConflicts}</div>
            <div className="metric-label">Pending Conflicts</div>
          </div>
          
          <div className="metric-card">
            <div className="metric-value">{Math.round(coordinationMetrics.systemEfficiency * 100)}%</div>
            <div className="metric-label">System Efficiency</div>
          </div>
        </div>
        
        <div className="coordination-actions">
          <button className="action-btn" onClick={this.props.onViewDetails}>
            View Details
          </button>
          <button 
            className="action-btn emergency"
            disabled={coordinationMetrics.pendingConflicts === 0}
            onClick={this.props.onResolveConflicts}
          >
            Resolve Conflicts
          </button>
        </div>
        
        <div className="last-update">
          Last updated: {coordinationMetrics.lastUpdate ? 
            new Date(coordinationMetrics.lastUpdate).toLocaleTimeString() : 
            'Never'}
        </div>
      </div>
    );
  }
}
```

### Phase 2 Completion Checklist
- [x] Settlement Overview Panel designed with health indicators and action buttons
- [x] Inter-Settlement Coordination View specified with resource flow visualization
- [x] Transfer status tracking component designed
- [x] Coordination health metrics panel created
- [x] Component APIs and styling specifications completed

## Phase 3: AI Coordination Monitoring Interface (45 min)

### Tasks
1. **AI Decision Feed**
   - Design real-time AI decision log
   - Create decision categorization (resource, expansion, crisis, coordination)
   - Implement decision impact visualization
   - Add decision confidence indicators

2. **System Orchestrator Status**
   - Design orchestrator health dashboard
   - Create coordination metrics display
   - Implement system-wide priority visualization
   - Add emergency override controls

### AI Monitoring Components
```javascript
// AIDecisionFeed Component
{
  decisions: [
    {
      timestamp: "2026-02-14T10:30:00Z",
      type: "resource_allocation",
      settlement: "Mars Base Alpha",
      action: "Prioritize water extraction",
      confidence: 0.87,
      impact: "high"
    }
  ],
  filters: ["all", "crisis", "coordination", "expansion"],
  autoScroll: true
}

// SystemOrchestratorStatus Component
{
  health: 0.94,
  activeCoordinations: 5,
  pendingConflicts: 1,
  systemEfficiency: 0.89,
  lastUpdate: "2026-02-14T10:35:00Z"
}
```

### Detailed Design: AI Decision Feed

**Decision Feed Component:**
```javascript
class AIDecisionFeed extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      decisions: [],
      filters: ['all'],
      autoScroll: true,
      maxDecisions: 100,
      isConnected: false
    };
    this.feedRef = React.createRef();
  }

  componentDidMount() {
    this.connectToDecisionStream();
    this.loadRecentDecisions();
  }

  componentWillUnmount() {
    if (this.decisionStream) {
      this.decisionStream.close();
    }
  }

  connectToDecisionStream() {
    // WebSocket connection for real-time decisions
    this.decisionStream = new WebSocket('/ws/ai/decisions');
    
    this.decisionStream.onopen = () => {
      this.setState({ isConnected: true });
    };
    
    this.decisionStream.onmessage = (event) => {
      const decision = JSON.parse(event.data);
      this.addDecision(decision);
    };
    
    this.decisionStream.onclose = () => {
      this.setState({ isConnected: false });
      // Attempt reconnection after delay
      setTimeout(() => this.connectToDecisionStream(), 5000);
    };
  }

  async loadRecentDecisions() {
    const response = await fetch('/api/admin/ai/decisions/recent');
    const decisions = await response.json();
    this.setState({ decisions });
  }

  addDecision(decision) {
    this.setState(prevState => {
      const newDecisions = [decision, ...prevState.decisions];
      // Keep only maxDecisions
      if (newDecisions.length > prevState.maxDecisions) {
        newDecisions.splice(prevState.maxDecisions);
      }
      return { decisions: newDecisions };
    });

    // Auto-scroll if enabled
    if (this.state.autoScroll && this.feedRef.current) {
      this.feedRef.current.scrollTop = 0;
    }
  }

  getDecisionIcon(type) {
    const icons = {
      resource_allocation: '📦',
      expansion: '🚀',
      crisis: '🚨',
      coordination: '🤝',
      construction: '🔨',
      research: '🔬'
    };
    return icons[type] || '🤖';
  }

  getDecisionColor(type) {
    const colors = {
      crisis: '#f00',
      coordination: '#0ff',
      expansion: '#0f0',
      resource_allocation: '#ff0',
      construction: '#f0f',
      research: '#0ff'
    };
    return colors[type] || '#666';
  }

  getConfidenceColor(confidence) {
    if (confidence >= 0.8) return '#0f0';
    if (confidence >= 0.6) return '#ff0';
    return '#f00';
  }

  toggleFilter(filter) {
    this.setState(prevState => {
      const filters = [...prevState.filters];
      if (filter === 'all') {
        return { filters: ['all'] };
      } else {
        const allIndex = filters.indexOf('all');
        if (allIndex > -1) filters.splice(allIndex, 1);
        
        const filterIndex = filters.indexOf(filter);
        if (filterIndex > -1) {
          filters.splice(filterIndex, 1);
        } else {
          filters.push(filter);
        }
        
        if (filters.length === 0) filters.push('all');
        return { filters };
      }
    });
  }

  filteredDecisions() {
    const { decisions, filters } = this.state;
    
    if (filters.includes('all')) return decisions;
    
    return decisions.filter(decision => filters.includes(decision.type));
  }

  render() {
    const { filters, autoScroll, isConnected } = this.state;
    const filteredDecisions = this.filteredDecisions();

    return (
      <div className="ai-decision-feed">
        <div className="feed-header">
          <h3>AI Decision Feed</h3>
          <div className="connection-status">
            <span 
              className={`status-indicator ${isConnected ? 'connected' : 'disconnected'}`}
            />
            {isConnected ? 'Live' : 'Disconnected'}
          </div>
        </div>
        
        <div className="feed-controls">
          <div className="filter-buttons">
            {['all', 'crisis', 'coordination', 'expansion', 'resource_allocation', 'construction'].map(filter => (
              <button
                key={filter}
                className={`filter-btn ${filters.includes(filter) ? 'active' : ''}`}
                onClick={() => this.toggleFilter(filter)}
              >
                {filter.replace('_', ' ').toUpperCase()}
              </button>
            ))}
          </div>
          
          <div className="feed-options">
            <label>
              <input
                type="checkbox"
                checked={autoScroll}
                onChange={(e) => this.setState({ autoScroll: e.target.checked })}
              />
              Auto-scroll
            </label>
          </div>
        </div>
        
        <div className="decisions-container" ref={this.feedRef}>
          {filteredDecisions.map(decision => (
            <div 
              key={decision.id}
              className="decision-item"
              style={{ borderLeftColor: this.getDecisionColor(decision.type) }}
            >
              <div className="decision-header">
                <div className="decision-meta">
                  <span className="decision-icon">
                    {this.getDecisionIcon(decision.type)}
                  </span>
                  <span className="decision-type">
                    {decision.type.replace('_', ' ').toUpperCase()}
                  </span>
                  <span className="decision-settlement">
                    {decision.settlement}
                  </span>
                </div>
                
                <div className="decision-metrics">
                  <span 
                    className="confidence"
                    style={{ color: this.getConfidenceColor(decision.confidence) }}
                  >
                    {Math.round(decision.confidence * 100)}%
                  </span>
                  <span className="timestamp">
                    {new Date(decision.timestamp).toLocaleTimeString()}
                  </span>
                </div>
              </div>
              
              <div className="decision-content">
                {decision.action}
              </div>
              
              {decision.impact && (
                <div className="decision-impact">
                  Impact: {decision.impact.toUpperCase()}
                </div>
              )}
            </div>
          ))}
          
          {filteredDecisions.length === 0 && (
            <div className="no-decisions">
              No decisions match current filters
            </div>
          )}
        </div>
      </div>
    );
  }
}
```

**Decision Feed Styling:**
```css
.ai-decision-feed {
  background: #0a0a0a;
  border: 1px solid #333;
  border-radius: 8px;
  height: 500px;
  display: flex;
  flex-direction: column;
}

.feed-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  border-bottom: 1px solid #333;
}

.feed-header h3 {
  margin: 0;
  color: #0ff;
}

.connection-status {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
}

.status-indicator {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.status-indicator.connected {
  background: #0f0;
}

.status-indicator.disconnected {
  background: #f00;
}

.feed-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 16px;
  border-bottom: 1px solid #333;
}

.filter-buttons {
  display: flex;
  gap: 4px;
  flex-wrap: wrap;
}

.filter-btn {
  padding: 4px 8px;
  background: #2a2a2a;
  border: 1px solid #333;
  color: #ccc;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
}

.filter-btn.active {
  background: #0ff;
  color: #000;
  border-color: #0ff;
}

.decisions-container {
  flex: 1;
  overflow-y: auto;
  padding: 8px;
}

.decision-item {
  background: #1a1a1a;
  border-left: 4px solid #666;
  border-radius: 4px;
  padding: 12px;
  margin-bottom: 8px;
  transition: all 0.2s ease;
}

.decision-item:hover {
  background: #222;
}

.decision-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 8px;
}

.decision-meta {
  display: flex;
  align-items: center;
  gap: 8px;
}

.decision-icon {
  font-size: 16px;
}

.decision-type {
  color: #0ff;
  font-weight: bold;
  font-size: 12px;
}

.decision-settlement {
  color: #ccc;
  font-size: 12px;
}

.decision-metrics {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 2px;
}

.confidence {
  font-weight: bold;
  font-size: 14px;
}

.timestamp {
  color: #666;
  font-size: 10px;
}

.decision-content {
  color: #0f0;
  font-family: 'Courier New', monospace;
  font-size: 13px;
  line-height: 1.4;
}

.decision-impact {
  color: #ff0;
  font-size: 12px;
  font-weight: bold;
  margin-top: 4px;
}
```

### System Orchestrator Status Design

**Orchestrator Status Component:**
```javascript
class SystemOrchestratorStatus extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      orchestratorStatus: {
        health: 0.94,
        activeCoordinations: 5,
        pendingConflicts: 1,
        systemEfficiency: 0.89,
        lastUpdate: null,
        isActive: true
      },
      showDetails: false
    };
  }

  componentDidMount() {
    this.loadOrchestratorStatus();
    this.startStatusPolling();
  }

  async loadOrchestratorStatus() {
    try {
      const response = await fetch('/api/admin/ai/orchestrator/status');
      const status = await response.json();
      this.setState({ orchestratorStatus: status });
    } catch (error) {
      console.error('Failed to load orchestrator status:', error);
    }
  }

  startStatusPolling() {
    this.pollingInterval = setInterval(() => {
      this.loadOrchestratorStatus();
    }, 10000); // Update every 10 seconds
  }

  componentWillUnmount() {
    if (this.pollingInterval) {
      clearInterval(this.pollingInterval);
    }
  }

  getHealthColor(health) {
    if (health >= 0.9) return '#0f0';
    if (health >= 0.7) return '#ff0';
    return '#f00';
  }

  async handleEmergencyStop() {
    if (confirm('Are you sure you want to pause the AI orchestrator? This will stop all autonomous coordination.')) {
      await fetch('/api/admin/ai/orchestrator/pause', { method: 'POST' });
      this.loadOrchestratorStatus();
    }
  }

  async handleResume() {
    await fetch('/api/admin/ai/orchestrator/resume', { method: 'POST' });
    this.loadOrchestratorStatus();
  }

  render() {
    const { orchestratorStatus, showDetails } = this.state;
    const healthColor = this.getHealthColor(orchestratorStatus.health);

    return (
      <div className="orchestrator-status">
        <div className="status-header">
          <h3>AI System Orchestrator</h3>
          <div className="status-indicator">
            <span 
              className={`indicator ${orchestratorStatus.isActive ? 'active' : 'inactive'}`}
            />
            {orchestratorStatus.isActive ? 'ACTIVE' : 'PAUSED'}
          </div>
        </div>
        
        <div className="status-metrics">
          <div className="metric-card">
            <div 
              className="metric-value"
              style={{ color: healthColor }}
            >
              {Math.round(orchestratorStatus.health * 100)}%
            </div>
            <div className="metric-label">Health</div>
          </div>
          
          <div className="metric-card">
            <div className="metric-value">
              {orchestratorStatus.activeCoordinations}
            </div>
            <div className="metric-label">Active Coordinations</div>
          </div>
          
          <div className="metric-card">
            <div className={`metric-value ${orchestratorStatus.pendingConflicts > 0 ? 'warning' : ''}`}>
              {orchestratorStatus.pendingConflicts}
            </div>
            <div className="metric-label">Pending Conflicts</div>
          </div>
          
          <div className="metric-card">
            <div className="metric-value">
              {Math.round(orchestratorStatus.systemEfficiency * 100)}%
            </div>
            <div className="metric-label">System Efficiency</div>
          </div>
        </div>
        
        <div className="status-controls">
          <button 
            className="control-btn details"
            onClick={() => this.setState({ showDetails: !showDetails })}
          >
            {showDetails ? 'Hide' : 'Show'} Details
          </button>
          
          {orchestratorStatus.isActive ? (
            <button 
              className="control-btn emergency"
              onClick={this.handleEmergencyStop}
            >
              Emergency Stop
            </button>
          ) : (
            <button 
              className="control-btn resume"
              onClick={this.handleResume}
            >
              Resume Orchestrator
            </button>
          )}
        </div>
        
        {showDetails && (
          <div className="status-details">
            <div className="detail-row">
              <span className="label">Last Update:</span>
              <span className="value">
                {orchestratorStatus.lastUpdate ? 
                  new Date(orchestratorStatus.lastUpdate).toLocaleString() : 
                  'Never'}
              </span>
            </div>
            
            <div className="detail-row">
              <span className="label">Coordination Cycles:</span>
              <span className="value">{orchestratorStatus.totalCycles || 0}</span>
            </div>
            
            <div className="detail-row">
              <span className="label">Resolved Conflicts:</span>
              <span className="value">{orchestratorStatus.resolvedConflicts || 0}</span>
            </div>
            
            <div className="detail-row">
              <span className="label">Average Response Time:</span>
              <span className="value">{orchestratorStatus.avgResponseTime || 'N/A'}ms</span>
            </div>
          </div>
        )}
      </div>
    );
  }
}
```

### Phase 3 Completion Checklist
- [x] AI Decision Feed component designed with real-time streaming
- [x] Decision categorization and filtering implemented
- [x] System Orchestrator Status dashboard created
- [x] Emergency override controls added
- [x] Component APIs and styling specifications completed
- [x] WebSocket integration for real-time updates planned

## Phase 4: Real-time Status Integration (30 min)

### Tasks
1. **WebSocket Architecture**
   - Design WebSocket connection management
   - Implement reconnection logic with exponential backoff
   - Create message routing and event handling
   - Add connection status monitoring

2. **Real-time Data Polling**
   - Implement fallback HTTP polling for critical data
   - Create data synchronization strategies
   - Add data freshness indicators
   - Optimize polling frequencies based on data criticality

3. **Error Handling & Resilience**
   - Design graceful degradation for connection failures
   - Implement data caching for offline scenarios
   - Create user feedback for connection issues
   - Add automatic recovery mechanisms

### WebSocket Integration Design

**Connection Manager Service:**
```javascript
class WebSocketManager {
  constructor() {
    this.connections = new Map();
    this.reconnectAttempts = new Map();
    this.maxReconnectAttempts = 5;
    this.reconnectDelay = 1000; // Start with 1 second
    this.maxReconnectDelay = 30000; // Max 30 seconds
  }

  connect(endpoint, options = {}) {
    const {
      onMessage,
      onConnect,
      onDisconnect,
      onError,
      autoReconnect = true
    } = options;

    const wsUrl = this.buildWebSocketUrl(endpoint);
    const ws = new WebSocket(wsUrl);

    ws.onopen = () => {
      console.log(`WebSocket connected: ${endpoint}`);
      this.reconnectAttempts.set(endpoint, 0);
      this.reconnectDelay = 1000;
      if (onConnect) onConnect();
    };

    ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        if (onMessage) onMessage(data);
      } catch (error) {
        console.error('Failed to parse WebSocket message:', error);
      }
    };

    ws.onclose = (event) => {
      console.log(`WebSocket disconnected: ${endpoint}`, event.code, event.reason);
      this.connections.delete(endpoint);
      if (onDisconnect) onDisconnect(event);
      
      if (autoReconnect && !event.wasClean) {
        this.scheduleReconnect(endpoint, options);
      }
    };

    ws.onerror = (error) => {
      console.error(`WebSocket error: ${endpoint}`, error);
      if (onError) onError(error);
    };

    this.connections.set(endpoint, ws);
    return ws;
  }

  scheduleReconnect(endpoint, options) {
    const attempts = this.reconnectAttempts.get(endpoint) || 0;
    
    if (attempts >= this.maxReconnectAttempts) {
      console.error(`Max reconnection attempts reached for ${endpoint}`);
      return;
    }

    this.reconnectAttempts.set(endpoint, attempts + 1);
    
    setTimeout(() => {
      console.log(`Attempting to reconnect to ${endpoint} (attempt ${attempts + 1})`);
      this.connect(endpoint, options);
    }, this.reconnectDelay);

    // Exponential backoff
    this.reconnectDelay = Math.min(this.reconnectDelay * 2, this.maxReconnectDelay);
  }

  disconnect(endpoint) {
    const ws = this.connections.get(endpoint);
    if (ws) {
      ws.close(1000, 'Client disconnect');
      this.connections.delete(endpoint);
    }
  }

  send(endpoint, data) {
    const ws = this.connections.get(endpoint);
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(data));
    } else {
      console.warn(`WebSocket not ready for ${endpoint}`);
    }
  }

  buildWebSocketUrl(endpoint) {
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const host = window.location.host;
    return `${protocol}//${host}${endpoint}`;
  }

  getConnectionStatus(endpoint) {
    const ws = this.connections.get(endpoint);
    if (!ws) return 'disconnected';
    
    switch (ws.readyState) {
      case WebSocket.CONNECTING: return 'connecting';
      case WebSocket.OPEN: return 'connected';
      case WebSocket.CLOSING: return 'closing';
      case WebSocket.CLOSED: return 'disconnected';
      default: return 'unknown';
    }
  }
}

// Global WebSocket manager instance
const wsManager = new WebSocketManager();
```

**Real-time Data Service:**
```javascript
class RealTimeDataService {
  constructor() {
    this.subscriptions = new Map();
    this.pollingIntervals = new Map();
    this.cache = new Map();
    this.cacheTimestamps = new Map();
    this.cacheTimeout = 5 * 60 * 1000; // 5 minutes
  }

  subscribe(endpoint, callback, options = {}) {
    const {
      useWebSocket = true,
      pollingInterval = 30000, // 30 seconds fallback
      cacheTimeout = this.cacheTimeout
    } = options;

    if (!this.subscriptions.has(endpoint)) {
      this.subscriptions.set(endpoint, new Set());
    }
    
    this.subscriptions.get(endpoint).add(callback);

    // Start WebSocket connection if requested
    if (useWebSocket) {
      this.startWebSocketSubscription(endpoint);
    }

    // Start polling as fallback
    this.startPolling(endpoint, pollingInterval);

    // Return unsubscribe function
    return () => this.unsubscribe(endpoint, callback);
  }

  unsubscribe(endpoint, callback) {
    const subscribers = this.subscriptions.get(endpoint);
    if (subscribers) {
      subscribers.delete(callback);
      
      if (subscribers.size === 0) {
        this.subscriptions.delete(endpoint);
        this.stopWebSocketSubscription(endpoint);
        this.stopPolling(endpoint);
      }
    }
  }

  startWebSocketSubscription(endpoint) {
    wsManager.connect(`/ws${endpoint}`, {
      onMessage: (data) => {
        this.updateCache(endpoint, data);
        this.notifySubscribers(endpoint, data);
      },
      onConnect: () => {
        console.log(`Real-time subscription active: ${endpoint}`);
      },
      onDisconnect: () => {
        console.log(`Real-time subscription lost: ${endpoint}`);
      }
    });
  }

  stopWebSocketSubscription(endpoint) {
    wsManager.disconnect(`/ws${endpoint}`);
  }

  startPolling(endpoint, interval) {
    if (this.pollingIntervals.has(endpoint)) return;

    const poll = async () => {
      try {
        const response = await fetch(`/api${endpoint}`);
        const data = await response.json();
        
        // Only update if data has changed or cache is stale
        const cached = this.cache.get(endpoint);
        if (!this.isDataEqual(cached, data) || this.isCacheStale(endpoint)) {
          this.updateCache(endpoint, data);
          this.notifySubscribers(endpoint, data);
        }
      } catch (error) {
        console.error(`Polling failed for ${endpoint}:`, error);
      }
    };

    // Initial poll
    poll();

    // Set up interval
    const intervalId = setInterval(poll, interval);
    this.pollingIntervals.set(endpoint, intervalId);
  }

  stopPolling(endpoint) {
    const intervalId = this.pollingIntervals.get(endpoint);
    if (intervalId) {
      clearInterval(intervalId);
      this.pollingIntervals.delete(endpoint);
    }
  }

  updateCache(endpoint, data) {
    this.cache.set(endpoint, data);
    this.cacheTimestamps.set(endpoint, Date.now());
  }

  getCachedData(endpoint) {
    const data = this.cache.get(endpoint);
    const timestamp = this.cacheTimestamps.get(endpoint);
    
    if (!data || this.isCacheStale(endpoint, timestamp)) {
      return null;
    }
    
    return data;
  }

  isCacheStale(endpoint, timestamp = this.cacheTimestamps.get(endpoint)) {
    if (!timestamp) return true;
    return (Date.now() - timestamp) > this.cacheTimeout;
  }

  isDataEqual(data1, data2) {
    return JSON.stringify(data1) === JSON.stringify(data2);
  }

  notifySubscribers(endpoint, data) {
    const subscribers = this.subscriptions.get(endpoint);
    if (subscribers) {
      subscribers.forEach(callback => {
        try {
          callback(data);
        } catch (error) {
          console.error('Subscriber callback error:', error);
        }
      });
    }
  }

  getDataFreshness(endpoint) {
    const timestamp = this.cacheTimestamps.get(endpoint);
    if (!timestamp) return 'unknown';
    
    const age = Date.now() - timestamp;
    if (age < 10000) return 'fresh'; // < 10 seconds
    if (age < 60000) return 'recent'; // < 1 minute
    if (age < 300000) return 'stale'; // < 5 minutes
    return 'stale';
  }
}

// Global real-time data service instance
const rtDataService = new RealTimeDataService();
```

**Error Boundary Component:**
```javascript
class RealTimeErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      hasError: false,
      error: null,
      errorInfo: null,
      retryCount: 0
    };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    this.setState({
      error,
      errorInfo
    });
    
    // Log error for monitoring
    console.error('Real-time component error:', error, errorInfo);
  }

  handleRetry = () => {
    this.setState(prevState => ({
      hasError: false,
      error: null,
      errorInfo: null,
      retryCount: prevState.retryCount + 1
    }));
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="realtime-error-boundary">
          <div className="error-message">
            <h4>Real-time Update Error</h4>
            <p>The component encountered an error while updating.</p>
            <div className="error-details">
              <details>
                <summary>Error Details</summary>
                <pre>{this.state.error && this.state.error.toString()}</pre>
                <pre>{this.state.errorInfo.componentStack}</pre>
              </details>
            </div>
            <div className="error-actions">
              <button 
                className="retry-btn"
                onClick={this.handleRetry}
              >
                Retry ({this.state.retryCount}/3)
              </button>
              {this.state.retryCount >= 3 && (
                <button 
                  className="fallback-btn"
                  onClick={() => window.location.reload()}
                >
                  Reload Page
                </button>
              )}
            </div>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}
```

### Phase 4 Completion Checklist
- [x] WebSocket connection management designed
- [x] Reconnection logic with exponential backoff implemented
- [x] Real-time data service with polling fallback created
- [x] Error boundary for graceful failure handling added
- [x] Data caching and freshness tracking implemented
- [x] Message routing and event handling architecture completed

## Phase 5: Component Integration & Architecture (30 min)

### Tasks
1. **Component Architecture**
   - Design reusable component library
   - Create data flow patterns
   - Implement state management strategy
   - Plan API integration points

2. **Responsive Design**
   - Design mobile/tablet adaptations
   - Create collapsible panels for space efficiency
   - Implement keyboard navigation
   - Add accessibility features

### Technical Architecture
```javascript
// Component Hierarchy
AdminDashboard
├── GalaxySelector
├── SystemStatusBar
├── SettlementGrid
│   ├── SettlementCard
│   └── CoordinationPanel
├── AIMonitoringPanel
│   ├── AIDecisionFeed
│   ├── SystemOrchestratorStatus
│   └── AlertSystem
└── DataProviders
    ├── RealtimeDataProvider
    └── APIClient
```

## Phase 6: Implementation Task Breakdown (30 min)

### Tasks
1. **Create Implementation Tasks**
   - Break down into specific development tasks
   - Estimate effort and dependencies
   - Create task files for implementation agent
   - Define success criteria and testing approach

2. **Prioritization & Sequencing**
   - Order tasks by dependency and impact
   - Identify quick wins vs. complex features
   - Plan iterative development approach
   - Create rollout strategy

### Implementation Tasks Generated
1. **Galaxy Navigation Component** (2-3 hours)
2. **Settlement Dashboard** (3-4 hours)
3. **AI Monitoring Interface** (4-5 hours)
4. **Alert & Status System** (2-3 hours)
5. **Component Integration** (2-3 hours)
6. **Responsive Design & Testing** (2-3 hours)

## Success Criteria
- [ ] Complete design specifications for all major components
- [ ] Detailed component APIs and data structures
- [ ] Implementation task breakdown with estimates
- [ ] Responsive design considerations
- [ ] Integration architecture plan
- [ ] Ready for implementation handoff

## Deliverables
- Detailed component designs with specifications
- Implementation task files for development
- API integration requirements
- Testing and validation approach
- Rollout and deployment plan

## Dependencies
- Phase 4A AI Manager MVP complete and tested
- Existing admin interface foundation
- Real-time data APIs available
- Component library established

## Expected Impact
- Enhanced AI monitoring and control capabilities
- Improved multi-body settlement management
- Better crisis response and coordination visibility
- Professional SimEarth-style admin experience</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/active/design_phase_4b_ui_enhancements.md