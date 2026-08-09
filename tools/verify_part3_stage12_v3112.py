#!/usr/bin/env python3
"""Contratos do ajuste Acolhedora — Parte 3, Etapa 12, v3.11.2.

Não inicializa o Godot e não simula campanhas. Confere os números aprovados,
a aplicação das metas, a transparência da interface e a preservação do save.
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


project = read("project.godot")
difficulty = read("scripts/campaign/DifficultyCatalog.gd")
campaign = read("scripts/campaign/CampaignCatalog.gd")
campaign_manager = read("scripts/campaign/CampaignManager.gd")
game = read("scripts/GameManager.gd")
ui = read("scripts/UIManager.gd")
ui_variant = read("scripts/UIManagerVariantB.gd")
main_menu = read("scripts/ui/MainMenu.gd")
diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")
diagnostics_window = read("scripts/ui/DiagnosticsWindow.gd")
save = read("scripts/save/SaveManager.gd")

check("Versão pública v3.11.2", 'config/version="3.11.2"' in project)
check("Layout oficial exibe v3.11.2", "LAYOUT OFICIAL\\nv3.11.2" in ui_variant)
check("Menu usa fallback v3.11.2", '"3.11.2"' in main_menu)
check("Diagnóstico espera v3.11.2", 'project_version != "3.11.2"' in diagnostics)
check("Envelope global permanece v18", "const SAVE_VERSION: int = 18" in save)
check(
    "SaveManager permanece idêntico à v3.11.1",
    sha256("scripts/save/SaveManager.gd")
    == "1e4222b1813e0177e6f68d43e854e6a7206ba82fbd717d346267fc981ec16bfe",
)
check(
    "Metas-base Moderada permanecem idênticas à v3.11.1",
    sha256("scripts/campaign/CampaignCatalog.gd")
    == "dd2f2b270436ec8282d267bbddf3df7fe535e826e3a8729c543ed9d4cad534ec",
)
check(
    "Economia diária permanece idêntica à v3.11.1",
    sha256("scripts/GameManager.gd")
    == "d7e44452902ee698cee28324a745d6ff1b3e0c926a934df73e348f439f2c3d3a",
)

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

for token in [
    '"food_target_multiplier": 0.80',
    '"material_target_multiplier": 0.80',
    '"population_target_multiplier": 1.0',
    '"population_target_offset": -1',
    '"happiness_target_offset": -8.0',
    '"initial_food": 48.0',
    '"initial_material": 22.0',
    '"initial_happiness": 72.0',
    '"crisis_grace_days": 4',
    '"post_crisis_happiness_recovery": 2.0',
    '"attraction_target": 2',
    '"abandonment_target": 4',
]:
    check(f"Regra Acolhedora presente: {token}", token in difficulty)

check(
    "Offset populacional participa da fórmula única de metas",
    '+ int(rules.get("population_target_offset", 0))' in difficulty,
)
check(
    "Duração real da crise aparece na derrota por alimentação",
    '"A vila terminou %d dias consecutivos sem "' in campaign_manager
    and campaign_manager.count("% _get_crisis_limit()") == 2,
)
check(
    "Guia não promete bônus econômicos inexistentes",
    "reduz metas e custos, melhora produção" not in ui
    and "Produção, consumo, manutenção e custos de construção permanecem iguais" in ui,
)
check(
    "Visão interna mostra reservas e tolerância",
    "Reservas iniciais:" in diagnostics_window
    and "Derrota por recurso zerado:" in diagnostics_window,
)

base_targets = [
    (20, 50, 22, 53, 11),
    (40, 75, 38, 55, 15),
    (60, 105, 55, 57, 20),
    (80, 135, 72, 58, 25),
    (100, 165, 82, 55, 30),
    (120, 200, 98, 54, 35),
]
expected_cozy = [
    (20, 40, 18, 45, 10),
    (40, 60, 30, 47, 14),
    (60, 84, 44, 49, 19),
    (80, 108, 58, 50, 24),
    (100, 132, 66, 47, 29),
    (120, 160, 78, 46, 34),
]
derived_cozy = [
    (
        day,
        round(food * 0.80),
        round(material * 0.80),
        max(0, min(100, happiness - 8)),
        max(1, math.ceil(population * 1.0) - 1),
    )
    for day, food, material, happiness, population in base_targets
]
check("As seis metas Acolhedoras derivadas são as aprovadas", derived_cozy == expected_cozy)
check("Dia 20 Acolhedor exige população 10, dentro da moradia inicial", expected_cozy[0][4] == 10)
check("Dia 20 Acolhedor exige 40 alimentação", expected_cozy[0][1] == 40)
check("Dia 20 Acolhedor exige 18 material", expected_cozy[0][2] == 18)
check("Dia 20 Acolhedor exige 45 felicidade", expected_cozy[0][3] == 45)

check("Moderada mantém alimentação inicial 34", '"initial_food": 34.0' in difficulty)
check("Moderada mantém material inicial 12", '"initial_material": 12.0' in difficulty)
check("Moderada mantém felicidade inicial 62", '"initial_happiness": 62.0' in difficulty)
check("Difícil mantém alimentação inicial 30", '"initial_food": 30.0' in difficulty)
check("Difícil mantém material inicial 10", '"initial_material": 10.0' in difficulty)
check("Difícil mantém felicidade inicial 60", '"initial_happiness": 60.0' in difficulty)
check("Schema da campanha permanece 5", "const CAMPAIGN_STATE_VERSION: int = 5" in campaign_manager)
check("Catálogo de campanha permanece 4", "const CATALOG_VERSION: int = 4" in campaign)
check("Save continua guardando apenas o ID da dificuldade", '"difficulty_id"' in save)
check("Novas reservas são usadas somente ao iniciar campanha", 'rules.get("initial_food"' in game and "func start_new_campaign(" in game)

print("Golem's Mandate — Parte 3, Etapa 12 — balanceamento v3.11.2")
print(f"Verificações corretivas: {CHECKS - len(FAILURES)}/{CHECKS} aprovadas")
if FAILURES:
    print("Falhas:")
    for failure in FAILURES:
        print(f"  - {failure}")
    sys.exit(1)
print("Resultado: APROVADO (sem inicializar o Godot e sem simular campanhas).")
