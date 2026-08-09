#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from collections import Counter
from dataclasses import dataclass
from pathlib import Path

from PIL import Image

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


VARIANT_IDS = [
    "silo_reserve",
    "community_kitchen",
    "intensive_sawmill",
    "carpentry_workshop",
    "deep_reservoir",
    "community_fountain",
    "community_market",
    "public_garden",
    "stone_bastion",
    "vigilant_gates",
]

BUILDING_IDS = ["barn", "sawmill", "well", "square", "palisade"]

PREVIEW_PATHS = {
    "silo_reserve": "assets/buildings/variants/barn_silo.png",
    "community_kitchen": "assets/buildings/variants/barn_kitchen.png",
    "intensive_sawmill": "assets/buildings/variants/sawmill_intensive.png",
    "carpentry_workshop": "assets/buildings/variants/sawmill_carpentry.png",
    "deep_reservoir": "assets/buildings/variants/well_reservoir.png",
    "community_fountain": "assets/buildings/variants/well_fountain.png",
    "community_market": "assets/buildings/variants/square_market.png",
    "public_garden": "assets/buildings/variants/square_garden.png",
    "stone_bastion": "assets/buildings/variants/palisade_bastion.png",
    "vigilant_gates": "assets/buildings/variants/palisade_gates.png",
}


def validate_versioning() -> None:
    project = read("project.godot")
    save = read("scripts/save/SaveManager.gd")
    tutorial = read("scripts/tutorial/TutorialManager.gd")
    diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")
    main_menu = read("scripts/ui/MainMenu.gd")
    variant = read("scripts/UIManagerVariantB.gd")

    check("Versão pública é 3.8.2", 'config/version="3.8.2"' in project)
    check("Save atual é versão 17", "const SAVE_VERSION: int = 17" in save)
    check("Tutorial revisado está na versão 7", "const TUTORIAL_VERSION: int = 7" in tutorial)
    check("Oráculo exige versão 3.8.2", 'project_version != "3.8.2"' in diagnostics)
    check("Oráculo exige save 17", "SAVE_VERSION != 17" in diagnostics)
    check("Menu usa versão 3.8.2", '"3.8.2"' in main_menu)
    check("Layout mostra v3.8.2", "v3.8.2" in variant)
    check("Cena principal mantém res://", 'run/main_scene="res://scenes/main.tscn"' in project)
    check("Project.godot sem UID frágil", "uid://" not in project)


def validate_catalog() -> None:
    catalog = read("scripts/buildings/BuildingVariantCatalog.gd")
    check("Catálogo de builds existe", (ROOT / "scripts/buildings/BuildingVariantCatalog.gd").is_file())
    check("Build final continua no nível 3", "const FINAL_LEVEL: int = 3" in catalog)

    found_ids = re.findall(r'\n\s*"id":\s*"([^"]+)"', catalog)
    variant_ids = [value for value in found_ids if value in VARIANT_IDS]
    check("Dez builds finais cadastradas", len(variant_ids) == 10, str(variant_ids))
    check("IDs de build únicos", len(set(variant_ids)) == 10, str(variant_ids))
    check("Todas as builds esperadas existem", set(variant_ids) == set(VARIANT_IDS), str(variant_ids))

    building_values = re.findall(r'"building_id":\s*"([^"]+)"', catalog)
    counts = Counter(value for value in building_values if value in BUILDING_IDS)
    for building_id in BUILDING_IDS:
        check(
            f"Duas builds para {building_id}",
            counts[building_id] == 2,
            str(counts[building_id]),
        )

    for token in [
        '"name":', '"identity":', '"effect_text":', '"effects":',
        '"preview_path":', '"preferred_npc_id":', '"dialogue_id":',
        '"fallback_dialogue_id":', '"event_interaction_ids":',
    ]:
        check(
            f"Todas as builds possuem {token}",
            catalog.count(token) >= 10,
            str(catalog.count(token)),
        )

    required_effects = [
        "food_production_bonus",
        "material_production_bonus",
        "happiness_decay_reduction",
        "daily_happiness_bonus",
        "maintenance_reduction",
        "fixed_food_consumption_reduction",
        "construction_cost_reduction",
    ]
    for effect in required_effects:
        check(f"Efeito {effect} está representado", effect in catalog)


