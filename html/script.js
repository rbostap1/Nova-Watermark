console.log('[Watermark] Control Center loaded');

// ==================== State Management ====================
let currentOffsetX = 20;
let currentOffsetY = 20;
let watermarkWidth = 150;
let watermarkHeight = 150;
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

// ==================== Message Handling ====================
window.addEventListener('message', function(event) {
    const data = event.data;
    console.log('[Watermark] Received action:', data.action);

    if (data.action === 'showWatermark') {
        handleShowWatermark(data);
    } else if (data.action === 'hideWatermark') {
        handleHideWatermark();
    } else if (data.action === 'openHUD') {
        handleOpenHUD(data);
    } else if (data.action === 'closeHUD') {
        handleCloseHUD();
    } else if (data.action === 'updateOpacity') {
        handleUpdateOpacity(data);
    } else if (data.action === 'syncState') {
        handleSyncState(data);
    }
});

function handleShowWatermark(data) {
    const watermark = document.getElementById('watermark');
    const watermarkImage = document.getElementById('watermark-image');

    currentOffsetX = data.offsetX;
    currentOffsetY = data.offsetY;
    watermarkWidth = data.width;
    watermarkHeight = data.height;

    const imagePath = `nui://Watermark/${data.image}`;
    console.log('[Watermark] Loading image:', imagePath);
    
    watermarkImage.src = imagePath;
    watermarkImage.style.width = data.width + 'px';
    watermarkImage.style.height = data.height + 'px';
    watermarkImage.style.opacity = data.opacity;

    watermark.style.right = data.offsetX + 'px';
    watermark.style.top = data.offsetY + 'px';
    watermark.classList.add('visible');

    watermarkImage.onerror = () => console.error('[Watermark] Failed to load:', imagePath);
    watermarkImage.onload = () => console.log('[Watermark] Image loaded successfully');
}

function handleHideWatermark() {
    const watermark = document.getElementById('watermark');
    watermark.classList.remove('visible');
    console.log('[Watermark] Watermark hidden');
}

function handleOpenHUD(data) {
    const state = data.state || { enabled: true, opacity: 0.8 };
    const overlay = document.getElementById('hud-overlay');
    const watermark = document.getElementById('watermark');

    overlay.classList.remove('hidden');
    overlay.classList.add('visible');
    watermark.classList.add('draggable');

    applyHudState(state);
    updateStatusDisplay();
}

function handleCloseHUD() {
    const overlay = document.getElementById('hud-overlay');
    const watermark = document.getElementById('watermark');

    overlay.classList.add('hidden');
    overlay.classList.remove('visible');
    watermark.classList.remove('draggable');
}

function handleUpdateOpacity(data) {
    const opacitySlider = document.getElementById('opacity-slider');
    const watermarkImage = document.getElementById('watermark-image');
    
    watermarkImage.style.opacity = data.opacity;
    opacitySlider.value = Math.round(data.opacity * 100);
    updateOpacityDisplay();
}

function handleSyncState(data) {
    if (type(data.state) === 'table') {
        applyHudState(data.state);
    }
}

function type(val) {
    return Object.prototype.toString.call(val).slice(8, -1).toLowerCase();
}

// ==================== HUD State Application ====================
function applyHudState(state) {
    hudState.enabled = typeof state.enabled === 'boolean' ? state.enabled : hudState.enabled;
    hudState.opacity = typeof state.opacity === 'number' ? state.opacity : hudState.opacity;
    hudState.offsetX = typeof state.offsetX === 'number' ? state.offsetX : hudState.offsetX;
    hudState.offsetY = typeof state.offsetY === 'number' ? state.offsetY : hudState.offsetY;
    hudState.localHidden = typeof state.localHidden === 'boolean' ? state.localHidden : hudState.localHidden;

    currentOffsetX = hudState.offsetX;
    currentOffsetY = hudState.offsetY;

    // Update UI elements
    const opacitySlider = document.getElementById('opacity-slider');
    if (opacitySlider) {
        opacitySlider.value = Math.round(hudState.opacity * 100);
    }

    updateOpacityDisplay();
    updatePositionDisplay();
    updateToggleButtons();
}

