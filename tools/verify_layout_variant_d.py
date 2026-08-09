#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


@dataclass
class Result:
    name: str
    ok: bool
    detail: str = ""


RESULTS: list[Result] = []


def check(name: str, ok: bool, detail: str = "") -> None:
    RESULTS.append(Result(name, bool(ok), detail))


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def strip_comments_and_strings(text: str) -> str:
    out: list[str] = []
    i = 0
    quote: str | None = None
    triple = False
    escaped = False
    while i < len(text):
        c = text[i]
        if quote is not None:
            if triple and text.startswith(quote * 3, i):
                out.extend("   ")
                i += 3
                quote = None
                triple = False
                continue
            if not triple and not escaped and c == quote:
                out.append(" ")
                i += 1
                quote = None
                continue
            out.append("\n" if c == "\n" else " ")
            if not triple:
                if escaped:
                    escaped = False
                elif c == "\\":
                    escaped = True
            i += 1
            continue
        if c == "#":
            while i < len(text) and text[i] != "\n":
                out.append(" ")
                i += 1
            continue
        if c in {'"', "'"}:
            if text.startswith(c * 3, i):
                out.extend("   ")
                i += 3
                quote = c
                triple = True
            else:
                out.append(" ")
                i += 1
                quote = c
                escaped = False
            continue
        out.append(c)
        i += 1
    if quote is not None:
        raise ValueError("string não terminada")
    return "".join(out)


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
                return f"delimitador inesperado {char} em {index}"
            stack.pop()
    if stack:
        char, index = stack[-1]
        return f"delimitador {char} não fechado em {index}"
    return None


def functions_in(text: str) -> set[str]:
    clean = strip_comments_and_strings(text)
    return set(re.findall(r"(?m)^\s*(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(", clean))


def validate_scripts() -> None:
    base_functions = functions_in(read("scripts/UIManager.gd"))
    for path in sorted(ROOT.rglob("*.gd")):
        rel = path.relative_to(ROOT).as_posix()
        text = path.read_text(encoding="utf-8")
        error = delimiter_error(text)
        check(f"Delimitadores: {rel}", error is None, error or "ok")

        clean = strip_comments_and_strings(text)
        funcs = re.findall(r"(?m)^\s*func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(", clean)
        duplicates = sorted({name for name in funcs if funcs.count(name) > 1})
        check(f"Funções únicas: {rel}", not duplicates, ", ".join(duplicates) or "ok")

        bad_draw = sorted(name for name in funcs if name.startswith("draw_"))
        check(f"Sem override nativo draw_*: {rel}", not bad_draw, ", ".join(bad_draw) or "ok")

        callbacks = re.findall(r"\.connect\(\s*([A-Za-z_][A-Za-z0-9_]*)", clean, re.S)
        available = set(funcs)
        if rel == "scripts/UIManagerVariantB.gd":
            available |= base_functions
        missing = sorted({cb for cb in callbacks if cb not in available and cb not in {"queue_free", "hide", "show"}})
        check(f"Callbacks existem: {rel}", not missing, ", ".join(missing) or "ok")

        for target in re.findall(r'preload\(\s*"res://([^"]+)"\s*\)', text, re.S):
            check(f"Preload existe: {rel} -> {target}", (ROOT / target).is_file(), target)

        for target in re.findall(r'"res://([^"\n]+\.(?:gd|tscn|png|jpg|jpeg|webp|ttf|otf|tres))"', text):
            check(f"Recurso existe: {rel} -> {target}", (ROOT / target).is_file(), target)

        leading_spaces = [i + 1 for i, line in enumerate(text.splitlines()) if line.startswith(" ") and line.strip()]
        check(f"Indentação sem espaços iniciais: {rel}", not leading_spaces, str(leading_spaces[:8]) if leading_spaces else "ok")


def validate_scenes() -> None:
    for path in sorted(ROOT.rglob("*.tscn")):
        rel = path.relative_to(ROOT).as_posix()
        text = path.read_text(encoding="utf-8")
        error = delimiter_error(text)
        check(f"Cena íntegra: {rel}", error is None, error or "ok")
        for target in re.findall(r'path="res://([^"]+)"', text):
            check(f"Recurso da cena existe: {rel} -> {target}", (ROOT / target).is_file(), target)


