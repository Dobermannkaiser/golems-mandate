#!/usr/bin/env python3
"""Auditoria estática da Parte 3 / Etapa 8 — memória e acontecimentos encadeados.

Não executa Godot nem substitui o teste humano. Verifica contratos de conteúdo,
integração, persistência, histórico, anti-repetição, vestígios visuais e as
correções incorporadas da Etapa 7.
"""
from __future__ import annotations

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


def read(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


def check(name: str, condition: bool, detail: str = "") -> None:
    RESULTS.append(Result(name, bool(condition), detail))


def validate_version_and_save() -> None:
    project = read("project.godot")
    save = read("scripts/save/SaveManager.gd")
    diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")
    menu = read("scripts/ui/MainMenu.gd")
    layout = read("scripts/UIManagerVariantB.gd")
    game = read("scripts/GameManager.gd")

    check("Versão pública é 3.8.2", 'config/version="3.8.2"' in project)
    check("Menu mostra 3.8.2", '"3.8.2"' in menu)
    check("Layout mostra v3.8.2", "v3.8.2" in layout)
    check("Diagnóstico exige 3.8.2", 'project_version != "3.8.2"' in diagnostics)
    check("Save evoluiu para versão 17", "const SAVE_VERSION: int = 17" in save)
    check("Save 15 é aceito", "save_version < 15" in save)
    check("Migração 15 para 16 existe", "15:" in save and 'game_state["founder_memories"]' in save)
    check("Estado de memória entra no save", 'game_state["founder_memories"]' in game)
    check("Estado de memória é obrigatório", '"founder_memories",' in save)
    check("Escrita usa temporário", "SAVE_TEMP_PATH" in save and "FileAccess.WRITE" in save)
    check("Escrita preserva backup", "SAVE_BACKUP_PATH" in save and "rename_absolute" in save)
    check("Temporário é verificado", "get_file_as_string(SAVE_TEMP_PATH) != serialized" in save)
    check("Validação cruza sistemas", "func _validate_cross_system_state" in save)
    check("Validação cruza acontecimento ativo", "active_memory_event_ids" in save and "active_event_id" in save)
    check("Validação protege sequência de recrutas", "_extract_recruit_sequence" in save and "max_recruit_sequence" in save)


def validate_memory_catalog() -> None:
    catalog = read("scripts/events/FounderMemoryCatalog.gd")
    manager = read("scripts/events/FounderMemoryManager.gd")
    diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")

    chain_ids = ["recognition", "responsibility", "belonging", "convictions"]
    event_ids = re.findall(r'"id": "(founder_memory_[^"]+)"', catalog)
    for chain_id in chain_ids:
        check(f"Cadeia {chain_id} existe", f'"{chain_id}"' in catalog)
        check(
            f"Cadeia {chain_id} tem abertura e consequência",
            f'founder_memory_{chain_id}_opening' in event_ids
            and f'founder_memory_{chain_id}_consequence' in event_ids,
        )
    check("Catálogo possui exatamente oito acontecimentos", len(set(event_ids)) == 8, str(len(set(event_ids))))
    check("Janela tardia é de dez dias", "const CONSEQUENCE_WINDOW_DAYS: int = 10" in manager)
    check("Atribuição usa personalidade", "personality_id" in catalog)
    check("Atribuição usa passiva", "passive_id" in catalog)
    check("Atribuição usa atributos", 'founder.get("attributes"' in catalog)
    check("Atribuição não repete fundador", "remaining_ids.erase(selected_id)" in manager)
    check("Cadeias são inicializadas uma vez", "if initialized:" in manager)
    check("Expiração possui estado próprio", 'STATUS_EXPIRED: String = "expired"' in manager)
    expire_block = manager.split("func _expire_windows", 1)[1].split("func ", 1)[0]
    check("Expiração é silenciosa", "history" not in expire_block and "record_" not in expire_block)
    check("Abertura guarda escolha", 'state["opening_choice_id"] = choice_id' in manager)
    check("Consequência usa escolha lembrada", "_opening_choice_summary(opening_choice_id)" in catalog)
    check("Condição de reconhecimento usa Conselho", "days_in_council" in manager)
    check("Condição de responsabilidade usa pressão", "food_shortage_days" in manager and "material_shortage_days" in manager)
    check("Condição de pertencimento usa composição", "council_signature" in manager)
    check("Condição de convicções usa construções", "building_signature" in manager)
    check("Variantes sazonais entram no texto", "season_context" in catalog and "season_name" in manager)
    check("Builds entram no texto", "building_variants" in manager and "BUILDING_VARIANT_CATALOG_SCRIPT" in manager)
    check("Outros fundadores reagem", "_get_observer_text" in manager)
    check("Diagnóstico inclui memória", '"Memória dos fundadores"' in diagnostics)


def validate_runtime_integration() -> None:
    game = read("scripts/GameManager.gd")
    events = read("scripts/events/EventManager.gd")
    foundation = read("scripts/foundation/Part3FoundationManager.gd")
    event_window = read("scripts/ui/EventWindow.gd")
    history_window = read("scripts/ui/CouncillorHistoryWindow.gd")
    ui = read("scripts/UIManager.gd")

    check("Manager de memória é instanciado", "FOUNDER_MEMORY_MANAGER_SCRIPT.new()" in game)
    check("Fundadores são inicializados pelo elenco", "_ensure_founder_memory_initialized" in game)
    check("Capítulo mantém prioridade", game.index("story_manager.should_trigger_chapter") < game.index("founder_memory_manager.try_prepare_event"))
    check("Memória precede acontecimento aleatório", game.index("founder_memory_manager.try_prepare_event") < game.index("event_manager.try_start_event(completed_day)"))
    check("Acontecimento de memória é forçado", "event_manager.start_forced_event" in game)
    check("Definições dinâmicas são registradas", "set_external_events" in events and "get_registered_events" in game)
    check("Definições dinâmicas são persistidas", '"known_events": known_events.duplicate(true)' in read("scripts/events/FounderMemoryManager.gd"))
    check("Ator fixo é respeitado", "fixed_actor_id" in event_window and "memory_founder_id" in game)
    check("XP pertence ao fundador", "credited_villager" in game and '"event_%s" % resolved_event_id' in game)
    check("Histórico pessoal possui tipo próprio", "record_founder_memory_entry" in foundation)
    check("Janela histórica formata as memórias", "founder_memory_opening" in history_window and "founder_memory_consequence" in history_window)
    check("Registro genérico duplicado é evitado", "not is_founder_memory" in game and "record_personal_event_entry" in foundation)
    check("Guia explica a janela", "Nos dez dias concluídos seguintes" in ui)
    check("Guia explica a expiração", "termina silenciosamente" in ui)
    check("Guia indica a Ficha Histórica", "Ficha Histórica" in ui)


def validate_repetition_and_visuals() -> None:
    events = read("scripts/events/EventManager.gd")
    memory = read("scripts/events/FounderMemoryManager.gd")
    visuals = read("scripts/ui/BuildingVisuals.gd")
    ui = read("scripts/UIManager.gd")

    check("Eventos recentes são salvos", '"recent_event_ids"' in events and "RECENT_EVENT_LIMIT" in events)
    check("Eventos recentes são filtrados", "non_recent_candidates" in events)
    check("Fallback procura alternativa não recente", "_all_candidates_are_recent" in events)
    marker_ids = ["founder_banner", "repair_cairn", "shared_bench", "council_lantern"]
    for marker_id in marker_ids:
        check(f"Vestígio {marker_id} existe", marker_id in memory and marker_id in visuals)
    check("Vestígios não são duplicados", "not _has_visual_marker(marker_id)" in memory)
    check("Vestígios são persistidos", '"visual_markers": visual_markers.duplicate(true)' in memory)
    check("Vila recebe atualização visual", "update_memory_markers" in visuals and "update_memory_markers" in ui)
    check("Desenho é nativo do projeto", "_draw_memory_markers" in visuals)


def validate_stage7_repairs() -> None:
    game = read("scripts/GameManager.gd")
    recruitment = read("scripts/council/CouncilRecruitmentManager.gd")
    window = read("scripts/ui/RecruitmentWindow.gd")

    species_function = game.split("func select_recruitment_species", 1)[1].split("func ", 1)[0]
    check("Escolha de espécie aciona autosave", "_autosave_if_enabled()" in species_function)
    check("Oferta antiga é reconciliada", "func reconcile_legacy_offer" in recruitment and "relationship_points" in recruitment)
    check("Load chama reconciliação", "reconcile_legacy_offer" in game)
    check("Janela de recrutamento possui scroll", "ScrollContainer.new()" in window)
    check("Janela é responsiva", "_apply_responsive_layout" in window and "available_width < 780.0" in window)
    check("Janela não exige 920 por 590", "920" not in window and "590" not in window)
    check("Foco fica dentro da decisão", "_configure_focus_loop" in window and "focus_neighbor_top" in window)
    check("Scroll acompanha foco", "ensure_control_visible" in window)
    check("Cancelar não oculta decisão obrigatória", 'event.is_action_pressed("ui_cancel")' in window and "hide_window()" not in window.split("func _unhandled_input", 1)[1])


def main() -> int:
    validate_version_and_save()
    validate_memory_catalog()
    validate_runtime_integration()
    validate_repetition_and_visuals()
    validate_stage7_repairs()

    failures = [result for result in RESULTS if not result.ok]
    print("Golem's Mandate — verificação da Parte 3 / Etapa 8 — preservada na v3.8.2")
    print(f"Verificações: {len(RESULTS)}")
    print(f"Aprovadas: {len(RESULTS) - len(failures)}")
    print(f"Falhas: {len(failures)}")
    if failures:
        for result in failures:
            suffix = f" — {result.detail}" if result.detail else ""
            print(f"[FALHA] {result.name}{suffix}")
        return 1
    print("Resultado: APROVADO NA AUDITORIA ESTÁTICA")
    return 0


if __name__ == "__main__":
    sys.exit(main())
