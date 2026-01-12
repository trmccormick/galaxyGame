// Import UI components
import UIManager from './ui_manager.js';
import SystemRenderer from './system_renderer.js';

document.addEventListener('DOMContentLoaded', function() {
  console.log('Game interface loaded');
  
  // System state
  let gameSpeed = 3; // Default simulation speed (1-5)
  let gamePaused = true;
  let gameTime = { year: 0, day: 0 };
  let lastUpdate = Date.now();
  let lastSaveTime = Date.now(); // Track last save time
  
  // Debug output
  const systemCanvas = document.getElementById('systemCanvas');
  if (systemCanvas && systemCanvas.dataset.planets) {
    try {
      console.log("Raw planets data:", systemCanvas.dataset.planets);
      const planets = JSON.parse(systemCanvas.dataset.planets);
      console.log(`Loaded ${planets.length} celestial bodies:`);
      planets.forEach(p => {
        console.log(`${p.name} (${p.type}): is_moon=${p.is_moon}, category=${p.body_category}`);
      });
    } catch (e) {
      console.error('Error parsing planet data:', e);
      console.log("Raw data that failed to parse:", systemCanvas.dataset.planets);
    }
  } else {
    console.warn('No planet data found on canvas');
  }
  
  // System View Canvas
  if (!systemCanvas) return; // Exit if canvas doesn't exist
  
  const systemCtx = systemCanvas.getContext('2d');
  
  // Load actual planet data
  let celestialBodies = [];
  try {
    if (systemCanvas.dataset.planets) {
      celestialBodies = JSON.parse(systemCanvas.dataset.planets);
      console.log("Loaded celestial bodies:", celestialBodies);
    }
  } catch (e) {
    console.error("Error parsing planets data:", e);
  }
  
  // Resize canvas to fit container
  function resizeSystemCanvas() {
    const container = systemCanvas.parentElement;
    systemCanvas.width = container.clientWidth;
    systemCanvas.height = container.clientHeight;
    
    // Regenerate stars on resize
    generateStarfield(systemCanvas.width, systemCanvas.height);
    
    renderSystemView();
  }
  
  // Initial resize and add listener
  resizeSystemCanvas();
  window.addEventListener('resize', resizeSystemCanvas);
  
  // Simulation control buttons
  const runSimBtn = document.getElementById('run-sim');
  const pauseSimBtn = document.getElementById('pause-sim');
  const simSpeedSlider = document.getElementById('sim-speed-slider');
  const timeDisplay = document.querySelector('.current-time');
  
  if (runSimBtn) {
    runSimBtn.addEventListener('click', function() {
      gamePaused = false;
      this.textContent = "Running...";
      lastUpdate = Date.now();
      updateTimeDisplay();
    });
  }
  
  if (pauseSimBtn) {
    pauseSimBtn.addEventListener('click', function() {
      gamePaused = true;
      if (runSimBtn) runSimBtn.textContent = "Run Simulation";
      updateTimeDisplay();
    });
  }
  
  if (simSpeedSlider) {
    simSpeedSlider.addEventListener('input', function() {
      gameSpeed = parseInt(this.value);
    });
  }
  
  // Generate star positions once
  function generateStarfield(width, height) {
    backgroundStars.length = 0; // Clear existing stars
    for (let i = 0; i < 200; i++) {
      backgroundStars.push({
        x: Math.random() * width,
        y: Math.random() * height,
        size: Math.random() * 2
      });
    }
  }
  
  // Draw the fixed stars
  function drawStars(ctx, width, height) {
    // If we haven't generated stars yet, do it now
    if (backgroundStars.length === 0) {
      generateStarfield(width, height);
    }
    
    ctx.fillStyle = '#FFF';
    for (let i = 0; i < backgroundStars.length; i++) {
      const star = backgroundStars[i];
      ctx.fillRect(star.x, star.y, star.size, star.size);
    }
  }
  
  function drawSun(ctx, x, y) {
    const sunRadius = 40;
    const gradient = ctx.createRadialGradient(x, y, 0, x, y, sunRadius);
    gradient.addColorStop(0, 'rgba(255, 255, 0, 1)');
    gradient.addColorStop(0.7, 'rgba(255, 165, 0, 1)');
    gradient.addColorStop(1, 'rgba(255, 69, 0, 0.5)');
    
    ctx.beginPath();
    ctx.arc(x, y, sunRadius, 0, Math.PI * 2);
    ctx.fillStyle = gradient;
    ctx.fill();
  }
  
  // Update game time based on real time elapsed and game speed
  function updateGameTime() {
    if (gamePaused) return;
    
    const now = Date.now();
    const elapsed = (now - lastUpdate); // milliseconds
    lastUpdate = now;
    
    advanceTime(elapsed);
  }
  
  function advanceTime(deltaMs) {
    if (gamePaused) return;
    
    // More consistent speed factors
    const speedFactors = [0.01, 0.05, 0.1, 0.5, 1, 5];
    const speedFactor = speedFactors[gameSpeed - 1] || 0.1;
    
    // Convert milliseconds to days with more noticeable progression
    const daysElapsed = (deltaMs / 1000) * speedFactor;
    
    // Add to local time
    gameTime.day += daysElapsed;
    
    // Handle year rollover
    while (gameTime.day >= 365) {
      gameTime.year++;
      gameTime.day -= 365;
    }
    
    // Update UI on every frame
    updateTimeDisplay();
    
    // Sync with server less frequently to reduce requests
    const now = Date.now();
    if (now - lastSaveTime > 5000) { // Every 5 seconds
      saveGameTime();
      lastSaveTime = now;
    }
  }
  
  function updateTimeDisplay() {
    if (timeDisplay) {
      timeDisplay.textContent = `Year: ${Math.floor(gameTime.year)} | Day: ${Math.floor(gameTime.day)}`;
    }
  }
  
  // Render solar system
  function renderSystemView() {
    // Update game time
    updateGameTime();
    
    // Clear canvas
    systemCtx.fillStyle = '#000';
    systemCtx.fillRect(0, 0, systemCanvas.width, systemCanvas.height);
    
    // Draw starfield background
    drawStars(systemCtx, systemCanvas.width, systemCanvas.height);
    
    // Draw sun at center
    const centerX = systemCanvas.width / 2;
    const centerY = systemCanvas.height / 2;
    drawSun(systemCtx, centerX, centerY);
    
    // Draw planets if we have data
    if (celestialBodies && celestialBodies.length > 0) {
      drawPlanets(systemCtx, centerX, centerY, celestialBodies);
    } else {
      // Show message if no planets
      systemCtx.fillStyle = 'white';
      systemCtx.font = '16px Arial';
      systemCtx.textAlign = 'center';
      systemCtx.fillText('No celestial bodies found. Please run the seed data.', centerX, centerY + 100);
    }
  }
  
  function drawPlanets(ctx, centerX, centerY, bodies) {
    // Scale factors to better represent the solar system
    const orbitScaleFactor = 30; // Increase this to spread orbits further apart
    const minOrbitRadius = 60;   // Minimum distance from the center
    
    // Filter out moons - they'll be drawn with their parents
    const planets = bodies.filter(body => !body.is_moon);
    
    // Draw planets
    planets.forEach((planet, index) => {
      // Calculate orbit radius - use logarithmic scaling to represent real distances
      const orbitRadius = minOrbitRadius + (Math.log(index + 1) * orbitScaleFactor * (index + 1));
      
      // Calculate planet position - angle based on orbital_period
      const angle = ((gameTime.day / planet.orbital_period) * Math.PI * 2) % (Math.PI * 2);
      const x = centerX + Math.cos(angle) * orbitRadius;
      const y = centerY + Math.sin(angle) * orbitRadius;
      
      // Calculate planet size based on actual radius but with a min/max range
      const planetSize = Math.max(5, Math.min(20, planet.radius / 1e6));
      
      // Draw orbit
      ctx.beginPath();
      ctx.arc(centerX, centerY, orbitRadius, 0, Math.PI * 2);
      ctx.strokeStyle = 'rgba(200, 200, 200, 0.2)';
      ctx.stroke();
      
      // Draw planet
      ctx.beginPath();
      ctx.arc(x, y, planetSize, 0, Math.PI * 2);
      
      // Color based on planet type
      switch(planet.body_category) {
        case 'terrestrial_planet':
          ctx.fillStyle = '#7CB9E8'; break;
        case 'gas_giant':
          ctx.fillStyle = '#E6BE8A'; break;
        case 'ice_giant':
          ctx.fillStyle = '#98D8C8'; break;
        case 'dwarf_planet':
          ctx.fillStyle = '#C8A2C8'; break;
        default:
          ctx.fillStyle = '#CCCCCC';
      }
      ctx.fill();
      
      // Draw planet name
      ctx.fillStyle = 'white';
      ctx.font = '12px Arial';
      ctx.textAlign = 'center';
      ctx.fillText(planet.name, x, y - planetSize - 5);
      
      // Find and draw moons for this planet with a significant distance from the planet
      const moons = bodies.filter(body => 
        body.is_moon && body.parent_body === planet.name
      );
      
      // Draw moons at a safe distance from the planet
      drawMoons(ctx, planet, moons, x, y, planetSize);
    });
  }
  
  function drawMoons(ctx, planet, moons, planetX, planetY, planetSize) {
    moons.forEach((moon, moonIndex) => {
      // Use the moon's actual orbital period if available, with a reasonable default
      const moonOrbitalPeriod = moon.orbital_period || 
                              (planet.orbital_period / 10 * (moonIndex + 1));
      
      // Calculate moon position based on its own orbital period
      const moonAngle = ((gameTime.day / moonOrbitalPeriod) * Math.PI * 2);
      
      // Increase moon orbit radius for better visibility
      // Ensure moons are drawn with increasing orbit radius to avoid overlaps
      const moonOrbitRadius = planetSize * 1.5 + (moonIndex * 15);
      
      // Make moons smaller but still visible
      const moonSize = Math.max(3, planetSize * 0.3);
      
      // Calculate moon position - faster orbit than planet
      const moonX = planetX + Math.cos(moonAngle) * moonOrbitRadius;
      const moonY = planetY + Math.sin(moonAngle) * moonOrbitRadius;
      
      // Draw moon orbit
      ctx.beginPath();
      ctx.arc(planetX, planetY, moonOrbitRadius, 0, Math.PI * 2);
      ctx.strokeStyle = 'rgba(150, 150, 150, 0.2)';
      ctx.stroke();
      
      // Draw moon
      ctx.beginPath();
      ctx.arc(moonX, moonY, moonSize, 0, Math.PI * 2);
      ctx.fillStyle = '#D0D0D0';
      ctx.fill();
      
      // Draw moon name (smaller font)
      ctx.fillStyle = 'white';
      ctx.font = '10px Arial';
      ctx.textAlign = 'center';
      ctx.fillText(moon.name, moonX, moonY - moonSize - 5);
    });
  }
  
  // Initial render
  renderSystemView();
  
  // Animate only at a reasonable framerate (30fps is plenty for this visualization)
  setInterval(renderSystemView, 33);
  
  // Initialize UI state
  updateTimeDisplay();
  
  // Load game time from server-side data
  try {
    const timeDataElement = document.getElementById('game-time-data');
    if (timeDataElement && timeDataElement.dataset.time) {
      const timeData = JSON.parse(timeDataElement.dataset.time);
      gameTime = timeData;
      console.log('Loaded game time:', gameTime);
      updateTimeDisplay();
    }
  } catch (e) {
    console.error('Error loading time data:', e);
  }
  
  // Run server-side simulation when clicking Run button
  async function runServerSimulation(days) {
    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
      const response = await fetch('/game/run_simulation', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken
        },
        body: JSON.stringify({
          days: days
        })
      });
      
      const data = await response.json();
      
      if (data.success) {
        // Update local game time with server time
        gameTime.year = data.time.year;
        gameTime.day = data.time.day;
        
        // Update the display
        updateTimeDisplay();
        
        // Add notification message
        if (data.message) {
          addNotification(data.message);
        }
      }
    } catch (error) {
      console.error('Error running simulation:', error);
    }
  }

  function addNotification(message) {
    const feed = document.getElementById('notification-feed');
    if (feed) {
      const notification = document.createElement('div');
      notification.className = 'notification';
      notification.textContent = message;
      feed.prepend(notification);
      
      // Limit notifications
      if (feed.children.length > 5) {
        feed.removeChild(feed.lastChild);
      }
    }
  }
  
  // Add these after your DOMContentLoaded event
  // Fast Forward button
  const fastForwardBtn = document.getElementById('fast-forward-btn');
  if (fastForwardBtn) {
    fastForwardBtn.addEventListener('click', function() {
      console.log('Fast forwarding 30 days');
      
      // Add 30 days to the current time
      gameTime.day += 30;
      
      // Handle year rollover
      while (gameTime.day >= 365) {
        gameTime.year++;
        gameTime.day -= 365;
      }
      
      // Update UI
      updateTimeDisplay();
      
      // Save to server
      saveGameTime();
    });
  }
  
  // Reset Time button
  const resetTimeBtn = document.getElementById('reset-time-btn');
  if (resetTimeBtn) {
    resetTimeBtn.addEventListener('click', function() {
      if (confirm('Are you sure you want to reset the game time to 0?')) {
        console.log('Resetting time to 0');
        
        // Reset time
        gameTime = { year: 0, day: 0 };
        
        // Update UI
        updateTimeDisplay();
        
        // Save to server
        saveGameTime();
      }
    });
  }
  
  // Connect run/pause button
  if (runSimBtn && pauseSimBtn) {
    runSimBtn.addEventListener('click', toggleSimulation);
    pauseSimBtn.addEventListener('click', toggleSimulation);
  }
  
  // Connect speed buttons
  const speedButtons = document.querySelectorAll('.speed-btn');
  speedButtons.forEach(button => {
    button.addEventListener('click', function() {
      const speed = parseInt(this.dataset.speed);
      setGameSpeed(speed);
    });
  });
  
  // Connect time jump buttons
  document.getElementById('jump-1-day')?.addEventListener('click', () => jumpTime(1));
  document.getElementById('jump-7-days')?.addEventListener('click', () => jumpTime(7));
  document.getElementById('jump-30-days')?.addEventListener('click', () => jumpTime(30));
  document.getElementById('jump-90-days')?.addEventListener('click', () => jumpTime(90));
  document.getElementById('jump-365-days')?.addEventListener('click', () => jumpTime(365));
  
  // Start polling for updates
  setInterval(pollGameState, 2000);
});

