#!/usr/bin/env python3
from __future__ import annotations

import random
from collections import Counter
from dataclasses import dataclass

ATTRIBUTE_TOTAL = 10
ATTRIBUTE_MINIMUM = 1
ATTRIBUTE_MAXIMUM = 5
FOUNDER_COUNT = 4

NAMES = [
    "Nilo Brisa-Mansa",
    "Tiri Musgo-Claro",
    "Luma Pata-Leve",
    "Pico Trilha-Fina",
    "Vela Dedo-Ágil",
    "Rino Salta-Orvalho",
]
PORTRAITS = [
    "passos_leves_andarilho",
    "passos_leves_artifice",
    "passos_leves_batedor",
    "felix_pescador",
    "lumi_cozinheira",
    "passos_leves_bolseiro",
    "passos_leves_cronista",
]
PASSIVES = [
    "adaptavel", "dedicado", "inquieto", "versatil", "rival_produtivo",
    "organizador", "veterano", "incansavel", "autossuficiente",
    "economico", "motivador", "otimista", "improvisador", "protetor",
    "mediador",
]
PERSONALITIES = [
    "optimistic",
    "cautious",
    "practical",
    "ambitious",
    "kind",
    "stubborn",
    "playful",
    "pessimistic",
]


@dataclass(frozen=True)
class Founder:
    name: str
    portrait: str
    passive: str
    personality: str
    attributes: tuple[int, int, int, int]


def generate_attributes(rng: random.Random) -> tuple[int, int, int, int]:
    values = [ATTRIBUTE_MINIMUM] * 4
    remaining = ATTRIBUTE_TOTAL - sum(values)
    while remaining > 0:
        available = [i for i, value in enumerate(values) if value < ATTRIBUTE_MAXIMUM]
        if not available:
            raise RuntimeError("No available attribute slot")
        values[rng.choice(available)] += 1
        remaining -= 1
    return tuple(values)


def generate_roster(seed: int) -> list[Founder]:
    rng = random.Random(max(1, seed))
    names = NAMES.copy()
    portraits = PORTRAITS.copy()
    passives = PASSIVES.copy()
    personalities = PERSONALITIES.copy()
    rng.shuffle(names)
    rng.shuffle(portraits)
    rng.shuffle(passives)
    rng.shuffle(personalities)
    return [
        Founder(
            name=names[index],
            portrait=portraits[index],
            passive=passives[index],
            personality=personalities[index],
            attributes=generate_attributes(rng),
        )
        for index in range(FOUNDER_COUNT)
    ]


def main() -> int:
    simulations = 10000
    failures: list[str] = []
    attribute_values: Counter[int] = Counter()
    personality_usage: Counter[str] = Counter()
    name_usage: Counter[str] = Counter()
    portrait_usage: Counter[str] = Counter()
    passive_usage: Counter[str] = Counter()
    roster_signatures: set[tuple] = set()

    for seed in range(1, simulations + 1):
        roster = generate_roster(seed)
        if len(roster) != FOUNDER_COUNT:
            failures.append(f"seed {seed}: count")
            continue
        for field_name, values in {
            "name": [founder.name for founder in roster],
            "portrait": [founder.portrait for founder in roster],
            "passive": [founder.passive for founder in roster],
            "personality": [founder.personality for founder in roster],
        }.items():
            if len(set(values)) != FOUNDER_COUNT:
                failures.append(f"seed {seed}: duplicate {field_name}")
        for founder in roster:
            if sum(founder.attributes) != ATTRIBUTE_TOTAL:
                failures.append(f"seed {seed}: total {founder.attributes}")
            if any(value < ATTRIBUTE_MINIMUM or value > ATTRIBUTE_MAXIMUM for value in founder.attributes):
                failures.append(f"seed {seed}: bounds {founder.attributes}")
            attribute_values.update(founder.attributes)
            personality_usage[founder.personality] += 1
            name_usage[founder.name] += 1
            portrait_usage[founder.portrait] += 1
            passive_usage[founder.passive] += 1
        roster_signatures.add(tuple(
            (founder.name, founder.portrait, founder.passive, founder.personality, founder.attributes)
            for founder in roster
        ))

    print("SIMULAÇÃO — CARTAS DO CONSELHO — REGRESSÃO DA ETAPA 5")
    print(f"Campanhas simuladas: {simulations}")
    print(f"Cartas geradas: {simulations * FOUNDER_COUNT}")
    print(f"Falhas de invariantes: {len(failures)}")
    print(f"Conselhos distintos: {len(roster_signatures)}")
    print(f"Distribuição de valores de atributo: {dict(sorted(attribute_values.items()))}")
    print(f"Uso de nomes: {dict(sorted(name_usage.items()))}")
    print(f"Uso de retratos: {dict(sorted(portrait_usage.items()))}")
    print(f"Uso de passivas: {dict(sorted(passive_usage.items()))}")
    print(f"Uso de personalidades: {dict(sorted(personality_usage.items()))}")
    if failures:
        print("Primeiras falhas:")
        for failure in failures[:20]:
            print(f"- {failure}")
        return 1
    print("Resultado: APROVADO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
