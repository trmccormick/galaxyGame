document.addEventListener('DOMContentLoaded', function() {
  const canvas = document.getElementById('planetCanvas');
  if (!canvas) return;
  
  const ctx = canvas.getContext('2d');
  
  // Resize canvas to fit container
  function resizeCanvas() {
    const container = canvas.parentElement;
    canvas.width = container.clientWidth;
    canvas.height = container.clientHeight;
    drawPlanet();
  }
  
  // Initial resize and add listener
  resizeCanvas();
  window.addEventListener('resize', resizeCanvas);
  
  // Function to draw the planet
  function drawPlanet() {
    // Clear canvas
    ctx.fillStyle = '#000';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    // Draw planet surface (simple placeholder visualization)
    const centerX = canvas.width / 2;
    const centerY = canvas.height / 2;
    const radius = Math.min(canvas.width, canvas.height) * 0.4;
    
    // Planet globe
    const gradient = ctx.createRadialGradient(
      centerX - radius * 0.2, centerY - radius * 0.2, 
      0, 
      centerX, centerY, 
      radius
    );
    
    // Get planet type from data attributes or use default blue
    const planetType = canvas.dataset.planetType || 'terrestrial';
    let colors;
    
    switch(planetType) {
      case 'rocky':
        colors = ['#8B4513', '#A0522D', '#CD853F'];
        break;
      case 'gas_giant':
        colors = ['#B5A642', '#D6C054', '#F0DC82'];
        break;
      case 'ice_giant':
        colors = ['#87CEEB', '#B0E0E6', '#ADD8E6'];
        break;
      case 'desert':
        colors = ['#DAA520', '#F4A460', '#FFDEAD'];
        break;
      case 'volcanic':
        colors = ['#8B0000', '#A52A2A', '#CD5C5C'];
        break;
      case 'terrestrial':
      default:
        colors = ['#2E8B57', '#3CB371', '#66CDAA'];
        break;
    }
    
    gradient.addColorStop(0, colors[0]);
    gradient.addColorStop(0.5, colors[1]);
    gradient.addColorStop(1, colors[2]);
    
    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, 0, Math.PI * 2);
    ctx.fillStyle = gradient;
    ctx.fill();
    
    // Add atmosphere if appropriate
    const hasAtmosphere = canvas.dataset.hasAtmosphere === 'true';
    if (hasAtmosphere) {
      ctx.beginPath();
      ctx.arc(centerX, centerY, radius + 10, 0, Math.PI * 2);
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.2)';
      ctx.lineWidth = 10;
      ctx.stroke();
    }
    
    // Draw simple surface details (placeholder)
    // In a real implementation, this would be generated from terrain data
    drawSurfaceFeatures(ctx, centerX, centerY, radius, planetType);
  }
  
  function drawSurfaceFeatures(ctx, centerX, centerY, radius, planetType) {
    // This is a very simplified placeholder
    // A real implementation would use actual planet data
    
    const hasWater = canvas.dataset.hasWater === 'true';
    
    if (planetType === 'terrestrial' && hasWater) {
      // Draw some "oceans"
      for (let i = 0; i < 3; i++) {
        const angle = Math.random() * Math.PI * 2;
        const distance = radius * 0.7 * Math.random();
        const size = radius * (0.2 + Math.random() * 0.3);
        
        const x = centerX + Math.cos(angle) * distance;
        const y = centerY + Math.sin(angle) * distance;
        
        ctx.beginPath();
        ctx.arc(x, y, size, 0, Math.PI * 2);
        ctx.fillStyle = 'rgba(30, 144, 255, 0.6)';
        ctx.fill();
      }
    }
    
    if (planetType === 'gas_giant') {
      // Draw bands
      for (let i = 0; i < 5; i++) {
        const y = centerY - radius + (radius * 2 / 5) * i;
        ctx.beginPath();
        ctx.moveTo(centerX - Math.sqrt(radius * radius - Math.pow(y - centerY, 2)), y);
        ctx.lineTo(centerX + Math.sqrt(radius * radius - Math.pow(y - centerY, 2)), y);
        ctx.strokeStyle = i % 2 === 0 ? 'rgba(0, 0, 0, 0.1)' : 'rgba(255, 255, 255, 0.1)';
        ctx.lineWidth = radius / 5;
        ctx.stroke();
      }
    }
  }
  
  // Modal handling for planet tools
  const sidePanels = document.querySelectorAll('.side-panel');
  const planetInfoLink = document.getElementById('planetInfo');
  
  if (planetInfoLink) {
    planetInfoLink.addEventListener('click', function(e) {
      e.preventDefault();
      document.getElementById('planetInfoPanel').classList.toggle('active');
    });
  }
  
  // Tools and menu handling
  const tools = document.querySelectorAll('#menuBar .dropdown-content a');
  tools.forEach(tool => {
    tool.addEventListener('click', function(e) {
      const toolId = this.id;
      // For now, just log which tool was clicked
      // In a real implementation, this would activate different tools/views
      console.log(`Tool activated: ${toolId}`);
      
      // Placeholder notification
      const notification = document.createElement('div');
      notification.textContent = `${toolId} tool activated`;
      notification.className = 'notification';
      document.body.appendChild(notification);
      
      setTimeout(() => {
        notification.remove();
      }, 3000);
    });
  });
  
  // Initial planet draw
  drawPlanet();
});