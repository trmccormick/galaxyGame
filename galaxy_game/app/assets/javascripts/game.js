document.addEventListener('DOMContentLoaded', function() {
    const tileSize = 40;
    const canvas = document.getElementById('gameCanvas');
    const ctx = canvas.getContext('2d');
    const map = [
      [1, 0, 1, 0],
      [0, 1, 0, 1],
      [1, 0, 1, 0],
      [0, 1, 0, 1]
    ];
  
    function drawMap() {
      for (let row = 0; row < map.length; row++) {
        for (let col = 0; col < map[row].length; col++) {
          ctx.fillStyle = map[row][col] === 1 ? 'green' : 'white';
          ctx.fillRect(col * tileSize, row * tileSize, tileSize, tileSize);
        }
      }
    }
  
    drawMap();
  
    // Function to open a modal
    function openModal(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
        modal.style.display = "block";
        // Prevent scrolling when modal is open
        document.body.style.overflow = "hidden";
        }
    }
  
    // Function to close a modal
    function closeModal(modal) {
        if (modal) {
        modal.style.display = "none";
        // Allow scrolling when modal is closed
        document.body.style.overflow = "";
        }
    }
  
    // Event listeners for menu items
    document.getElementById('newPlanet').addEventListener('click', function() {
        openModal('newPlanetModal');
    });
  
    document.getElementById('loadPlanet').addEventListener('click', function() {
        openModal('loadPlanetModal');
    });
  
    // Add more event listeners for other menu items...
  
    // Event listeners for closing modals
    const closeButtons = document.querySelectorAll('.close');
    closeButtons.forEach(button => {
        button.addEventListener('click', function() {
        const modalId = this.getAttribute('data-modal');
        const modal = document.getElementById(modalId);
        closeModal(modal);
        });
    });

    window.addEventListener('click', function(event) {
        if (event.target.classList.contains('modal')) {
        closeModal(event.target);
        }
    });
  });
  