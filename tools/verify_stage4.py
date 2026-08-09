#!/usr/bin/env python3
"""Static and data-level validation for Square Village Part 2 Stage 4.

This does not replace launching the project in Godot, but it catches broken
resource paths, delimiter errors, duplicate functions, invalid initial roster
configuration and regressions in the Council/save integration.
"""
from __future__ import annotations

import json
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


def check(name: str, condition: bool, detail: str = "") -> None:
    RESULTS.append(Result(name, bool(condition), detail))


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def strip_comments_and_strings(text: str) -> str:
    """Replace comments/string contents while retaining newlines."""
    out: list[str] = []
    i = 0
    n = len(text)
    quote: str | None = None
    triple = False
    escaped = False
    while i < n:
        c = text[i]
        if quote is not None:
            if triple:
                if text.startswith(quote * 3, i):
                    out.extend("   ")
                    i += 3
                    quote = None
                    triple = False
                    continue
            elif not escaped and c == quote:
                out.append(" ")
                i += 1
                quote = None
                continue
            if c == "\n":
                out.append("\n")
            else:
                out.append(" ")
            if triple:
                i += 1
                continue
            if escaped:
                escaped = False
            elif c == "\\":
                escaped = True
            i += 1
            continue

        if c == "#":
            while i < n and text[i] != "\n":
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
                triple = False
                escaped = False
            continue
        out.append(c)
        i += 1
    if quote is not None:
        raise ValueError("unterminated string")
    return "".join(out)


def delimiter_error(text: str) -> str | None:
    try:
        clean = strip_comments_and_strings(text)
    except ValueError as exc:
        return str(exc)
    pairs = {')': '(', ']': '[', '}': '{'}
    stack: list[tuple[str, int]] = []
    for i, c in enumerate(clean):
        if c in "([{":
            stack.append((c, i))
        elif c in ")]}":
            if not stack or stack[-1][0] != pairs[c]:
                return f"unexpected {c!r} at offset {i}"
            stack.pop()
    if stack:
        c, i = stack[-1]
        return f"unclosed {c!r} at offset {i}"
    return None


def tscn_node_blocks(text: str) -> list[tuple[str, dict[str, str]]]:
    blocks: list[tuple[str, dict[str, str]]] = []
    current_header = ""
    current: dict[str, str] = {}
    for line in text.splitlines():
        if line.startswith("[node "):
            if current_header:
                blocks.append((current_header, current))
            current_header = line
            current = {}
        elif current_header and line and not line.startswith("[") and " = " in line:
            key, value = line.split(" = ", 1)
            current[key.strip()] = value.strip()
        elif line.startswith("[") and current_header:
            blocks.append((current_header, current))
            current_header = ""
            current = {}
    if current_header:
        blocks.append((current_header, current))
    return blocks


def parse_bool(value: str | None, default: bool) -> bool:
    if value is None:
        return default
    return value == "true"


def q(value: str | None) -> str:
    if value is None:
        return ""
    try:
        return json.loads(value)
    except json.JSONDecodeError:
        return value.strip('"')


def validate_gdscript_files() -> None:
    gd_files = sorted(ROOT.rglob("*.gd"))
    check("Há scripts GDScript", bool(gd_files), f"{len(gd_files)} arquivo(s)")
    all_functions: dict[str, list[str]] = {}
    for path in gd_files:
        rel = path.relative_to(ROOT).as_posix()
        try:
            text = path.read_text(encoding="utf-8")
        except Exception as exc:  # pragma: no cover
            check(f"UTF-8: {rel}", False, str(exc))
            continue
        err = delimiter_error(text)
        check(f"Delimitadores: {rel}", err is None, err or "ok")
        funcs = re.findall(r"(?m)^func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(", text)
        duplicates = sorted({name for name in funcs if funcs.count(name) > 1})
        check(f"Funções únicas: {rel}", not duplicates, ", ".join(duplicates) or "ok")
        all_functions[rel] = funcs

        for target in re.findall(r'preload\(\s*"res://([^"]+)"\s*\)', text, flags=re.S):
            target_path = ROOT / target
            check(f"preload existe: {rel} -> {target}", target_path.is_file(), str(target_path))



