#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from statistics import mean

DIFFICULTIES = {
    "Acolhedora": {
        "prod": 1.15,
        "food_cons": 0.85,
        "maint": 0.85,
        "happy": 0.75,
        "cost": 0.85,
        "initial_food": 42.0,
        "initial_material": 18.0,
        "initial_happiness": 70.0,
    },
    "Moderada": {
        "prod": 1.00,
        "food_cons": 1.00,
        "maint": 1.00,
        "happy": 0.95,
        "cost": 1.00,
        "initial_food": 34.0,
        "initial_material": 12.0,
        "initial_happiness": 62.0,
    },
    "Difícil": {
        "prod": 1.05,
        "food_cons": 1.05,
        "maint": 1.05,
        "happy": 0.95,
        "cost": 1.05,
        "initial_food": 30.0,
        "initial_material": 10.0,
        "initial_happiness": 62.0,
    },
}

SEASONS = [
    (1.10, 1.00, 1.00, 1.10),
    (1.20, 1.00, 1.10, 1.00),
    (1.10, 1.15, 1.00, 1.00),
    (0.80, 1.00, 1.00, 1.00),
]

LEVEL2 = {
    "food_bonus": 0.22,
    "material_bonus": 0.25,
    "decay_reduction": 0.22,
    "daily_happiness": 1.30,
    "maintenance_reduction": 0.25,
    "fixed_food_reduction": 0.0,
    "construction_cost_reduction": 0.0,
}

GENERIC_LEVEL3 = {
    "food_bonus": 0.35,
    "material_bonus": 0.40,
    "decay_reduction": 0.35,
    "daily_happiness": 2.10,
    "maintenance_reduction": 0.40,
    "fixed_food_reduction": 0.0,
    "construction_cost_reduction": 0.0,
}

VARIANTS = {
    "silo_reserve": {"food_bonus": 0.40},
    "community_kitchen": {
        "food_bonus": 0.28,
        "fixed_food_reduction": 0.75,
        "daily_happiness": 0.25,
    },
    "intensive_sawmill": {"material_bonus": 0.44},
    "carpentry_workshop": {
        "material_bonus": 0.30,
        "construction_cost_reduction": 0.10,
    },
    "deep_reservoir": {"decay_reduction": 0.40},
    "community_fountain": {
        "decay_reduction": 0.25,
        "daily_happiness": 0.65,
    },
    "community_market": {
        "food_bonus": 0.04,
        "material_bonus": 0.04,
        "daily_happiness": 1.30,
    },
    "public_garden": {"daily_happiness": 2.30},
    "stone_bastion": {"maintenance_reduction": 0.46},
    "vigilant_gates": {"maintenance_reduction": 0.32},
}

PAIRS = [
    ("silo_reserve", "community_kitchen"),
    ("intensive_sawmill", "carpentry_workshop"),
    ("deep_reservoir", "community_fountain"),
    ("community_market", "public_garden"),
    ("stone_bastion", "vigilant_gates"),
]

LEVEL3_COSTS = [18.0, 20.0, 16.0, 18.0, 22.0]


@dataclass
class Result:
    food: float
    material: float
    happiness: float
    inflow: float
    outflow: float
    utility: float


def merge_variant_effects(selection: tuple[str, ...]) -> dict[str, float]:
    result = {
        "food_bonus": 0.0,
        "material_bonus": 0.0,
        "decay_reduction": 0.0,
        "daily_happiness": 0.0,
        "maintenance_reduction": 0.0,
        "fixed_food_reduction": 0.0,
        "construction_cost_reduction": 0.0,
    }
    for variant_id in selection:
        for key, value in VARIANTS[variant_id].items():
            result[key] += value
    return result