def validate_visuals() -> None:
    visual_script = read("scripts/ui/BuildingVisuals.gd")
    check("Mapa de texturas de builds existe", "BUILDING_VARIANT_TEXTURES" in visual_script)
    check("Vila acompanha IDs das builds", "building_variants" in visual_script)
    check("Nível 3 usa textura da build", "level >= 3 and BUILDING_VARIANT_TEXTURES.has(variant_id)" in visual_script)
    check("Bastião possui detalhe procedural", 'variant_id == "stone_bastion"' in visual_script)
    check("Portões possuem detalhe procedural", 'variant_id == "vigilant_gates"' in visual_script)

    for variant_id, relative in PREVIEW_PATHS.items():
        path = ROOT / relative
        check(f"Imagem existe: {variant_id}", path.is_file(), relative)
        if not path.is_file():
            continue
        try:
            with Image.open(path) as image:
                check(f"PNG válido: {variant_id}", image.format == "PNG", str(image.format))
                check(f"Dimensão útil: {variant_id}", image.width >= 180 and image.height >= 160, str(image.size))
                has_alpha = "A" in image.getbands()
                check(f"Canal alfa: {variant_id}", has_alpha, image.mode)
                if has_alpha:
                    low, high = image.getchannel("A").getextrema()
                    check(
                        f"Transparência real: {variant_id}",
                        low < 255 and high == 255,
                        f"{low}-{high}",
                    )
        except Exception as exc:  # pragma: no cover - diagnostic path
            check(f"Imagem legível: {variant_id}", False, str(exc))


def validate_building_manager() -> None:
    manager = read("scripts/buildings/BuildingManager.gd")
    check("Fila de obras usa schema 2", "const QUEUE_STATE_VERSION: int = 2" in manager)
    for field in [
        "selected_build_variants",
        "variant_completion_days",
        "variant_event_uses",
    ]:
        check(f"Estado persistente {field}", f'"{field}":' in manager)
        check(f"Importa estado {field}", f'save_data.get(\n\t\t"{field}"' in manager or f'save_data.get("{field}"' in manager)

    check("Nível 3 exige build válida", "is_valid_for_building" in manager and "Escolha uma das duas builds finais" in manager)
    check("Build é guardada apenas na conclusão", "selected_build_variants[building_id] = variant_id" in manager and "finalize_completed_constructions" in manager)
    check("Cancelamento remove a ordem, não fixa a build", "construction_orders.remove_at(order_index)" in manager)
    check("Dia de conclusão é persistido", "variant_completion_days[building_id] = completed_day + 1" in manager)
    check("Uso em acontecimento é registrado", "func record_variant_event_use" in manager)
    check("Oficina reduz custos futuros", 'get_effect_value("construction_cost_reduction")' in manager)
    check("Cache deriva todos os efeitos da build", "BUILDING_VARIANT_CATALOG_SCRIPT.get_effects" in manager)
    check("Estado da janela expõe opções", '"variant_options": variant_options' in manager)
    check("Estado expõe histórico da build", '"variant_completion_day":' in manager and '"variant_event_uses":' in manager)


def validate_game_integration() -> None:
    game = read("scripts/GameManager.gd")
    story = read("scripts/story/StoryManager.gd")
    ui = read("scripts/UIManager.gd")

    check("Produção usa bônus das builds", 'get_effect_value(\n\t\t\t"food_production_bonus"' in game and '"material_production_bonus"' in game)
    check("Cozinha reduz consumo", "_get_building_fixed_food_reduction_for_day" in game)
    check("Contexto de evento contém builds", '"building_variants": building_manager.get_building_variants()' in game)
    check("Acontecimento registra uso da build", "record_variant_event_use" in game)
    check("Conclusão agenda reação narrativa", "_queue_building_variant_reaction" in game)
    check("Reação não duplica diálogo pendente", "had_pending_dialogue" in game and "if not queued or had_pending_dialogue" in game)
    check("StoryManager persiste fila de reações", '"custom_dialogue_queue":' in story)
    check("StoryManager persiste metadados", '"pending_custom_metadata":' in story)
    check("Fila é promovida após capítulo", story.count("_promote_next_custom_dialogue()") >= 5, str(story.count("_promote_next_custom_dialogue()")))
    check("UI solicita próxima reação enfileirada", "was_story_dialogue" in ui and 'call_deferred("_request_pending_story_dialogue")' in ui)


def validate_window() -> None:
    window = read("scripts/ui/BuildingWindow.gd")
    ui = read("scripts/UIManager.gd")
    check("Sinal de obra transporta build", "signal upgrade_requested(building_id: String, variant_id: String)" in window)
    check("UI repassa build ao GameManager", "GameManager.upgrade_building(\n\t\tbuilding_id,\n\t\tvariant_id" in ui)
    check("Botão anuncia build final", '"ESCOLHER BUILD FINAL' in window)
    check("Modal compara opções lado a lado", "variant_choice_cards" in window and "HBoxContainer.new()" in window)
    check("Modal mostra imagens", "current_variant_preview_path" in window or "preview_path" in window)
    check("Modal mostra identidade", 'variant.get("identity"' in window)
    check("Modal mostra efeito", 'variant.get("effect_text"' in window)
    check("Modal mostra custo e duração", 'variant.get("work_days"' in window and 'variant.get("cost"' in window)
    check("Confirmação explícita", '"CONFIRMAR BUILD"' in window)
    check("Aviso de irreversibilidade", "IRREVERSÍVEL" in window.upper())
    check("ESC fecha primeiro o modal", "variant_choice_overlay.visible" in window and "_hide_variant_choice()" in window)
    check("Build concluída fica visível", '"BUILD FINAL — %s"' in window)
    check("Dia e usos ficam visíveis", '"Concluída no dia %d • usada em %d acontecimento(s)."' in window)


