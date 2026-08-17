class_name VillageBuildingManager
extends RefCounted


const BUILDING_CATALOG_SCRIPT = preload(
	"res://scripts/buildings/BuildingCatalog.gd"
)
const BUILDING_VARIANT_CATALOG_SCRIPT = preload(
	"res://scripts/buildings/BuildingVariantCatalog.gd"
)

const QUEUE_STATE_VERSION: int = 2
const HOUSING_ID: String = "housing"
const INITIAL_HOUSE_COUNT: int = 2
const HOUSING_CAPACITY_PER_HOUSE: int = 5
const FIRST_HOUSE_COST: float = 8.0
const HOUSE_COST_STEP: float = 4.0
const MAX_SAFE_HOUSE_COUNT: int = 20000
const CONSTRUCTION_POPULATION_STEP: int = 20
const MAX_CONSTRUCTION_SITES: int = 4
const MAX_QUEUE_LENGTH: int = 256
const ACTIVE_REFUND_RATE: float = 0.50

const STATUS_QUEUED: String = "queued"
const STATUS_ACTIVE: String = "active"
const STATUS_COMPLETED_PENDING: String = "completed_pending"


var building_catalog: Array[Dictionary] = []
var building_levels: Dictionary = {}
var selected_build_variants: Dictionary = {}
var variant_completion_days: Dictionary = {}
var variant_event_uses: Dictionary = {}
var buildings_by_id: Dictionary = {}
var effect_values_by_key: Dictionary = {}
var construction_orders: Array[Dictionary] = []
var house_count: int = INITIAL_HOUSE_COUNT
var cost_multiplier: float = 1.0
var next_order_sequence: int = 1
var active_effects_text: String = (
	"Nenhum benefício de construção está ativo."
)


func setup() -> void:
	building_catalog = BUILDING_CATALOG_SCRIPT.create()
	building_levels.clear()
	selected_build_variants.clear()
	variant_completion_days.clear()
	variant_event_uses.clear()
	buildings_by_id.clear()
	effect_values_by_key.clear()
	construction_orders.clear()
	house_count = INITIAL_HOUSE_COUNT
	cost_multiplier = 1.0
	next_order_sequence = 1

	for building: Dictionary in building_catalog:
		var building_id: String = String(building.get("id", ""))
		if not building_id.is_empty():
			building_levels[building_id] = 0
			selected_build_variants[building_id] = ""
			variant_completion_days[building_id] = 0
			variant_event_uses[building_id] = []
			buildings_by_id[building_id] = building

	_rebuild_derived_cache()


func configure_difficulty(new_cost_multiplier: float) -> void:
	cost_multiplier = clampf(new_cost_multiplier, 0.5, 2.0)


func get_cost_multiplier() -> float:
	return cost_multiplier


func get_effect_value(effect_key: String) -> float:
	return float(effect_values_by_key.get(effect_key, 0.0))


func get_effects_for_state(
	building_id: String,
	level: int,
	variant_id: String = ""
) -> Dictionary:
	if level <= 0:
		return {}
	var building: Dictionary = _find_building(building_id)
	if building.is_empty():
		return {}
	if level == BUILDING_VARIANT_CATALOG_SCRIPT.FINAL_LEVEL:
		if not BUILDING_VARIANT_CATALOG_SCRIPT.is_valid_for_building(
			variant_id,
			building_id
		):
			return {}
		return BUILDING_VARIANT_CATALOG_SCRIPT.get_effects(variant_id)
	var levels: Array = building.get("levels", [])
	var level_index: int = level - 1
	if level_index < 0 or level_index >= levels.size():
		return {}
	var effect_key: String = String(building.get("effect_key", ""))
	if effect_key.is_empty():
		return {}
	var level_data: Dictionary = levels[level_index]
	return {effect_key: float(level_data.get("value", 0.0))}


func get_building_level(building_id: String) -> int:
	return int(building_levels.get(building_id, 0))


func get_building_variant(building_id: String) -> String:
	return String(selected_build_variants.get(building_id, ""))


func get_building_variants() -> Dictionary:
	return selected_build_variants.duplicate(true)


func get_variant_completion_day(building_id: String) -> int:
	return int(variant_completion_days.get(building_id, 0))


func get_variant_event_uses(building_id: String) -> Array[String]:
	var result: Array[String] = []
	var value: Variant = variant_event_uses.get(building_id, [])
	if value is Array:
		for item: Variant in value as Array:
			result.append(String(item))
	return result


func record_variant_event_use(variant_id: String, interaction_id: String) -> bool:
	var variant: Dictionary = BUILDING_VARIANT_CATALOG_SCRIPT.get_variant(variant_id)
	if variant.is_empty():
		return false
	var building_id: String = String(variant.get("building_id", ""))
	if get_building_variant(building_id) != variant_id:
		return false
	var uses: Array[String] = get_variant_event_uses(building_id)
	if not uses.has(interaction_id):
		uses.append(interaction_id)
	variant_event_uses[building_id] = uses
	return true


func get_housing_capacity() -> int:
	return house_count * HOUSING_CAPACITY_PER_HOUSE


func calculate_construction_site_capacity(population_value: int) -> int:
	return clampi(
		1 + floori(
			float(maxi(0, population_value))
			/ float(CONSTRUCTION_POPULATION_STEP)
		),
		1,
		MAX_CONSTRUCTION_SITES
	)


func get_active_order_count() -> int:
	var count: int = 0
	for order: Dictionary in construction_orders:
		if String(order.get("status", "")) == STATUS_ACTIVE:
			count += 1
	return count


func get_queued_order_count() -> int:
	var count: int = 0
	for order: Dictionary in construction_orders:
		if String(order.get("status", "")) == STATUS_QUEUED:
			count += 1
	return count


