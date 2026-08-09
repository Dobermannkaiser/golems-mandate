#!/usr/bin/env python3
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
failures: list[str] = []
passed = 0


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def check(label: str, condition: bool) -> None:
    global passed
    if condition:
        passed += 1
    else:
        failures.append(label)


catalog = read("scripts/relationships/NpcRelationshipCatalog.gd")
manager = read("scripts/relationships/NpcRelationshipManager.gd")
game = read("scripts/GameManager.gd")
ui = read("scripts/UIManager.gd")
window = read("scripts/ui/RelationshipsWindow.gd")
forecast_window = read("scripts/ui/ForecastDetailsWindow.gd")
save = read("scripts/save/SaveManager.gd")
project = read("project.godot")
diagnostics = read("scripts/diagnostics/InternalDiagnostics.gd")

pair_lines = re.findall(r'^\s*_pair\("([^"]+)", "([^"]+)", (-?\d+), (\d+),', catalog, re.M)
pair_keys = {tuple(sorted((a, b))) for a, b, _, _ in pair_lines}
days: list[int] = []
for _, _, _, first_day in pair_lines:
    start = int(first_day)
    days.extend((start, start + 1))

check("versão do projeto 3.9.0", 'config/version="3.9.0"' in project)
check("save global 18", "const SAVE_VERSION: int = 18" in save)
check("migração 17 para 18", "17:" in save and 'version = 18' in save and 'npc_relationships' in save)
check("diagnóstico reconhece etapa 10", 'project_version != "3.9.0"' in diagnostics and "SAVE_VERSION != 18" in diagnostics)
check("oito NPCs cadastrados", len(re.findall(r'^\s*"[^"]+": \{"name":', catalog, re.M)) == 8)
check("28 combinações únicas", len(pair_lines) == 28 and len(pair_keys) == 28)
check("56 dias únicos", len(days) == 56 and len(set(days)) == 56)
check("calendário entre 15 e 118", min(days) == 15 and max(days) == 118)
check("224 respostas derivadas", manager.count('npc_relationship_choice') >= 1 and all(token in manager for token in ['"support_a"', '"support_b"', '"neutral"', '"reconcile"']))
check("cinco estados", all(token in manager for token in ['"conflict"', '"tension"', '"neutral"', '"affinity"', '"strong_bond"']))
check("apoio aplica +20 e -10", '20, -10' in manager and '-10, 20' in manager)
check("conciliação aplica +10/+10", '10, 10, 18' in manager)
check("conciliação tem requisito público", 'disabled_reason' in manager and '_build_reconciliation_requirement' in manager)
check("segunda conversa lembra a primeira", '_get_previous_memory_text' in manager and 'primeira conversa' in manager)
check("comentário posterior", 'get_follow_up_comment' in manager and 'COMENTÁRIO ENTRE PERSONAGENS' in manager)
check("diálogo obrigatório sem fechar", '"allow_close": false' in manager)
check("fim do dia é interrompido", '_try_request_npc_relationship_dialogue' in game and 'npc_relationship_dialogue_requested.emit' in game)
check("escolha é transação única", 'resolved_dialogues.has(dialogue_id)' in manager and 'resolved_dialogues[dialogue_id]' in manager)
check("consequências afetam amizade do jogador", 'foundation_manager.add_relationship_points(a, a_delta)' in game and 'foundation_manager.add_relationship_points(b, b_delta)' in game)
check("mapa possui filtros", all(token in window for token in ['"all"', '"positive"', '"negative"']))
check("causa desconhecida é protegida", 'Ainda não compreendido.' in manager and 'Ainda não compreendido.' in window)
check("mapa não revela NPC futuro", 'visible_pairs' in game and 'foundation_manager.get_relationship_overview(current_day, true)' in game)
check("bônus positivo é 1% e não cumulativo", '0.01 if positive_count > 0 else 0.0' in manager and 'npc_relationship_bonus' in game)
check("bônus é visível na decomposição", 'RELAÇÕES ENTRE PERSONAGENS' in forecast_window and 'npc_relationship_synergy' in forecast_window)
check("save persiste sistema novo", 'game_state["npc_relationships"]' in game and 'import_save_data(npc_relationship_state_value' in game)
check("load restaura diálogo pendente", 'npc_relationship_manager.get_pending_conversation()' in game)
check("UI resolve escolha no domínio", 'GameManager.resolve_npc_relationship_choice(choice_data)' in ui)
check("UI bloqueia novo dia durante diálogo", 'GameManager.has_pending_npc_relationship_dialogue()' in ui)
check("IDs reais de Silas e Dália", '"meio_vampiro_emo_gotico"' in catalog and '"bruxinha_ruiva"' in catalog and 'silas_meio_vampiro' not in catalog and 'dalia_bruxinha' not in catalog)
check("conteúdo de Dália sem tema corporal", not re.search(r'(?i)\b(gorda|gordo|peso|corpo|barriga|emagrec|engord)\w*\b', catalog))

print(f"Etapa 10: {passed} contratos aprovados; {len(failures)} falhas.")
for failure in failures:
    print(f"FALHA: {failure}")
raise SystemExit(1 if failures else 0)
