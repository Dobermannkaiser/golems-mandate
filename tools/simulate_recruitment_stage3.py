#!/usr/bin/env python3
from __future__ import annotations

import random
from collections import Counter

OFFER_DAYS = [20, 40, 60, 80, 100, 120]
NPCS = [
    ("passos_leves_faz_tudo", "Passos-Leves", 0),
    ("aelric_ferreiro", "Elfo", 15),
    ("kobi_mercante", "Kobold", 30),
    ("orion_draconato", "Draconato", 45),
    ("rubra_meio_demonia", "Meio-demônia", 60),
    ("brunna_ana_barbara", "Anã", 75),
]


def choose_source(day: int, points: dict[str, int], used: set[str]) -> tuple[str, str] | None:
    eligible = [
        (npc_id, species, arrival, points.get(npc_id, 0))
        for npc_id, species, arrival in NPCS
        if arrival <= day and npc_id not in used
    ]
    if not eligible:
        return None
    eligible.sort(key=lambda row: (-row[3], row[2], row[0]))
    return eligible[0][0], eligible[0][1]


def main() -> int:
    simulations = 10_000
    failures: list[str] = []
    species_usage: Counter[str] = Counter()
    second_choice_cases = 0

    for seed in range(1, simulations + 1):
        rng = random.Random(seed)
        points = {npc_id: 0 for npc_id, _, _ in NPCS}
        used: set[str] = set()
        offers: list[tuple[int, str, str]] = []
        for day in OFFER_DAYS:
            for npc_id, _, arrival in NPCS:
                if arrival <= day:
                    points[npc_id] += rng.randrange(0, 81)
            ranked = sorted(
                [
                    (npc_id, points[npc_id], arrival)
                    for npc_id, _, arrival in NPCS
                    if arrival <= day
                ],
                key=lambda row: (-row[1], row[2], row[0]),
            )
            source = choose_source(day, points, used)
            if source is None:
                failures.append(f"seed {seed}: sem fonte no dia {day}")
                break
            npc_id, species = source
            if npc_id in used:
                failures.append(f"seed {seed}: NPC repetido {npc_id}")
            if ranked and ranked[0][0] in used and npc_id != ranked[0][0]:
                second_choice_cases += 1
            used.add(npc_id)
            species_usage[species] += 1
            offers.append((day, npc_id, species))
        if len(offers) != len(OFFER_DAYS):
            failures.append(f"seed {seed}: {len(offers)} ofertas")
        if len({npc_id for _, npc_id, _ in offers}) != len(offers):
            failures.append(f"seed {seed}: repetição de fonte")

    print("SIMULAÇÃO — RECRUTAMENTO DE CARTAS — v3.2.3")
    print(f"Campanhas simuladas: {simulations}")
    print(f"Ofertas simuladas: {simulations * len(OFFER_DAYS)}")
    print(f"Falhas: {len(failures)}")
    print(f"Casos em que a segunda maior amizade foi usada: {second_choice_cases}")
    print(f"Uso de espécies: {dict(sorted(species_usage.items()))}")
    if failures:
        for failure in failures[:20]:
            print(f"- {failure}")
        return 1
    print("Resultado: APROVADO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
