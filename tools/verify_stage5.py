#!/usr/bin/env python3
"""Static validation for Square Village Part 2 Stage 5.

This checker is intentionally focused on errors that prevent the Godot project
from parsing or loading: invalid project-class members, missing resources,
missing signal callbacks, duplicate functions, damaged scenes and missing
Stage 5 visual integration.
"""
from __future__ import annotations

import re
import sys

from PIL import Image
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


@dataclass
class Result:
    name: str
    ok: bool
    detail: str = ""


RESULTS: list[Result] = []


def check(name: str, condition: bool, detail: str = "") -> None:
    RESULTS.append(Result(name, bool(condition), detail))


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def strip_comments_and_strings(text: str) -> str:
    output: list[str] = []
    index = 0
    quote: str | None = None
    triple = False
    escaped = False

    while index < len(text):
        char = text[index]
        if quote is not None:
            if triple and text.startswith(quote * 3, index):
                output.extend("   ")
                index += 3
                quote = None
                triple = False
                continue
            if not triple and not escaped and char == quote:
                output.append(" ")
                index += 1
                quote = None
                continue
            output.append("\n" if char == "\n" else " ")
            if not triple:
                if escaped:
                    escaped = False
                elif char == "\\":
                    escaped = True
            index += 1
            continue

        if char == "#":
            while index < len(text) and text[index] != "\n":
                output.append(" ")
                index += 1
            continue
        if char in {'"', "'"}:
            if text.startswith(char * 3, index):
                output.extend("   ")
                index += 3
                quote = char
                triple = True
            else:
                output.append(" ")
                index += 1
                quote = char
                triple = False
                escaped = False
            continue
        output.append(char)
        index += 1

    if quote is not None:
        raise ValueError("string não terminada")
    return "".join(output)


def delimiter_error(text: str) -> str | None:
    try:
        clean = strip_comments_and_strings(text)
    except ValueError as exc:
        return str(exc)

    pairs = {")": "(", "]": "[", "}": "{"}
    stack: list[tuple[str, int]] = []
    for index, char in enumerate(clean):
        if char in "([{":
            stack.append((char, index))
        elif char in ")]}" :
            if not stack or stack[-1][0] != pairs[char]:
                return f"delimitador inesperado {char!r} no offset {index}"
            stack.pop()
    if stack:
        char, index = stack[-1]
        return f"delimitador {char!r} não fechado no offset {index}"
    return None


def collect_project_classes() -> dict[str, tuple[Path, set[str]]]:
    classes: dict[str, tuple[Path, set[str]]] = {}
    for path in sorted(ROOT.rglob("*.gd")):
        clean = strip_comments_and_strings(path.read_text(encoding="utf-8"))
        match = re.search(r"(?m)^class_name\s+([A-Za-z_][A-Za-z0-9_]*)", clean)
        if match is None:
            continue
        members: set[str] = set()
        members.update(re.findall(r"(?m)^\s*const\s+([A-Za-z_][A-Za-z0-9_]*)\s*[:=]", clean))
        members.update(re.findall(r"(?m)^\s*var\s+([A-Za-z_][A-Za-z0-9_]*)\s*[:=]", clean))
        members.update(re.findall(r"(?m)^\s*(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(", clean))
        members.update(re.findall(r"(?m)^\s*signal\s+([A-Za-z_][A-Za-z0-9_]*)", clean))
        members.update(re.findall(r"(?m)^\s*enum\s+([A-Za-z_][A-Za-z0-9_]*)\b", clean))
        classes[match.group(1)] = (path, members)
    return classes


def validate_gdscript() -> None:
    gd_files = sorted(ROOT.rglob("*.gd"))
    check("Scripts GDScript encontrados", bool(gd_files), f"{len(gd_files)} arquivo(s)")

    for path in gd_files:
        rel = path.relative_to(ROOT).as_posix()
        text = path.read_text(encoding="utf-8")
        error = delimiter_error(text)
        check(f"Delimitadores: {rel}", error is None, error or "ok")

        functions = re.findall(r"(?m)^func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(", text)
        duplicates = sorted({name for name in functions if functions.count(name) > 1})
        check(f"Funções únicas: {rel}", not duplicates, ", ".join(duplicates) or "ok")

        reserved_draw_helpers = sorted(
            name for name in functions
            if name.startswith("draw_")
        )
        check(
            f"Sem conflito com métodos nativos draw_*: {rel}",
            not reserved_draw_helpers,
            ", ".join(reserved_draw_helpers) or "ok",
        )

        clean = strip_comments_and_strings(text)
        handlers = set(functions)
        missing_callbacks: list[str] = []
        for callback in re.findall(r"\.connect\(\s*([A-Za-z_][A-Za-z0-9_]*)", clean, flags=re.S):
            if callback not in handlers and callback not in {"queue_free", "hide", "show"}:
                missing_callbacks.append(callback)
        check(
            f"Callbacks conectados existem: {rel}",
            not missing_callbacks,
            ", ".join(sorted(set(missing_callbacks))) or "ok",
        )

        for target in re.findall(r'preload\(\s*"res://([^"]+)"\s*\)', text, flags=re.S):
            check(
                f"Preload existe: {rel} -> {target}",
                (ROOT / target).is_file(),
                target,
            )

        for target in re.findall(r'"res://([^"\n]+\.(?:png|jpg|jpeg|webp|ttf|otf|gd|tscn|tres))"', text):
            check(
                f"Recurso literal existe: {rel} -> {target}",
                (ROOT / target).is_file(),
                target,
            )


