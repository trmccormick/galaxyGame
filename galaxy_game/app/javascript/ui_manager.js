/**
 * UI Manager - Centralizes UI state and interactions
 */

class UIManager {
  constructor() {
    this.selectedPlanet = null;
    this.viewMode = 'system'; // 'system' or 'planet'
    this.showLabels = true;
    this.showOrbits = true;
    this.showMoons = true;
    this.eventLog = [];
    this.maxLogEntries = 50;
  }

  /**
   * Initialize UI manager and attach event listeners
   */
  initialize() {
    this.attachMenuListeners();
    this.attachTabListeners();
    this.initializeTooltips();
    console.log('UI Manager initialized');
  }

  /**
   * Attach menu dropdown listeners
   */
  attachMenuListeners() {
    // View menu options
    document.getElementById('toggle-labels')?.addEventListener('click', (e) => {
      e.preventDefault();
      this.showLabels = !this.showLabels;
      this.logEvent(`Labels ${this.showLabels ? 'enabled' : 'disabled'}`);
    });

    document.getElementById('toggle-orbits')?.addEventListener('click', (e) => {
      e.preventDefault();
      this.showOrbits = !this.showOrbits;
      this.logEvent(`Orbits ${this.showOrbits ? 'enabled' : 'disabled'}`);
    });

    document.getElementById('toggle-moons')?.addEventListener('click', (e) => {
      e.preventDefault();
      this.showMoons = !this.showMoons;
      this.logEvent(`Moons ${this.showMoons ? 'enabled' : 'disabled'}`);
    });
  }

  /**
   * Attach tab switching listeners
   */
  attachTabListeners() {
    const tabButtons = document.querySelectorAll('.tab-btn');
    tabButtons.forEach(btn => {
      btn.addEventListener('click', () => {
        const tabName = btn.dataset.tab;
        this.switchTab(tabName);
      });
    });
  }

  /**
   * Switch active tab
   */
  switchTab(tabName) {
    // Update button states
    document.querySelectorAll('.tab-btn').forEach(btn => {
      btn.classList.toggle('active', btn.dataset.tab === tabName);
    });

    // Update content visibility
    document.querySelectorAll('.tab-content').forEach(content => {
      content.classList.toggle('active', content.id === tabName);
    });

    // Load tab data if planet is selected
    if (this.selectedPlanet) {
      this.loadTabData(tabName, this.selectedPlanet);
    }
  }

  /**
   * Initialize tooltips for interactive elements
   */
  initializeTooltips() {
    // Simple tooltip system
    document.querySelectorAll('[data-tooltip]').forEach(element => {
      element.addEventListener('mouseenter', (e) => {
        this.showTooltip(e.target.dataset.tooltip, e.clientX, e.clientY);
      });
      element.addEventListener('mouseleave', () => {
        this.hideTooltip();
      });
    });
  }

  /**
   * Select a celestial body
   */
  selectPlanet(planetData) {
    this.selectedPlanet = planetData;
    this.updateDetailsPanel(planetData);
    this.logEvent(`Selected ${planetData.name}`);
  }

  /**
   * Update the details panel with planet information
   */
  updateDetailsPanel(planet) {
    const overviewData = document.getElementById('overview-data');
    if (!overviewData) return;

    overviewData.innerHTML = `
      <div class="planet-detail-card">
        <h4>${planet.name}</h4>
        <div class="detail-row">
          <span class="label">Type:</span>
          <span class="value">${planet.body_category || 'Unknown'}</span>
        </div>
        <div class="detail-row">
          <span class="label">Mass:</span>
          <span class="value">${this.formatMass(planet.mass)}</span>
        </div>
        <div class="detail-row">
          <span class="label">Radius:</span>
          <span class="value">${this.formatRadius(planet.radius)}</span>
        </div>
        <div class="detail-row">
          <span class="label">Surface Temp:</span>
          <span class="value">${this.formatTemperature(planet.surface_temperature)}</span>
        </div>
        <div class="detail-row">
          <span class="label">Orbital Period:</span>
          <span class="value">${this.formatDays(planet.orbital_period)}</span>
        </div>
        ${planet.atmosphere ? `
          <div class="detail-section">
            <h5>Atmosphere</h5>
            <div class="detail-row">
              <span class="label">Pressure:</span>
              <span class="value">${this.formatPressure(planet.atmosphere.surface_pressure)}</span>
            </div>
            <div class="detail-row">
              <span class="label">Composition:</span>
              <span class="value">${this.formatComposition(planet.atmosphere)}</span>
            </div>
          </div>
        ` : ''}
        ${this.renderTerraformingStatus(planet)}
      </div>
    `;
  }

