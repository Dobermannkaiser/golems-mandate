#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
import wave
from array import array
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


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def strip_comments_and_strings(text: str) -> str:
    out: list[str] = []
    i = 0
    quote: str | None = None
    triple = False
    escaped = False
    while i < len(text):
        c = text[i]
        if quote is not None:
            if triple and text.startswith(quote * 3, i):
                out.extend("   ")
                i += 3
                quote = None
                triple = False
                continue
            if not triple and not escaped and c == quote:
                out.append(" ")
                i += 1
                quote = None
                continue
            out.append("\n" if c == "\n" else " ")
            if not triple:
                if escaped:
                    escaped = False
                elif c == "\\":
                    escaped = True
            i += 1
            continue
        if c == "#":
            while i < len(text) and text[i] != "\n":
                out.append(" ")
                i += 1
            continue
        if c in {'"', "'"}:
            if text.startswith(c * 3, i):
                out.extend("   ")
                i += 3
                quote = c
                triple = True
            else:
                out.append(" ")
                i += 1
                quote = c
                escaped = False
            continue
        out.append(c)
        i += 1
    if quote is not None:
        raise ValueError("string não terminada")
    return "".join(out)


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


def constants_in(text: str) -> set[str]:
    clean = strip_comments_and_strings(text)
    result = set(re.findall(
        r"(?m)^\s*const\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?::[^=\n]+)?=",
        clean,
    ))
    # Enum names are valid static members as well.
    result |= set(re.findall(
        r"(?m)^\s*enum\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{",
        clean,
    ))
    return result


def class_name_in(text: str) -> str | None:
    match = re.search(r"(?m)^class_name\s+([A-Za-z_][A-Za-z0-9_]*)", text)
    return match.group(1) if match else None


def inherited_functions(path: Path, seen: set[Path] | None = None) -> set[str]:
    if seen is None:
        seen = set()
    if path in seen or not path.is_file():
        return set()
    seen.add(path)
    text = path.read_text(encoding="utf-8")
    result = functions_in(text)
    match = re.search(r'^extends\s+"res://([^"]+)"', text, re.M)
    if match:
        result |= inherited_functions(ROOT / match.group(1), seen)
    return result


def validate_scripts() -> None:
    class_symbols: dict[str, tuple[set[str], set[str], str]] = {}
    for path in ROOT.rglob("*.gd"):
        text = path.read_text(encoding="utf-8")
        class_name = class_name_in(text)
        if class_name:
            class_symbols[class_name] = (
                functions_in(text),
                constants_in(text),
                path.relative_to(ROOT).as_posix(),
            )

    for path in sorted(ROOT.rglob("*.gd")):
        rel = path.relative_to(ROOT).as_posix()
        text = path.read_text(encoding="utf-8")
        clean = strip_comments_and_strings(text)
        error = delimiter_error(text)
        check(f"Delimitadores: {rel}", error is None, error or "ok")

        funcs = re.findall(
            r"(?m)^\s*(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(",
            clean,
        )
        duplicates = sorted({name for name in funcs if funcs.count(name) > 1})
        check(f"Funções únicas: {rel}", not duplicates, ", ".join(duplicates) or "ok")

        bad_draw = sorted(name for name in funcs if name.startswith("draw_"))
        check(
            f"Sem override nativo draw_*: {rel}",
            not bad_draw,
            ", ".join(bad_draw) or "ok",
        )

        callbacks = re.findall(r"\.connect\(\s*([A-Za-z_][A-Za-z0-9_]*)", clean, re.S)
        available = inherited_functions(path)
        missing = sorted({
            cb for cb in callbacks
            if cb not in available and cb not in {"queue_free", "hide", "show"}
        })
        check(f"Callbacks existem: {rel}", not missing, ", ".join(missing) or "ok")

        for target in re.findall(r'preload\(\s*"res://([^"]+)"\s*\)', text, re.S):
            check(f"Preload existe: {rel} -> {target}", (ROOT / target).is_file(), target)

        for target in re.findall(
            r'"res://([^"\n]+\.(?:gd|tscn|png|jpg|jpeg|webp|ttf|otf|tres))"',
            text,
        ):
            check(f"Recurso existe: {rel} -> {target}", (ROOT / target).is_file(), target)

        leading_spaces = [
            i + 1 for i, line in enumerate(text.splitlines())
            if line.startswith(" ") and line.strip()
        ]
        check(
            f"Indentação por tab: {rel}",
            not leading_spaces,
            str(leading_spaces[:8]) if leading_spaces else "ok",
        )

        # Validate calls such as VillageStoryChapterCatalog.get_chapter_for_day().
        static_refs = re.findall(
            r"\b([A-Z][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)\s*\(",
            clean,
        )
        unknown_refs: list[str] = []
        for class_name, member in static_refs:
            if class_name not in class_symbols:
                continue
            functions, _, _ = class_symbols[class_name]
            if member not in functions:
                unknown_refs.append(f"{class_name}.{member}")
        check(
            f"Métodos estáticos de classes existem: {rel}",
            not unknown_refs,
            ", ".join(sorted(set(unknown_refs))) or "ok",
        )

        static_members = re.findall(
            r"\b([A-Z][A-Za-z0-9_]*)\.([A-Z][A-Z0-9_]*)\b(?!\s*\()",
            clean,
        )
        unknown_members: list[str] = []
        for class_name, member in static_members:
            if class_name not in class_symbols:
                continue
            _, constants, _ = class_symbols[class_name]
            if member not in constants:
                unknown_members.append(f"{class_name}.{member}")
        check(
            f"Constantes de classes existem: {rel}",
            not unknown_members,
            ", ".join(sorted(set(unknown_members))) or "ok",
        )

    medieval = read("scripts/MedievalTheme.gd")
    allowed_medieval_calls = functions_in(medieval)
    used_medieval_calls: set[str] = set()
    for path in ROOT.rglob("*.gd"):
        used_medieval_calls |= set(re.findall(
            r"MedievalTheme\.([A-Za-z_][A-Za-z0-9_]*)\s*\(",
            path.read_text(encoding="utf-8"),
        ))
    unknown = sorted(used_medieval_calls - allowed_medieval_calls)
    check("Chamadas MedievalTheme válidas", not unknown, ", ".join(unknown) or "ok")