func export_save_data() -> Dictionary:
	return {
		"queue_state_version": QUEUE_STATE_VERSION,
		"building_levels": building_levels.duplicate(true),
		"selected_build_variants": selected_build_variants.duplicate(true),
		"variant_completion_days": variant_completion_days.duplicate(true),
		"variant_event_uses": variant_event_uses.duplicate(true),
		"house_count": house_count,
		"construction_orders": construction_orders.duplicate(true),
		"next_order_sequence": next_order_sequence
	}


func import_save_data(save_data: Dictionary) -> bool:
	var saved_levels_value: Variant = save_data.get("building_levels", null)
	var saved_variants_value: Variant = save_data.get(
		"selected_build_variants",
		null
	)
	var saved_completion_days_value: Variant = save_data.get(
		"variant_completion_days",
		null
	)
	var saved_event_uses_value: Variant = save_data.get(
		"variant_event_uses",
		null
	)
	var saved_house_count: int = int(save_data.get("house_count", 0))
	if (
		not saved_levels_value is Dictionary
		or not saved_variants_value is Dictionary
		or not saved_completion_days_value is Dictionary
		or not saved_event_uses_value is Dictionary
		or saved_house_count < INITIAL_HOUSE_COUNT
		or saved_house_count > MAX_SAFE_HOUSE_COUNT
	):
		return false

	var queue_version: int = int(
		save_data.get("queue_state_version", QUEUE_STATE_VERSION)
	)
	if queue_version != QUEUE_STATE_VERSION:
		return false

	var saved_orders_value: Variant = save_data.get(
		"construction_orders",
		[]
	)
	if not saved_orders_value is Array:
		return false
	var saved_orders: Array = saved_orders_value
	if saved_orders.size() > MAX_QUEUE_LENGTH:
		return false

	var saved_levels: Dictionary = saved_levels_value
	var saved_variants: Dictionary = saved_variants_value
	var saved_completion_days: Dictionary = saved_completion_days_value
	var saved_event_uses: Dictionary = saved_event_uses_value
	house_count = saved_house_count
	for building: Dictionary in building_catalog:
		var building_id: String = String(building.get("id", ""))
		if building_id.is_empty():
			continue
		var levels: Array = building.get("levels", [])
		building_levels[building_id] = clampi(
			int(saved_levels.get(building_id, 0)),
			0,
			levels.size()
		)
		var saved_variant_id: String = String(
			saved_variants.get(building_id, "")
		).strip_edges()
		if building_levels[building_id] >= BUILDING_VARIANT_CATALOG_SCRIPT.FINAL_LEVEL:
			if not BUILDING_VARIANT_CATALOG_SCRIPT.is_valid_for_building(
				saved_variant_id,
				building_id
			):
				return false
		else:
			saved_variant_id = ""
		selected_build_variants[building_id] = saved_variant_id
		variant_completion_days[building_id] = maxi(
			0,
			int(saved_completion_days.get(building_id, 0))
		)
		var uses_value: Variant = saved_event_uses.get(building_id, [])
		if not uses_value is Array:
			return false
		var sanitized_uses: Array[String] = []
		for use_value: Variant in uses_value as Array:
			var use_id: String = String(use_value).strip_edges()
			if not use_id.is_empty() and not sanitized_uses.has(use_id):
				sanitized_uses.append(use_id)
		variant_event_uses[building_id] = sanitized_uses

	construction_orders.clear()
	var seen_order_ids: Dictionary = {}
	for order_value: Variant in saved_orders:
		if not order_value is Dictionary:
			return false
		var sanitized: Dictionary = _sanitize_loaded_order(
			(order_value as Dictionary).duplicate(true)
		)
		if sanitized.is_empty():
			return false
		var order_id: String = String(sanitized.get("order_id", ""))
		if seen_order_ids.has(order_id):
			return false
		seen_order_ids[order_id] = true
		construction_orders.append(sanitized)

	next_order_sequence = maxi(
		1,
		int(save_data.get("next_order_sequence", 1))
	)
	_normalize_queue_positions()
	_rebuild_derived_cache()
	return true


func get_state(
	available_material: float,
	building_allowed: bool = true,
	blocked_reason: String = "",
	total_population: int = 0,
	current_day: int = 1,
	checkpoint_days: Array[int] = []
) -> Dictionary:
	var building_states: Array[Dictionary] = []
	var built_upgrades: int = 0
	var total_upgrades: int = 0
	var predictions: Dictionary = _build_order_predictions(
		current_day,
		total_population
	)
	var next_checkpoint_day: int = _get_next_checkpoint_day(
		current_day,
		checkpoint_days
	)

	for building: Dictionary in building_catalog:
		var state: Dictionary = _build_building_state(
			building,
			available_material,
			building_allowed,
			blocked_reason
		)
		building_states.append(state)
		built_upgrades += int(state.get("current_level", 0))
		total_upgrades += int(state.get("max_level", 0))

	var active_orders: Array[Dictionary] = []
	var queued_orders: Array[Dictionary] = []
	for order: Dictionary in construction_orders:
		var enriched: Dictionary = _build_order_state(
			order,
			predictions,
			next_checkpoint_day
		)
		match String(order.get("status", "")):
			STATUS_ACTIVE, STATUS_COMPLETED_PENDING:
				active_orders.append(enriched)
			STATUS_QUEUED:
				queued_orders.append(enriched)

	var site_capacity: int = calculate_construction_site_capacity(
		total_population
	)
	var active_count: int = get_active_order_count()
	var pending_completion_count: int = 0
	for order: Dictionary in construction_orders:
		if String(order.get("status", "")) == STATUS_COMPLETED_PENDING:
			pending_completion_count += 1

	return {
		"buildings": building_states,
		"housing": _build_housing_state(
			available_material,
			building_allowed,
			blocked_reason,
			total_population
		),
		"house_count": house_count,
		"planned_house_count": house_count + _count_pending_housing_orders(),
		"housing_capacity": get_housing_capacity(),
		"built_upgrades": built_upgrades,
		"total_upgrades": total_upgrades,
		"available_material": available_material,
		"building_allowed": building_allowed,
		"blocked_reason": blocked_reason,
		"active_effects_text": get_active_effects_text(),
		"construction": {
			"site_capacity": site_capacity,
			"active_count": active_count,
			"pending_completion_count": pending_completion_count,
			"queued_count": queued_orders.size(),
			"total_orders": construction_orders.size(),
			"active_orders": active_orders,
			"queued_orders": queued_orders,
			"next_checkpoint_day": next_checkpoint_day,
			"current_day": current_day,
			"capacity_formula": (
				"1 + parte inteira da população ÷ 20 (máximo 4)"
			),
			"capacity_warning": (
				"As obras ativas continuam, mas nenhuma nova começa "
				+ "enquanto os canteiros ativos excederem a capacidade."
				if active_count > site_capacity
				else ""
			)
		}
	}


