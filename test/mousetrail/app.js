function drawTrail(x, y) {
    const canvas = document.getElementById('trailCanvas');
    const ctx = canvas.getContext('2d');
    const radius = 10;
    
    ctx.beginPath();
    ctx.arc(x, y, radius, 0, Math.PI * 2, true);
    ctx.fillStyle = 'rgba(255, 255, 255, 0.5)';
    ctx.fill();
  }
document.addEventListener('mousemove', (event) => {
  const x = event.clientX;
  const y = event.clientY;
  
  drawTrail(x, y);
});
ctx.clearRect(0, 0, canvas.width, canvas.height);
function drawTrail(x, y) {
    const canvas = document.getElementById('trailCanvas');
    const ctx = canvas.getContext('2d');
    const radius = 10;
    const maxOpacity = 0.5;
    
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    for (let i = 0; i < 10; i++) {
      const distance = i * radius * 2;
      const opacity = maxOpacity - i / 10 * maxOpacity;
      
      ctx.beginPath();
      ctx.arc(x, y, distance, 0, Math.PI * 2, true);
      ctx.fillStyle = `rgba(255, 255, 255, ${opacity})`;
      ctx.fill();
    }
  }
  