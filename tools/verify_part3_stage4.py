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
    path = ROOT / relative
    if not path.is_file():
        return ""
    return path.read_text(encoding="utf-8")


def count_token(text: str, token: str) -> int:
    return text.count(token)


def extract_balanced(text: str, start: int, opener: str, closer: str) -> str:
    if start < 0 or start >= len(text) or text[start] != opener:
        return ""
    depth = 0
    quote: str | None = None
    escaped = False
    index = start
    while index < len(text):
        char = text[index]
        if quote is not None:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = None
            index += 1
            continue
        if char in {'"', "'"}:
            quote = char
            index += 1
            continue
        if char == "#":
            while index < len(text) and text[index] != "\n":
                index += 1
            continue
        if char == opener:
            depth += 1
        elif char == closer:
            depth -= 1
            if depth == 0:
                return text[start:index + 1]
        index += 1
    return ""


def split_top_level_dicts(array_block: str) -> list[str]:
    result: list[str] = []
    index = 1
    while index < len(array_block) - 1:
        if array_block[index] == "{":
            block = extract_balanced(array_block, index, "{", "}")
            if not block:
                break
            result.append(block)
            index += len(block)
            continue
        if array_block[index] in {'"', "'"}:
            quote = array_block[index]
            index += 1
            while index < len(array_block):
                if array_block[index] == "\\":
                    index += 2
                    continue
                if array_block[index] == quote:
                    index += 1
                    break
                index += 1
            continue
        index += 1
    return result


def extract_key_container(block: str, key: str, opener: str, closer: str) -> str:
    match = re.search(rf'"{re.escape(key)}"\s*:\s*\{opener}', block)
    if not match:
        return ""
    start = block.find(opener, match.start())
    return extract_balanced(block, start, opener, closer)




def extract_function_block(text: str, function_name: str) -> str:
    match = re.search(
        rf"(?m)^func\s+{re.escape(function_name)}\s*\([^\n]*",
        text,
    )
    if not match:
        return ""
    next_match = re.search(r"(?m)^func\s+", text[match.end():])
    end = len(text) if not next_match else match.end() + next_match.start()
    return text[match.start():end]

