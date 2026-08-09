#!/usr/bin/env python3
"""Auditoria estática da Parte 3 — Etapa 12 (v3.11.5).

Não inicializa o Godot e não simula campanhas. Valida os contratos persistentes,
as integrações de identidade/telemetria e a estrutura dos arquivos entregues.
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
        elif char in ")]}" and (not stack or stack.pop() != expected[char]):
            return f"delimitador inesperado: {char}"
    return None if not stack else f"delimitador não fechado: {stack[-1]}"


project = read("project.godot")
game = read("scripts/GameManager.gd")
ui = read("scripts/UIManager.gd")
ui_variant = read("scripts/UIManagerVariantB.gd")
identity = read("scripts/campaign/CampaignIdentityCatalog.gd")
outcomes = read("scripts/campaign/CampaignOutcomeCatalog.gd")
difficulty = read("scripts/campaign/DifficultyCatalog.gd")
campaign = read("scripts/campaign/CampaignManager.gd")
records = read("scripts/campaign/CampaignRecords.gd")
events = read("scripts/events/EventManager.gd")
memories = read("scripts/events/FounderMemoryManager.gd")
part2 = read("scripts/foundation/Part2FoundationManager.gd")
part3 = read("scripts/foundation/Part3FoundationManager.gd")
profile = read("scripts/models/PlayerProfile.gd")
relationships = read("scripts/relationships/RelationshipDialogueCatalog.gd")
save = read("scripts/save/SaveManager.gd")
building = read("scripts/buildings/BuildingManager.gd")
campaign_ui = read("scripts/ui/CampaignWindow.gd")
main_menu = read("scripts/ui/MainMenu.gd")
profile_ui = read("scripts/ui/ProfileSetupWindow.gd")
diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")
recruitment = read("scripts/council/CouncilRecruitmentManager.gd")
recruitment_ui = read("scripts/ui/RecruitmentWindow.gd")
council_ui = read("scripts/ui/CouncilWindow.gd")
save_ui = read("scripts/ui/SaveWindow.gd")
settings = read("scripts/settings/GameSettings.gd")
villager_scene = read("scenes/villager.tscn")
main_scene = read("scenes/main.tscn")
tutorial = read("scripts/tutorial/TutorialManager.gd")
audio = read("scripts/audio/AudioManager.gd")

check("Versão pública v3.11.5", 'config/version="3.11.5"' in project)
check("Layout oficial exibe v3.11.5", "LAYOUT OFICIAL\\nv3.11.5" in ui_variant)
check("Save global permanece no envelope v18", "const SAVE_VERSION: int = 18" in save)
check("Caminho de save permanece isolado", "golems_mandate_part3" in save)
check("Save registra a versão do projeto", '"project_version"' in save)
check("Backup é usado para recuperação", "_read_save_path(SAVE_BACKUP_PATH)" in save and '"loaded_from_backup"' in save)
check("Recuperação não sobrescreve o backup válido", "recovered_from_backup_pending" in save and "não pode ser substituído" in save)
check("Save de versão futura não cai para backup antigo", 'error_code == "future_version"' in save and '"future_version"' in save)
check("Fila de obras valida o schema realmente exportado", "QUEUE_STATE_VERSION: int = 2" in building and 'queue_state_version", 0)) != 2' in save)

check("Catálogo de identidade existe", "class_name VillageCampaignIdentityCatalog" in identity)
check("Versão do gerador persistente", "const GENERATOR_VERSION: int = 1" in identity and '"generator_version"' in part3)
check("Hash textual próprio e estável", "unicode_at" in identity and ".hash()" not in identity)
check("Nome sugerido depende da semente", "suggest_village_name" in identity and "NAME_PREFIXES" in identity and "NAME_SUFFIXES" in identity)
check("Perfil salva vila e criação", all(token in profile for token in ["village_name", "campaign_created_at_unix", "created_project_version"]))
check("Setup recebe vila e semente", all(token in profile_ui for token in ["village_name_input", "seed_input", "NOVA SEMENTE", "COPIAR"]))
check("Sinal de criação transporta identidade", "village_name: String" in profile_ui and "campaign_seed: int" in profile_ui)
check("GameManager inicia com identidade completa", "func start_new_campaign(" in game and "reset_game(clean_seed)" in game and "sanitize_village_name" in game)
check("Visão geral expõe identidade da campanha", "func get_campaign_identity()" in game and "playing_campaign_seed" in game)

check("RNG dos acontecimentos usa semente", "event_random.seed = campaign_seed + 104729" in events)
check("Estado do RNG dos acontecimentos é salvo", '"rng_state": str(event_random.state)' in events and "event_random.state = int" in events)
check("Eventos não chamam randomize", "randomize()" not in events)
check("Conversas de relação não usam shuffle global", "choices.shuffle()" not in relationships)
check("Tópicos de relação usam RNG local estável", "_shuffle_choices" in relationships and "topic_seed" in relationships and "campaign_seed" in relationships)

check("Três dificuldades preservadas", 'DIFFICULTY_IDS: Array[String] = ["cozy", "moderate", "hard"]' in difficulty)
for neutral_key in [
    "production_multiplier",
    "food_consumption_multiplier",
    "maintenance_multiplier",
    "happiness_decay_multiplier",
    "building_cost_multiplier",
]:
    check(
        f"{neutral_key} não mascara a diferença qualitativa",
        len(re.findall(rf'"{neutral_key}": 1\.0', difficulty)) == 3,
    )
check("Dificuldades alteram reservas iniciais", all(token in difficulty for token in ['"initial_food": 48.0', '"initial_food": 34.0', '"initial_food": 30.0']))
check("Dificuldades alteram tolerância a crise", '"crisis_grace_days": 4' in difficulty and difficulty.count('"crisis_grace_days": 2') == 2)
check("Dificuldades alteram recuperação", all(token in difficulty for token in ['"post_crisis_happiness_recovery": 2.0', '"post_crisis_happiness_recovery": 0.5', '"post_crisis_happiness_recovery": 0.0']))
check("Acolhedora reduz metas de recursos para 80%", difficulty.count('"food_target_multiplier": 0.80') == 1 and difficulty.count('"material_target_multiplier": 0.80') == 1)
check("Acolhedora exige um habitante a menos", '"population_target_offset": -1' in difficulty and "+ int(rules.get(\"population_target_offset\", 0))" in difficulty)
check("Acolhedora usa felicidade inicial 72", '"initial_happiness": 72.0' in difficulty)
check("As três dificuldades reduzem o tempo de atração", all(token in difficulty for token in ['"attraction_target": 1', '"attraction_target": 2']))
check("Felicidade mínima de atração varia por dificuldade", all(token in difficulty for token in ['"growth_minimum_happiness": 52.0', '"growth_minimum_happiness": 55.0', '"growth_minimum_happiness": 58.0']))
check("Dificuldades alteram janela narrativa", all(token in difficulty for token in ['"event_window_day_adjustment": 2', '"event_window_day_adjustment": 0', '"event_window_day_adjustment": -1']))
check("Recuperação qualitativa está aplicada", "difficulty_recovery_bonus" in game and "post_crisis_happiness_recovery" in game)
check("Janela narrativa qualitativa está aplicada", "consequence_window_day_adjustment" in memories and "configure_difficulty" in memories)

check("Fundação telemétrica usa schema 4", "FOUNDATION_STATE_VERSION: int = 4" in part3)
check("Histórico diário preserva estado anterior", '"resources_before"' in part3)
check("Contribuições guardam decomposição", all(token in part3 for token in ["attribute_base", "personal_bonus", "global_bonus", "specialization_bonus", "passive_active"]))
check("Medalhas comportamentais persistem", "behavioral_medals" in part3 and "record_behavioral_medals" in part3)
check("Consultas por período existem", "get_production_history_between" in part3 and "get_decision_history" in part3)

check("Campanha usa schema 5", "CAMPAIGN_STATE_VERSION: int = 5" in campaign)
check("Relatórios de avaliação persistem", '"evaluation_reports"' in campaign and "record_evaluation_report" in campaign)
check("Estatísticas e perfil final persistem", '"final_statistics"' in campaign and '"final_profile"' in campaign and "set_final_outcome" in campaign)
check("Pontuação final antiga saiu do gerenciador", "final_score" not in campaign and "final_medal" not in campaign)
check("Relatório usa metas realmente avaliadas", "evaluated_goals" in game and "_build_evaluation_report" in game)
check("Relatório contém memória de recursos", "_build_period_resource_breakdown" in game and "resource_breakdown" in game)
check("Relatório contém contribuição individual", "_build_interval_contribution_data" in game and "councillor_contributions" in game)
check("Relatório contém comparação", "_build_evaluation_comparison" in game and "comparison_with_previous" in game)
check("Relatório contém fatores e consequências", "_build_period_factors" in game and '"consequences"' in game)

for medal_name in [
    "Sustento da Vila",
    "Mãos à Obra",
    "Coração da Comunidade",
    "Espírito Versátil",
    "Guarda nas Horas Difíceis",
    "Voz da Conciliação",
    "Companheiro Leal",
    "Virada Decisiva",
]:
    check(f"Medalha comportamental: {medal_name}", medal_name in outcomes)
check("Medalhas não definem bônus", "bonus" not in outcomes.lower())
check("Perfil final é descritivo", "select_campaign_profile" in outcomes and len(re.findall(r'"description":', outcomes)) >= 14)
check("Histórico não classifica melhor campanha", "get_recent_record" in records and "record_campaign" in records and "score" not in records)

check("Preparação projeta cada meta", all(token in game for token in ["projected_value", "difference_to_target", "projection_status"]))
check("Preparação considera obras contratadas", "_build_construction_projection" in game and "predicted_available_day" in game)
check("Preparação declara premissas", "projection_assumptions" in game and "Não antecipa escolhas futuras" in game)
check("UI de campanha possui relatório rolável", "ScrollContainer.new()" in campaign_ui and "details_label" in campaign_ui)
check("UI distingue agora, projeção e meta", "Agora %s  •  Projeção %s  •  Meta" in campaign_ui)
check("UI mostra memória avaliada", "MEMÓRIA DOS DIAS" in campaign_ui and "CONTRIBUIÇÕES DO CONSELHO" in campaign_ui)
check("UI esclarece medalhas sem bônus", "reconhecimento, sem bônus" in campaign_ui)
check("UI final declara ausência de pontuação", "Não há pontuação geral" in campaign_ui and "final_score" not in campaign_ui)
check("Menu usa perfil recente", "get_recent_record" in main_menu and "campaign_profile_name" in main_menu)
check("Menu não exibe score antigo", "final_score" not in main_menu and 'get("score"' not in main_menu)
check("Guia explica identidade e relatórios", "IDENTIDADE DA CAMPANHA" in ui and "MEDALHAS COMPORTAMENTAIS" in ui)
check("Guia não promete bronze/prata/ouro", "BRONZE, PRATA E OURO" not in ui)
check("Guia explica a pressão de inverno reduzida", "inverno reduz em 10% a produção de comida enquanto aumenta em 10% o consumo" in ui)

check("Recrutamento usa estado interno v3", "const STATE_VERSION: int = 3" in recruitment)
check("As seis escolhas não exigem pontos mínimos", recruitment.count(": 0,") >= 5 and "120: 0" in recruitment)
check("Relação escolhe a origem sem bloquear a oferta", "eligible_rows: Array[Dictionary] = source_rows.duplicate(true)" in recruitment)
check("Save v2 de recrutamento é aceito", "[1, 2, STATE_VERSION]" in recruitment and "_migrate_threshold_offer" in recruitment)
check("Resumo separa pendentes e futuras", 'status["pending_count"]' in recruitment and 'status["future_count"]' in recruitment and "ESCOLHAS CONCLUÍDAS" in council_ui)
check("Janela não exibe requisito antigo", "%d/%d" not in recruitment_ui and "cumpriram o requisito" not in recruitment_ui)
check("Guia declara escolhas garantidas", "avaliação aprovada garante uma escolha" in ui and "nenhuma vaga antiga apaga ou bloqueia" in ui)

check("Configurações usam nome oficial", "user://golems_mandate_settings.cfg" in settings)
check("Configurações antigas são migradas", "LEGACY_SETTINGS_PATH" in settings and "_save_settings()" in settings)
check("Tutorial usa nome oficial e migra progresso antigo", "user://golems_mandate_tutorial.cfg" in tutorial and "LEGACY_TUTORIAL_PATH" in tutorial)
check("Metadado de áudio usa identidade oficial", "golems_mandate_audio_bound" in audio and "square_village_audio_bound" not in audio)
check("Histórico usa nome oficial", "user://golems_mandate_campaign_records.json" in records)
check("Histórico antigo permanece legível", "LEGACY_RECORDS_PATH" in records)
check("Histórico possui escrita temporária e backup", "RECORDS_TEMP_PATH" in records and "RECORDS_BACKUP_PATH" in records)
check("Cena não expõe o nome provisório", 'text = "Habitante"' in villager_scene and 'text = "Quadrado"' not in villager_scene)
check("Fundadores aguardam a geração determinística", main_scene.count("randomize_on_ready = false") == 5)
check("Tela informa recuperação por backup", "Backup de segurança recuperado" in save_ui and "BACKUP DE SEGURANÇA RECUPERADO" in main_menu)

check("Diagnóstico espera v3.11.5", 'project_version != "3.11.5"' in diagnostics)
check("Diagnóstico espera fundação schema 4", "FOUNDATION_STATE_VERSION != 4" in diagnostics)
check("Diagnóstico mantém save global 18", "SAVE_VERSION != 18" in diagnostics)

gdscript_files = sorted((ROOT / "scripts").rglob("*.gd"))
for path in gdscript_files:
    text = path.read_text(encoding="utf-8")
    check(f"Delimitadores: {path.relative_to(ROOT)}", delimiter_error(text) is None)
    function_names = re.findall(r"^(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(", text, re.MULTILINE)
    check(
        f"Funções únicas: {path.relative_to(ROOT)}",
        len(function_names) == len(set(function_names)),
    )

referenced_paths = set(re.findall(r'"(res://[^"\n]+)"', "\n".join(
    path.read_text(encoding="utf-8") for path in gdscript_files
)))
missing_paths = [path for path in referenced_paths if not (ROOT / path.removeprefix("res://")).exists()]
check("Todos os res:// literais existem", not missing_paths)

print("Golem's Mandate — Parte 3, Etapa 12")
print(f"Verificações estáticas: {CHECKS - len(FAILURES)}/{CHECKS} aprovadas")
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
