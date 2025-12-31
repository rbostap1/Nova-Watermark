window.addEventListener('message', function(event) {
    const data = event.data;
    const watermark = document.getElementById('watermark');
    const watermarkImage = document.getElementById('watermark-image');

    if (data.action === 'showWatermark') {
        // Set image source
        watermarkImage.src = `../${data.image}`;
        
        // Set dimensions
        watermarkImage.style.width = data.width + 'px';
        watermarkImage.style.height = data.height + 'px';
        
        // Set position (top-right corner with offsets)
        watermark.style.right = data.offsetX + 'px';
        watermark.style.top = data.offsetY + 'px';
        
        // Set opacity
        watermarkImage.style.opacity = data.opacity;
        
        // Show watermark
        watermark.classList.add('visible');
        
    } else if (data.action === 'hideWatermark') {
        watermark.classList.remove('visible');
    }
});
