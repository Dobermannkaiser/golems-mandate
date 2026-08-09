#!/usr/bin/env python3
"""Contratos corretivos da revisão com as skills 3.0 — v3.11.5.

Não inicializa o Godot e não simula campanhas completas. Os pequenos modelos
abaixo verificam somente invariantes de agenda e recuperação alterados nesta
corretiva.
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


project = read("project.godot")
recruitment = read("scripts/council/CouncilRecruitmentManager.gd")
recruitment_ui = read("scripts/ui/RecruitmentWindow.gd")
council_ui = read("scripts/ui/CouncilWindow.gd")
guide = read("scripts/UIManager.gd")
save = read("scripts/save/SaveManager.gd")
save_ui = read("scripts/ui/SaveWindow.gd")
main_menu = read("scripts/ui/MainMenu.gd")
settings = read("scripts/settings/GameSettings.gd")
tutorial = read("scripts/tutorial/TutorialManager.gd")
records = read("scripts/campaign/CampaignRecords.gd")
audio = read("scripts/audio/AudioManager.gd")
diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")
scene = read("scenes/villager.tscn")
main_scene = read("scenes/main.tscn")

check("Versão pública v3.11.5", 'config/version="3.11.5"' in project)
check("Diagnóstico reconhece v3.11.5", 'project_version != "3.11.5"' in diagnostics)
check("Save global continua v18", "const SAVE_VERSION: int = 18" in save)
check("Schema da campanha continua 5", "const CAMPAIGN_STATE_VERSION: int = 5" in read("scripts/campaign/CampaignManager.gd"))
check("Fila de obras continua schema 2", "const QUEUE_STATE_VERSION: int = 2" in read("scripts/buildings/BuildingManager.gd"))

check("Recrutamento usa estado v3", "const STATE_VERSION: int = 3" in recruitment)
check("Recrutamento aceita saves v1 e v2", "[1, 2, STATE_VERSION]" in recruitment)
check("Oferta v2 remove requisito antigo", "_migrate_threshold_offer" in recruitment and 'migrated["required_relationship_points"] = 0' in recruitment)
check("Seis requisitos estão zerados", len(re.findall(r"\b(?:20|40|60|80|100|120): 0\b", recruitment)) == 6)
check("Todas as fontes conhecidas podem ser elegíveis", "eligible_rows: Array[Dictionary] = source_rows.duplicate(true)" in recruitment)
check("Nenhum teste de limiar bloqueia source_rows", "relationship_points\", 0)) >= required_points" not in recruitment)
check("Oferta materializada continua persistida", '"pending_offer": pending_offer.duplicate(true)' in recruitment)
check("Candidatas materializadas não rerrolam no load", "if not pending_offer.is_empty():\n\t\treturn pending_offer.duplicate(true)" in recruitment)
check("Backlog continua ordenado", "pending_checkpoint_days.sort()" in recruitment)
check("Próxima pendência é preparada após escolha", "var next_offer: Dictionary = _prepare_recruitment_offer(0)" in read("scripts/GameManager.gd"))
check("Resumo separa pendente e futuro", 'status["pending_count"]' in recruitment and 'status["future_count"]' in recruitment)
check("Conselho nomeia escolhas concluídas", "ESCOLHAS CONCLUÍDAS" in council_ui)
check("Janela não mostra razão requisito antigo", "%d/%d" not in recruitment_ui and "cumpriram o requisito" not in recruitment_ui)
check("Guia explica garantia e sequência", "avaliação aprovada garante uma escolha" in guide and "apresentadas em sequência" in guide)

offer_days = [20, 40, 60, 80, 100, 120]
sources = [
    ("mimo", "Passos-Leves", 0),
    ("aelric", "Elfo", 15),
    ("kobi", "Kobold", 30),
    ("orion", "Draconato", 45),
    ("rubra", "Meio-demônia", 60),
    ("brunna", "Anã", 75),
    ("silas", "Meio-vampiro", 90),
    ("dalia", "Bruxa", 105),
]


def choose(day: int, used: set[str], points: dict[str, int]) -> str | None:
    available = [row for row in sources if row[2] <= day and row[0] not in used]
    available.sort(key=lambda row: (-points.get(row[0], 0), row[2], row[0]))
    return available[0][0] if available else None


for scenario_name, points in [
    ("todos zero", {source[0]: 0 for source in sources}),
    ("relações baixas", {source[0]: index for index, source in enumerate(sources)}),
    ("relações invertidas", {source[0]: 100 - index for index, source in enumerate(sources)}),
]:
    used: set[str] = set()
    for day in offer_days:
        source_id = choose(day, used, points)
        if source_id is not None:
            used.add(source_id)
    check(f"Seis ofertas possíveis com {scenario_name}", len(used) == 6)

backlog_used: set[str] = set()
for pending_day in [20, 40, 60]:
    source_id = choose(60, backlog_used, {source[0]: 0 for source in sources})
    if source_id is not None:
        backlog_used.add(source_id)
check("Três pendências acumuladas têm fontes independentes", len(backlog_used) == 3)

check("Save registra versão pública", '"project_version"' in save)
check("Leitura tenta principal antes do backup", save.index("_read_save_path(SAVE_PATH)") < save.index("_read_save_path(SAVE_BACKUP_PATH)"))
check("Versão futura não usa fallback", 'error_code == "future_version"' in save)
check("Backup recuperado é identificado", 'backup_result["loaded_from_backup"] = true' in save)
check("Backup válido não é rotacionado com principal inválido", "if recovered_from_backup_pending:" in save and "não pode ser substituído" in save)
check("Estado de recuperação termina após salvar", "recovered_from_backup_pending = false" in save)
check("Save mostra recuperação ao jogador", "Backup de segurança recuperado" in save_ui)
check("Menu mostra recuperação ao jogador", "BACKUP DE SEGURANÇA RECUPERADO" in main_menu)

check("Configuração canônica", "user://golems_mandate_settings.cfg" in settings)
check("Configuração antiga preservada", "LEGACY_SETTINGS_PATH" in settings)
check("Tutorial canônico", "user://golems_mandate_tutorial.cfg" in tutorial)
check("Tutorial antigo preservado", "LEGACY_TUTORIAL_PATH" in tutorial)
check("Histórico canônico", "user://golems_mandate_campaign_records.json" in records)
check("Histórico antigo preservado", "LEGACY_RECORDS_PATH" in records)
check("Histórico possui escrita temporária", "RECORDS_TEMP_PATH" in records and "get_file_as_string" in records)
check("Histórico possui backup", "RECORDS_BACKUP_PATH" in records and "rename_absolute" in records)
check("Histórico legado é migrado ao caminho canônico", 'if path != RECORDS_PATH:' in records and "_write_records(records)" in records)
check("Backup válido do histórico sobrevive a principal inválido", "not primary_is_valid" in records and "and not backup_is_valid" in records and "rotated_primary" in records)
check("Metadado de áudio canônico", "golems_mandate_audio_bound" in audio and "square_village_audio_bound" not in audio)
check("Placeholder público não usa nome provisório", 'text = "Habitante"' in scene and 'text = "Quadrado"' not in scene)
check("Quatro fundadores não randomizam antes da semente", main_scene.count("randomize_on_ready = false") == 5 and "if randomize_on_ready:\n\t\t_random.randomize()" in read("scripts/Villager.gd"))

legacy_occurrences: list[str] = []
for path in sorted((ROOT / "scripts").rglob("*.gd")):
    text = path.read_text(encoding="utf-8")
    for match in re.finditer("square_village", text):
        legacy_occurrences.append(f"{path.relative_to(ROOT)}:{match.start()}")
check("Nome provisório só aparece nas três rotas legacy", len(legacy_occurrences) == 3)

unsafe_variant_patterns: list[str] = []
unsafe_pattern = re.compile(
    r"String\s*\(\s*[A-Za-z_][A-Za-z0-9_]*\.get\([^,\n]+,\s*-?\d+(?:\.\d+)?\s*\)\s*\)",
    re.MULTILINE,
)
for path in sorted((ROOT / "scripts").rglob("*.gd")):
    text = path.read_text(encoding="utf-8")
    if unsafe_pattern.search(text):
        unsafe_variant_patterns.append(str(path.relative_to(ROOT)))
check("Nenhum String(dicionário.get(..., número)) perigoso", not unsafe_variant_patterns)

sensitive_matches: list[str] = []
for folder in ["dialogue", "events", "relationships", "council"]:
    for path in sorted((ROOT / "scripts" / folder).glob("*.gd")):
        if re.search(r"\bgord(?:o|a|os|as)\b|\bobes", path.read_text(encoding="utf-8"), re.IGNORECASE):
            sensitive_matches.append(str(path.relative_to(ROOT)))
check("Conteúdo removido sobre peso não reapareceu", not sensitive_matches)

all_gdscript = "\n".join(
    path.read_text(encoding="utf-8")
    for path in sorted((ROOT / "scripts").rglob("*.gd"))
)
missing_paths = [
    resource_path
    for resource_path in set(re.findall(r'"(res://[^"\n]+)"', all_gdscript))
    if not (ROOT / resource_path.removeprefix("res://")).exists()
]
check("Todos os caminhos res:// literais existem", not missing_paths)

print("Golem's Mandate — revisão Skills 3.0 — v3.11.5")
print(f"Verificações corretivas: {CHECKS - len(FAILURES)}/{CHECKS} aprovadas")
if FAILURES:
    print("Falhas:")
    for failure in FAILURES:
        print(f"  - {failure}")
    sys.exit(1)
print("Resultado: APROVADO (sem inicializar o Godot e sem simulação extensa).")
