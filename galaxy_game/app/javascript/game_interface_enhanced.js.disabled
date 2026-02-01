// Enhanced Game Interface with UI Manager and System Renderer Integration
// Import UI components
import UIManager from './ui_manager.js';
import SystemRenderer from './system_renderer.js';

document.addEventListener('DOMContentLoaded', function() {
  console.log('Enhanced Game interface loaded');
  
  // System state
  let gameSpeed = 3;
  let gamePaused = true;
  let gameTime = { year: 0, day: 0 };
  let lastUpdate = Date.now();
  let lastSaveTime = Date.now();
  
  const systemCanvas = document.getElementById('systemCanvas');
  if (!systemCanvas) {
    console.warn('System canvas not found');
    return;
  }
  
  // Load actual planet data
  let celestialBodies = [];
  try {
    if (systemCanvas.dataset.planets) {
      celestialBodies = JSON.parse(systemCanvas.dataset.planets);
      console.log(`Loaded ${celestialBodies.length} celestial bodies`);
    }
  } catch (e) {
    console.error("Error parsing planets data:", e);
  }
  
  // Initialize UI Manager
  const uiManager = new UIManager();
  uiManager.initialize();
  uiManager.logEvent('Game interface initialized', 'info');
  
  // Initialize System Renderer
  const systemRenderer = new SystemRenderer(systemCanvas, celestialBodies, uiManager);
  systemRenderer.initialize();
  
  // Resize handler
  function resizeSystemCanvas() {
    systemRenderer.resize();
    renderSystemView();
  }
  
  // Initial resize and add listener
  resizeSystemCanvas();
  window.addEventListener('resize', resizeSystemCanvas);
  
  // Simulation control buttons
  const runSimBtn = document.getElementById('run-sim');
  const pauseSimBtn = document.getElementById('pause-sim');
  const timeDisplay = document.querySelector('.current-time');
  
  if (runSimBtn) {
    runSimBtn.addEventListener('click', function() {
      gamePaused = !gamePaused;
      this.textContent = gamePaused ? "Run" : "Running...";
      lastUpdate = Date.now();
      uiManager.logEvent(`Simulation ${gamePaused ? 'paused' : 'started'}`, 'info');
      updateTimeDisplay();
    });
  }
  
  if (pauseSimBtn) {
    pauseSimBtn.addEventListener('click', function() {
      gamePaused = true;
      if (runSimBtn) runSimBtn.textContent = "Run";
      uiManager.logEvent('Simulation paused', 'info');
      updateTimeDisplay();
    });
  }
  
  // Speed control buttons
  const speedButtons = document.querySelectorAll('.speed-btn');
  speedButtons.forEach(button => {
    button.addEventListener('click', function() {
      gameSpeed = parseInt(this.dataset.speed);
      speedButtons.forEach(btn => btn.classList.remove('active'));
      this.classList.add('active');
      uiManager.logEvent(`Speed set to ${gameSpeed}x`, 'info');
    });
  });
  
  // Time jump buttons
  document.getElementById('jump-1-day')?.addEventListener('click', () => jumpTime(1));
  document.getElementById('jump-7-days')?.addEventListener('click', () => jumpTime(7));
  document.getElementById('jump-30-days')?.addEventListener('click', () => jumpTime(30));
  document.getElementById('jump-90-days')?.addEventListener('click', () => jumpTime(90));
  document.getElementById('jump-365-days')?.addEventListener('click', () => jumpTime(365));
  
  // Update game time based on real time elapsed and game speed
  function updateGameTime() {
    if (gamePaused) return;
    
    const now = Date.now();
    const elapsed = (now - lastUpdate) / 1000; // seconds
    lastUpdate = now;
    
    // Convert to game days (speed 3 = 1 day per second)
    const daysPassed = elapsed * gameSpeed;
    gameTime.day += daysPassed;
    
    // Check if a year has passed
    while (gameTime.day >= 365) {
      gameTime.year++;
      gameTime.day -= 365;
    }
    
    // Auto-save every 10 seconds
    if (now - lastSaveTime > 10000) {
      saveGameTime();
      lastSaveTime = now;
    }
    
    updateTimeDisplay();
  }
  
  function updateTimeDisplay() {
    if (timeDisplay) {
      timeDisplay.textContent = `Year: ${Math.floor(gameTime.year)} | Day: ${Math.floor(gameTime.day)}`;
    }
    
    // Update renderer with current time
    systemRenderer.updateTime(gameTime.year, gameTime.day, gamePaused);
  }
  
  // Render solar system
  function renderSystemView() {
    updateGameTime();
    systemRenderer.render();
  }
  
  // Load game time from server-side data
  try {
    const gameTimeData = document.getElementById('game-time-data');
    if (gameTimeData && gameTimeData.dataset.time) {
      const serverTime = JSON.parse(gameTimeData.dataset.time);
      gameTime.year = serverTime.year || 0;
      gameTime.day = serverTime.day || 0;
      gamePaused = !serverTime.running;
      console.log('Loaded game time from server:', gameTime);
      updateTimeDisplay();
    }
  } catch (e) {
    console.error('Error loading game time:', e);
  }
  
  // Initial render
  renderSystemView();
  
  // Animate at 30fps
  setInterval(renderSystemView, 33);
  
  // Initialize UI state
  updateTimeDisplay();
  
  // Time jump function
  async function jumpTime(days) {
    uiManager.logEvent(`Jumping forward ${days} days...`, 'info');
    
    try {
      const response = await fetch('/game/jump_time', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
        },
        body: JSON.stringify({ days: days })
      });
      
      const data = await response.json();
      if (data.success) {
        gameTime.year = data.year;
        gameTime.day = data.day;
        updateTimeDisplay();
        uiManager.logEvent(`Time advanced ${days} days`, 'success');
        
        // Reload planet data to show updated terraforming progress
        await reloadPlanetData();
      } else {
        uiManager.logEvent('Failed to jump time', 'error');
      }
    } catch (error) {
      console.error('Error jumping time:', error);
      uiManager.logEvent('Error jumping time', 'error');
    }
  }
  
  // Save game time to the server
  function saveGameTime() {
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
      console.log('Game time saved:', data);
    })
    .catch(error => {
      console.error('Error saving game time:', error);
    });
  }
  
  // Reload planet data from server
  async function reloadPlanetData() {
    try {
      const response = await fetch('/game/celestial_bodies_data');
      const data = await response.json();
      
      if (data.celestial_bodies) {
        // Update renderer with new data
        systemRenderer.celestialBodies = data.celestial_bodies;
        uiManager.logEvent('Planet data refreshed', 'info');
      }
    } catch (error) {
      console.error('Error reloading planet data:', error);
    }
  }
  
  // Poll for game state updates every 2 seconds
  setInterval(pollGameState, 2000);
  
  function pollGameState() {
    if (gamePaused) return; // Don't poll if paused
    
    fetch('/game/state')
      .then(response => response.json())
      .then(data => {
        if (data.time) {
          // Update time from server if running
          gameTime.year = data.time.year || gameTime.year;
          gameTime.day = data.time.day || gameTime.day;
          updateTimeDisplay();
        }
      })
      .catch(error => console.error('Error polling game state:', error));
  }
});
