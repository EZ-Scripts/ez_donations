'use strict';

let audioCtx = null;

function getAudioCtx() {
    if (!audioCtx) {
        audioCtx = new (window.AudioContext || window.webkitAudioContext)();
    }
    return audioCtx;
}

// ─── Web Audio sound library ──────────────────────────────────────
// All sounds generated procedurally — no external files, no native sound banks needed.

// Mechanical telegraph-key click (used per keystroke)
function playTypeClick() {
    try {
        const ctx = getAudioCtx();
        const len = Math.floor(ctx.sampleRate * 0.022);
        const buf = ctx.createBuffer(1, len, ctx.sampleRate);
        const d   = buf.getChannelData(0);
        for (let i = 0; i < len; i++) {
            d[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / len, 10) * 0.3;
        }
        const src    = ctx.createBufferSource();
        src.buffer   = buf;
        const filter = ctx.createBiquadFilter();
        filter.type  = 'bandpass';
        filter.frequency.value = 3200;
        filter.Q.value         = 0.9;
        const gain       = ctx.createGain();
        gain.gain.value  = 0.55;
        src.connect(filter); filter.connect(gain); gain.connect(ctx.destination);
        src.start();
    } catch (_) {}
}

// Subtle wood-tick (button hover)
function playHoverSound() {
    try {
        const ctx = getAudioCtx();
        const len = Math.floor(ctx.sampleRate * 0.012);
        const buf = ctx.createBuffer(1, len, ctx.sampleRate);
        const d   = buf.getChannelData(0);
        for (let i = 0; i < len; i++) {
            d[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / len, 14) * 0.22;
        }
        const src   = ctx.createBufferSource();
        src.buffer  = buf;
        const gain  = ctx.createGain();
        gain.gain.value = 0.45;
        src.connect(gain); gain.connect(ctx.destination);
        src.start();
    } catch (_) {}
}

// Parchment rustle (UI open)
function playOpenSound() {
    try {
        const ctx = getAudioCtx();
        const dur = 0.18;
        const len = Math.floor(ctx.sampleRate * dur);
        const buf = ctx.createBuffer(1, len, ctx.sampleRate);
        const d   = buf.getChannelData(0);
        for (let i = 0; i < len; i++) {
            d[i] = (Math.random() * 2 - 1) * Math.sin(Math.PI * i / len) * 0.35;
        }
        const src    = ctx.createBufferSource();
        src.buffer   = buf;
        const filter = ctx.createBiquadFilter();
        filter.type  = 'highpass';
        filter.frequency.value = 1000;
        const gain      = ctx.createGain();
        gain.gain.value = 0.55;
        src.connect(filter); filter.connect(gain); gain.connect(ctx.destination);
        src.start();
    } catch (_) {}
}

// Two-note telegraph bell (submit/confirm)
function playSubmitSound() {
    try {
        const ctx = getAudioCtx();
        [660, 880].forEach((freq, i) => {
            const osc  = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.type   = 'sine';
            osc.frequency.value = freq;
            const t = ctx.currentTime + i * 0.11;
            gain.gain.setValueAtTime(0.001, t);
            gain.gain.linearRampToValueAtTime(0.28, t + 0.015);
            gain.gain.exponentialRampToValueAtTime(0.001, t + 0.5);
            osc.connect(gain); gain.connect(ctx.destination);
            osc.start(t); osc.stop(t + 0.55);
        });
    } catch (_) {}
}

// Descending buzz (error / empty submit)
function playErrorSound() {
    try {
        const ctx = getAudioCtx();
        const osc  = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type   = 'sawtooth';
        osc.frequency.setValueAtTime(220, ctx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(75, ctx.currentTime + 0.18);
        gain.gain.setValueAtTime(0.25, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.22);
        osc.connect(gain); gain.connect(ctx.destination);
        osc.start(); osc.stop(ctx.currentTime + 0.25);
    } catch (_) {}
}

// Soft descending note (cancel / close)
function playCancelSound() {
    try {
        const ctx = getAudioCtx();
        const osc  = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type   = 'sine';
        osc.frequency.setValueAtTime(440, ctx.currentTime);
        osc.frequency.linearRampToValueAtTime(300, ctx.currentTime + 0.13);
        gain.gain.setValueAtTime(0.18, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.18);
        osc.connect(gain); gain.connect(ctx.destination);
        osc.start(); osc.stop(ctx.currentTime + 0.22);
    } catch (_) {}
}

// ─── NUI post helper ──────────────────────────────────────────────

function nuiPost(endpoint, data) {
    return fetch(`https://ez_donations/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data || {})
    });
}

// ─── Show / Hide ──────────────────────────────────────────────────

function showUI() {
    const overlay = document.getElementById('overlay');
    const input   = document.getElementById('codeInput');
    input.value   = '';
    input.classList.remove('error');
    overlay.classList.add('active');
    playOpenSound();
    setTimeout(() => input.focus(), 120);
}

function hideUI() {
    document.getElementById('overlay').classList.remove('active');
    document.getElementById('codeInput').blur();
}

// ─── Submit / Cancel ──────────────────────────────────────────────

function submitCode() {
    const input = document.getElementById('codeInput');
    const code  = input.value.trim();

    if (!code) {
        input.classList.add('error');
        playErrorSound();
        setTimeout(() => input.classList.remove('error'), 450);
        input.focus();
        return;
    }

    playSubmitSound();
    nuiPost('redeemCode', { code });
    hideUI();
}

function cancelUI() {
    playCancelSound();
    nuiPost('cancel', {});
    hideUI();
}

// ─── Event listeners ─────────────────────────────────────────────

document.getElementById('redeemBtn').addEventListener('click', submitCode);
document.getElementById('cancelBtn').addEventListener('click', cancelUI);

document.querySelectorAll('.btn').forEach(btn => {
    btn.addEventListener('mouseenter', playHoverSound);
});

document.getElementById('codeInput').addEventListener('keydown', e => {
    if (e.key.length === 1 || e.key === 'Backspace' || e.key === 'Delete') {
        playTypeClick();
    }
});

document.addEventListener('keydown', e => {
    if (!document.getElementById('overlay').classList.contains('active')) return;
    if (e.key === 'Escape') cancelUI();
    else if (e.key === 'Enter') submitCode();
});

// ─── NUI message handler ──────────────────────────────────────────

window.addEventListener('message', e => {
    const data = e.data;
    if (!data || !data.action) return;
    if (data.action === 'show') showUI();
    else if (data.action === 'hide') hideUI();
});