func request_construction(
	building_id: String,
	available_material: float,
	requested_day: int,
	building_allowed: bool = true,
	blocked_reason: String = "",
	variant_id: String = ""
) -> Dictionary:
	if not building_allowed:
		return {"queued": false, "reason": blocked_reason}
	if requested_day < 1:
		return {"queued": false, "reason": "O dia da solicitação é inválido."}
	if construction_orders.size() >= MAX_QUEUE_LENGTH:
		return {
			"queued": false,
			"reason": "A fila de obras atingiu o limite seguro."
		}

	if building_id == HOUSING_ID:
		return _request_house(
			available_material,
			requested_day
		)

	var building: Dictionary = _find_building(building_id)
	if building.is_empty():
		return {"queued": false, "reason": "Essa construção não existe."}
	if _has_pending_order_for_building(building_id):
		return {
			"queued": false,
			"reason": (
				"Essa construção já possui uma melhoria na fila ou em andamento."
			)
		}

	var current_level: int = get_building_level(building_id)
	var levels: Array = building.get("levels", [])
	if current_level >= levels.size():
		return {
			"queued": false,
			"reason": "%s já alcançou o nível máximo." % String(
				building.get("name", "Esta construção")
			)
		}

	var target_level: int = current_level + 1
	var selected_variant_id: String = variant_id.strip_edges()
	if target_level == BUILDING_VARIANT_CATALOG_SCRIPT.FINAL_LEVEL:
		if not BUILDING_VARIANT_CATALOG_SCRIPT.is_valid_for_building(
			selected_variant_id,
			building_id
		):
			return {
				"queued": false,
				"reason": "Escolha uma das duas builds finais antes de planejar o nível 3."
			}
	else:
		selected_variant_id = ""
	var level_data: Dictionary = levels[current_level]
	var material_cost: float = _calculate_construction_cost(
		float(level_data.get("cost", 0.0))
	)
	if available_material + 0.001 < material_cost:
		return {
			"queued": false,
			"reason": "São necessários %.1f de material." % material_cost
		}

	var building_name: String = String(
		building.get("name", "Construção")
	)
	var order_effect_text: String = String(
		level_data.get("effect_text", "Novo benefício permanente.")
	)
	if not selected_variant_id.is_empty():
		var variant_data: Dictionary = (
			BUILDING_VARIANT_CATALOG_SCRIPT.get_variant(selected_variant_id)
		)
		order_effect_text = String(
			variant_data.get("effect_text", order_effect_text)
		)
	var order: Dictionary = _create_order(
		building_id,
		building_name,
		false,
		target_level,
		requested_day,
		target_level,
		material_cost,
		order_effect_text,
		selected_variant_id
	)
	construction_orders.append(order)
	_normalize_queue_positions()
	return {
		"queued": true,
		"building_id": building_id,
		"building_name": building_name,
		"target_level": target_level,
		"work_days": target_level,
		"cost": material_cost,
		"order_id": String(order.get("order_id", "")),
		"variant_id": selected_variant_id,
		"variant_name": String(
			BUILDING_VARIANT_CATALOG_SCRIPT.get_variant(
				selected_variant_id
			).get("name", "")
		),
		"message": (
			"%s — nível %d entrou na fila. Custo pago: %.1f de material. "
			+ "Trabalho: %d dia(s); benefício disponível no dia seguinte à conclusão."
		) % [
			building_name,
			target_level,
			material_cost,
			target_level
		]
	}


func cancel_construction(order_id: String) -> Dictionary:
	var order_index: int = _find_order_index(order_id)
	if order_index < 0:
		return {"cancelled": false, "reason": "Essa obra não existe mais."}
	var order: Dictionary = construction_orders[order_index]
	var status: String = String(order.get("status", ""))
	if status == STATUS_COMPLETED_PENDING:
		return {
			"cancelled": false,
			"reason": "Essa obra já concluiu o trabalho e aguarda liberação."
		}
	if status not in [STATUS_QUEUED, STATUS_ACTIVE]:
		return {"cancelled": false, "reason": "Essa obra não pode ser cancelada."}

	var paid_cost: float = float(order.get("paid_cost", 0.0))
	var refund_rate: float = 1.0 if status == STATUS_QUEUED else ACTIVE_REFUND_RATE
	var refund: float = _round_material_cost(paid_cost * refund_rate)
	construction_orders.remove_at(order_index)
	_normalize_queue_positions()
	return {
		"cancelled": true,
		"order_id": order_id,
		"building_id": String(order.get("building_id", "")),
		"building_name": String(order.get("building_name", "Obra")),
		"was_active": status == STATUS_ACTIVE,
		"refund": refund,
		"paid_cost": paid_cost,
		"message": (
			"%s foi cancelada. Reembolso: %.1f de material (%d%%)."
		) % [
			_build_order_target_label(order),
			refund,
			int(round(refund_rate * 100.0))
		]
	}


