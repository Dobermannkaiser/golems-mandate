#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from statistics import mean

DIFFICULTIES = {
    "Acolhedora": {
        "prod": 1.15, "food_cons": 0.85, "maint": 0.85, "happy": 0.75,
        "initial_food": 42.0, "initial_material": 18.0, "initial_happiness": 70.0,
    },
    "Moderada": {
        "prod": 1.00, "food_cons": 1.00, "maint": 1.00, "happy": 0.95,
        "initial_food": 34.0, "initial_material": 12.0, "initial_happiness": 62.0,
    },
    "Difícil": {
        "prod": 1.05, "food_cons": 1.05, "maint": 1.05, "happy": 0.95,
        "initial_food": 30.0, "initial_material": 10.0, "initial_happiness": 62.0,
    },
}

SEASONS = [
    (1.10, 1.00, 1.00),
    (1.20, 1.00, 1.10),
    (1.10, 1.15, 1.00),
    (0.80, 1.00, 1.00),
]

CONCENTRATION = {1: 1.00, 2: 0.97, 3: 0.93, 4: 0.88}


@dataclass(frozen=True)
class Card:
    profession: str
    passive: str
    level: int = 3
    streak: int = 8


BASE_OUTPUT = {
    "farmer": (3.25, 0.0, 0.0),
    "blacksmith": (0.0, 2.0, 0.0),
    "civil": (0.0, 0.0, 0.95),
    "guard": (0.0, 0.0, 0.55),
    "gatherer": (1.25, 0.85, 0.0),
}


def passive_multiplier(card: Card, counts: dict[str, int], all_assigned: bool) -> float:
    p = card.passive
    if p == "adaptavel": return 0.03
    if p == "dedicado": return 0.06 if card.streak >= 5 else 0.0
    if p == "inquieto": return 0.06 if card.streak < 3 else 0.0
    if p == "rival_produtivo": return 0.05 if counts[card.profession] == 2 else 0.0
    if p == "organizador": return 0.03 if all_assigned else 0.0
    if p == "veterano": return min(0.05, max(0, card.level - 1) * 0.01)
    if p == "faz_tudo": return 0.10 if counts[card.profession] == 1 else 0.05
    return 0.0


def synergies(cards: list[Card], totals: tuple[float, float, float]) -> list[tuple[str, tuple[int, ...], float, str]]:
    food, material, happiness = totals
    candidates: list[tuple[str, tuple[int, ...], float, str]] = []
    pairs = [
        ("Ciclo de Sustento", {"farmer", "gatherer"}, food * 0.03, "food"),
        ("Forja Abastecida", {"blacksmith", "gatherer"}, material * 0.03, "material"),
        ("Obras Protegidas", {"blacksmith", "guard"}, 0.25, "maintenance"),
        ("Ordem Comunitária", {"civil", "guard"}, 0.25, "happiness"),
    ]
    for name, required, score, kind in pairs:
        for i, j in combinations(range(len(cards)), 2):
            if {cards[i].profession, cards[j].profession} == required:
                candidates.append((name, (i, j), score, kind))
    if len({c.profession for c in cards}) == 4:
        candidates.append(("Conselho Diverso", tuple(range(4)), (food + material + happiness) * 0.02, "all"))
    best: list[tuple[str, tuple[int, ...], float, str]] = []
    best_score = -1.0
    for c in candidates:
        if c[2] > best_score:
            best = [c]
            best_score = c[2]
    for a, b in combinations(candidates, 2):
        if a[0] == b[0] or set(a[1]) & set(b[1]):
            continue
        score = a[2] + b[2]
        if score > best_score:
            best = [a, b]
            best_score = score
    return best[:2]