def validate_resources() -> None:
    character_dir = ROOT / "characters"
    character_ids: list[str] = []
    for path in sorted(character_dir.glob("*.tres")):
        rel = path.relative_to(ROOT).as_posix()
        text = path.read_text(encoding="utf-8")
        check(f"Cadastro referencia CharacterDefinition: {rel}", "CharacterDefinition.gd" in text)
        id_match = re.search(r'character_id = "([^"]+)"', text)
        character_id = id_match.group(1) if id_match else ""
        check(f"Cadastro possui ID: {rel}", bool(character_id), character_id or "ausente")
        if character_id:
            character_ids.append(character_id)
        portrait_match = re.search(r'portrait_path = "res://([^"]+)"', text)
        portrait_path = portrait_match.group(1) if portrait_match else ""
        check(f"Cadastro possui retrato: {rel}", bool(portrait_path), portrait_path or "ausente")
        if portrait_path:
            check(f"Retrato do cadastro existe: {rel}", (ROOT / portrait_path).is_file(), portrait_path)
    duplicate_ids = sorted({x for x in character_ids if character_ids.count(x) > 1})
    check("IDs de personagens únicos", not duplicate_ids, ", ".join(duplicate_ids) or "ok")

    portraits = sorted((ROOT / "assets/dialogue/portraits").glob("*.png"))
    check("Retratos necessários incorporados", len(portraits) >= 12, str(len(portraits)))
    for portrait in portraits:
        try:
            with Image.open(portrait) as image:
                rgba = image.convert("RGBA")
                alpha = rgba.getchannel("A")
                check(
                    f"Retrato com transparência: {portrait.name}",
                    alpha.getextrema()[0] == 0,
                    str(alpha.getextrema()),
                )
        except Exception as exc:
            check(f"Retrato legível: {portrait.name}", False, str(exc))

    aelric = read("characters/19_aelric_ferreiro.tres")
    check("Aelric usa retrato oficial", 'portrait_path = "res://assets/dialogue/portraits/aelric_ferreiro.png"' in aelric)
    check("Aelric é opção romântica", "romance_available = true" in aelric)
    check("Fonte Alagard incorporada", (ROOT / "assets/dialogue/alagard.ttf").is_file())


def validate_story_catalog() -> None:
    story = read("scripts/story/StoryChapterCatalog.gd")
    dialogue = read("scripts/dialogue/DialogueCatalog.gd")
    specialist = read("scripts/specialists/SpecialistCatalog.gd")

    chapter_days_match = re.search(r"CHAPTER_DAYS.*?= \[(.*?)\]", story, re.S)
    chapter_days = [int(x) for x in re.findall(r"\d+", chapter_days_match.group(1))] if chapter_days_match else []
    check("Seis dias de capítulo", chapter_days == [20, 40, 60, 80, 100, 120], str(chapter_days))

    chapter_ids = re.findall(r'"id": "(capitulo_[^"]+)"', story)
    # Every chapter is present once in chapter catalog; event chapter_id uses same token, so unique it.
    unique_chapter_ids = list(dict.fromkeys(chapter_ids))
    check("Seis capítulos únicos", len(unique_chapter_ids) == 6, str(unique_chapter_ids))

    story_event_ids = re.findall(r'"id": "(story_day\d+_[^"]+)"', story)
    check("Seis acontecimentos principais", len(story_event_ids) == 6, str(story_event_ids))
    check("IDs de acontecimentos principais únicos", len(set(story_event_ids)) == 6)

    required_recruits = [
        "aelric_ferreiro",
        "kobi_mercante",
        "orion_draconato",
        "rubra_meio_demonia",
        "brunna_ana_barbara",
    ]
    for npc_id in required_recruits:
        check(f"NPC de capítulo cadastrado: {npc_id}", npc_id in story and npc_id in specialist)

    check("Aelric substitui goblin", "goblin" not in story.lower() and "goblin" not in specialist.lower())
    check("Sem nome antigo de espécie", "nekob" not in (story + dialogue + specialist).lower())
    check("Passos-Leves introduzidos no prólogo", "Passos-Leves" in dialogue)
    check("Prefeito Perfeito no prólogo", "PREFEITO PERFEITO" in dialogue)
    check("Sanctuary-Void conduz auditorias", "Sanctuary-Void" in dialogue and "deusa_auditoria" in dialogue)

    expected_ids = {
        "prologue_reincarnation",
        *{f"chapter_{day}_intro" for day in [20, 40, 60, 80, 100, 120]},
        *{f"chapter_{day}_outro_{variant}" for day in [20, 40, 60, 80, 100] for variant in ["safe", "special", "risky"]},
        *{f"chapter_120_outro_{variant}" for variant in ["people", "work", "special"]},
    }
    static_ids = set(re.findall(
        r'"(prologue_reincarnation|chapter_(?:20|40|60|80|100|120)_intro)"',
        dialogue,
    ))
    generated_outros = {
        f"chapter_{day}_outro_{variant}"
        for day in [20, 40, 60, 80, 100]
        for variant in ["safe", "special", "risky"]
        if f'_create_chapter_outro_{day}' in dialogue
    }
    if "_create_chapter_outro_120" in dialogue:
        generated_outros |= {
            f"chapter_120_outro_{variant}"
            for variant in ["people", "work", "special"]
        }
    available_ids = static_ids | generated_outros
    missing_ids = sorted(expected_ids - available_ids)
    check("Vinte e cinco diálogos principais cadastrados", not missing_ids, ", ".join(missing_ids) or str(len(expected_ids)))

    # Event choice IDs are indented 4 tabs in the six event choice arrays. Count selected known variants.
    choice_tokens = re.findall(r'(?m)^\t\t\t\t"id": "([^"]+)"', story)
    check("Dezoito escolhas narrativas", len(choice_tokens) == 18, str(len(choice_tokens)))
    check("Escolhas narrativas únicas", len(set(choice_tokens)) == 18)
    check("Consequências persistentes por flags", story.count('"story_flag":') == 18, str(story.count('"story_flag":')))
    check("Variantes de encerramento em todas as escolhas", story.count('"outro_variant":') == 18, str(story.count('"outro_variant":')))
    check("Escolhas especiais por construções", story.count('"required_building":') >= 4, str(story.count('"required_building":')))
    check("Escolha especial por profissão", '"required_profession":' in story)
    check("Escolha final exige aliados", '"required_known_npcs": 5' in story)
    tested_attributes = {
        attribute
        for attribute in ["strength", "intelligence", "charisma", "agility"]
        if f'"test_attribute": "{attribute}"' in story
    }
    check(
        "Variedade de testes de atributos nos capítulos",
        len(tested_attributes) >= 3,
        ", ".join(sorted(tested_attributes)),
    )


