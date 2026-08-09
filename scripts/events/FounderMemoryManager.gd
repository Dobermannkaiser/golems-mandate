class_name FounderMemoryManager
extends RefCounted


const CATALOG_SCRIPT = preload("res://scripts/events/FounderMemoryCatalog.gd")
const BUILDING_VARIANT_CATALOG_SCRIPT = preload(
	"res://scripts/buildings/BuildingVariantCatalog.gd"
)

const STATE_VERSION: int = 1
const CONSEQUENCE_WINDOW_DAYS: int = 10

const STATUS_WAITING_OPENING: String = "waiting_opening"
const STATUS_OPENING_ACTIVE: String = "opening_active"
const STATUS_WAITING_CONSEQUENCE: String = "waiting_consequence"
const STATUS_CONSEQUENCE_ACTIVE: String = "consequence_active"
const STATUS_COMPLETED: String = "completed"
const STATUS_EXPIRED: String = "expired"


var initialized: bool = false
var assignments: Dictionary = {}
var chain_states: Dictionary = {}
var visual_markers: Array[Dictionary] = []
var known_events: Dictionary = {}
var consequence_window_day_adjustment: int = 0


func setup() -> void:
	initialized = false
	assignments.clear()
	chain_states.clear()
	visual_markers.clear()
	known_events.clear()
	consequence_window_day_adjustment = 0


func configure_difficulty(window_day_adjustment: int) -> void:
	consequence_window_day_adjustment = clampi(window_day_adjustment, -3, 5)


func initialize_founders(founders: Array[Dictionary]) -> bool:
	if initialized:
		return true
	if founders.size() != CATALOG_SCRIPT.CHAIN_IDS.size():
		return false

	var founder_by_id: Dictionary = {}
	for founder: Dictionary in founders:
		var founder_id: String = String(founder.get("founder_id", "")).strip_edges()
		if founder_id.is_empty() or founder_by_id.has(founder_id):
			return false
		founder_by_id[founder_id] = founder.duplicate(true)

	var remaining_ids: Array[String] = []
	for founder_id_value: Variant in founder_by_id.keys():
		remaining_ids.append(String(founder_id_value))
	remaining_ids.sort()

	assignments.clear()
	chain_states.clear()
	for chain_id: String in CATALOG_SCRIPT.get_chain_ids():
		var selected_id: String = ""
		var selected_score: int = -1
		for founder_id: String in remaining_ids:
			var founder: Dictionary = founder_by_id[founder_id]
			var score: int = CATALOG_SCRIPT.score_compatibility(chain_id, founder)
			if score > selected_score:
				selected_id = founder_id
				selected_score = score
		if selected_id.is_empty():
			setup()
			return false
		var assigned: Dictionary = (founder_by_id[selected_id] as Dictionary).duplicate(true)
		assigned["compatibility_score"] = selected_score
		assignments[chain_id] = assigned
		chain_states[chain_id] = {
			"chain_id": chain_id,
			"status": STATUS_WAITING_OPENING,
			"start_day": CATALOG_SCRIPT.get_start_day(chain_id),
			"opening_day": 0,
			"opening_choice_id": "",
			"consequence_day": 0,
			"consequence_choice_id": "",
			"window_end_day": 0,
			"baseline": {},
			"prepared_event": {}
		}
		remaining_ids.erase(selected_id)

	initialized = true
	return true