def validate_custom_class_members() -> None:
    """Catch references such as ClassName.REMOVED_CONSTANT before Godot does."""
    class_members: dict[str, tuple[Path, set[str]]] = {}

    for path in sorted(ROOT.rglob("*.gd")):
        text = strip_comments_and_strings(path.read_text(encoding="utf-8"))
        class_match = re.search(r"(?m)^class_name\s+([A-Za-z_][A-Za-z0-9_]*)", text)
        if class_match is None:
            continue

        members: set[str] = set()
        members.update(re.findall(r"(?m)^\s*const\s+([A-Za-z_][A-Za-z0-9_]*)\s*[:=]", text))
        members.update(re.findall(r"(?m)^\s*var\s+([A-Za-z_][A-Za-z0-9_]*)\s*[:=]", text))
        members.update(re.findall(r"(?m)^\s*(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(", text))
        members.update(re.findall(r"(?m)^\s*signal\s+([A-Za-z_][A-Za-z0-9_]*)", text))
        members.update(re.findall(r"(?m)^\s*enum\s+([A-Za-z_][A-Za-z0-9_]*)\b", text))
        class_members[class_match.group(1)] = (path, members)

    invalid: list[str] = []
    inherited_static_members = {"new"}

    for path in sorted(ROOT.rglob("*.gd")):
        text = strip_comments_and_strings(path.read_text(encoding="utf-8"))
        for class_name, member_name in re.findall(
            r"\b([A-Z][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)\b",
            text,
        ):
            if class_name not in class_members:
                continue
            if member_name in inherited_static_members:
                continue
            declaring_path, members = class_members[class_name]
            if member_name in members:
                continue
            invalid.append(
                "%s: %s.%s (declarada em %s)"
                % (
                    path.relative_to(ROOT).as_posix(),
                    class_name,
                    member_name,
                    declaring_path.relative_to(ROOT).as_posix(),
                )
            )

    check(
        "Referências a membros de classes são válidas",
        not invalid,
        "; ".join(invalid) or "ok",
    )

def validate_scene_resources() -> None:
    for path in sorted(ROOT.rglob("*.tscn")):
        rel = path.relative_to(ROOT).as_posix()
        text = path.read_text(encoding="utf-8")
        err = delimiter_error(text)
        check(f"Delimitadores de cena: {rel}", err is None, err or "ok")
        for target in re.findall(r'path="res://([^"]+)"', text):
            check(
                f"Recurso de cena existe: {rel} -> {target}",
                (ROOT / target).is_file(),
                target,
            )


def validate_initial_roster() -> None:
    text = read("scenes/main.tscn")
    blocks = tscn_node_blocks(text)
    villager_blocks = [
        (header, props)
        for header, props in blocks
        if 'parent="World/Villagers"' in header and 'instance=ExtResource("1_o5qli")' in header
    ]
    ids = [q(props.get("representative_id")) for _, props in villager_blocks]
    active = [
        rid
        for rid, (_, props) in zip(ids, villager_blocks)
        if parse_bool(props.get("is_council_active"), True)
    ]
    reserve = [rid for rid in ids if rid not in active]
    check("Cena possui cinco personagens nomeados", len(villager_blocks) == 5, str(ids))
    check("IDs iniciais são únicos", len(ids) == len(set(ids)) and all(ids), str(ids))
    check("Conselho inicial possui quatro membros", len(active) == 4, str(active))
    check("Reserva inicial possui um membro", reserve == ["passos_leves_faz_tudo"], str(reserve))

    mimo = next((props for _, props in villager_blocks if q(props.get("representative_id")) == "passos_leves_faz_tudo"), None)
    check("Mimo está presente na cena", mimo is not None)
    if mimo is not None:
        check("Mimo começa oculto", mimo.get("visible") == "false", str(mimo.get("visible")))
        check("Mimo começa na reserva", mimo.get("is_council_active") == "false", str(mimo.get("is_council_active")))
        check("Mimo é Passos-Leves", q(mimo.get("species_name")) == "Passos-Leves", q(mimo.get("species_name")))
        check("Mimo é NPC especial", mimo.get("is_special_npc") == "true", str(mimo.get("is_special_npc")))
        check("Mimo possui atributos 6/6/6/6", all(mimo.get(k) == "6" for k in ("strength", "intelligence", "charisma", "agility")), str({k: mimo.get(k) for k in ("strength", "intelligence", "charisma", "agility")}))

    # Data-level swap simulation: outgoing becomes reserve; Mimo enters and inherits profession.
    roster = {
        rid: {
            "active": rid in active,
            "profession": int(props.get("current_profession", "0")),
        }
        for rid, (_, props) in zip(ids, villager_blocks)
    }
    outgoing_id = active[0] if active else ""
    if outgoing_id and "passos_leves_faz_tudo" in roster:
        inherited = roster[outgoing_id]["profession"]
        roster[outgoing_id]["active"] = False
        roster["passos_leves_faz_tudo"]["active"] = True
        roster["passos_leves_faz_tudo"]["profession"] = inherited
        check("Simulação de troca preserva quatro ativos", sum(1 for d in roster.values() if d["active"]) == 4)
        check("Simulação de troca herda a profissão", roster["passos_leves_faz_tudo"]["profession"] == inherited)


