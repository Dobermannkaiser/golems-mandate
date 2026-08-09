#!/usr/bin/env python3
from __future__ import annotations

import random
from collections import Counter
from dataclasses import dataclass
from itertools import combinations

RNG = random.Random(3400)
SIMULATIONS = 120_000

PROFESSIONS = ("farmer", "blacksmith", "civil", "guard", "gatherer")
PASSIVES = (
    "adaptavel", "dedicado", "inquieto", "versatil", "rival_produtivo",
    "organizador", "veterano", "incansavel", "autossuficiente",
    "economico", "motivador", "otimista", "improvisador", "protetor",
    "mediador",
)
CONCENTRATION = {1: 1.00, 2: 0.97, 3: 0.93, 4: 0.88}
BASE_OUTPUT = {
    "farmer": (3.25, 0.0, 0.0),
    "blacksmith": (0.0, 2.0, 0.0),
    "civil": (0.0, 0.0, 0.95),
    "guard": (0.0, 0.0, 0.55),
    "gatherer": (1.25, 0.85, 0.0),
}
DIFFICULTIES = {
    "cozy": (1.15, 0.85, 0.85),
    "moderate": (1.00, 1.00, 1.00),
    "hard": (1.05, 1.05, 1.05),
}


@dataclass(frozen=True)
class Card:
    profession: str
    passive: str
    level: int
    streak: int
    change_count: int
    versatile_professions: int


def passive_bonus(card: Card, counts: Counter[str]) -> tuple[float, float, float, float]:
    """production multiplier, happiness, food reduction, material reduction"""
    p = card.passive
    multiplier = 0.0
    happiness = 0.0
    food_reduction = 0.0
    material_reduction = 0.0
    if p == "adaptavel":
        multiplier = 0.03
    elif p == "dedicado" and card.streak >= 5:
        multiplier = 0.06
    elif p == "inquieto" and card.change_count > 0 and card.streak < 3:
        multiplier = 0.06
    elif p == "versatil":
        multiplier = min(0.04, card.versatile_professions * 0.01)
    elif p == "rival_produtivo" and counts[card.profession] == 2:
        multiplier = 0.05
    elif p == "organizador":
        multiplier = 0.03
    elif p == "veterano":
        multiplier = min(0.05, max(0, card.level - 1) * 0.01)
    elif p == "autossuficiente":
        food_reduction = 2.10
    elif p == "economico":
        material_reduction = 0.30
    elif p == "motivador":
        happiness = 0.25
    elif p == "otimista":
        # Stress case assumes the condition is fulfilled.
        happiness = 0.25
    return multiplier, happiness, food_reduction, material_reduction


def build_synergy_candidates(cards: list[Card], totals: tuple[float, float, float]):
    food, material, happiness = totals
    candidates: list[tuple[str, tuple[int, ...], float, str, float]] = []
    pair_defs = (
        ("ciclo_sustento", {"farmer", "gatherer"}, food * 0.03, "food", 0.03),
        ("forja_abastecida", {"blacksmith", "gatherer"}, material * 0.03, "material", 0.03),
        ("obras_protegidas", {"blacksmith", "guard"}, 0.25, "maintenance", 0.25),
        ("ordem_comunitaria", {"civil", "guard"}, 0.25, "happiness", 0.25),
    )
    for synergy_id, required, score, kind, value in pair_defs:
        for i, j in combinations(range(4), 2):
            if {cards[i].profession, cards[j].profession} == required:
                candidates.append((synergy_id, (i, j), score, kind, value))
    if len({card.profession for card in cards}) == 4:
        candidates.append((
            "conselho_diverso",
            (0, 1, 2, 3),
            (food + material + happiness) * 0.02,
            "all",
            0.02,
        ))
    return candidates


def select_synergies(candidates):
    best = []
    best_score = -1.0
    for candidate in candidates:
        if candidate[2] > best_score:
            best = [candidate]
            best_score = candidate[2]
    for first, second in combinations(candidates, 2):
        if first[0] == second[0] or set(first[1]) & set(second[1]):
            continue
        score = first[2] + second[2]
        if score > best_score:
            best = [first, second]
            best_score = score
    return best[:2]