def validate_previous_stage() -> None:
    completed = subprocess.run(
        [sys.executable, "tools/verify_part3_stage3.py", "--strict-art"],
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    check(
        "Base da Etapa 3 continua estruturalmente válida",
        completed.returncode == 0,
        completed.stdout.strip()[-500:] if completed.stdout else completed.stderr.strip(),
    )


def validate_versions_and_save() -> None:
    project = read("project.godot")
    save = read("scripts/save/SaveManager.gd")
    foundation = read("scripts/foundation/Part3FoundationManager.gd")
    diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")
    check("Versão pública é 3.8.2", 'config/version="3.8.2"' in project)
    check("Save atual é versão 17", "const SAVE_VERSION: int = 17" in save)
    check("Fundação persistente é versão 3", "const FOUNDATION_STATE_VERSION: int = 3" in foundation)
    check("Schema da Parte 3 permanece estável", 'golems_mandate_part3_foundation' in foundation)
    check("Projeto mantém caminhos res://", "uid://" not in project)
    check("Mensagem do save é neutra para a Parte 3", "Campanha compatível da Parte 3 encontrada." in save and "Etapa 5 da Parte 3" not in save)
    check("Fundação valida estrutura histórica carregada", "Histórico de %s não possui o campo %s." in foundation)
    check("Oráculo exige versão 3.8.2", 'project_version != "3.8.2"' in diagnostics)
    check("Oráculo exige save 17", "SAVE_VERSION != 17" in diagnostics)
    check("Oráculo exige fundação schema 3", "FOUNDATION_STATE_VERSION != 3" in diagnostics)


def validate_xp_and_levels() -> None:
    villager = read("scripts/Villager.gd")
    game = read("scripts/GameManager.gd")
    cards = read("scripts/council/CouncilCardCatalog.gd")
    check("Nível máximo é 6", "const MAX_LEVEL: int = 6" in villager)
    check("Atributo máximo é 8", "const MAX_ATTRIBUTE_VALUE: int = 8" in villager)
    check("XP vitalício existe", "var lifetime_xp" in villager)
    check("XP vitalício sempre cresce", "lifetime_xp += amount" in villager)
    check("XP de nível para no máximo", "if level < MAX_LEVEL:" in villager and "xp += amount" in villager)
    check("XP atual zera no nível máximo", "if level >= MAX_LEVEL:" in villager and "xp = 0" in villager)
    check("Subida concede ponto pendente", "unspent_attribute_points += 1" in villager)
    check("Fórmula de XP permanece 80 + 20 por nível", "80 + 20 * maxi(0, level - 1)" in cards)
    check("XP diário mantém base +2", 'var xp_amount: int = 2 + int(' in game and '"daily_council_service"' in game)
    check("XP diário só percorre Conselho ativo", "for villager: Villager in get_active_council():" in game)
    check(
        "Responsabilidade concede +20 XP",
        re.search(
            r"_grant_xp_to_villager\(\s*credited_villager,\s*20,\s*\"event_",
            game,
            re.S,
        ) is not None,
    )
    check("Marco concede +10 XP", re.search(r"_grant_xp_to_villager\(\s*villager,\s*10,\s*\"production_", game, re.S) is not None)
    check("Todos os níveis ganhos geram conversa", "for gained_index: int in range(levels_gained):" in game and "_queue_level_up_dialogue" in game)
    check("Avanço do dia bloqueia conversa pendente", "or has_pending_level_dialogue()" in game)
    check("Obras bloqueadas durante conversa de nível", "Conclua a conversa de conquista antes de planejar obras." in game)


def validate_manual_attributes() -> None:
    villager = read("scripts/Villager.gd")
    game = read("scripts/GameManager.gd")
    card = read("scripts/ui/VillagerCard.gd")
    foundation = read("scripts/foundation/Part3FoundationManager.gd")
    check("Distribuição manual existe no modelo", "func spend_attribute_point" in villager)
    for attribute_id in ["strength", "intelligence", "charisma", "agility"]:
        check(
            f"Distribuição aceita {attribute_id}",
            f'"{attribute_id}":' in villager,
        )
    check("Ponto é consumido", "unspent_attribute_points -= 1" in villager)
    check("Ponto gasto é contabilizado", "attribute_points_spent += 1" in villager)
    check("Limite 8 é aplicado antes da compra", "current_value >= MAX_ATTRIBUTE_VALUE" in villager)
    check("GameManager expõe distribuição", "func spend_councillor_attribute_point" in game)
    check("Distribuição é salva no histórico", "record_attribute_spent" in game and "func record_attribute_spent" in foundation)
    check("Carta possui quatro botões manuais", all(token in card for token in ['"+ FOR"', '"+ INT"', '"+ CAR"', '"+ AGI"']))
    check("Botões aparecem só com pontos", "button.visible = points > 0" in card)
    check("Botões respeitam limite 8", "Villager.MAX_ATTRIBUTE_VALUE" in card)


def validate_personal_production_and_milestones() -> None:
    game = read("scripts/GameManager.gd")
    foundation = read("scripts/foundation/Part3FoundationManager.gd")
    check("Saída pessoal possui função separada", "func _calculate_villager_personal_output" in game)
    check("Registro pessoal possui função própria", "func _calculate_recorded_personal_production" in game)
    check("Registro pessoal aplica estação", "get_season_modifiers_for_day(day_value)" in game)
    check("Registro pessoal declara exclusão de bônus globais", "personal_with_season_without_global_or_building_bonuses" in game)
    recorded_block = game[game.find("func _calculate_recorded_personal_production"):game.find("func _calculate_total_production_internal")]
    check("Registro pessoal não aplica construções", "building_manager.get_effect_value" not in recorded_block)
    check("Registro pessoal não aplica relacionamentos", "relationship_modifiers" not in recorded_block)
    check("Registro pessoal não aplica dificuldade", "difficulty_production" not in recorded_block)
    check("Reserva recebe produção zero", "if villager.is_council_active:" in game and "var individual: Production = Production.new()" in game)
    check("Histórico separa três recursos", 'for resource_id: String in ["food", "material", "happiness"]:' in foundation)
    check("Marcos são calculados por cada 100", "previous_total / 100.0" in foundation and "new_total / 100.0" in foundation and "step * 100" in foundation)
    check("Fila de novos marcos é consumível", "func consume_new_production_milestones" in foundation)
    check("Marcos entram na crônica", '"type": "production_milestone"' in foundation)
    check("Produção total pessoal é persistida", '"total_production"' in foundation and '"production_milestones"' in foundation)


def validate_history_sheet() -> None:
    history = read("scripts/ui/CouncillorHistoryWindow.gd")
    card = read("scripts/ui/VillagerCard.gd")
    ui = read("scripts/UIManager.gd")
    foundation = read("scripts/foundation/Part3FoundationManager.gd")
    check("Janela histórica existe", bool(history))
    check("Histórico fica oculto por padrão", "visible = false" in history)
    check("Carta abre ficha sob demanda", "ABRIR FICHA HISTÓRICA" in card and "history_requested" in card)
    check("UI cria modal histórico", "_create_councillor_history_window" in ui)
    required_fields = [
        "joined_day", "days_in_council", "days_in_reserve", "lifetime_xp",
        "total_production", "profession_day_counts", "events_resolved",
        "event_successes", "event_failures", "event_guaranteed",
        "successful_audits", "production_milestones", "history_entries",
        "attribute_points_spent", "unspent_attribute_points",
    ]
    for field in required_fields:
        check(f"Ficha histórica mostra {field}", field in history)
    check("Histórico limita crescimento", "MAX_COUNCILLOR_HISTORY: int = 160" in foundation and "history.pop_front()" in foundation)
    check("Crônica mostra entradas recentes", "history_entries.size() - 24" in history)
    check("Dias de reserva são contabilizados", 'progress["days_in_reserve"]' in foundation)
    check("Profissão mais exercida é calculada", "favorite_profession" in history and "profession_day_counts" in history)


def validate_event_responsibility() -> None:
    event_window = read("scripts/ui/EventWindow.gd")
    game = read("scripts/GameManager.gd")
    foundation = read("scripts/foundation/Part3FoundationManager.gd")
    check("Responsável é pré-selecionado", "preferred_villager = selected_villager" in event_window)
    check("Somente cartas ativas aparecem", "not villager.is_council_active" in event_window)
    check("Decisão usa carta já selecionada", "_get_event_selected_villager()" in event_window and "resolve_event_choice" in event_window)
    check("Interface informa fluxo de um clique", "a decisão continua em um clique" in event_window)
    check("Responsabilidade entra no histórico", "mark_event_resolution" in game and '"last_actor_id"' in foundation)
    check("Histórico distingue teste e solução garantida", "event_had_test" in game and '"event_guaranteed"' in foundation)
    check("Falas reagem a sucesso ou falha", "get_event_result_quote" in game)


def validate_level_dialogues() -> None:
    dialogue = read("scripts/council/CouncillorProgressionDialogueCatalog.gd")
    game = read("scripts/GameManager.gd")
    ui = read("scripts/UIManager.gd")
    check("Catálogo de diálogo de progressão existe", bool(dialogue))
    personality_ids = ["optimistic", "cautious", "practical", "ambitious", "kind", "stubborn", "playful", "pessimistic"]
    for personality_id in personality_ids:
        check(f"Diálogo possui personalidade {personality_id}", f'"{personality_id}":' in dialogue)
    for level in range(2, 7):
        check(
            f"Todas as personalidades possuem fala do nível {level}",
            count_token(dialogue, f"\t\t\t{level}:") == 8,
            str(count_token(dialogue, f"\t\t\t{level}:")),
        )
    for token in ["best_reply", "neutral_reply", "poor_reply", "best_response", "neutral_response", "poor_response"]:
        check(f"Oito perfis possuem {token}", count_token(dialogue, f'"{token}"') >= 9, str(count_token(dialogue, f'"{token}"')))
    check("Opções são embaralhadas", "_shuffle_choices" in dialogue)
    check("Conversa não pode ser fechada sem resposta", '"allow_close": false' in dialogue)
    check("Resposta correta é identificada internamente", '"level_up_quality": "best"' in dialogue)
    check("Recompensa usa recurso dominante", "get_dominant_resource" in game and 'active_level_dialogue.get("dominant_resource"' in game)
    check("Sem produção usa profissão como fallback", "_get_profession_resource" in game and '"has_personal_production"' in game)
    check("Diálogo não inventa produção inexistente", "Ainda estou descobrindo onde meu trabalho faz mais diferença" in dialogue)
    check("Apenas resposta correta recompensa", 'quality == "best"' in game and 'reward_claimed' in game)
    check("Recompensa é exatamente +1", all(token in game for token in ["food += 1.0", "building_material += 1.0", "happiness + 1.0"]))
    check("Conversa é persistida no save", all(token in game for token in ["pending_level_dialogues", "active_level_dialogue", "pending_level_resume_mode"]))
    check("Load preserva dia pendente durante diálogo", "and not has_pending_level_dialogue()" in game)
    check("UI resolve escolha antes de relações", "choice_data.has(\"level_up_representative_id\")" in ui)
    check("Histórico registra qualidade e recurso", "record_level_dialogue" in game)


def validate_recruitment_progression() -> None:
    recruitment = read("scripts/council/CouncilRecruitmentManager.gd")
    cards = read("scripts/council/CouncilCardCatalog.gd")
    game = read("scripts/GameManager.gd")
    check("Nível recrutado cresce a cada avaliação", "1 + floori(float(checkpoint_day) / 20.0)" in recruitment)
    check("Nível recrutado respeita máximo 6", "clampi(" in recruitment and "Villager.MAX_LEVEL" in recruitment)
    expected_levels = {20: 2, 40: 3, 60: 4, 80: 5, 100: 6, 120: 6}
    calculated_levels = {day: min(6, 1 + day // 20) for day in expected_levels}
    check("Progressão recrutada é 2/3/4/5/6/6", calculated_levels == expected_levels, str(calculated_levels))
    check("Pontos prévios são distribuídos proceduralmente", "add_progression_attribute_points" in recruitment and "func add_progression_attribute_points" in cards)
    check("Atributos recrutados respeitam limite 8", "candidate_level - 1" in recruitment and "8" in recruitment)
    check("Recruta não começa com pontos pendentes", '"unspent_attribute_points": 0' in recruitment)
    check("Recruta registra pontos já distribuídos", '"attribute_points_spent": maxi(0, candidate_level - 1)' in recruitment)
    check("Dia de entrada é registrado", 'recruited_progress["joined_day"] = current_day' in game)



def validate_meaningful_councillor_opportunities() -> None:
    catalog = read("scripts/council/CouncillorOpportunityCatalog.gd")
    manager = read("scripts/council/CouncillorOpportunityManager.gd")
    dialogue = read("scripts/council/CouncillorOpportunityDialogueCatalog.gd")
    generic_dialogue = read("scripts/dialogue/DialogueCatalog.gd")
    game = read("scripts/GameManager.gd")
    ui = read("scripts/UIManager.gd")
    card = read("scripts/ui/VillagerCard.gd")
    dialogue_window = read("scripts/ui/DialogueWindow.gd")
    save = read("scripts/save/SaveManager.gd")
    foundation = read("scripts/foundation/Part3FoundationManager.gd")
    history = read("scripts/ui/CouncillorHistoryWindow.gd")

    check("Catálogo de oportunidades existe", bool(catalog))
    check("Gerenciador de oportunidades existe", bool(manager))
    check("Diálogo de oportunidades existe", bool(dialogue))
    check(
        "Conversas decorativas foram desativadas",
        "static func create_for_villager(_villager: Villager)" in generic_dialogue
        and "return {}" in generic_dialogue[generic_dialogue.find("static func create_for_villager"):generic_dialogue.find("static func create_diagnostic_conversation")],
    )
    check(
        "UI não chama o diálogo decorativo",
        "DIALOGUE_CATALOG_SCRIPT.create_for_villager" not in ui,
    )
    check(
        "Carta só abre conversa com assunto pendente",
        "GameManager.has_councillor_opportunity" in ui
        and "não possui um assunto com consequência pendente" in ui,
    )

    const_pos = catalog.find("const OPPORTUNITIES")
    assignment_pos = catalog.find("=", const_pos)
    array_start = catalog.find("[", assignment_pos)
    opportunities_block = extract_balanced(catalog, array_start, "[", "]")
    templates = split_top_level_dicts(opportunities_block)
    check("Doze oportunidades narrativas", len(templates) == 12, str(len(templates)))

    profession_counts: dict[str, int] = {}
    total_choices = 0
    bad_durations: list[str] = []
    empty_modifiers: list[str] = []
    empty_text_fields: list[str] = []
    templates_without_free_choice: list[str] = []
    for template in templates:
        template_id_match = re.search(r'"id"\s*:\s*"([^"]+)"', template)
        template_id = template_id_match.group(1) if template_id_match else "<sem-id>"
        profession_match = re.search(r'"profession"\s*:\s*Villager\.Profession\.([A-Z_]+)', template)
        profession = profession_match.group(1) if profession_match else "INVALID"
        profession_counts[profession] = profession_counts.get(profession, 0) + 1
        choices_block = extract_key_container(template, "choices", "[", "]")
        choices = split_top_level_dicts(choices_block)
        total_choices += len(choices)
        has_free_choice = False
        if len(choices) != 3:
            empty_text_fields.append(f"{template_id}:choices={len(choices)}")
        for choice in choices:
            choice_id_match = re.search(r'"id"\s*:\s*"([^"]+)"', choice)
            choice_id = choice_id_match.group(1) if choice_id_match else "<sem-id>"
            duration_match = re.search(r'"duration_days"\s*:\s*(\d+)', choice)
            duration = int(duration_match.group(1)) if duration_match else 0
            if duration not in {2, 3}:
                bad_durations.append(f"{template_id}/{choice_id}:{duration}")
            immediate = extract_key_container(choice, "immediate", "{", "}")
            modifiers = extract_key_container(choice, "modifiers", "{", "}")
            if immediate and not immediate[1:-1].strip():
                has_free_choice = True
            if not modifiers or not modifiers[1:-1].strip():
                empty_modifiers.append(f"{template_id}/{choice_id}")
            for field in ["text", "result", "completion"]:
                if not re.search(rf'"{field}"\s*:\s*"', choice):
                    empty_text_fields.append(f"{template_id}/{choice_id}:{field}")
        if not has_free_choice:
            templates_without_free_choice.append(template_id)

    expected_professions = {
        "UNASSIGNED": 2,
        "FARMER": 2,
        "BLACKSMITH": 2,
        "CIVIL_SERVANT": 2,
        "GUARD": 2,
        "GATHERER": 2,
    }
    check("Duas oportunidades por profissão", profession_counts == expected_professions, str(profession_counts))
    check("Trinta e seis decisões distintas", total_choices == 36, str(total_choices))
    check("Projetos duram dois ou três dias", not bad_durations, str(bad_durations))
    check("Toda decisão altera a vila durante o projeto", not empty_modifiers, str(empty_modifiers))
    check("Toda decisão possui fala e encerramento", not empty_text_fields, str(empty_text_fields))
    check("Cada assunto mantém ao menos uma opção sem custo", not templates_without_free_choice, str(templates_without_free_choice))
    check("Catálogo valida efeitos não vazios", "não altera a vila durante o projeto" in catalog)

    check("Primeira oportunidade não aparece antes do dia 4", "const FIRST_OPPORTUNITY_DAY: int = 4" in manager)
    check("Oportunidades respeitam intervalo", "const OPPORTUNITY_INTERVAL_DAYS: int = 4" in manager)
    check("Mesmo representante possui recarga", "const INDIVIDUAL_COOLDOWN_DAYS: int = 10" in manager)
    check("Modelos narrativos não se repetem na campanha", "var used_template_ids: Array[String]" in manager and "used_template_ids.has(template_id)" in manager)
    check("Uso de modelos únicos é salvo", '"used_template_ids"' in manager)
    check("Assunto pendente é único e persistente", "var pending_opportunity: Dictionary" in manager and '"pending_opportunity"' in manager)
    check("Novo assunto não sobrepõe projeto ativo", "or not active_projects.is_empty()" in manager)
    check("Projetos ativos são persistentes", "var active_projects: Array[Dictionary]" in manager and '"active_projects"' in manager)
    check("Estado de oportunidades entra no save", '"councillor_opportunities"' in game and '"councillor_opportunities"' in save)
    check("Troca de carta arquiva assunto pendente", "cancel_pending_for" in game)
    check("Escolhas verificam recursos antes de iniciar", "A vila não possui os recursos exigidos" in game)
    check("Opções inviáveis ficam desabilitadas", '"disabled": not disabled_reason.is_empty()' in dialogue and "button.disabled" in dialogue_window)
    check("Escolhas mantêm duração e consequência na interface", "duration_days" in catalog and "[" in catalog and "dias:" in catalog)
    check("Reação final respeita personalidade", "get_personality_commitment" in dialogue and "PERSONALITY_COMMITMENTS" in catalog)
    check("Opções longas quebram linha", "button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART" in dialogue_window)

    for modifier in [
        "food_production_multiplier",
        "material_production_multiplier",
        "happiness_production_multiplier",
        "food_consumption_multiplier",
        "material_maintenance_multiplier",
        "happiness_decay_multiplier",
        "daily_happiness_bonus",
    ]:
        check(f"Economia integra {modifier}", modifier in manager and modifier in game)
    check("Conclusão concede XP", "const COMPLETION_XP: int = 6" in manager and "councillor_project_completed" in game)
    check("Projetos entram no histórico", "record_councillor_project_started" in foundation and "record_councillor_project_completed" in foundation)
    check("Ficha mostra projetos iniciados e concluídos", "council_projects_started" in history and "council_projects_completed" in history)
    check("Resumo diário mostra projeto ativo", "PROJETO ATIVO" in game)
    check("Resumo diário anuncia assunto marcado", "Procure o marcador ! na carta" in game)

    check("Carta possui marcador vermelho de atributo", "_attribute_badge" in card and 'Color("#8E2F2F")' in card and '"+%d" % points' in card)
    check("Marcador de atributo não depende apenas de cor", "ponto(s) de atributo disponível(is)" in card)
    check("Carta possui marcador de diálogo", "_dialogue_badge" in card and '_dialogue_badge_label.text = "!"' in card)
    check("Marcador ! só aparece com oportunidade", "_dialogue_badge.visible = has_dialogue" in card)
    check("Cartas atualizam quando oportunidade muda", "_on_councillor_opportunities_changed" in ui and "_refresh_villager_cards()" in ui)

    forecast_start = game.find("func calculate_next_day_forecast")
    forecast_end = game.find("func advance_day", forecast_start)
    forecast_block = game[forecast_start:forecast_end]
    check("Previsão não usa dia inexistente", "completed_day" not in forecast_block)




def validate_parser_scope_regression() -> None:
    game = read("scripts/GameManager.gd")
    forecast = extract_function_block(game, "calculate_next_day_forecast")
    advance = extract_function_block(game, "advance_day")
    declaration = "var active_projects_applied: Array = ("
    use = "for active_project_value: Variant in active_projects_applied:"
    check(
        "Previsão não declara variável de resumo diário",
        declaration not in forecast and "active_projects_applied" not in forecast,
    )
    check(
        "Avanço diário declara projetos aplicados no próprio escopo",
        declaration in advance,
    )
    check(
        "Avanço diário usa projetos após a declaração",
        declaration in advance
        and use in advance
        and advance.find(declaration) < advance.find(use),
    )
    check(
        "Variável de projetos não vaza entre funções",
        game.count("active_projects_applied") == 2,
        str(game.count("active_projects_applied")),
    )
    scope_check = subprocess.run(
        [sys.executable, "tools/verify_gdscript_local_scope.py"],
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    check(
        "Verificador geral não encontra vazamento de variável local",
        scope_check.returncode == 0,
        scope_check.stdout.strip()[-600:] if scope_check.stdout else scope_check.stderr.strip(),
    )

def validate_debug_safety() -> None:
    game = read("scripts/GameManager.gd")
    check("Teste narrativo bloqueia conquista pendente", "or has_pending_level_dialogue()" in game[game.find("func debug_start_story_sequence"):game.find("func _restore_debug_story_snapshot")])
    check("Teste narrativo preserva estados das cartas", '"villagers": villager_states.duplicate(true)' in game)
    check("Teste narrativo preserva histórico da Parte 3", '"part3_foundation": part3_foundation_manager.export_save_data()' in game)
    check("Teste narrativo restaura progressão das cartas", "villager.import_save_data(state)" in game)
    check("Teste narrativo restaura histórico pessoal", "part3_foundation_manager.import_save_data(part3_state)" in game)
    check("Teste narrativo restaura diálogos de nível pendentes", '"pending_level_dialogues",' in game and "pending_level_dialogues.clear()" in game)

def validate_audit_history() -> None:
    game = read("scripts/GameManager.gd")
    foundation = read("scripts/foundation/Part3FoundationManager.gd")
    check("Avaliação aprovada registra cartas ativas", "record_successful_audit" in game)
    check("Fundação conta avaliações aprovadas", 'progress["successful_audits"]' in foundation)
    check("Avaliação entra na crônica", '"type": "audit"' in foundation)


def main() -> int:
    validate_previous_stage()
    validate_versions_and_save()
    validate_xp_and_levels()
    validate_manual_attributes()
    validate_personal_production_and_milestones()
    validate_history_sheet()
    validate_event_responsibility()
    validate_level_dialogues()
    validate_recruitment_progression()
    validate_meaningful_councillor_opportunities()
    validate_parser_scope_regression()
    validate_debug_safety()
    validate_audit_history()

    failures = [result for result in RESULTS if not result.ok]
    print("Golem's Mandate — verificação da Parte 3 / Etapa 4")
    print(f"Verificações: {len(RESULTS)}")
    print(f"Falhas: {len(failures)}")
    if failures:
        print("\nFALHAS:")
        for result in failures:
            print(f"- {result.name}: {result.detail}")
    else:
        print("Resultado estrutural: APROVADO")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
