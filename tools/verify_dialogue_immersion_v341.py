#!/usr/bin/env python3
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RESULTS: list[tuple[str, bool, str]] = []


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def check(name: str, ok: bool, detail: str = "") -> None:
    RESULTS.append((name, bool(ok), detail))


def main() -> int:
    opportunity = read("scripts/council/CouncillorOpportunityDialogueCatalog.gd")
    progression = read("scripts/council/CouncillorProgressionDialogueCatalog.gd")
    relationships = read("scripts/relationships/RelationshipDialogueCatalog.gd")
    dialogue = read("scripts/dialogue/DialogueCatalog.gd")

    forbidden_runtime_phrases = [
        "As três respostas têm consequências reais e visíveis na economia da vila",
        "O projeto começa hoje e produz efeitos até o fim do dia",
        "Quando terminar, o resultado será registrado na ficha histórica",
        "A conversa transformou a conquista em impulso concreto",
        "ficou registrado no meu histórico",
        "Nível máximo!",
        "teto desta etapa",
        "máximo desta jornada",
        "máximo desta etapa",
        "Retrato, resposta, histórico e avanço funcionaram",
    ]
    joined = "\n".join([opportunity, progression, relationships, dialogue])
    for phrase in forbidden_runtime_phrases:
        check(f"Fala não contém metalinguagem: {phrase}", phrase not in joined)

    check(
        "Oportunidade começa com contexto narrado",
        'nodes["context"]' in opportunity
        and '"speaker_name": "Narrador"' in opportunity
        and '"start": "context"' in opportunity,
    )
    check(
        "Representante só fala sua reação e personalidade",
        '"text": OPPORTUNITY_CATALOG_SCRIPT.get_personality_opening' in opportunity
        and 'String(choice.get("result", "Vou cuidar disso."))' in opportunity,
    )
    check(
        "Informação mecânica permanece nas opções",
        '"text": String(choice.get("text"' in opportunity,
    )
    check(
        "Recompensa de nível não é narrada como sistema",
        'profile.get("best_response", "Vou lembrar disso.")' in progression
        and "+1 de" not in progression,
    )
    check(
        "Falhas e sucessos usam reação pessoal",
        "Agora veremos o que ela muda para a vila" in progression
        and "Cabe aprender com ele e seguir" in progression,
    )
    check(
        "Eventos pessoais usam narrador para premissa",
        '"speaker_name": "Narrador"' in relationships
        and '"hide_portrait": true' in relationships,
    )
    check(
        "Respostas narrativas não são atribuídas ao NPC",
        'static func _reply_node(_portrait_id: String, _name: String, text: String)' in relationships
        and '"speaker_name": "Narrador"' in relationships,
    )
    check(
        "Diagnóstico de Mimo permanece diegético",
        "O cristal guardou nossa conversa" in dialogue
        and "a caixa de diálogo não virou um sapo" in dialogue,
    )

    # Mechanical notation is allowed in choice labels, but not in generated spoken text.
    spoken_sources = opportunity + progression
    bad_spoken_patterns = [
        r"economia da vila",
        r"ficha histórica",
        r"interface",
        r"tooltip",
        r"clique",
        r"\+\d+ de [a-záéíóúç]+ para a vila",
    ]
    for pattern in bad_spoken_patterns:
        check(
            f"Falas geradas evitam padrão mecânico {pattern}",
            re.search(pattern, spoken_sources, re.I) is None,
        )

    failures = [row for row in RESULTS if not row[1]]
    print("Golem's Mandate — auditoria de imersão dos diálogos — v3.4.1")
    print(f"Verificações: {len(RESULTS)}")
    print(f"Falhas: {len(failures)}")
    if failures:
        print("\nFALHAS:")
        for name, _, detail in failures:
            print(f"- {name}: {detail}")
        return 1
    print("Resultado: APROVADO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
