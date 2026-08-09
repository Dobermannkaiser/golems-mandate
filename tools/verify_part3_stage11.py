#!/usr/bin/env python3
"""Auditoria estática da Parte 3 — Etapa 11 (v3.10.1)."""

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


def jpeg_dimensions(path: Path) -> tuple[int, int] | None:
    data = path.read_bytes()
    if not data.startswith(b"\xff\xd8"):
        return None
    offset = 2
    while offset + 9 <= len(data):
        if data[offset] != 0xFF:
            offset += 1
            continue
        marker = data[offset + 1]
        offset += 2
        if marker in {0xD8, 0xD9}:
            continue
        if offset + 2 > len(data):
            return None
        segment_length = int.from_bytes(data[offset:offset + 2], "big")
        if segment_length < 2 or offset + segment_length > len(data):
            return None
        if marker in {
            0xC0, 0xC1, 0xC2, 0xC3, 0xC5, 0xC6, 0xC7,
            0xC9, 0xCA, 0xCB, 0xCD, 0xCE, 0xCF,
        }:
            height = int.from_bytes(data[offset + 3:offset + 5], "big")
            width = int.from_bytes(data[offset + 5:offset + 7], "big")
            return width, height
        offset += segment_length
    return None


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
        elif char in ")]}":
            if not stack or stack.pop() != expected[char]:
                return f"delimitador inesperado: {char}"
    return None if not stack else f"delimitador não fechado: {stack[-1]}"


project = read("project.godot")
save = read("scripts/save/SaveManager.gd")
catalog = read("scripts/relationships/RelationshipCatalog.gd")
dialogue_catalog = read("scripts/relationships/RelationshipDialogueCatalog.gd")
relationship_state = read("scripts/models/RelationshipState.gd")
foundation = read("scripts/foundation/Part2FoundationManager.gd")
game = read("scripts/GameManager.gd")
ui = read("scripts/UIManager.gd")
relationship_window = read("scripts/ui/RelationshipsWindow.gd")
dialogue_window = read("scripts/ui/DialogueWindow.gd")
village = read("scripts/ui/BuildingVisuals.gd")
village_pawn = read("scripts/ui/VillagePawn.gd")
village_window = read("scripts/ui/VillageWindow.gd")
campaign_window = read("scripts/ui/CampaignWindow.gd")
diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")

check("Versão pública v3.10.1", 'config/version="3.10.1"' in project)
check("Save global permanece v18", "const SAVE_VERSION: int = 18" in save)
check(
    "Compatibilidade direta com o save da v3.9.0",
    'SAVE_VERSION != 18' in diagnostics and "Etapa 11 deve manter" in diagnostics,
)
check(
    "Marcos exatos 200/400/600/800",
    "PERSONAL_EVENT_POINT_THRESHOLDS: Array[int] = [200, 400, 600, 800]" in catalog,
)
check(
    "Nomes dos quatro marcos",
    all(name in catalog for name in ["Amizade", "Confiança", "Intimidade", "Decisão"]),
)
check(
    "Liberação usa pontos, não nível",
    "points >= PERSONAL_EVENT_POINT_THRESHOLDS[index]" in catalog
    and "relationship_points" in catalog,
)
check(
    "Interface expõe próximo marco",
    "next_personal_event_threshold" in foundation
    and "next_personal_event_stage" in foundation
    and "Próxima cena" in relationship_window,
)
check(
    "Interesse é registrado nas cenas 400 e 600",
    "if index in [1, 2]" in dialogue_catalog
    and "record_romance_interest" in dialogue_catalog,
)
check(
    "Romance exige duas marcas",
    "interest_markers.size() >= 2" in dialogue_catalog,
)
check(
    "Romance ocorre somente na decisão final",
    "var is_final_event: bool = index == 3" in dialogue_catalog
    and "if is_final_event:" in dialogue_catalog
    and "commit_romance" in dialogue_catalog,
)
check(
    "Amizade profunda sempre disponível",
    "respectful_friendship" in dialogue_catalog
    and "amizade profunda" in dialogue_catalog,
)
check(
    "Decidir depois sempre disponível",
    "defer_relationship_decision" in dialogue_catalog
    and "decidir depois" in dialogue_catalog.lower(),
)
check(
    "Adiar não conclui o evento",
    game.find('if action == "defer_relationship_decision"')
    < game.find("complete_relationship_personal_event", game.find("func resolve_relationship_choice")),
)
check(
    "Adiar não rejeita romance",
    "defer_relationship_decision" in game
    and "A decisão foi adiada" in game
    and 'match action:' in game,
)
check(
    "Exclusividade de parceiro preservada",
    "another_partner" in dialogue_catalog and "official_partner_id" in dialogue_catalog,
)
check(
    "Mimo permanece apenas amizade",
    "MIMO_ID" in catalog
    and "MIMO_ID" not in catalog.split("const ROMANCE_IDS", 1)[1].split("]", 1)[0],
)
check(
    "Estado persistente anterior preservado",
    all(
        key in relationship_state
        for key in [
            "relationship_points",
            "romance_interest_markers",
            "official_partner",
            "romance_declined",
            "completed_personal_event_ids",
        ]
    ),
)