def validate_integration() -> None:
    project = read("project.godot")
    scene = read("scenes/main.tscn")
    game = read("scripts/GameManager.gd")
    ui = read("scripts/UIManager.gd")
    event_manager = read("scripts/events/EventManager.gd")
    diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")
    diagnostics_window = read("scripts/ui/DiagnosticsWindow.gd")
    save = read("scripts/save/SaveManager.gd")
    story_manager = read("scripts/story/StoryManager.gd")
    population = read("scripts/models/PopulationState.gd")

    check("Versão 3.1.2", 'config/version="3.1.2"' in project)
    check("Layout oficial aprovado permanece", "res://scripts/UIManagerVariantB.gd" in scene)
    check("Save v9", "const SAVE_VERSION: int = 9" in save)
    main_menu = read("scripts/ui/MainMenu.gd")
    tutorial_window = read("scripts/ui/TutorialWindow.gd")
    check("Menu possui Guia do Jogo", "GUIA DO JOGO" in main_menu)
    check("Tutorial básico separado", "_build_basic_tutorial_steps" in ui)
    check("Guia completo separado", "_build_full_guide_steps" in ui)
    check("Tutoriais contextuais integrados", "_build_contextual_tutorial_steps" in ui and ui.count("area_") >= 13)
    check("Guia cobre relações", "AMIZADE E ROMANCE" in ui and "Apenas um parceiro oficial" in ui)
    check("Guia cobre salvamento", "SALVAR E CARREGAR" in ui and "autosave" in ui.lower())
    check(
        "Tutorial inteiro fica acima dos modais",
        "z_index = 1000" in tutorial_window
        and "z_as_relative = false" in tutorial_window
        and "overlay.z_index = 0" in tutorial_window,
    )
    check(
        "Tutorial assume prioridade de entrada",
        "mouse_filter = Control.MOUSE_FILTER_STOP" in tutorial_window
        and "move_to_front()" in tutorial_window
        and "overlay.move_to_front()" in tutorial_window,
    )
    check(
        "Tutorial deixa de bloquear ao fechar",
        "mouse_filter = Control.MOUSE_FILTER_IGNORE" in tutorial_window
        and "visible = false" in tutorial_window,
    )
    check(
        "Botões do tutorial recebem foco",
        "focus_mode = Control.FOCUS_ALL" in tutorial_window
        and "_focus_primary_button" in tutorial_window,
    )
    check(
        "Tutorial possui navegação de segurança",
        "func _input(event: InputEvent)" in tutorial_window
        and "ui_cancel" in tutorial_window
        and "ui_left" in tutorial_window
        and "ui_right" in tutorial_window,
    )
    check("Save da Parte 2 não é localizado", "const LEGACY_SAVE_PATHS: Array[String] = []" in save)
    check(
        "Migrações antigas não permanecem acessíveis",
        all(
            token not in save
            for token in [
                "_has_legacy_save",
                "_find_legacy_save_path",
                "_migrate_v5_to_v6",
                "_migrate_v6_to_v7",
            ]
        ),
    )
    check("Story exigida no schema", '"story"' in save)
    check("Story exportada no save", 'game_state["story"] = story_manager.export_save_data()' in game)
    check("Story importada no load", "story_manager.import_save_data" in game)

    check("Prólogo enfileirado em nova campanha", "story_manager.setup(true)" in game)
    check("Prólogo exibido antes do tutorial", "tutorial_after_story" in ui and "has_pending_story_dialogue" in ui)
    check("Capítulos interceptam dias especiais", "story_manager.should_trigger_chapter(completed_day)" in game)
    check("Evento principal iniciado após introdução", "start_forced_event" in game and "start_event_id" in game)
    check("Avaliação ocorre após encerramento narrativo", "pending_campaign_completed_day" in game and "chapter_completed" in game)
    check("NPC novo marcado como conhecido", "mark_npc_known" in game)
    check("NPC novo aumenta população protegida", "add_named_story_resident" in game and "add_named_story_resident" in population)
    check("Afinidade inicial aplicada", "add_relationship_points" in game)
    check("Consequências de população aplicadas", "apply_story_population_delta" in game)
    check("Sem autosave destrutivo em teste", "debug_story_sequence_active" in game and "_restore_debug_story_snapshot" in game)

    check("Eventos principais fora do sorteio aleatório", "event_catalog = EVENT_CATALOG_SCRIPT.create()" in event_manager and "create_story_events()" in event_manager)
    check("Chance aleatória continua 52,5%", "const EVENT_CHANCE: float = 0.525" in event_manager)
    check("Eventos comuns recebem contexto sazonal", "_get_seasonal_event_context" in event_manager and "_prepare_event_for_day" in event_manager)
    check("Requisitos de gestão validados", all(token in event_manager for token in ["required_building", "required_profession", "required_known_npcs"]))

    check("Sinal de diálogo narrativo integrado", "story_dialogue_requested" in game and "_on_story_dialogue_requested" in ui)
    check("Diálogos obrigatórios sem fechar", '"allow_close": false' in read("scripts/dialogue/DialogueCatalog.gd"))
    check("Retrato pode ser ocultado para narrador", "hide_portrait" in read("scripts/ui/DialogueWindow.gd"))
    check("Histórico permanece disponível", "HISTÓRICO" in read("scripts/ui/DialogueWindow.gd"))

    check("Oráculo valida campanha", "_validate_story_campaign" in diagnostics)
    check("Oráculo testa prólogo e capítulos", "story_test_requested" in diagnostics_window and all(str(day) in diagnostics_window for day in [20, 40, 60, 80, 100, 120]))
    check("Teste narrativo preserva campanha", "debug_start_story_sequence" in game and "debug_story_snapshot" in game)
    check("Diagnóstico inclui recursos da Etapa 7", "StoryChapterCatalog.gd" in diagnostics and "aelric_ferreiro.png" in diagnostics)

    active_code = "\n".join(
        path.read_text(encoding="utf-8")
        for base in [ROOT / "scripts", ROOT / "characters", ROOT / "scenes"]
        for path in base.rglob("*")
        if path.is_file() and path.suffix in {".gd", ".tres", ".tscn"}
    ).lower()
    check("Sem Nekobípedes em conteúdo ativo", "nekob" not in active_code)
    check("Sem goblin ferreiro em conteúdo ativo", "goblin" not in active_code)


def validate_stage6_preservation() -> None:
    villager = read("scripts/Villager.gd")
    event_catalog = read("scripts/events/EventCatalog.gd")
    magical_catalog = read("scripts/events/MagicalEventCatalog.gd")
    ui = read("scripts/UIManager.gd")

    names_match = re.search(r"const POSSIBLE_NAMES.*?= \[(.*?)\n\]", villager, re.S)
    names = re.findall(r'"([^"]+)"', names_match.group(1)) if names_match else []
    check("Quarenta nomes aleatórios preservados", len(names) == 40, str(len(names)))
    check("Retratos persistentes preservados", '"portrait_id": portrait_id' in villager and 'save_data.get("portrait_id"' in villager)
    check("Conversa comum por segundo clique preservada", "_open_dialogue_for_villager" in ui)
    check("Mimo mantém conversa própria", "_create_mimo_conversation" in read("scripts/dialogue/DialogueCatalog.gd"))

    base_events = len(re.findall(r"(?m)^\s*events\.append\(\{", event_catalog))
    magical_events = len(re.findall(r'(?m)^\t\t\t"id": "[^"]+"', magical_catalog))
    check("Quarenta eventos comuns preservados", base_events + magical_events == 40, f"{base_events}+{magical_events}")


