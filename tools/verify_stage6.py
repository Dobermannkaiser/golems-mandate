#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path
from PIL import Image

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
    return set(re.findall(
        r"(?m)^\s*(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(",
        clean,
    ))


def inherited_functions(path: Path, seen: set[Path] | None = None) -> set[str]:
    if seen is None:
        seen = set()
    if path in seen or not path.is_file():
        return set()
    seen.add(path)
    text = path.read_text(encoding="utf-8")
    result = functions_in(text)
    match = re.search(r'^extends\s+"res://([^"]+)"', text, re.M)
    if match:
        result |= inherited_functions(ROOT / match.group(1), seen)
    return result


def validate_scripts() -> None:
    all_functions: set[str] = set()
    for path in ROOT.rglob("*.gd"):
        all_functions |= functions_in(path.read_text(encoding="utf-8"))

    for path in sorted(ROOT.rglob("*.gd")):
        rel = path.relative_to(ROOT).as_posix()
        text = path.read_text(encoding="utf-8")
        clean = strip_comments_and_strings(text)
        error = delimiter_error(text)
        check(f"Delimitadores: {rel}", error is None, error or "ok")

        funcs = re.findall(
            r"(?m)^\s*(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(",
            clean,
        )
        duplicates = sorted({name for name in funcs if funcs.count(name) > 1})
        check(f"Funções únicas: {rel}", not duplicates, ", ".join(duplicates) or "ok")

        bad_draw = sorted(name for name in funcs if name.startswith("draw_"))
        check(
            f"Sem override nativo draw_*: {rel}",
            not bad_draw,
            ", ".join(bad_draw) or "ok",
        )

        callbacks = re.findall(r"\.connect\(\s*([A-Za-z_][A-Za-z0-9_]*)", clean, re.S)
        available = inherited_functions(path)
        missing = sorted({
            cb for cb in callbacks
            if cb not in available and cb not in {"queue_free", "hide", "show"}
        })
        check(f"Callbacks existem: {rel}", not missing, ", ".join(missing) or "ok")

        for target in re.findall(r'preload\(\s*"res://([^"]+)"\s*\)', text, re.S):
            check(f"Preload existe: {rel} -> {target}", (ROOT / target).is_file(), target)

        for target in re.findall(
            r'"res://([^"\n]+\.(?:gd|tscn|png|jpg|jpeg|webp|ttf|otf|tres))"',
            text,
        ):
            check(f"Recurso existe: {rel} -> {target}", (ROOT / target).is_file(), target)

        leading_spaces = [
            i + 1 for i, line in enumerate(text.splitlines())
            if line.startswith(" ") and line.strip()
        ]
        check(
            f"Indentação por tab: {rel}",
            not leading_spaces,
            str(leading_spaces[:8]) if leading_spaces else "ok",
        )

    medieval = read("scripts/MedievalTheme.gd")
    allowed_medieval_calls = functions_in(medieval)
    used_medieval_calls: set[str] = set()
    for path in ROOT.rglob("*.gd"):
        used_medieval_calls |= set(re.findall(
            r"MedievalTheme\.([A-Za-z_][A-Za-z0-9_]*)\s*\(",
            path.read_text(encoding="utf-8"),
        ))
    unknown = sorted(used_medieval_calls - allowed_medieval_calls)
    check("Chamadas MedievalTheme válidas", not unknown, ", ".join(unknown) or "ok")


def validate_resources() -> None:
    script_path = ROOT / "scripts/dialogue/CharacterDefinition.gd"
    for path in sorted((ROOT / "characters").glob("*.tres")):
        rel = path.relative_to(ROOT).as_posix()
        text = path.read_text(encoding="utf-8")
        check(f"Cadastro referencia script: {rel}", "CharacterDefinition.gd" in text)
        for portrait in re.findall(r'portrait_path = "res://([^"]+)"', text):
            check(f"Retrato do cadastro existe: {rel}", (ROOT / portrait).is_file(), portrait)
        check(f"Cadastro possui ID: {rel}", bool(re.search(r'character_id = "[^"]+"', text)))
    check("Script CharacterDefinition existe", script_path.is_file())

    portrait_dir = ROOT / "assets/dialogue/portraits"
    portraits = sorted(portrait_dir.glob("*.png"))
    check("Dez bustos incorporados", len(portraits) == 10, str(len(portraits)))
    for portrait in portraits:
        with Image.open(portrait) as image:
            rgba = image.convert("RGBA")
            alpha = rgba.getchannel("A")
            has_transparency = alpha.getextrema()[0] == 0
            check(
                f"Retrato com transparência: {portrait.name}",
                has_transparency,
                str(alpha.getextrema()),
            )

    check("Fonte Alagard incorporada", (ROOT / "assets/dialogue/alagard.ttf").is_file())