expected_images = {
    "aelric.jpg": (1280, 960),
    "brunna.jpg": (1280, 1024),
    "dalia.jpg": (1280, 1024),
    "kobi.jpg": (1280, 1024),
    "mimo.jpg": (1280, 720),
    "orion.jpg": (1280, 1024),
    "rubra.jpg": (1280, 1024),
    "silas.jpg": (1280, 1024),
}
scene_dir = ROOT / "assets/relationships/scenes_800"
actual_images = {path.name for path in scene_dir.glob("*.jpg")}
check("Exatamente oito imagens finais", actual_images == set(expected_images))
for image_name, dimensions in expected_images.items():
    image_path = scene_dir / image_name
    check(f"JPEG válido: {image_name}", image_path.is_file() and jpeg_dimensions(image_path) == dimensions)
    check(
        f"Imagem catalogada: {image_name}",
        f"res://assets/relationships/scenes_800/{image_name}" in catalog,
    )
check(
    "Cena de 800 exibe imagem antes da decisão",
    '"scene_image_path": image_path' in dialogue_catalog
    and "_configure_scene_image" in dialogue_window
    and dialogue_window.find("scene_art_frame") < dialogue_window.find("choices_container ="),
)
check(
    "Fallback seguro para imagem ausente",
    "ResourceLoader.exists" in dialogue_window
    and "_apply_scene_image_fallback" in dialogue_window,
)

