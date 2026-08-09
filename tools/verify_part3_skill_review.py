#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import re
import sys

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


def _relative_luminance(hex_color: str) -> float:
    clean = hex_color.lstrip("#")
    channels = [int(clean[index:index + 2], 16) / 255.0 for index in (0, 2, 4)]

    def linearize(channel: float) -> float:
        if channel <= 0.04045:
            return channel / 12.92
        return ((channel + 0.055) / 1.055) ** 2.4

    red, green, blue = [linearize(channel) for channel in channels]
    return 0.2126 * red + 0.7152 * green + 0.0722 * blue


def _contrast_ratio(first: str, second: str) -> float:
    first_luminance = _relative_luminance(first)
    second_luminance = _relative_luminance(second)
    lighter = max(first_luminance, second_luminance)
    darker = min(first_luminance, second_luminance)
    return (lighter + 0.05) / (darker + 0.05)


def main() -> int:
    project = read("project.godot")
    settings = read("scripts/settings/GameSettings.gd")
    theme = read("scripts/MedievalTheme.gd")
    ui = read("scripts/UIManager.gd")
    variant = read("scripts/UIManagerVariantB.gd")
    menu = read("scripts/ui/MainMenu.gd")
    dialogue = read("scripts/ui/DialogueWindow.gd")
    building_window = read("scripts/ui/BuildingWindow.gd")
    building_visuals = read("scripts/ui/BuildingVisuals.gd")
    diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")
    helper = read("scripts/ui/UIAccessibility.gd")
    save = read("scripts/save/SaveManager.gd")
    campaign = read("scripts/campaign/CampaignCatalog.gd")
    difficulty = read("scripts/campaign/DifficultyCatalog.gd")

    check("Versão da Parte 3 3.1.2", 'config/version="3.1.2"' in project)
    check("Parte 3 usa save v9", "const SAVE_VERSION: int = 9" in save)
    check("Save da Parte 3 está isolado", "golems_mandate_part3_v3_save.json" in save)
    check("Seis avaliações preservadas", all(str(day) in campaign for day in [20, 40, 60, 80, 100, 120]))
    check("Três dificuldades preservadas", all(x in difficulty for x in ["cozy", "moderate", "hard"]))

    check("Helper de acessibilidade incorporado", (ROOT / "scripts/ui/UIAccessibility.gd").is_file())
    for function_name in [
        "remember_focus", "restore_focus_deferred", "focus_first_enabled",
        "configure_button", "configure_input", "mark_feedback",
    ]:
        check(
            f"Contrato de UI: {function_name}",
            re.search(rf"static func {function_name}\s*\(", helper) is not None,
        )

    check("Alvos interativos mínimos", "DEFAULT_TARGET_HEIGHT: float = 40.0" in helper)
    check("Botões usam foco completo", "Control.FOCUS_ALL" in helper)
    check("Feedback não depende só de cor", "[OK]" in helper and "[ATENÇÃO]" in helper)

    check("Schema global de configurações", "SETTINGS_SCHEMA_VERSION: int = 2" in settings)
    for key in ["reduced_motion", "instant_dialogue_text", "enhanced_contrast"]:
        check(f"Preferência persistida: {key}", settings.count(f'"{key}"') >= 3)
    check("Padrões de acessibilidade restauráveis", "restore_accessibility_defaults" in settings)

    check("Paletas sazonais com contraste reforçado", "_get_high_contrast_palette" in theme)
    for season in ["summer", "autumn", "winter"]:
        check(f"Contraste sazonal: {season}", f'"{season}":' in theme)
    check("Foco visual reforçado", "4 if enhanced_contrast else 3" in theme)
    check("LineEdit possui estado de foco", '_configure_line_edits' in theme and '"focus", "LineEdit"' in theme)

    contrast_pairs = [
        ("Texto claro / botão padrão", "#F4E7C6", "#53663D"),
        ("Texto claro / botão reforçado", "#F4E7C6", "#344719"),
        ("Tinta / pergaminho", "#302219", "#E8D3A5"),
        ("Texto claro / painel reforçado", "#F4E7C6", "#452813"),
        ("Acento de inverno / fundo", "#C7EEFF", "#101C24"),
    ]
    for pair_name, foreground, background in contrast_pairs:
        measured = _contrast_ratio(foreground, background)
        check(
            f"Contraste >= 4,5:1: {pair_name}",
            measured >= 4.5,
            f"{measured:.2f}:1",
        )

    check("Menu expõe texto instantâneo", "TEXTO INSTANTÂNEO" in menu)
    check("Menu expõe contraste reforçado", "CONTRASTE REFORÇADO" in menu)
    check("Menu restaura acessibilidade", "RESTAURAR ACESSIBILIDADE" in menu)
    check("Confirmação começa em ação segura", "page_focus_targets[confirmation_page.name] = cancel_button" in menu)
    check("Páginas escolhem foco inicial", "focus_first_enabled(page, preferred)" in menu)

    check("Diálogo respeita texto instantâneo", "GameSettings.instant_dialogue_text" in dialogue)
    check("Diálogo fecha histórico com voltar", "_on_history_close_pressed" in dialogue)
    check("Diálogo foca escolhas", "_focus_current_action" in dialogue)
    check("Diálogo restaura foco anterior", "restore_focus_deferred(previous_focus)" in dialogue)

    modal_files = [
        "BuildingWindow.gd", "CampaignWindow.gd", "CouncilWindow.gd",
        "DiagnosticsWindow.gd", "ProfileSetupWindow.gd",
        "RelationshipsWindow.gd", "SaveWindow.gd", "SeasonHintWindow.gd",
        "VillageWindow.gd",
    ]
    for filename in modal_files:
        text = read(f"scripts/ui/{filename}")
        check(f"Modal restaura foco: {filename}", "restore_focus_deferred" in text)
        check(f"Modal aceita ui_cancel: {filename}", 'is_action_pressed("ui_cancel")' in text)

    council = read("scripts/ui/CouncilWindow.gd")
    check("Conselho possui contrato hide_window", "func hide_window()" in council)
    check("UI usa contrato do Conselho", "council_window.hide_window()" in ui)

    check("Tema reage às configurações", "_on_game_settings_changed" in ui)
    check("Layout oficial respeita contraste", "GameSettings.enhanced_contrast" in variant)
    check("Guia documenta acessibilidade", '"ACESSIBILIDADE"' in ui and "FOCO, CONTRASTE E LEITURA" in ui)
    check("Oráculo valida UX/UI", "_validate_ui_quality" in diagnostics)
    check("Oráculo verifica recurso de acessibilidade", "UIAccessibility.gd" in diagnostics)

    check(
        "Fila usa confirmação específica antes de cancelar",
        "_create_cancel_confirmation" in building_window
        and "_confirm_cancel_order" in building_window,
    )
    check(
        "Cancelamento começa na ação segura",
        "cancel_confirmation_cancel_button.grab_focus.call_deferred()" in building_window,
    )
    check(
        "Esc fecha confirmação antes da janela",
        "_hide_cancel_confirmation()" in building_window
        and 'is_action_pressed("ui_cancel")' in building_window,
    )
    check(
        "Fila comunica previsão e avaliação",
        "Início previsto: dia %d" in building_window and "audit_text" in building_window,
    )
    check(
        "Canteiros são desenhados proceduralmente",
        "_draw_construction_sites" in building_visuals
        and "_draw_single_construction_site" in building_visuals,
    )
    check(
        "Elementos de obra permanecem recortados na vila",
        "clip_contents = true" in building_visuals,
    )
    check(
        "Oráculo não valida nome do projeto",
        "application/config/name" not in diagnostics
        and "Nome público" not in diagnostics,
    )

    failed = [result for result in RESULTS if not result.ok]
    for result in RESULTS:
        status = "OK" if result.ok else "FALHA"
        suffix = f" — {result.detail}" if result.detail else ""
        print(f"[{status}] {result.name}{suffix}")
    print(f"\nResumo: {len(RESULTS)} verificações, {len(failed)} falha(s).")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