func reorder_construction(order_id: String, direction: int) -> Dictionary:
	if direction not in [-1, 1]:
		return {"reordered": false, "reason": "Direção de fila inválida."}
	var order_index: int = _find_order_index(order_id)
	if order_index < 0:
		return {"reordered": false, "reason": "Essa obra não existe mais."}
	var order: Dictionary = construction_orders[order_index]
	if String(order.get("status", "")) != STATUS_QUEUED:
		return {
			"reordered": false,
			"reason": "Somente obras que ainda não começaram podem ser reordenadas."
		}

	var queued_indices: Array[int] = []
	for index: int in range(construction_orders.size()):
		if String(construction_orders[index].get("status", "")) == STATUS_QUEUED:
			queued_indices.append(index)
	var queue_index: int = queued_indices.find(order_index)
	var target_queue_index: int = queue_index + direction
	if queue_index < 0 or target_queue_index < 0 or target_queue_index >= queued_indices.size():
		return {
			"reordered": false,
			"reason": "A obra já está no limite dessa direção."
		}

	var target_actual_index: int = queued_indices[target_queue_index]
	var temporary: Dictionary = construction_orders[target_actual_index]
	construction_orders[target_actual_index] = construction_orders[order_index]
	construction_orders[order_index] = temporary
	_normalize_queue_positions()
	return {
		"reordered": true,
		"order_id": order_id,
		"message": "%s foi movida na fila." % _build_order_target_label(order)
	}


func process_construction_work_day(completed_day: int) -> Dictionary:
	var worked_orders: Array[Dictionary] = []
	var completed_orders: Array[Dictionary] = []
	for index: int in range(construction_orders.size()):
		var order: Dictionary = construction_orders[index]
		if String(order.get("status", "")) != STATUS_ACTIVE:
			continue
		if int(order.get("started_day", 0)) > completed_day:
			continue

		var progress_days: int = mini(
			int(order.get("work_days", 1)),
			int(order.get("progress_days", 0)) + 1
		)
		order["progress_days"] = progress_days
		if progress_days >= int(order.get("work_days", 1)):
			order["status"] = STATUS_COMPLETED_PENDING
			order["completed_work_day"] = completed_day
			order["available_day"] = completed_day + 1
			completed_orders.append(order.duplicate(true))
		else:
			worked_orders.append(order.duplicate(true))
		construction_orders[index] = order

	return {
		"worked_orders": worked_orders,
		"completed_orders": completed_orders,
		"message": _build_work_day_message(worked_orders, completed_orders)
	}


func finalize_completed_constructions(completed_day: int) -> Dictionary:
	var applied_orders: Array[Dictionary] = []
	var failures: Array[String] = []
	for index: int in range(construction_orders.size() - 1, -1, -1):
		var order: Dictionary = construction_orders[index]
		if String(order.get("status", "")) != STATUS_COMPLETED_PENDING:
			continue
		if int(order.get("completed_work_day", 0)) > completed_day:
			continue

		var applied: bool = false
		if bool(order.get("is_housing", false)):
			if house_count < MAX_SAFE_HOUSE_COUNT:
				house_count += 1
				applied = true
		else:
			var building_id: String = String(order.get("building_id", ""))
			var target_level: int = int(order.get("target_level", 0))
			if (
				buildings_by_id.has(building_id)
				and target_level == get_building_level(building_id) + 1
			):
				var variant_id: String = String(
					order.get("variant_id", "")
				)
				if (
					target_level == BUILDING_VARIANT_CATALOG_SCRIPT.FINAL_LEVEL
					and not BUILDING_VARIANT_CATALOG_SCRIPT.is_valid_for_building(
						variant_id,
						building_id
					)
				):
					applied = false
				else:
					building_levels[building_id] = target_level
					if target_level == BUILDING_VARIANT_CATALOG_SCRIPT.FINAL_LEVEL:
						selected_build_variants[building_id] = variant_id
						variant_completion_days[building_id] = completed_day + 1
					applied = true

		if applied:
			applied_orders.append(order.duplicate(true))
			construction_orders.remove_at(index)
		else:
			failures.append(
				"Não foi possível aplicar %s." % _build_order_target_label(order)
			)

	if not applied_orders.is_empty():
		_rebuild_derived_cache()
	_normalize_queue_positions()
	return {
		"applied_orders": applied_orders,
		"failures": failures,
		"message": _build_completion_message(applied_orders, failures)
	}


func start_constructions_for_day(
	day_value: int,
	population_value: int
) -> Dictionary:
	var capacity: int = calculate_construction_site_capacity(population_value)
	var active_count: int = get_active_order_count()
	var started_orders: Array[Dictionary] = []
	if active_count >= capacity:
		return {
			"started_orders": started_orders,
			"capacity": capacity,
			"active_count": active_count,
			"message": (
				"Nenhuma nova obra começou: %d canteiro(s) ativo(s) para %d disponível(is)."
				% [active_count, capacity]
				if get_queued_order_count() > 0
				else ""
			)
		}

	for index: int in range(construction_orders.size()):
		if active_count >= capacity:
			break
		var order: Dictionary = construction_orders[index]
		if String(order.get("status", "")) != STATUS_QUEUED:
			continue
		if int(order.get("earliest_start_day", day_value + 1)) > day_value:
			# A fila é estritamente sequencial: uma obra posterior não
			# ultrapassa a primeira obra ainda inelegível.
			break
		order["status"] = STATUS_ACTIVE
		order["started_day"] = day_value
		construction_orders[index] = order
		started_orders.append(order.duplicate(true))
		active_count += 1

	_normalize_queue_positions()
	return {
		"started_orders": started_orders,
		"capacity": capacity,
		"active_count": active_count,
		"message": _build_started_message(started_orders)
	}


