const RESOURCE_NAME = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'Watermark';

const ui = {
    overlay: null,
    watermark: null,
    watermarkImage: null,
    visibilityStatus: null,
    visibilityChip: null,
    stateValue: null,
    opacityValue: null,
    opacityReadout: null,
    canvasValue: null,
    opacitySlider: null,
    posXInput: null,
    posYInput: null,
    widthInput: null,
    heightInput: null,
    toggleButton: null,
    layoutApplyButton: null,
    syncButton: null,
    refreshButton: null,
    resetButton: null,
    closeButton: null,
    footerCloseButton: null
};

const state = {
    enabled: true,
    opacity: 0.5,
    offsetX: 28,
    offsetY: 20,
    width: 150,
    height: 150,
    image: 'images/placeholder.jpg',
    hudOpen: false
};

function postNUI(action, payload = {}) {
    return fetch(`https://${RESOURCE_NAME}/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(payload)
    }).catch(() => null);
}

function clamp(value, minimum, maximum) {
    return Math.min(maximum, Math.max(minimum, value));
}

function syncState(nextState = {}) {
    if (typeof nextState.enabled === 'boolean') {
        state.enabled = nextState.enabled;
    }

    if (typeof nextState.opacity === 'number') {
        state.opacity = clamp(nextState.opacity, 0, 1);
    }

    if (typeof nextState.offsetX === 'number') {
        state.offsetX = clamp(Math.round(nextState.offsetX), 0, 10000);
    }

    if (typeof nextState.offsetY === 'number') {
        state.offsetY = clamp(Math.round(nextState.offsetY), 0, 10000);
    }

    if (typeof nextState.width === 'number') {
        state.width = clamp(Math.round(nextState.width), 20, 2000);
    }

    if (typeof nextState.height === 'number') {
        state.height = clamp(Math.round(nextState.height), 20, 2000);
    }

    if (typeof nextState.image === 'string' && nextState.image !== '') {
        state.image = nextState.image;
    }
}

function cacheElements() {
    ui.overlay = document.getElementById('hud-overlay');
    ui.watermark = document.getElementById('watermark');
    ui.watermarkImage = document.getElementById('watermark-image');
    ui.visibilityStatus = document.getElementById('visibility-status');
    ui.visibilityChip = document.getElementById('visibility-chip');
    ui.stateValue = document.getElementById('state-value');
    ui.opacityValue = document.getElementById('opacity-value');
    ui.opacityReadout = document.getElementById('opacity-readout');
    ui.canvasValue = document.getElementById('canvas-value');
    ui.opacitySlider = document.getElementById('opacity-slider');
    ui.posXInput = document.getElementById('pos-x-input');
    ui.posYInput = document.getElementById('pos-y-input');
    ui.widthInput = document.getElementById('width-input');
    ui.heightInput = document.getElementById('height-input');
    ui.toggleButton = document.getElementById('toggle-btn');
    ui.layoutApplyButton = document.getElementById('layout-apply-btn');
    ui.syncButton = document.getElementById('sync-btn');
    ui.refreshButton = document.getElementById('refresh-btn');
    ui.resetButton = document.getElementById('reset-btn');
    ui.closeButton = document.getElementById('hud-close');
    ui.footerCloseButton = document.getElementById('cancel-btn');
}

function applyWatermarkStyles() {
    ui.watermark.style.right = `${state.offsetX}px`;
    ui.watermark.style.top = `${state.offsetY}px`;
    ui.watermarkImage.style.width = `${state.width}px`;
    ui.watermarkImage.style.height = `${state.height}px`;
    ui.watermarkImage.style.opacity = String(state.opacity);
}

function updateSliderVisual() {
    const percent = Math.round(state.opacity * 100);
    ui.opacitySlider.value = String(percent);
    ui.opacitySlider.style.background = `linear-gradient(90deg, var(--accent-strong) 0%, var(--accent) ${percent}%, rgba(255,255,255,0.08) ${percent}%, rgba(255,255,255,0.08) 100%)`;
}

function renderDashboard() {
    const percent = Math.round(state.opacity * 100);
    const layoutSummary = `${state.offsetX}, ${state.offsetY} · ${state.width} x ${state.height}`;

    ui.visibilityStatus.textContent = state.enabled ? 'Enabled' : 'Hidden';
    ui.visibilityChip.textContent = state.enabled ? 'Visible' : 'Hidden';
    ui.visibilityChip.classList.toggle('is-danger', !state.enabled);
    ui.stateValue.textContent = state.enabled ? 'Enabled' : 'Hidden';
    ui.opacityValue.textContent = `${percent}%`;
    ui.opacityReadout.textContent = `${percent}%`;
    ui.canvasValue.textContent = layoutSummary;
    ui.toggleButton.textContent = state.enabled ? 'Hide Watermark' : 'Show Watermark';
    ui.posXInput.value = String(state.offsetX);
    ui.posYInput.value = String(state.offsetY);
    ui.widthInput.value = String(state.width);
    ui.heightInput.value = String(state.height);

    updateSliderVisual();
    applyWatermarkStyles();
}

function handleWatermarkVisibility() {
    ui.watermark.classList.toggle('is-visible', state.enabled);
    ui.watermark.setAttribute('aria-hidden', state.enabled ? 'false' : 'true');
}

function renderState(nextState = {}) {
    syncState(nextState);
    handleWatermarkVisibility();
    renderDashboard();

    if (state.hudOpen) {
        ui.overlay.classList.remove('hidden');
        ui.overlay.classList.add('visible');
    }
}

function openHud(newState = {}) {
    state.hudOpen = true;
    syncState(newState);
    ui.overlay.classList.remove('hidden');
    ui.overlay.classList.add('visible');
    renderDashboard();
}

function closeHud() {
    state.hudOpen = false;
    ui.overlay.classList.add('hidden');
    ui.overlay.classList.remove('visible');
}

function parseInputValue(element, minimum, maximum) {
    const parsed = Number.parseInt(element.value, 10);
    return clamp(Number.isNaN(parsed) ? minimum : parsed, minimum, maximum);
}

function submitLayout() {
    const payload = {
        offsetX: parseInputValue(ui.posXInput, 0, 10000),
        offsetY: parseInputValue(ui.posYInput, 0, 10000),
        width: parseInputValue(ui.widthInput, 20, 2000),
        height: parseInputValue(ui.heightInput, 20, 2000)
    };

    syncState(payload);
    renderDashboard();
    postNUI('hud:updateLayout', payload);
}

function handleMessage(event) {
    const data = event.data || {};

    if (data.action === 'showWatermark') {
        syncState(data.state || {});

        if (state.image) {
            ui.watermarkImage.src = `nui://${RESOURCE_NAME}/${state.image}`;
        }

        handleWatermarkVisibility();
        renderDashboard();
        return;
    }

    if (data.action === 'hideWatermark') {
        ui.watermark.classList.remove('is-visible');
        ui.watermark.setAttribute('aria-hidden', 'true');
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

    if (data.action === 'syncState' && data.state) {
        renderState(data.state);
    }
}

