console.log('[Watermark] Script loaded');

let currentOffsetX = 20;
let currentOffsetY = 20;
let watermarkWidth = 150;
let watermarkHeight = 150;

// Drag state
let isDraggingHUD = false;
let isDraggingWatermark = false;
let dragStartX = 0;
let dragStartY = 0;
let elementStartX = 0;
let elementStartY = 0;
let hudState = {
    enabled: true,
    opacity: 0.8,
    offsetX: 20,
    offsetY: 20,
    localHidden: false
};

window.addEventListener('message', function(event) {
    const data = event.data;
    const watermark = document.getElementById('watermark');
    const watermarkImage = document.getElementById('watermark-image');
    const overlay = document.getElementById('hud-overlay');
    const opacitySlider = document.getElementById('opacity-slider');
    const opacityValue = document.getElementById('opacity-value');
    const toggleBtn = document.getElementById('toggle-btn');
    const positionDisplay = document.getElementById('position-display');
    const localToggleBtn = document.getElementById('local-toggle-btn');

    console.log('[Watermark] Received message:', data);

    if (data.action === 'showWatermark') {
        // Store dimensions and offsets
        currentOffsetX = data.offsetX;
        currentOffsetY = data.offsetY;
        watermarkWidth = data.width;
        watermarkHeight = data.height;
        
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
        applyHudState(state);
        
        // Enable watermark dragging
        watermark.classList.add('draggable');
        
        // Update position display
        if (positionDisplay) {
            positionDisplay.textContent = `X: ${currentOffsetX}, Y: ${currentOffsetY}`;
        }
        
    } else if (data.action === 'closeHUD') {
        overlay.classList.add('hidden');
        overlay.classList.remove('visible');
        
        // Disable watermark dragging
        watermark.classList.remove('draggable');
        
    } else if (data.action === 'updateOpacity') {
        const opacity = data.opacity;
        watermarkImage.style.opacity = opacity;
        opacitySlider.value = Math.round(opacity * 100);
        opacityValue.textContent = opacity.toFixed(2);
    } else if (data.action === 'syncState') {
        applyHudState(data.state || {});
    }
});

function applyHudState(state) {
    const opacitySlider = document.getElementById('opacity-slider');
    const opacityValue = document.getElementById('opacity-value');
    const toggleBtn = document.getElementById('toggle-btn');
    const localToggleBtn = document.getElementById('local-toggle-btn');
    const positionDisplay = document.getElementById('position-display');

    hudState.enabled = typeof state.enabled === 'boolean' ? state.enabled : hudState.enabled;
    hudState.opacity = typeof state.opacity === 'number' ? state.opacity : hudState.opacity;
    hudState.offsetX = typeof state.offsetX === 'number' ? state.offsetX : hudState.offsetX;
    hudState.offsetY = typeof state.offsetY === 'number' ? state.offsetY : hudState.offsetY;
    hudState.localHidden = typeof state.localHidden === 'boolean' ? state.localHidden : hudState.localHidden;

    if (typeof hudState.offsetX === 'number') {
        currentOffsetX = hudState.offsetX;
    }
    if (typeof hudState.offsetY === 'number') {
        currentOffsetY = hudState.offsetY;
    }

    if (opacitySlider) {
        opacitySlider.value = Math.round((hudState.opacity || 0.8) * 100);
    }
    if (opacityValue) {
        const value = opacitySlider ? opacitySlider.value : Math.round((hudState.opacity || 0.8) * 100);
        opacityValue.textContent = (value / 100).toFixed(2);
    }
    if (toggleBtn) {
        toggleBtn.textContent = hudState.enabled ? 'Hide Logo (Server Wide)' : 'Show Logo (Server Wide)';
    }
    if (localToggleBtn) {
        localToggleBtn.textContent = hudState.localHidden ? 'Show (Client Only)' : 'Hide (Client Only)';
    }
    if (positionDisplay) {
        const x = typeof hudState.offsetX === 'number' ? hudState.offsetX : 0;
        const y = typeof hudState.offsetY === 'number' ? hudState.offsetY : 0;
        positionDisplay.textContent = `X: ${Math.round(x)}, Y: ${Math.round(y)}`;
    }
}