func try_prepare_event(completed_day: int, world_context: Dictionary) -> Dictionary:
	if not initialized or completed_day < 1:
		return {"event": {}, "state_changed": false}

	var state_changed: bool = _expire_windows(completed_day)
	if _has_active_chain_event():
		return {"event": {}, "state_changed": state_changed}

	for chain_id: String in CATALOG_SCRIPT.get_chain_ids():
		var state: Dictionary = chain_states.get(chain_id, {})
		if String(state.get("status", "")) != STATUS_WAITING_CONSEQUENCE:
			continue
		if completed_day > int(state.get("window_end_day", 0)):
			continue
		var condition: Dictionary = _evaluate_consequence_condition(
			chain_id,
			state,
			world_context
		)
		if not bool(condition.get("met", false)):
			continue
		var event_context: Dictionary = _build_event_context(
			chain_id,
			world_context,
			condition
		)
		var event_data: Dictionary = CATALOG_SCRIPT.build_event(
			chain_id,
			"consequence",
			event_context,
			String(state.get("opening_choice_id", ""))
		)
		if event_data.is_empty():
			continue
		event_data["triggered_after_day"] = completed_day
		known_events[String(event_data.get("id", ""))] = event_data.duplicate(true)
		state["status"] = STATUS_CONSEQUENCE_ACTIVE
		state["prepared_event"] = event_data.duplicate(true)
		chain_states[chain_id] = state
		return {"event": event_data, "state_changed": true}

	for chain_id: String in CATALOG_SCRIPT.get_chain_ids():
		var state: Dictionary = chain_states.get(chain_id, {})
		if String(state.get("status", "")) != STATUS_WAITING_OPENING:
			continue
		if completed_day < int(state.get("start_day", 1)):
			continue
		var event_context: Dictionary = _build_event_context(
			chain_id,
			world_context,
			{}
		)
		var event_data: Dictionary = CATALOG_SCRIPT.build_event(
			chain_id,
			"opening",
			event_context
		)
		if event_data.is_empty():
			continue
		event_data["triggered_after_day"] = completed_day
		known_events[String(event_data.get("id", ""))] = event_data.duplicate(true)
		state["status"] = STATUS_OPENING_ACTIVE
		state["prepared_event"] = event_data.duplicate(true)
		chain_states[chain_id] = state
		return {"event": event_data, "state_changed": true}

	return {"event": {}, "state_changed": state_changed}


func record_resolution(
	event_data: Dictionary,
	choice_data: Dictionary,
	day_value: int,
	world_context: Dictionary
) -> Dictionary:
	if not bool(event_data.get("is_founder_memory", false)):
		return {}
	var chain_id: String = String(event_data.get("memory_chain_id", ""))
	var stage: String = String(event_data.get("memory_stage", ""))
	var founder_id: String = String(event_data.get("memory_founder_id", ""))
	var choice_id: String = String(choice_data.get("id", ""))
	var state: Dictionary = chain_states.get(chain_id, {})
	if state.is_empty() or founder_id.is_empty() or choice_id.is_empty():
		return {}

	var expected_status: String = (
		STATUS_OPENING_ACTIVE if stage == "opening" else STATUS_CONSEQUENCE_ACTIVE
	)
	if String(state.get("status", "")) != expected_status:
		return {}

	var history_entry: Dictionary = {
		"day": maxi(1, day_value),
		"chain_id": chain_id,
		"chain_name": CATALOG_SCRIPT.get_chain_name(chain_id),
		"choice_id": choice_id,
		"choice_title": String(choice_data.get("title", "Decisão registrada"))
	}
	var visual_changed: bool = false

	if stage == "opening":
		var opening_day: int = maxi(
			1,
			int(event_data.get("triggered_after_day", day_value))
		)
		state["status"] = STATUS_WAITING_CONSEQUENCE
		state["opening_day"] = opening_day
		state["opening_choice_id"] = choice_id
		state["window_end_day"] = (
			opening_day
			+ CONSEQUENCE_WINDOW_DAYS
			+ consequence_window_day_adjustment
		)
		state["baseline"] = _build_baseline(chain_id, founder_id, world_context)
		state["prepared_event"] = {}
		history_entry["type"] = "founder_memory_opening"
		history_entry["title"] = (
			"conversou sobre %s; você decidiu “%s”"
			% [
				CATALOG_SCRIPT.get_chain_name(chain_id).to_lower(),
				String(choice_data.get("title", "responder"))
			]
		)
	else:
		state["status"] = STATUS_COMPLETED
		state["consequence_day"] = maxi(1, day_value)
		state["consequence_choice_id"] = choice_id
		state["prepared_event"] = {}
		history_entry["type"] = "founder_memory_consequence"
		history_entry["title"] = (
			"viu a decisão sobre %s retornar; você escolheu “%s”"
			% [
				CATALOG_SCRIPT.get_chain_name(chain_id).to_lower(),
				String(choice_data.get("title", "responder"))
			]
		)
		var marker_id: String = String(choice_data.get("memory_marker_id", ""))
		if not marker_id.is_empty() and not _has_visual_marker(marker_id):
			visual_markers.append({
				"marker_id": marker_id,
				"marker_name": _marker_name(marker_id),
				"chain_id": chain_id,
				"founder_id": founder_id,
				"founder_name": String(
					(assignments.get(chain_id, {}) as Dictionary).get(
						"founder_name",
						"Fundador"
					)
				),
				"day": maxi(1, day_value)
			})
			visual_changed = true

	chain_states[chain_id] = state
	return {
		"founder_id": founder_id,
		"chain_id": chain_id,
		"stage": stage,
		"history_entry": history_entry,
		"visual_changed": visual_changed,
		"overview": get_overview()
	}