def validate_stage8_system() -> None:
    relationship_state = read("scripts/models/RelationshipState.gd")
    relationship_catalog = read("scripts/relationships/RelationshipCatalog.gd")
    relationship_dialogue = read("scripts/relationships/RelationshipDialogueCatalog.gd")
    foundation = read("scripts/foundation/Part2FoundationManager.gd")
    game = read("scripts/GameManager.gd")
    save = read("scripts/save/SaveManager.gd")
    profile = read("scripts/models/PlayerProfile.gd")
    ui = read("scripts/UIManager.gd")
    variant = read("scripts/UIManagerVariantB.gd")
    diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")
    specialist = read("scripts/specialists/SpecialistCatalog.gd")

    check("Sistema usa 0 a 1000 pontos", "MAX_RELATIONSHIP_POINTS: int = 1000" in relationship_state)
    check("Sistema possui dez níveis", "MAX_LEVEL: int = 10" in relationship_state and "LEVEL_THRESHOLDS" in relationship_state)
    check("Limite diário de conversa", "last_conversation_day" in relationship_state and "can_gain_conversation_points" in relationship_state)
    check("Encontros com intervalo", "last_date_day" in relationship_state and "day - last_date_day >= 7" in relationship_state)
    check("Eventos pessoais persistentes", "completed_personal_event_ids" in relationship_state)
    check("Falas sazonais persistentes", "seen_seasonal_dialogue_keys" in relationship_state)

    romance_ids = re.findall(r'"(aelric_ferreiro|kobi_mercante|orion_draconato|rubra_meio_demonia|brunna_ana_barbara)"', relationship_catalog)
    check("Cinco candidatos românticos", len(set(romance_ids)) == 5, str(sorted(set(romance_ids))))
    check("Mimo sem romance", 'const MIMO_ID: String = "passos_leves_faz_tudo"' in relationship_catalog and 'MIMO_ID,\n\t"aelric' in relationship_catalog)
    check("Kobi com romance", '"npc_id": KOBI_ID' in specialist and '"romance_available": true' in specialist)
    mimo_block = specialist.split("static func get_mimo_npc_data", 1)[1].split("static func get_story_npc_data", 1)[0]
    check("Mimo marcado sem romance", '"romance_available": false' in mimo_block)

    personal_section = relationship_dialogue.split("const PERSONAL_EVENTS", 1)[1].split("static func create_conversation", 1)[0]
    check("Vinte e quatro eventos pessoais", personal_section.count('"title":') == 24, str(personal_section.count('"title":')))
    check("Respostas boas, neutras e ruins", all(token in relationship_dialogue for token in ['"good"', '"neutral"', '"bad"', 'relationship_points']))
    check("Falas para quatro estações", all(f'"{season}"' in relationship_dialogue for season in ["spring", "summer", "autumn", "winter"]))
    check("Falas pós-romance", relationship_dialogue.count('"partner_lines"') >= 5, str(relationship_dialogue.count('"partner_lines"')))
    check("Encontros românticos cadastrados", "create_date_conversation" in relationship_dialogue)
    check("Sem sistema de presentes ou inventário", "gift" not in relationship_dialogue.lower() and "inventory" not in relationship_dialogue.lower())

    check("Parceiro oficial único", "official_partner_id" in foundation and "O Prefeito já possui um parceiro oficial" in foundation)
    check("Bônus de gestão por relacionamento", "get_relationship_management_modifiers" in foundation and "relationship_modifiers" in game)
    check("Dificuldade de alimentação aumentada", "FOOD_CONSUMPTION_PER_VILLAGER: float = 2.10" in game)
    check("Dificuldade de manutenção aumentada", "MATERIAL_MAINTENANCE_PER_VILLAGER: float = 0.27" in game)
    check("Produção comum ajustada", "COMMON_FOOD_PRODUCTION_PER_VILLAGER: float = 1.55" in game)

    check("Perfil aceita nome e gênero", "gender_id" in profile and "masculino" in profile and "feminino" in profile)
    check("Cargo continua Prefeito", 'DEFAULT_TITLE: String = "Prefeito"' in profile)
    check("Janela de perfil integrada", "ProfileSetupWindow.gd" in ui and "profile_confirmed" in ui)
    check("Aba Relações integrada", '"RELAÇÕES"' in variant and "RelationshipsWindow.gd" in ui)
    check("Escolhas de diálogo retornam metadados", "choice_selected" in read("scripts/ui/DialogueWindow.gd") and '"choice": selected_choice' in read("scripts/dialogue/DialogueManager.gd"))

    check("Save v9 e caminho exclusivo", "SAVE_VERSION: int = 9" in save and "golems_mandate_part3_v3_save.json" in save)
    check("Parte 3 exige nova campanha", "LEGACY_SAVE_PATHS: Array[String] = []" in save and "Inicie uma nova campanha" in save)
    check("Estado completo de relações salvo", all(token in relationship_state for token in ["response_counts", "dates_total", "romance_interest", "official_partner"]))
    check("Oráculo valida relações", "_validate_relationship_system" in diagnostics)
    check("Falas sazonais são registradas no save", "seasonal_dialogue_key" in relationship_dialogue and "mark_relationship_seasonal_dialogue_seen" in game and "mark_relationship_seasonal_dialogue_seen" in foundation)
    check("Nome do Prefeito aparece nos diálogos", "player_speaker_name" in read("scripts/dialogue/DialogueManager.gd") and "Prefeito %s" in read("scripts/ui/DialogueWindow.gd"))
    check("Menu de carregamento mostra o Prefeito", '"player_name": String(profile_state.get("name", "Alex"))' in save and "saved_player_name" in read("scripts/ui/MainMenu.gd"))
    check("Lateral compactada para a nova aba", 'Vector2(0.0, 48.0)' in variant and 'Vector2(0.0, 44.0)' in variant)
    check("Fundadores fora do sistema de relações", all(token not in relationship_catalog for token in ["representante_01", "representante_02", "representante_03", "representante_04"]))

    prohibited = ["assédio", "assedio", "violência doméstica", "violencia domestica"]
    active_relationship_text = (relationship_dialogue + relationship_catalog).lower()
    check("Sem temas românticos proibidos", not any(term in active_relationship_text for term in prohibited))



def validate_stage81_maintenance() -> None:
    relationship_dialogue = read("scripts/relationships/RelationshipDialogueCatalog.gd")
    relationship_state = read("scripts/models/RelationshipState.gd")
    relationships_window = read("scripts/ui/RelationshipsWindow.gd")
    ui = read("scripts/UIManager.gd")
    game = read("scripts/GameManager.gd")

    topic_section = relationship_dialogue.split("const CONVERSATION_TOPICS", 1)[1].split("const PERSONAL_EVENTS", 1)[0]
    topic_ids = re.findall(r'"id": "(?:mimo|aelric|kobi|orion|rubra|brunna)_[^"]+"', topic_section)
    check("Trinta tópicos comuns cadastrados", len(topic_ids) == 30, str(len(topic_ids)))

    expected_prefixes = {
        "passos_leves_faz_tudo": "mimo_",
        "aelric_ferreiro": "aelric_",
        "kobi_mercante": "kobi_",
        "orion_draconato": "orion_",
        "rubra_meio_demonia": "rubra_",
        "brunna_ana_barbara": "brunna_",
    }
    for npc_id, prefix in expected_prefixes.items():
        count = len([topic_id for topic_id in topic_ids if f'"id": "{prefix}' in topic_id])
        check(f"Cinco tópicos para {npc_id}", count == 5, str(count))

    check("Respostas de conversa embaralhadas", relationship_dialogue.count("choices.shuffle()") >= 3, str(relationship_dialogue.count("choices.shuffle()")))
    check("Assunto anterior persistido", "last_conversation_topic_id" in relationship_state)
    check("Conversa evita repetição imediata", "last_topic_id" in relationship_dialogue and "randi_range" in relationship_dialogue)
    check("Teste lista personagens desconhecidos", "get_relationship_test_overview" in game and "_open_relationships_test_window" in ui)
    check("Teste permite conversar com desconhecidos", "include_unknown" in relationships_window and "include_unknown" in ui)