def simulate(
    difficulty: dict[str, float],
    selection: tuple[str, ...] | None,
) -> Result:
    food_stock = difficulty["initial_food"]
    material_stock = difficulty["initial_material"]
    happiness = difficulty["initial_happiness"]
    inflow = 0.0
    outflow = 0.0

    final_effects = GENERIC_LEVEL3 if selection is None else merge_variant_effects(selection)

    # O modelo presume que as cinco especializações entram em vigor no dia 61.
    # Isso isola a força econômica das builds; fila, acontecimentos e relações
    # continuam fora do modelo comparativo.
    material_stock -= sum(LEVEL3_COSTS) * difficulty["cost"]
    if selection is not None and "carpentry_workshop" in selection:
        # Cenário favorável plausível: a oficina é concluída primeiro e reduz
        # o custo das quatro especializações planejadas depois dela.
        later_costs = sum(LEVEL3_COSTS) - 20.0
        material_stock += later_costs * difficulty["cost"] * 0.10

    for day in range(1, 121):
        season_index = (day - 1) // 30
        food_season, material_season, happiness_decay_mult, maintenance_season = SEASONS[season_index]
        population = round(10 + (day - 1) * 25 / 119)
        common = max(0, population - 4)

        effects = LEVEL2 if day <= 60 else final_effects

        # Conselho equilibrado e população comum, iguais em todos os cenários.
        base_food = 4.50 + common * 1.55
        base_material = 2.85 + common * 0.19
        base_happiness = 1.50

        food_prod = (
            base_food
            * (1.0 + effects["food_bonus"])
            * food_season
            * difficulty["prod"]
        )
        material_prod = (
            base_material
            * (1.0 + effects["material_bonus"])
            * material_season
            * difficulty["prod"]
        )
        happiness_prod = (
            base_happiness + effects["daily_happiness"]
        ) * difficulty["prod"]

        food_consumption = max(
            0.0,
            population * 2.10 * difficulty["food_cons"]
            - effects["fixed_food_reduction"],
        )
        material_consumption = (
            population
            * 0.27
            * (1.0 - min(0.75, effects["maintenance_reduction"]))
            * difficulty["maint"]
            * maintenance_season
        )
        happiness_decay = (
            (4 * 0.53 + common * 0.13)
            * (1.0 - min(0.75, effects["decay_reduction"]))
            * difficulty["happy"]
            * happiness_decay_mult
        )

        food_stock = max(0.0, food_stock + food_prod - food_consumption)
        material_stock = max(0.0, material_stock + material_prod - material_consumption)
        happiness = min(100.0, max(0.0, happiness + happiness_prod - happiness_decay))
        inflow += food_prod + material_prod + happiness_prod
        outflow += food_consumption + material_consumption + happiness_decay

    # Utilidade comparativa: estoques são somados e felicidade recebe peso 2
    # por ser limitada a 100 e afetar atração/abandono.
    utility = food_stock + material_stock + happiness * 2.0
    return Result(food_stock, material_stock, happiness, inflow, outflow, utility)


def main() -> int:
    lines = [
        "SIMULAÇÃO ECONÔMICA INICIAL — BUILDS DAS CONSTRUÇÕES — ETAPA 6",
        "Modelo comparativo de 120 dias; não executa o Godot e não substitui o teste de runtime.",
        "As builds entram em vigor no dia 61 para isolar o impacto econômico.",
        "Acontecimentos especiais e reações narrativas não recebem valor econômico estimado.",
        "A Oficina de Carpintaria recebe um cenário favorável plausível: concluída antes das outras quatro builds.",
        "",
    ]

    all_deltas: list[float] = []
    pair_spreads: list[float] = []
    failures: list[str] = []

    for difficulty_name, difficulty in DIFFICULTIES.items():
        baseline = simulate(difficulty, None)
        lines.append(f"DIFICULDADE: {difficulty_name}")
        lines.append(
            f"- nível 3 genérico antigo: utilidade {baseline.utility:.1f}; "
            f"entrada acumulada {baseline.inflow:.1f}"
        )

        combo_results: list[tuple[tuple[str, ...], Result, float]] = []
        for bits in product([0, 1], repeat=5):
            selection = tuple(PAIRS[index][bit] for index, bit in enumerate(bits))
            result = simulate(difficulty, selection)
            delta = 100.0 * (result.inflow - baseline.inflow) / max(1.0, baseline.inflow)
            combo_results.append((selection, result, delta))
            all_deltas.append(delta)

        combo_results.sort(key=lambda item: item[1].utility)
        weakest = combo_results[0]
        strongest = combo_results[-1]
        lines.append(
            f"- combinação de menor utilidade: {weakest[1].utility:.1f} "
            f"({weakest[2]:+.2f}% de entrada) — {', '.join(weakest[0])}"
        )
        lines.append(
            f"- combinação de maior utilidade: {strongest[1].utility:.1f} "
            f"({strongest[2]:+.2f}% de entrada) — {', '.join(strongest[0])}"
        )

        neutral = [pair[0] for pair in PAIRS]
        for pair_index, (left, right) in enumerate(PAIRS):
            left_selection = neutral.copy()
            right_selection = neutral.copy()
            left_selection[pair_index] = left
            right_selection[pair_index] = right
            left_result = simulate(difficulty, tuple(left_selection))
            right_result = simulate(difficulty, tuple(right_selection))
            spread = 100.0 * abs(left_result.utility - right_result.utility) / max(
                1.0, mean([left_result.utility, right_result.utility])
            )
            pair_spreads.append(spread)
            lines.append(
                f"  • {left} x {right}: utilidade {left_result.utility:.1f} x "
                f"{right_result.utility:.1f}; diferença {spread:.2f}%"
            )
        lines.append("")

    max_increase = max(all_deltas)
    min_change = min(all_deltas)
    max_pair_spread = max(pair_spreads)
    lines.extend([
        f"Variação média de entrada vs. nível 3 genérico: {mean(all_deltas):+.2f}%",
        f"Maior aumento de entrada: {max_increase:+.2f}%",
        f"Maior redução de entrada: {min_change:+.2f}%",
        f"Maior diferença de utilidade dentro de um par: {max_pair_spread:.2f}%",
    ])

    if max_increase > 12.0:
        failures.append("Alguma combinação ultrapassa o teto de +12% de entrada.")
    if max_pair_spread > 35.0:
        failures.append("Um par apresenta diferença econômica excessiva acima de 35%.")

    lines.append("Resultado: " + ("APROVADO" if not failures else "REPROVADO"))
    for failure in failures:
        lines.append(f"- {failure}")

    print("\n".join(lines))
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
