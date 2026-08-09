#!/usr/bin/env python3
from __future__ import annotations

import argparse
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


def check(name: str, ok: bool, detail: str = "") -> None:
    RESULTS.append(Result(name, bool(ok), detail))


def read(relative: str) -> str:
    return (ROOT / relative).read_text(encoding="utf-8")


def strip_comments_and_strings(text: str) -> str:
    output: list[str] = []
    index = 0
    quote: str | None = None
    triple = False
    escaped = False
    while index < len(text):
        char = text[index]
        if quote is not None:
            if triple and text.startswith(quote * 3, index):
                output.extend("   ")
                index += 3
                quote = None
                triple = False
                continue
            if not triple and not escaped and char == quote:
                output.append(" ")
                index += 1
                quote = None
                continue
            if not triple and char == "\n":
                raise ValueError("string simples atravessa uma quebra de linha")
            output.append("\n" if char == "\n" else " ")
            if not triple:
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
            if text.startswith(char * 3, index):
                output.extend("   ")
                index += 3
                quote = char
                triple = True
            else:
                output.append(" ")
                index += 1
                quote = char
                escaped = False
            continue
        output.append(char)
        index += 1
    if quote is not None:
        raise ValueError("string não terminada")
    return "".join(output)


def delimiter_error(text: str) -> str | None:
    try:
        clean = strip_comments_and_strings(text)
    except ValueError as exc:
        return str(exc)
    pairs = {")": "(", "]": "[", "}": "{"}
    stack: list[tuple[str, int]] = []
    for index, char in enumerate(clean):
        if char in "([{":
            stack.append((char, index))
        elif char in ")]}" :
            if not stack or stack[-1][0] != pairs[char]:
                return f"delimitador inesperado {char} em {index}"
            stack.pop()
    if stack:
        char, index = stack[-1]
        return f"delimitador {char} não fechado em {index}"
    return None


def functions_in(text: str) -> set[str]:
    clean = strip_comments_and_strings(text)
    return set(re.findall(
        r"(?m)^\s*(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(",
        clean,
    ))


def inherited_functions(path: Path, seen: set[Path] | None = None) -> set[str]:
    seen = seen or set()
    if path in seen or not path.is_file():
        return set()
    seen.add(path)
    text = path.read_text(encoding="utf-8")
    result = functions_in(text)
    match = re.search(r'^extends\s+"res://([^"]+)"', text, re.M)
    if match:
        result |= inherited_functions(ROOT / match.group(1), seen)
    return result


def validate_all_scripts() -> None:
    for path in sorted(ROOT.rglob("*.gd")):
        relative = path.relative_to(ROOT).as_posix()
        text = path.read_text(encoding="utf-8")
        clean = strip_comments_and_strings(text)

        error = delimiter_error(text)
        check(f"Delimitadores: {relative}", error is None, error or "ok")

        function_names = re.findall(
            r"(?m)^\s*(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(",
            clean,
        )
        duplicates = sorted({
            name for name in function_names if function_names.count(name) > 1
        })
        check(
            f"Funções únicas: {relative}",
            not duplicates,
            ", ".join(duplicates) or "ok",
        )

        bad_draw_helpers = sorted(
            name for name in function_names if name.startswith("draw_")
        )
        check(
            f"Sem helpers draw_* conflitantes: {relative}",
            not bad_draw_helpers,
            ", ".join(bad_draw_helpers) or "ok",
        )

        callbacks = re.findall(
            r"\.connect\(\s*([A-Za-z_][A-Za-z0-9_]*)",
            clean,
            re.S,
        )
        available = inherited_functions(path)
        missing_callbacks = sorted({
            callback for callback in callbacks
            if callback not in available
            and callback not in {"queue_free", "hide", "show"}
        })
        check(
            f"Callbacks existem: {relative}",
            not missing_callbacks,
            ", ".join(missing_callbacks) or "ok",
        )

        private_calls = set(re.findall(
            r"(?<![.A-Za-z0-9_])(_[A-Za-z][A-Za-z0-9_]*)\s*\(",
            clean,
        ))
        missing_private_calls = sorted(
            private_calls - available
        )
        check(
            f"Chamadas privadas existem: {relative}",
            not missing_private_calls,
            ", ".join(missing_private_calls) or "ok",
        )

        for target in re.findall(r'preload\(\s*"res://([^"]+)"\s*\)', text, re.S):
            check(
                f"Preload existe: {relative} -> {target}",
                (ROOT / target).is_file(),
                target,
            )

        leading_spaces = [
            line_number + 1
            for line_number, line in enumerate(text.splitlines())
            if line.startswith(" ") and line.strip()
        ]
        check(
            f"Indentação por tab: {relative}",
            not leading_spaces,
            str(leading_spaces[:8]) if leading_spaces else "ok",
        )