def calculate(cards: list[Card], difficulty: tuple[float, float, float]):
    prod_mult, food_cons_mult, material_cons_mult = difficulty
    counts = Counter(card.profession for card in cards)
    personal = [0.0, 0.0, 0.0]
    fixed_food = 0.0
    fixed_material = 0.0
    for card in cards:
        f, m, h = BASE_OUTPUT[card.profession]
        bonus, happiness, food_reduction, material_reduction = passive_bonus(card, counts)
        personal[0] += f * (1.0 + bonus)
        personal[1] += m * (1.0 + bonus)
        personal[2] += h * (1.0 + bonus) + happiness
        fixed_food += food_reduction * food_cons_mult
        fixed_material += material_reduction

    # Representative plus common-population production at population 20.
    common = 16
    food = (personal[0] + common * 1.55) * prod_mult
    material = (personal[1] + common * 0.19) * prod_mult
    happiness = personal[2] * prod_mult
    baseline = (
        (sum(BASE_OUTPUT[c.profession][0] for c in cards) + common * 1.55) * prod_mult,
        (sum(BASE_OUTPUT[c.profession][1] for c in cards) + common * 0.19) * prod_mult,
        sum(BASE_OUTPUT[c.profession][2] for c in cards) * prod_mult,
    )

    active = select_synergies(build_synergy_candidates(cards, (food, material, happiness)))
    used: set[int] = set()
    maintenance_synergy = 0.0
    for _, members, _, kind, value in active:
        assert not (used & set(members))
        used.update(members)
        if kind == "food":
            food *= 1.0 + value
        elif kind == "material":
            material *= 1.0 + value
        elif kind == "maintenance":
            maintenance_synergy += value
        elif kind == "happiness":
            happiness += value
        elif kind == "all":
            food *= 1.0 + value
            material *= 1.0 + value
            happiness *= 1.0 + value
    assert len(active) <= 2

    concentration = CONCENTRATION[max(counts.values())]
    food *= concentration
    material *= concentration
    happiness *= concentration
    baseline_inflow = sum(baseline)
    final_inflow = food + material + happiness

    baseline_outflow = 20 * 2.10 * food_cons_mult + 20 * 0.27 * material_cons_mult
    outflow_reduction = min(baseline_outflow, fixed_food + fixed_material + maintenance_synergy)
    total_economic_baseline = baseline_inflow + baseline_outflow
    total_economic_benefit = final_inflow + outflow_reduction
    return {
        "production_delta": 100.0 * (final_inflow - baseline_inflow) / max(1.0, baseline_inflow),
        "economic_delta": 100.0 * (total_economic_benefit - baseline_inflow) / max(1.0, total_economic_baseline),
        "active_synergies": len(active),
        "concentration": concentration,
    }


def random_card(profession: str, passive: str) -> Card:
    return Card(
        profession=profession,
        passive=passive,
        level=RNG.randint(1, 6),
        streak=RNG.randint(0, 9),
        change_count=RNG.randint(0, 4),
        versatile_professions=RNG.randint(0, 5),
    )


def main() -> int:
    maximum_production = (-10_000.0, None)
    maximum_economic = (-10_000.0, None)
    minimum_production = (10_000.0, None)
    passive_usage: Counter[str] = Counter()
    concentration_usage: Counter[float] = Counter()
    synergy_count_usage: Counter[int] = Counter()

    for _ in range(SIMULATIONS):
        professions = [RNG.choice(PROFESSIONS) for _ in range(4)]
        passives = RNG.sample(PASSIVES, 4)
        cards = [random_card(professions[i], passives[i]) for i in range(4)]
        difficulty_name = RNG.choice(tuple(DIFFICULTIES))
        result = calculate(cards, DIFFICULTIES[difficulty_name])
        passive_usage.update(passives)
        concentration_usage[result["concentration"]] += 1
        synergy_count_usage[result["active_synergies"]] += 1
        signature = (difficulty_name, tuple(professions), tuple(passives))
        if result["production_delta"] > maximum_production[0]:
            maximum_production = (result["production_delta"], signature)
        if result["production_delta"] < minimum_production[0]:
            minimum_production = (result["production_delta"], signature)
        if result["economic_delta"] > maximum_economic[0]:
            maximum_economic = (result["economic_delta"], signature)

    failures: list[str] = []
    if set(passive_usage) != set(PASSIVES):
        failures.append("nem todas as passivas foram exercitadas")
    if maximum_production[0] > 12.0 + 1e-9:
        failures.append(f"aumento produtivo acima de 12%: {maximum_production[0]:.2f}%")
    if max(synergy_count_usage, default=0) > 2:
        failures.append("mais de duas sinergias ativas")

    print("SIMULAÇÃO DE ESTRESSE — PASSIVAS, SINERGIAS E CONCENTRAÇÃO — ETAPA 5")
    print(f"Conselhos aleatórios simulados: {SIMULATIONS}")
    print(f"Passivas exercitadas: {len(passive_usage)} / {len(PASSIVES)}")
    print(f"Uso de multiplicadores de concentração: {dict(sorted(concentration_usage.items()))}")
    print(f"Quantidade de sinergias ativas: {dict(sorted(synergy_count_usage.items()))}")
    print(f"Maior aumento de produção: {maximum_production[0]:+.2f}%")
    print(f"Maior redução de produção: {minimum_production[0]:+.2f}%")
    print(f"Maior ganho econômico combinado estimado: {maximum_economic[0]:+.2f}%")
    if failures:
        print(f"Falhas: {len(failures)}")
        for failure in failures:
            print(f"- {failure}")
        return 1
    print("Falhas: 0")
    print("Resultado: APROVADO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