func get_registered_events() -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	var event_ids: Array[String] = []
	for event_id_value: Variant in known_events.keys():
		event_ids.append(String(event_id_value))
	event_ids.sort()
	for event_id: String in event_ids:
		var event_value: Variant = known_events.get(event_id, null)
		if event_value is Dictionary:
			events.append((event_value as Dictionary).duplicate(true))
	return events


func get_overview() -> Dictionary:
	var rows: Array[Dictionary] = []
	for chain_id: String in CATALOG_SCRIPT.get_chain_ids():
		var assignment: Dictionary = assignments.get(chain_id, {})
		var state: Dictionary = chain_states.get(chain_id, {})
		rows.append({
			"chain_id": chain_id,
			"chain_name": CATALOG_SCRIPT.get_chain_name(chain_id),
			"founder_id": String(assignment.get("founder_id", "")),
			"founder_name": String(assignment.get("founder_name", "")),
			"status": String(state.get("status", "")),
			"opening_day": int(state.get("opening_day", 0)),
			"window_end_day": int(state.get("window_end_day", 0)),
			"consequence_day": int(state.get("consequence_day", 0))
		})
	return {
		"initialized": initialized,
		"chains": rows,
		"visual_markers": visual_markers.duplicate(true),
		"completed_count": _count_status(STATUS_COMPLETED),
		"expired_count": _count_status(STATUS_EXPIRED)
	}


func export_save_data() -> Dictionary:
	return {
		"state_version": STATE_VERSION,
		"initialized": initialized,
		"assignments": assignments.duplicate(true),
		"chain_states": chain_states.duplicate(true),
		"visual_markers": visual_markers.duplicate(true),
		"known_events": known_events.duplicate(true)
	}


func import_save_data(save_data: Dictionary) -> bool:
	if int(save_data.get("state_version", 0)) != STATE_VERSION:
		return false
	if (
		not save_data.get("assignments", null) is Dictionary
		or not save_data.get("chain_states", null) is Dictionary
		or not save_data.get("visual_markers", null) is Array
		or not save_data.get("known_events", null) is Dictionary
	):
		return false

	initialized = bool(save_data.get("initialized", false))
	assignments = (save_data.get("assignments", {}) as Dictionary).duplicate(true)
	chain_states = (save_data.get("chain_states", {}) as Dictionary).duplicate(true)
	known_events = (save_data.get("known_events", {}) as Dictionary).duplicate(true)
	visual_markers.clear()
	for marker_value: Variant in save_data.get("visual_markers", []) as Array:
		if not marker_value is Dictionary:
			return false
		visual_markers.append((marker_value as Dictionary).duplicate(true))
	return validate_state()


func validate_state() -> bool:
	if not initialized:
		return (
			assignments.is_empty()
			and chain_states.is_empty()
			and visual_markers.is_empty()
			and known_events.is_empty()
		)
	if (
		assignments.size() != CATALOG_SCRIPT.CHAIN_IDS.size()
		or chain_states.size() != CATALOG_SCRIPT.CHAIN_IDS.size()
	):
		return false

	var founder_ids: Array[String] = []
	for chain_id: String in CATALOG_SCRIPT.get_chain_ids():
		var assignment_value: Variant = assignments.get(chain_id, null)
		var state_value: Variant = chain_states.get(chain_id, null)
		if not assignment_value is Dictionary or not state_value is Dictionary:
			return false
		var founder_id: String = String(
			(assignment_value as Dictionary).get("founder_id", "")
		).strip_edges()
		if founder_id.is_empty() or founder_ids.has(founder_id):
			return false
		founder_ids.append(founder_id)
		var status: String = String((state_value as Dictionary).get("status", ""))
		if status not in [
			STATUS_WAITING_OPENING,
			STATUS_OPENING_ACTIVE,
			STATUS_WAITING_CONSEQUENCE,
			STATUS_CONSEQUENCE_ACTIVE,
			STATUS_COMPLETED,
			STATUS_EXPIRED
		]:
			return false
		var prepared_value: Variant = (state_value as Dictionary).get("prepared_event", {})
		if not prepared_value is Dictionary:
			return false
		if status in [STATUS_OPENING_ACTIVE, STATUS_CONSEQUENCE_ACTIVE]:
			if (prepared_value as Dictionary).is_empty():
				return false
		elif not (prepared_value as Dictionary).is_empty():
			return false

	var marker_ids: Array[String] = []
	for marker: Dictionary in visual_markers:
		var marker_id: String = String(marker.get("marker_id", "")).strip_edges()
		if marker_id.is_empty() or marker_ids.has(marker_id):
			return false
		marker_ids.append(marker_id)
	for event_id_value: Variant in known_events.keys():
		var event_id: String = String(event_id_value).strip_edges()
		var event_value: Variant = known_events.get(event_id_value, null)
		if event_id.is_empty() or not event_value is Dictionary:
			return false
		if String((event_value as Dictionary).get("id", "")) != event_id:
			return false
	return true


