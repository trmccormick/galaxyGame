document.addEventListener('DOMContentLoaded', function() {
  // Canvas setup
  const canvas = document.getElementById('systemCanvas');
  
  // Add a check in case the canvas doesn't exist
  if (!canvas) return;
  
  const ctx = canvas.getContext('2d');
  
  // Resize canvas to fit window
  function resizeCanvas() {
    canvas.width = canvas.parentElement.clientWidth;
    canvas.height = canvas.parentElement.clientHeight;
    renderGame(); // Re-render when resized
  }
  
  // Initial resize and add listener
  resizeCanvas();
  window.addEventListener('resize', resizeCanvas);
  
  // Basic game rendering
  function renderGame() {
    // Clear canvas
    ctx.fillStyle = '#000';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    // Draw stars backdrop
    drawStars();
    
    // Draw planets (placeholder - will be replaced with actual data)
    drawPlanets();
  }
  
  // Draw random stars
  function drawStars() {
    ctx.fillStyle = '#FFF';
    for (let i = 0; i < 200; i++) {
      const x = Math.random() * canvas.width;
      const y = Math.random() * canvas.height;
      const size = Math.random() * 2;
      ctx.fillRect(x, y, size, size);
    }
  }
  
  // Placeholder for planet drawing
  function drawPlanets() {
    // This would be replaced with actual planet data
    const planets = [
      { x: canvas.width * 0.3, y: canvas.height * 0.5, radius: 30, color: '#3498db' },
      { x: canvas.width * 0.7, y: canvas.height * 0.3, radius: 20, color: '#e74c3c' },
      { x: canvas.width * 0.5, y: canvas.height * 0.7, radius: 25, color: '#2ecc71' }
    ];
    
    planets.forEach(planet => {
      ctx.beginPath();
      ctx.arc(planet.x, planet.y, planet.radius, 0, Math.PI * 2);
      ctx.fillStyle = planet.color;
      ctx.fill();
    });
  }
  
  // Modal handling
  const modals = document.querySelectorAll('.modal');
  const modalTriggers = document.querySelectorAll('[id^="new"], [id^="load"]');
  const closeButtons = document.querySelectorAll('.close');
  
  modalTriggers.forEach(trigger => {
    trigger.addEventListener('click', function(e) {
      e.preventDefault();
      const modalId = this.id + 'Modal';
      const modal = document.getElementById(modalId);
      if (modal) modal.style.display = 'block';
    });
  });
  
  closeButtons.forEach(button => {
    button.addEventListener('click', function() {
      const modalId = this.getAttribute('data-modal');
      const modal = document.getElementById(modalId);
      if (modal) modal.style.display = 'none';
    });
  });
  
  // Close modal when clicking outside of it
  window.addEventListener('click', function(e) {
    modals.forEach(modal => {
      if (e.target === modal) {
        modal.style.display = 'none';
      }
    });
  });
  
  // Initial render
  renderGame();
});