func get_active_effects_text() -> String:
	return active_effects_text


func get_next_house_cost() -> float:
	return _get_planned_house_cost(_count_pending_housing_orders())


func _request_house(
	available_material: float,
	requested_day: int
) -> Dictionary:
	var pending_houses: int = _count_pending_housing_orders()
	if house_count + pending_houses >= MAX_SAFE_HOUSE_COUNT:
		return {
			"queued": false,
			"reason": "A vila alcançou o limite seguro de casas planejadas."
		}
	var material_cost: float = _get_planned_house_cost(pending_houses)
	if available_material + 0.001 < material_cost:
		return {
			"queued": false,
			"reason": (
				"São necessários %.1f de material para planejar a próxima casa."
				% material_cost
			)
		}

	var order: Dictionary = _create_order(
		HOUSING_ID,
		"Casa",
		true,
		house_count + pending_houses + 1,
		requested_day,
		1,
		material_cost,
		"+%d vagas de moradia." % HOUSING_CAPACITY_PER_HOUSE
	)
	construction_orders.append(order)
	_normalize_queue_positions()
	return {
		"queued": true,
		"is_housing": true,
		"building_id": HOUSING_ID,
		"building_name": "Casa",
		"target_level": int(order.get("target_level", house_count + 1)),
		"work_days": 1,
		"cost": material_cost,
		"order_id": String(order.get("order_id", "")),
		"message": (
			"Uma casa entrou na fila. Custo pago: %.1f de material. "
			+ "Ela exige um dia completo de trabalho e libera cinco vagas no dia seguinte."
		) % material_cost
	}


func _create_order(
	building_id: String,
	building_name: String,
	is_housing: bool,
	target_level: int,
	requested_day: int,
	work_days: int,
	paid_cost: float,
	effect_text: String,
	variant_id: String = ""
) -> Dictionary:
	var order_id: String = "obra_%06d" % next_order_sequence
	next_order_sequence += 1
	return {
		"order_id": order_id,
		"building_id": building_id,
		"building_name": building_name,
		"is_housing": is_housing,
		"target_level": target_level,
		"requested_day": requested_day,
		"earliest_start_day": requested_day + 1,
		"work_days": clampi(work_days, 1, 3),
		"progress_days": 0,
		"paid_cost": _round_material_cost(paid_cost),
		"effect_text": effect_text,
		"variant_id": variant_id,
		"status": STATUS_QUEUED,
		"started_day": 0,
		"completed_work_day": 0,
		"available_day": 0,
		"queue_position": get_queued_order_count()
	}


func _build_housing_state(
	available_material: float,
	building_allowed: bool,
	blocked_reason: String,
	total_population: int
) -> Dictionary:
	var pending_houses: int = _count_pending_housing_orders()
	var next_cost: float = _get_planned_house_cost(pending_houses)
	var capacity: int = get_housing_capacity()
	var unavailable_reason: String = ""
	if not building_allowed:
		unavailable_reason = blocked_reason
	elif house_count + pending_houses >= MAX_SAFE_HOUSE_COUNT:
		unavailable_reason = "Limite seguro de casas planejadas alcançado."
	elif available_material + 0.001 < next_cost:
		unavailable_reason = "Faltam %.1f de material." % maxf(
			0.0,
			next_cost - available_material
		)

	return {
		"id": HOUSING_ID,
		"name": "Moradia",
		"short_name": "CASAS",
		"flavor": "Casas dão segurança e abrem espaço para novos moradores.",
		"color": "#B47D55",
		"house_count": house_count,
		"planned_house_count": house_count + pending_houses,
		"pending_house_count": pending_houses,
		"capacity_per_house": HOUSING_CAPACITY_PER_HOUSE,
		"housing_capacity": capacity,
		"total_population": total_population,
		"available_housing": maxi(0, capacity - total_population),
		"next_cost": next_cost,
		"work_days": 1,
		"can_upgrade": (
			building_allowed
			and house_count + pending_houses < MAX_SAFE_HOUSE_COUNT
			and available_material + 0.001 >= next_cost
		),
		"unavailable_reason": unavailable_reason
	}