def validate_events_and_dialogues() -> None:
    interaction_catalog = read("scripts/events/BuildingVariantEventCatalog.gd")
    event_catalog = read("scripts/events/EventCatalog.gd")
    magical_catalog = read("scripts/events/MagicalEventCatalog.gd")
    event_manager = read("scripts/events/EventManager.gd")
    event_window = read("scripts/ui/EventWindow.gd")
    dialogue_catalog = read("scripts/dialogue/BuildingVariantDialogueCatalog.gd")
    main_dialogue = read("scripts/dialogue/DialogueCatalog.gd")

    choice_ids = re.findall(r'"id":\s*"(variant_[^"]+)"', interaction_catalog)
    check("Vinte interações de build", len(choice_ids) == 20, str(len(choice_ids)))
    check("Interações possuem IDs únicos", len(set(choice_ids)) == 20, str(choice_ids))
    required_variants = re.findall(r'"required_building_variant":\s*"([^"]+)"', interaction_catalog)
    counts = Counter(required_variants)
    for variant_id in VARIANT_IDS:
        check(f"Duas interações para {variant_id}", counts[variant_id] == 2, str(counts[variant_id]))

    target_event_ids = re.findall(r'"event_id":\s*"([^"]+)"', interaction_catalog)
    event_sources = event_catalog + magical_catalog
    for event_id in sorted(set(target_event_ids)):
        check(
            f"Acontecimento-alvo existe: {event_id}",
            f'"id": "{event_id}"' in event_sources,
        )

    check("Interações são aplicadas ao catálogo", "apply_to_events(events)" in event_catalog)
    check("Requisito de build é validado", 'choice.get("required_building_variant"' in event_manager)
    check("Escolhas especiais recebem marcador", 'special_choice["is_build_variant_choice"] = true' in interaction_catalog)
    check("Escolha especial fica oculta sem build", 'choice.get("is_build_variant_choice"' in event_window and 'begins_with(\n\t\t\t\t"Exige a build"' in event_window)

    dialogue_ids = re.findall(r'^\s*"(building_variant_[^"]+)":\s*\{', dialogue_catalog, re.M)
    check("Vinte reações narrativas", len(dialogue_ids) == 20, str(len(dialogue_ids)))
    check("Reações possuem IDs únicos", len(set(dialogue_ids)) == 20, str(dialogue_ids))
    check("Kobi reage ao Mercado Comunitário", "building_variant_square_market_kobi" in dialogue_catalog and "Kobi Cobre-Fino" in dialogue_catalog)
    for npc_name in ["Mimo", "Aelric Brasa-Clara", "Kobi Cobre-Fino", "Orion Escamagelo", "Rubra Verbum", "Brunna Ana"]:
        check(f"NPC reage a construções: {npc_name}", npc_name in dialogue_catalog)
    check("Contexto vem do Narrador", '"speaker_name": "Narrador"' in dialogue_catalog)
    check("Catálogo principal delega reações", "BUILDING_VARIANT_DIALOGUE_CATALOG_SCRIPT.create" in main_dialogue)

    forbidden = ["interface", "mecânica", "bônus de", "clique", "nível 3", "save"]
    line_values = re.findall(r'"line":\s*"([^"]*)"', dialogue_catalog)
    for word in forbidden:
        check(
            f"Falas de construção não usam metalinguagem: {word}",
            all(word.casefold() not in line.casefold() for line in line_values),
        )


def validate_tutorials() -> None:
    ui = read("scripts/UIManager.gd")
    required_phrases = [
        "Ao planejar o nível 3 das cinco construções únicas",
        "A escolha se torna irreversível quando a obra é concluída",
        "BUILDS FINAIS IRREVERSÍVEIS",
        "Cancelar antes da conclusão libera uma nova escolha",
        "builds finais, dia de conclusão, usos em acontecimentos",
    ]
    for phrase in required_phrases:
        check(f"Tutorial explica: {phrase[:38]}", phrase in ui)
    check("Guia remove motivo antigo da campanha nova", "catálogo de passivas e os estados de profissão foram ampliados" not in ui)


def main() -> int:
    validate_versioning()
    validate_catalog()
    validate_visuals()
    validate_building_manager()
    validate_game_integration()
    validate_window()
    validate_events_and_dialogues()
    validate_tutorials()

    failures = [result for result in RESULTS if not result.ok]
    print("Golem's Mandate — verificação da Parte 3 / Etapa 6")
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
    sys.exit(main())
