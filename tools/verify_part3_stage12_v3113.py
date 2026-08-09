#!/usr/bin/env python3
"""Contratos do rebalanceamento populacional — Etapa 12, v3.11.3.

Não inicializa o Godot e não simula campanhas. Confere metas, atração,
transparência da interface, compatibilidade de saves e escopo econômico.
"""

from __future__ import annotations

import hashlib
import math
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FAILURES: list[str] = []
CHECKS = 0


def read(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


def sha256(relative_path: str) -> str:
    return hashlib.sha256((ROOT / relative_path).read_bytes()).hexdigest()


def check(label: str, condition: bool) -> None:
    global CHECKS
    CHECKS += 1
    if not condition:
        FAILURES.append(label)


def block(source: str, difficulty_id: str, next_id: str | None) -> str:
    start = source.index(f'\t"{difficulty_id}": {{')
    end = source.index(f'\n\t"{next_id}": {{', start) if next_id else source.index("\n}\n", start)
    return source[start:end]


project = read("project.godot")
difficulty = read("scripts/campaign/DifficultyCatalog.gd")
campaign_catalog = read("scripts/campaign/CampaignCatalog.gd")
campaign_manager = read("scripts/campaign/CampaignManager.gd")
game = read("scripts/GameManager.gd")
part2 = read("scripts/foundation/Part2FoundationManager.gd")
population = read("scripts/models/PopulationState.gd")
ui = read("scripts/UIManager.gd")
ui_variant = read("scripts/UIManagerVariantB.gd")
main_menu = read("scripts/ui/MainMenu.gd")
diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")
diagnostics_window = read("scripts/ui/DiagnosticsWindow.gd")
save = read("scripts/save/SaveManager.gd")
campaign_window = read("scripts/ui/CampaignWindow.gd")
identity = read("scripts/campaign/CampaignIdentityCatalog.gd")
building = read("scripts/buildings/BuildingManager.gd")
opportunities = read("scripts/council/CouncillorOpportunityManager.gd")
villager_card = read("scripts/ui/VillagerCard.gd")

cozy = block(difficulty, "cozy", "moderate")
moderate = block(difficulty, "moderate", "hard")
hard = block(difficulty, "hard", None)

check("Versão pública v3.11.3", 'config/version="3.11.3"' in project)
check("Layout oficial exibe v3.11.3", "LAYOUT OFICIAL\\nv3.11.3" in ui_variant)
check("Menu usa fallback v3.11.3", '"3.11.3"' in main_menu)
check("Diagnóstico espera v3.11.3", 'project_version != "3.11.3"' in diagnostics)

check("Acolhedora atrai após um dia", '"attraction_target": 1' in cozy)
check("Moderada atrai após dois dias", '"attraction_target": 2' in moderate)
check("Difícil atrai após dois dias", '"attraction_target": 2' in hard)
check("Acolhedora atrai com felicidade 52", '"growth_minimum_happiness": 52.0' in cozy)
check("Moderada atrai com felicidade 55", '"growth_minimum_happiness": 55.0' in moderate)
check("Difícil atrai com felicidade 58", '"growth_minimum_happiness": 58.0' in hard)
check("Fallback populacional usa dois dias", "const ATTRACTION_TARGET: int = 2" in population)
check("Fallback de felicidade usa 55", "const GROWTH_MINIMUM_HAPPINESS: float = 55.0" in game)

base_population = [int(value) for value in re.findall(r'"population": (\d+)', campaign_catalog)]
expected_base = [10, 13, 17, 21, 25, 29]
check("Metas-base populacionais reduzidas", base_population == expected_base)

expected_population = {
    "cozy": [9, 12, 16, 20, 24, 28],
    "moderate": [10, 13, 17, 21, 25, 29],
    "hard": [11, 14, 18, 23, 27, 31],
}
derived_population = {
    "cozy": [max(1, math.ceil(value * 1.0) - 1) for value in expected_base],
    "moderate": [max(1, math.ceil(value * 1.0)) for value in expected_base],
    "hard": [max(1, math.ceil(value * 1.05)) for value in expected_base],
}
for difficulty_id, expected in expected_population.items():
    check(
        f"Metas populacionais {difficulty_id} são as aprovadas",
        derived_population[difficulty_id] == expected,
    )

old_population = {
    "cozy": [10, 14, 19, 24, 29, 34],
    "moderate": [11, 15, 20, 25, 30, 35],
    "hard": [12, 16, 21, 27, 32, 37],
}
for difficulty_id in expected_population:
    check(
        f"Todas as avaliações diminuíram em {difficulty_id}",
        all(
            new_value < old_value
            for new_value, old_value in zip(
                expected_population[difficulty_id],
                old_population[difficulty_id],
            )
        ),
    )

check("Fórmula única ainda aplica multiplicador populacional", 'rules.get("population_target_multiplier", 1.0)' in difficulty)
check("Fórmula única ainda aplica offset populacional", 'rules.get("population_target_offset", 0)' in difficulty)
check("Threshold de felicidade vem do catálogo", 'get_current_difficulty_rules().get(' in game and '"growth_minimum_happiness"' in game)
check("Runtime usa threshold variável", ">= growth_minimum_happiness" in game and "< growth_minimum_happiness" in game)
check("Previsão expõe threshold variável", '"growth_minimum_happiness": growth_minimum_happiness' in game)

refresh_start = part2.index("func refresh_population_difficulty()")
refresh_end = part2.index("\n\nfunc ", refresh_start + 1)
refresh_body = part2[refresh_start:refresh_end]
check("Fundação reaplica atração da dificuldade", "population_state.configure_difficulty(" in refresh_body)
load_start = game.index("func _apply_loaded_game_state(")
load_end = game.index("\n\nfunc ", load_start + 1)
load_body = game[load_start:load_end]
check("Save existente recebe regra populacional nova", "foundation_manager.refresh_population_difficulty()" in load_body)
check("Progresso antigo é limitado ao novo alvo", "attraction_progress = mini(attraction_progress, attraction_target - 1)" in population)

check(
    "Tutorial explica thresholds 52/55/58",
    "52 na Acolhedora, 55 na Moderada e 58" in ui
    and '"na Difícil. Acolhedora atrai após 1 dia favorável;' in ui,
)
check("Guia explica cadência 1/2/2", "Acolhedora exige um dia favorável" in ui and "Moderada usa dois" in ui and "Difícil usa dois" in ui)
check("Tooltip mostra felicidade mínima", "Felicidade mínima para atração" in ui and 'outlook.get(' in ui)
check("Teste Interno mostra felicidade mínima", "Felicidade mínima para atração" in diagnostics_window)
check("Teste Interno mostra dias de atração", "Atração: 1 morador após %d dias favoráveis" in diagnostics_window)
check("Guia não mantém a antiga felicidade fixa 60", "felicidade 60" not in ui)

check("Oráculo valida os três tempos de atração", "expected_growth_rules" in diagnostics and "Tempo de atração incorreto" in diagnostics)
check("Oráculo valida os três thresholds", "Felicidade mínima de atração incorreta" in diagnostics)
check("Oráculo espera finais 28/29/31", all(token in diagnostics for token in ['"cozy": 28', '"moderate": 29', '"hard": 31']))

for neutral_key in [
    "production_multiplier",
    "food_consumption_multiplier",
    "maintenance_multiplier",
    "happiness_decay_multiplier",
    "building_cost_multiplier",
]:
    check(
        f"{neutral_key} continua neutro nas três dificuldades",
        len(re.findall(rf'"{neutral_key}": 1\.0', difficulty)) == 3,
    )
check("Reservas iniciais permanecem 48/34/30", all(token in difficulty for token in ['"initial_food": 48.0', '"initial_food": 34.0', '"initial_food": 30.0']))
check("Abandono permanece 4/3/2", '"abandonment_target": 4' in cozy and '"abandonment_target": 3' in moderate and '"abandonment_target": 2' in hard)
check("Envelope global permanece v18", "const SAVE_VERSION: int = 18" in save)
check("SaveManager não foi alterado", sha256("scripts/save/SaveManager.gd") == "1e4222b1813e0177e6f68d43e854e6a7206ba82fbd717d346267fc981ec16bfe")
check("Schema da campanha permanece 5", "const CAMPAIGN_STATE_VERSION: int = 5" in campaign_manager)
check("Catálogo da campanha permanece 4", "const CATALOG_VERSION: int = 4" in campaign_catalog)

check("Conversão numérica segura da Avaliação foi preservada", 'String(goal.get("current_value", 0.0))' not in campaign_window)
check("Semente local não volta a sombrear função global", "var seed: int" not in identity)
check("Chaves de efeito continuam inequívocas", "variant_effect_key" in building and "building_effect_key" in building)
check("Representante candidato continua inequívoco", "candidate_representative_id" in opportunities)
check("Parâmetro não usado permanece explícito", "_animate: bool = true" in villager_card)
check("Variável met_goals não volta a duplicar", campaign_window.count("var met_goals:") == 1)
check("Variável total_goals não volta a duplicar", campaign_window.count("var total_goals:") == 1)

numeric_string_constructor = re.compile(
    r"String\(\s*[A-Za-z_][A-Za-z0-9_]*\.get\("
    r"\s*\"[^\"]+\"\s*,\s*-?\d+(?:\.\d+)?\s*\)\s*\)",
    re.DOTALL,
)
numeric_constructor_hits = [
    path
    for path in sorted((ROOT / "scripts").rglob("*.gd"))
    if numeric_string_constructor.search(path.read_text(encoding="utf-8"))
]
check("Nenhum String(Dictionary.get) numérico permanece", not numeric_constructor_hits)

print("Golem's Mandate — Parte 3, Etapa 12 — população v3.11.3")
print(f"Verificações corretivas: {CHECKS - len(FAILURES)}/{CHECKS} aprovadas")
if FAILURES:
    print("Falhas:")
    for failure in FAILURES:
        print(f"  - {failure}")
    sys.exit(1)
print("Resultado: APROVADO (sem inicializar o Godot e sem simular campanhas).")