func _expire_windows(completed_day: int) -> bool:
	var changed: bool = false
	for chain_id: String in CATALOG_SCRIPT.get_chain_ids():
		var state: Dictionary = chain_states.get(chain_id, {})
		if String(state.get("status", "")) != STATUS_WAITING_CONSEQUENCE:
			continue
		if completed_day <= int(state.get("window_end_day", 0)):
			continue
		state["status"] = STATUS_EXPIRED
		state["prepared_event"] = {}
		chain_states[chain_id] = state
		changed = true
	return changed


func _has_active_chain_event() -> bool:
	for state_value: Variant in chain_states.values():
		if not state_value is Dictionary:
			continue
		if String((state_value as Dictionary).get("status", "")) in [
			STATUS_OPENING_ACTIVE,
			STATUS_CONSEQUENCE_ACTIVE
		]:
			return true
	return false


func _build_event_context(
	chain_id: String,
	world_context: Dictionary,
	condition: Dictionary
) -> Dictionary:
	var assignment: Dictionary = assignments.get(chain_id, {})
	var context: Dictionary = assignment.duplicate(true)
	var season_name: String = String(world_context.get("season_name", "Primavera"))
	context["season_context"] = "tempo de %s" % season_name
	context["building_context"] = _get_building_context(world_context)
	context["council_context"] = _get_council_context(
		String(assignment.get("founder_id", "")),
		world_context
	)
	context["condition_text"] = String(
		condition.get("condition_text", "A vila ofereceu uma nova circunstância.")
	)
	context["observer_text"] = _get_observer_text(chain_id)
	return context


func _build_baseline(
	chain_id: String,
	founder_id: String,
	world_context: Dictionary
) -> Dictionary:
	var progress_by_id: Dictionary = world_context.get("founder_progress", {})
	var progress: Dictionary = progress_by_id.get(founder_id, {})
	return {
		"chain_id": chain_id,
		"days_in_council": int(progress.get("days_in_council", 0)),
		"food_shortage_days": int(world_context.get("food_shortage_days", 0)),
		"material_shortage_days": int(world_context.get("material_shortage_days", 0)),
		"council_signature": String(world_context.get("council_signature", "")),
		"building_signature": String(world_context.get("building_signature", ""))
	}


func _evaluate_consequence_condition(
	chain_id: String,
	state: Dictionary,
	world_context: Dictionary
) -> Dictionary:
	var baseline: Dictionary = state.get("baseline", {})
	var assignment: Dictionary = assignments.get(chain_id, {})
	var founder_id: String = String(assignment.get("founder_id", ""))
	match chain_id:
		"recognition":
			var progress_by_id: Dictionary = world_context.get("founder_progress", {})
			var progress: Dictionary = progress_by_id.get(founder_id, {})
			var added_days: int = (
				int(progress.get("days_in_council", 0))
				- int(baseline.get("days_in_council", 0))
			)
			return {
				"met": added_days >= 2,
				"condition_text": "houve mais %d dia(s) de contribuição direta ao Conselho." % maxi(0, added_days)
			}
		"responsibility":
			var food_delta: int = (
				int(world_context.get("food_shortage_days", 0))
				- int(baseline.get("food_shortage_days", 0))
			)
			var material_delta: int = (
				int(world_context.get("material_shortage_days", 0))
				- int(baseline.get("material_shortage_days", 0))
			)
			var low_happiness: bool = float(world_context.get("happiness", 100.0)) < 45.0
			return {
				"met": food_delta > 0 or material_delta > 0 or low_happiness,
				"condition_text": (
					"a alimentação ficou sob pressão."
					if food_delta > 0
					else (
						"a manutenção consumiu mais material do que havia disponível."
						if material_delta > 0
						else "a felicidade caiu a um nível preocupante."
					)
				)
			}
		"belonging":
			var changed: bool = (
				String(world_context.get("council_signature", ""))
				!= String(baseline.get("council_signature", ""))
			)
			return {
				"met": changed,
				"condition_text": "funções ou membros ativos já não ocupam os mesmos lugares."
			}
		"convictions":
			var changed: bool = (
				String(world_context.get("building_signature", ""))
				!= String(baseline.get("building_signature", ""))
			)
			return {
				"met": changed,
				"condition_text": "uma construção avançou ou assumiu uma variante irreversível."
			}
	return {"met": false, "condition_text": ""}


