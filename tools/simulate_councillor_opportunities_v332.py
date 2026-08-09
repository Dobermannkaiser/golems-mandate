#!/usr/bin/env python3
from __future__ import annotations

import random
import re
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG_PATH = ROOT / "scripts/council/CouncillorOpportunityCatalog.gd"

FIRST_OPPORTUNITY_DAY = 4
OPPORTUNITY_INTERVAL_DAYS = 4
INDIVIDUAL_COOLDOWN_DAYS = 10
CAMPAIGN_DAYS = 120
SIMULATIONS = 10_000


def extract_balanced(text: str, start: int, opener: str, closer: str) -> str:
    depth = 0
    quote: str | None = None
    escaped = False
    index = start
    while index < len(text):
        char = text[index]
        if quote is not None:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = None
            index += 1
            continue
        if char in {'"', "'"}:
            quote = char
            index += 1
            continue
        if char == "#":
            while index < len(text) and text[index] != "\n":
                index += 1
            continue
        if char == opener:
            depth += 1
        elif char == closer:
            depth -= 1
            if depth == 0:
                return text[start:index + 1]
        index += 1
    raise ValueError(f"Unclosed {opener} at {start}")


def split_top_level_dicts(array_block: str) -> list[str]:
    result: list[str] = []
    index = 1
    while index < len(array_block) - 1:
        if array_block[index] == "{":
            block = extract_balanced(array_block, index, "{", "}")
            result.append(block)
            index += len(block)
            continue
        if array_block[index] in {'"', "'"}:
            quote = array_block[index]
            index += 1
            while index < len(array_block):
                if array_block[index] == "\\":
                    index += 2
                    continue
                if array_block[index] == quote:
                    index += 1
                    break
                index += 1
            continue
        index += 1
    return result


def extract_key_container(block: str, key: str, opener: str, closer: str) -> str:
    match = re.search(rf'"{re.escape(key)}"\s*:\s*\{opener}', block)
    if not match:
        return ""
    start = block.find(opener, match.start())
    return extract_balanced(block, start, opener, closer)


@dataclass(frozen=True)
class Choice:
    choice_id: str
    duration: int
    has_immediate: bool
    has_modifiers: bool


@dataclass(frozen=True)
class Template:
    template_id: str
    profession: str
    choices: tuple[Choice, ...]


def parse_catalog() -> list[Template]:
    text = CATALOG_PATH.read_text(encoding="utf-8")
    const_pos = text.index("const OPPORTUNITIES")
    assignment_pos = text.index("=", const_pos)
    array_start = text.index("[", assignment_pos)
    array_block = extract_balanced(text, array_start, "[", "]")
    result: list[Template] = []
    for template_block in split_top_level_dicts(array_block):
        template_id = re.search(r'"id"\s*:\s*"([^"]+)"', template_block)
        profession = re.search(
            r'"profession"\s*:\s*Villager\.Profession\.([A-Z_]+)',
            template_block,
        )
        choices_block = extract_key_container(template_block, "choices", "[", "]")
        choices: list[Choice] = []
        for choice_block in split_top_level_dicts(choices_block):
            choice_id = re.search(r'"id"\s*:\s*"([^"]+)"', choice_block)
            duration = re.search(r'"duration_days"\s*:\s*(\d+)', choice_block)
            immediate = extract_key_container(choice_block, "immediate", "{", "}")
            modifiers = extract_key_container(choice_block, "modifiers", "{", "}")
            choices.append(
                Choice(
                    choice_id.group(1) if choice_id else "",
                    int(duration.group(1)) if duration else 0,
                    bool(immediate[1:-1].strip()) if immediate else False,
                    bool(modifiers[1:-1].strip()) if modifiers else False,
                )
            )
        result.append(
            Template(
                template_id.group(1) if template_id else "",
                profession.group(1) if profession else "INVALID",
                tuple(choices),
            )
        )
    return result


@dataclass
class Project:
    representative_id: str
    template_id: str
    start_day: int
    end_day: int


