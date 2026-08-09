#!/usr/bin/env python3
from __future__ import annotations

import math
import random
from collections import Counter
from dataclasses import dataclass, field

MAX_LEVEL = 6
MAX_ATTRIBUTE = 8
RESOURCES = ("food", "material", "happiness")


def xp_required(level: int) -> int:
    return 80 + 20 * max(0, level - 1)


@dataclass
class Card:
    level: int = 1
    xp: int = 0
    lifetime_xp: int = 0
    unspent: int = 0
    spent: int = 0
    attributes: dict[str, int] = field(default_factory=lambda: {
        "strength": 1,
        "intelligence": 1,
        "charisma": 1,
        "agility": 1,
    })
    production: dict[str, float] = field(default_factory=lambda: {key: 0.0 for key in RESOURCES})
    milestones: dict[str, list[int]] = field(default_factory=lambda: {key: [] for key in RESOURCES})

    def grant_xp(self, amount: int) -> int:
        if amount <= 0:
            return 0
        previous = self.level
        self.lifetime_xp += amount
        if self.level < MAX_LEVEL:
            self.xp += amount
        while self.level < MAX_LEVEL and self.xp >= xp_required(self.level):
            self.xp -= xp_required(self.level)
            self.level += 1
            self.unspent += 1
        if self.level >= MAX_LEVEL:
            self.xp = 0
        return self.level - previous

    def spend(self, attribute: str) -> bool:
        if self.unspent <= 0 or attribute not in self.attributes:
            return False
        if self.attributes[attribute] >= MAX_ATTRIBUTE:
            return False
        self.attributes[attribute] += 1
        self.unspent -= 1
        self.spent += 1
        return True

    def add_production(self, values: dict[str, float]) -> list[tuple[str, int]]:
        reached: list[tuple[str, int]] = []
        for resource in RESOURCES:
            previous = self.production[resource]
            current = max(0.0, previous + max(0.0, values.get(resource, 0.0)))
            self.production[resource] = current
            previous_step = math.floor(previous / 100.0)
            current_step = math.floor(current / 100.0)
            for step in range(previous_step + 1, current_step + 1):
                milestone = step * 100
                self.milestones[resource].append(milestone)
                reached.append((resource, milestone))
        return reached

    def dominant_resource(self) -> str:
        best = "food"
        best_value = -1.0
        for resource in RESOURCES:
            if self.production[resource] > best_value:
                best = resource
                best_value = self.production[resource]
        return best


def recruited_level(active_levels: list[int]) -> int:
    average = sum(active_levels) / len(active_levels)
    return max(1, math.floor(average) - 1)


def reward_for_dialogue(card: Card, quality: str, village: dict[str, float]) -> tuple[bool, str]:
    resource = card.dominant_resource()
    if quality != "best":
        return False, resource
    village[resource] += 1.0
    if resource == "happiness":
        village[resource] = min(100.0, village[resource])
    return True, resource


def assert_scenarios() -> None:
    card = Card(attributes={key: 3 for key in ("strength", "intelligence", "charisma", "agility")})
    for _ in range(40):
        card.grant_xp(2)
    assert (card.level, card.xp, card.lifetime_xp, card.unspent) == (2, 0, 80, 1)
    for _ in range(50):
        card.grant_xp(2)
    assert (card.level, card.xp, card.lifetime_xp, card.unspent) == (3, 0, 180, 2)
    card.grant_xp(420)
    assert card.level == 6 and card.xp == 0 and card.lifetime_xp == 600 and card.unspent == 5
    card.grant_xp(123)
    assert card.level == 6 and card.xp == 0 and card.lifetime_xp == 723

    for attribute in ("strength", "intelligence", "charisma", "agility", "strength"):
        assert card.spend(attribute)
    assert card.unspent == 0 and card.spent == 5
    assert max(card.attributes.values()) <= MAX_ATTRIBUTE
    assert not card.spend("strength")

    milestone_card = Card()
    reached = milestone_card.add_production({"food": 250.0, "material": 99.0, "happiness": 305.0})
    assert reached == [
        ("food", 100), ("food", 200),
        ("happiness", 100), ("happiness", 200), ("happiness", 300),
    ]
    reached = milestone_card.add_production({"material": 2.0})
    assert reached == [("material", 100)]
    assert milestone_card.milestones["food"] == [100, 200]
    assert milestone_card.milestones["material"] == [100]
    assert milestone_card.milestones["happiness"] == [100, 200, 300]

    assert recruited_level([1, 1, 1, 1]) == 1
    assert recruited_level([2, 3, 3, 4]) == 2
    assert recruited_level([6, 6, 6, 6]) == 5

    reward_card = Card()
    reward_card.production = {"food": 20.0, "material": 45.0, "happiness": 10.0}
    village = {"food": 10.0, "material": 10.0, "happiness": 99.5}
    rewarded, resource = reward_for_dialogue(reward_card, "neutral", village)
    assert not rewarded and resource == "material" and village["material"] == 10.0
    rewarded, resource = reward_for_dialogue(reward_card, "best", village)
    assert rewarded and resource == "material" and village["material"] == 11.0