  /**
   * Render terraforming status if applicable
   */
  renderTerraformingStatus(planet) {
    // Check if planet has active terraforming missions
    // This would be populated from backend data
    if (planet.terraforming_status) {
      const progress = planet.terraforming_status.progress || 0;
      return `
        <div class="terraforming-status">
          <h5>Terraforming Progress</h5>
          <div class="progress-bar">
            <div class="progress-fill" style="width: ${progress}%"></div>
          </div>
          <p class="progress-text">${progress.toFixed(1)}% Complete</p>
          <p class="status-text">${planet.terraforming_status.phase || 'Initializing'}</p>
        </div>
      `;
    }
    return '';
  }

  /**
   * Load data for a specific tab
   */
  loadTabData(tabName, planet) {
    const tabContent = document.getElementById(tabName);
    if (!tabContent) return;

    switch(tabName) {
      case 'atmosphere':
        this.loadAtmosphereData(tabContent, planet);
        break;
      case 'hydrosphere':
        this.loadHydrosphereData(tabContent, planet);
        break;
      case 'geosphere':
        this.loadGeosphereData(tabContent, planet);
        break;
    }
  }

  /**
   * Load atmosphere tab data
   */
  loadAtmosphereData(container, planet) {
    if (!planet.atmosphere) {
      container.innerHTML = '<p>No atmosphere data available</p>';
      return;
    }

    const atm = planet.atmosphere;
    container.innerHTML = `
      <h4>Atmospheric Composition</h4>
      <div class="composition-chart">
        ${this.renderCompositionBars(atm)}
      </div>
      <div class="detail-row">
        <span class="label">Surface Pressure:</span>
        <span class="value">${this.formatPressure(atm.surface_pressure)}</span>
      </div>
      <div class="detail-row">
        <span class="label">Scale Height:</span>
        <span class="value">${atm.scale_height ? atm.scale_height.toFixed(2) + ' km' : 'N/A'}</span>
      </div>
      <div class="detail-row">
        <span class="label">Mean Molecular Weight:</span>
        <span class="value">${atm.mean_molecular_weight ? atm.mean_molecular_weight.toFixed(2) + ' g/mol' : 'N/A'}</span>
      </div>
    `;
  }

  /**
   * Render composition bars
   */
  renderCompositionBars(atmosphere) {
    const gases = [
      { key: 'co2_percent', label: 'CO₂', color: '#e74c3c' },
      { key: 'n2_percent', label: 'N₂', color: '#3498db' },
      { key: 'o2_percent', label: 'O₂', color: '#2ecc71' },
      { key: 'h2o_percent', label: 'H₂O', color: '#1abc9c' },
      { key: 'ar_percent', label: 'Ar', color: '#95a5a6' },
      { key: 'ch4_percent', label: 'CH₄', color: '#f39c12' },
      { key: 'he_percent', label: 'He', color: '#9b59b6' }
    ];

    return gases
      .filter(gas => atmosphere[gas.key] && atmosphere[gas.key] > 0.01)
      .map(gas => {
        const percent = atmosphere[gas.key];
        return `
          <div class="composition-bar">
            <span class="gas-label">${gas.label}</span>
            <div class="bar-container">
              <div class="bar-fill" style="width: ${Math.min(percent, 100)}%; background-color: ${gas.color}"></div>
            </div>
            <span class="gas-percent">${percent.toFixed(2)}%</span>
          </div>
        `;
      })
      .join('');
  }

  /**
   * Load hydrosphere tab data
   */
  loadHydrosphereData(container, planet) {
    if (!planet.hydrosphere) {
      container.innerHTML = '<p>No hydrosphere data available</p>';
      return;
    }

    const hydro = planet.hydrosphere;
    container.innerHTML = `
      <h4>Water Distribution</h4>
      <div class="detail-row">
        <span class="label">Surface Water:</span>
        <span class="value">${hydro.surface_water_percent ? hydro.surface_water_percent.toFixed(2) + '%' : 'N/A'}</span>
      </div>
      <div class="detail-row">
        <span class="label">Ice Coverage:</span>
        <span class="value">${hydro.ice_coverage_percent ? hydro.ice_coverage_percent.toFixed(2) + '%' : 'N/A'}</span>
      </div>
      <div class="detail-row">
        <span class="label">Ocean Depth (avg):</span>
        <span class="value">${hydro.avg_ocean_depth_km ? hydro.avg_ocean_depth_km.toFixed(2) + ' km' : 'N/A'}</span>
      </div>
      <div class="detail-row">
        <span class="label">Salinity:</span>
        <span class="value">${hydro.salinity_percent ? hydro.salinity_percent.toFixed(2) + '%' : 'N/A'}</span>
      </div>
    `;
  }