// Toggle running state
function toggleSimulation() {
  fetch('/game/toggle_running', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
    }
  })
  .then(response => response.json())
  .then(data => {
    updateGameDisplay(data);
    
    // Update button text
    const runSimBtn = document.getElementById('run-sim');
    if (runSimBtn) {
      runSimBtn.textContent = data.running ? "Running..." : "Run Simulation";
    }
  })
  .catch(error => console.error('Error toggling simulation:', error));
}

// Set game speed
function setGameSpeed(speed) {
  fetch('/game/set_speed', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
    },
    body: JSON.stringify({ speed: speed })
  })
  .then(response => response.json())
  .then(data => {
    updateGameDisplay(data);
    
    // Update active speed button
    document.querySelectorAll('.speed-btn').forEach(btn => {
      btn.classList.remove('active');
    });
    document.querySelector(`.speed-btn[data-speed="${speed}"]`)?.classList.add('active');
  })
  .catch(error => console.error('Error setting speed:', error));
}

// Jump forward in time
function jumpTime(days) {
  fetch('/game/jump_time', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
    },
    body: JSON.stringify({ days: days })
  })
  .then(response => response.json())
  .then(data => {
    updateGameDisplay(data);
  })
  .catch(error => console.error('Error jumping time:', error));
}

// Poll for game state updates
function pollGameState() {
  fetch('/game/state')
    .then(response => response.json())
    .then(data => {
      updateGameDisplay(data);
    })
    .catch(error => console.error('Error polling game state:', error));
}

// Update time display and other UI elements
function updateGameDisplay(data) {
  // Update time display
  const timeDisplay = document.querySelector('.current-time');
  if (timeDisplay && data.time) {
    timeDisplay.textContent = `Year: ${data.time.year} | Day: ${data.time.day}`;
  }
  
  // Other UI updates as needed
}

// Add this function to save game time to the server
function saveGameTime() {
  // Round to integers before saving
  const days = Math.floor(gameTime.day);
  const years = Math.floor(gameTime.year);
  
  fetch('/game/update_time', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
    },
    body: JSON.stringify({ days: days, years: years })
  })
  .then(response => response.json())
  .then(data => {
    console.log('Time saved to server:', data);
  })
  .catch(error => {
    console.error('Error saving time:', error);
  });
}