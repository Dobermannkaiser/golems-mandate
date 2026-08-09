#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
UI_PATH = ROOT / "scripts/UIManager.gd"


@dataclass
class Result:
    name: str
    ok: bool
    detail: str = ""


RESULTS: list[Result] = []


def check(name: str, ok: bool, detail: str = "") -> None:
    RESULTS.append(Result(name, bool(ok), detail))


def extract_function(text: str, name: str) -> str:
    pattern = re.compile(rf"(?m)^func\s+{re.escape(name)}\s*\(")
    match = pattern.search(text)
    if not match:
        return ""
    next_match = re.search(r"(?m)^func\s+", text[match.end():])
    end = match.end() + next_match.start() if next_match else len(text)
    return text[match.start():end]


def position(block: str, token: str) -> int:
    return block.find(token)


def validate_tutorial_fix(text: str) -> None:
    create = extract_function(text, "_create_tutorial_window")
    ensure = extract_function(text, "_ensure_tutorial_window")
    full = extract_function(text, "_show_campaign_tutorial")
    contextual = extract_function(text, "_show_contextual_tutorial")

    check("Criador do tutorial existe", bool(create))
    check(
        "Criador valida a instância antes de add_child",
        position(create, "if not is_instance_valid(tutorial_window):")
        < position(create, "add_child(tutorial_window)")
        and position(create, "if not is_instance_valid(tutorial_window):") >= 0,
    )
    check("Helper de garantia do tutorial existe", bool(ensure))
    check(
        "Helper cria a janela quando necessário",
        "if not is_instance_valid(tutorial_window):" in ensure
        and "_create_tutorial_window()" in ensure,
    )
    check(
        "Helper retorna sucesso somente com instância válida",
        "if is_instance_valid(tutorial_window):" in ensure
        and "return true" in ensure
        and "return false" in ensure,
    )
    check(
        "Tutorial completo garante a janela antes de exibir",
        position(full, "if not _ensure_tutorial_window():")
        < position(full, "tutorial_window.show_tutorial(steps)")
        and position(full, "if not _ensure_tutorial_window():") >= 0,
    )
    check(
        "Tutorial contextual garante a janela antes de exibir",
        position(contextual, "if not _ensure_tutorial_window():")
        < position(contextual, "tutorial_window.show_tutorial(steps)")
        and position(contextual, "if not _ensure_tutorial_window():") >= 0,
    )
    check(
        "Tutorial contextual ainda valida o alvo adiado",
        position(contextual, "if not is_instance_valid(target):")
        < position(contextual, "if not _ensure_tutorial_window():")
        and position(contextual, "if not is_instance_valid(target):") >= 0,
    )


def validate_lazy_inventory(text: str) -> None:
    windows = [
        "event_window",
        "campaign_window",
        "recruitment_window",
        "season_hint_window",
        "building_window",
        "save_window",
        "tutorial_window",
        "council_window",
        "councillor_history_window",
        "forecast_details_window",
        "village_window",
        "dialogue_window",
        "diagnostics_window",
        "relationships_window",
        "profile_setup_window",
    ]

    ready = extract_function(text, "_ready")
    for window in windows:
        check(f"Declaração preservada: {window}", re.search(rf"(?m)^var\s+{window}(?:\s*:|\s*$)", text) is not None)
        check(f"Criador sob demanda existe: {window}", f"func _create_{window}()" in text)
        check(f"{window} não é criado avidamente em _ready", f"_create_{window}()" not in ready)

    check("Menu inicial continua sendo criado em _ready", "_create_main_menu()" in ready)


def validate_opening_paths(text: str) -> None:
    expected: dict[str, tuple[str, str]] = {
        "_on_village_event_started": ("event_window", "_create_event_window()"),
        "_on_campaign_button_pressed": ("campaign_window", "_create_campaign_window()"),
        "_open_pending_recruitment_if_available": ("recruitment_window", "_create_recruitment_window()"),
        "_on_season_hint_available": ("season_hint_window", "_create_season_hint_window()"),
        "_on_building_button_pressed": ("building_window", "_create_building_window()"),
        "_on_save_button_pressed": ("save_window", "_create_save_window()"),
        "_on_council_button_pressed": ("council_window", "_create_council_window()"),
        "_on_card_history_requested": ("councillor_history_window", "_create_councillor_history_window()"),
        "_on_forecast_details_pressed": ("forecast_details_window", "_create_forecast_details_window()"),
        "_on_expand_village_button_pressed": ("village_window", "_create_village_window()"),
        "_on_councillor_level_dialogue_requested": ("dialogue_window", "_create_dialogue_window()"),
        "show_internal_diagnostics": ("diagnostics_window", "_create_diagnostics_window()"),
        "_open_relationships_window": ("relationships_window", "_create_relationships_window()"),
        "_on_main_menu_new_campaign_requested": ("profile_setup_window", "_create_profile_setup_window()"),
    }

    for function_name, (window, creator) in expected.items():
        block = extract_function(text, function_name)
        check(f"Fluxo existe: {function_name}", bool(block))
        check(
            f"{function_name} cria {window} antes do primeiro uso",
            position(block, creator) >= 0
            and position(block, creator) < position(block, f"{window}.")
            and position(block, f"{window}.") >= 0,
            block[:500],
        )


def validate_guarded_callbacks(text: str) -> None:
    expected_guards: dict[str, str] = {
        "_show_building_action_error": "building_window",
        "_on_save_requested": "save_window",
        "_on_load_requested": "save_window",
        "_on_delete_save_requested": "save_window",
        "_sync_village_visuals": "village_window",
        "_on_relationships_changed": "relationships_window",
    }
    for function_name, window in expected_guards.items():
        block = extract_function(text, function_name)
        check(f"Callback existe: {function_name}", bool(block))
        check(
            f"{function_name} protege acesso a {window}",
            f"is_instance_valid({window})" in block,
            block[:500],
        )


def validate_version() -> None:
    project = (ROOT / "project.godot").read_text(encoding="utf-8")
    save = (ROOT / "scripts/save/SaveManager.gd").read_text(encoding="utf-8")
    check("Versão pública é 3.8.2", 'config/version="3.8.2"' in project)
    check("Save permanece na versão 17", "const SAVE_VERSION: int = 17" in save)


def main() -> int:
    text = UI_PATH.read_text(encoding="utf-8")
    validate_tutorial_fix(text)
    validate_lazy_inventory(text)
    validate_opening_paths(text)
    validate_guarded_callbacks(text)
    validate_version()

    failures = [result for result in RESULTS if not result.ok]
    print("Golem's Mandate — verificação das janelas sob demanda — v3.8.2")
    print(f"Verificações: {len(RESULTS)}")
    print(f"Falhas: {len(failures)}")
    for result in failures:
        suffix = f" — {result.detail}" if result.detail else ""
        print(f"[FALHA] {result.name}{suffix}")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