def randomized_simulation(seed: int = 330, careers: int = 25000) -> dict[str, object]:
    rng = random.Random(seed)
    failures: list[str] = []
    level_distribution: Counter[int] = Counter()
    milestone_distribution: Counter[str] = Counter()
    total_dialogues = 0
    total_rewards = 0
    total_cards = 0

    for career_index in range(careers):
        attrs = {key: 1 for key in ("strength", "intelligence", "charisma", "agility")}
        for _ in range(6):
            available = [key for key, value in attrs.items() if value < 5]
            attrs[rng.choice(available)] += 1
        card = Card(attributes=attrs)
        level_dialogues = 0

        for _day in range(1, 121):
            active = rng.random() < 0.78
            if active:
                level_dialogues += card.grant_xp(2)
                resource = rng.choice(RESOURCES)
                output = {key: 0.0 for key in RESOURCES}
                output[resource] = rng.uniform(0.4, 6.5)
                reached = card.add_production(output)
                for reached_resource, _value in reached:
                    milestone_distribution[reached_resource] += 1
                    level_dialogues += card.grant_xp(10)
            if rng.random() < 0.035:
                level_dialogues += card.grant_xp(20)

            while card.unspent > 0:
                available = [key for key, value in card.attributes.items() if value < MAX_ATTRIBUTE]
                if not available:
                    break
                if not card.spend(rng.choice(available)):
                    failures.append(f"career {career_index}: failed spend")
                    break

        total_cards += 1
        total_dialogues += level_dialogues
        for _ in range(level_dialogues):
            quality = rng.choice(("best", "neutral", "poor"))
            village = {key: 50.0 for key in RESOURCES}
            rewarded, resource = reward_for_dialogue(card, quality, village)
            if rewarded:
                total_rewards += 1
                expected = 51.0 if resource != "happiness" else 51.0
                if village[resource] != expected:
                    failures.append(f"career {career_index}: bad reward")
            elif any(value != 50.0 for value in village.values()):
                failures.append(f"career {career_index}: reward on wrong quality")

        if not 1 <= card.level <= MAX_LEVEL:
            failures.append(f"career {career_index}: level {card.level}")
        if card.level == MAX_LEVEL and card.xp != 0:
            failures.append(f"career {career_index}: max xp {card.xp}")
        if card.lifetime_xp < card.xp:
            failures.append(f"career {career_index}: lifetime xp")
        if any(not 1 <= value <= MAX_ATTRIBUTE for value in card.attributes.values()):
            failures.append(f"career {career_index}: attributes {card.attributes}")
        if card.spent + card.unspent != card.level - 1:
            failures.append(
                f"career {career_index}: points {card.spent}+{card.unspent}!={card.level - 1}"
            )
        for resource in RESOURCES:
            expected_count = math.floor(card.production[resource] / 100.0)
            if len(card.milestones[resource]) != expected_count:
                failures.append(f"career {career_index}: milestone {resource}")
        level_distribution[card.level] += 1

    return {
        "careers": careers,
        "cards": total_cards,
        "failures": failures,
        "level_distribution": dict(sorted(level_distribution.items())),
        "milestone_distribution": dict(sorted(milestone_distribution.items())),
        "level_dialogues": total_dialogues,
        "correct_rewards": total_rewards,
    }


def main() -> int:
    assert_scenarios()
    result = randomized_simulation()
    failures: list[str] = result["failures"]  # type: ignore[assignment]
    print("SIMULAÇÃO — EXPERIÊNCIA E HISTÓRICO — ETAPA 4")
    print("Cenários determinísticos: APROVADOS")
    print(f"Carreiras simuladas: {result['careers']}")
    print(f"Cartas simuladas: {result['cards']}")
    print(f"Diálogos de nível gerados: {result['level_dialogues']}")
    print(f"Respostas corretas recompensadas: {result['correct_rewards']}")
    print(f"Distribuição final de níveis: {result['level_distribution']}")
    print(f"Marcos por recurso: {result['milestone_distribution']}")
    print(f"Falhas de invariantes: {len(failures)}")
    if failures:
        for failure in failures[:25]:
            print(f"- {failure}")
        return 1
    print("Resultado: APROVADO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