def validate_custom_class_members() -> None:
    classes = collect_project_classes()
    invalid: list[str] = []
    for path in sorted(ROOT.rglob("*.gd")):
        clean = strip_comments_and_strings(path.read_text(encoding="utf-8"))
        for class_name, member_name in re.findall(
            r"\b([A-Z][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)\b",
            clean,
        ):
            if class_name not in classes or member_name == "new":
                continue
            declaring_path, members = classes[class_name]
            if member_name not in members:
                invalid.append(
                    f"{path.relative_to(ROOT).as_posix()}: {class_name}.{member_name} "
                    f"(classe em {declaring_path.relative_to(ROOT).as_posix()})"
                )
    check(
        "Membros de classes do projeto são válidos",
        not invalid,
        "; ".join(invalid) or "ok",
    )



def validate_typed_project_instances() -> None:
    classes = collect_project_classes()
    invalid: list[str] = []
    inherited_members = {
        "add_child", "remove_child", "queue_free", "get_node",
        "get_node_or_null", "is_inside_tree", "get_tree",
        "set_process", "set_physics_process", "show", "hide",
    }

    for path in sorted(ROOT.rglob("*.gd")):
        clean = strip_comments_and_strings(path.read_text(encoding="utf-8"))
        typed_variables = dict(re.findall(
            r"(?m)^\s*var\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*([A-Za-z_][A-Za-z0-9_]*)",
            clean,
        ))
        for variable_name, class_name in typed_variables.items():
            if class_name not in {"VillageWindow", "VillageBuildingVisuals"}:
                continue
            if class_name not in classes:
                continue
            declaring_path, members = classes[class_name]
            pattern = rf"\b{re.escape(variable_name)}\.([A-Za-z_][A-Za-z0-9_]*)"
            for member_name in re.findall(pattern, clean):
                if member_name in members or member_name in inherited_members:
                    continue
                # Theme/layout properties inherited from Control are assignments,
                # not project API calls, and are intentionally ignored here.
                if re.search(
                    rf"\b{re.escape(variable_name)}\.{re.escape(member_name)}\s*=",
                    clean,
                ):
                    continue
                invalid.append(
                    f"{path.relative_to(ROOT).as_posix()}: "
                    f"{variable_name}:{class_name}.{member_name} "
                    f"(classe em {declaring_path.relative_to(ROOT).as_posix()})"
                )

    check(
        "Instâncias tipadas usam membros válidos",
        not invalid,
        "; ".join(sorted(set(invalid))) or "ok",
    )

def validate_scenes() -> None:
    for path in sorted(ROOT.rglob("*.tscn")):
        rel = path.relative_to(ROOT).as_posix()
        text = path.read_text(encoding="utf-8")
        error = delimiter_error(text)
        check(f"Cena íntegra: {rel}", error is None, error or "ok")
        for target in re.findall(r'path="res://([^"]+)"', text):
            check(
                f"Recurso da cena existe: {rel} -> {target}",
                (ROOT / target).is_file(),
                target,
            )