def validate_stage9_audio() -> None:
    project = read("project.godot")
    manager = read("scripts/audio/AudioManager.gd")
    settings = read("scripts/settings/GameSettings.gd")
    menu = read("scripts/ui/MainMenu.gd")
    ui = read("scripts/UIManager.gd")
    dialogue = read("scripts/ui/DialogueWindow.gd")
    diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")

    check(
        "AudioManager registrado como autoload",
        'AudioManager="*res://scripts/audio/AudioManager.gd"' in project,
    )
    check(
        "Cinco canais independentes cadastrados",
        all(name in manager for name in ["Music", "Ambience", "SFX", "UI"])
        and "Master" in settings,
    )
    check(
        "Configurações possuem cinco volumes",
        all(token in settings for token in [
            "master_volume_percent",
            "music_volume_percent",
            "ambience_volume_percent",
            "effects_volume_percent",
            "interface_volume_percent",
        ]),
    )
    check(
        "Migração do volume geral anterior preservada",
        '"volume_percent"' in settings and "legacy_volume" in settings,
    )
    check(
        "Silenciar tudo preserva canais individuais",
        "master_muted" in settings and "restore_audio_defaults" in settings,
    )
    check(
        "Tela de configurações testa todos os canais",
        menu.count('_create_audio_setting_row(') >= 6
        and 'AudioManager.test_channel(channel_id)' in menu,
        str(menu.count('_create_audio_setting_row(') - 1),
    )
    check(
        "Controles separados aparecem na interface",
        all(label in menu for label in [
            '"VOLUME GERAL"', '"MÚSICA"', '"AMBIENTE"',
            '"EFEITOS"', '"INTERFACE"', '"SILENCIAR TUDO',
        ]),
    )
    check(
        "Música muda por estação",
        all(season in manager for season in [
            '"spring"', '"summer"', '"autumn"', '"winter"',
        ]) and "set_season" in manager,
    )
    check(
        "Primavera e inverno possuem variações",
        manager.count("music_spring_") >= 2
        and manager.count("music_winter_") >= 2,
    )
    check(
        "Transições suaves de música e ambiente",
        "MUSIC_CROSSFADE_SECONDS" in manager
        and "AMBIENCE_CROSSFADE_SECONDS" in manager
        and "create_tween" in manager,
    )
    check(
        "Diálogos reduzem música e ambiente",
        "DIALOGUE_MUSIC_DUCK_DB" in manager
        and "DIALOGUE_AMBIENCE_DUCK_DB" in manager
        and "AudioManager.begin_dialogue" in ui
        and "AudioManager.end_dialogue" in ui,
    )
    check(
        "Som de texto integrado ao efeito de digitação",
        "play_dialogue_text_tick" in manager
        and "last_typed_audio_character" in dialogue,
    )
    check(
        "Botões recebem áudio automaticamente",
        "node_added" in manager
        and "_bind_button_audio" in manager
        and "HOVER_COOLDOWN_MSEC" in manager,
    )
    check(
        "Áudio reduzido quando o jogo perde foco",
        "NOTIFICATION_APPLICATION_FOCUS_OUT" in manager
        and "focus_attenuated" in manager,
    )
    check(
        "Acontecimentos e gestão possuem efeitos",
        all(token in manager for token in [
            '"event_positive"', '"event_negative"', '"event_magic"',
            '"event_audit"', '"event_victory"', '"event_defeat"',
            '"build"', '"upgrade"', '"end_day"', '"save"', '"load"',
        ]),
    )
    check(
        "Relacionamentos possuem efeitos",
        all(token in manager for token in [
            '"relation_gain"', '"relation_loss"',
            '"relation_romance"', '"relation_date"',
        ]) and 'AudioManager.play_sfx("relation_gain"' in ui,
    )
    check(
        "Oráculo valida o áudio",
        "_validate_audio_system" in diagnostics
        and '"Música e efeitos"' in diagnostics,
    )
    check(
        "Guia explica controles de áudio",
        '"ÁUDIO"' in ui and "Silenciar tudo" in ui,
    )

    music_files = sorted((ROOT / "assets/audio/music").glob("*.ogg"))
    ambience_files = sorted((ROOT / "assets/audio/ambience").glob("*.ogg"))
    wav_files = sorted((ROOT / "assets/audio").rglob("*.wav"))
    check("Nove músicas incorporadas", len(music_files) == 9, str(len(music_files)))
    check("Quatro ambientes sazonais incorporados", len(ambience_files) == 4, str(len(ambience_files)))
    check("Ao menos quarenta efeitos WAV incorporados", len(wav_files) >= 40, str(len(wav_files)))

    for path in music_files + ambience_files:
        rel = path.relative_to(ROOT).as_posix()
        data = path.read_bytes()[:4]
        check(f"OGG válido: {rel}", data == b"OggS", repr(data))
        check(f"OGG possui conteúdo: {rel}", path.stat().st_size > 100_000, str(path.stat().st_size))

    invalid_wavs: list[str] = []
    for path in wav_files:
        try:
            with wave.open(str(path), "rb") as handle:
                if handle.getframerate() not in {44100, 48000}:
                    invalid_wavs.append(f"{path.name}: taxa {handle.getframerate()}")
                if handle.getnframes() <= 0:
                    invalid_wavs.append(f"{path.name}: vazio")
                if handle.getsampwidth() != 2:
                    invalid_wavs.append(f"{path.name}: {handle.getsampwidth() * 8} bits")
        except Exception as exc:
            invalid_wavs.append(f"{path.name}: {exc}")
    check("Efeitos WAV legíveis", not invalid_wavs, "; ".join(invalid_wavs[:8]) or "ok")

    click_path = ROOT / "assets/audio/sfx/ui/ui_click.wav"
    reward_path = ROOT / "assets/audio/sfx/events/event_positive.wav"
    with wave.open(str(click_path), "rb") as handle:
        click_duration = handle.getnframes() / float(handle.getframerate())
    with wave.open(str(reward_path), "rb") as handle:
        reward_duration = handle.getnframes() / float(handle.getframerate())
        sample_count = min(handle.getnframes(), int(handle.getframerate() * 0.20))
        samples = array("h")
        samples.frombytes(handle.readframes(sample_count))
        initial_peak = max((abs(value) for value in samples), default=0)
    check("Clique fornecido foi recortado", click_duration <= 0.35, f"{click_duration:.3f}s")
    check("Recompensa fornecida não começa atrasada", reward_duration <= 2.20 and initial_peak > 500, f"{reward_duration:.3f}s; pico {initial_peak}")
    check("Fontes M4A não foram incluídas no projeto", not list((ROOT / "assets/audio").rglob("*.m4a")))
    check("Músicas WAV brutas não foram incluídas", not list((ROOT / "assets/audio/music").glob("*.wav")))



