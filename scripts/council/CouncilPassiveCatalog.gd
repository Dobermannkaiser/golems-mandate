class_name CouncilPassiveCatalog
extends RefCounted


const PASSIVES: Array[Dictionary] = [
	{
		"id": "adaptavel",
		"name": "Adaptável",
		"description": "+3% de produção pessoal em qualquer profissão.",
		"condition": "Ativa enquanto a carta tiver uma profissão definida."
	},
	{
		"id": "dedicado",
		"name": "Dedicado",
		"description": "+6% de produção pessoal após cinco dias completos na mesma profissão.",
		"condition": "Perde o bônus ao trocar de profissão."
	},
	{
		"id": "inquieto",
		"name": "Inquieto",
		"description": "+6% de produção pessoal nos três primeiros dias depois de trocar de profissão.",
		"condition": "A primeira profissão escolhida não conta como troca."
	},
	{
		"id": "versatil",
		"name": "Versátil",
		"description": "+1% de produção pessoal por profissão exercida durante ao menos três dias, até +4%.",
		"condition": "O histórico de trabalho da carta é permanente."
	},
	{
		"id": "rival_produtivo",
		"name": "Rival Produtivo",
		"description": "+5% de produção pessoal quando exatamente outra carta possui a mesma profissão.",
		"condition": "Ativa somente com duas cartas nessa profissão."
	},
	{
		"id": "organizador",
		"name": "Organizador",
		"description": "+3% de produção pessoal quando as quatro cartas ativas possuem profissão definida.",
		"condition": "Nenhuma vaga ativa pode estar sem profissão."
	},
	{
		"id": "veterano",
		"name": "Veterano",
		"description": "+1% de produção pessoal por nível acima do primeiro, até +5%.",
		"condition": "O bônus cresce automaticamente com o nível."
	},
	{
		"id": "incansavel",
		"name": "Incansável",
		"description": "+1 XP adicional ao terminar o dia ativo no Conselho.",
		"condition": "Não concede XP enquanto a carta estiver na reserva."
	},
	{
		"id": "autossuficiente",
		"name": "Autossuficiente",
		"description": "Reduz o consumo diário de alimentação pelo equivalente a um habitante.",
		"condition": "Ativa enquanto a carta estiver no Conselho."
	},
	{
		"id": "economico",
		"name": "Econômico",
		"description": "Reduz em 0,30 a manutenção diária total de material.",
		"condition": "Ativa enquanto a carta estiver no Conselho."
	},
	{
		"id": "motivador",
		"name": "Motivador",
		"description": "+0,25 de felicidade produzida por dia.",
		"condition": "Ativa enquanto a carta estiver no Conselho."
	},
	{
		"id": "otimista",
		"name": "Otimista",
		"description": "+0,25 de felicidade produzida quando a felicidade da vila estiver abaixo de 55.",
		"condition": "Fica inativa quando a felicidade chega a 55 ou mais."
	},
	{
		"id": "improvisador",
		"name": "Improvisador",
		"description": "+5 pontos percentuais em testes arriscados quando esta carta é responsável.",
		"condition": "Só atua em escolhas que possuem teste de atributo."
	},
	{
		"id": "protetor",
		"name": "Protetor",
		"description": "Reduz em 15% as consequências negativas de uma falha quando esta carta é responsável.",
		"condition": "Custos pagos antes da tentativa não são reduzidos."
	},
	{
		"id": "mediador",
		"name": "Mediador",
		"description": "Aumenta em 1 os ganhos de relação ou reduz em 1 as perdas, no máximo uma vez por dia.",
		"condition": "Só atua em decisões de história pelas quais esta carta é responsável."
	}
]

const MIMO_PASSIVE: Dictionary = {
	"id": "faz_tudo",
	"name": "Faz-tudo",
	"description": "+5% em qualquer profissão e +5% adicional quando sua profissão é única no Conselho.",
	"condition": "A parcela adicional exige que nenhuma outra carta use a mesma profissão."
}


static func get_all() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for definition: Dictionary in PASSIVES:
		result.append(definition.duplicate(true))
	return result


static func get_definition(passive_id: String) -> Dictionary:
	if passive_id == "faz_tudo":
		return MIMO_PASSIVE.duplicate(true)
	for definition: Dictionary in PASSIVES:
		if String(definition.get("id", "")) == passive_id:
			return definition.duplicate(true)
	return {}


