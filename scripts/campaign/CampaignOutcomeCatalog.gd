class_name VillageCampaignOutcomeCatalog
extends RefCounted


const MEDALS: Array[Dictionary] = [
	{
		"id": "sustento_da_vila",
		"name": "Sustento da Vila",
		"description": "Maior contribuição de alimentação no período.",
		"metric": "food"
	},
	{
		"id": "maos_a_obra",
		"name": "Mãos à Obra",
		"description": "Maior contribuição de material no período.",
		"metric": "material"
	},
	{
		"id": "coracao_da_comunidade",
		"name": "Coração da Comunidade",
		"description": "Maior contribuição direta de felicidade.",
		"metric": "happiness"
	},
	{
		"id": "espirito_versatil",
		"name": "Espírito Versátil",
		"description": "Atuou de forma relevante em mais profissões.",
		"metric": "profession_variety"
	},
	{
		"id": "guarda_nas_horas_dificeis",
		"name": "Guarda nas Horas Difíceis",
		"description": "Contribuiu nos dias em que a vila enfrentou escassez.",
		"metric": "crisis_output"
	},
	{
		"id": "voz_da_conciliacao",
		"name": "Voz da Conciliação",
		"description": "Participou de acontecimentos e projetos do Conselho.",
		"metric": "resolved_actions"
	},
	{
		"id": "companheiro_leal",
		"name": "Companheiro Leal",
		"description": "Permaneceu mais dias atuando no Conselho.",
		"metric": "active_days"
	},
	{
		"id": "virada_decisiva",
		"name": "Virada Decisiva",
		"description": "Teve a maior contribuição direta no dia da avaliação.",
		"metric": "checkpoint_output"
	}
]

const PROFILES: Dictionary = {
	"administracao_comunitaria": {
		"id": "administracao_comunitaria",
		"name": "Administração Comunitária",
		"description": "A vila cresceu preservando felicidade, diversidade de trabalho e vínculos."
	},
	"vila_prospera": {
		"id": "vila_prospera",
		"name": "Vila Próspera",
		"description": "Produção, reservas e população avançaram com poucos períodos de escassez."
	},
	"conselho_resiliente": {
		"id": "conselho_resiliente",
		"name": "Conselho Resiliente",
		"description": "A comunidade atravessou crises reais e conseguiu recuperar sua estabilidade."
	},
	"crescimento_arriscado": {
		"id": "crescimento_arriscado",
		"name": "Crescimento Arriscado",
		"description": "A vila cresceu depressa, aceitando reservas apertadas e períodos de tensão."
	},
	"diplomacia_exemplar": {
		"id": "diplomacia_exemplar",
		"name": "Diplomacia Exemplar",
		"description": "Relações positivas e decisões conciliadoras marcaram a campanha."
	},
	"administracao_equilibrada": {
		"id": "administracao_equilibrada",
		"name": "Administração Equilibrada",
		"description": "A campanha combinou produção, cuidado e adaptação sem depender de um único caminho."
	}
}


static func get_medal(medal_id: String) -> Dictionary:
	for medal: Dictionary in MEDALS:
		if String(medal.get("id", "")) == medal_id:
			return medal.duplicate(true)
	return {}