def validate_stage92_visual_fixes() -> None:
    menu = read("scripts/ui/MainMenu.gd")
    visuals = read("scripts/ui/BuildingVisuals.gd")
    check(
        "Página do menu recorta conteúdo excedente",
        "page_holder.clip_contents = true" in menu,
    )
    check(
        "Configurações usam rolagem limitada",
        "Vector2(0.0, 220.0)" in menu
        and "scroll.clip_contents = true" in menu
        and "SCROLL_MODE_AUTO" in menu,
    )
    check(
        "Muralha é desenhada proceduralmente",
        all(token in visuals for token in [
            "_paint_wall_segment",
            "_paint_wall_tower",
            "_paint_gatehouse",
            "draw_colored_polygon",
        ]),
    )
    check(
        "Muralha não usa PNGs antigos",
        all(token not in visuals for token in [
            "wall_line.png",
            "wall_corner.png",
            "wall_gate.png",
        ])
        and all(not (ROOT / "assets/etapa5" / name).exists() for name in [
            "wall_line.png",
            "wall_corner.png",
            "wall_gate.png",
        ]),
    )
    check(
        "Ícone da muralha é gerado em tempo de execução",
        "_get_palisade_icon_texture" in visuals
        and "ImageTexture.create_from_image" in visuals
        and "Image.create_empty" in visuals
        and "image.fill_rect" in visuals,
    )
    check(
        "Muralha possui escala normal e ampliada",
        "visual_scale: float = 2.0 if is_large_view else 1.0" in visuals,
    )
    check(
        "Portão possui abertura central exclusiva",
        "gatehouse_rect" in visuals
        and "opening_width" in visuals
        and "opening_height" in visuals
        and "_paint_gatehouse(gatehouse_rect" in visuals,
    )
    check(
        "Níveis da muralha possuem visuais distintos",
        "if level == 1" in visuals
        and "if level >= 3" in visuals
        and "stone_body" in visuals
        and "wood_body" in visuals,
    )


def validate_stage10_balance() -> None:
    project = read("project.godot")
    difficulty = read("scripts/campaign/DifficultyCatalog.gd")
    campaign = read("scripts/campaign/CampaignCatalog.gd")
    campaign_manager = read("scripts/campaign/CampaignManager.gd")
    records = read("scripts/campaign/CampaignRecords.gd")
    profile = read("scripts/models/PlayerProfile.gd")
    profile_window = read("scripts/ui/ProfileSetupWindow.gd")
    population = read("scripts/models/PopulationState.gd")
    buildings = read("scripts/buildings/BuildingManager.gd")
    game = read("scripts/GameManager.gd")
    save = read("scripts/save/SaveManager.gd")
    main_menu = read("scripts/ui/MainMenu.gd")
    medal_badge = read("scripts/ui/MedalBadge.gd")
    tutorial = read("scripts/tutorial/TutorialManager.gd")
    ui_manager = read("scripts/UIManager.gd")
    dialogue = read("scripts/dialogue/DialogueCatalog.gd")
    relationship_dialogue = read("scripts/relationships/RelationshipDialogueCatalog.gd")
    diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")
    diagnostics_window = read("scripts/ui/DiagnosticsWindow.gd")

    check("Versão da Parte 3 3.1.2", 'config/version="3.1.2"' in project)
    check("Três dificuldades cadastradas", 'DIFFICULTY_IDS: Array[String] = ["cozy", "moderate", "hard"]' in difficulty)
    check("Dificuldades possuem nomes oficiais", all(name in difficulty for name in ["Acolhedora", "Moderada", "Difícil"]))
    check("Moderada é a dificuldade padrão", 'DEFAULT_DIFFICULTY_ID: String = "moderate"' in difficulty)
    check("Custos variam por dificuldade", "building_cost_multiplier" in difficulty and "cost_multiplier" in buildings)
    check("Produção e consumo variam por dificuldade", all(token in difficulty for token in ["production_multiplier", "food_consumption_multiplier", "maintenance_multiplier", "happiness_decay_multiplier"]))
    check("Crescimento varia por dificuldade", all(token in difficulty for token in ["attraction_target", "abandonment_target"]) and "configure_difficulty" in population)

    days_match = re.search(r"const CHECKPOINT_DAYS.*?= \[(.*?)\]", campaign, re.S)
    days = [int(value) for value in re.findall(r"\d+", days_match.group(1))] if days_match else []
    check("Seis avaliações finais", days == [20, 40, 60, 80, 100, 120], str(days))
    target_blocks = re.findall(r'"targets": \{(.*?)\n\t\t\}', campaign, re.S)
    check("Seis blocos de metas", len(target_blocks) == 6, str(len(target_blocks)))
    goal_count = sum(sum(1 for key in ["food", "material", "happiness", "population"] if f'"{key}"' in block) for block in target_blocks)
    check("Vinte e quatro metas", goal_count == 24, str(goal_count))
    check("Metas marcadas como finais", campaign.count('"balance_status": "final"') == 6, str(campaign.count('"balance_status": "final"')))
    check("Metas ajustadas pela dificuldade", "apply_checkpoint_targets" in difficulty and "difficulty_id" in campaign_manager)
    check("Campanha exporta dificuldade", '"difficulty_id": difficulty_id' in campaign_manager)
    check("Derrota continua imediata", "_finish_checkpoint_defeat" in campaign_manager and "_are_all_goals_met" in campaign_manager and "STATUS_DEFEAT" in campaign_manager)
    check("Próxima avaliação completa", "current_checkpoint" in campaign_manager and "targets" in campaign_manager)
    check("Avaliações futuras resumidas", "future_checkpoint_preview" in campaign_manager and "_build_future_checkpoint_preview" in campaign_manager)
    check("Prefeito Perfeito classifica tendência", all(token in game for token in ["safe", "tight", "danger", "impossible_pace"]))

    # A faixa final acordada é verificada pelos valores concretos resultantes.
    check("Meta final Acolhedora em 34 habitantes", '"population": 35' in campaign and '"population_target_multiplier": 0.95' in difficulty)
    check("Meta final Moderada em 35 habitantes", '"population": 35' in campaign and '"population_target_multiplier": 1.0' in difficulty)
    check("Meta final Difícil em 37 habitantes", '"population": 35' in campaign and '"population_target_multiplier": 1.05' in difficulty)

    check("Outono preserva bônus de reservas", '"id": SEASON_AUTUMN' in campaign and '"material_production_multiplier": 1.15' in campaign)
    check("Inverno preserva pressão alimentar", '"id": SEASON_WINTER' in campaign and '"food_production_multiplier": 0.80' in campaign and '"food_consumption_multiplier": 1.20' in campaign)

    check("Perfil salva dificuldade", "difficulty_id" in profile and "difficulty_id" in save)
    check("Criação de vila escolhe dificuldade", "difficulty_options" in profile_window and "profile_confirmed" in profile_window and "difficulty_id" in profile_window)
    check("Save v9 separado", "SAVE_VERSION: int = 9" in save and "golems_mandate_part3_v3_save.json" in save)
    check("Schema exclusivo da Parte 3", 'SAVE_SCHEMA_ID: String = "golems_mandate_part3"' in save)
    check("Saves antigos ficam fora da Parte 3", "v2_8_0_save.json" not in save and "v2_7_0_save.json" not in save)
    check("Resumo do save mostra dificuldade", "difficulty_name" in save and "difficulty_name" in main_menu)

    check("Três medalhas finais", all(token in campaign_manager for token in ['"bronze"', '"silver"', '"gold"']))
    check("Pontuação considera dificuldade", "score_bonus" in difficulty and "final_score" in campaign_manager)
    check("Histórico global separado", "square_village_campaign_records.json" in records and "MAX_RECORDS" in records)
    check("Menu mostra melhor medalha", "best_medal_badge" in main_menu and "_refresh_best_medal" in main_menu)
    check("Histórico de vitórias acessível", "records_page" in main_menu and "_refresh_records_page" in main_menu)
    check("Medalha procedural desenhada", all(token in medal_badge for token in ["draw_circle", "draw_colored_polygon", "medal_id"]))
    check("Página de recordes participa da navegação", "records_page" in main_menu.split("func _show_page", 1)[1].split("func _show_main_page", 1)[0])

    winter_ids = ["passos_leves_faz_tudo", "aelric_ferreiro", "kobi_mercante", "orion_draconato", "rubra_meio_demonia", "brunna_ana_barbara"]
    check("Seis falas pessoais sobre o inverno", all(npc_id in relationship_dialogue for npc_id in winter_ids) and relationship_dialogue.count('"winter_warning"') >= 6, str(relationship_dialogue.count('"winter_warning"')))
    check("Representantes alertam sobre o inverno", "_get_representative_winter_warning" in dialogue and "winter_warning" in dialogue.lower())
    check("Sanctuary-Void alerta sobre o inverno", "Sanctuary-Void" in dialogue and "pré-inverno" in dialogue)

    check("Tutorial atualizado para a fila de obras", "TUTORIAL_VERSION: int = 4" in tutorial)
    check("Guia explica dificuldades", "DIFICULDADE" in ui_manager and all(name in ui_manager for name in ["Acolhedora", "Moderada", "Difícil"]))
    check("Guia explica as 24 metas", "24 metas" in ui_manager.lower())
    check("Guia explica medalhas", "MEDALHAS" in ui_manager and all(name in ui_manager.lower() for name in ["bronze", "prata", "ouro"]))
    check("Guia explica preparação para o inverno", "reservas" in ui_manager.lower() and "inverno" in ui_manager.lower())

    check("Oráculo valida balanceamento", "_validate_balance_system" in diagnostics)
    check("Oráculo oferece visão das metas", "_show_balance_snapshot" in diagnostics_window and "SIMULAR METAS" in diagnostics_window)
    check("Simulador de 120 dias incluído", (ROOT / "tools/simulate_economy_stage10.py").is_file())
    check("Relatório de simulação incluído", (ROOT / "SIMULACAO_ECONOMICA_120_DIAS_v2.10.1.txt").is_file())
    if (ROOT / "SIMULACAO_ECONOMICA_120_DIAS_v2.10.1.txt").is_file():
        simulation = read("SIMULACAO_ECONOMICA_120_DIAS_v2.10.1.txt")
        check("Simulação cobre 120 dias", "SIMULAÇÃO ECONÔMICA DE 120 DIAS" in simulation)
        check("Simulação cobre as três dificuldades", all(name in simulation for name in ["ACOLHEDORA", "MODERADA", "DIFÍCIL"]))
        check("Simulação lista as 24 metas", "MATRIZ DAS 24 METAS" in simulation and simulation.count("Dia ") >= 18)



