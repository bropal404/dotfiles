#!/usr/bin/env python3
"""Synthesises the Dune desktop sound set (original, procedural — no samples).

    python3 gen.py          # writes *.wav next to this file

  horn.wav      login      — deep brass-like swell with a throat-chant undertone
  thumper.wav   lock       — the rhythmic sand thumper: thump-thump ... thump-thump
  wind.wav      unlock     — a desert gust sweeping past
  notify.wav    message    — soft metallic tone over a hiss of sand
  shift.wav     screenshot — short sand-slide "shhk"
  low.wav       warning    — low pulse, for critical notifications / low battery
"""
import wave
from pathlib import Path

import numpy as np

SR = 48000
OUT = Path(__file__).resolve().parent
rng = np.random.default_rng(10191)  # the year Paul arrives on Arrakis


def t(sec):
    return np.arange(int(SR * sec)) / SR


def env(n, a, r, curve=2.0):
    """attack/release envelope (seconds) over n samples."""
    e = np.ones(n)
    ai, ri = int(SR * a), int(SR * r)
    if ai:
        e[:ai] = np.linspace(0, 1, ai) ** curve
    if ri:
        e[-ri:] *= np.linspace(1, 0, ri) ** curve
    return e


def _onepole(x, a):
    y = np.empty_like(x)
    acc = 0.0
    for i in range(len(x)):
        acc = (1 - a[i]) * x[i] + a[i] * acc
        y[i] = acc
    return y


def lowpass(x, cutoff, poles=4):
    """cascaded one-pole lowpass (-6 dB/oct per pole); cutoff may be an array (sweep)."""
    cutoff = np.broadcast_to(np.asarray(cutoff, float), x.shape)
    a = np.exp(-2 * np.pi * cutoff / SR)
    for _ in range(poles):
        x = _onepole(x, a)
    return x


def bandpass(x, lo, hi):
    return lowpass(x, hi) - lowpass(lowpass(x, lo), lo)


def saw(f, tt, detune=0.0):
    ph = (f * (1 + detune)) * tt
    return 2 * (ph - np.floor(ph + 0.5))


def reverb(x, decay=1.8, mix=0.35):
    """cheap feedback-comb + allpass reverb, enough for a desert expanse."""
    out = np.copy(x)
    tail = np.zeros(len(x) + int(SR * decay))
    tail[: len(x)] = x
    wet = np.zeros_like(tail)
    for d_ms, g in ((29.7, 0.78), (37.1, 0.76), (41.1, 0.74), (43.7, 0.72)):
        d = int(SR * d_ms / 1000)
        buf = np.copy(tail)
        for i in range(d, len(buf)):
            buf[i] += g * buf[i - d]
        wet += buf
    wet = lowpass(wet / 4, 3500)
    res = (1 - mix) * np.pad(out, (0, len(tail) - len(out))) + mix * wet * 0.25
    return res


def write(name, x, gain=0.85):
    x = x / (np.max(np.abs(x)) + 1e-9) * gain
    data = (x * 32767).astype(np.int16)
    with wave.open(str(OUT / name), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())
    print("wrote", name, f"{len(x)/SR:.2f}s")


# ── horn: stacked detuned saws on a low A, lowpass opening slowly ──
def horn():
    d = 5.0
    tt = t(d)
    f0 = 55.0
    x = sum(saw(f0 * h, tt, dt) * w for h, dt, w in
            ((1, 0, 1.0), (1, 0.004, 0.8), (1.5, -0.003, 0.45), (2, 0.002, 0.5), (0.5, 0, 0.6)))
    # throat-chant formant: narrow band around 700 Hz pulsing slowly
    chant = bandpass(saw(f0 * 2, tt), 600, 820) * (0.5 + 0.5 * np.sin(2 * np.pi * 0.7 * tt))
    sweep = 120 + 1400 * (np.sin(np.pi * np.clip(tt / d, 0, 1)) ** 1.5)
    y = lowpass(x + 0.6 * chant, sweep) * env(len(tt), 1.6, 2.2, 1.6)
    return reverb(y, 2.5, 0.4)


# ── thumper: pitch-dropping sub kick + gritty sand transient, rhythm x-x---x-x ──
def thump():
    d = 0.55
    tt = t(d)
    f = 70 * np.exp(-tt * 6) + 34
    ph = 2 * np.pi * np.cumsum(f) / SR
    body = np.sin(ph) * np.exp(-tt * 7)
    grit = lowpass(rng.standard_normal(len(tt)), 900) * np.exp(-tt * 40) * 0.8
    return body + grit


def thumper():
    beat = thump()
    pattern = [0.0, 0.32, 1.1, 1.42]
    x = np.zeros(int(SR * 2.3))
    for s in pattern:
        i = int(SR * s)
        x[i:i + len(beat)] += beat[: len(x) - i]
    return reverb(x, 1.6, 0.3)


# ── wind: band-limited noise with a moving centre frequency ──
def wind(d=2.2):
    tt = t(d)
    n = rng.standard_normal(len(tt))
    centre = 300 + 900 * np.sin(np.pi * tt / d) ** 2
    y = lowpass(n, centre) - lowpass(n, centre * 0.35)
    y *= env(len(tt), 0.7, 1.1, 1.3)
    return y


# ── notify: two soft sine partials (a fifth) with long decay + sand hiss ──
def notify():
    d = 1.3
    tt = t(d)
    tone = (np.sin(2 * np.pi * 587.3 * tt) + 0.55 * np.sin(2 * np.pi * 880 * tt)
            + 0.15 * np.sin(2 * np.pi * 1761 * tt)) * np.exp(-tt * 4.2)
    tone *= env(len(tt), 0.008, 0.05)
    hiss = bandpass(rng.standard_normal(len(tt)), 2500, 7000) * np.exp(-tt * 9) * 0.25
    return reverb(tone + hiss, 1.2, 0.3)


# ── shift: quick sand slide ──
def shift():
    d = 0.35
    tt = t(d)
    n = rng.standard_normal(len(tt))
    y = bandpass(n, 1500, 6000) * np.exp(-tt * 14) * env(len(tt), 0.004, 0.05)
    return y


# ── low: ominous double pulse ──
def low():
    d = 1.4
    tt = t(d)
    x = np.sin(2 * np.pi * 73.4 * tt) + 0.4 * np.sin(2 * np.pi * 110 * tt)
    pulse = np.exp(-((tt - 0.15) ** 2) / 0.006) + np.exp(-((tt - 0.6) ** 2) / 0.006)
    return reverb(lowpass(x * pulse, 600), 1.5, 0.35)


if __name__ == "__main__":
    write("horn.wav", horn(), 0.8)
    write("thumper.wav", thumper(), 0.9)
    write("wind.wav", wind(), 0.6)
    write("notify.wav", notify(), 0.55)
    write("shift.wav", shift(), 0.5)
    write("low.wav", low(), 0.8)
