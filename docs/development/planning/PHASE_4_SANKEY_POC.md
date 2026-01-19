# Phase 4: D3.js Sankey Diagram Proof-of-Concept
**Date**: January 19, 2026
**Status**: Implementation Plan (Ready after Phase 3 completion)

## Overview
Build a working D3.js Sankey diagram to visualize resource flows between celestial bodies, demonstrating the core visualization component for the SimEarth admin panel.

## What is a Sankey Diagram?

A Sankey diagram is a flow visualization that shows:
- **Nodes**: Entities (settlements, factories, sources)
- **Links**: Flows between nodes (resource movement)
- **Width**: Proportional to flow volume/magnitude

```
[Earth] ──────────────▶ [Mars Colony]
   │                           │
   │ (H2O: 15,000 kg/month)    │ (Structural Carbon: 8,000 kg/month)
   ▼                           ▼
[Venus Station] ◀───────────── [Mars Colony]
```

## Why Sankey for Resource Flows?

### Perfect for Economic Visualization
- **GCC Value Flows**: Link width shows economic value (not just volume)
- **Multi-hop Routes**: Earth → Mars → Venus supply chains
- **Efficiency Metrics**: Color coding for route efficiency
- **Time Animation**: Slider to show flow changes over time

### Admin Use Cases
- **Trade Analysis**: Which routes are most profitable?
- **Bottleneck Identification**: Where are resources getting stuck?
- **Optimization Opportunities**: Which flows could be more efficient?
- **Economic Health**: Visual representation of system-wide trade

## Proof-of-Concept Scope

### Minimal Working Example
**Goal**: Functional Sankey diagram with sample data
**Data Source**: Mock trade data (no database integration yet)
**Features**:
- Basic node/link rendering
- Hover tooltips
- Responsive layout
- Export to PNG

### Technical Stack
```javascript
// app/assets/javascripts/admin/sankey_poc.js
import * as d3 from 'd3';
import { sankey, sankeyLinkHorizontal } from 'd3-sankey';
```

## Implementation Steps

### Step 1: Create Sample Data Structure
```javascript
const sampleData = {
  nodes: [
    { id: 'earth', name: 'Earth', type: 'source' },
    { id: 'mars_colony', name: 'Mars Colony', type: 'settlement' },
    { id: 'venus_station', name: 'Venus L1 Station', type: 'station' },
    { id: 'titan_refinery', name: 'Titan Refinery', type: 'factory' }
  ],
  links: [
    {
      source: 'earth',
      target: 'mars_colony',
      value: 15000,           // kg/month
      resource: 'H2O',
      gcc_value: 1200000,     // economic value
      route_efficiency: 0.94
    },
    {
      source: 'mars_colony',
      target: 'venus_station',
      value: 8000,
      resource: 'structural_carbon',
      gcc_value: 450000,
      route_efficiency: 0.87
    }
  ]
};
```

### Step 2: Basic Sankey Layout
```javascript
// Create SVG container
const svg = d3.select('#sankey-container')
  .append('svg')
  .attr('width', width)
  .attr('height', height);

// Define Sankey generator
const sankey = d3.sankey()
  .nodeWidth(15)
  .nodePadding(10)
  .extent([[10, 10], [width - 10, height - 10]]);

// Process data
const { nodes, links } = sankey({
  nodes: sampleData.nodes.map(d => Object.assign({}, d)),
  links: sampleData.links.map(d => Object.assign({}, d))
});
```

### Step 3: Render Links (Flows)
```javascript
// Create link paths
const link = svg.append('g')
  .attr('class', 'links')
  .selectAll('path')
  .data(links)
  .enter().append('path')
  .attr('d', sankeyLinkHorizontal())
  .attr('stroke-width', d => Math.max(1, d.width))
  .attr('stroke', d => getLinkColor(d))
  .attr('fill', 'none')
  .attr('opacity', 0.7);

// Link color based on resource type
function getLinkColor(d) {
  const colors = {
    'H2O': '#2196F3',           // Blue for water
    'structural_carbon': '#4CAF50', // Green for carbon
    'O2': '#FF9800',           // Orange for oxygen
    'regolith': '#795548'      // Brown for regolith
  };
  return colors[d.resource] || '#9E9E9E';
}
```

### Step 4: Render Nodes (Entities)
```javascript
// Create node rectangles
const node = svg.append('g')
  .attr('class', 'nodes')
  .selectAll('rect')
  .data(nodes)
  .enter().append('rect')
  .attr('x', d => d.x0)
  .attr('y', d => d.y0)
  .attr('height', d => d.y1 - d.y0)
  .attr('width', d => d.x1 - d.x0)
  .attr('fill', d => getNodeColor(d))
  .attr('stroke', '#000');

// Node color based on type
function getNodeColor(d) {
  const colors = {
    'source': '#4CAF50',       // Green for sources
    'settlement': '#2196F3',   // Blue for settlements
    'station': '#FF9800',      // Orange for stations
    'factory': '#9C27B0'       // Purple for factories
  };
  return colors[d.type] || '#9E9E9E';
}
```

