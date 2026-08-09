#!/usr/bin/env python3
"""Modelo independente de referência para a fila de obras da Parte 3 — Etapa 2.

Este script valida as regras temporais e invariantes aprovadas. Ele não executa
GDScript nem substitui um teste no Godot real.
"""
from __future__ import annotations

from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Literal

ROOT = Path(__file__).resolve().parents[1]
REPORT_PATH = ROOT / "SIMULACAO_FILA_DE_OBRAS_v3.1.0.txt"

Status = Literal["queued", "active", "completed_pending"]


@dataclass
class Order:
    order_id: str
    requested_day: int
    work_days: int
    paid_cost: float
    status: Status = "queued"
    progress_days: int = 0
    started_day: int = 0
    completed_work_day: int = 0
    available_day: int = 0


class QueueModel:
    def __init__(self) -> None:
        self.orders: list[Order] = []
        self.next_id = 1
        self.applied: list[str] = []

    @staticmethod
    def capacity(population: int) -> int:
        return max(1, min(4, 1 + max(0, population) // 20))

    def enqueue(self, requested_day: int, work_days: int, paid_cost: float) -> str:
        if requested_day < 1 or work_days not in (1, 2, 3) or paid_cost < 0:
            raise ValueError("invalid order")
        order_id = f"obra_{self.next_id:06d}"
        self.next_id += 1
        self.orders.append(Order(order_id, requested_day, work_days, paid_cost))
        return order_id

    def start_for_day(self, day: int, population: int) -> list[str]:
        capacity = self.capacity(population)
        active = sum(order.status == "active" for order in self.orders)
        started: list[str] = []
        if active >= capacity:
            return started
        for order in self.orders:
            if active >= capacity:
                break
            if order.status != "queued":
                continue
            if order.requested_day + 1 > day:
                break
            order.status = "active"
            order.started_day = day
            active += 1
            started.append(order.order_id)
        return started

    def work_day(self, completed_day: int) -> list[str]:
        completed: list[str] = []
        for order in self.orders:
            if order.status != "active" or order.started_day > completed_day:
                continue
            order.progress_days += 1
            if order.progress_days >= order.work_days:
                order.status = "completed_pending"
                order.completed_work_day = completed_day
                order.available_day = completed_day + 1
                completed.append(order.order_id)
        return completed

    def finalize_after_audit(self, completed_day: int) -> list[str]:
        finalized: list[str] = []
        remaining: list[Order] = []
        for order in self.orders:
            if order.status == "completed_pending" and order.completed_work_day <= completed_day:
                finalized.append(order.order_id)
                self.applied.append(order.order_id)
            else:
                remaining.append(order)
        self.orders = remaining
        return finalized

    def cancel(self, order_id: str) -> float:
        for index, order in enumerate(self.orders):
            if order.order_id != order_id:
                continue
            if order.status == "completed_pending":
                raise ValueError("completed work cannot be cancelled")
            rate = 1.0 if order.status == "queued" else 0.5
            self.orders.pop(index)
            return round(order.paid_cost * rate, 1)
        raise KeyError(order_id)

    def reorder(self, order_id: str, direction: int) -> bool:
        queued_indexes = [i for i, order in enumerate(self.orders) if order.status == "queued"]
        actual_index = next((i for i, order in enumerate(self.orders) if order.order_id == order_id), -1)
        if actual_index < 0 or self.orders[actual_index].status != "queued" or direction not in (-1, 1):
            return False
        queue_index = queued_indexes.index(actual_index)
        target_queue_index = queue_index + direction
        if not 0 <= target_queue_index < len(queued_indexes):
            return False
        target_actual = queued_indexes[target_queue_index]
        self.orders[actual_index], self.orders[target_actual] = self.orders[target_actual], self.orders[actual_index]
        return True

    def snapshot(self) -> list[dict[str, object]]:
        return [asdict(order) for order in self.orders]


def assert_equal(name: str, actual: object, expected: object, lines: list[str]) -> None:
    if actual != expected:
        raise AssertionError(f"{name}: expected {expected!r}, got {actual!r}")
    lines.append(f"[OK] {name}: {actual!r}")


def run_suite() -> str:
    lines = [
        "SIMULAÇÃO DE REFERÊNCIA — FILA DE OBRAS — v3.1.0",
        "",
        "Escopo: regras temporais, capacidade, ordem, cancelamento e auditoria.",
        "Limitação: este modelo não executa Godot nem GDScript.",
        "",
    ]

    # Tempos fundamentais.
    for work_days, expected_day in ((1, 12), (2, 13), (3, 14)):
        model = QueueModel()
        order_id = model.enqueue(10, work_days, 20.0)
        assert_equal(f"dia 10 / início", model.start_for_day(10, 8), [], lines)
        assert_equal(f"dia 11 / início ({work_days}d)", model.start_for_day(11, 8), [order_id], lines)
        for day in range(11, 11 + work_days):
            model.work_day(day)
        order = model.orders[0]
        assert_equal(f"disponibilidade ({work_days}d)", order.available_day, expected_day, lines)

    # Capacidade.
    capacities = {1: 1, 19: 1, 20: 2, 39: 2, 40: 3, 59: 3, 60: 4, 79: 4, 200: 4}
    for population, expected in capacities.items():
        assert_equal(f"capacidade população {population}", QueueModel.capacity(population), expected, lines)

    # Ordem e reordenação.
    model = QueueModel()
    ids = [model.enqueue(5, 1, 10.0), model.enqueue(5, 2, 20.0), model.enqueue(5, 3, 30.0)]
    assert_equal("reordenar terceira para cima", model.reorder(ids[2], -1), True, lines)
    assert_equal("ordem após reordenar", [o.order_id for o in model.orders], [ids[0], ids[2], ids[1]], lines)
    assert_equal("início respeita dois canteiros", model.start_for_day(6, 20), [ids[0], ids[2]], lines)
    assert_equal("obra ativa não reordena", model.reorder(ids[0], 1), False, lines)

    # Cancelamentos e ausência de substituição imediata.
    model = QueueModel()
    pending = model.enqueue(2, 1, 18.0)
    active = model.enqueue(2, 2, 18.0)
    assert_equal("reembolso pendente", model.cancel(pending), 18.0, lines)
    model.start_for_day(3, 1)
    assert_equal("reembolso ativo", model.cancel(active), 9.0, lines)
    assert_equal("nenhuma obra iniciou no próprio cancelamento", [o.status for o in model.orders], [], lines)

    # Queda populacional: ativas continuam; fila espera.
    model = QueueModel()
    ids = [model.enqueue(1, 3, 10.0) for _ in range(3)]
    assert_equal("três canteiros com população 40", model.start_for_day(2, 40), ids, lines)
    queued = model.enqueue(2, 1, 10.0)
    model.work_day(2)
    assert_equal("queda não cancela ativas", sum(o.status == "active" for o in model.orders), 3, lines)
    assert_equal("queda bloqueia nova obra", model.start_for_day(3, 1), [], lines)
    model.work_day(3)
    model.work_day(4)
    model.finalize_after_audit(4)
    assert_equal("fila recomeça após liberar capacidade", model.start_for_day(5, 1), [queued], lines)

    # Auditoria antes da liberação.
    model = QueueModel()
    audit_order = model.enqueue(19, 1, 12.0)
    model.start_for_day(20, 10)
    model.work_day(20)
    assert_equal("obra ainda pendente durante avaliação do dia 20", audit_order in [o.order_id for o in model.orders], True, lines)
    assert_equal("benefício ainda não aplicado na avaliação", model.applied, [], lines)
    assert_equal("liberação após avaliação", model.finalize_after_audit(20), [audit_order], lines)
    assert_equal("benefício disponível no dia 21", model.applied, [audit_order], lines)

    # Stress determinístico.
    model = QueueModel()
    for index in range(100):
        model.enqueue(1 + index // 5, 1 + index % 3, 5.0 + index)
    for day in range(1, 121):
        model.work_day(day)
        model.finalize_after_audit(day)
        model.start_for_day(day + 1, min(79, 8 + day // 2))
    assert_equal("stress sem duplicar conclusão", len(model.applied), len(set(model.applied)), lines)
    assert_equal("stress preserva no máximo 100 ordens", len(model.applied) + len(model.orders), 100, lines)

    lines.extend([
        "",
        "RESULTADO: todos os cenários do modelo de referência passaram.",
        "A validação no Godot real ainda é obrigatória para foco, cliques, desenho e save/runtime.",
    ])
    return "\n".join(lines) + "\n"


def main() -> int:
    report = run_suite()
    REPORT_PATH.write_text(report, encoding="utf-8")
    print(report, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
