#!/usr/bin/env python3
"""Verifica a propagação do modo interno até a regra de pontos."""

from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
FAILURES: list[str] = []


def read(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


def check(label: str, condition: bool) -> None:
    if not condition:
        FAILURES.append(label)


state = read("scripts/models/RelationshipState.gd")
foundation = read("scripts/foundation/Part2FoundationManager.gd")
dialogue = read("scripts/relationships/RelationshipDialogueCatalog.gd")
game = read("scripts/GameManager.gd")
ui = read("scripts/UIManager.gd")
window = read("scripts/ui/RelationshipsWindow.gd")
runtime_test = read("tools/test_internal_relationship_test_v382.gd")

check(
    "A janela propaga o modo atual",
    "conversation_requested.emit(npc_id, current_test_mode)" in window,
)
check(
    "A UI informa o modo ao catálogo",
    "GameManager.get_relationship_world_context(),\n\t\tinclude_unknown" in ui,
)
check(
    "As escolhas carregam a flag interna",
    '"relationship_internal_test": internal_test_mode' in dialogue,
)
check(
    "O GameManager lê a flag interna",
    'choice_data.get("relationship_internal_test", false)' in game,
)
check(
    "A fundação encaminha a exceção",
    "ignore_daily_limit: bool = false" in foundation,
)
check(
    "A exceção aplica pontos sem consumir o dia",
    "ignore_daily_limit or can_gain_conversation_points(day)" in state
    and "if not ignore_daily_limit:\n\t\t\tlast_conversation_day = day" in state,
)
check(
    "O limite normal continua presente",
    "return day > 0 and last_conversation_day != day" in state,
)
check(
    "A interface explica a exceção",
    "Conversas de teste geram pontos sem limite diário" in window,
)
check(
    "O teste de runtime cobre 54 pontos e o limite normal",
    "relationship.relationship_points != 54" in runtime_test
    and "O limite diário do jogo normal deixou de funcionar." in runtime_test,
)

print("Golem's Mandate — correção do Teste Interno v3.8.2")
print(f"Verificações: 9")
print(f"Falhas: {len(FAILURES)}")
for failure in FAILURES:
    print(f"- {failure}")
sys.exit(1 if FAILURES else 0)