def validate_stage5() -> None:
    project = read("project.godot")
    ui = read("scripts/UIManager.gd")
    visuals = read("scripts/ui/BuildingVisuals.gd")
    village_window = read("scripts/ui/VillageWindow.gd")
    save_manager = read("scripts/save/SaveManager.gd")

    check("Versão do projeto é 2.5.4", 'config/version="2.5.4"' in project)
    check("Base de save continua na versão 4", "const SAVE_VERSION: int = 4" in save_manager)
    check("Save anterior continua compatível", "v2_4_2_save.json" in save_manager)
    check("Função inexistente create_button foi removida", "MedievalTheme.create_button" not in "\n".join([ui, visuals, village_window]))

    check("UI carrega VillageWindow", 'res://scripts/ui/VillageWindow.gd' in ui)
    check("UI carrega BuildingVisuals", 'res://scripts/ui/BuildingVisuals.gd' in ui)
    check("Botão AMPLIAR existe", 'expand_village_button.text = "AMPLIAR"' in ui)
    check("Janela ampliada pode abrir", "func show_village()" in village_window)
    check("Janela ampliada pode fechar", "func hide_window()" in village_window)
    check("Mini-vila e janela usam a mesma sincronização", "func _sync_village_visuals()" in ui and "village_window.refresh(" in ui)

    required_visual_methods = [
        "apply_season",
        "update_buildings",
        "update_population_overview",
        "update_council",
        "set_large_view_enabled",
    ]
    for method in required_visual_methods:
        check(
            f"Visual da vila implementa {method}",
            re.search(rf"(?m)^func\s+{re.escape(method)}\s*\(", visuals) is not None,
        )

    check("Casas possuem limite visual", "HOUSE_VISUAL_LIMIT: int = 12" in visuals)
    check("Moradores comuns possuem movimento", "_start_common_villager_tween" in visuals)
    check("Conselheiros possuem sprites próprios", "_create_council_node" in visuals)
    check("Construções são clicáveis", "signal building_requested" in visuals and "_on_building_button_pressed" in visuals)
    check("Variações sazonais existem", all(season in visuals for season in ['"spring"', '"summer"', '"autumn"', '"winter"']))
    check("Quadrados antigos ficam ocultos", "legacy_villagers_layer.visible = false" in ui)

    expected_assets = [
        "house_level1.png", "house_level2.png", "house_level3.png",
        "barn_level1.png", "barn_level2.png", "barn_level3.png",
        "sawmill_level1.png", "sawmill_level2.png", "sawmill_level3.png",
        "well_level1.png", "well_level2.png", "well_level3.png",
        "square_level1.png", "square_level2.png", "square_level3.png",
        "wall_line.png", "wall_corner.png", "wall_gate.png",
        "ground_spring.png", "ground_summer.png", "ground_autumn.png", "ground_winter.png",
        "cat_01.png", "cat_02.png", "cat_03.png", "cat_04.png",
    ]
    missing_assets = [name for name in expected_assets if not (ROOT / "assets" / "etapa5" / name).is_file()]
    check("Pack visual essencial está completo", not missing_assets, ", ".join(missing_assets) or "ok")

    check("Terreno não usa repetição visível", "STRETCH_TILE" not in visuals)
    check("Caminhos ficam acima do terreno", "ground_rect.show_behind_parent = true" in visuals and "ground_rect.z_index = -20" in visuals)
    check("Sombras escuras sobre prédios foram removidas", 'shadow.name = "Shadow"' not in visuals)
    check("Camadas da vila ficam abaixo dos modais", all(token in visuals for token in [
        "z_index = 0",
        "building_layer.z_index = 0",
        "villager_layer.z_index = 30",
        "_local_depth_for_y(center.y, 10, 24)",
    ]))
    check("Painel da vila recorta sprites", "clip_contents = true" in visuals and "frame.clip_contents = true" in ui)
    check("Camadas internas ocupam o painel inteiro", visuals.count("Control.PRESET_FULL_RECT") >= 3)
    check("Atualizações visuais usam assinaturas de estado", "_last_population_signature" in visuals and "_last_house_signature" in visuals)
    check("Visão ampliada pausa animações ao fechar", "set_simulation_active(false)" in village_window)
    check("Mini-vila possui escala própria", "Vector2(43.0, 43.0)" in visuals)
    check("Vila ampliada possui escala própria", "Vector2(82.0, 82.0)" in visuals)

    alpha_errors: list[str] = []
    for cat_name in ["cat_01.png", "cat_02.png", "cat_03.png", "cat_04.png"]:
        cat_path = ROOT / "assets" / "etapa5" / cat_name
        if not cat_path.is_file():
            alpha_errors.append(f"{cat_name}: ausente")
            continue
        with Image.open(cat_path) as image:
            rgba = image.convert("RGBA")
            alpha_min, alpha_max = rgba.getchannel("A").getextrema()
            if alpha_min != 0 or alpha_max != 255:
                alpha_errors.append(f"{cat_name}: alfa {alpha_min}-{alpha_max}")
    check("Sprites dos moradores possuem transparência real", not alpha_errors, ", ".join(alpha_errors) or "ok")

    ground_errors: list[str] = []
    for season in ["spring", "summer", "autumn", "winter"]:
        ground_path = ROOT / "assets" / "etapa5" / f"ground_{season}.png"
        if not ground_path.is_file():
            ground_errors.append(f"ground_{season}.png: ausente")
            continue
        with Image.open(ground_path) as image:
            if image.width < 512 or image.height < 256:
                ground_errors.append(f"ground_{season}.png: {image.size}")
    check("Terrenos sazonais têm resolução ampla", not ground_errors, ", ".join(ground_errors) or "ok")


def main() -> int:
    validate_gdscript()
    validate_custom_class_members()
    validate_typed_project_instances()
    validate_scenes()
    validate_stage5()

    failed = [result for result in RESULTS if not result.ok]
    for result in RESULTS:
        status = "OK" if result.ok else "FALHA"
        suffix = f" — {result.detail}" if result.detail else ""
        print(f"[{status}] {result.name}{suffix}")
    print(f"\nResumo: {len(RESULTS)} verificações, {len(failed)} falha(s).")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