def parse_quoted_values(block: str) -> list[str]:
    return re.findall(r'"([^"]+)"', block)


def extract_dictionary_array(text: str, constant_name: str) -> str:
    match = re.search(
        rf"const\s+{re.escape(constant_name)}[^=]*=\s*\[(.*?)\n\]",
        text,
        re.S,
    )
    return match.group(1) if match else ""


def validate_catalogs() -> None:
    cards = read("scripts/council/CouncilCardCatalog.gd")
    personalities = read("scripts/council/CouncillorPersonalityCatalog.gd")
    passive_catalog = read("scripts/council/CouncilPassiveCatalog.gd")

    check("Catálogo das cartas existe", (ROOT / "scripts/council/CouncilCardCatalog.gd").is_file())
    check("Catálogo de personalidades existe", (ROOT / "scripts/council/CouncillorPersonalityCatalog.gd").is_file())
    check("Atributos começam com total 10", "const ATTRIBUTE_TOTAL: int = 10" in cards)
    check("Atributos começam no mínimo 1", "const ATTRIBUTE_MINIMUM: int = 1" in cards)
    check("Atributos começam no máximo 5", "const ATTRIBUTE_INITIAL_MAXIMUM: int = 5" in cards)
    check("Carta começa no nível 1", "const STARTING_LEVEL: int = 1" in cards)
    check("Carta começa com 0 XP", "const STARTING_XP: int = 0" in cards)
    check("Fórmula inicial de XP cadastrada", "80 + 20 * maxi(0, level - 1)" in cards)

    expected_species = [
        "Passos-Leves", "Elfo", "Anã", "Draconato", "Meio-demônia", "Kobold"
    ]
    all_names: list[str] = []
    for species in expected_species:
        pattern = rf'"{re.escape(species)}"\s*:\s*\[(.*?)\]'
        match = re.search(pattern, cards, re.S)
        names = parse_quoted_values(match.group(1)) if match else []
        check(f"Seis nomes para {species}", len(names) == 6, str(names))
        check(f"Nomes únicos em {species}", len(set(names)) == len(names), str(names))
        all_names.extend(names)
    check("Nomes únicos entre espécies", len(set(all_names)) == len(all_names), str(len(all_names)))

    passive_block = extract_dictionary_array(passive_catalog, "PASSIVES")
    passive_ids = re.findall(r'"id":\s*"([^"]+)"', passive_block)
    check("Quinze passivas regulares", len(passive_ids) == 15, str(passive_ids))
    check("Passivas regulares únicas", len(set(passive_ids)) == 15, str(passive_ids))
    check(
        "Passivas têm nome, descrição e condição",
        passive_block.count('"name":') == 15
        and passive_block.count('"description":') == 15
        and passive_block.count('"condition":') == 15,
    )
    check("Catálogo de cartas delega passivas", "PASSIVE_CATALOG_SCRIPT.get_randomized_passives" in cards)

    personality_block = extract_dictionary_array(personalities, "DEFINITIONS")
    personality_ids = re.findall(r'"id":\s*"([^"]+)"', personality_block)
    expected_personalities = {
        "optimistic", "cautious", "practical", "ambitious",
        "kind", "stubborn", "playful", "pessimistic",
    }
    check("Oito arquétipos de personalidade", set(personality_ids) == expected_personalities, str(personality_ids))
    for field in [
        "name", "description", "intro", "practical", "curious",
        "cautious", "winter", "prepare", "watch", "ignore",
    ]:
        check(
            f"Toda personalidade possui {field}",
            personality_block.count(f'"{field}":') == 8,
            str(personality_block.count(f'"{field}":')),
        )


