class_name CouncilCompositionCatalog
extends RefCounted


const MAX_ACTIVE_SYNERGIES: int = 2
const CONCENTRATION_MULTIPLIERS: Dictionary = {
	1: 1.00,
	2: 0.97,
	3: 0.93,
	4: 0.88
}

const SYNERGIES: Array[Dictionary] = [
	{
		"id": "ciclo_sustento",
		"name": "Ciclo de Sustento",
		"professions": [Villager.Profession.FARMER, Villager.Profession.GATHERER],
		"effect_type": "food_multiplier",
		"value": 0.03,
		"description": "Agricultor + Coletor: +3% na produção de alimentação."
	},
	{
		"id": "forja_abastecida",
		"name": "Forja Abastecida",
		"professions": [Villager.Profession.BLACKSMITH, Villager.Profession.GATHERER],
		"effect_type": "material_multiplier",
		"value": 0.03,
		"description": "Ferreiro + Coletor: +3% na produção de material."
	},
	{
		"id": "obras_protegidas",
		"name": "Obras Protegidas",
		"professions": [Villager.Profession.BLACKSMITH, Villager.Profession.GUARD],
		"effect_type": "maintenance_reduction",
		"value": 0.25,
		"description": "Ferreiro + Guarda: -0,25 de manutenção diária total."
	},
	{
		"id": "ordem_comunitaria",
		"name": "Ordem Comunitária",
		"professions": [Villager.Profession.CIVIL_SERVANT, Villager.Profession.GUARD],
		"effect_type": "happiness_bonus",
		"value": 0.25,
		"description": "Servidor Público + Guarda: +0,25 de felicidade diária."
	},
	{
		"id": "conselho_diverso",
		"name": "Conselho Diverso",
		"professions": [],
		"effect_type": "all_production_multiplier",
		"value": 0.02,
		"description": "Quatro profissões diferentes: +2% em toda produção do Conselho.",
		"requires_four_unique": true
	}
]


static func get_concentration_overview(active_council: Array[Villager]) -> Dictionary:
	var counts: Dictionary = {}
	var max_count: int = 1
	var concentrated_profession: int = Villager.Profession.UNASSIGNED
	for villager: Villager in active_council:
		if not is_instance_valid(villager):
			continue
		var profession: int = villager.current_profession
		if profession == Villager.Profession.UNASSIGNED:
			continue
		counts[profession] = int(counts.get(profession, 0)) + 1
		if int(counts[profession]) > max_count:
			max_count = int(counts[profession])
			concentrated_profession = profession
	var multiplier: float = float(CONCENTRATION_MULTIPLIERS.get(max_count, 1.0))
	return {
		"max_same_profession": max_count,
		"profession_counts": counts.duplicate(true),
		"profession": concentrated_profession,
		"profession_name": Villager.get_profession_name(concentrated_profession),
		"multiplier": multiplier,
		"penalty_percent": roundi((1.0 - multiplier) * 100.0),
		"active": multiplier < 0.999
	}


static func select_synergies(
	active_council: Array[Villager],
	base_totals: Dictionary
) -> Dictionary:
	var candidates: Array[Dictionary] = _build_candidates(active_council, base_totals)
	var best: Array[Dictionary] = []
	var best_score: float = -1.0
	for candidate: Dictionary in candidates:
		var score: float = float(candidate.get("score", 0.0))
		if score > best_score:
			best = [candidate]
			best_score = score
	for first_index: int in range(candidates.size()):
		for second_index: int in range(first_index + 1, candidates.size()):
			var first: Dictionary = candidates[first_index]
			var second: Dictionary = candidates[second_index]
			if String(first.get("id", "")) == String(second.get("id", "")):
				continue
			if _members_overlap(
				first.get("member_ids", []) as Array,
				second.get("member_ids", []) as Array
			):
				continue
			var score: float = float(first.get("score", 0.0)) + float(second.get("score", 0.0))
			if score > best_score:
				best = [first, second]
				best_score = score
	if best.size() > MAX_ACTIVE_SYNERGIES:
		best.resize(MAX_ACTIVE_SYNERGIES)
	var active_keys: Dictionary = {}
	for selected: Dictionary in best:
		active_keys[_candidate_key(selected)] = true
	var limited: Array[Dictionary] = []
	for candidate: Dictionary in candidates:
		if not active_keys.has(_candidate_key(candidate)):
			limited.append(candidate.duplicate(true))
	return {
		"active": _duplicate_dictionary_array(best),
		"qualified_but_limited": limited,
		"qualified_count": candidates.size(),
		"limit": MAX_ACTIVE_SYNERGIES
	}


