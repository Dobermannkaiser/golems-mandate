class_name VillageBuildingVariantEventCatalog
extends RefCounted


const INTERACTIONS: Array[Dictionary] = [
	{
		"event_id": "barn_storm",
		"choice": {
			"id": "variant_silo_storm",
			"title": "Selar os compartimentos do silo",
			"description": "Build — Silo de Reserva. Solução garantida; recupera 2 alimentos.",
			"required_building_variant": "silo_reserve",
			"effects": {"food": 2.0, "happiness": 2.0},
			"result_text": "Os compartimentos internos foram fechados antes que a chuva alcançasse as reservas."
		}
	},
	{
		"event_id": "autumn_harvest_winds",
		"choice": {
			"id": "variant_silo_harvest_winds",
			"title": "Recolher a colheita diretamente no silo",
			"description": "Build — Silo de Reserva. Ganha 8 alimentos sem teste.",
			"required_building_variant": "silo_reserve",
			"effects": {"food": 8.0},
			"result_text": "As carroças descarregaram sob cobertura e quase nada se perdeu para o vento."
		}
	},
	{
		"event_id": "summer_heat_wave",
		"choice": {
			"id": "variant_kitchen_heat_wave",
			"title": "Servir refeições frias na cozinha",
			"description": "Build — Cozinha Comunitária. Custa 2 alimentos e ganha 6 felicidade.",
			"required_building_variant": "community_kitchen",
			"costs": {"food": 2.0},
			"effects": {"happiness": 6.0},
			"result_text": "Mesas longas, água fresca e comida leve ajudaram a vila a atravessar o pior do calor."
		}
	},
	{
		"event_id": "harvest_festival",
		"choice": {
			"id": "variant_kitchen_harvest_festival",
			"title": "Preparar um banquete comunitário",
			"description": "Build — Cozinha Comunitária. Custa 4 alimentos e ganha 9 felicidade.",
			"required_building_variant": "community_kitchen",
			"costs": {"food": 4.0},
			"effects": {"happiness": 9.0},
			"result_text": "Cada família trouxe algo para as panelas, e a celebração terminou com nenhuma mesa vazia."
		}
	},
	{
		"event_id": "broken_bridge",
		"choice": {
			"id": "variant_intensive_bridge",
			"title": "Enviar vigas da serraria intensiva",
			"description": "Build — Serraria Intensiva. Custa 3 materiais e ganha 4 felicidade.",
			"required_building_variant": "intensive_sawmill",
			"costs": {"material": 3.0},
			"effects": {"happiness": 4.0},
			"result_text": "Vigas largas chegaram antes do anoitecer e sustentaram uma travessia mais forte que a anterior."
		}
	},
	{
		"event_id": "winter_blocked_road",
		"choice": {
			"id": "variant_intensive_winter_road",
			"title": "Montar passarelas de madeira",
			"description": "Build — Serraria Intensiva. Custa 2 materiais e evita perdas da carga.",
			"required_building_variant": "intensive_sawmill",
			"costs": {"material": 2.0},
			"effects": {"food": 4.0, "happiness": 2.0},
			"result_text": "As passarelas mantiveram carroças e moradores acima da neve acumulada."
		}
	},
	{
		"event_id": "spring_flooded_gardens",
		"choice": {
			"id": "variant_carpentry_flood",
			"title": "Instalar canais pré-montados",
			"description": "Build — Oficina de Carpintaria. Custa 2 materiais e recupera 5 alimentos.",
			"required_building_variant": "carpentry_workshop",
			"costs": {"material": 2.0},
			"effects": {"food": 5.0, "happiness": 2.0},
			"result_text": "Peças encaixadas na oficina conduziram a água para longe dos canteiros em poucas horas."
		}
	},
	{
		"event_id": "stuck_caravan",
		"choice": {
			"id": "variant_carpentry_caravan",
			"title": "Substituir o eixo na oficina",
			"description": "Build — Oficina de Carpintaria. Custa 1 material e recebe 5 alimentos.",
			"required_building_variant": "carpentry_workshop",
			"costs": {"material": 1.0},
			"effects": {"food": 5.0, "happiness": 2.0},
			"result_text": "Um novo eixo foi ajustado à carroça, e os viajantes agradeceram deixando parte da carga."
		}
	},
	{
		"event_id": "contaminated_well",
		"choice": {
			"id": "variant_reservoir_contamination",
			"title": "Isolar a cisterna contaminada",
			"description": "Build — Reservatório Profundo. Solução garantida; ganha 3 felicidade.",
			"required_building_variant": "deep_reservoir",
			"effects": {"happiness": 3.0},
			"result_text": "As comportas internas separaram a água limpa enquanto o trecho contaminado era esvaziado."
		}
	},
	{
		"event_id": "winter_frost_spirit",
		"choice": {
			"id": "variant_reservoir_frost_spirit",
			"title": "Oferecer a câmara fria do reservatório",
			"description": "Build — Reservatório Profundo. Ganha 8 felicidade.",
			"required_building_variant": "deep_reservoir",
			"effects": {"happiness": 8.0},
			"result_text": "O espírito encontrou abrigo junto à água profunda e deixou uma camada protetora de gelo sobre as pedras."
		}
	},
	{
		"event_id": "summer_heat_wave",
		"choice": {
			"id": "variant_fountain_heat_wave",
			"title": "Abrir a fonte para toda a vila",
			"description": "Build — Fonte Comunitária. Ganha 7 felicidade.",
			"required_building_variant": "community_fountain",
			"effects": {"happiness": 7.0},
			"result_text": "A praça virou ponto de descanso, e a água corrente tornou o calor suportável."
		}
	},
	{
		"event_id": "ghostly_bard",
		"choice": {
			"id": "variant_fountain_bard",
			"title": "Convidar o bardo para tocar junto à fonte",
			"description": "Build — Fonte Comunitária. Ganha 8 felicidade.",
			"required_building_variant": "community_fountain",
			"effects": {"happiness": 8.0},
			"result_text": "A água acompanhou a melodia e espalhou o refrão por toda a praça."
		}
	},
	{
		"event_id": "traveling_merchant",
		"choice": {
			"id": "variant_market_merchant",
			"title": "Abrir uma banca no mercado",
			"description": "Build — Mercado Comunitário. Troca 2 alimentos por 7 materiais.",
			"required_building_variant": "community_market",
			"costs": {"food": 2.0},
			"effects": {"material": 7.0},
			"result_text": "Com espaço, testemunhas e concorrência, o mercador aceitou termos melhores para a vila."
		}
	},
	{
		"event_id": "market_dispute",
		"choice": {
			"id": "variant_market_dispute",
			"title": "Aplicar as regras do mercado comunitário",
			"description": "Build — Mercado Comunitário. Solução garantida; ganha 5 felicidade.",
			"required_building_variant": "community_market",
			"effects": {"happiness": 5.0},
			"result_text": "Pesos públicos e registros claros encerraram a disputa sem expulsar nenhum comerciante."
		}
	},
	{
		"event_id": "harvest_festival",
		"choice": {
			"id": "variant_garden_festival",
			"title": "Celebrar no jardim público",
			"description": "Build — Jardim Público. Custa 2 alimentos e ganha 8 felicidade.",
			"required_building_variant": "public_garden",
			"costs": {"food": 2.0},
			"effects": {"happiness": 8.0},
			"result_text": "Flores, música e mesas sob as árvores transformaram a colheita em uma lembrança coletiva."
		}
	},
	{
		"event_id": "spring_pollinator_swarm",
		"choice": {
			"id": "variant_garden_pollinators",
			"title": "Conduzir o enxame ao jardim",
			"description": "Build — Jardim Público. Ganha 6 alimentos e 3 felicidade.",
			"required_building_variant": "public_garden",
			"effects": {"food": 6.0, "happiness": 3.0},
			"result_text": "As flores atraíram o enxame para longe das casas e fortaleceram os canteiros."
		}
	},
	{
		"event_id": "stranger_at_gate",
		"choice": {
			"id": "variant_bastion_gate",
			"title": "Receber o estranho sob guarda do bastião",
			"description": "Build — Bastião de Pedra. Solução segura; ganha 3 felicidade.",
			"required_building_variant": "stone_bastion",
			"effects": {"happiness": 3.0},
			"result_text": "A conversa aconteceu diante das muralhas, longe das casas e sem colocar moradores em risco."
		}
	},
	{
		"event_id": "winter_blocked_road",
		"choice": {
			"id": "variant_bastion_winter_road",
			"title": "Abrigar a carga no bastião",
			"description": "Build — Bastião de Pedra. Preserva a carga e ganha 3 materiais.",
			"required_building_variant": "stone_bastion",
			"effects": {"material": 3.0, "happiness": 2.0},
			"result_text": "Depósitos protegidos junto à muralha mantiveram a carga seca até a estrada reabrir."
		}
	},
	{
		"event_id": "stranger_at_gate",
		"choice": {
			"id": "variant_gates_stranger",
			"title": "Observar antes de abrir os portões",
			"description": "Build — Portões Vigilantes. Solução garantida; ganha 2 felicidade.",
			"required_building_variant": "vigilant_gates",
			"effects": {"happiness": 2.0},
			"result_text": "Os vigias confirmaram que o visitante vinha sozinho e a recepção ocorreu sem alarme."
		}
	},
	{
		"event_id": "wild_boar",
		"choice": {
			"id": "variant_gates_boar",
			"title": "Fechar a rota do javali",
			"description": "Build — Portões Vigilantes. Evita perdas e ganha 3 felicidade.",
			"required_building_variant": "vigilant_gates",
			"effects": {"happiness": 3.0},
			"result_text": "Sinais das torres guiaram os moradores, e os portões laterais conduziram o animal para longe da plantação."
		}
	}
]