def validate_generation_and_persistence() -> None:
    game = read("scripts/GameManager.gd")
    villager = read("scripts/Villager.gd")
    save = read("scripts/save/SaveManager.gd")
    foundation = read("scripts/foundation/Part3FoundationManager.gd")

    check("Versão do projeto é 3.8.2", 'config/version="3.8.2"' in read("project.godot"))
    check("Save atual é versão 17", "const SAVE_VERSION: int = 17" in save)
    check(
        "Save rejeita versão global incompatível",
        "save_version > SAVE_VERSION or save_version < 15" in save
        and "versão incompatível" in save.lower(),
    )
    check("Migração antiga foi removida", "_migrate_stage1_save_to_stage2" not in save)
    check("Cena principal usa caminho res://", 'run/main_scene="res://scenes/main.tscn"' in read("project.godot"))
    check("Autoloads usam caminhos res://", "uid://" not in read("project.godot"))

    check("Geração usa semente persistente da campanha", "part3_foundation_manager.campaign_seed" in game)
    check("Quatro fundadores continuam ativos", "INITIAL_FOUNDER_IDS" in game and "ACTIVE_COUNCIL_LIMIT: int = 4" in game)
    check("Fundadores são Passos-Leves", 'founder.species_name = "Passos-Leves"' in game)
    check("Fundadores recebem nomes únicos", "get_unique_names(" in game)
    check("Fundadores recebem retratos embaralhados", "get_founder_appearance_ids" in game and "_shuffle_strings_with_rng" in game)
    check("Fundadores recebem passivas únicas", "get_randomized_passives" in game)
    check("Fundadores recebem personalidades únicas", "get_unique_random_ids" in game)
    check("Fundadores recebem atributos gerados", "generate_attributes(rng)" in game)
    check("Especialização inicial não é gerada", "founder.specialization = Villager.Profession.UNASSIGNED" in game)

    check("Mimo sempre existe", 'helper.villager_name = "Mimo"' in game)
    check("Mimo usa retrato fixo", 'helper.portrait_id = "mimo"' in game)
    check("Mimo começa na reserva", "helper.set_council_active(false)" in game)
    check("Mimo mantém Faz-tudo", 'helper.passive_id = "faz_tudo"' in game)
    check("Mimo tem personalidade persistente", 'helper.personality_id = "playful"' in game)
    check("Mimo usa atributos 3/3/3/3", all(token in game for token in [
        "helper.strength = 3", "helper.intelligence = 3",
        "helper.charisma = 3", "helper.agility = 3",
    ]))
    check("XP diário está ligado", "_grant_daily_council_xp(completed_day)" in game and '"daily_council_service"' in game)
    check("Evento concede 20 XP ao responsável", '"event_%s" % resolved_event_id' in game and "20," in game)
    check("Villager possui progressão de XP", "func grant_xp(amount: int)" in villager and "levels_gained" in villager)
    check("Recrutamento é salvo", 'game_state["council_recruitment"]' in game and '"council_recruitment"' in save)
    check("Recrutamento também ocorre após a vitória do dia 120", "if checkpoint_passed:" in game and "_prepare_recruitment_offer(completed_day)" in game and "if finished_now:" in game)

    saved_fields = [
        '"personality_id": personality_id',
        '"personality_name": personality_name',
        '"personality_description": personality_description',
        '"level": level',
        '"xp": xp',
        '"passive_id": passive_id',
        '"portrait_id": portrait_id',
        '"is_recruited_card": is_recruited_card',
        '"unspent_attribute_points": unspent_attribute_points',
    ]
    for token in saved_fields:
        check(f"Campo salvo: {token.split(':')[0]}", token in villager)
    loaded_fields = [
        'save_data.get("personality_id"',
        'save_data.get("personality_name"',
        'save_data.get("personality_description"',
        'save_data.get("level"',
        'save_data.get("xp"',
        'save_data.get("passive_id"',
        'save_data.get("portrait_id"',
        'save_data.get("is_recruited_card"',
        'save_data.get("unspent_attribute_points"',
    ]
    for token in loaded_fields:
        check(f"Campo carregado: {token}", token in villager)

    check("Fundação da Parte 3 mantém progresso de conselheiros", "councillor_progress" in foundation)