static func select_behavior_medals(
	metrics_by_councillor: Dictionary
) -> Array[Dictionary]:
	var maximum_by_metric: Dictionary = {}
	for medal: Dictionary in MEDALS:
		var metric_id: String = String(medal.get("metric", ""))
		var maximum: float = 0.0
		for metrics_value: Variant in metrics_by_councillor.values():
			if metrics_value is Dictionary:
				maximum = maxf(
					maximum,
					float((metrics_value as Dictionary).get(metric_id, 0.0))
				)
		maximum_by_metric[metric_id] = maximum

	var candidates: Array[Dictionary] = []
	for representative_id_value: Variant in metrics_by_councillor.keys():
		var representative_id: String = String(representative_id_value)
		var metrics_value: Variant = metrics_by_councillor.get(representative_id, {})
		if representative_id.is_empty() or not metrics_value is Dictionary:
			continue
		var metrics: Dictionary = metrics_value as Dictionary
		if int(metrics.get("active_days", 0)) <= 0:
			continue
		for medal_index: int in range(MEDALS.size()):
			var medal: Dictionary = MEDALS[medal_index]
			var metric_id: String = String(medal.get("metric", ""))
			var raw_value: float = float(metrics.get(metric_id, 0.0))
			var maximum: float = float(maximum_by_metric.get(metric_id, 0.0))
			if raw_value <= 0.001 or maximum <= 0.001:
				continue
			candidates.append({
				"representative_id": representative_id,
				"display_name": String(metrics.get("display_name", "Conselheiro")),
				"medal_index": medal_index,
				"normalized_score": raw_value / maximum,
				"raw_value": raw_value
			})

	candidates.sort_custom(_sort_medal_candidate)
	var assigned_councillors: Dictionary = {}
	var assigned_medals: Dictionary = {}
	var result: Array[Dictionary] = []
	for candidate: Dictionary in candidates:
		var representative_id: String = String(candidate.get("representative_id", ""))
		var medal_index: int = int(candidate.get("medal_index", -1))
		if medal_index < 0 or medal_index >= MEDALS.size():
			continue
		var medal: Dictionary = MEDALS[medal_index]
		var medal_id: String = String(medal.get("id", ""))
		if assigned_councillors.has(representative_id) or assigned_medals.has(medal_id):
			continue
		var award: Dictionary = medal.duplicate(true)
		award["representative_id"] = representative_id
		award["display_name"] = String(candidate.get("display_name", "Conselheiro"))
		award["metric_value"] = float(candidate.get("raw_value", 0.0))
		result.append(award)
		assigned_councillors[representative_id] = true
		assigned_medals[medal_id] = true

	result.sort_custom(_sort_award_by_name)
	return result


static func select_campaign_profile(statistics: Dictionary) -> Dictionary:
	var status: String = String(statistics.get("status", "active"))
	var average_happiness: float = float(statistics.get("average_happiness", 0.0))
	var lowest_happiness: float = float(statistics.get("lowest_happiness", 100.0))
	var crisis_days: int = int(statistics.get("crisis_days", 0))
	var shortage_days: int = int(statistics.get("shortage_days", 0))
	var max_population: int = int(statistics.get("maximum_population", 0))
	var profession_variety: int = int(statistics.get("profession_variety", 0))
	var positive_pairs: int = int(statistics.get("positive_npc_pairs", 0))
	var resolved_actions: int = int(statistics.get("resolved_relationship_actions", 0))

	var profile_id: String = "administracao_equilibrada"
	if positive_pairs >= 10 and resolved_actions >= 6:
		profile_id = "diplomacia_exemplar"
	elif max_population >= 32 and (lowest_happiness < 40.0 or shortage_days >= 5):
		profile_id = "crescimento_arriscado"
	elif status == "victory" and crisis_days >= 2:
		profile_id = "conselho_resiliente"
	elif average_happiness >= 65.0 and profession_variety >= 4:
		profile_id = "administracao_comunitaria"
	elif max_population >= 32 and shortage_days <= 2:
		profile_id = "vila_prospera"

	return (PROFILES[profile_id] as Dictionary).duplicate(true)


static func _sort_medal_candidate(a: Dictionary, b: Dictionary) -> bool:
	var a_score: float = float(a.get("normalized_score", 0.0))
	var b_score: float = float(b.get("normalized_score", 0.0))
	if not is_equal_approx(a_score, b_score):
		return a_score > b_score
	var a_medal: int = int(a.get("medal_index", 999))
	var b_medal: int = int(b.get("medal_index", 999))
	if a_medal != b_medal:
		return a_medal < b_medal
	return String(a.get("representative_id", "")) < String(b.get("representative_id", ""))


static func _sort_award_by_name(a: Dictionary, b: Dictionary) -> bool:
	return String(a.get("display_name", "")) < String(b.get("display_name", ""))
