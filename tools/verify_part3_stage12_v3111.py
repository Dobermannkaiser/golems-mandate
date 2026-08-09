#!/usr/bin/env python3
"""Regressões corretivas da Parte 3 — Etapa 12 — v3.11.1.

Não inicializa o Godot. Confere o erro de formatação observado no runtime,
os seis avisos relatados pelo compilador e contratos estruturais da candidata.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FAILURES: list[str] = []
CHECKS = 0


def read(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


def check(label: str, condition: bool) -> None:
    global CHECKS
    CHECKS += 1
    if not condition:
        FAILURES.append(label)


def strip_comments_and_strings(text: str) -> str:
    output: list[str] = []
    index = 0
    quote: str | None = None
    escaped = False
    while index < len(text):
        char = text[index]
        if quote is not None:
            if not escaped and char == quote:
                quote = None
            output.append("\n" if char == "\n" else " ")
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
            quote = char
            output.append(" ")
            index += 1
            continue
        output.append(char)
        index += 1
    if quote is not None:
        raise ValueError("string não terminada")
    return "".join(output)


def delimiter_error(text: str) -> str | None:
    try:
        clean = strip_comments_and_strings(text)
    except ValueError as error:
        return str(error)
    expected = {")": "(", "]": "[", "}": "{"}
    stack: list[str] = []
    for char in clean:
        if char in "([{":
            stack.append(char)
        elif char in ")]}":
            if not stack or stack.pop() != expected[char]:
                return f"delimitador inesperado: {char}"
    return None if not stack else f"delimitador não fechado: {stack[-1]}"


project = read("project.godot")
campaign_window = read("scripts/ui/CampaignWindow.gd")
identity = read("scripts/campaign/CampaignIdentityCatalog.gd")
building = read("scripts/buildings/BuildingManager.gd")
opportunities = read("scripts/council/CouncillorOpportunityManager.gd")
villager_card = read("scripts/ui/VillagerCard.gd")
ui_variant = read("scripts/UIManagerVariantB.gd")
main_menu = read("scripts/ui/MainMenu.gd")
diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")
save = read("scripts/save/SaveManager.gd")

check("Versão pública v3.11.1", 'config/version="3.11.1"' in project)
check("Layout oficial exibe v3.11.1", "LAYOUT OFICIAL\\nv3.11.1" in ui_variant)
check("Menu usa fallback v3.11.1", '"3.11.1"' in main_menu)
check("Diagnóstico espera v3.11.1", 'project_version != "3.11.1"' in diagnostics)
check("Envelope global de save permanece v18", "const SAVE_VERSION: int = 18" in save)

check("Formatador de metas existe", "func _format_goal_value(value: Variant) -> String:" in campaign_window)
check("Recurso decimal usa uma casa", 'return "%.1f" % float(value)' in campaign_window)
check("População inteira permanece inteira", 'return "%d" % int(value)' in campaign_window)
check("Fallback usa str seguro", "return str(value)" in campaign_window)
check(
    "Valor atual usa o formatador seguro",
    '_format_goal_value(goal.get("current_value", 0.0))' in campaign_window,
)
check(
    "Projeção usa o formatador seguro",
    '_format_goal_value(goal.get("projected_text", "?"))' in campaign_window,
)
check(
    "Meta usa o formatador seguro",
    '_format_goal_value(goal.get("target_value", 0.0))' in campaign_window,
)
check(
    "Conversão que fechava a tela foi removida",
    'String(goal.get("current_value", 0.0))' not in campaign_window,
)

check("Semente local não sombreia função global", "var seed: int" not in identity)
check("Semente sanitizada tem nome explícito", "var sanitized_seed: int" in identity)
check("Efeito de variante tem nome próprio", "variant_effect_key" in building)
check("Efeito de construção tem nome próprio", "building_effect_key" in building)
check(
    "Candidato não confunde o representante selecionado",
    "candidate_representative_id" in opportunities,
)
check("Parâmetro intencionalmente não usado é explícito", "_animate: bool = true" in villager_card)
check(
    "Só permanece o met_goals usado na preparação",
    campaign_window.count("var met_goals:") == 1,
)
check(
    "Só permanece o total_goals usado na preparação",
    campaign_window.count("var total_goals:") == 1,
)

numeric_string_constructor = re.compile(
    r"String\(\s*[A-Za-z_][A-Za-z0-9_]*\.get\("
    r"\s*\"[^\"]+\"\s*,\s*-?\d+(?:\.\d+)?\s*\)\s*\)",
    re.DOTALL,
)
gdscript_files = sorted((ROOT / "scripts").rglob("*.gd"))
numeric_constructor_hits: list[str] = []
for path in gdscript_files:
    text = path.read_text(encoding="utf-8")
    if numeric_string_constructor.search(text):
        numeric_constructor_hits.append(str(path.relative_to(ROOT)))
    check(
        f"Delimitadores: {path.relative_to(ROOT)}",
        delimiter_error(text) is None,
    )
    function_names = re.findall(
        r"^(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(",
        text,
        re.MULTILINE,
    )
    check(
        f"Funções únicas: {path.relative_to(ROOT)}",
        len(function_names) == len(set(function_names)),
    )

check("Nenhum String(Dictionary.get) numérico permanece", not numeric_constructor_hits)

referenced_paths = set(
    re.findall(
        r'"(res://[^"\n]+)"',
        "\n".join(path.read_text(encoding="utf-8") for path in gdscript_files),
    )
)
missing_paths = [
    path
    for path in referenced_paths
    if not (ROOT / path.removeprefix("res://")).exists()
]
check("Todos os res:// literais existem", not missing_paths)

print("Golem's Mandate — Parte 3, Etapa 12 — correção v3.11.1")
print(f"Verificações estáticas: {CHECKS - len(FAILURES)}/{CHECKS} aprovadas")
if numeric_constructor_hits:
    print("Conversões numéricas perigosas:")
    for path in numeric_constructor_hits:
        print(f"  - {path}")
if missing_paths:
    print("Caminhos res:// ausentes:")
    for path in missing_paths:
        print(f"  - {path}")
if FAILURES:
    print("Falhas:")
    for failure in FAILURES:
        print(f"  - {failure}")
    sys.exit(1)
print("Resultado: APROVADO (sem inicializar o Godot).")
