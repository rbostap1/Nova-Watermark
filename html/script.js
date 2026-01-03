console.log('[Watermark] Script loaded');

window.addEventListener('message', function(event) {
    const data = event.data;
    const watermark = document.getElementById('watermark');
    const watermarkImage = document.getElementById('watermark-image');

    console.log('[Watermark] Received message:', data);

    if (data.action === 'showWatermark') {
        // Set image source - use nui:// protocol for FiveM resources
        const imagePath = `nui://Watermark/${data.image}`;
        console.log('[Watermark] Loading image:', imagePath);
        watermarkImage.src = imagePath;
        
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
        console.log('[Watermark] Watermark displayed');
        
        // Log if image fails to load
        watermarkImage.onerror = function() {
            console.error('[Watermark] Failed to load image:', imagePath);
        };
        
        watermarkImage.onload = function() {
            console.log('[Watermark] Image loaded successfully');
        };
        
    } else if (data.action === 'hideWatermark') {
        watermark.classList.remove('visible');
        console.log('[Watermark] Watermark hidden');
    }
});
