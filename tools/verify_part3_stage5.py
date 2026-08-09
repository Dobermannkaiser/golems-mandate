#!/usr/bin/env python3
from __future__ import annotations

import re
import subprocess
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


def read(relative: str) -> str:
    return (ROOT / relative).read_text(encoding="utf-8")


def validate_regressions() -> None:
    for script in ["verify_part3_stage3.py", "verify_part3_stage4.py", "verify_gdscript_local_scope.py"]:
        completed = subprocess.run(
            [sys.executable, str(ROOT / "tools" / script)]
            + (["--strict-art"] if script == "verify_part3_stage3.py" else []),
            cwd=ROOT,
            capture_output=True,
            text=True,
        )
        check(
            f"Regressão aprovada: {script}",
            completed.returncode == 0,
            (completed.stdout or completed.stderr)[-700:],
        )


def validate_versions() -> None:
    project = read("project.godot")
    save = read("scripts/save/SaveManager.gd")
    tutorial = read("scripts/tutorial/TutorialManager.gd")
    diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")
    variant = read("scripts/UIManagerVariantB.gd")
    main_menu = read("scripts/ui/MainMenu.gd")
    check("Versão pública é 3.8.2", 'config/version="3.8.2"' in project)
    check("Save é versão 17", "const SAVE_VERSION: int = 17" in save)
    check("Save mantém compatibilidade da Parte 3", "Campanha compatível da Parte 3 encontrada." in save and "Etapa 5 da Parte 3" not in save)
    check("Tutorial revisado está na versão 7", "const TUTORIAL_VERSION: int = 7" in tutorial)
    check("Oráculo exige versão 3.8.2", 'project_version != "3.8.2"' in diagnostics)
    check("Oráculo exige save 17", "SAVE_VERSION != 17" in diagnostics)
    check("Layout visual mostra v3.8.2", "v3.8.2" in variant)
    check("Menu mostra 3.8.2", '"3.8.2"' in main_menu)


def validate_passive_catalog() -> None:
    passive = read("scripts/council/CouncilPassiveCatalog.gd")
    card = read("scripts/council/CouncilCardCatalog.gd")
    recruitment = read("scripts/council/CouncilRecruitmentManager.gd")
    expected = {
        "adaptavel", "dedicado", "inquieto", "versatil", "rival_produtivo",
        "organizador", "veterano", "incansavel", "autossuficiente",
        "economico", "motivador", "otimista", "improvisador", "protetor",
        "mediador",
    }
    match = re.search(r"const PASSIVES: Array\[Dictionary\] = \[(.*?)\n\]", passive, re.S)
    block = match.group(1) if match else ""
    ids = re.findall(r'"id":\s*"([^"]+)"', block)
    check("Quinze passivas aprovadas", set(ids) == expected, str(ids))
    check("Passivas têm condição clara", block.count('"condition":') == 15, str(block.count('"condition":')))
    check("Mimo mantém Faz-tudo exclusiva", 'const MIMO_PASSIVE' in passive and '"id": "faz_tudo"' in passive)
    check("Passiva provisória Cooperativo foi removida", "cooperativo" not in passive.lower())
    check("Catálogo de cartas delega ao catálogo novo", "PASSIVE_CATALOG_SCRIPT.get_randomized_passives" in card)
    check("Fundadores sorteiam catálogo ampliado", "get_randomized_passives" in card)
    check("Recrutamento exclui passivas já no elenco", "existing_passive_ids" in recruitment)
    check("Candidatas nunca repetem passiva entre si", "chosen_ids.has(passive_id)" in passive)
    for token in [
        '"production_multiplier_bonus"', '"daily_happiness_bonus"',
        '"daily_xp_bonus"', '"fixed_food_consumption_reduction"',
        '"fixed_material_maintenance_reduction"', '"event_chance_bonus"',
        '"failure_negative_multiplier"', '"relationship_delta_adjustment"',
    ]:
        check(f"Catálogo expõe efeito {token}", token in passive)


def validate_composition() -> None:
    composition = read("scripts/council/CouncilCompositionCatalog.gd")
    game = read("scripts/GameManager.gd")
    expected_synergies = {
        "ciclo_sustento", "forja_abastecida", "obras_protegidas",
        "ordem_comunitaria", "conselho_diverso",
    }
    match = re.search(r"const SYNERGIES: Array\[Dictionary\] = \[(.*?)\n\]", composition, re.S)
    block = match.group(1) if match else ""
    ids = re.findall(r'"id":\s*"([^"]+)"', block)
    check("Cinco sinergias aprovadas", set(ids) == expected_synergies, str(ids))
    check("Limite geral de duas sinergias", "const MAX_ACTIVE_SYNERGIES: int = 2" in composition)
    check("Uma carta não entra em duas sinergias", "_members_overlap" in composition)
    check("Escolha é automática por melhor efeito", "best_score" in composition and "_estimate_score" in composition)
    check("Concentração 100/97/93/88", all(token in composition for token in ["1.00", "0.97", "0.93", "0.88"]))
    check("Penalidade é aplicada ao total final", "_apply_council_composition_to_production" in game and 'concentration.get("multiplier", 1.0)' in game)
    check("Produção pessoal não recebe penalidade", "_calculate_recorded_personal_production" in game and "_apply_council_composition_to_production" not in game[game.find("func _calculate_recorded_personal_production"):game.find("func _calculate_total_production_internal")])
    check("Sinergias são aplicadas automaticamente", "select_synergies" in game and "get_combined_modifiers" in game)
    check("Sinergia de manutenção reduz custo final", "maintenance_reduction" in composition and "_get_council_fixed_material_reduction_for_day" in game)