// HUD interactions → NUI callbacks
function postNUI(name, payload) {
    fetch('https://Watermark/' + name, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(payload || {})
    });
}

// Make HUD card draggable
function makeDraggable() {
    const hudCard = document.querySelector('.hud-card');
    const hudHeader = document.querySelector('.hud-header');
    const watermark = document.getElementById('watermark');
    
    // HUD Card drag
    hudHeader.addEventListener('mousedown', (e) => {
        if (e.target.closest('.icon-btn')) return; // Don't drag when clicking close button
        
        isDraggingHUD = true;
        dragStartX = e.clientX;
        dragStartY = e.clientY;
        
        const rect = hudCard.getBoundingClientRect();
        elementStartX = rect.left;
        elementStartY = rect.top;
        
        e.preventDefault();
    });
    
    // Watermark drag
    watermark.addEventListener('mousedown', (e) => {
        if (!watermark.classList.contains('draggable')) return;
        
        isDraggingWatermark = true;
        dragStartX = e.clientX;
        dragStartY = e.clientY;
        
        const rect = watermark.getBoundingClientRect();
        elementStartX = window.innerWidth - rect.right;
        elementStartY = rect.top;
        
        e.preventDefault();
    });
    
    document.addEventListener('mousemove', (e) => {
        if (isDraggingHUD) {
            const deltaX = e.clientX - dragStartX;
            const deltaY = e.clientY - dragStartY;
            
            hudCard.style.position = 'absolute';
            hudCard.style.left = (elementStartX + deltaX) + 'px';
            hudCard.style.top = (elementStartY + deltaY) + 'px';
        }
        
        if (isDraggingWatermark) {
            const deltaX = e.clientX - dragStartX;
            const deltaY = e.clientY - dragStartY;
            
            // Calculate new position (right and top)
            const newOffsetX = Math.max(0, elementStartX - deltaX);
            const newOffsetY = Math.max(0, elementStartY + deltaY);
            
            watermark.style.right = newOffsetX + 'px';
            watermark.style.top = newOffsetY + 'px';
            
            // Update stored values
            currentOffsetX = Math.round(newOffsetX);
            currentOffsetY = Math.round(newOffsetY);
            
            // Update position display
            const positionDisplay = document.getElementById('position-display');
            if (positionDisplay) {
                positionDisplay.textContent = `X: ${currentOffsetX}, Y: ${currentOffsetY}`;
            }
            
            // Send update to client
            postNUI('hud:updatePosition', { 
                offsetX: currentOffsetX, 
                offsetY: currentOffsetY 
            });
        }
    });
    
    document.addEventListener('mouseup', () => {
        isDraggingHUD = false;
        isDraggingWatermark = false;
    });
}

document.addEventListener('DOMContentLoaded', () => {
    const opacitySlider = document.getElementById('opacity-slider');
    const toggleBtn = document.getElementById('toggle-btn');
    const refreshBtn = document.getElementById('refresh-btn');
    const syncBtn = document.getElementById('sync-btn');
    const closeBtn = document.getElementById('hud-close');
    const saveBtn = document.getElementById('save-btn');
    const resetBtn = document.getElementById('reset-btn');
    const localToggleBtn = document.getElementById('local-toggle-btn');
    const cancelBtn = document.getElementById('cancel-btn');

    makeDraggable();

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
    if (syncBtn) {
        syncBtn.addEventListener('click', () => {
            postNUI('hud:syncState', {});
        });
    }
      if (cancelBtn) {
          cancelBtn.addEventListener('click', () => {
              postNUI('hud:close', {});
          });
      }
      if (localToggleBtn) {
          localToggleBtn.addEventListener('click', () => {
              postNUI('hud:toggleLocal', {});
          });
      }
    if (saveBtn) {
        saveBtn.addEventListener('click', () => {
            postNUI('hud:saveState', {});
        });
    }
    if (resetBtn) {
        resetBtn.addEventListener('click', () => {
            postNUI('hud:resetDefaults', {});
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
