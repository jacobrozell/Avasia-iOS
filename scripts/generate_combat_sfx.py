#!/usr/bin/env python3
"""Generate placeholder combat SFX as .wav files for App/Resources/Audio/."""

from __future__ import annotations

import math
import struct
import wave
from pathlib import Path

SAMPLE_RATE = 44_100
OUT_DIR = Path(__file__).resolve().parents[1] / "App" / "Resources" / "Audio"


def write_wav(path: Path, samples: list[float]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "w") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(SAMPLE_RATE)
        frames = b"".join(
            struct.pack("<h", int(max(-32_767, min(32_767, sample))))
            for sample in samples
        )
        handle.writeframes(frames)


def envelope(t: float, duration: float, attack: float = 0.01, release: float = 0.12) -> float:
    if t < attack:
        return t / attack if attack else 1.0
    if t > duration - release:
        return max(0.0, (duration - t) / release) if release else 0.0
    return 1.0


def sine(freq: float, t: float, amp: float = 1.0) -> float:
    return amp * math.sin(2.0 * math.pi * freq * t)


def noise(t: float, seed: float) -> float:
    return math.sin(t * 12_989.0 + seed * 78_233.0) * 43758.5453 % 1.0 - 0.5


def render(duration: float, fn) -> list[float]:
    count = int(SAMPLE_RATE * duration)
    return [fn(i / SAMPLE_RATE) for i in range(count)]


def hit_sample(t: float) -> float:
    duration = 0.16
    e = envelope(t, duration, 0.001, 0.06)
    body = sine(110, t, 0.55) + sine(70, t, 0.35)
    crack = sine(240, t, 0.25) * math.exp(-t * 40)
    return (body + crack) * e * 22_000


def miss_sample(t: float) -> float:
    duration = 0.22
    e = envelope(t, duration, 0.005, 0.14)
    sweep = sine(900 - t * 2_800, t, 0.35) + sine(500 - t * 1_600, t, 0.2)
    return sweep * e * 16_000


def block_sample(t: float) -> float:
    duration = 0.24
    e = envelope(t, duration, 0.001, 0.16)
    clang = sine(520, t, 0.45) + sine(780, t, 0.25) + sine(1_040, t, 0.15)
    ring = sine(520, t, 0.2) * math.exp(-t * 8)
    return (clang + ring) * e * 18_000


def heal_sample(t: float) -> float:
    duration = 0.42
    e = envelope(t, duration, 0.02, 0.18)
    note_a = sine(440 + t * 180, t, 0.35)
    note_b = sine(660 + t * 120, t, 0.25) * (0.4 + 0.6 * t / duration)
    shimmer = sine(880, t, 0.12) * math.sin(t * 24)
    return (note_a + note_b + shimmer) * e * 14_000


def combat_start_sample(t: float) -> float:
    duration = 0.35
    e = envelope(t, duration, 0.002, 0.12)
    low = sine(180, t, 0.4)
    rise = sine(220 + t * 500, t, 0.35)
    stab = sine(330, t, 0.25) * math.exp(-max(0, t - 0.08) * 18)
    return (low + rise + stab) * e * 17_000


def victory_sample(t: float) -> float:
    duration = 0.55
    e = envelope(t, duration, 0.01, 0.2)
    notes = [392, 494, 587, 784]
    value = 0.0
    for index, freq in enumerate(notes):
        start = index * 0.08
        if t >= start:
            local = t - start
            value += sine(freq, local, 0.28) * math.exp(-local * 4.5)
    return value * e * 15_000


def main() -> None:
    cues = {
        "sfx_hit": render(0.16, hit_sample),
        "sfx_miss": render(0.22, miss_sample),
        "sfx_block": render(0.24, block_sample),
        "sfx_heal": render(0.42, heal_sample),
        "sfx_combat_start": render(0.35, combat_start_sample),
        "sfx_victory": render(0.55, victory_sample),
    }
    for name, samples in cues.items():
        path = OUT_DIR / f"{name}.wav"
        write_wav(path, samples)
        print(f"wrote {path}")


if __name__ == "__main__":
    main()
