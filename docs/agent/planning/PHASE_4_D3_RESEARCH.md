# Phase 4 D3.js Research: Resource Flow Visualization
**Date**: January 19, 2026
**Status**: Research & Prototyping Phase

## Overview
Research and prototyping for D3.js-based resource flow visualization in the SimEarth admin panel, showing GCC flow, material movement, and trade routes.

## D3.js Library Selection

### Core Libraries
- **D3.js v7**: Primary visualization library
- **d3-sankey**: Sankey diagram for resource flows
- **d3-force**: Force-directed graphs for complex networks
- **d3-zoom**: Pan/zoom controls for large networks
- **d3-tip**: Interactive tooltips

### Integration Approach
```javascript
// Rails asset pipeline integration
// app/assets/javascripts/admin/resource_flow.js
import * as d3 from 'd3';
import { sankey, sankeyLinkHorizontal } from 'd3-sankey';
```

## Visualization Types

### 1. Sankey Diagram (Primary)
**Use Case**: Resource flow between settlements
**Pros**: Clear flow visualization, quantitative representation
**Cons**: Fixed layout, less interactive for exploration

```javascript
const sankey = d3.sankey()
  .nodeWidth(15)
  .nodePadding(10)
  .extent([[10, 10], [width - 10, height - 10]]);

const {nodes, links} = sankey({
  nodes: sankeyData.nodes.map(d => Object.assign({}, d)),
  links: sankeyData.links.map(d => Object.assign({}, d))
});
```

### 2. Force-Directed Graph (Alternative)
**Use Case**: Complex trade networks with multiple routes
**Pros**: Interactive exploration, dynamic layout
**Cons**: Less quantitative, can be cluttered

```javascript
const simulation = d3.forceSimulation(nodes)
  .force('link', d3.forceLink(links).id(d => d.id).distance(100))
  .force('charge', d3.forceManyBody().strength(-300))
  .force('center', d3.forceCenter(width / 2, height / 2));
```

### 3. Chord Diagram (Specialized)
**Use Case**: Bilateral trade relationships
**Pros**: Shows reciprocity, compact representation
**Cons**: Limited to pairwise relationships

## Data Structure Design

### Node Types
```javascript
const nodeTypes = {
  source: { color: '#4CAF50', shape: 'circle' },      // Earth, raw material sources
  settlement: { color: '#2196F3', shape: 'square' },  // Colonies, stations
  factory: { color: '#FF9800', shape: 'diamond' },    // Manufacturing facilities
  consumer: { color: '#9C27B0', shape: 'triangle' }   // End consumers
};
```

### Link Properties
```javascript
const linkData = {
  source: 'earth',
  target: 'mars_colony',
  value: 15000,        // kg/month
  resource: 'H2O',     // material type
  gcc_value: 1200000,  // economic value
  route_efficiency: 0.94,
  transport_method: 'cyclers'
};
```

### Time Series Support
```javascript
// For animated transitions
const timeSeriesData = [
  { date: '2026-01', links: [...] },
  { date: '2026-02', links: [...] },
  // ...
];
```

## Interactive Features

### 1. Time Slider
```javascript
const timeSlider = d3.sliderHorizontal()
  .min(d3.min(dates))
  .max(d3.max(dates))
  .step(1)
  .width(400)
  .displayValue(true)
  .on('onchange', val => {
    updateVisualization(dates[val]);
  });
```

### 2. Resource Filtering
```javascript
const resourceFilter = d3.select('#resource-filter')
  .selectAll('option')
  .data(resourceTypes)
  .enter().append('option')
  .text(d => d)
  .property('selected', d => selectedResources.includes(d));
```

### 3. Node Details Panel
```javascript
// On node click
nodeGroup.on('click', function(event, d) {
  showNodeDetails(d);
  // Highlight connected links
  linkGroup.classed('highlighted', l => l.source === d || l.target === d);
});
```

### 4. Tooltip System
```javascript
const tooltip = d3.select('body').append('div')
  .attr('class', 'tooltip')
  .style('opacity', 0);

linkGroup.on('mouseover', function(event, d) {
  tooltip.transition().duration(200).style('opacity', 0.9);
  tooltip.html(`
    <strong>${d.source.name} → ${d.target.name}</strong><br/>
    Resource: ${d.resource}<br/>
    Volume: ${d3.format(',')(d.value)} kg/month<br/>
    GCC Value: ${d3.format('$,')(d.gcc_value)}
  `);
});
```

## Performance Considerations

### Data Aggregation
- Pre-aggregate data on server side
- Use time-bucketed data for large datasets
- Implement progressive loading for large networks

### Rendering Optimization
```javascript
// Use Canvas for large datasets
const canvas = d3.select('#viz').append('canvas')
  .attr('width', width)
  .attr('height', height);

const context = canvas.node().getContext('2d');
```

### Memory Management
- Clean up event listeners on component destruction
- Use object pooling for frequently created elements
- Implement virtual scrolling for large node lists

## Proof-of-Concept Implementation

### HTML Structure
```html
<div id="resource-flow-viz">
  <div class="controls">
    <div class="time-slider"></div>
    <div class="resource-filter"></div>
    <button class="export-btn">Export PNG</button>
  </div>
  <svg id="flow-diagram"></svg>
  <div class="node-details-panel"></div>
</div>
```

### JavaScript Architecture
```javascript
class ResourceFlowVisualizer {
  constructor(container, dataUrl) {
    this.container = container;
    this.dataUrl = dataUrl;
    this.init();
  }

  async init() {
    this.data = await this.loadData();
    this.setupControls();
    this.createVisualization();
  }

  // ... implementation methods
}
```

## Integration with Rails

### Asset Pipeline
```ruby
# app/assets/javascripts/admin/resource_flow.js
//= require d3
//= require d3-sankey
//= require admin/resource_flow_visualizer
```

### View Integration
```erb
<!-- app/views/admin/resources/flows.html.erb -->
<div id="resource-flow-container"
     data-solar-system-id="<%= @solar_system.id %>"
     data-api-url="<%= admin_resources_flows_path(@solar_system) %>">
</div>

<%= javascript_include_tag 'admin/resource_flow' %>
```

### Controller Data Preparation
```ruby
# app/controllers/admin/resources_controller.rb
def flows
  @solar_system = SolarSystem.find(params[:solar_system_id])

  # Aggregate trade data
  @flow_data = ResourceFlowService.new(@solar_system).aggregate_flows(
    start_date: params[:start_date],
    end_date: params[:end_date],
    resource_types: params[:resource_types]
  )

  respond_to do |format|
    format.json { render json: @flow_data }
    format.html
  end
end
```

## Testing Strategy

### Unit Tests
- Data transformation functions
- Visualization rendering logic
- User interaction handlers

### Integration Tests
- API data loading
- Real-time updates
- Export functionality

### Performance Tests
- Large dataset rendering (1000+ nodes)
- Animation smoothness
- Memory usage monitoring

## Next Steps

1. **Create Proof-of-Concept**: Build minimal working Sankey diagram
2. **Data Pipeline**: Implement server-side data aggregation
3. **Interactive Features**: Add time slider and filtering
4. **Performance Testing**: Validate with large datasets
5. **UI Integration**: Embed in admin panel layout</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/development/planning/PHASE_4_D3_RESEARCH.md