static func get_randomized_passives(
	count: int,
	rng: RandomNumberGenerator,
	excluded_ids: Array[String] = []
) -> Array[Dictionary]:
	var unseen_pool: Array[Dictionary] = []
	var fallback_pool: Array[Dictionary] = []
	for definition: Dictionary in PASSIVES:
		var passive_id: String = String(definition.get("id", ""))
		fallback_pool.append(definition.duplicate(true))
		if not excluded_ids.has(passive_id):
			unseen_pool.append(definition.duplicate(true))
	_shuffle_dictionary_array(unseen_pool, rng)
	_shuffle_dictionary_array(fallback_pool, rng)
	var result: Array[Dictionary] = []
	var chosen_ids: Array[String] = []
	for definition: Dictionary in unseen_pool:
		if result.size() >= count:
			break
		var passive_id: String = String(definition.get("id", ""))
		if chosen_ids.has(passive_id):
			continue
		result.append(definition.duplicate(true))
		chosen_ids.append(passive_id)
	for definition: Dictionary in fallback_pool:
		if result.size() >= count:
			break
		var passive_id: String = String(definition.get("id", ""))
		if chosen_ids.has(passive_id):
			continue
		result.append(definition.duplicate(true))
		chosen_ids.append(passive_id)
	return result


static func evaluate(passive_id: String, context: Dictionary) -> Dictionary:
	var definition: Dictionary = get_definition(passive_id)
	var result: Dictionary = {
		"id": passive_id,
		"name": String(definition.get("name", "Sem passiva")),
		"description": String(definition.get("description", "")),
		"condition": String(definition.get("condition", "")),
		"state": "inactive",
		"active": false,
		"status_text": "Sem efeito na situação atual.",
		"production_multiplier_bonus": 0.0,
		"daily_happiness_bonus": 0.0,
		"daily_xp_bonus": 0,
		"fixed_food_consumption_reduction": 0.0,
		"fixed_material_maintenance_reduction": 0.0,
		"event_chance_bonus": 0.0,
		"failure_negative_multiplier": 1.0,
		"relationship_delta_adjustment": 0
	}
	var assigned: bool = bool(context.get("assigned", false))
	var same_profession_count: int = int(context.get("same_profession_count", 0))
	var all_assigned: bool = bool(context.get("all_assigned", false))
	var level_value: int = maxi(1, int(context.get("level", 1)))
	var streak_days: int = maxi(0, int(context.get("profession_streak_days", 0)))
	var change_count: int = maxi(0, int(context.get("profession_change_count", 0)))
	var profession_day_counts: Dictionary = context.get("profession_day_counts", {})
	var current_happiness: float = float(context.get("current_happiness", 0.0))
	var active_in_council: bool = bool(context.get("active_in_council", false))
	match passive_id:
		"faz_tudo":
			if assigned and active_in_council:
				result["active"] = true
				result["state"] = "active"
				result["production_multiplier_bonus"] = 0.05 if same_profession_count == 1 else 0.0
				result["status_text"] = (
					"Ativa em potência máxima: profissão única no Conselho."
					if same_profession_count == 1
					else "Ativa: +5% básico; o bônus adicional exige profissão única."
				)
		"adaptavel":
			if assigned and active_in_council:
				_set_active(result, "+3% de produção pessoal.")
				result["production_multiplier_bonus"] = 0.03
		"dedicado":
			if assigned and active_in_council and streak_days >= 5:
				_set_active(result, "+6% após %d dias na mesma profissão." % streak_days)
				result["production_multiplier_bonus"] = 0.06
			else:
				_set_conditional(result, "Requer 5 dias completos na mesma profissão; atual: %d." % streak_days)
		"inquieto":
			if assigned and active_in_council and change_count > 0 and streak_days < 3:
				_set_active(result, "+6% durante a adaptação à nova profissão (%d/3 dias)." % (streak_days + 1))
				result["production_multiplier_bonus"] = 0.06
			else:
				_set_conditional(result, "Ativa somente nos três primeiros dias depois de uma troca de profissão.")
		"versatil":
			var qualified_professions: int = 0
			for key_value: Variant in profession_day_counts.keys():
				if int(profession_day_counts[key_value]) >= 3:
					qualified_professions += 1
			var bonus: float = minf(0.04, float(qualified_professions) * 0.01)
			if assigned and active_in_council and bonus > 0.0:
				_set_active(result, "+%d%% por experiência em %d profissão(ões)." % [roundi(bonus * 100.0), qualified_professions])
				result["production_multiplier_bonus"] = bonus
			else:
				_set_conditional(result, "Trabalhe três dias em uma profissão para iniciar o bônus.")
		"rival_produtivo":
			if assigned and active_in_council and same_profession_count == 2:
				_set_active(result, "+5% com exatamente duas cartas na profissão.")
				result["production_multiplier_bonus"] = 0.05
			else:
				_set_conditional(result, "Exige exatamente duas cartas na mesma profissão.")
		"organizador":
			if assigned and active_in_council and all_assigned:
				_set_active(result, "+3% porque todas as profissões estão definidas.")
				result["production_multiplier_bonus"] = 0.03
			else:
				_set_conditional(result, "Defina a profissão das quatro cartas ativas.")
		"veterano":
			var veteran_bonus: float = minf(0.05, float(maxi(0, level_value - 1)) * 0.01)
			if assigned and active_in_council and veteran_bonus > 0.0:
				_set_active(result, "+%d%% pelo nível %d." % [roundi(veteran_bonus * 100.0), level_value])
				result["production_multiplier_bonus"] = veteran_bonus
			else:
				_set_conditional(result, "O bônus começa no nível 2.")
		"incansavel":
			if active_in_council:
				_set_active(result, "+1 XP ao encerrar o dia.")
				result["daily_xp_bonus"] = 1
		"autossuficiente":
			if active_in_council:
				_set_active(result, "Reduz o consumo pelo equivalente a um habitante.")
				result["fixed_food_consumption_reduction"] = maxf(0.0, float(context.get("food_consumption_per_villager", 0.0)))
		"economico":
			if active_in_council:
				_set_active(result, "Reduz a manutenção total em 0,30 material.")
				result["fixed_material_maintenance_reduction"] = 0.30
		"motivador":
			if active_in_council:
				_set_active(result, "+0,25 de felicidade por dia.")
				result["daily_happiness_bonus"] = 0.25
		"otimista":
			if active_in_council and current_happiness < 55.0:
				_set_active(result, "+0,25 porque a felicidade está abaixo de 55.")
				result["daily_happiness_bonus"] = 0.25
			else:
				_set_conditional(result, "Ativa quando a felicidade da vila fica abaixo de 55.")
		"improvisador":
			_set_conditional(result, "Pronta para conceder +5 pontos percentuais quando responsável por um teste.")
			result["event_chance_bonus"] = 0.05
		"protetor":
			_set_conditional(result, "Pronta para reduzir em 15% as perdas de uma falha sob sua responsabilidade.")
			result["failure_negative_multiplier"] = 0.85
		"mediador":
			_set_conditional(result, "Pronta para melhorar uma alteração de relação, uma vez por dia.")
			result["relationship_delta_adjustment"] = 1
	return result


