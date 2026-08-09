#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]

EXPECTED = [
    *sorted((ROOT / "assets/council/portraits").rglob("*.png")),
    *sorted((ROOT / "assets/dialogue/portraits").rglob("*.png")),
]


def main() -> int:
    failures: list[str] = []
    checked = 0
    for path in EXPECTED:
        relative = path.relative_to(ROOT).as_posix()
        if not path.is_file():
            failures.append(f"Arquivo ausente: {relative}")
            continue
        with Image.open(path) as image:
            rgba = image.convert("RGBA")
            checked += 1
            if rgba.size != (768, 768):
                failures.append(f"Resolução inválida: {relative} = {rgba.size}")
            alpha = rgba.getchannel("A")
            extrema = alpha.getextrema()
            if extrema[0] >= 255:
                failures.append(f"Sem transparência: {relative}")
                continue
            pixels = list(alpha.get_flattened_data())
            transparent_ratio = sum(value < 16 for value in pixels) / len(pixels)
            if transparent_ratio < 0.05:
                failures.append(
                    f"Pouco fundo transparente: {relative} = {transparent_ratio:.3f}"
                )
            corner_points = [
                (0, 0), (rgba.width - 1, 0),
                (0, rgba.height - 1), (rgba.width - 1, rgba.height - 1),
            ]
            if max(alpha.getpixel(point) for point in corner_points) > 32:
                failures.append(f"Canto ainda opaco: {relative}")

    print("VERIFICAÇÃO — TRANSPARÊNCIA DOS RETRATOS — v3.2.3")
    print(f"Imagens verificadas: {checked}")
    print(f"Falhas: {len(failures)}")
    if failures:
        for failure in failures:
            print(f"- {failure}")
        return 1
    print("Resultado: APROVADO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
