#!/usr/bin/env python3
"""Simulação determinística e aleatória das regras de recrutamento da Etapa 7."""
from __future__ import annotations

import random
from dataclasses import dataclass, field

OFFER_DAYS = [20, 40, 60, 80, 100, 120]
REQUIREMENTS = {20: 50, 40: 120, 60: 220, 80: 340, 100: 480, 120: 620}
LEVELS = {20: 2, 40: 3, 60: 4, 80: 5, 100: 6, 120: 6}


@dataclass
class Source:
    npc_id: str
    species: str
    points: int


@dataclass
class RecruitmentModel:
    pending: list[int] = field(default_factory=list)
    completed: list[int] = field(default_factory=list)
    used_sources: set[str] = field(default_factory=set)

    def unlock(self, day: int) -> None:
        if day in OFFER_DAYS and day not in self.pending and day not in self.completed:
            self.pending.append(day)
            self.pending.sort()

    def prepare(self, sources: list[Source]):
        if not self.pending:
            return None
        slot = self.pending[0]
        rows = [s for s in sources if s.npc_id not in self.used_sources]
        rows.sort(key=lambda s: (-s.points, s.npc_id))
        eligible = [s for s in rows if s.points >= REQUIREMENTS[slot]]
        if not eligible:
            best = rows[0].points if rows else 0
            return {"state": "blocked", "slot": slot, "missing": max(0, REQUIREMENTS[slot] - best)}
        top = eligible[0].points
        tied = [s for s in eligible if s.points == top]
        options = {}
        for source in tied:
            options.setdefault(source.species, source)
        if len(options) > 1:
            return {"state": "species_choice", "slot": slot, "options": options}
        source = next(iter(options.values()))
        return self.activate(slot, source)

    def activate(self, slot: int, source: Source):
        self.used_sources.add(source.npc_id)
        return {
            "state": "candidate_choice",
            "slot": slot,
            "source": source.npc_id,
            "species": source.species,
            "level": LEVELS[slot],
            "candidate_count": 2,
        }

    def complete(self, offer: dict) -> None:
        slot = offer["slot"]
        self.pending.remove(slot)
        self.completed.append(slot)
        self.completed.sort()


def deterministic_tests(errors: list[str]) -> None:
    if [REQUIREMENTS[d] for d in OFFER_DAYS] != [50, 120, 220, 340, 480, 620]:
        errors.append("requisitos progressivos incorretos")
    if [LEVELS[d] for d in OFFER_DAYS] != [2, 3, 4, 5, 6, 6]:
        errors.append("níveis incorretos")

    model = RecruitmentModel()
    model.unlock(20)
    blocked = model.prepare([Source("a", "Elfo", 49)])
    if blocked != {"state": "blocked", "slot": 20, "missing": 1}:
        errors.append(f"bloqueio/pontos faltantes incorreto: {blocked}")
    model.unlock(40)
    ready = model.prepare([Source("a", "Elfo", 120), Source("b", "Kobold", 90)])
    if not ready or ready["slot"] != 20 or ready["level"] != 2:
        errors.append(f"vaga antiga não foi priorizada: {ready}")
    model.complete(ready)
    next_ready = model.prepare([Source("a", "Elfo", 120), Source("b", "Kobold", 120)])
    if not next_ready or next_ready["slot"] != 40 or next_ready["source"] != "b":
        errors.append(f"fonte repetida ou encadeamento incorreto: {next_ready}")

    tie_model = RecruitmentModel()
    tie_model.unlock(20)
    tie = tie_model.prepare([
        Source("elf", "Elfo", 80),
        Source("kob", "Kobold", 80),
        Source("ana", "Anã", 70),
    ])
    if not tie or tie["state"] != "species_choice" or set(tie["options"]) != {"Elfo", "Kobold"}:
        errors.append(f"desempate de espécie incorreto: {tie}")
    else:
        chosen = tie_model.activate(20, tie["options"]["Kobold"])
        if chosen["species"] != "Kobold" or chosen["candidate_count"] != 2:
            errors.append(f"ativação da espécie incorreta: {chosen}")