function updateOpacityDisplay() {
    const value = Math.round((hudState.opacity || 0.8) * 100);
    const opacityValue = document.getElementById('opacity-value');
    if (opacityValue) {
        opacityValue.textContent = value + '%';
    }
}

function updatePositionDisplay() {
    const positionDisplay = document.getElementById('position-display');
    const posXInput = document.getElementById('pos-x-input');
    const posYInput = document.getElementById('pos-y-input');

    const x = typeof hudState.offsetX === 'number' ? hudState.offsetX : 0;
    const y = typeof hudState.offsetY === 'number' ? hudState.offsetY : 0;

    if (positionDisplay) {
        positionDisplay.textContent = `X: ${Math.round(x)}, Y: ${Math.round(y)}`;
    }
    if (posXInput) posXInput.value = Math.round(x);
    if (posYInput) posYInput.value = Math.round(y);
}

function updateToggleButtons() {
    const toggleBtn = document.getElementById('toggle-btn');
    const localToggleBtn = document.getElementById('local-toggle-btn');

    if (toggleBtn) {
        const icon = hudState.enabled ? '👁️' : '👁️‍🗨️';
        const text = hudState.enabled ? 'Hide Watermark' : 'Show Watermark';
        toggleBtn.innerHTML = `<span class="btn-icon">${icon}</span>${text}`;
    }

    if (localToggleBtn) {
        const text = hudState.localHidden ? 'Show Locally' : 'Hide Locally';
        localToggleBtn.textContent = text;
    }
}

function updateStatusDisplay() {
    const badge = document.getElementById('visibility-status');
    if (badge) {
        badge.textContent = hudState.enabled ? 'Visible' : 'Hidden';
        badge.classList.toggle('hidden', !hudState.enabled);
    }
}

// ==================== NUI Communication ====================
function postNUI(action, payload) {
    fetch('https://Watermark/' + action, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(payload || {})
    }).catch(err => console.error('[Watermark] NUI call failed:', err));
}

// ==================== Dragging System ====================
function setupDragSystem() {
    const hudCard = document.querySelector('.hud-container');
    const hudHeader = document.querySelector('.hud-header');
    const watermark = document.getElementById('watermark');

    // HUD Header Drag
    hudHeader.addEventListener('mousedown', (e) => {
        if (e.target.closest('.close-btn')) return;
        
        isDraggingHUD = true;
        dragStartX = e.clientX;
        dragStartY = e.clientY;
        
        const rect = hudCard.getBoundingClientRect();
        elementStartX = rect.left;
        elementStartY = rect.top;
        
        hudCard.style.position = 'absolute';
        e.preventDefault();
    });

    // Watermark Drag
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

    // Mouse Move
    document.addEventListener('mousemove', (e) => {
        if (isDraggingHUD) {
            const deltaX = e.clientX - dragStartX;
            const deltaY = e.clientY - dragStartY;
            
            hudCard.style.left = (elementStartX + deltaX) + 'px';
            hudCard.style.top = (elementStartY + deltaY) + 'px';
        }

        if (isDraggingWatermark) {
            const deltaX = e.clientX - dragStartX;
            const deltaY = e.clientY - dragStartY;
            
            const newOffsetX = Math.max(0, elementStartX - deltaX);
            const newOffsetY = Math.max(0, elementStartY + deltaY);
            
            watermark.style.right = newOffsetX + 'px';
            watermark.style.top = newOffsetY + 'px';
            
            currentOffsetX = Math.round(newOffsetX);
            currentOffsetY = Math.round(newOffsetY);
            
            updatePositionDisplay();
            postNUI('hud:updatePosition', { offsetX: currentOffsetX, offsetY: currentOffsetY });
        }
    });

    // Mouse Up
    document.addEventListener('mouseup', () => {
        isDraggingHUD = false;
        isDraggingWatermark = false;
    });
}