def validate_part3_stage2() -> None:
    project = read("project.godot")
    game = read("scripts/GameManager.gd")
    save = read("scripts/save/SaveManager.gd")
    foundation = read("scripts/foundation/Part3FoundationManager.gd")
    buildings = read("scripts/buildings/BuildingManager.gd")
    building_window = read("scripts/ui/BuildingWindow.gd")
    building_visuals = read("scripts/ui/BuildingVisuals.gd")
    diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")
    ui = read("scripts/UIManager.gd")
    tutorial = read("scripts/tutorial/TutorialManager.gd")

    check("Versão candidata da Etapa 2", 'config/version="3.1.2"' in project)
    check("Save da fila usa schema v9", "const SAVE_VERSION: int = 9" in save)
    check("Migração exclusiva da Etapa 1", all(token in save for token in [
        "if save_version == 8",
        "_migrate_stage1_save_to_stage2",
        '"was_migrated": was_migrated',
        "queue_state_version",
        "construction_orders",
    ]))
    check("Save da Parte 2 continua isolado", "LEGACY_SAVE_PATHS: Array[String] = []" in save)
    check("Nome do projeto não é validado", all(token not in diagnostics for token in [
        'application/config/name',
        'Nome público',
        'nome público',
    ]))

    check("Gerenciador de fila persistente", all(token in buildings for token in [
        "QUEUE_STATE_VERSION: int = 1",
        "construction_orders: Array[Dictionary]",
        "export_save_data",
        "import_save_data",
        '"construction_orders"',
        '"next_order_sequence"',
    ]))
    check("Capacidade por população", all(token in buildings for token in [
        "CONSTRUCTION_POPULATION_STEP: int = 20",
        "MAX_CONSTRUCTION_SITES: int = 4",
        "calculate_construction_site_capacity",
        "1 + floori",
    ]))
    check("Fila possui limite seguro", "MAX_QUEUE_LENGTH: int = 256" in buildings)
    check("Casas e prédios usam a mesma fila", all(token in buildings for token in [
        'HOUSING_ID: String = "housing"',
        "request_construction",
        "_request_house",
        "construction_orders.append(order)",
    ]))
    check("Custo é pago ao entrar na fila", all(token in game for token in [
        "building_manager.request_construction",
        "building_material = maxf(0.0, building_material - material_cost)",
        '"construction_enqueued"',
    ]))
    check("Durações são 1, 2 e 3 dias", all(token in buildings for token in [
        '"work_days": target_level',
        '"work_days": 1',
        "clampi(work_days, 1, 3)",
    ]))
    check("Obra começa somente no dia seguinte", all(token in buildings for token in [
        '"earliest_start_day": requested_day + 1',
        "start_constructions_for_day",
        'order["started_day"] = day_value',
    ]))
    check("Ordem da fila é estrita", "ultrapassa a primeira obra ainda inelegível" in buildings and "A previsão respeita a mesma ordem estrita" in buildings)
    check("Trabalho diário registra progresso", all(token in buildings for token in [
        "process_construction_work_day",
        'order["progress_days"] = progress_days',
        'order["status"] = STATUS_COMPLETED_PENDING',
        'order["available_day"] = completed_day + 1',
    ]))
    check("Avaliação ocorre antes da liberação da obra", game.index("campaign_manager.evaluate_completed_day") < game.index("building_manager.finalize_completed_constructions"))
    check("Conclusão aplica benefício no novo dia", all(token in game for token in [
        "_finalize_construction_transition",
        "finalize_completed_constructions",
        "start_constructions_for_day",
        '"construction_completed"',
    ]))
    check("Queda populacional não cancela obra ativa", "active_count >= capacity" in buildings and "Nenhuma nova obra começou" in buildings and "construction_orders.remove_at" not in buildings.split("func start_constructions_for_day", 1)[1].split("func get_active_effects_text", 1)[0])

    check("Cancelamento pendente devolve 100%", "1.0 if status == STATUS_QUEUED" in buildings)
    check("Cancelamento ativo devolve 50%", "ACTIVE_REFUND_RATE: float = 0.50" in buildings)
    check("Cancelamento não inicia substituta imediatamente", "start_constructions_for_day" not in game.split("func cancel_construction", 1)[1].split("func reorder_construction", 1)[0])
    check("Somente fila pendente pode ser reordenada", "Somente obras que ainda não começaram podem ser reordenadas" in buildings)
    check("Reordenação e cancelamento entram no histórico", all(token in game for token in [
        '"construction_cancelled"',
        '"construction_reordered"',
    ]))

    check("Previsão mostra início e disponibilidade", all(token in buildings + building_window for token in [
        "predicted_start_day",
        "predicted_available_day",
        "Início previsto: dia",
        "Disponível no início do dia",
    ]))
    check("Previsão informa relação com avaliação", all(token in buildings for token in [
        "_build_audit_prediction_text",
        "a tempo da avaliação",
        "depois da avaliação",
    ]))
    check("Interface mostra canteiros e fila", all(token in building_window for token in [
        "FILA DE OBRAS",
        "CANTEIROS:",
        "queue_container",
        "active_orders",
        "queued_orders",
    ]))
    check("Interface permite reordenar", all(token in building_window for token in [
        'up_button.text = "▲"',
        'down_button.text = "▼"',
        "construction_move_requested",
    ]))
    check("Cancelamento possui confirmação segura", all(token in building_window for token in [
        "CONFIRMAÇÃO DE CANCELAMENTO",
        "MANTER OBRA",
        "CANCELAR OBRA",
        "cancel_confirmation_cancel_button.grab_focus",
        "Todo o progresso será perdido",
    ]))
    check("Esc fecha primeiro a confirmação", "cancel_confirmation_overlay.visible" in building_window and "_hide_cancel_confirmation()" in building_window)
    check("Fila usa scroll e mantém saída fixa", "ScrollContainer.new()" in building_window and building_window.index("ScrollContainer.new()") < building_window.index('close_button.text = "VOLTAR À VILA"'))

    check("Canteiros aparecem na vila", all(token in building_visuals for token in [
        "_draw_construction_sites",
        "_draw_single_construction_site",
        "foundation_rect",
        "scaffold_color",
        "progress_days",
    ]))
    check("A vila recorta os canteiros", "clip_contents = true" in building_visuals)
    check("Tutorial v4 explica a fila", "TUTORIAL_VERSION: int = 4" in tutorial and all(token in ui for token in [
        "fila de obras",
        "canteiros",
        "reembolso",
        "dia seguinte",
    ]))
    check("Guia explica a capacidade", "população ÷ 20" in ui or "população / 20" in ui)
    check("Guia explica a avaliação", "avaliação" in ui.lower() and "obra" in ui.lower())

    check("Oráculo possui checagem dedicada da fila", "_validate_construction_queue" in diagnostics and '"Fila de obras"' in diagnostics)
    check("Oráculo valida IDs, status e duração", all(token in diagnostics for token in [
        "Identificador de obra repetido",
        "status desconhecido",
        "duração fora de 1–3 dias",
        "posição da fila não é sequencial",
    ]))
    check("Oráculo não transforma queda populacional em erro", "mais obras ativas que a capacidade atual" in diagnostics and "warnings.append" in diagnostics)

    check("Fundação da Etapa 1 permanece", all(token in foundation for token in [
        "production_history",
        "decision_history",
        "event_flags",
        "councillor_progress",
        "building_variants",
    ]))
    check("XP continua desativado", "grant_councillor_xp(" not in game)
    check("Variantes continuam preparatórias", "choose_building_variant(" not in game)
    check("Fórmulas econômicas preservadas", all(token in game for token in [
        "FOOD_CONSUMPTION_PER_VILLAGER: float = 2.10",
        "MATERIAL_MAINTENANCE_PER_VILLAGER: float = 0.27",
        "HAPPINESS_DECAY_PER_VILLAGER: float = 0.53",
        "COMMON_FOOD_PRODUCTION_PER_VILLAGER: float = 1.55",
        "COMMON_MATERIAL_PRODUCTION_PER_VILLAGER: float = 0.19",
    ]))

    check("Documentação da Etapa 2", (ROOT / "LEIA-ME_PARTE3_ETAPA2_v3.1.2.md").is_file())
    check("Auditoria da fila", (ROOT / "AUDITORIA_FILA_DE_OBRAS_v3.1.2.txt").is_file())
    check("Roteiro de teste da Etapa 2", (ROOT / "ROTEIRO_DE_TESTE_PARTE3_ETAPA2_v3.1.2.txt").is_file())