check("Peça de tabuleiro procedural", "class_name VillageBoardPawn" in village_pawn)
check(
    "Peça não depende de sprite de aldeão",
    "Texture2D" not in village_pawn and "load(" not in village_pawn,
)
check(
    "Paleta possui ao menos doze cores",
    len(
        re.findall(
            r'Color\("#[0-9A-Fa-f]{6}"\)',
            village.split("const PAWN_COLORS", 1)[1]
            .split("= [", 1)[1]
            .split("\n]", 1)[0],
        )
    ) >= 12,
)
check(
    "Representantes têm cor estável e inicial",
    "REPRESENTATIVE_COLOR_INDEX" in village
    and "_get_pawn_initial" in village
    and 'get_node_or_null("Badge")' in village,
)
check(
    "Representante selecionado tem destaque",
    "is_selected" in village_pawn and "Color(\"#F1C86C\")" in village_pawn,
)
check(
    "Peças não dependem somente de cor",
    "pattern_index % 5" in village_pawn
    and all(mood in village_pawn for mood in ['"joyful"', '"worried"', '"crisis"']),
)
check(
    "Aldeões antigos ficam ocultos",
    "villager.visible = false" in ui and "VillageBoardPawn" in village,
)
check(
    "Felicidade possui quatro faixas",
    all(token in village for token in ["happiness >= 70.0", "happiness >= 40.0", "happiness >= 20.0"]),
)
check(
    "Felicidade altera movimento e marcas",
    "_get_happiness_movement_multiplier" in village
    and "_get_happiness_mood_id" in village
    and "_draw_responsive_ambience" in village,
)
check(
    "Sem filtro global de crise",
    "full_screen" not in village.lower() and "crisis_overlay" not in village.lower(),
)
check(
    "Feedback visual recebe construção, sucesso e crise",
    "signal village_visual_feedback_requested" in game
    and all(kind in game for kind in ['"construction"', '"success"', '"crisis"']),
)
check(
    "Feedback chega aos dois mapas",
    "_on_village_visual_feedback_requested" in ui
    and "show_world_feedback" in village_window
    and "show_world_feedback" in village,
)
check(
    "Redução de movimento respeitada",
    "GameSettings.reduced_motion" in village,
)
check(
    "Canteiro continua genérico e único",
    village.count("func _draw_single_construction_site") == 1
    and "construction_site_" not in village
    and "scaffold_color" in village,
)
check(
    "Nenhum novo diretório de decoração",
    not (ROOT / "assets/decorations").exists()
    and not (ROOT / "assets/decoration").exists(),
)
check(
    "Dez variantes finais anteriores preservadas",
    len(re.findall(r'"[a-z_]+": "res://assets/buildings/variants/[^"]+"', village)) == 10,
)
check(
    "Diagnóstico interno cobre imagens e marcos",
    "scene_image_count" in diagnostics
    and "expected_thresholds" in diagnostics
    and "_get_relationship_choice_actions" in diagnostics,
)
check(
    "Campanha formata a frase composta como uma unidade",
    'description_label.text = (\n\t\t(\n\t\t\t"Dificuldade %s' in campaign_window,
)
check(
    "Previsão formata atração e risco separadamente",
    '+ (\n\t\t\t"\\nAtração: %d/%d dias favoráveis."' in ui
    and '+ (\n\t\t\t"\\nRisco de abandono: %d/%d dias preocupantes."' in ui,
)
schema_validator = save.split("func _get_game_state_schema_error", 1)[1].split(
    "func _migrate_save_data", 1
)[0]
check(
    "Save estrutural informa a seção inválida",
    "_get_game_state_schema_error" in save
    and "seção obrigatória '%s' ausente" in save,
)
check(
    "Auditoria cruzada não bloqueia estado completo",
    "_validate_cross_system_state" not in schema_validator,
)
check(
    "Pendência diária possui estado e retomada centralizados",
    "func _get_advance_day_blocker" in ui
    and "func _refresh_advance_day_state" in ui
    and "func _resume_pending_mandatory_content" in ui
    and "request_pending_npc_relationship_dialogue" in game,
)
check(
    "Diagnóstico aceita progressão e troca da Mimo",
    "founder.get_attribute_total()" in diagnostics
    and "Mimo deve iniciar na reserva" not in diagnostics,
)

gd_files = sorted(ROOT.rglob("*.gd"))
structural_errors: list[str] = []
duplicate_function_errors: list[str] = []
missing_preloads: list[str] = []
indentation_errors: list[str] = []
for script_path in gd_files:
    script_text = script_path.read_text(encoding="utf-8")
    relative_script = script_path.relative_to(ROOT).as_posix()
    error = delimiter_error(script_text)
    if error:
        structural_errors.append(f"{relative_script}: {error}")
    clean_script = strip_comments_and_strings(script_text)
    function_names = re.findall(
        r"(?m)^\s*(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(",
        clean_script,
    )
    duplicates = sorted({name for name in function_names if function_names.count(name) > 1})
    if duplicates:
        duplicate_function_errors.append(f"{relative_script}: {', '.join(duplicates)}")
    for target in re.findall(r'preload\(\s*"res://([^"]+)"\s*\)', script_text, re.S):
        if not (ROOT / target).is_file():
            missing_preloads.append(f"{relative_script}: {target}")
    bad_lines = [
        line_number
        for line_number, line in enumerate(script_text.splitlines(), 1)
        if line.startswith(" ") and line.strip()
    ]
    if bad_lines:
        indentation_errors.append(f"{relative_script}: {bad_lines[:5]}")

check(f"Delimitadores válidos em {len(gd_files)} scripts", not structural_errors)
check("Funções sem duplicatas por script", not duplicate_function_errors)
check("Todos os preloads existem", not missing_preloads)
check("Indentação GDScript permanece em tabs", not indentation_errors)
check(
    "Sem marcadores de conflito",
    not any(
        marker in path.read_text(encoding="utf-8")
        for path in ROOT.rglob("*.gd")
        for marker in ["<<<<<<<", "=======", ">>>>>>>"]
    ),
)

print("Golem's Mandate — Parte 3, Etapa 11")
print(f"Verificações: {CHECKS}")
if FAILURES:
    print(f"Falhas: {len(FAILURES)}")
    for failure in FAILURES:
        print(f"- {failure}")
    sys.exit(1)
print("Falhas: 0")
print("Resultado: APROVADO")