func _get_building_context(world_context: Dictionary) -> String:
	var variants: Dictionary = world_context.get("building_variants", {})
	var selected_ids: Array[String] = []
	for variant_value: Variant in variants.values():
		var variant_id: String = String(variant_value).strip_edges()
		if not variant_id.is_empty():
			selected_ids.append(variant_id)
	selected_ids.sort()
	if not selected_ids.is_empty():
		var definition: Dictionary = BUILDING_VARIANT_CATALOG_SCRIPT.get_variant(
			selected_ids[0]
		)
		return "A build %s já influencia as conversas." % String(
			definition.get("name", "escolhida")
		)

	var levels: Dictionary = world_context.get("building_levels", {})
	var highest_name: String = ""
	var highest_level: int = 0
	for building_id_value: Variant in levels.keys():
		var level: int = int(levels[building_id_value])
		if level > highest_level:
			highest_level = level
			highest_name = _building_name(String(building_id_value))
	if highest_level > 0:
		return "%s é a obra mais desenvolvida, no nível %d." % [highest_name, highest_level]
	return "Nenhuma obra domina a identidade da vila ainda."


func _get_council_context(founder_id: String, world_context: Dictionary) -> String:
	var active_ids: Array = world_context.get("active_council_ids", [])
	var profession_count: int = int(world_context.get("distinct_professions", 0))
	return (
		"A pessoa está no Conselho ativo, que reúne %d profissão(ões) diferente(s)."
		% profession_count
		if active_ids.has(founder_id)
		else "A pessoa observa da reserva enquanto o Conselho ativo reúne %d profissão(ões)." % profession_count
	)


func _get_observer_text(chain_id: String) -> String:
	var protagonist_id: String = String(
		(assignments.get(chain_id, {}) as Dictionary).get("founder_id", "")
	)
	for other_chain_id: String in CATALOG_SCRIPT.get_chain_ids():
		var other: Dictionary = assignments.get(other_chain_id, {})
		if String(other.get("founder_id", "")) == protagonist_id:
			continue
		var other_name: String = String(other.get("founder_name", "Outro fundador"))
		var personality_id: String = String(other.get("personality_id", ""))
		var reaction: String = (
			"lembra que uma promessa precisa aparecer nas decisões, não apenas nas falas."
			if personality_id in ["cautious", "practical", "stubborn"]
			else "observa que a forma de reparar também contará como parte da história da vila."
		)
		return "\n\n%s reage sem tomar o centro da conversa e %s" % [other_name, reaction]
	return ""


func _has_visual_marker(marker_id: String) -> bool:
	for marker: Dictionary in visual_markers:
		if String(marker.get("marker_id", "")) == marker_id:
			return true
	return false


func _count_status(status: String) -> int:
	var count: int = 0
	for state_value: Variant in chain_states.values():
		if state_value is Dictionary and String((state_value as Dictionary).get("status", "")) == status:
			count += 1
	return count


func _marker_name(marker_id: String) -> String:
	match marker_id:
		"founder_banner": return "Estandarte dos Fundadores"
		"repair_cairn": return "Marco da Reparação"
		"shared_bench": return "Banco Compartilhado"
		"council_lantern": return "Lanterna do Conselho"
		_: return "Memória da vila"


func _building_name(building_id: String) -> String:
	match building_id:
		"barn": return "O Celeiro"
		"sawmill": return "A Serraria"
		"well": return "O Poço"
		"square": return "A Praça"
		"palisade": return "A Muralha"
		_: return "Uma construção"
