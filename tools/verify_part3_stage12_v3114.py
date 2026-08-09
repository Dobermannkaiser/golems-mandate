#!/usr/bin/env python3
"""Contratos do rebalanceamento de inverno — Etapa 12, v3.11.4.

Não inicializa o Godot e não simula campanhas. Confere a redução exata da
pressão sazonal, a fonte única da regra, a transparência e o escopo econômico.
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


def dictionary_block(source: str, marker: str) -> str:
    start = source.index(marker)
    end = source.index("\n\t}\n]", start)
    return source[start:end]


project = read("project.godot")
catalog = read("scripts/campaign/CampaignCatalog.gd")
difficulty = read("scripts/campaign/DifficultyCatalog.gd")
game = read("scripts/GameManager.gd")
ui = read("scripts/UIManager.gd")
ui_variant = read("scripts/UIManagerVariantB.gd")
main_menu = read("scripts/ui/MainMenu.gd")
diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")
save = read("scripts/save/SaveManager.gd")
campaign_manager = read("scripts/campaign/CampaignManager.gd")
winter = dictionary_block(catalog, '\t\t"id": SEASON_WINTER,')

check("Versão pública v3.11.4", 'config/version="3.11.4"' in project)
check("Layout oficial exibe v3.11.4", "LAYOUT OFICIAL\\nv3.11.4" in ui_variant)
check("Menu usa fallback v3.11.4", '"3.11.4"' in main_menu)
check("Diagnóstico espera v3.11.4", 'project_version != "3.11.4"' in diagnostics)

check("Inverno reduz produção em 10%", '"food_production_multiplier": 0.90' in winter)
check("Inverno aumenta consumo em 10%", '"food_consumption_multiplier": 1.10' in winter)
check("Penalidade antiga de produção saiu do inverno", '"food_production_multiplier": 0.80' not in winter)
check("Penalidade antiga de consumo saiu do inverno", '"food_consumption_multiplier": 1.20' not in winter)
check("Resumo sazonal informa -10%", '"-10% na produção de alimentação e "' in winter)
check("Resumo sazonal informa +10%", '"+10% no consumo de alimentação."' in winter)
check(
    "Guia informa os dois modificadores de 10%",
    "inverno reduz em 10% a produção de comida enquanto aumenta em 10% o consumo" in ui,
)
check(
    "Oráculo exige os multiplicadores novos",
    'food_production_multiplier", 1.0)), 0.90' in diagnostics
    and 'food_consumption_multiplier", 1.0)), 1.10' in diagnostics,
)

old_balanced_delta = 100.0 * 0.80 - 100.0 * 1.20
new_balanced_delta = 100.0 * 0.90 - 100.0 * 1.10
check(
    "Pressão sazonal de uma economia equilibrada caiu pela metade",
    math.isclose(new_balanced_delta, old_balanced_delta * 0.5, abs_tol=1e-9),
)
check(
    "Produção e consumo continuam positivos",
    100.0 * 0.90 > 0.0 and 100.0 * 1.10 > 0.0,
)

check(
    "Produção runtime lê o catálogo sazonal",
    "get_current_season_modifiers()" in game
    and 'season_modifiers.get(\n\t\t\t"food_production_multiplier"' in game,
)
check(
    "Consumo runtime lê o catálogo sazonal",
    "_get_effective_food_consumption_for_day" in game
    and "VillageCampaignCatalog.get_season_modifiers_for_day" in game
    and 'modifiers.get(\n\t\t\t"food_consumption_multiplier"' in game,
)
check(
    "Previsão e avanço usam a mesma produção",
    game.count("var production: Production = calculate_total_production()") == 2,
)
check(
    "Previsão e avanço usam o mesmo consumo por habitante",
    game.count("* get_effective_food_consumption_per_villager()") >= 2,
)

check("Regras de dificuldade ficaram intactas", sha256("scripts/campaign/DifficultyCatalog.gd") == "585ed5d934b253764a7b839a8eca69d2d71be6d0e854e8c9e5caefbfe73171a8")
check("GameManager ficou intacto", sha256("scripts/GameManager.gd") == "03ac9fdb12b4bea25f9d1a7c96bab5e04184db9d4e89c75d2822cb72c79a251e")
check("SaveManager ficou intacto", sha256("scripts/save/SaveManager.gd") == "1e4222b1813e0177e6f68d43e854e6a7206ba82fbd717d346267fc981ec16bfe")
check("CampaignManager ficou intacto", sha256("scripts/campaign/CampaignManager.gd") == "7b542fa01533f66285b26d85f148f1848b73c832099bf4bd294a6983e1b7656d")
check("BuildingManager ficou intacto", sha256("scripts/buildings/BuildingManager.gd") == "6a7bdc4efcad0221e4947294b484ded87120baa581f91c4cd17bf7004a5554e0")
check("Envelope global permanece v18", "const SAVE_VERSION: int = 18" in save)
check("Schema da campanha permanece 5", "const CAMPAIGN_STATE_VERSION: int = 5" in campaign_manager)
check("Catálogo permanece compatível com saves existentes", "const CATALOG_VERSION: int = 4" in catalog)
check(
    "Dificuldades não ganharam modificador oculto de inverno",
    len(re.findall(r'"food_consumption_multiplier": 1\.0', difficulty)) == 3,
)

print("Golem's Mandate — Parte 3, Etapa 12 — inverno v3.11.4")
print(f"Verificações corretivas: {CHECKS - len(FAILURES)}/{CHECKS} aprovadas")
if FAILURES:
    print("Falhas:")
    for failure in FAILURES:
        print(f"  - {failure}")
    sys.exit(1)
print("Resultado: APROVADO (sem inicializar o Godot e sem simular campanhas).")
