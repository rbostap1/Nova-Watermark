console.log('[Watermark] Script loaded');

window.addEventListener('message', function(event) {
    const data = event.data;
    const watermark = document.getElementById('watermark');
    const watermarkImage = document.getElementById('watermark-image');
    const overlay = document.getElementById('hud-overlay');
    const opacitySlider = document.getElementById('opacity-slider');
    const opacityValue = document.getElementById('opacity-value');
    const toggleBtn = document.getElementById('toggle-btn');
    const refreshBtn = document.getElementById('refresh-btn');
    const closeBtn = document.getElementById('hud-close');

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
    } else if (data.action === 'openHUD') {
        const state = data.state || { enabled: true, opacity: 0.8 };
        overlay.classList.remove('hidden');
        overlay.classList.add('visible');
        opacitySlider.value = Math.round((state.opacity || 0.8) * 100);
        opacityValue.textContent = (opacitySlider.value / 100).toFixed(2);
        toggleBtn.textContent = state.enabled ? 'Hide Logo' : 'Show Logo';
    } else if (data.action === 'closeHUD') {
        overlay.classList.add('hidden');
        overlay.classList.remove('visible');
    } else if (data.action === 'updateOpacity') {
        const opacity = data.opacity;
        watermarkImage.style.opacity = opacity;
        opacitySlider.value = Math.round(opacity * 100);
        opacityValue.textContent = opacity.toFixed(2);
    }
});

// HUD interactions → NUI callbacks
function postNUI(name, payload) {
    fetch('https://Watermark/' + name, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(payload || {})
    });
}

document.addEventListener('DOMContentLoaded', () => {
    const overlay = document.getElementById('hud-overlay');
    const opacitySlider = document.getElementById('opacity-slider');
    const toggleBtn = document.getElementById('toggle-btn');
    const refreshBtn = document.getElementById('refresh-btn');
    const closeBtn = document.getElementById('hud-close');

    if (toggleBtn) {
        toggleBtn.addEventListener('click', () => {
            postNUI('hud:toggle', {});
        });
    }
    if (refreshBtn) {
        refreshBtn.addEventListener('click', () => {
            postNUI('hud:refresh', {});
        });
    }
    if (closeBtn) {
        closeBtn.addEventListener('click', () => {
            postNUI('hud:close', {});
        });
    }
    if (opacitySlider) {
        opacitySlider.addEventListener('input', (e) => {
            const value = parseInt(e.target.value, 10);
            const normalized = Math.max(0, Math.min(100, value)) / 100;
            document.getElementById('opacity-value').textContent = normalized.toFixed(2);
            postNUI('hud:setOpacity', { opacity: normalized });
        });
    }
});
