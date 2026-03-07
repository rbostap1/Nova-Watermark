const RESOURCE_NAME = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'Watermark';

const ui = {
    overlay: null,
    hud: null,
    watermark: null,
    watermarkImage: null,
    opacitySlider: null,
    opacityValue: null,
    statusBadge: null,
    positionDisplay: null,
    posXInput: null,
    posYInput: null,
    toggleBtn: null,
    localToggleBtn: null
};

const state = {
    enabled: true,
    localHidden: false,
    opacity: 0.8,
    offsetX: 20,
    offsetY: 20,
    width: 150,
    height: 150,
    isHudOpen: false,
    isDraggingHud: false,
    isDraggingWatermark: false,
    dragStartX: 0,
    dragStartY: 0,
    baseX: 0,
    baseY: 0,
    rafTicking: false,
    pendingX: 20,
    pendingY: 20
};

function postNUI(action, payload = {}) {
    return fetch(`https://${RESOURCE_NAME}/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(payload)
    }).catch(() => null);
}

function clamp(value, min, max) {
    return Math.min(max, Math.max(min, value));
}

function applyWatermarkStyles() {
    ui.watermark.style.right = `${state.offsetX}px`;
    ui.watermark.style.top = `${state.offsetY}px`;
    ui.watermarkImage.style.width = `${state.width}px`;
    ui.watermarkImage.style.height = `${state.height}px`;
    ui.watermarkImage.style.opacity = String(state.opacity);
}

function renderVisibilityStatus() {
    ui.statusBadge.textContent = state.enabled ? 'Visible' : 'Hidden';
    ui.statusBadge.classList.toggle('hidden', !state.enabled);

    ui.toggleBtn.innerHTML = state.enabled
        ? '<span class="btn-icon" aria-hidden="true">SV</span>Hide Watermark'
        : '<span class="btn-icon" aria-hidden="true">SV</span>Show Watermark';

    ui.localToggleBtn.innerHTML = state.localHidden
        ? '<span class="btn-icon" aria-hidden="true">LC</span>Show Locally'
        : '<span class="btn-icon" aria-hidden="true">LC</span>Hide Locally';
}

function renderOpacity() {
    const percent = Math.round(state.opacity * 100);
    ui.opacitySlider.value = String(percent);
    ui.opacityValue.textContent = `${percent}%`;
}

function renderPosition() {
    const x = Math.round(state.offsetX);
    const y = Math.round(state.offsetY);
    ui.positionDisplay.textContent = `X: ${x}, Y: ${y}`;
    ui.posXInput.value = String(x);
    ui.posYInput.value = String(y);
}

function renderAll() {
    applyWatermarkStyles();
    renderVisibilityStatus();
    renderOpacity();
    renderPosition();
}

function queueDragRender(x, y) {
    state.pendingX = x;
    state.pendingY = y;

    if (state.rafTicking) {
        return;
    }

    state.rafTicking = true;
    requestAnimationFrame(() => {
        state.rafTicking = false;
        state.offsetX = state.pendingX;
        state.offsetY = state.pendingY;
        applyWatermarkStyles();
        renderPosition();
    });
}

function openHud(newState = {}) {
    state.isHudOpen = true;
    syncState(newState);
    ui.overlay.classList.remove('hidden');
    ui.overlay.classList.add('visible');
    ui.watermark.classList.add('draggable');
    renderAll();
}

function closeHud() {
    state.isHudOpen = false;
    ui.overlay.classList.add('hidden');
    ui.overlay.classList.remove('visible');
    ui.watermark.classList.remove('draggable');
}

function syncState(next) {
    if (typeof next.enabled === 'boolean') {
        state.enabled = next.enabled;
    }
    if (typeof next.localHidden === 'boolean') {
        state.localHidden = next.localHidden;
    }
    if (typeof next.opacity === 'number') {
        state.opacity = clamp(next.opacity, 0, 1);
    }
    if (typeof next.offsetX === 'number') {
        state.offsetX = clamp(next.offsetX, 0, 10000);
    }
    if (typeof next.offsetY === 'number') {
        state.offsetY = clamp(next.offsetY, 0, 10000);
    }
    if (typeof next.width === 'number') {
        state.width = clamp(next.width, 20, 2000);
    }
    if (typeof next.height === 'number') {
        state.height = clamp(next.height, 20, 2000);
    }
}

function switchTab(tabName) {
    document.querySelectorAll('.tab-btn').forEach((btn) => {
        btn.classList.toggle('active', btn.dataset.tab === tabName);
    });

    document.querySelectorAll('.tab-content').forEach((content) => {
        content.classList.toggle('active', content.id === `${tabName}-tab`);
    });
}

function setupTabHandlers() {
    document.querySelectorAll('.tab-btn').forEach((btn) => {
        btn.addEventListener('click', () => {
            switchTab(btn.dataset.tab);
        });
    });
}

function setupDragHandlers() {
    const dragHandle = document.getElementById('hud-drag-handle');

    dragHandle.addEventListener('mousedown', (event) => {
        if (event.target.closest('button')) {
            return;
        }

        const rect = ui.hud.getBoundingClientRect();
        state.isDraggingHud = true;
        state.dragStartX = event.clientX;
        state.dragStartY = event.clientY;
        state.baseX = rect.left;
        state.baseY = rect.top;

        ui.hud.style.position = 'absolute';
        ui.hud.style.left = `${state.baseX}px`;
        ui.hud.style.top = `${state.baseY}px`;
        event.preventDefault();
    });

    ui.watermark.addEventListener('mousedown', (event) => {
        if (!state.isHudOpen) {
            return;
        }

        state.isDraggingWatermark = true;
        state.dragStartX = event.clientX;
        state.dragStartY = event.clientY;
        state.baseX = state.offsetX;
        state.baseY = state.offsetY;
        event.preventDefault();
    });

    document.addEventListener('mousemove', (event) => {
        if (state.isDraggingHud) {
            const nextLeft = state.baseX + (event.clientX - state.dragStartX);
            const nextTop = state.baseY + (event.clientY - state.dragStartY);
            ui.hud.style.left = `${nextLeft}px`;
            ui.hud.style.top = `${nextTop}px`;
            return;
        }

        if (state.isDraggingWatermark) {
            const nextX = clamp(Math.round(state.baseX - (event.clientX - state.dragStartX)), 0, 10000);
            const nextY = clamp(Math.round(state.baseY + (event.clientY - state.dragStartY)), 0, 10000);
            queueDragRender(nextX, nextY);
        }
    });

    document.addEventListener('mouseup', () => {
        if (state.isDraggingWatermark) {
            postNUI('hud:updatePosition', { offsetX: state.offsetX, offsetY: state.offsetY });
        }

        state.isDraggingHud = false;
        state.isDraggingWatermark = false;
    });
}

function setupControlHandlers() {
    document.getElementById('toggle-btn').addEventListener('click', () => {
        postNUI('hud:toggle');
    });

    document.getElementById('local-toggle-btn').addEventListener('click', () => {
        postNUI('hud:toggleLocal');
    });

    document.getElementById('refresh-btn').addEventListener('click', () => {
        postNUI('hud:refresh');
    });

    document.getElementById('sync-btn').addEventListener('click', () => {
        postNUI('hud:syncState');
    });

    document.getElementById('reset-btn').addEventListener('click', () => {
        postNUI('hud:resetDefaults').then(() => {
            setTimeout(() => postNUI('hud:syncState'), 250);
        });
    });

    document.getElementById('hud-close').addEventListener('click', () => {
        postNUI('hud:close');
    });

    document.getElementById('cancel-btn').addEventListener('click', () => {
        postNUI('hud:close');
    });

    document.getElementById('pos-apply-btn').addEventListener('click', () => {
        const x = clamp(Number.parseInt(ui.posXInput.value, 10) || 0, 0, 10000);
        const y = clamp(Number.parseInt(ui.posYInput.value, 10) || 0, 0, 10000);
        state.offsetX = x;
        state.offsetY = y;
        renderPosition();
        applyWatermarkStyles();
        postNUI('hud:updatePosition', { offsetX: x, offsetY: y });
    });

    ui.opacitySlider.addEventListener('input', () => {
        const value = clamp((Number.parseInt(ui.opacitySlider.value, 10) || 0) / 100, 0, 1);
        state.opacity = value;
        renderOpacity();
        ui.watermarkImage.style.opacity = String(value);
        postNUI('hud:setOpacity', { opacity: value });
    });

    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape' && state.isHudOpen) {
            postNUI('hud:close');
        }
    });
}

function handleNuiMessage(event) {
    const data = event.data || {};

    if (data.action === 'showWatermark') {
        syncState({
            opacity: data.opacity,
            offsetX: data.offsetX,
            offsetY: data.offsetY,
            width: data.width,
            height: data.height
        });

        if (data.image) {
            ui.watermarkImage.src = `nui://${RESOURCE_NAME}/${data.image}`;
        }

        ui.watermark.classList.add('visible');
        renderAll();
        return;
    }

    if (data.action === 'hideWatermark') {
        ui.watermark.classList.remove('visible');
        return;
    }

    if (data.action === 'openHUD') {
        openHud(data.state || {});
        return;
    }

    if (data.action === 'closeHUD') {
        closeHud();
        return;
    }

    if (data.action === 'updateOpacity') {
        syncState({ opacity: data.opacity });
        renderOpacity();
        applyWatermarkStyles();
        return;
    }

    if (data.action === 'syncState' && data.state) {
        syncState(data.state);
        renderAll();
    }
}

function cacheElements() {
    ui.overlay = document.getElementById('hud-overlay');
    ui.hud = document.querySelector('.hud-container');
    ui.watermark = document.getElementById('watermark');
    ui.watermarkImage = document.getElementById('watermark-image');
    ui.opacitySlider = document.getElementById('opacity-slider');
    ui.opacityValue = document.getElementById('opacity-value');
    ui.statusBadge = document.getElementById('visibility-status');
    ui.positionDisplay = document.getElementById('position-display');
    ui.posXInput = document.getElementById('pos-x-input');
    ui.posYInput = document.getElementById('pos-y-input');
    ui.toggleBtn = document.getElementById('toggle-btn');
    ui.localToggleBtn = document.getElementById('local-toggle-btn');
}

document.addEventListener('DOMContentLoaded', () => {
    cacheElements();
    setupTabHandlers();
    setupDragHandlers();
    setupControlHandlers();
    renderAll();
    window.addEventListener('message', handleNuiMessage);
});