def validate_stage6() -> None:
    project = read("project.godot")
    villager = read("scripts/Villager.gd")
    game_manager = read("scripts/GameManager.gd")
    event_manager = read("scripts/events/EventManager.gd")
    event_catalog = read("scripts/events/EventCatalog.gd")
    magical_catalog = read("scripts/events/MagicalEventCatalog.gd")
    ui = read("scripts/UIManager.gd")
    variant = read("scripts/UIManagerVariantB.gd")
    save_manager = read("scripts/save/SaveManager.gd")

    check("Versão 2.6.1", 'config/version="2.6.1"' in project)
    check("Layout aprovado permanece ativo", "res://scripts/UIManagerVariantB.gd" in read("scenes/main.tscn"))
    check("Save v4 preservado", "const SAVE_VERSION: int = 4" in save_manager)
    check("Caminho de save compatível preservado", "v2_4_2_save.json" in save_manager)

    names_match = re.search(r"const POSSIBLE_NAMES.*?= \[(.*?)\n\]", villager, re.S)
    names = re.findall(r'"([^"]+)"', names_match.group(1)) if names_match else []
    check("Quarenta nomes aleatórios", len(names) == 40, str(len(names)))
    check("Sorteio de nomes sem repetição", "get_unique_random_names" in villager and "founder_names" in game_manager)

    base_events = len(re.findall(r"(?m)^\s*events\.append\(\{", event_catalog))
    magical_events = len(re.findall(r'(?m)^\t\t\t"id": "[^"]+"', magical_catalog))
    check("Vinte acontecimentos originais", base_events == 20, str(base_events))
    check("Vinte acontecimentos mágicos novos", magical_events == 20, str(magical_events))
    check("Quarenta acontecimentos totais", base_events + magical_events == 40, str(base_events + magical_events))
    check("Catálogo mágico anexado", "MAGICAL_EVENT_CATALOG_SCRIPT.create()" in event_catalog)
    check("Chance de evento reduzida em 25%", "const EVENT_CHANCE: float = 0.525" in event_manager)

    check("Retrato persistente exportado", '"portrait_id": portrait_id' in villager)
    check("Retrato persistente importado", 'save_data.get("portrait_id"' in villager)
    check("Fundadores recebem retratos únicos", "founder_portraits.shuffle()" in game_manager and "used_portraits" in game_manager)
    check("Mimo recebe retrato fixo", 'helper.portrait_id = "mimo"' in game_manager)
    check("Saves antigos recebem retratos", "_ensure_roster_portraits" in game_manager)

    for rel in [
        "scripts/dialogue/CharacterDefinition.gd",
        "scripts/dialogue/CharacterCatalog.gd",
        "scripts/dialogue/DialogueManager.gd",
        "scripts/dialogue/DialogueCatalog.gd",
        "scripts/ui/DialogueWindow.gd",
        "scripts/diagnostics/InternalDiagnostics.gd",
        "scripts/ui/DiagnosticsWindow.gd",
    ]:
        check(f"Componente Etapa 6 existe: {rel}", (ROOT / rel).is_file())

    check("Diálogo criado pela interface", "_create_dialogue_window()" in ui)
    check("Segundo clique abre conversa", "selected_villager == villager" in ui and "_open_dialogue_for_villager" in ui)
    check("Histórico de conversa disponível", "HISTÓRICO" in read("scripts/ui/DialogueWindow.gd"))
    check("Fallback de retrato disponível", "portrait_fallback" in read("scripts/ui/DialogueWindow.gd"))
    check("Prefeito sem retrato", '"speaker_id": "prefeito"' in read("scripts/dialogue/DialogueManager.gd"))
    check("Mimo possui diálogo próprio", "_create_mimo_conversation" in read("scripts/dialogue/DialogueCatalog.gd"))
    check("Personalidade de Mimo preservada", "jovem aperitivo" in read("scripts/dialogue/DialogueCatalog.gd"))

    check("Teste interno acessível", "TESTE INTERNO" in variant)
    check("Janela de diagnóstico integrada", "show_internal_diagnostics" in ui)
    check("Teste de diálogo integrado", "dialogue_test_requested" in read("scripts/ui/DiagnosticsWindow.gd"))
    check("Catálogo de personagens validado", "validate_catalog" in read("scripts/dialogue/CharacterCatalog.gd"))
    check("Catálogo de eventos validado", "_validate_events" in read("scripts/diagnostics/InternalDiagnostics.gd"))
    check("Grafos de diálogo validados", "validate_conversation" in read("scripts/diagnostics/InternalDiagnostics.gd"))

    check("Fonte pixel usada nos diálogos", "assets/dialogue/alagard.ttf" in read("scripts/ui/DialogueWindow.gd"))
    check("Fonte pixel usada nos eventos", "assets/dialogue/alagard.ttf" in read("scripts/ui/EventWindow.gd"))
    check("Eventos apresentados como presságios", "PRESSÁGIO DA VILA" in read("scripts/ui/EventWindow.gd"))
    check("Sem função inexistente create_button", "MedievalTheme.create_button" not in "\n".join(
        p.read_text(encoding="utf-8") for p in ROOT.rglob("*.gd")
    ))

    diagnostics_text = read("scripts/diagnostics/InternalDiagnostics.gd")
    check(
        "Diagnóstico permite chance fixa sem atributo",
        "if requires_villager:" in diagnostics_text
        and "elif not test_attribute.is_empty():" in diagnostics_text,
    )
    check(
        "Quatro escolhas fixas continuam sem teste de atributo",
        all(token in (event_catalog + magical_catalog) for token in [
            '"id": "taste_berries"',
            '"id": "well_ask_treasure"',
            '"id": "broom_open"',
            '"id": "mimic_feed"',
        ]),
    )


def main() -> int:
    validate_scripts()
    validate_resources()
    validate_stage6()
    failed = [r for r in RESULTS if not r.ok]
    for result in RESULTS:
        status = "OK" if result.ok else "FALHA"
        suffix = f" — {result.detail}" if result.detail else ""
        print(f"[{status}] {result.name}{suffix}")
    print(f"\nResumo: {len(RESULTS)} verificações, {len(failed)} falha(s).")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