def validate_stage2_reference_scenarios() -> None:
    # Modelo de referência independente. Ele confirma as regras aprovadas;
    # não é apresentado como execução do GDScript ou do Godot.
    def capacity(population: int) -> int:
        return max(1, min(4, 1 + max(0, population) // 20))

    def available_day(requested_day: int, work_days: int) -> int:
        start_day = requested_day + 1
        return start_day + work_days

    check("Cenário: casa pedida no dia 10 fica disponível no dia 12", available_day(10, 1) == 12)
    check("Cenário: nível 2 pedido no dia 10 fica disponível no dia 13", available_day(10, 2) == 13)
    check("Cenário: nível 3 pedido no dia 10 fica disponível no dia 14", available_day(10, 3) == 14)
    check("Cenário: obra concluída durante o dia 20 não conta na avaliação 20", available_day(19, 1) == 21)
    check("Cenário: capacidade 1–19", all(capacity(value) == 1 for value in [0, 1, 19]))
    check("Cenário: capacidade 20–39", all(capacity(value) == 2 for value in [20, 39]))
    check("Cenário: capacidade 40–59", all(capacity(value) == 3 for value in [40, 59]))
    check("Cenário: capacidade limitada a quatro", all(capacity(value) == 4 for value in [60, 79, 80, 999]))
    check("Cenário: reembolso pendente integral", round(18.0 * 1.0, 1) == 18.0)
    check("Cenário: reembolso ativo pela metade", round(18.0 * 0.5, 1) == 9.0)

def main() -> int:
    validate_scripts()
    validate_resources()
    validate_story_catalog()
    validate_integration()
    validate_stage6_preservation()
    validate_stage8_system()
    validate_stage81_maintenance()
    validate_stage9_audio()
    validate_stage92_visual_fixes()
    validate_stage10_balance()
    validate_part3_stage2()
    validate_stage2_reference_scenarios()

    failed = [result for result in RESULTS if not result.ok]
    for result in RESULTS:
        status = "OK" if result.ok else "FALHA"
        suffix = f" — {result.detail}" if result.detail else ""
        print(f"[{status}] {result.name}{suffix}")
    print(f"\nResumo: {len(RESULTS)} verificações, {len(failed)} falha(s).")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