def validate_variant() -> None:
    project = read("project.godot")
    scene = read("scenes/main.tscn")
    variant = read("scripts/UIManagerVariantB.gd")
    base_ui = read("scripts/UIManager.gd")
    main_menu = read("scripts/ui/MainMenu.gd")
    visuals = read("scripts/ui/BuildingVisuals.gd")
    save_manager = read("scripts/save/SaveManager.gd")
    council_window = read("scripts/ui/CouncilWindow.gd")

    check("Versão da variante", 'config/version="2.5.4.d"' in project)
    check("Cena principal usa layout B", 'res://scripts/UIManagerVariantB.gd' in scene)
    check("Layout B herda a UI estável", 'extends "res://scripts/UIManager.gd"' in variant)
    check("Save permanece na versão 4", "const SAVE_VERSION: int = 4" in save_manager)
    check("Arquivo de save anterior preservado", "v2_4_2_save.json" in save_manager)
    check("Nenhuma create_button inexistente", "MedievalTheme.create_button" not in "\n".join([variant, base_ui, main_menu]))
    check("Sidebar criada", "func _create_sidebar()" in variant)
    check("Barra superior reduzida", "const TOP_BAR_HEIGHT: float = 92.0" in variant)
    check("Bloco antigo removido do topo", "AVALIAÇÃO & OBRAS" not in variant and "progress_panel" not in variant)
    check("Recursos permanecem no topo", '"POP."' in variant and '"ALIMENT."' in variant and '"MATERIAL"' in variant and '"FELIC."' in variant)
    check("Avaliação criada na lateral", 'campaign_button = _create_sidebar_management_button' in variant)
    check("Obras criada na lateral", 'building_button = _create_sidebar_management_button' in variant)
    check("Função de botão lateral de gestão existe", "func _create_sidebar_management_button(" in variant)

    register_pos = variant.find('sidebar_buttons["register"] = register_button')
    campaign_pos = variant.find('campaign_button = _create_sidebar_management_button')
    building_pos = variant.find('building_button = _create_sidebar_management_button')
    spacer_pos = variant.find('var spacer: Control = Control.new()')
    check(
        "Ordem lateral Registro > Avaliação > Obras > espaço",
        -1 not in {register_pos, campaign_pos, building_pos, spacer_pos}
        and register_pos < campaign_pos < building_pos < spacer_pos,
    )

    check("Área da vila permanece principal", "RESIDENTS_PANEL_WIDTH: float = 366.0" in variant and "village_frame.size_flags_horizontal" in variant)
    check("Registro em aba", 'sidebar_buttons["register"]' in variant and "func _create_register_workspace()" in variant)
    check("Histórico limitado", "LOG_HISTORY_LIMIT: int = 40" in variant)
    check("Configurações em acesso lateral", "func _on_sidebar_settings_pressed()" in variant and "func show_settings(" in main_menu)
    check("Ajuda em acesso lateral", "help_button = _create_sidebar_button" in variant)
    check("Cabeçalho verde redundante ausente", "brand_panel" not in variant and '"◇"' not in variant)
    check("Identificação da variante atualizada", '"LAYOUT B\\nv2.5.4.d"' in variant)
    check("Conselho acima da vila", "z_index = 130" in council_window and "z_as_relative = false" in council_window)
    check("Mini-vila em camada global segura", "building_visuals.z_as_relative = false" in variant)
    check("Rodapé compacto", "BOTTOM_BAR_HEIGHT: float = 82.0" in variant)
    check("Vila ampliada preservada", "_on_expand_village_button_pressed" in variant)
    check("Conselho preservado", "_on_council_button_pressed" in variant)
    check("Simulação pausa fora da aba Vila", 'set_simulation_active(workspace_id == "village")' in variant)
    check("Visual não ultrapassa modais", "villager_layer.z_index = 30" in visuals and "frame.clip_contents = true" in base_ui)
    check("Base estável não foi substituída", 'config/version="2.5.4.d"' not in base_ui)

    required_controls = [
        "day_label", "checkpoint_label", "forecast_status_label",
        "campaign_button", "building_button", "population_label",
        "food_label", "material_label", "happiness_label",
        "forecast_population_label", "forecast_food_label",
        "forecast_material_label", "forecast_happiness_label",
        "residents_panel", "villager_cards", "village_frame",
        "building_visuals", "summary_label", "menu_button",
        "save_button", "advance_day_button", "help_button",
        "council_button", "expand_village_button",
    ]
    missing_controls = [name for name in required_controls if re.search(rf"\b{name}\s*=", variant) is None]
    check("Todos os controles esperados são criados", not missing_controls, ", ".join(missing_controls) or "ok")

    inherited_calls = sorted(set(re.findall(r"\b(_on_[A-Za-z0-9_]+)\b", variant)))
    variant_funcs = functions_in(variant)
    missing_inherited = [name for name in inherited_calls if name not in variant_funcs and name not in functions_in(base_ui)]
    check("Chamadas herdadas existem", not missing_inherited, ", ".join(missing_inherited) or "ok")


def main() -> int:
    validate_scripts()
    validate_scenes()
    validate_variant()
    failed = [r for r in RESULTS if not r.ok]
    for result in RESULTS:
        status = "OK" if result.ok else "FALHA"
        suffix = f" — {result.detail}" if result.detail else ""
        print(f"[{status}] {result.name}{suffix}")
    print(f"\nResumo: {len(RESULTS)} verificações, {len(failed)} falha(s).")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