  /**
   * Load geosphere tab data
   */
  loadGeosphereData(container, planet) {
    if (!planet.geosphere) {
      container.innerHTML = '<p>No geosphere data available</p>';
      return;
    }

    const geo = planet.geosphere;
    container.innerHTML = `
      <h4>Geological Activity</h4>
      <div class="detail-row">
        <span class="label">Tectonic Activity:</span>
        <span class="value">${geo.tectonic_activity || 'Unknown'}</span>
      </div>
      <div class="detail-row">
        <span class="label">Volcanic Activity:</span>
        <span class="value">${geo.volcanic_activity || 'Unknown'}</span>
      </div>
      <div class="detail-row">
        <span class="label">Core Type:</span>
        <span class="value">${geo.core_type || 'Unknown'}</span>
      </div>
      <div class="detail-row">
        <span class="label">Magnetic Field:</span>
        <span class="value">${geo.magnetic_field_strength ? geo.magnetic_field_strength + ' μT' : 'None'}</span>
      </div>
    `;
  }

  /**
   * Log an event to the notification feed
   */
  logEvent(message, type = 'info') {
    const timestamp = new Date().toLocaleTimeString();
    this.eventLog.unshift({ timestamp, message, type });
    
    // Limit log size
    if (this.eventLog.length > this.maxLogEntries) {
      this.eventLog.pop();
    }

    this.updateEventLog();
  }

  /**
   * Update the event log display
   */
  updateEventLog() {
    const feed = document.getElementById('notification-feed');
    if (!feed) return;

    feed.innerHTML = this.eventLog
      .slice(0, 10) // Show only last 10
      .map(event => `
        <div class="log-entry ${event.type}">
          <span class="log-time">${event.timestamp}</span>
          <span class="log-message">${event.message}</span>
        </div>
      `)
      .join('');
  }

  /**
   * Show tooltip
   */
  showTooltip(text, x, y) {
    let tooltip = document.getElementById('ui-tooltip');
    if (!tooltip) {
      tooltip = document.createElement('div');
      tooltip.id = 'ui-tooltip';
      tooltip.className = 'tooltip';
      document.body.appendChild(tooltip);
    }

    tooltip.textContent = text;
    tooltip.style.left = (x + 10) + 'px';
    tooltip.style.top = (y + 10) + 'px';
    tooltip.style.display = 'block';
  }

  /**
   * Hide tooltip
   */
  hideTooltip() {
    const tooltip = document.getElementById('ui-tooltip');
    if (tooltip) {
      tooltip.style.display = 'none';
    }
  }

  // Formatting helpers
  formatMass(mass) {
    if (!mass) return 'Unknown';
    const earthMasses = mass / 5.972e24;
    if (earthMasses < 0.01) {
      return `${(mass / 1e20).toFixed(2)}×10²⁰ kg`;
    }
    return `${earthMasses.toFixed(3)} M⊕`;
  }

  formatRadius(radius) {
    if (!radius) return 'Unknown';
    const earthRadii = radius / 6371;
    return `${radius.toFixed(0)} km (${earthRadii.toFixed(3)} R⊕)`;
  }

  formatTemperature(temp) {
    if (!temp) return 'Unknown';
    return `${temp.toFixed(1)} K (${(temp - 273.15).toFixed(1)} °C)`;
  }

  formatPressure(pressure) {
    if (!pressure) return 'None';
    if (pressure < 0.001) return `${(pressure * 1000).toFixed(2)} mbar`;
    if (pressure < 1) return `${pressure.toFixed(3)} bar`;
    return `${pressure.toFixed(2)} bar`;
  }

  formatDays(days) {
    if (!days) return 'Unknown';
    const years = days / 365.25;
    if (years < 1) return `${days.toFixed(1)} days`;
    return `${years.toFixed(2)} years`;
  }

  formatComposition(atmosphere) {
    if (!atmosphere) return 'None';
    const gases = [];
    if (atmosphere.n2_percent > 1) gases.push(`N₂ ${atmosphere.n2_percent.toFixed(0)}%`);
    if (atmosphere.o2_percent > 1) gases.push(`O₂ ${atmosphere.o2_percent.toFixed(0)}%`);
    if (atmosphere.co2_percent > 1) gases.push(`CO₂ ${atmosphere.co2_percent.toFixed(0)}%`);
    if (atmosphere.ar_percent > 1) gases.push(`Ar ${atmosphere.ar_percent.toFixed(0)}%`);
    return gases.join(', ') || 'Trace gases';
  }
}

// Export for use in other modules
window.UIManager = UIManager;

export default UIManager;