### Step 5: Add Labels
```javascript
// Add node labels
svg.append('g')
  .attr('class', 'node-labels')
  .selectAll('text')
  .data(nodes)
  .enter().append('text')
  .attr('x', d => d.x0 < width / 2 ? d.x1 + 6 : d.x0 - 6)
  .attr('y', d => (d.y1 + d.y0) / 2)
  .attr('dy', '0.35em')
  .attr('text-anchor', d => d.x0 < width / 2 ? 'start' : 'end')
  .text(d => d.name);
```

### Step 6: Interactive Tooltips
```javascript
// Add tooltip
const tooltip = d3.select('body').append('div')
  .attr('class', 'sankey-tooltip')
  .style('opacity', 0);

// Link hover effects
link.on('mouseover', function(event, d) {
  tooltip.transition().duration(200).style('opacity', 0.9);
  tooltip.html(`
    <strong>${d.source.name} → ${d.target.name}</strong><br/>
    Resource: ${d.resource}<br/>
    Volume: ${d3.format(',')(d.value)} kg/month<br/>
    GCC Value: ${d3.format('$,')(d.gcc_value)}<br/>
    Efficiency: ${(d.route_efficiency * 100).toFixed(1)}%
  `);
})
.on('mouseout', function() {
  tooltip.transition().duration(500).style('opacity', 0);
});
```

### Step 7: Export Functionality
```javascript
// Add export button
d3.select('#export-btn').on('click', function() {
  // Convert SVG to PNG
  const svgElement = document.querySelector('#sankey-container svg');
  const serializer = new XMLSerializer();
  const svgString = serializer.serializeToString(svgElement);

  // Use canvas to convert to PNG
  const canvas = document.createElement('canvas');
  const ctx = canvas.getContext('2d');
  const img = new Image();

  img.onload = function() {
    canvas.width = img.width;
    canvas.height = img.height;
    ctx.drawImage(img, 0, 0);
    const link = document.createElement('a');
    link.download = 'resource_flows.png';
    link.href = canvas.toDataURL();
    link.click();
  };

  img.src = 'data:image/svg+xml;base64,' + btoa(svgString);
});
```

## Rails Integration

### View Template
```erb
<!-- app/views/admin/resources/sankey_poc.html.erb -->
<div class="sankey-container">
  <h2>Resource Flow Visualization (Proof-of-Concept)</h2>

  <div class="controls">
    <button id="export-btn">Export PNG</button>
  </div>

  <div id="sankey-container"></div>
</div>

<%= javascript_include_tag 'admin/sankey_poc' %>
```

### Route
```ruby
# config/routes.rb
namespace :admin do
  resources :resources do
    get :sankey_poc, on: :collection
  end
end
```

### Controller Action
```ruby
# app/controllers/admin/resources_controller.rb
def sankey_poc
  # Proof-of-concept - no data loading yet
end
```

## CSS Styling
```css
/* app/assets/stylesheets/admin/sankey.css */
.sankey-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

#sankey-container svg {
  width: 100%;
  height: 600px;
  border: 1px solid #ddd;
}

.sankey-tooltip {
  position: absolute;
  background: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 8px 12px;
  border-radius: 4px;
  font-size: 12px;
  pointer-events: none;
  z-index: 1000;
}
```

## Success Criteria

### ✅ Functional Requirements
- [ ] Sankey diagram renders with sample data
- [ ] Links show proportional width to flow values
- [ ] Nodes are colored by type
- [ ] Hover tooltips display flow details
- [ ] Export to PNG works

### ✅ Technical Requirements
- [ ] No JavaScript errors in browser console
- [ ] Responsive layout (works on different screen sizes)
- [ ] Clean, readable code with comments
- [ ] Follows D3.js best practices

### ✅ Performance Requirements
- [ ] Initial render < 500ms
- [ ] Smooth hover interactions
- [ ] Memory efficient (no leaks)

## Next Steps After Proof-of-Concept

### Phase 4-A: Real Data Integration
- Connect to actual trade/supply chain data
- Implement time series filtering
- Add real-time updates

### Phase 4-B: Advanced Features
- Force-directed layout option
- Interactive node details
- Route optimization suggestions
- Multi-resource type filtering

### Phase 4-C: Production Polish
- Loading states
- Error handling
- Accessibility features
- Mobile responsiveness

## Why This Proof-of-Concept Matters

1. **Risk Reduction**: Validates D3.js approach before full implementation
2. **Team Alignment**: Demonstrates visual design to stakeholders
3. **Technical Foundation**: Establishes patterns for future visualizations
4. **User Feedback**: Early validation of interaction design
5. **Iterative Development**: Foundation for incremental feature additions

The proof-of-concept transforms abstract planning into concrete visual results, proving the feasibility of D3.js resource flow visualization for the SimEarth admin panel.</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/development/planning/PHASE_4_SANKEY_POC.md