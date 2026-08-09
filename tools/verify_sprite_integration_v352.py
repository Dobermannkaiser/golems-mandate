#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import sys

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]

ASSETS = {
    "Silo de Reserva": "assets/buildings/variants/barn_silo.png",
    "Cozinha Comunitária": "assets/buildings/variants/barn_kitchen.png",
    "Serraria Intensiva": "assets/buildings/variants/sawmill_intensive.png",
    "Oficina de Carpintaria": "assets/buildings/variants/sawmill_carpentry.png",
    "Reservatório Profundo": "assets/buildings/variants/well_reservoir.png",
    "Fonte Comunitária": "assets/buildings/variants/well_fountain.png",
    "Mercado Comunitário": "assets/buildings/variants/square_market.png",
    "Jardim Público": "assets/buildings/variants/square_garden.png",
    "Bastião de Pedra": "assets/buildings/variants/palisade_bastion.png",
    "Portões Vigilantes": "assets/buildings/variants/palisade_gates.png",
}


@dataclass
class Result:
    name: str
    ok: bool
    detail: str = ""


results: list[Result] = []


def check(name: str, ok: bool, detail: str = "") -> None:
    results.append(Result(name, bool(ok), detail))


def read(relative: str) -> str:
    return (ROOT / relative).read_text(encoding="utf-8")


def validate_version() -> None:
    check("Versão pública 3.8.2", 'config/version="3.8.2"' in read("project.godot"))
    check("Menu mostra 3.8.2", '"3.8.2"' in read("scripts/ui/MainMenu.gd"))
    check("Layout mostra v3.8.2", "v3.8.2" in read("scripts/UIManagerVariantB.gd"))
    check(
        "Diagnóstico exige 3.8.2",
        'project_version != "3.8.2"' in read("scripts/diagnostics/InternalDiagnostics.gd"),
    )
    check("Save continua na versão 17", "const SAVE_VERSION: int = 17" in read("scripts/save/SaveManager.gd"))


def validate_references() -> None:
    catalog = read("scripts/buildings/BuildingVariantCatalog.gd")
    visuals = read("scripts/ui/BuildingVisuals.gd")
    for name, relative in ASSETS.items():
        res_path = "res://" + relative
        check(f"Catálogo referencia {name}", res_path in catalog)
        check(f"Vila referencia {name}", res_path in visuals)
    active_text = catalog + "\n" + visuals
    check("Nenhuma build referencia JPG", ".jpg" not in active_text.lower())


def validate_images() -> None:
    for name, relative in ASSETS.items():
        path = ROOT / relative
        check(f"Arquivo existe — {name}", path.is_file(), relative)
        if not path.is_file():
            continue
        try:
            with Image.open(path) as image:
                check(f"Formato PNG — {name}", image.format == "PNG", str(image.format))
                check(f"Resolução 352x240 — {name}", image.size == (352, 240), str(image.size))
                check(f"Canal RGBA — {name}", image.mode == "RGBA", image.mode)
                if image.mode != "RGBA":
                    continue
                alpha = image.getchannel("A")
                low, high = alpha.getextrema()
                check(f"Transparência real — {name}", low == 0 and high == 255, f"{low}-{high}")
                data = list(alpha.get_flattened_data())
                transparent = sum(value == 0 for value in data)
                opaque = sum(value == 255 for value in data)
                total = len(data)
                ratio = transparent / total if total else 0.0
                check(
                    f"Fundo removido — {name}",
                    0.08 <= ratio <= 0.80,
                    f"{ratio:.1%} transparente; {opaque}/{total} opacos",
                )
                corners = [
                    alpha.getpixel((0, 0)),
                    alpha.getpixel((351, 0)),
                    alpha.getpixel((0, 239)),
                    alpha.getpixel((351, 239)),
                ]
                check(f"Cantos transparentes — {name}", all(value == 0 for value in corners), str(corners))
                bbox = alpha.getbbox()
                check(f"Conteúdo visível — {name}", bbox is not None, str(bbox))
        except Exception as exc:
            check(f"Imagem legível — {name}", False, str(exc))


def main() -> int:
    validate_version()
    validate_references()
    validate_images()

    failures = [result for result in results if not result.ok]
    for result in results:
        marker = "OK" if result.ok else "FALHA"
        detail = f" — {result.detail}" if result.detail else ""
        print(f"[{marker}] {result.name}{detail}")

    print(f"\nTotal: {len(results)} verificações; {len(failures)} falhas.")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