func _build_building_state(
	building: Dictionary,
	available_material: float,
	building_allowed: bool,
	blocked_reason: String
) -> Dictionary:
	var building_id: String = String(building.get("id", ""))
	var current_level: int = get_building_level(building_id)
	var levels: Array = building.get("levels", [])
	var max_level: int = levels.size()
	var is_maximum: bool = current_level >= max_level
	var has_pending_order: bool = _has_pending_order_for_building(building_id)
	var current_variant_id: String = get_building_variant(building_id)
	var current_variant: Dictionary = (
		BUILDING_VARIANT_CATALOG_SCRIPT.get_variant(current_variant_id)
	)
	var current_title: String = "Terreno preparado"
	var current_effect_text: String = "Nenhum benefício ativo."
	if current_level > 0:
		if (
			current_level == BUILDING_VARIANT_CATALOG_SCRIPT.FINAL_LEVEL
			and not current_variant.is_empty()
		):
			current_title = String(current_variant.get("name", "Build final"))
			current_effect_text = String(
				current_variant.get("effect_text", "Benefício permanente ativo.")
			)
		else:
			var current_data: Dictionary = levels[current_level - 1]
			current_title = String(
				current_data.get("title", "Nível %d" % current_level)
			)
			current_effect_text = String(
				current_data.get("effect_text", "Benefício permanente ativo.")
			)

	var next_cost: float = 0.0
	var next_title: String = ""
	var next_effect_text: String = ""
	var next_work_days: int = 0
	var variant_options: Array[Dictionary] = []
	var requires_variant_choice: bool = false
	if not is_maximum:
		var next_data: Dictionary = levels[current_level]
		next_cost = _calculate_construction_cost(
			float(next_data.get("cost", 0.0))
		)
		next_work_days = current_level + 1
		requires_variant_choice = (
			next_work_days == BUILDING_VARIANT_CATALOG_SCRIPT.FINAL_LEVEL
		)
		if requires_variant_choice:
			next_title = "Escolha a build final"
			next_effect_text = (
				"Duas especializações irreversíveis estarão disponíveis."
			)
			for variant: Dictionary in (
				BUILDING_VARIANT_CATALOG_SCRIPT.get_variants_for_building(
					building_id
				)
			):
				variant["cost"] = next_cost
				variant["work_days"] = next_work_days
				variant_options.append(variant)
		else:
			next_title = String(next_data.get("title", "Próximo nível"))
			next_effect_text = String(
				next_data.get("effect_text", "Novo benefício permanente.")
			)

	var can_afford: bool = available_material + 0.001 >= next_cost
	var can_upgrade: bool = (
		not is_maximum
		and not has_pending_order
		and building_allowed
		and can_afford
	)
	var unavailable_reason: String = ""
	if is_maximum:
		unavailable_reason = "Build final concluída e irreversível."
	elif has_pending_order:
		unavailable_reason = "Uma melhoria desta construção já está planejada."
	elif not building_allowed:
		unavailable_reason = blocked_reason
	elif not can_afford:
		unavailable_reason = "Material insuficiente: %.1f necessário." % next_cost

	return {
		"id": building_id,
		"name": String(building.get("name", "Construção")),
		"short_name": String(building.get("short_name", "OBRA")),
		"flavor": String(
			building.get("flavor", "Uma melhoria permanente para a vila.")
		),
		"color": String(building.get("color", "#8A765F")),
		"current_level": current_level,
		"max_level": max_level,
		"is_maximum": is_maximum,
		"has_pending_order": has_pending_order,
		"current_title": current_title,
		"current_effect_text": current_effect_text,
		"current_variant_id": current_variant_id,
		"current_variant_name": String(current_variant.get("name", "")),
		"current_variant_visual_id": String(
			current_variant.get("visual_id", "")
		),
		"current_variant_preview_path": String(
			current_variant.get("preview_path", "")
		),
		"variant_completion_day": get_variant_completion_day(building_id),
		"variant_event_uses": get_variant_event_uses(building_id),
		"next_title": next_title,
		"next_effect_text": next_effect_text,
		"next_cost": next_cost,
		"next_work_days": next_work_days,
		"requires_variant_choice": requires_variant_choice,
		"variant_options": variant_options,
		"can_afford": can_afford,
		"can_upgrade": can_upgrade,
		"unavailable_reason": unavailable_reason
	}


func _build_order_state(
	order: Dictionary,
	predictions: Dictionary,
	next_checkpoint_day: int
) -> Dictionary:
	var state: Dictionary = order.duplicate(true)
	var order_id: String = String(order.get("order_id", ""))
	var prediction: Dictionary = predictions.get(order_id, {})
	var predicted_start_day: int = int(
		prediction.get("predicted_start_day", int(order.get("started_day", 0)))
	)
	var predicted_available_day: int = int(
		prediction.get("predicted_available_day", int(order.get("available_day", 0)))
	)
	var status: String = String(order.get("status", ""))
	var paid_cost: float = float(order.get("paid_cost", 0.0))
	state["target_label"] = _build_order_target_label(order)
	state["status_text"] = _get_status_text(status)
	state["predicted_start_day"] = predicted_start_day
	state["predicted_available_day"] = predicted_available_day
	state["remaining_work_days"] = maxi(
		0,
		int(order.get("work_days", 1)) - int(order.get("progress_days", 0))
	)
	state["refund_amount"] = _round_material_cost(
		paid_cost * (1.0 if status == STATUS_QUEUED else ACTIVE_REFUND_RATE)
	)
	state["refund_rate"] = 1.0 if status == STATUS_QUEUED else ACTIVE_REFUND_RATE
	state["can_reorder"] = status == STATUS_QUEUED
	state["can_cancel"] = status in [STATUS_QUEUED, STATUS_ACTIVE]
	state["audit_text"] = _build_audit_prediction_text(
		predicted_available_day,
		next_checkpoint_day
	)
	return state