static func apply_to_events(events: Array[Dictionary]) -> void:
	var by_id: Dictionary = {}
	for index: int in range(events.size()):
		var event_data: Dictionary = events[index]
		by_id[String(event_data.get("id", ""))] = index
	for interaction: Dictionary in INTERACTIONS:
		var event_id: String = String(interaction.get("event_id", ""))
		if not by_id.has(event_id):
			continue
		var event_index: int = int(by_id[event_id])
		var event_data: Dictionary = events[event_index]
		var choices_value: Variant = event_data.get("choices", [])
		if not choices_value is Array:
			continue
		var choices: Array = choices_value
		var choice_value: Variant = interaction.get("choice", {})
		if choice_value is Dictionary:
			var special_choice: Dictionary = (
				(choice_value as Dictionary).duplicate(true)
			)
			special_choice["is_build_variant_choice"] = true
			choices.append(special_choice)
			event_data["choices"] = choices
			events[event_index] = event_data


static func validate_catalog() -> Dictionary:
	var errors: Array[String] = []
	var choice_ids: Dictionary = {}
	var variant_counts: Dictionary = {}
	for interaction: Dictionary in INTERACTIONS:
		var choice: Dictionary = interaction.get("choice", {})
		var choice_id: String = String(choice.get("id", ""))
		var variant_id: String = String(
			choice.get("required_building_variant", "")
		)
		if choice_id.is_empty():
			errors.append("Interação de build sem ID.")
		elif choice_ids.has(choice_id):
			errors.append("Interação duplicada: %s." % choice_id)
		else:
			choice_ids[choice_id] = true
		if variant_id.is_empty():
			errors.append("%s não exige uma build." % choice_id)
		variant_counts[variant_id] = int(variant_counts.get(variant_id, 0)) + 1
	for variant_id: String in [
		"silo_reserve",
		"community_kitchen",
		"intensive_sawmill",
		"carpentry_workshop",
		"deep_reservoir",
		"community_fountain",
		"community_market",
		"public_garden",
		"stone_bastion",
		"vigilant_gates"
	]:
		if int(variant_counts.get(variant_id, 0)) < 2:
			errors.append("%s precisa de duas interações." % variant_id)
	return {
		"success": errors.is_empty(),
		"interactions": INTERACTIONS.size(),
		"errors": errors
	}
