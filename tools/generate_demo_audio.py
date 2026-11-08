"""Gera exclusivamente os instrumentais originais do catálogo de demonstração.

Somente biblioteca padrão; sem samples, gravações ou downloads de terceiros.
Executar na raiz: python tools/generate_demo_audio.py
"""

from array import array
import hashlib
import json
import math
from pathlib import Path
import random
import sys
import wave

ROOT = Path(__file__).resolve().parents[1]
SAMPLE_RATE = 22050
TRACKS = [
    ("aurora_lofi", "Aurora Lo-Fi", "estudo", 18, 80, 48, "lofi"),
    ("orbita_piano", "Órbita de Piano", "estudo", 20, 88, 50, "piano"),
    ("pulso_neon", "Pulso Neon", "treino", 18, 132, 45, "beat"),
    ("corrida_solar", "Corrida Solar", "treino", 20, 140, 48, "beat"),
    ("fluxo_criativo", "Fluxo Criativo", "trabalho", 18, 100, 52, "lofi"),
    ("mesa_cafe", "Mesa de Café", "trabalho", 20, 96, 53, "piano"),
    ("estrada_azul", "Estrada Azul", "viagem", 18, 108, 48, "synth"),
    ("horizonte_synth", "Horizonte Synth", "viagem", 20, 112, 50, "synth"),
    ("paginas_calmas", "Páginas Calmas", "leitura", 18, 68, 53, "piano"),
    ("jardim_acustico", "Jardim Acústico", "leitura", 20, 72, 55, "piano"),
    ("lua_serena", "Lua Serena", "dormir", 18, 50, 48, "ambient"),
    ("mar_estrelas", "Mar de Estrelas", "dormir", 20, 54, 45, "ambient"),
]


def frequency(midi):
    return 440 * 2 ** ((midi - 69) / 12)


def synthesize(index, seconds, bpm, root_note, style):
    rng = random.Random(7100 + index)
    beat = 60 / bpm
    progression = [0, 5, 9, 7]
    melody = [0, 4, 7, 11, 7, 4, 2, 7]
    samples = []
    for sample in range(seconds * SAMPLE_RATE):
        time = sample / SAMPLE_RATE
        bar = int(time / (beat * 4))
        chord = root_note + progression[bar % len(progression)]
        pad = sum(math.sin(math.tau * frequency(chord + n) * time)
                  for n in (0, 4, 7)) / 3
        pad *= 0.23 + 0.04 * math.sin(math.tau * 0.15 * time)

        step = int(time / (beat / 2))
        age = time % (beat / 2)
        note = frequency(chord + 12 + melody[(step + index) % len(melody)])
        attack = min(age / 0.008, 1)
        decay = math.exp(-age * (7 if style != "ambient" else 2))
        voice = math.sin(math.tau * note * time)
        voice += 0.20 * math.sin(math.tau * note * 2 * time)
        voice += 0.07 * math.sin(math.tau * note * 3 * time)
        lead = voice * attack * decay * (0.20 if style != "ambient" else 0.07)
        bass = math.sin(math.tau * frequency(chord - 12) * time) * 0.11

        drums = 0
        if style in ("lofi", "beat", "synth"):
            beat_age = time % beat
            kick = math.sin(math.tau * (48 * beat_age + 9 * (1 - math.exp(-28 * beat_age))))
            kick *= math.exp(-beat_age * 20) * min(beat_age / 0.003, 1)
            noise = rng.uniform(-1, 1)
            hat_age = time % (beat / 2)
            hat = noise * math.exp(-hat_age * 100) * min(hat_age / 0.002, 1)
            snare = noise * math.exp(-beat_age * 35) if int(time / beat) % 2 else 0
            strength = 0.30 if style == "beat" else 0.12
            drums = strength * kick + 0.04 * hat + strength * 0.30 * snare

        fade = min(time / 0.4, (seconds - time) / 0.6, 1)
        samples.append((pad + lead + bass + drums) * max(0, fade))

    peak = max(abs(value) for value in samples)
    pcm = array("h", (round(value / peak * 22000) for value in samples))
    if sys.byteorder != "little":
        pcm.byteswap()
    return pcm.tobytes()


def main():
    output = ROOT / "assets" / "audio"
    output.mkdir(parents=True, exist_ok=True)
    manifest = []
    for index, (track_id, title, context, seconds, bpm, note, style) in enumerate(TRACKS):
        file = output / f"{track_id}.wav"
        with wave.open(str(file), "wb") as audio:
            audio.setnchannels(1)
            audio.setsampwidth(2)
            audio.setframerate(SAMPLE_RATE)
            audio.writeframes(synthesize(index, seconds, bpm, note, style))
        with wave.open(str(file), "rb") as audio:
            duration_ms = round(audio.getnframes() / audio.getframerate() * 1000)
        manifest.append({
            "id": track_id, "title": title, "artist": "SoundWave Demo",
            "assetPath": file.relative_to(ROOT).as_posix(),
            "contextId": context, "durationMs": duration_ms, "bpm": bpm,
            "sha256": hashlib.sha256(file.read_bytes()).hexdigest(),
        })
    (ROOT / "assets" / "audio_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Geradas {len(manifest)} faixas, {sum(t['durationMs'] for t in manifest)/1000:.0f}s de áudio.")


if __name__ == "__main__":
    main()