function setupHandlers() {
    ui.toggleButton.addEventListener('click', () => {
        const nextEnabled = !state.enabled;
        syncState({ enabled: nextEnabled });
        renderDashboard();
        postNUI('hud:toggle');
    });

    ui.opacitySlider.addEventListener('input', () => {
        const nextOpacity = clamp((Number.parseInt(ui.opacitySlider.value, 10) || 0) / 100, 0, 1);
        syncState({ opacity: nextOpacity });
        renderDashboard();
    });

    ui.opacitySlider.addEventListener('change', () => {
        postNUI('hud:setOpacity', { opacity: state.opacity });
    });

    ui.layoutApplyButton.addEventListener('click', submitLayout);

    ui.syncButton.addEventListener('click', () => {
        postNUI('hud:syncState');
    });

    ui.refreshButton.addEventListener('click', () => {
        postNUI('hud:refresh');
    });

    ui.resetButton.addEventListener('click', () => {
        postNUI('hud:resetDefaults');
        setTimeout(() => postNUI('hud:syncState'), 150);
    });

    ui.closeButton.addEventListener('click', () => {
        postNUI('hud:close');
    });

    ui.footerCloseButton.addEventListener('click', () => {
        postNUI('hud:close');
    });

    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape' && state.hudOpen) {
            postNUI('hud:close');
        }
    });
}

document.addEventListener('DOMContentLoaded', () => {
    cacheElements();
    setupHandlers();
    renderState();
    window.addEventListener('message', handleMessage);
});