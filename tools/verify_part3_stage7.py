#!/usr/bin/env python3
"""Auditoria estática da Parte 3 / Etapa 7 — recrutamento de cartas.

Não executa Godot. Valida integração, persistência, UI, conteúdo e referências.
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


def check(name: str, condition: bool, detail: str = "") -> None:
    RESULTS.append(Result(name, bool(condition), detail))


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


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
                triple = False
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
                return f"delimitador inesperado {char!r} no offset {index}"
            stack.pop()
    if stack:
        char, index = stack[-1]
        return f"delimitador {char!r} não fechado no offset {index}"
    return None


def functions_in(path: Path) -> set[str]:
    clean = strip_comments_and_strings(path.read_text(encoding="utf-8"))
    return set(re.findall(
        r"(?m)^\s*(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(",
        clean,
    ))


def inherited_functions(path: Path) -> set[str]:
    available = functions_in(path)
    text = path.read_text(encoding="utf-8")
    match = re.search(r'(?m)^extends\s+"res://([^"]+)"', text)
    if match is None:
        return available
    base = ROOT / match.group(1)
    if base.is_file():
        available.update(inherited_functions(base))
    return available


def validate_all_gdscript() -> None:
    scripts = sorted(
        path for path in ROOT.rglob("*.gd")
        if "development_archive" not in path.parts
    )
    check("Scripts GDScript encontrados", bool(scripts), str(len(scripts)))
    for path in scripts:
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
        available = inherited_functions(path)
        callbacks = set(re.findall(
            r"\.connect\(\s*([A-Za-z_][A-Za-z0-9_]*)",
            clean,
            re.S,
        ))
        missing_callbacks = sorted(
            cb for cb in callbacks
            if cb not in available and cb not in {"queue_free", "hide", "show"}
        )
        check(
            f"Callbacks locais existem: {rel}",
            not missing_callbacks,
            ", ".join(missing_callbacks) or "ok",
        )
        private_calls = set(re.findall(
            r"(?<![.A-Za-z0-9_])(_[A-Za-z][A-Za-z0-9_]*)\s*\(",
            clean,
        ))
        missing_private = sorted(private_calls - available)
        check(
            f"Chamadas privadas existem: {rel}",
            not missing_private,
            ", ".join(missing_private) or "ok",
        )
        for target in re.findall(r'preload\(\s*"res://([^"]+)"\s*\)', text, re.S):
            check(
                f"Preload existe: {rel} -> {target}",
                (ROOT / target).is_file(),
                target,
            )


def validate_version_and_compatibility() -> None:
    project = read("project.godot")
    menu = read("scripts/ui/MainMenu.gd")
    layout = read("scripts/UIManagerVariantB.gd")
    diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")
    save = read("scripts/save/SaveManager.gd")
    tutorial = read("scripts/tutorial/TutorialManager.gd")
    check("Versão pública é 3.8.2", 'config/version="3.8.2"' in project)
    check("Menu mostra 3.8.2", '"3.8.2"' in menu)
    check("Layout mostra v3.8.2", "v3.8.2" in layout)
    check("Diagnóstico exige 3.8.2", 'project_version != "3.8.2"' in diagnostics)
    check("Save global permanece compatível na versão 17", "const SAVE_VERSION: int = 17" in save)
    check("Tutorial revisado usa versão 7", "const TUTORIAL_VERSION: int = 7" in tutorial)
    check("Mensagem de save não cita Etapa 5", "Etapa 5" not in save)


def validate_recruitment_manager() -> None:
    manager = read("scripts/council/CouncilRecruitmentManager.gd")
    game = read("scripts/GameManager.gd")
    expected_thresholds = {20: 50, 40: 120, 60: 220, 80: 340, 100: 480, 120: 620}
    for day, points in expected_thresholds.items():
        check(
            f"Requisito do Dia {day} é {points}",
            re.search(rf"(?m)^\s*{day}:\s*{points},?\s*$", manager) is not None,
        )
    check("Estado de recrutamento evoluiu para v2", "const STATE_VERSION: int = 2" in manager)
    check("Estado v1 é aceito para migração", "state_version not in [1, STATE_VERSION]" in manager)
    check("Fila de vagas pendentes existe", "pending_checkpoint_days" in manager)
    check("Vaga é registrada após avaliação", "func register_checkpoint" in manager)
    check("Oferta tenta a vaga pendente mais antiga", "pending_checkpoint_days[0]" in manager)
    check("Vaga só é removida ao concluir a oferta", "pending_checkpoint_days.erase(checkpoint_day)" in manager)
    check("Recrutamento termina no Dia 120", "[20, 40, 60, 80, 100, 120]" in manager)
    check("NPC fonte não se repete", "used_source_npc_ids.has(npc_id)" in manager)
    check("Empate gera escolha de espécie", '"phase": "species_choice"' in manager or '"species_choice" if species_options.size() > 1' in manager)
    check("Escolha de espécie possui função própria", "func select_species(" in manager)
    check("Oferta sempre usa duas candidatas", "const CANDIDATE_COUNT: int = 2" in manager)
    check("Candidatas compartilham espécie escolhida", '"species_name": species_name' in manager)
    check("Passivas existentes influenciam a sacola", "existing_passive_ids" in manager and "get_randomized_passives" in manager)
    check("Nível usa a vaga original", "get_candidate_level(checkpoint_day)" in manager)
    check("Média do Conselho não interfere mais no nível", "active_level_average" not in manager and "active_level_average" not in game)
    check("Progressão é 2/3/4/5/6/6", "1 + floori(float(checkpoint_day) / 20.0)" in manager and "Villager.MAX_LEVEL" in manager)
    check("Atributos do nível chegam distribuídos", "add_progression_attribute_points" in manager)
    check("Recruta começa na reserva", '"is_council_active": false' in manager)
    check("Recruta tem marca de carta dinâmica", '"is_recruited_card": true' in manager)
    check("Status mostra pontos faltantes", '"missing_points"' in manager and '"required_relationship_points"' in manager)
    check("Save inclui vagas pendentes", '"pending_checkpoint_days"' in manager and "export_save_data" in manager)
    check("Oferta pendente é validada no load", "func _validate_pending_offer" in manager)
    check("Load valida opções de espécie", "func _validate_species_choice_offer" in manager)
    check("Load valida as duas candidatas", "func _validate_candidate_choice_offer" in manager)
    check("Load valida nível, retrato, passiva e atributos", "expected_attribute_total" in manager and "portrait_ids.has(portrait_id)" in manager and "passive_ids.has(passive_id)" in manager)
    check("Avaliação reprovada não chama recrutamento", "if checkpoint_passed:" in game and "_prepare_recruitment_offer(completed_day)" in game)
    check("Ofertas atrasadas são encadeadas", "var next_offer: Dictionary = _prepare_recruitment_offer(0)" in game)
    check("Histórico registra vaga e NPC fonte", '"checkpoint_day"' in game and '"source_npc_id"' in game and '"candidate_level"' in game)
    check("Migração reconstrói avaliações aprovadas", "campaign_manager.completed_checkpoint_days" in game and "legacy_recruitment_state" in game)
    check("Estado derivado é recalculado em todo load", "_sync_legacy_narrative_from_story()" in game and "_prepare_recruitment_offer(0)" in game)
    check("Pendências finais podem ser rechecadas", "func recheck_pending_recruitment_after_final_audit" in game and "current_day <= 120" in game)
    check("Visão do Conselho inclui recrutamento", '"recruitment": get_recruitment_overview()' in game)


def validate_ui_and_tutorial() -> None:
    window = read("scripts/ui/RecruitmentWindow.gd")
    council = read("scripts/ui/CouncilWindow.gd")
    ui = read("scripts/UIManager.gd")
    check("Janela emite escolha de espécie", "signal species_selected" in window)
    check("Janela emite escolha de candidata", "signal candidate_selected" in window)
    check("Janela tem fase de espécie", "_rebuild_species_choices" in window)
    check("Janela mostra requisito e pontuação", "required_relationship_points" in window and "relationship_points" in window)
    check("Janela mostra duas cartas lado a lado", "candidates_row" in window and "_create_candidate_card" in window)
    check("UI conecta escolha de espécie", "recruitment_window.species_selected.connect" in ui)
    check("UI conecta oferta pronta", "GameManager.recruitment_offer_ready.connect" in ui)
    check("UI mostra vaga bloqueada", "_on_recruitment_status_changed" in ui and 'state", "")) != "blocked"' in ui)
    check("Conselho mostra estado persistente", "_recruitment_status" in council and "_refresh_recruitment_status" in council)
    check("Reserva é dinâmica por OptionButton", "_reserve_selector" in council and "for entry: Dictionary in _reserve_entries" in council)
    check("Comparação inclui personalidade", "PERSONALIDADE" in council and "personality_name" in council)
    check("Guia explica seis requisitos", "50, 120, 220, 340, 480 e 620" in ui)
    check("Guia explica vaga pendente", "vaga permanece pendente" in ui)
    check("Guia explica desempate por espécie", "espécies diferentes empatam" in ui)
    check("Guia informa níveis fixos", "níveis 2, 3, 4, 5, 6 e 6" in ui)
    check("Guia explica pendências após o Dia 120", "Após o Dia 120, nenhuma vaga nova é criada" in ui)
    check("Rechecagem final ocorre depois de fechar diálogo", "GameManager.recheck_pending_recruitment_after_final_audit()" in ui)
    check("Janela usa vínculo, não amizade genérica", "sua amizade com" not in window and "seu vínculo com" in window)
    check("Tutorial não afirma uma única reserva", "QUATRO ATIVOS E UMA RESERVA" not in ui)
    check("Tutorial não coloca NPCs da história no Conselho", "entram na reserva após seus capítulos" not in ui)
    check("Save/guia não exige campanha nova nesta etapa", "Esta etapa exige uma campanha nova" not in ui)


def extract_array_block(text: str, key: str) -> str:
    match = re.search(rf'"{re.escape(key)}"\s*:\s*\[(.*?)\]\s*,?', text, re.S)
    return match.group(1) if match else ""


def validate_portraits_and_species() -> None:
    catalog = read("scripts/council/CouncilCardCatalog.gd")
    character_catalog = read("scripts/dialogue/CharacterCatalog.gd")
    species = [
        "Passos-Leves", "Elfo", "Anã", "Draconato", "Meio-demônia",
        "Kobold", "Bruxa", "Meio-vampiro",
    ]
    for name in species:
        block = extract_array_block(catalog, name)
        portrait_ids = re.findall(r'"([^"]+)"', block)
        # SPECIES_NAMES é a primeira ocorrência; procurar explicitamente no bloco de retratos.
        portrait_section = catalog.split("const SPECIES_PORTRAIT_IDS", 1)[1]
        portrait_block = extract_array_block(portrait_section, name)
        portrait_ids = re.findall(r'"([^"]+)"', portrait_block)
        check(f"{name} possui ao menos dois retratos", len(portrait_ids) >= 2, str(portrait_ids))
        for portrait_id in portrait_ids:
            matching_resources = []
            for resource_path in (ROOT / "characters").glob("*.tres"):
                resource_text = resource_path.read_text(encoding="utf-8")
                if f'character_id = "{portrait_id}"' in resource_text:
                    matching_resources.append(resource_path)
            check(
                f"Retrato {portrait_id} está cadastrado",
                len(matching_resources) == 1,
                ", ".join(path.name for path in matching_resources) or portrait_id,
            )
            if matching_resources:
                resource_text = matching_resources[0].read_text(encoding="utf-8")
                portrait_match = re.search(r'portrait_path = "res://([^"]+)"', resource_text)
                check(
                    f"Arquivo do retrato {portrait_id} existe",
                    portrait_match is not None and (ROOT / portrait_match.group(1)).is_file(),
                    portrait_match.group(1) if portrait_match else "portrait_path ausente",
                )
    check("Catálogo rejeita espécie sem duas imagens", "get_portrait_ids(species_name).size() >= 2" in catalog)


def validate_resource_paths() -> None:
    missing: list[str] = []
    pattern = re.compile(r'res://([^"\'\s)]+)')
    for path in ROOT.rglob("*"):
        if not path.is_file() or "development_archive" in path.parts:
            continue
        if path.suffix.lower() not in {".gd", ".tscn", ".tres", ".godot"} and path.name != "project.godot":
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for target in pattern.findall(text):
            if not (ROOT / target).exists():
                missing.append(f"{path.relative_to(ROOT)} -> {target}")
    check("Referências res:// existem", not missing, "\n".join(missing[:20]) or "ok")


def main() -> int:
    validate_version_and_compatibility()
    validate_recruitment_manager()
    validate_ui_and_tutorial()
    validate_portraits_and_species()
    validate_all_gdscript()
    validate_resource_paths()
    failures = [result for result in RESULTS if not result.ok]
    print("Golem's Mandate — auditoria da Parte 3 / Etapa 7")
    print(f"Verificações: {len(RESULTS)}")
    print(f"Falhas: {len(failures)}")
    if failures:
        print("\nFALHAS:")
        for failure in failures:
            print(f"- {failure.name}: {failure.detail}")
        return 1
    print("Resultado: APROVADO")
    return 0


if __name__ == "__main__":
    sys.exit(main())
