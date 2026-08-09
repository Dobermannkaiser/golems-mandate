#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass, asdict

MAX_LEVEL = 6


def xp_required(level: int) -> int:
    return 80 + 20 * max(0, level - 1)


@dataclass
class CardProgress:
    level: int = 1
    xp: int = 0
    unspent_attribute_points: int = 0
    lifetime_xp: int = 0

    def grant(self, amount: int) -> int:
        if amount <= 0:
            return 0
        self.xp += amount
        self.lifetime_xp += amount
        gained = 0
        while self.level < MAX_LEVEL and self.xp >= xp_required(self.level):
            self.xp -= xp_required(self.level)
            self.level += 1
            self.unspent_attribute_points += 1
            gained += 1
        if self.level >= MAX_LEVEL:
            self.xp = min(self.xp, xp_required(self.level) - 1)
        return gained


def check(condition: bool, message: str, failures: list[str]) -> None:
    if not condition:
        failures.append(message)


def main() -> int:
    failures: list[str] = []

    daily = CardProgress()
    daily.grant(2)
    check(daily.xp == 2 and daily.level == 1, f"XP diário: {daily}", failures)

    event = CardProgress()
    event.grant(20)
    check(event.xp == 20 and event.level == 1, f"XP de evento: {event}", failures)

    combined = CardProgress()
    for _ in range(30):
        combined.grant(2)
    combined.grant(20)
    check(
        combined.level == 2
        and combined.xp == 0
        and combined.unspent_attribute_points == 1
        and combined.lifetime_xp == 80,
        f"Progressão combinada: {combined}",
        failures,
    )

    carry = CardProgress(xp=79, lifetime_xp=79)
    carry.grant(20)
    check(
        carry.level == 2 and carry.xp == 19 and carry.unspent_attribute_points == 1,
        f"Resto de XP: {carry}",
        failures,
    )

    long_run = CardProgress()
    for _ in range(500):
        long_run.grant(2)
    check(long_run.level == MAX_LEVEL, f"Limite de nível: {long_run}", failures)
    check(
        0 <= long_run.xp < xp_required(MAX_LEVEL),
        f"XP no nível máximo: {long_run}",
        failures,
    )

    saved = asdict(carry)
    loaded = CardProgress(**saved)
    check(loaded == carry, f"Roundtrip do save: {loaded} != {carry}", failures)

    print("SIMULAÇÃO — XP DAS CARTAS — v3.2.3")
    print("Fontes modeladas: +2 por dia ativo; +20 por acontecimento resolvido.")
    print(f"Casos verificados: 6")
    print(f"Falhas: {len(failures)}")
    if failures:
        for failure in failures:
            print(f"- {failure}")
        return 1
    print("Resultado: APROVADO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