def validate_recruitment_system() -> None:
    manager_path = ROOT / "scripts/council/CouncilRecruitmentManager.gd"
    check("Gerenciador de recrutamento existe", manager_path.is_file())
    if not manager_path.is_file():
        return
    manager = manager_path.read_text(encoding="utf-8")
    catalog = read("scripts/council/CouncilCardCatalog.gd")
    ui = read("scripts/ui/RecruitmentWindow.gd")
    game = read("scripts/GameManager.gd")
    check("Recrutamentos ocorrem após seis avaliações", "[20, 40, 60, 80, 100, 120]" in manager)
    check("NPC fonte não pode repetir", "used_source_npc_ids" in manager and "used_source_npc_ids.has(npc_id)" in manager)
    check("Segunda maior amizade é considerada", "source_rows.sort_custom(_sort_source_rows)" in manager)
    check("Cada oferta possui duas cartas", "const CANDIDATE_COUNT: int = 2" in manager)
    check("Duas cartas usam a mesma espécie", '"species_name": species_name' in manager)
    check("Oferta persiste no save", "pending_offer" in manager and "export_save_data" in manager and "import_save_data" in manager)
    check("Janela de recrutamento existe", (ROOT / "scripts/ui/RecruitmentWindow.gd").is_file())
    check("Janela exige escolha", "ESCOLHER ESTA CARTA" in ui and "candidate_selected" in ui)
    check("Escolhida entra na reserva", 'recruited.is_council_active = bool(candidate.get("is_council_active", false))' in game)
    check("Retratos recrutáveis cadastrados", all(token in catalog for token in [
        "carta_elfo_homem", "carta_ana_homem", "carta_draconato_homem",
        "carta_meio_demonio_homem", "carta_kobold_homem",
    ]))


def validate_card_ui() -> None:
    card = read("scripts/ui/VillagerCard.gd")
    council_window = read("scripts/ui/CouncilWindow.gd")
    ui = read("scripts/UIManager.gd")
    variant = read("scripts/UIManagerVariantB.gd")

    required_card_tokens = [
        "_portrait", "_name_label", "_attribute_labels", "_xp_bar",
        "_xp_label", "_passive_name_label", "_passive_description_label",
    ]
    for token in required_card_tokens:
        check(f"Carta contém {token}", token in card)
    check("Carta mostra quatro atributos", all(token in card for token in ["FOR", "INT", "CAR", "AGI"]))
    check("Carta mostra nível e XP", '"NÍVEL %d • XP %d / %d"' in card)
    check("Carta mostra passiva", '"PASSIVA • %s"' in card)
    check("Cartas removem sombra das letras", "_remove_card_text_shadows" in card and "font_shadow_color" in card and "Color.TRANSPARENT" in card)
    check("Carta mantém personalidade fora das cinco informações visuais", "personality" not in card.lower() and "personalidade" not in card.lower())
    check("Carta permite expandir e recolher", "_toggle_details" in card and '"RECOLHER CARTA"' in card and '"EXPANDIR CARTA"' in card)
    check("Carta usa retrato cadastrado", "get_portrait_texture(" in card and "villager.portrait_id" in card)
    check("Carta não exibe especialização", "specialization" not in card.lower() and "especialização" not in card.lower())
    check("Carta possui seleção explícita de profissão", "OptionButton" in card and "_on_profession_selected" in card)
    check("Trabalho fica fora da carta selecionada", "selected_profession_selector" in ui and '"TRABALHO"' in ui)

    check("Área principal se chama Cartas do Conselho", '"CARTAS DO CONSELHO"' in ui)
    check("Cartas ficam na área de Representantes", "villager_cards" in ui and "VillagerCard" in ui)
    check("Grade comporta quatro cartas", "columns = 2" in ui or "columns = 2" in variant)
    check("Botão de troca usa linguagem de cartas", '"TROCAR CARTAS"' in ui)
    check("Janela secundária compara cartas", '"TROCAR E COMPARAR CARTAS"' in council_window)
    check("Comparação mostra diferenças de atributos", "_build_comparison_text" in council_window and "_format_difference" in council_window)
    check("Comparação não exibe especialização", "specialization" not in council_window.lower() and "especialização" not in council_window.lower())
    check("Versão visual é v3.8.2", "v3.8.2" in variant)


