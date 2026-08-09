#!/usr/bin/env python3
"""Auditoria estática leve da Parte 3 — Etapa 9 (v3.8.2)."""

from pathlib import Path
import re
import sys


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


project = read("project.godot")
save = read("scripts/save/SaveManager.gd")
state = read("scripts/models/RelationshipState.gd")
foundation = read("scripts/foundation/Part2FoundationManager.gd")
game = read("scripts/GameManager.gd")
catalog = read("scripts/relationships/RelationshipCatalog.gd")
expansion = read("scripts/relationships/RelationshipExpansionCatalog.gd")
dialogue = read("scripts/relationships/RelationshipDialogueCatalog.gd")
story = read("scripts/story/StoryChapterCatalog.gd")
story_dialogue = read("scripts/dialogue/DialogueCatalog.gd")
event_manager = read("scripts/events/EventManager.gd")
ui = read("scripts/UIManager.gd")
relationship_window = read("scripts/ui/RelationshipsWindow.gd")
dialogue_window = read("scripts/ui/DialogueWindow.gd")
specialists = read("scripts/specialists/SpecialistCatalog.gd")
diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")

check("Versão pública 3.8.2", 'config/version="3.8.2"' in project)
check("Save global v17", "const SAVE_VERSION: int = 17" in save)
check("Save v15 ainda pode migrar", "save_version < 15" in save)
check("Migração 16 para 17", re.search(r"\n\s*16:\s*\n", save) is not None)
check("Migração adiciona marcadores", 'relationship_entry["romance_interest_markers"]' in save)
check("Migração adiciona cooldown", 'relationship_entry["last_management_passive_day"] = 0' in save)
check("Schema de relações v3", 'relationship_system_version"] = 3' in save and '"relationship_system_version": 3' in foundation)
check("Diagnóstico reconhece v3.8.2", 'project_version != "3.8.2"' in diagnostics)
check("Diagnóstico reconhece save 17", "SAVE_MANAGER_SCRIPT.SAVE_VERSION != 17" in diagnostics)

for npc_id, name in [
    ("meio_vampiro_emo_gotico", "Silas Nocturno"),
    ("bruxinha_ruiva", "Dália Folhaverde"),
]:
    check(f"Especialista {name}", npc_id in specialists and name in specialists)
    check(f"Recurso de {name}", any(name in read(str(path.relative_to(ROOT))) for path in (ROOT / "characters").glob("*.tres")))

romance_block = catalog.split("const ROMANCE_IDS", 1)[1].split("= [", 1)[1].split("\n]", 1)[0]
check("Sete candidatos românticos", all(candidate in romance_block for candidate in ["aelric_ferreiro", "kobi_mercante", "orion_draconato", "rubra_meio_demonia", "brunna_ana_barbara", "DALIA_ID", "SILAS_ID"]))
check("Oito vínculos rastreados", "DALIA_ID" in catalog.split("const TRACKED_IDS", 1)[1] and "SILAS_ID" in catalog.split("const TRACKED_IDS", 1)[1])
check("Eventos nos níveis 2/4/6/8", "[2, 4, 6, 8]" in catalog)
check("Passivas liberadas no nível 4", 'if level < 4:' in catalog)
check("Horta Partilhada usa déficit", 'food_balance_negative' in catalog and 'result["food_production_bonus"] = 0.04' in catalog)
check("Canção de Vigília tem cooldown", "COOLDOWN_DAYS: int = 5" in foundation)
check("Canção recupera um ponto", '"happiness_recovery": 1.0' in foundation)
check("Passiva resolve no avanço de dia", "resolve_relationship_daily_passives" in game)
check("Passiva é registrada antes do save", game.find("resolve_relationship_daily_passives") < game.find("_autosave_if_enabled", game.find("func advance_day")))

check("Marcadores persistem", '"romance_interest_markers"' in state)
check("São exigidos dois marcadores", "romance_interest_markers.size() >= 2" in state)
check("Rejeição bloqueia requisitos", "and not romance_declined" in state)
check("Interesse tem ação estável", '"record_romance_interest"' in dialogue and '"record_romance_interest"' in game)
check("Interesse dos níveis 4 e 6", "if index in [1, 2]" in dialogue)
check("Todos os candidatos têm textos de interesse", all(npc_id in expansion for npc_id in ["aelric_ferreiro", "kobi_mercante", "orion_draconato", "rubra_meio_demonia", "brunna_ana_barbara", "SILAS_ID", "DALIA_ID"]))
check("Final exige histórico de interesse", "interest_markers.size() >= 2" in dialogue)
check("Sem interesse há amizade profunda", "amizade profunda" in dialogue)
check("Rejeição encerra romance", "decline_relationship_romance" in game)
check("Compromisso permanece exclusivo", "O Prefeito já possui um parceiro oficial" in foundation)
check("Interface mostra progresso 0/2", "Interesse demonstrado: %d/2 escolhas." in relationship_window)
check("Teste interno é propagado pela conversa", '"relationship_internal_test": internal_test_mode' in dialogue and "include_unknown" in ui)
check("Teste interno ignora somente o limite diário", "ignore_daily_limit or can_gain_conversation_points(day)" in state and "if not ignore_daily_limit:" in state)
check("Jogo normal mantém limite diário", "func can_gain_conversation_points" in state and "last_conversation_day = day" in state)
check("Interface explica ausência de limite no teste", "Conversas de teste geram pontos sem limite diário" in relationship_window)