def validate_passive_integration() -> None:
    game = read("scripts/GameManager.gd")
    villager = read("scripts/Villager.gd")
    event_manager = read("scripts/events/EventManager.gd")
    foundation = read("scripts/foundation/Part3FoundationManager.gd")
    check("Estado de passiva é calculado centralmente", "func get_villager_passive_overview" in game)
    check("Produção pessoal usa passiva", 'passive_overview.get("production_multiplier_bonus"' in game)
    check("Felicidade diária usa passiva", 'passive_overview.get("daily_happiness_bonus"' in game)
    check("Incansável aumenta XP diário", 'var xp_amount: int = 2 + int(' in game and 'daily_xp_bonus' in game)
    check("Autossuficiente reduz consumo fixo", "_get_council_fixed_food_reduction_for_day" in game)
    check("Econômico reduz manutenção fixa", "_get_council_fixed_material_reduction_for_day" in game)
    check("Improvisador aumenta chance em 5pp", 'villager.passive_id == "improvisador"' in event_manager and "chance += 0.05" in event_manager)
    check("Protetor reduz perdas em 15%", 'villager.passive_id == "protetor"' in event_manager and "effect_value * 0.85" in event_manager)
    check("Mediador aplica no máximo uma vez por dia", "mediator_last_trigger_day != current_day" in game and "mediator_last_trigger_day = current_day" in game)
    check("Sequência na profissão é persistida", all(token in villager for token in ["profession_streak_days", "profession_change_count", "record_completed_profession_day"]))
    check("Sequência é salva", '"profession_streak_days": profession_streak_days' in villager and 'save_data.get("profession_streak_days"' in villager)
    check("Histórico fornece dias por profissão", '"profession_day_counts"' in foundation)


def validate_ui_and_tutorials() -> None:
    card = read("scripts/ui/VillagerCard.gd")
    forecast_window = read("scripts/ui/ForecastDetailsWindow.gd")
    ui = read("scripts/UIManager.gd")
    check("Carta mostra estado da passiva", "_passive_state_label" in card and all(token in card for token in ["ATIVA", "CONDICIONAL", "INATIVA"]))
    check("Estados usam cor e texto", "state_color" in card and "status_text" in card)
    check("Previsão possui botão de detalhamento", 'forecast_details_button.text = "DETALHAR MODIFICADORES"' in ui)
    check("Janela de detalhamento existe", bool(forecast_window) and "class_name ForecastDetailsWindow" in forecast_window)
    for section in [
        "PRODUÇÃO DO PRÓXIMO DIA", "RETORNO POR CONCENTRAÇÃO",
        "SINERGIAS AUTOMÁTICAS", "PASSIVAS DAS CARTAS ATIVAS",
        "CONSUMO E MANUTENÇÃO",
    ]:
        check(f"Detalhamento mostra {section}", section in forecast_window)
    check("Tutorial básico explica concentração", "reduzem em 3%, 7% ou 12%" in ui)
    check("Guia explica estados das passivas", "ATIVA, CONDICIONAL ou INATIVA" in ui)
    check("Guia explica ativação automática", "Não existe botão para ativar sinergias" in ui)
    check("Guia não força nova campanha na Etapa 7", "Esta etapa exige uma campanha nova" not in ui)
    check("Ajuda não promete migração antiga", "Saves da Etapa 1 da Parte 3 são convertidos" not in ui)



def validate_simulations() -> None:
    for script in [
        "simulate_passives_synergies_stage5.py",
        "simulate_stage5_stress.py",
    ]:
        completed = subprocess.run(
            [sys.executable, str(ROOT / "tools" / script)],
            cwd=ROOT,
            capture_output=True,
            text=True,
        )
        check(
            f"Simulação aprovada: {script}",
            completed.returncode == 0,
            (completed.stdout or completed.stderr)[-900:],
        )

def main() -> int:
    validate_regressions()
    validate_versions()
    validate_passive_catalog()
    validate_composition()
    validate_passive_integration()
    validate_ui_and_tutorials()
    validate_simulations()
    failures = [result for result in RESULTS if not result.ok]
    print("Golem's Mandate — verificação da Parte 3 / Etapa 5")
    print(f"Verificações: {len(RESULTS)}")
    print(f"Falhas: {len(failures)}")
    if failures:
        print("\nFALHAS:")
        for result in failures:
            print(f"- {result.name}: {result.detail}")
        return 1
    print("Resultado estrutural: APROVADO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