def validate_personality_dialogues() -> None:
    dialogue = read("scripts/dialogue/DialogueCatalog.gd")
    villager = read("scripts/Villager.gd")

    check("Diálogo carrega catálogo de personalidades", "CouncillorPersonalityCatalog.gd" in dialogue)
    for line_id in ["intro", "practical", "curious", "cautious", "winter", "prepare", "watch", "ignore"]:
        check(f"Diálogo consulta fala {line_id}", f'"{line_id}"' in dialogue)
    check("Falas usam personalidade persistida", "villager.personality_id" in dialogue)
    check("Personalidade não é sorteada ao conversar", "get_unique_random_ids" not in dialogue and "randomize" not in dialogue)
    check("Personalidade é salva no habitante", '"personality_id": personality_id' in villager)


def validate_runtime_fixes() -> None:
    npc_model = read("scripts/models/NpcModel.gd")
    specialists = read("scripts/specialists/SpecialistCatalog.gd")
    card = read("scripts/ui/VillagerCard.gd")
    ui = read("scripts/UIManager.gd")

    check("Chegadas narrativas aceitam dias não vinculados à auditoria", "is_valid_checkpoint_day" not in npc_model)
    for day in [15, 30, 45, 60, 75]:
        check(f"NPC preparado para o dia {day}", f'"arrival_checkpoint_day": {day}' in specialists)
    check("Carta não usa escala fracionária persistente", "1.015" not in card and "0.97" not in card)
    check("Carta emite mudança de profissão", "profession_requested.emit" in card)
    check("UI recebe mudança de profissão", "_on_card_profession_requested" in ui)
    check("Snap de controles habilitado", "common/snap_controls_to_pixels=true" in read("project.godot"))


def validate_art_structure(strict_art: bool) -> None:
    expected_folders = [
        "assets/council/portraits/passos_leves",
        "assets/council/portraits/elfos",
        "assets/council/portraits/anoes",
        "assets/council/portraits/draconatos",
        "assets/council/portraits/meio_demonios",
        "assets/council/portraits/kobolds",
        "assets/dialogue/portraits",
    ]
    for folder in expected_folders:
        check(f"Pasta de arte preparada: {folder}", (ROOT / folder).is_dir())

    if not strict_art:
        check("Integração final das artes pendente", True, "modo estrutural")
        return

    council_species = expected_folders[:6]
    for folder in council_species:
        pngs = list((ROOT / folder).glob("*.png"))
        check(f"Duas artes em {folder}", len(pngs) >= 2, str(len(pngs)))
    relationship_pngs = list((ROOT / "assets/dialogue/portraits").rglob("*.png"))
    check("Retratos narrativos e de relacionamento integrados", len(relationship_pngs) >= 8, str(len(relationship_pngs)))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--strict-art",
        action="store_true",
        help="Exige todas as artes finais da Etapa 3.",
    )
    args = parser.parse_args()

    validate_all_scripts()
    validate_catalogs()
    validate_generation_and_persistence()
    validate_recruitment_system()
    validate_card_ui()
    validate_personality_dialogues()
    validate_runtime_fixes()
    validate_art_structure(args.strict_art)

    failures = [result for result in RESULTS if not result.ok]
    print("Golem's Mandate — verificação da Parte 3 / Etapa 3")
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