class OpportunitySimulation:
    def __init__(self, seed: int, templates: list[Template]) -> None:
        self.seed = seed
        self.templates_by_profession: dict[str, list[Template]] = defaultdict(list)
        for template in templates:
            self.templates_by_profession[template.profession].append(template)
        profession_profiles = [
            ["FARMER", "BLACKSMITH", "CIVIL_SERVANT", "GUARD"],
            ["GATHERER", "UNASSIGNED", "FARMER", "BLACKSMITH"],
        ]
        profile = profession_profiles[seed % len(profession_profiles)]
        self.representatives = [
            (f"representante_{index + 1:02d}", profession)
            for index, profession in enumerate(profile)
        ]
        self.next_day = FIRST_OPPORTUNITY_DAY
        self.sequence = 1
        self.last_day: dict[str, int] = {}
        self.last_template: dict[str, str] = {}
        self.used_templates: set[str] = set()
        self.projects: list[Project] = []
        self.opportunity_count = 0
        self.completed_count = 0
        self.representative_usage: Counter[str] = Counter()
        self.template_usage: Counter[str] = Counter()
        self.duration_usage: Counter[int] = Counter()
        self.errors: list[str] = []

    def run(self) -> None:
        active_project: Project | None = None
        for day in range(1, CAMPAIGN_DAYS + 1):
            if active_project is not None and day > active_project.end_day:
                self.completed_count += 1
                active_project = None
            if day < self.next_day or active_project is not None:
                continue

            def has_unused(row: tuple[str, str]) -> bool:
                return any(
                    template.template_id not in self.used_templates
                    for template in self.templates_by_profession[row[1]]
                )

            eligible = [
                row for row in self.representatives
                if has_unused(row)
                and day - self.last_day.get(row[0], -9999) >= INDIVIDUAL_COOLDOWN_DAYS
            ]
            if not eligible:
                eligible = [row for row in self.representatives if has_unused(row)]
            if not eligible:
                self.next_day = day + OPPORTUNITY_INTERVAL_DAYS
                continue
            eligible.sort(key=lambda row: row[0])
            rng = random.Random(max(1, self.seed + day * 3571 + self.sequence * 7919))
            selected = eligible[rng.randrange(min(2, len(eligible)))]
            representative_id, profession = selected
            templates = list(self.templates_by_profession[profession])
            previous = self.last_template.get(representative_id, "")
            available = [
                template for template in templates
                if template.template_id not in self.used_templates
                and (len(templates) == 1 or template.template_id != previous)
            ]
            if not available:
                available = [
                    template for template in templates
                    if template.template_id not in self.used_templates
                ]
            if not available:
                self.errors.append(f"day {day}: no template for {profession}")
                continue
            template = available[rng.randrange(len(available))]
            free_choices = [choice for choice in template.choices if not choice.has_immediate]
            choice_pool = free_choices or list(template.choices)
            choice = choice_pool[rng.randrange(len(choice_pool))]
            if not choice.has_modifiers:
                self.errors.append(f"day {day}: inert choice {template.template_id}/{choice.choice_id}")
            if choice.duration not in {2, 3}:
                self.errors.append(f"day {day}: duration {choice.duration}")
            project = Project(
                representative_id,
                template.template_id,
                day,
                day + choice.duration - 1,
            )
            if self.projects and project.start_day <= self.projects[-1].end_day:
                self.errors.append(f"day {day}: project overlap")
            if template.template_id in self.used_templates:
                self.errors.append(f"day {day}: globally repeated template")
            if self.last_template.get(representative_id) == template.template_id:
                self.errors.append(f"day {day}: immediate repeated template")
            self.projects.append(project)
            active_project = project
            self.used_templates.add(template.template_id)
            self.last_day[representative_id] = day
            self.last_template[representative_id] = template.template_id
            self.next_day = max(day + OPPORTUNITY_INTERVAL_DAYS, project.end_day + 1)
            self.sequence += 1
            self.opportunity_count += 1
            self.representative_usage[representative_id] += 1
            self.template_usage[template.template_id] += 1
            self.duration_usage[choice.duration] += 1

        if active_project is not None and active_project.end_day <= CAMPAIGN_DAYS:
            self.completed_count += 1
        if self.opportunity_count != len(self.used_templates):
            self.errors.append("opportunity count differs from unique template count")


def main() -> int:
    templates = parse_catalog()
    errors: list[str] = []
    if len(templates) != 12:
        errors.append(f"catalog templates={len(templates)}")
    if sum(len(template.choices) for template in templates) != 36:
        errors.append("catalog does not contain 36 choices")

    recruitment_expected = {20: 2, 40: 3, 60: 4, 80: 5, 100: 6, 120: 6}
    recruitment_actual = {
        day: max(1, min(6, 1 + day // 20)) for day in recruitment_expected
    }
    if recruitment_actual != recruitment_expected:
        errors.append(f"recruitment levels={recruitment_actual}")

    total_opportunities = 0
    total_completed = 0
    duration_usage: Counter[int] = Counter()
    representative_usage: Counter[str] = Counter()
    template_usage: Counter[str] = Counter()
    min_opportunities = 10**9
    max_opportunities = 0
    campaigns_with_all_representatives = 0

    for seed in range(1, SIMULATIONS + 1):
        simulation = OpportunitySimulation(seed, templates)
        simulation.run()
        if simulation.errors:
            errors.extend(f"seed {seed}: {error}" for error in simulation.errors[:5])
            if len(errors) >= 100:
                break
        total_opportunities += simulation.opportunity_count
        total_completed += simulation.completed_count
        duration_usage.update(simulation.duration_usage)
        representative_usage.update(simulation.representative_usage)
        template_usage.update(simulation.template_usage)
        min_opportunities = min(min_opportunities, simulation.opportunity_count)
        max_opportunities = max(max_opportunities, simulation.opportunity_count)
        if len(simulation.representative_usage) == 4:
            campaigns_with_all_representatives += 1

    print("SIMULAÇÃO — DIÁLOGOS COM CONSEQUÊNCIA — v3.3.2")
    print(f"Campanhas simuladas: {SIMULATIONS}")
    print(f"Dias por campanha: {CAMPAIGN_DAYS}")
    print(f"Oportunidades iniciadas: {total_opportunities}")
    print(f"Projetos concluídos: {total_completed}")
    print(f"Oportunidades únicas por campanha: mínimo {min_opportunities}, máximo {max_opportunities}")
    print(f"Durações: {dict(sorted(duration_usage.items()))}")
    print(f"Uso por representante: {dict(sorted(representative_usage.items()))}")
    print(f"Uso por modelo narrativo: {dict(sorted(template_usage.items()))}")
    print(f"Campanhas envolvendo os quatro representantes: {campaigns_with_all_representatives}")
    print(f"Níveis das ofertas: {recruitment_actual}")
    print(f"Falhas: {len(errors)}")
    if errors:
        print("Primeiras falhas:")
        for error in errors[:30]:
            print(f"- {error}")
        return 1
    print("Resultado: APROVADO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