character_data_block = expansion.split("const CHARACTER_DATA", 1)[1].split("const CONVERSATION_TOPICS", 1)[0]
silas_block = character_data_block.split("SILAS_ID:", 1)[1].split("DALIA_ID:", 1)[0]
dalia_block = character_data_block.split("DALIA_ID:", 1)[1]
check("Quatro falas sazonais de Silas", all(f'"{season}"' in silas_block for season in ["spring", "summer", "autumn", "winter"]))
check("Quatro falas sazonais de Dália", all(f'"{season}"' in dalia_block for season in ["spring", "summer", "autumn", "winter"]))
check("Assunto comunitário substitui o tema corporal", '"id": "dalia_compostagem"' in expansion and '"id": "dalia_corpo"' not in expansion)
check("Textos de Dália não mencionam corpo ou peso", not any(term in (dalia_block + expansion.split("DALIA_ID: [", 1)[1].lower()) for term in ["gorda", "gordo", "corpo", "peso", "barriga"]))
check("Comentários contextuais da vila", "get_village_topic" in expansion and "food_balance" in expansion and "happiness" in expansion)
check("Contexto chega ao catálogo", "GameManager.get_relationship_world_context()" in ui)
check("Contexto usa previsão", "calculate_next_day_forecast()" in game[game.find("func get_relationship_world_context"):])
check("Respostas usam expressões", '"expression": expression' in dialogue)
check("Retratos aceitam expressões", "_apply_portrait_expression(expression)" in dialogue_window)
check("PNG mantém as cores originais", "portrait_texture.modulate = Color.WHITE" in dialogue_window and "expression_color" not in dialogue_window)
check("Catálogo aceita retrato por expressão", "expression_portrait_paths" in read("scripts/dialogue/CharacterDefinition.gd"))

check("Cadência inclui dias 90 e 105", "[15, 30, 45, 60, 75, 90, 105, 120]" in story)
check("Capítulo de Silas", "story_day90_silas_concert" in story and "chapter_90_intro" in story_dialogue)
check("Capítulo de Dália", "story_day105_dalia_garden" in story and "chapter_105_intro" in story_dialogue)
check("Final exige sete aliados", '"required_known_npcs": 7' in story)
check("Amizade libera informação", "required_relationship_id" in story and "required_relationship_points" in event_manager)
check("Romance integra acontecimento", "requires_official_partner" in story and "requires_official_partner" in event_manager)
check("Opção romântica não é superior isolada", '"dalia_partner_seed"' in story and '"food": 8.0' in story)
check("UI explica a nova cadência", "Silas e Dália nos dias 15 a 105" in ui)
check("UI explica as duas escolhas", "níveis 4 e 6" in ui)

for portrait in [
    "assets/dialogue/portraits/meio_vampiro_emo_gotico.png",
    "assets/dialogue/portraits/bruxinha_ruiva.png",
]:
    check(f"Retrato existe: {portrait}", (ROOT / portrait).is_file())

for relative_path in [
    "scripts/models/RelationshipState.gd",
    "scripts/foundation/Part2FoundationManager.gd",
    "scripts/GameManager.gd",
    "scripts/relationships/RelationshipDialogueCatalog.gd",
    "scripts/story/StoryChapterCatalog.gd",
    "scripts/dialogue/DialogueCatalog.gd",
    "scripts/events/EventManager.gd",
    "scripts/save/SaveManager.gd",
]:
    source = read(relative_path)
    check(f"Sem marcadores de conflito: {relative_path}", not any(marker in source for marker in ["<<<<<<<", "=======", ">>>>>>>"]))

print("Golem's Mandate — Parte 3, Etapa 9")
print(f"Verificações: {CHECKS}")
if FAILURES:
    print(f"Falhas: {len(FAILURES)}")
    for failure in FAILURES:
        print(f"- {failure}")
    sys.exit(1)
print("Falhas: 0")
print("Resultado: APROVADO")