def validate_stage4_integration() -> None:
    gm = read("scripts/GameManager.gd")
    villager = read("scripts/Villager.gd")
    ui = read("scripts/UIManager.gd")
    event_ui = read("scripts/ui/EventWindow.gd")
    foundation = read("scripts/foundation/Part2FoundationManager.gd")
    population = read("scripts/models/PopulationState.gd")
    save = read("scripts/save/SaveManager.gd")
    specialists = read("scripts/specialists/SpecialistCatalog.gd")
    project = read("project.godot")

    check("Versão do projeto é 2.4.2", 'config/version="2.4.2"' in project)
    check("Save usa esquema v4", "const SAVE_VERSION: int = 4" in save)
    check("Save corrigido é isolado", "v2_4_2_save.json" in save)
    check("Autoload não acessa current_scene", "get_tree().current_scene" not in gm and ".current_scene" not in gm)
    check("Rotina defeituosa foi removida", "_ensure_initial_roster" not in gm)
    check("Inicialização aguarda IDs da cena", "_initialize_roster_if_ready" in gm and "_has_complete_initial_roster" in gm)
    check("Conselho exige quatro ativos", "ACTIVE_COUNCIL_LIMIT: int = 4" in gm)
    check("Troca gratuita está implementada", "func swap_council_member" in gm and "incoming.set_profession(inherited_profession)" in gm)
    check("Produção filtra Conselho ativo", "not villager.is_council_active" in gm and "calculate_total_production" in gm)
    check("Eventos filtram Conselho ativo", "not villager.is_council_active" in event_ui)
    check("Especialização de 5%", "return 0.05" in villager)
    check("Polivalente é exibido", 'return "Polivalente"' in villager)
    check("Faz-tudo possui bônus de profissão única", 'villager.passive_id == "faz_tudo"' in gm and "personal_multiplier += 0.05" in gm)
    check("Passivas só usam Conselho ativo", "for villager: Villager in get_active_council()" in gm)
    check("Personagens nomeados são protegidos", "protected_named_resident_count" in population and "total_population > protected_named_resident_count" in population)
    check("Previsão usa a contagem protegida real", "and population > protected_named_resident_count" in gm and "VillagePopulationState.REPRESENTATIVE_COUNT" not in gm)
    check("UI do Conselho possui guarda contra duplicação", "if is_instance_valid(council_window):\n\t\treturn" in ui)
    check("Carregamento usa IDs", "var villagers_by_id: Dictionary" in gm and "villagers_by_id[representative_id]" in gm and "loaded_ids" in gm)
    check("Catálogo contém Mimo", 'MIMO_ID: String = "passos_leves_faz_tudo"' in specialists)
    check("Goblin está preparado e invisível", 'GOBLIN_BLACKSMITH_ID: String = "goblin_ferreiro"' in specialists and '"known": false' in specialists and '"visible": false' in specialists)
    check("Relacionamentos preparados são recompostos", "func _ensure_relationship_for_npc" in foundation)

    old_species = []
    for path in ROOT.rglob("*"):
        if not path.is_file() or path.suffix in {".png", ".jpg", ".ogg", ".wav", ".uid"}:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        if re.search(r"nekob[ií]pede", text, re.I):
            old_species.append(path.relative_to(ROOT).as_posix())
    check("Nome antigo da espécie foi removido", not old_species, ", ".join(old_species) or "ok")


def main() -> int:
    validate_gdscript_files()
    validate_custom_class_members()
    validate_scene_resources()
    validate_initial_roster()
    validate_stage4_integration()

    failed = [result for result in RESULTS if not result.ok]
    for result in RESULTS:
        status = "OK" if result.ok else "FALHA"
        suffix = f" — {result.detail}" if result.detail else ""
        print(f"[{status}] {result.name}{suffix}")
    print("\nResumo: %d verificações, %d falha(s)." % (len(RESULTS), len(failed)))
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