static func get_combined_modifiers(active_synergies: Array) -> Dictionary:
	var result: Dictionary = {
		"food_multiplier_bonus": 0.0,
		"material_multiplier_bonus": 0.0,
		"all_production_multiplier_bonus": 0.0,
		"maintenance_reduction": 0.0,
		"happiness_bonus": 0.0
	}
	for value: Variant in active_synergies:
		if not value is Dictionary:
			continue
		var synergy: Dictionary = value as Dictionary
		var effect_type: String = String(synergy.get("effect_type", ""))
		var amount: float = float(synergy.get("value", 0.0))
		match effect_type:
			"food_multiplier": result["food_multiplier_bonus"] = float(result["food_multiplier_bonus"]) + amount
			"material_multiplier": result["material_multiplier_bonus"] = float(result["material_multiplier_bonus"]) + amount
			"all_production_multiplier": result["all_production_multiplier_bonus"] = float(result["all_production_multiplier_bonus"]) + amount
			"maintenance_reduction": result["maintenance_reduction"] = float(result["maintenance_reduction"]) + amount
			"happiness_bonus": result["happiness_bonus"] = float(result["happiness_bonus"]) + amount
	return result


static func validate_catalog() -> Dictionary:
	var errors: Array[String] = []
	var ids: Dictionary = {}
	for synergy: Dictionary in SYNERGIES:
		var synergy_id: String = String(synergy.get("id", ""))
		if synergy_id.is_empty():
			errors.append("Sinergia sem ID.")
		elif ids.has(synergy_id):
			errors.append("Sinergia duplicada: %s." % synergy_id)
		else:
			ids[synergy_id] = true
		if String(synergy.get("description", "")).is_empty():
			errors.append("%s sem descrição." % synergy_id)
	return {
		"success": errors.is_empty(),
		"count": SYNERGIES.size(),
		"errors": errors
	}


static func _build_candidates(
	active_council: Array[Villager],
	base_totals: Dictionary
) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	for definition: Dictionary in SYNERGIES:
		if bool(definition.get("requires_four_unique", false)):
			var unique_professions: Dictionary = {}
			var member_ids: Array[String] = []
			var member_names: Array[String] = []
			for villager: Villager in active_council:
				if not is_instance_valid(villager) or villager.current_profession == Villager.Profession.UNASSIGNED:
					unique_professions.clear()
					break
				unique_professions[villager.current_profession] = true
				member_ids.append(villager.representative_id)
				member_names.append(villager.villager_name)
			if active_council.size() == 4 and unique_professions.size() == 4:
				candidates.append(_make_candidate(definition, member_ids, member_names, base_totals))
			continue
		var professions_value: Variant = definition.get("professions", [])
		if not professions_value is Array or (professions_value as Array).size() != 2:
			continue
		var required: Array = professions_value as Array
		for first_index: int in range(active_council.size()):
			var first: Villager = active_council[first_index]
			if not is_instance_valid(first):
				continue
			for second_index: int in range(first_index + 1, active_council.size()):
				var second: Villager = active_council[second_index]
				if not is_instance_valid(second):
					continue
				var matches: bool = (
					(first.current_profession == int(required[0]) and second.current_profession == int(required[1]))
					or (first.current_profession == int(required[1]) and second.current_profession == int(required[0]))
				)
				if matches:
					candidates.append(_make_candidate(
						definition,
						[first.representative_id, second.representative_id],
						[first.villager_name, second.villager_name],
						base_totals
					))
	return candidates


static func _make_candidate(
	definition: Dictionary,
	member_ids: Array[String],
	member_names: Array[String],
	base_totals: Dictionary
) -> Dictionary:
	var candidate: Dictionary = definition.duplicate(true)
	candidate["member_ids"] = member_ids.duplicate()
	candidate["member_names"] = member_names.duplicate()
	candidate["score"] = _estimate_score(candidate, base_totals)
	return candidate


static func _estimate_score(candidate: Dictionary, base_totals: Dictionary) -> float:
	var value: float = float(candidate.get("value", 0.0))
	match String(candidate.get("effect_type", "")):
		"food_multiplier": return float(base_totals.get("food", 0.0)) * value
		"material_multiplier": return float(base_totals.get("material", 0.0)) * value
		"all_production_multiplier":
			return (
				float(base_totals.get("food", 0.0))
				+ float(base_totals.get("material", 0.0))
				+ float(base_totals.get("happiness", 0.0))
			) * value
		"maintenance_reduction": return value
		"happiness_bonus": return value
		_: return 0.0


static func _members_overlap(first: Array, second: Array) -> bool:
	for value: Variant in first:
		if second.has(value):
			return true
	return false


static func _candidate_key(candidate: Dictionary) -> String:
	var ids: Array[String] = []
	var members_value: Variant = candidate.get("member_ids", [])
	if members_value is Array:
		for value: Variant in members_value as Array:
			ids.append(String(value))
	ids.sort()
	var packed_ids: PackedStringArray = PackedStringArray()
	for member_id: String in ids:
		packed_ids.append(member_id)
	return "%s:%s" % [String(candidate.get("id", "")), ",".join(packed_ids)]


static func _duplicate_dictionary_array(values: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value: Dictionary in values:
		result.append(value.duplicate(true))
	return result