def relationship_pace_tests(errors: list[str]) -> dict:
    # Cenário focado: uma boa conversa por dia com cada personagem conhecido.
    # A seleção automática usa sempre o vínculo elegível mais forte ainda não usado.
    arrivals = {
        "Mimo": (1, 0, "Passos-Leves"),
        "Aelric": (15, 35, "Elfo"),
        "Kobi": (30, 35, "Kobold"),
        "Orion": (45, 0, "Draconato"),
        "Rubra": (60, 35, "Meio-demônia"),
        "Brunna": (75, 35, "Anã"),
    }
    sources = [
        Source(name.lower(), species, 0)
        for name, (_arrival, _initial, species) in arrivals.items()
    ]
    names_by_id = {name.lower(): name for name in arrivals}
    model = RecruitmentModel()
    observed = {}
    for day in OFFER_DAYS:
        for source in sources:
            name = names_by_id[source.npc_id]
            arrival, initial, _species = arrivals[name]
            conversation_days = max(0, day - arrival + 1)
            source.points = min(1000, initial + conversation_days * 18)
        model.unlock(day)
        offer = model.prepare(sources)
        if not offer or offer["state"] == "blocked":
            errors.append(f"ritmo focado não produziu oferta no dia {day}: {offer}")
            continue
        if offer["state"] == "species_choice":
            species = sorted(offer["options"])[0]
            offer = model.activate(offer["slot"], offer["options"][species])
        source = next(item for item in sources if item.npc_id == offer["source"])
        observed[day] = {
            "source": names_by_id[source.npc_id],
            "points": source.points,
            "required": REQUIREMENTS[day],
        }
        if source.points < REQUIREMENTS[day]:
            errors.append(
                f"ritmo de relacionamento inviável no dia {day}: "
                f"{names_by_id[source.npc_id]} {source.points}/{REQUIREMENTS[day]}"
            )
        model.complete(offer)
    return observed

def randomized_tests(errors: list[str], campaigns: int = 5000) -> dict:
    rng = random.Random(3600)
    delayed_slots = 0
    ties = 0
    post_final_completions = 0
    max_reserve = 1
    completed_total = 0
    for _campaign in range(campaigns):
        model = RecruitmentModel()
        sources = [
            Source(f"npc_{i}", species, 0)
            for i, species in enumerate([
                "Passos-Leves", "Elfo", "Kobold",
                "Draconato", "Meio-demônia", "Anã",
            ])
        ]
        reserve_count = 1  # Mimo
        for day in OFFER_DAYS:
            for source in sources:
                source.points = min(1000, source.points + rng.randint(25, 170))
            model.unlock(day)
            while model.pending:
                offer = model.prepare(sources)
                if not offer or offer["state"] == "blocked":
                    delayed_slots += 1
                    break
                if offer["state"] == "species_choice":
                    ties += 1
                    species = sorted(offer["options"])[0]
                    offer = model.activate(offer["slot"], offer["options"][species])
                if offer["candidate_count"] != 2:
                    errors.append("oferta aleatória sem duas candidatas")
                    return {}
                if offer["level"] != LEVELS[offer["slot"]]:
                    errors.append("nível aleatório não corresponde à vaga")
                    return {}
                model.complete(offer)
                reserve_count += 1
                max_reserve = max(max_reserve, reserve_count)
                completed_total += 1

        # Depois do Dia 120 não surgem novas vagas. As antigas, porém, ainda
        # devem poder ser concluídas quando os vínculos finalmente atingem o requisito.
        pending_before_final_recheck = len(model.pending)
        for source in sources:
            source.points = 1000
        while model.pending:
            offer = model.prepare(sources)
            if not offer or offer["state"] == "blocked":
                errors.append(f"vaga permaneceu perdida após a auditoria final: {offer}")
                return {}
            if offer["state"] == "species_choice":
                ties += 1
                species = sorted(offer["options"])[0]
                offer = model.activate(offer["slot"], offer["options"][species])
            model.complete(offer)
            reserve_count += 1
            max_reserve = max(max_reserve, reserve_count)
            completed_total += 1
            post_final_completions += 1
        if len(model.completed) != 6 or reserve_count != 7:
            errors.append("as seis vagas não foram preservadas até o modo livre")
            return {}
        if pending_before_final_recheck < 0:
            errors.append("contagem impossível de vagas pendentes")
            return {}
    return {
        "campaigns": campaigns,
        "offers_completed": completed_total,
        "delayed_checks": delayed_slots,
        "species_ties": ties,
        "post_final_completions": post_final_completions,
        "max_reserve": max_reserve,
    }


def main() -> int:
    errors: list[str] = []
    deterministic_tests(errors)
    pace = relationship_pace_tests(errors)
    stats = randomized_tests(errors)
    print("Golem's Mandate — simulação do recrutamento da Etapa 7")
    print("Ritmo focado viável:")
    for day in OFFER_DAYS:
        row = pace[day]
        print(f"- Dia {day}: {row['source']} {row['points']}/{row['required']}")
    print(f"Campanhas aleatórias: {stats.get('campaigns', 0)}")
    print(f"Ofertas concluídas: {stats.get('offers_completed', 0)}")
    print(f"Verificações adiadas: {stats.get('delayed_checks', 0)}")
    print(f"Empates de espécie: {stats.get('species_ties', 0)}")
    print(f"Ofertas concluídas após o Dia 120: {stats.get('post_final_completions', 0)}")
    print(f"Maior reserva observada: {stats.get('max_reserve', 0)}")
    print(f"Erros: {len(errors)}")
    if errors:
        for error in errors:
            print(f"- {error}")
        return 1
    print("Resultado: APROVADO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
