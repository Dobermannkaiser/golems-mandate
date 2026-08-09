#!/usr/bin/env python3
"""Simulação determinística/Monte Carlo da economia da Etapa 10.

O modelo replica as fórmulas centrais do GameManager (produção, consumo,
manutenção, felicidade, crescimento e estações). A escolha diária de profissões
e construções é uma política automatizada, não uma garantia de como todo jogador
agirá. Eventos são representados por variações pequenas e simétricas porque o
catálogo real depende das escolhas do jogador.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from itertools import combinations_with_replacement
from math import ceil
from pathlib import Path
import random
import statistics

ROOT = Path(__file__).resolve().parents[1]
REPORT_PATH = ROOT / "SIMULACAO_ECONOMICA_120_DIAS_v2.10.1.txt"

DIFFICULTIES = {
    "cozy": {
        "name": "Acolhedora", "production": 1.15, "food_consumption": 0.85,
        "maintenance": 0.85, "happiness_decay": 0.75, "cost": 0.85,
        "food_target": 0.80, "material_target": 0.80,
        "population_target": 0.95, "happiness_offset": -8.0,
        "attraction": 2, "abandonment": 4, "initial": (42.0, 18.0, 70.0),
    },
    "moderate": {
        "name": "Moderada", "production": 1.0, "food_consumption": 1.0,
        "maintenance": 1.0, "happiness_decay": 0.95, "cost": 1.0,
        "food_target": 1.0, "material_target": 1.0,
        "population_target": 1.0, "happiness_offset": 0.0,
        "attraction": 3, "abandonment": 3, "initial": (34.0, 12.0, 62.0),
    },
    "hard": {
        "name": "Difícil", "production": 1.05, "food_consumption": 1.05,
        "maintenance": 1.05, "happiness_decay": 0.95, "cost": 1.05,
        "food_target": 1.05, "material_target": 1.02,
        "population_target": 1.05, "happiness_offset": 0.0,
        "attraction": 3, "abandonment": 2, "initial": (30.0, 10.0, 62.0),
    },
}

BASE_TARGETS = {
    20: (50.0, 22.0, 53.0, 11),
    40: (75.0, 38.0, 55.0, 15),
    60: (105.0, 55.0, 57.0, 20),
    80: (135.0, 72.0, 58.0, 25),
    100: (165.0, 82.0, 55.0, 30),
    120: (200.0, 98.0, 54.0, 35),
}
CHECKPOINTS = tuple(BASE_TARGETS)

SEASONS = {
    "spring": (1.10, 1.00, 1.00, 1.10, 1.00),
    "summer": (1.20, 1.00, 1.00, 1.00, 1.10),
    "autumn": (1.10, 1.15, 1.00, 1.00, 1.00),
    "winter": (0.80, 1.00, 1.20, 1.00, 1.00),
}

BUILDINGS = {
    "barn": [(6.0, 0.10), (11.0, 0.22), (18.0, 0.35)],
    "sawmill": [(8.0, 0.12), (13.0, 0.25), (20.0, 0.40)],
    "well": [(5.0, 0.10), (10.0, 0.22), (16.0, 0.35)],
    "square": [(7.0, 0.60), (12.0, 1.30), (18.0, 2.10)],
    "wall": [(9.0, 0.12), (15.0, 0.25), (22.0, 0.40)],
}

# Produção média de um representante com atributo efetivo 6.
PROFESSIONS = {
    "farmer": (6.4, 0.0, 0.0),
    "blacksmith": (0.0, 4.1, 0.0),
    "civil_servant": (0.0, 0.0, 2.1),
    "guard": (0.0, 0.0, 1.2),
    "gatherer": (2.5, 1.7, 0.0),
}
COMBINATIONS = []
for professions in combinations_with_replacement(PROFESSIONS, 4):
    COMBINATIONS.append((
        professions,
        sum(PROFESSIONS[p][0] for p in professions),
        sum(PROFESSIONS[p][1] for p in professions),
        sum(PROFESSIONS[p][2] for p in professions),
    ))


def season_for_day(day: int) -> tuple[float, float, float, float, float]:
    if day <= 30:
        return SEASONS["spring"]
    if day <= 60:
        return SEASONS["summer"]
    if day <= 90:
        return SEASONS["autumn"]
    return SEASONS["winter"]


def adjusted_target(day: int, difficulty: dict) -> tuple[float, float, float, int]:
    food, material, happiness, population = BASE_TARGETS[day]
    return (
        round(food * difficulty["food_target"]),
        round(material * difficulty["material_target"]),
        max(0.0, min(100.0, happiness + difficulty["happiness_offset"])),
        max(1, ceil(population * difficulty["population_target"])),
    )


@dataclass
class CampaignSimulation:
    difficulty_id: str
    policy: str
    seed: int
    food: float = 0.0
    material: float = 0.0
    happiness: float = 0.0
    population: int = 8
    capacity: int = 10
    houses: int = 2
    attraction_progress: int = 0
    concerning_streak: int = 0
    levels: dict[str, int] = field(default_factory=lambda: {key: 0 for key in BUILDINGS})
    checkpoint_results: list[dict] = field(default_factory=list)
    failed_day: int = 0
    lowest_happiness: float = 100.0
    winter_start_food: float = 0.0

    def __post_init__(self) -> None:
        self.rules = DIFFICULTIES[self.difficulty_id]
        self.food, self.material, self.happiness = self.rules["initial"]
        self.rng = random.Random(self.seed)

    def next_checkpoint(self, day: int) -> int:
        return next(checkpoint for checkpoint in CHECKPOINTS if checkpoint >= day)

    def level_value(self, building_id: str) -> float:
        level = self.levels[building_id]
        return 0.0 if level == 0 else BUILDINGS[building_id][level - 1][1]

    def house_cost(self) -> float:
        return (8.0 + float(self.houses - 2) * 4.0) * self.rules["cost"]

    def build_house(self) -> bool:
        cost = self.house_cost()
        if self.material + 1e-6 < cost:
            return False
        self.material -= cost
        self.houses += 1
        self.capacity += 5
        return True

    def upgrade(self, building_id: str) -> bool:
        level = self.levels[building_id]
        if level >= 3:
            return False
        cost = BUILDINGS[building_id][level][0] * self.rules["cost"]
        if self.material + 1e-6 < cost:
            return False
        self.material -= cost
        self.levels[building_id] += 1
        return True

    def manage_buildings(self, day: int) -> None:
        checkpoint = self.next_checkpoint(day)
        targets = adjusted_target(checkpoint, self.rules)
        days_left = checkpoint - day + 1
        # A campanha planejada constrói somente a capacidade necessária para a
        # próxima meta, evitando crescimento descontrolado antes do inverno.
        desired_capacity = targets[3] + (2 if day <= 90 else 1)
        if self.capacity < desired_capacity:
            cost = self.house_cost()
            expected_material = self.material + days_left * (4.5 if self.policy == "planned" else 1.8)
            if expected_material - cost >= targets[1]:
                self.build_house()
                return

        if self.policy == "casual":
            if day in (12, 34, 66, 84):
                self.upgrade("barn")
            if day in (28, 58, 78):
                self.upgrade("well")
            return

        if self.policy == "neglectful":
            if day in (30, 70):
                self.upgrade("barn")
            return

        priorities = ["barn", "well", "square", "sawmill", "wall"]
        if day >= 51:
            priorities = ["barn", "sawmill", "well", "square", "wall"]
        if day >= 81:
            priorities = ["barn", "well", "square", "wall", "sawmill"]
        if day % 5 != 1:
            return
        for building_id in priorities:
            level = self.levels[building_id]
            if level >= 3:
                continue
            cost = BUILDINGS[building_id][level][0] * self.rules["cost"]
            # Não gastar a reserva da auditoria atual. A margem usa uma
            # produção conservadora, menor que a observada na política.
            conservative_future = self.material + days_left * 4.5
            if conservative_future - cost >= targets[1] + 4.0:
                self.upgrade(building_id)
                return

    def choose_professions(self, day: int) -> tuple[tuple[str, ...], float, float, float]:
        checkpoint = self.next_checkpoint(day)
        target_food, target_material, target_happiness, _ = adjusted_target(checkpoint, self.rules)
        days_left = max(1, checkpoint - day + 1)
        common = max(0, self.population - 4)
        season_food, season_material, food_cons_mult, maintenance_mult, happiness_mult = season_for_day(day)
        food_bonus = self.level_value("barn")
        material_bonus = self.level_value("sawmill")
        happiness_reduction = self.level_value("well")
        happiness_bonus = self.level_value("square")
        maintenance_reduction = self.level_value("wall")

        food_cost = self.population * 2.10 * food_cons_mult * self.rules["food_consumption"]
        material_cost = self.population * 0.27 * (1.0 - maintenance_reduction) * maintenance_mult * self.rules["maintenance"]
        happiness_cost = (
            4.0 * 0.53 + common * 0.13
        ) * (1.0 - happiness_reduction) * happiness_mult * self.rules["happiness_decay"]

        # Outono deve criar a reserva que será consumida no inverno.
        winter_food_buffer = 0.0
        if 61 <= day <= 90:
            winter_food_buffer = 220.0 if self.difficulty_id == "hard" else 170.0
        desired_food_net = (target_food + 10.0 + winter_food_buffer - self.food) / days_left
        desired_material_net = (target_material + 6.0 - self.material) / days_left
        desired_happiness_net = (target_happiness + 3.0 - self.happiness) / days_left

        if self.policy == "casual":
            desired_food_net *= 0.82
            desired_material_net *= 0.82
            desired_happiness_net *= 0.82
        elif self.policy == "neglectful":
            desired_food_net *= 0.55
            desired_material_net *= 0.55
            desired_happiness_net *= 0.45

        best = None
        for professions, representative_food, representative_material, representative_happiness in COMBINATIONS:
            food_production = (
                representative_food * (1.0 + food_bonus)
                + common * 1.55 * (1.0 + food_bonus)
            ) * season_food * self.rules["production"]
            material_production = (
                representative_material * (1.0 + material_bonus)
                + common * 0.19 * (1.0 + material_bonus)
            ) * season_material * self.rules["production"]
            happiness_production = (
                representative_happiness + happiness_bonus
            ) * self.rules["production"]
            food_net = food_production - food_cost
            material_net = material_production - material_cost
            happiness_net = happiness_production - happiness_cost
            loss = (
                max(0.0, desired_food_net - food_net) ** 2 * 4.0
                + max(0.0, desired_material_net - material_net) ** 2 * 5.0
                + max(0.0, desired_happiness_net - happiness_net) ** 2 * 8.0
            )
            # A política planejada mantém uma reserva de felicidade para o inverno
            # e para os requisitos de atração, em vez de perseguir somente a meta
            # imediatamente seguinte.
            projected_happiness = self.happiness + happiness_net
            safety_happiness = 61.0
            if self.policy == "planned":
                safety_happiness = {"cozy": 64.0, "moderate": 69.0, "hard": 72.0}[self.difficulty_id]
            elif self.policy == "casual":
                safety_happiness = 60.0
            if projected_happiness < safety_happiness:
                loss += (safety_happiness - projected_happiness) ** 2 * 5.5
            if projected_happiness < 42.0:
                loss += (42.0 - projected_happiness) ** 2 * 20.0
            # No inverno, não permitir que a política ignore uma queda alimentar grande.
            if day >= 91 and food_net < -6.0:
                loss += (-6.0 - food_net) ** 2 * 2.0
            candidate = (loss, professions, food_production, material_production, happiness_production,
                         food_cost, material_cost, happiness_cost)
            if best is None or candidate[0] < best[0]:
                best = candidate
        assert best is not None
        return best[1:]

    def apply_random_event(self) -> None:
        if self.rng.random() > 0.525:
            return
        # O catálogo real costuma afetar um recurso por escolha, às vezes dois.
        # O modelo evita aplicar perdas simultâneas em alimentação, material e
        # felicidade, algo mais severo que os acontecimentos do jogo.
        quality = {"planned": 0.82, "casual": 0.60, "neglectful": 0.35}[self.policy]
        favorable = self.rng.random() < quality
        direction = 1.0 if favorable else -1.0
        resources = ["food", "material", "happiness"]
        selected = [self.rng.choice(resources)]
        if self.rng.random() < 0.30:
            remaining = [resource for resource in resources if resource not in selected]
            selected.append(self.rng.choice(remaining))
        for resource in selected:
            if resource == "food":
                self.food = max(0.0, self.food + direction * self.rng.uniform(1.0, 7.0))
            elif resource == "material":
                self.material = max(0.0, self.material + direction * self.rng.uniform(0.5, 4.0))
            else:
                self.happiness = max(0.0, min(100.0, self.happiness + direction * self.rng.uniform(0.5, 3.0)))

    def run_day(self, day: int) -> None:
        self.manage_buildings(day)
        professions, food_production, material_production, happiness_production, food_cost, material_cost, happiness_cost = self.choose_professions(day)
        available_food = self.food + food_production
        available_material = self.material + material_production
        food_shortage = max(0.0, food_cost - available_food)
        material_shortage = max(0.0, material_cost - available_material)
        self.food = max(0.0, available_food - food_cost)
        self.material = max(0.0, available_material - material_cost)
        self.happiness = max(0.0, min(
            100.0,
            self.happiness + happiness_production - happiness_cost
            - food_shortage * 1.5 - material_shortage * 0.5,
        ))
        self.apply_random_event()
        self.lowest_happiness = min(self.lowest_happiness, self.happiness)

        # Crescimento usa as necessidades do dia seguinte.
        next_day = min(120, day + 1)
        _, _, next_food_mult, next_maintenance_mult, _ = season_for_day(next_day)
        next_food_need = self.population * 2.10 * next_food_mult * self.rules["food_consumption"]
        next_material_need = (
            self.population * 0.27 * (1.0 - self.level_value("wall"))
            * next_maintenance_mult * self.rules["maintenance"]
        )
        concerning = (
            self.happiness < 40.0 or self.food + 1e-6 < next_food_need
            or self.material + 1e-6 < next_material_need
            or self.population > self.capacity or food_shortage > 1e-6
            or material_shortage > 1e-6
        )
        favorable = (
            not concerning and self.population < self.capacity
            and self.happiness >= 60.0
        )
        if concerning:
            self.concerning_streak += 1
            if self.concerning_streak >= self.rules["abandonment"] and self.population > 5:
                self.population -= 1
                self.concerning_streak = 0
                self.attraction_progress = 0
        else:
            self.concerning_streak = 0
            if favorable:
                self.attraction_progress += 1
                if self.attraction_progress >= self.rules["attraction"]:
                    self.population += 1
                    self.attraction_progress = 0

        # Os cinco capítulos anteriores ao final recrutam um residente protegido.
        if day in (20, 40, 60, 80, 100):
            self.population += 1

        if day == 91:
            self.winter_start_food = self.food

        if day in CHECKPOINTS:
            target = adjusted_target(day, self.rules)
            passed = (
                self.food + 1e-6 >= target[0]
                and self.material + 1e-6 >= target[1]
                and self.happiness + 1e-6 >= target[2]
                and self.population >= target[3]
            )
            self.checkpoint_results.append({
                "day": day, "passed": passed, "food": self.food,
                "material": self.material, "happiness": self.happiness,
                "population": self.population, "target": target,
            })
            if not passed and self.failed_day == 0:
                self.failed_day = day

    def run(self) -> "CampaignSimulation":
        for day in range(1, 121):
            self.run_day(day)
        return self


def run_suite(runs_per_case: int = 200) -> str:
    lines = [
        "SQUARE VILLAGE — SIMULAÇÃO ECONÔMICA DE 120 DIAS — v2.10.1",
        "",
        "Modelo: fórmulas centrais da campanha, atributos médios 6, quatro representantes,",
        "cinco recrutamentos narrativos e acontecimentos aleatórios aproximados.",
        "As políticas automatizadas podem trocar profissões diariamente e não substituem o teste no Godot.",
        "",
    ]
    all_success_rates = {}
    for difficulty_id, rules in DIFFICULTIES.items():
        lines.append(f"DIFICULDADE: {rules['name'].upper()}")
        for policy, label in (
            ("planned", "Planejamento atento"),
            ("casual", "Gestão casual"),
            ("neglectful", "Gestão negligente"),
        ):
            simulations = [CampaignSimulation(difficulty_id, policy, seed).run() for seed in range(runs_per_case)]
            victories = [simulation for simulation in simulations if simulation.failed_day == 0]
            rate = 100.0 * len(victories) / runs_per_case
            all_success_rates[(difficulty_id, policy)] = rate
            failure_days = [simulation.failed_day for simulation in simulations if simulation.failed_day]
            typical_failure = int(statistics.median(failure_days)) if failure_days else 0
            final_pops = [simulation.population for simulation in simulations]
            final_food = [simulation.food for simulation in simulations]
            winter_food = [simulation.winter_start_food for simulation in simulations]
            lines.append(
                f"  {label}: {rate:5.1f}% de vitórias | "
                f"população final mediana {statistics.median(final_pops):.0f} | "
                f"comida no início do inverno {statistics.median(winter_food):.1f} | "
                f"comida final {statistics.median(final_food):.1f}"
                + (f" | falha típica no dia {typical_failure}" if typical_failure else "")
            )
        lines.append("")

    lines.append("MATRIZ DAS 24 METAS")
    for difficulty_id, rules in DIFFICULTIES.items():
        lines.append(f"  {rules['name']}:")
        for day in CHECKPOINTS:
            food, material, happiness, population = adjusted_target(day, rules)
            lines.append(
                f"    Dia {day:3d}: alimentação {food:3.0f} | material {material:3.0f} | "
                f"felicidade {happiness:2.0f} | população {population:2d}"
            )

    lines.extend([
        "",
        "CRITÉRIOS DE LEITURA",
        "- Acolhedora deve aceitar gestão casual e oferecer ampla margem à política planejada.",
        "- Moderada deve recompensar planejamento e punir negligência.",
        "- Difícil pode exigir várias tentativas, mas deve permanecer matematicamente alcançável.",
        "- Outono acumula reservas; inverno consome parte relevante delas.",
        "",
        "Taxas observadas:",
        *[
            f"- {DIFFICULTIES[difficulty_id]['name']} / {policy}: {rate:.1f}%"
            for (difficulty_id, policy), rate in all_success_rates.items()
        ],
    ])
    return "\n".join(lines) + "\n"


def main() -> int:
    report = run_suite()
    REPORT_PATH.write_text(report, encoding="utf-8")
    print(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