// ==================== Tab System ====================
function setupTabs() {
    const tabButtons = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');

    tabButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            const tabName = btn.dataset.tab;

            // Deactivate all tabs
            tabButtons.forEach(b => b.classList.remove('active'));
            tabContents.forEach(c => c.classList.remove('active'));

            // Activate selected tab
            btn.classList.add('active');
            document.getElementById(tabName + '-tab').classList.add('active');
        });
    });
}

// ==================== Event Listeners ====================
document.addEventListener('DOMContentLoaded', () => {
    console.log('[Watermark] Initializing controls');

    // Setup systems
    setupDragSystem();
    setupTabs();

    // Button references
    const toggleBtn = document.getElementById('toggle-btn');
    const localToggleBtn = document.getElementById('local-toggle-btn');
    const refreshBtn = document.getElementById('refresh-btn');
    const syncBtn = document.getElementById('sync-btn');
    const closeBtn = document.getElementById('hud-close');
    const saveBtn = document.getElementById('save-btn');
    const resetBtn = document.getElementById('reset-btn');
    const cancelBtn = document.getElementById('cancel-btn');
    const posXInput = document.getElementById('pos-x-input');
    const posYInput = document.getElementById('pos-y-input');
    const posApplyBtn = document.getElementById('pos-apply-btn');
    const opacitySlider = document.getElementById('opacity-slider');

    // Toggle Watermark (Server-Wide)
    if (toggleBtn) {
        toggleBtn.addEventListener('click', () => {
            console.log('[Watermark] Toggling server-wide visibility');
            postNUI('hud:toggle', {});
        });
    }

    // Toggle Local Hidden
    if (localToggleBtn) {
        localToggleBtn.addEventListener('click', () => {
            console.log('[Watermark] Toggling local visibility');
            postNUI('hud:toggleLocal', {});
        });
    }

    // Refresh Display
    if (refreshBtn) {
        refreshBtn.addEventListener('click', () => {
            console.log('[Watermark] Refreshing display');
            postNUI('hud:refresh', {});
        });
    }

    // Sync State
    if (syncBtn) {
        syncBtn.addEventListener('click', () => {
            console.log('[Watermark] Syncing state from server');
            postNUI('hud:syncState', {});
        });
    }

    // Close HUD
    if (closeBtn) {
        closeBtn.addEventListener('click', () => {
            console.log('[Watermark] Closing HUD');
            postNUI('hud:close', {});
        });
    }

    // Cancel (same as close)
    if (cancelBtn) {
        cancelBtn.addEventListener('click', () => {
            console.log('[Watermark] Canceling - closing HUD');
            postNUI('hud:close', {});
        });
    }

    // Save Settings to Config
    if (saveBtn) {
        saveBtn.addEventListener('click', () => {
            console.log('[Watermark] Saving settings to config');
            postNUI('hud:saveState', {});
        });
    }

    // Reset to Defaults
    if (resetBtn) {
        resetBtn.addEventListener('click', () => {
            console.log('[Watermark] Resetting to defaults');
            postNUI('hud:resetDefaults', {});
        });
    }

    // Position Input
    if (posApplyBtn) {
        posApplyBtn.addEventListener('click', () => {
            const xVal = parseInt(posXInput.value, 10);
            const yVal = parseInt(posYInput.value, 10);
            
            if (Number.isFinite(xVal) && Number.isFinite(yVal)) {
                currentOffsetX = Math.max(0, Math.min(10000, xVal));
                currentOffsetY = Math.max(0, Math.min(10000, yVal));
                console.log('[Watermark] Applying position:', currentOffsetX, currentOffsetY);
                postNUI('hud:updatePosition', { offsetX: currentOffsetX, offsetY: currentOffsetY });
            }
        });
    }

    // Opacity Slider
    if (opacitySlider) {
        opacitySlider.addEventListener('input', (e) => {
            const value = parseInt(e.target.value, 10);
            const normalized = Math.max(0, Math.min(100, value)) / 100;
            console.log('[Watermark] Setting opacity:', normalized);
            postNUI('hud:setOpacity', { opacity: normalized });
            updateOpacityDisplay();
        });
    }

    console.log('[Watermark] Controls initialized');
});