func _build_order_predictions(
	current_day: int,
	population_value: int
) -> Dictionary:
	var predictions: Dictionary = {}
	var active_remaining: Array[Dictionary] = []
	var queued_orders: Array[Dictionary] = []
	for order: Dictionary in construction_orders:
		var status: String = String(order.get("status", ""))
		var order_id: String = String(order.get("order_id", ""))
		if status == STATUS_COMPLETED_PENDING:
			predictions[order_id] = {
				"predicted_start_day": int(order.get("started_day", 0)),
				"predicted_available_day": int(order.get("available_day", current_day))
			}
		elif status == STATUS_ACTIVE:
			var remaining: int = maxi(
				1,
				int(order.get("work_days", 1)) - int(order.get("progress_days", 0))
			)
			active_remaining.append({"order_id": order_id, "remaining": remaining})
			predictions[order_id] = {
				"predicted_start_day": int(order.get("started_day", current_day)),
				"predicted_available_day": current_day + remaining
			}
		elif status == STATUS_QUEUED:
			queued_orders.append(order.duplicate(true))

	var capacity: int = calculate_construction_site_capacity(population_value)
	var simulation_day: int = current_day
	var guard: int = 0
	while not queued_orders.is_empty() and guard < MAX_QUEUE_LENGTH * 4:
		guard += 1
		for index: int in range(active_remaining.size() - 1, -1, -1):
			var active: Dictionary = active_remaining[index]
			active["remaining"] = int(active.get("remaining", 1)) - 1
			if int(active.get("remaining", 0)) <= 0:
				active_remaining.remove_at(index)
			else:
				active_remaining[index] = active
		simulation_day += 1

		var queue_index: int = 0
		while queue_index < queued_orders.size() and active_remaining.size() < capacity:
			var queued: Dictionary = queued_orders[queue_index]
			if int(queued.get("earliest_start_day", simulation_day)) > simulation_day:
				# A previsão respeita a mesma ordem estrita usada pelo runtime.
				break
			var order_id: String = String(queued.get("order_id", ""))
			var work_days: int = int(queued.get("work_days", 1))
			predictions[order_id] = {
				"predicted_start_day": simulation_day,
				"predicted_available_day": simulation_day + work_days
			}
			active_remaining.append({"order_id": order_id, "remaining": work_days})
			queued_orders.remove_at(queue_index)

		if active_remaining.is_empty() and not queued_orders.is_empty():
			var earliest: int = simulation_day + 1
			for queued: Dictionary in queued_orders:
				earliest = mini(
					earliest,
					int(queued.get("earliest_start_day", earliest))
				)
			if earliest > simulation_day + 1:
				simulation_day = earliest - 1
	return predictions


func _build_audit_prediction_text(
	predicted_available_day: int,
	next_checkpoint_day: int
) -> String:
	if predicted_available_day <= 0:
		return "Conclusão ainda não calculada."
	if next_checkpoint_day <= 0:
		return "Disponível no início do dia %d." % predicted_available_day
	if predicted_available_day <= next_checkpoint_day:
		return (
			"Disponível no início do dia %d — a tempo da avaliação do dia %d."
			% [predicted_available_day, next_checkpoint_day]
		)
	return (
		"Disponível no início do dia %d — depois da avaliação do dia %d."
		% [predicted_available_day, next_checkpoint_day]
	)


func _get_next_checkpoint_day(
	current_day: int,
	checkpoint_days: Array[int]
) -> int:
	for day_value: int in checkpoint_days:
		if day_value >= current_day:
			return day_value
	return 0


func _get_planned_house_cost(pending_houses: int) -> float:
	var houses_built_or_planned: int = maxi(
		0,
		house_count + maxi(0, pending_houses) - INITIAL_HOUSE_COUNT
	)
	return _calculate_construction_cost(
		FIRST_HOUSE_COST
		+ float(houses_built_or_planned) * HOUSE_COST_STEP
	)


func _count_pending_housing_orders() -> int:
	var count: int = 0
	for order: Dictionary in construction_orders:
		if bool(order.get("is_housing", false)):
			count += 1
	return count


func _has_pending_order_for_building(building_id: String) -> bool:
	for order: Dictionary in construction_orders:
		if (
			not bool(order.get("is_housing", false))
			and String(order.get("building_id", "")) == building_id
		):
			return true
	return false


func _find_order_index(order_id: String) -> int:
	for index: int in range(construction_orders.size()):
		if String(construction_orders[index].get("order_id", "")) == order_id:
			return index
	return -1


func _normalize_queue_positions() -> void:
	var queue_position: int = 0
	for index: int in range(construction_orders.size()):
		var order: Dictionary = construction_orders[index]
		if String(order.get("status", "")) == STATUS_QUEUED:
			order["queue_position"] = queue_position
			queue_position += 1
		else:
			order["queue_position"] = -1
		construction_orders[index] = order


func _sanitize_loaded_order(order: Dictionary) -> Dictionary:
	var order_id: String = String(order.get("order_id", "")).strip_edges()
	var building_id: String = String(order.get("building_id", "")).strip_edges()
	var status: String = String(order.get("status", ""))
	if order_id.is_empty() or building_id.is_empty():
		return {}
	if status not in [STATUS_QUEUED, STATUS_ACTIVE, STATUS_COMPLETED_PENDING]:
		return {}
	var is_housing: bool = bool(order.get("is_housing", building_id == HOUSING_ID))
	if not is_housing and not buildings_by_id.has(building_id):
		return {}
	var work_days: int = int(order.get("work_days", 0))
	var progress_days: int = int(order.get("progress_days", 0))
	if work_days < 1 or work_days > 3 or progress_days < 0 or progress_days > work_days:
		return {}
	if float(order.get("paid_cost", -1.0)) < 0.0:
		return {}
	order["order_id"] = order_id
	order["building_id"] = building_id
	order["building_name"] = String(
		order.get("building_name", "Casa" if is_housing else building_id.capitalize())
	)
	order["is_housing"] = is_housing
	order["target_level"] = maxi(1, int(order.get("target_level", 1)))
	order["requested_day"] = maxi(1, int(order.get("requested_day", 1)))
	order["earliest_start_day"] = maxi(
		int(order.get("requested_day", 1)) + 1,
		int(order.get("earliest_start_day", 2))
	)
	order["work_days"] = work_days
	order["progress_days"] = progress_days
	order["paid_cost"] = _round_material_cost(float(order.get("paid_cost", 0.0)))
	order["effect_text"] = String(order.get("effect_text", ""))
	var variant_id: String = String(order.get("variant_id", "")).strip_edges()
	if (
		not is_housing
		and int(order.get("target_level", 1))
		== BUILDING_VARIANT_CATALOG_SCRIPT.FINAL_LEVEL
	):
		if not BUILDING_VARIANT_CATALOG_SCRIPT.is_valid_for_building(
			variant_id,
			building_id
		):
			return {}
	else:
		variant_id = ""
	order["variant_id"] = variant_id
	order["status"] = status
	order["started_day"] = maxi(0, int(order.get("started_day", 0)))
	order["completed_work_day"] = maxi(0, int(order.get("completed_work_day", 0)))
	order["available_day"] = maxi(0, int(order.get("available_day", 0)))
	return order