static func validate_catalog() -> Dictionary:
	var errors: Array[String] = []
	var ids: Dictionary = {}
	for definition: Dictionary in PASSIVES:
		var passive_id: String = String(definition.get("id", "")).strip_edges()
		if passive_id.is_empty():
			errors.append("Passiva sem ID.")
		elif ids.has(passive_id):
			errors.append("ID de passiva duplicado: %s." % passive_id)
		else:
			ids[passive_id] = true
		for field: String in ["name", "description", "condition"]:
			if String(definition.get(field, "")).strip_edges().is_empty():
				errors.append("%s sem %s." % [passive_id, field])
	return {
		"success": errors.is_empty(),
		"count": PASSIVES.size(),
		"errors": errors
	}


static func _set_active(result: Dictionary, text: String) -> void:
	result["active"] = true
	result["state"] = "active"
	result["status_text"] = text


static func _set_conditional(result: Dictionary, text: String) -> void:
	result["active"] = false
	result["state"] = "conditional"
	result["status_text"] = text


static func _shuffle_dictionary_array(
	values: Array[Dictionary],
	rng: RandomNumberGenerator
) -> void:
	for index: int in range(values.size() - 1, 0, -1):
		var swap_index: int = rng.randi_range(0, index)
		var temporary: Dictionary = values[index]
		values[index] = values[swap_index]
		values[swap_index] = temporary