def simulate(cards: list[Card], difficulty: dict[str, float], stage5: bool) -> dict[str, float]:
    food_stock = difficulty["initial_food"]
    material_stock = difficulty["initial_material"]
    happiness = difficulty["initial_happiness"]
    cumulative_inflow = 0.0
    cumulative_outflow = 0.0
    for day in range(1, 121):
        season_index = (day - 1) // 30
        food_season, material_season, happiness_decay_mult = SEASONS[season_index]
        population = round(10 + (day - 1) * 25 / 119)
        common = max(0, population - 4)
        counts: dict[str, int] = {}
        for card in cards:
            counts[card.profession] = counts.get(card.profession, 0) + 1
        personal = [0.0, 0.0, 0.0]
        for card in cards:
            f, m, h = BASE_OUTPUT[card.profession]
            bonus = passive_multiplier(card, counts, True) if stage5 else 0.0
            personal[0] += f * (1 + bonus)
            personal[1] += m * (1 + bonus)
            personal[2] += h * (1 + bonus)
            if stage5 and card.passive == "motivador": personal[2] += 0.25
            if stage5 and card.passive == "otimista" and happiness < 55: personal[2] += 0.25
        food_prod = (personal[0] + common * 1.55) * food_season * difficulty["prod"]
        material_prod = (personal[1] + common * 0.19) * material_season * difficulty["prod"]
        happiness_prod = personal[2] * difficulty["prod"]
        maintenance_reduction = 0.0
        if stage5:
            active = synergies(cards, (food_prod, material_prod, happiness_prod))
            for _, _, _, kind in active:
                if kind == "food": food_prod *= 1.03
                elif kind == "material": material_prod *= 1.03
                elif kind == "maintenance": maintenance_reduction += 0.25
                elif kind == "happiness": happiness_prod += 0.25
                elif kind == "all":
                    food_prod *= 1.02
                    material_prod *= 1.02
                    happiness_prod *= 1.02
            mult = CONCENTRATION[max(counts.values())]
            food_prod *= mult
            material_prod *= mult
            happiness_prod *= mult
        food_consumption = population * 2.10 * difficulty["food_cons"]
        material_consumption = population * 0.27 * difficulty["maint"]
        if stage5:
            if any(c.passive == "autossuficiente" for c in cards):
                food_consumption -= 2.10 * difficulty["food_cons"]
            if any(c.passive == "economico" for c in cards):
                material_consumption -= 0.30
            material_consumption -= maintenance_reduction
        food_consumption = max(0.0, food_consumption)
        material_consumption = max(0.0, material_consumption)
        happiness_decay = (4 * 0.53 + common * 0.13) * difficulty["happy"] * happiness_decay_mult
        food_stock = max(0.0, food_stock + food_prod - food_consumption)
        material_stock = max(0.0, material_stock + material_prod - material_consumption)
        happiness = min(100.0, max(0.0, happiness + happiness_prod - happiness_decay))
        cumulative_inflow += food_prod + material_prod + happiness_prod
        cumulative_outflow += food_consumption + material_consumption + happiness_decay
    return {
        "food": food_stock,
        "material": material_stock,
        "happiness": happiness,
        "inflow": cumulative_inflow,
        "outflow": cumulative_outflow,
    }


SCENARIOS = {
    "equilibrado": [
        Card("farmer", "adaptavel"), Card("blacksmith", "veterano"),
        Card("civil", "motivador"), Card("guard", "protetor"),
    ],
    "quatro_profissoes": [
        Card("farmer", "organizador"), Card("blacksmith", "economico"),
        Card("gatherer", "versatil"), Card("civil", "incansavel"),
    ],
    "concentracao_alimento": [
        Card("farmer", "dedicado"), Card("farmer", "rival_produtivo"),
        Card("gatherer", "adaptavel"), Card("civil", "motivador"),
    ],
    "concentracao_material": [
        Card("blacksmith", "dedicado"), Card("blacksmith", "rival_produtivo"),
        Card("gatherer", "economico"), Card("guard", "protetor"),
    ],
    "quatro_iguais": [
        Card("farmer", "dedicado"), Card("farmer", "rival_produtivo"),
        Card("farmer", "adaptavel"), Card("farmer", "veterano"),
    ],
    "passivas_fixadas": [
        Card("farmer", "autossuficiente"), Card("blacksmith", "economico"),
        Card("civil", "motivador"), Card("guard", "otimista"),
    ],
    "mimo_ativa": [
        Card("farmer", "faz_tudo"), Card("blacksmith", "adaptavel"),
        Card("gatherer", "veterano"), Card("civil", "motivador"),
    ],
}


def main() -> int:
    rows: list[str] = [
        "SIMULAÇÃO ECONÔMICA INICIAL — ETAPA 5",
        "Modelo comparativo de 120 dias; não executa o Godot nem substitui o teste de runtime.",
        "Valores de dificuldade, consumo, manutenção e recursos iniciais seguem os catálogos do projeto.",
        "O modelo mede impacto relativo; não tenta reproduzir construções, eventos, relações ou aprovação de avaliações.",
        "",
    ]
    deltas: list[float] = []
    for difficulty_name, difficulty in DIFFICULTIES.items():
        rows.append(f"DIFICULDADE: {difficulty_name}")
        for scenario_name, cards in SCENARIOS.items():
            baseline = simulate(cards, difficulty, False)
            stage5 = simulate(cards, difficulty, True)
            delta = 100.0 * (stage5["inflow"] - baseline["inflow"]) / max(1.0, baseline["inflow"])
            deltas.append(delta)
            rows.append(
                f"- {scenario_name}: entrada acumulada {stage5['inflow']:.1f} "
                f"({delta:+.2f}% vs. a mesma composição sem a Etapa 5)"
            )
        rows.append("")
    rows.append(f"Variação média da entrada: {mean(deltas):+.2f}%")
    rows.append(f"Maior aumento: {max(deltas):+.2f}%")
    rows.append(f"Maior redução: {min(deltas):+.2f}%")
    cap_ok = max(deltas) <= 12.0
    rows.append("Limite de +12%: " + ("APROVADO" if cap_ok else "REPROVADO"))
    # Structural invariant: four identical must be reduced by 12% before stock.
    assert CONCENTRATION[4] == 0.88
    assert CONCENTRATION[3] == 0.93
    assert CONCENTRATION[2] == 0.97
    print("\n".join(rows))
    return 0 if cap_ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