func _build_order_target_label(order: Dictionary) -> String:
	if bool(order.get("is_housing", false)):
		return "Casa"
	var variant_id: String = String(order.get("variant_id", ""))
	if not variant_id.is_empty():
		var variant: Dictionary = BUILDING_VARIANT_CATALOG_SCRIPT.get_variant(
			variant_id
		)
		return "%s — %s" % [
			String(order.get("building_name", "Construção")),
			String(variant.get("name", "build final"))
		]
	return "%s — nível %d" % [
		String(order.get("building_name", "Construção")),
		int(order.get("target_level", 1))
	]


func _get_status_text(status: String) -> String:
	match status:
		STATUS_ACTIVE:
			return "EM ANDAMENTO"
		STATUS_COMPLETED_PENDING:
			return "TRABALHO CONCLUÍDO"
		_:
			return "NA FILA"


func _build_work_day_message(
	worked_orders: Array[Dictionary],
	completed_orders: Array[Dictionary]
) -> String:
	var parts: Array[String] = []
	for order: Dictionary in worked_orders:
		parts.append(
			"%s %d/%d" % [
				_build_order_target_label(order),
				int(order.get("progress_days", 0)),
				int(order.get("work_days", 1))
			]
		)
	for order: Dictionary in completed_orders:
		parts.append(
			"%s concluiu o trabalho; disponível no início do dia %d" % [
				_build_order_target_label(order),
				int(order.get("available_day", 0))
			]
		)
	return "Obras: " + "; ".join(parts) + "." if not parts.is_empty() else ""


func _build_completion_message(
	applied_orders: Array[Dictionary],
	failures: Array[String]
) -> String:
	var parts: Array[String] = []
	for order: Dictionary in applied_orders:
		parts.append(
			"%s ficou disponível. %s" % [
				_build_order_target_label(order),
				String(order.get("effect_text", ""))
			]
		)
	for failure: String in failures:
		parts.append(failure)
	return " ".join(parts)


func _build_started_message(started_orders: Array[Dictionary]) -> String:
	if started_orders.is_empty():
		return ""
	var names: Array[String] = []
	for order: Dictionary in started_orders:
		names.append(_build_order_target_label(order))
	return "Novos canteiros iniciados: %s." % ", ".join(names)


func _calculate_construction_cost(base_cost: float) -> float:
	var reduction: float = clampf(
		get_effect_value("construction_cost_reduction"),
		0.0,
		0.50
	)
	return _round_material_cost(
		base_cost * cost_multiplier * (1.0 - reduction)
	)


func _round_material_cost(value: float) -> float:
	return roundf(maxf(0.0, value) * 10.0) / 10.0


func _rebuild_derived_cache() -> void:
	effect_values_by_key.clear()
	var active_effects: Array[String] = []
	for building: Dictionary in building_catalog:
		var building_id: String = String(building.get("id", ""))
		var current_level: int = get_building_level(building_id)
		if current_level <= 0:
			continue
		if current_level == BUILDING_VARIANT_CATALOG_SCRIPT.FINAL_LEVEL:
			var variant_id: String = get_building_variant(building_id)
			var variant: Dictionary = (
				BUILDING_VARIANT_CATALOG_SCRIPT.get_variant(variant_id)
			)
			if variant.is_empty():
				continue
			var effects: Dictionary = (
				BUILDING_VARIANT_CATALOG_SCRIPT.get_effects(variant_id)
			)
			for effect_key_value: Variant in effects.keys():
				var variant_effect_key: String = String(effect_key_value)
				effect_values_by_key[variant_effect_key] = (
					float(effect_values_by_key.get(variant_effect_key, 0.0))
					+ float(effects.get(variant_effect_key, 0.0))
				)
			active_effects.append(
				"%s — %s: %s" % [
					String(building.get("name", "Construção")),
					String(variant.get("name", "Build final")),
					String(variant.get("effect_text", "benefício ativo"))
				]
			)
			continue

		var levels: Array = building.get("levels", [])
		var level_index: int = current_level - 1
		if level_index < 0 or level_index >= levels.size():
			continue
		var level_data: Dictionary = levels[level_index]
		var building_effect_key: String = String(building.get("effect_key", ""))
		if not building_effect_key.is_empty():
			effect_values_by_key[building_effect_key] = (
				float(effect_values_by_key.get(building_effect_key, 0.0))
				+ float(level_data.get("value", 0.0))
			)
		active_effects.append(
			"%s: %s" % [
				String(building.get("name", "Construção")),
				String(level_data.get("effect_text", "benefício ativo"))
			]
		)
	active_effects_text = (
		"Nenhum benefício de construção está ativo."
		if active_effects.is_empty()
		else " ".join(active_effects)
	)


func _find_building(building_id: String) -> Dictionary:
	return buildings_by_id.get(building_id, {})
