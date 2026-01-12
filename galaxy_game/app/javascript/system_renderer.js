/**
 * System Renderer - Enhanced solar system visualization
 */

class SystemRenderer {
  constructor(canvas, celestialBodies, uiManager) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.celestialBodies = celestialBodies;
    this.uiManager = uiManager;
    
    // Rendering state
    this.centerX = 0;
    this.centerY = 0;
    this.hoveredPlanet = null;
    this.selectedPlanet = null;
    
    // Starfield
    this.backgroundStars = [];
    
    // Animation
    this.gameTime = { year: 0, day: 0 };
    this.gamePaused = true;
    
    // Mouse interaction
    this.setupMouseHandlers();
  }

  /**
   * Initialize the renderer
   */
  initialize() {
    this.resize();
    this.generateStarfield();
    console.log('System Renderer initialized');
  }

  /**
   * Resize canvas to fit container
   */
  resize() {
    const container = this.canvas.parentElement;
    this.canvas.width = container.clientWidth;
    this.canvas.height = container.clientHeight;
    
    this.centerX = this.canvas.width / 2;
    this.centerY = this.canvas.height / 2;
    
    this.generateStarfield();
  }

  /**
   * Generate starfield background
   */
  generateStarfield() {
    this.backgroundStars = [];
    for (let i = 0; i < 300; i++) {
      this.backgroundStars.push({
        x: Math.random() * this.canvas.width,
        y: Math.random() * this.canvas.height,
        size: Math.random() * 2,
        brightness: 0.5 + Math.random() * 0.5
      });
    }
  }

  /**
   * Setup mouse interaction handlers
   */
  setupMouseHandlers() {
    this.canvas.addEventListener('mousemove', (e) => {
      const rect = this.canvas.getBoundingClientRect();
      const mouseX = e.clientX - rect.left;
      const mouseY = e.clientY - rect.top;
      
      this.hoveredPlanet = this.getPlanetAtPosition(mouseX, mouseY);
      
      // Change cursor
      this.canvas.style.cursor = this.hoveredPlanet ? 'pointer' : 'default';
    });

    this.canvas.addEventListener('click', (e) => {
      if (this.hoveredPlanet) {
        this.selectPlanet(this.hoveredPlanet);
      }
    });
  }

  /**
   * Get planet at mouse position
   */
  getPlanetAtPosition(mouseX, mouseY) {
    const planets = this.celestialBodies.filter(b => !b.is_moon);
    const maxOrbit = Math.min(this.centerX, this.centerY) * 0.85;
    
    for (let i = 0; i < planets.length; i++) {
      const planet = planets[i];
      const orbitRadius = 80 + ((maxOrbit - 80) * (i + 1) / (planets.length + 1));
      const orbitDuration = parseFloat(planet.orbital_period) || 365;
      const angle = this.gamePaused 
        ? (i * (Math.PI / 4)) % (Math.PI * 2)
        : ((this.gameTime.day / orbitDuration) * Math.PI * 2) % (Math.PI * 2);
      
      const x = this.centerX + Math.cos(angle) * orbitRadius;
      const y = this.centerY + Math.sin(angle) * orbitRadius;
      
      const planetSize = this.calculatePlanetSize(planet);
      const distance = Math.sqrt(Math.pow(mouseX - x, 2) + Math.pow(mouseY - y, 2));
      
      if (distance < planetSize + 5) {
        return planet;
      }
    }
    
    return null;
  }

  /**
   * Select a planet
   */
  selectPlanet(planet) {
    this.selectedPlanet = planet;
    if (this.uiManager) {
      this.uiManager.selectPlanet(planet);
    }
  }

  /**
   * Calculate planet visual size
   */
  calculatePlanetSize(planet) {
    let planetSize = 10;
    if (planet.radius) {
      planetSize = 5 + Math.log10(parseFloat(planet.radius) / 1000) * 3;
    } else if (planet.mass) {
      planetSize = 5 + Math.log10(parseFloat(planet.mass) / 1e23) * 2;
    }
    return Math.max(6, Math.min(30, planetSize));
  }

  /**
   * Get planet color based on type and temperature
   */
  getPlanetColor(planet) {
    if (planet.body_category === 'terrestrial') {
      const temp = planet.surface_temperature || 250;
      if (temp > 400) return '#d35400'; // Hot (Venus)
      if (temp > 250) return '#3498db'; // Habitable (Earth)
      return '#95a5a6'; // Cold (Mars)
    } else if (planet.body_category === 'gas_giant') {
      return '#f39c12';
    } else if (planet.body_category === 'ice_giant') {
      return '#3498db';
    } else if (planet.body_category === 'super_earth') {
      return '#16a085';
    } else if (planet.body_category === 'ocean_planet') {
      return '#2980b9';
    } else if (planet.body_category === 'dwarf_planet') {
      return '#7f8c8d';
    }
    return '#ecf0f1';
  }

  /**
   * Render the solar system
   */
  render() {
    // Clear canvas
    this.ctx.fillStyle = '#000';
    this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
    
    // Draw starfield
    this.drawStars();
    
    // Draw sun
    this.drawSun();
    
    // Draw planets
    if (this.celestialBodies && this.celestialBodies.length > 0) {
      this.drawPlanets();
    } else {
      this.drawNoDataMessage();
    }
  }

  /**
   * Draw starfield
   */
  drawStars() {
    this.backgroundStars.forEach(star => {
      this.ctx.fillStyle = `rgba(255, 255, 255, ${star.brightness})`;
      this.ctx.fillRect(star.x, star.y, star.size, star.size);
    });
  }

  /**
   * Draw the sun
   */
  drawSun() {
    const sunRadius = 40;
    const gradient = this.ctx.createRadialGradient(
      this.centerX, this.centerY, 0,
      this.centerX, this.centerY, sunRadius
    );
    gradient.addColorStop(0, 'rgba(255, 255, 0, 1)');
    gradient.addColorStop(0.7, 'rgba(255, 165, 0, 1)');
    gradient.addColorStop(1, 'rgba(255, 69, 0, 0.5)');
    
    this.ctx.beginPath();
    this.ctx.arc(this.centerX, this.centerY, sunRadius, 0, Math.PI * 2);
    this.ctx.fillStyle = gradient;
    this.ctx.fill();
    
    // Glow effect
    this.ctx.beginPath();
    this.ctx.arc(this.centerX, this.centerY, sunRadius + 15, 0, Math.PI * 2);
    this.ctx.strokeStyle = 'rgba(255, 200, 0, 0.2)';
    this.ctx.lineWidth = 10;
    this.ctx.stroke();
  }

  /**
   * Draw all planets
   */
  drawPlanets() {
    const planets = this.celestialBodies.filter(b => !b.is_moon);
    planets.sort((a, b) => {
      if (a.orbital_period && b.orbital_period) {
        return parseFloat(a.orbital_period) - parseFloat(b.orbital_period);
      }
      return 0;
    });
    
    const maxOrbit = Math.min(this.centerX, this.centerY) * 0.85;
    
    planets.forEach((planet, index) => {
      const orbitRadius = 80 + ((maxOrbit - 80) * (index + 1) / (planets.length + 1));
      
      // Draw orbit if enabled
      if (this.uiManager.showOrbits) {
        this.drawOrbit(orbitRadius);
      }
      
      // Calculate planet position
      const orbitDuration = parseFloat(planet.orbital_period) || 365;
      const angle = this.gamePaused 
        ? (index * (Math.PI / 4)) % (Math.PI * 2)
        : ((this.gameTime.day / orbitDuration) * Math.PI * 2) % (Math.PI * 2);
      
      const x = this.centerX + Math.cos(angle) * orbitRadius;
      const y = this.centerY + Math.sin(angle) * orbitRadius;
      
      // Draw planet
      this.drawPlanet(planet, x, y);
      
      // Draw label if enabled
      if (this.uiManager.showLabels) {
        this.drawLabel(planet.name, x, y);
      }
      
      // Draw selection indicator
      if (this.selectedPlanet === planet) {
        this.drawSelectionRing(x, y, this.calculatePlanetSize(planet));
      }
      
      // Draw hover effect
      if (this.hoveredPlanet === planet) {
        this.drawHoverEffect(x, y, this.calculatePlanetSize(planet));
      }
      
      // Draw moons if enabled
      if (this.uiManager.showMoons) {
        this.drawMoons(planet, x, y);
      }
    });
  }

  /**
   * Draw orbit circle
   */
  drawOrbit(radius) {
    this.ctx.beginPath();
    this.ctx.arc(this.centerX, this.centerY, radius, 0, Math.PI * 2);
    this.ctx.strokeStyle = 'rgba(255, 255, 255, 0.15)';
    this.ctx.lineWidth = 1;
    this.ctx.stroke();
  }

  /**
   * Draw a single planet
   */
  drawPlanet(planet, x, y) {
    const size = this.calculatePlanetSize(planet);
    const color = this.getPlanetColor(planet);
    
    // Planet gradient
    const gradient = this.ctx.createRadialGradient(
      x - size * 0.3, y - size * 0.3, 0,
      x, y, size
    );
    gradient.addColorStop(0, this.lightenColor(color, 40));
    gradient.addColorStop(1, color);
    
    this.ctx.beginPath();
    this.ctx.arc(x, y, size, 0, Math.PI * 2);
    this.ctx.fillStyle = gradient;
    this.ctx.fill();
    
    // Atmosphere glow if planet has atmosphere
    if (planet.atmosphere && planet.atmosphere.surface_pressure > 0.01) {
      this.ctx.beginPath();
      this.ctx.arc(x, y, size + 2, 0, Math.PI * 2);
      this.ctx.strokeStyle = `rgba(135, 206, 250, 0.4)`;
      this.ctx.lineWidth = 2;
      this.ctx.stroke();
    }
  }

  /**
   * Draw planet label
   */
  drawLabel(name, x, y) {
    this.ctx.fillStyle = '#fff';
    this.ctx.font = '12px Arial';
    this.ctx.textAlign = 'center';
    this.ctx.fillText(name, x, y + 25);
  }

  /**
   * Draw selection ring
   */
  drawSelectionRing(x, y, size) {
    this.ctx.beginPath();
    this.ctx.arc(x, y, size + 8, 0, Math.PI * 2);
    this.ctx.strokeStyle = 'rgba(52, 152, 219, 0.8)';
    this.ctx.lineWidth = 2;
    this.ctx.stroke();
  }

  /**
   * Draw hover effect
   */
  drawHoverEffect(x, y, size) {
    this.ctx.beginPath();
    this.ctx.arc(x, y, size + 5, 0, Math.PI * 2);
    this.ctx.strokeStyle = 'rgba(255, 255, 255, 0.5)';
    this.ctx.lineWidth = 1;
    this.ctx.stroke();
  }

  /**
   * Draw moons for a planet
   */
  drawMoons(planet, planetX, planetY) {
    const moons = this.celestialBodies.filter(b => 
      b.is_moon && b.parent_celestial_body_id === planet.id
    );
    
    moons.forEach((moon, index) => {
      const moonOrbit = 20 + (index * 8);
      const moonAngle = (this.gameTime.day * 10 + index * 90) * Math.PI / 180;
      const moonX = planetX + Math.cos(moonAngle) * moonOrbit;
      const moonY = planetY + Math.sin(moonAngle) * moonOrbit;
      
      // Draw moon orbit
      this.ctx.beginPath();
      this.ctx.arc(planetX, planetY, moonOrbit, 0, Math.PI * 2);
      this.ctx.strokeStyle = 'rgba(200, 200, 200, 0.1)';
      this.ctx.lineWidth = 1;
      this.ctx.stroke();
      
      // Draw moon
      this.ctx.beginPath();
      this.ctx.arc(moonX, moonY, 3, 0, Math.PI * 2);
      this.ctx.fillStyle = '#bdc3c7';
      this.ctx.fill();
    });
  }

  /**
   * Draw "no data" message
   */
  drawNoDataMessage() {
    this.ctx.fillStyle = 'white';
    this.ctx.font = '16px Arial';
    this.ctx.textAlign = 'center';
    this.ctx.fillText(
      'No celestial bodies found. Please run the seed data.',
      this.centerX,
      this.centerY + 100
    );
  }

  /**
   * Update game time
   */
  updateTime(year, day, paused) {
    this.gameTime.year = year;
    this.gameTime.day = day;
    this.gamePaused = paused;
  }

  /**
   * Lighten a hex color
   */
  lightenColor(color, percent) {
    const num = parseInt(color.replace('#', ''), 16);
    const amt = Math.round(2.55 * percent);
    const R = (num >> 16) + amt;
    const G = (num >> 8 & 0x00FF) + amt;
    const B = (num & 0x0000FF) + amt;
    return '#' + (0x1000000 + (R < 255 ? R < 1 ? 0 : R : 255) * 0x10000 +
      (G < 255 ? G < 1 ? 0 : G : 255) * 0x100 +
      (B < 255 ? B < 1 ? 0 : B : 255))
      .toString(16).slice(1);
  }
}

// Export for use in other modules
window.SystemRenderer = SystemRenderer;

export default SystemRenderer;
