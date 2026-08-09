class_name VillageBuildingVariantCatalog
extends RefCounted


const FINAL_LEVEL: int = 3

const VARIANTS: Array[Dictionary] = [
	{
		"id": "silo_reserve",
		"building_id": "barn",
		"name": "Silo de Reserva",
		"short_name": "SILO",
		"identity": "Especialização focada em volume e proteção das reservas.",
		"event_hint": "Pode proteger estoques durante tempestades e ventos de colheita.",
		"effect_text": "+40% na produção de alimentação e opções próprias para proteger estoques.",
		"effects": {
			"food_production_bonus": 0.40
		},
		"visual_id": "barn_silo",
		"preview_path": "res://assets/buildings/variants/barn_silo.png",
		"preferred_npc_id": "rubra_meio_demonia",
		"dialogue_id": "building_variant_barn_silo_rubra",
		"fallback_dialogue_id": "building_variant_barn_silo_mimo",
		"event_interaction_ids": [
			"variant_silo_storm",
			"variant_silo_harvest_winds"
		]
	},
	{
		"id": "community_kitchen",
		"building_id": "barn",
		"name": "Cozinha Comunitária",
		"short_name": "COZINHA",
		"identity": "Transforma parte do celeiro em cozinha coletiva e ponto de encontro.",
		"event_hint": "Pode alimentar moradores em ondas de calor e festivais.",
		"effect_text": "+28% na produção de alimentação, -0,75 de consumo diário e +0,25 de felicidade por dia.",
		"effects": {
			"food_production_bonus": 0.28,
			"fixed_food_consumption_reduction": 0.75,
			"daily_happiness_bonus": 0.25
		},
		"visual_id": "barn_kitchen",
		"preview_path": "res://assets/buildings/variants/barn_kitchen.png",
		"preferred_npc_id": "brunna_ana_barbara",
		"dialogue_id": "building_variant_barn_kitchen_brunna",
		"fallback_dialogue_id": "building_variant_barn_kitchen_mimo",
		"event_interaction_ids": [
			"variant_kitchen_heat_wave",
			"variant_kitchen_harvest_festival"
		]
	},
	{
		"id": "intensive_sawmill",
		"building_id": "sawmill",
		"name": "Serraria Intensiva",
		"short_name": "SERRARIA INTENSIVA",
		"identity": "Prioriza rendimento máximo de madeira, pedra e peças brutas.",
		"event_hint": "Pode fornecer material em pontes danificadas e estradas de inverno.",
		"effect_text": "+44% na produção de material e respostas de grande escala em obras emergenciais.",
		"effects": {
			"material_production_bonus": 0.44
		},
		"visual_id": "sawmill_intensive",
		"preview_path": "res://assets/buildings/variants/sawmill_intensive.png",
		"preferred_npc_id": "aelric_ferreiro",
		"dialogue_id": "building_variant_sawmill_intensive_aelric",
		"fallback_dialogue_id": "building_variant_sawmill_intensive_mimo",
		"event_interaction_ids": [
			"variant_intensive_bridge",
			"variant_intensive_winter_road"
		]
	},
	{
		"id": "carpentry_workshop",
		"building_id": "sawmill",
		"name": "Oficina de Carpintaria",
		"short_name": "OFICINA",
		"identity": "Troca parte do rendimento bruto por peças precisas e planejamento.",
		"event_hint": "Pode criar peças precisas para enchentes e caravanas.",
		"effect_text": "+30% na produção de material e -10% no custo de futuras obras.",
		"effects": {
			"material_production_bonus": 0.30,
			"construction_cost_reduction": 0.10
		},
		"visual_id": "sawmill_carpentry",
		"preview_path": "res://assets/buildings/variants/sawmill_carpentry.png",
		"preferred_npc_id": "aelric_ferreiro",
		"dialogue_id": "building_variant_sawmill_carpentry_aelric",
		"fallback_dialogue_id": "building_variant_sawmill_carpentry_mimo",
		"event_interaction_ids": [
			"variant_carpentry_flood",
			"variant_carpentry_caravan"
		]
	},
	{
		"id": "deep_reservoir",
		"building_id": "well",
		"name": "Reservatório Profundo",
		"short_name": "RESERVATÓRIO",
		"identity": "Protege o abastecimento e reduz o desgaste coletivo.",
		"event_hint": "Pode garantir água segura contra contaminação e espíritos de gelo.",
		"effect_text": "-40% na redução diária de felicidade e opções seguras em crises de água.",
		"effects": {
			"happiness_decay_reduction": 0.40
		},
		"visual_id": "well_reservoir",
		"preview_path": "res://assets/buildings/variants/well_reservoir.png",
		"preferred_npc_id": "orion_draconato",
		"dialogue_id": "building_variant_well_reservoir_orion",
		"fallback_dialogue_id": "building_variant_well_reservoir_mimo",
		"event_interaction_ids": [
			"variant_reservoir_contamination",
			"variant_reservoir_frost_spirit"
		]
	},
	{
		"id": "community_fountain",
		"building_id": "well",
		"name": "Fonte Comunitária",
		"short_name": "FONTE",
		"identity": "Transforma água limpa em espaço de descanso e convivência.",
		"event_hint": "Pode aliviar ondas de calor e acolher apresentações na praça.",
		"effect_text": "-25% na redução diária de felicidade e +0,65 de felicidade por dia.",
		"effects": {
			"happiness_decay_reduction": 0.25,
			"daily_happiness_bonus": 0.65
		},
		"visual_id": "well_fountain",
		"preview_path": "res://assets/buildings/variants/well_fountain.png",
		"preferred_npc_id": "orion_draconato",
		"dialogue_id": "building_variant_well_fountain_orion",
		"fallback_dialogue_id": "building_variant_well_fountain_mimo",
		"event_interaction_ids": [
			"variant_fountain_heat_wave",
			"variant_fountain_bard"
		]
	},
	{
		"id": "community_market",
		"building_id": "square",
		"name": "Mercado Comunitário",
		"short_name": "MERCADO",
		"identity": "Faz da praça um centro regular de trocas e abastecimento.",
		"event_hint": "Pode abrir negociações próprias com mercadores e disputas comerciais.",
		"effect_text": "+1,3 de felicidade por dia e +4% na produção de alimentação e material.",
		"effects": {
			"daily_happiness_bonus": 1.30,
			"food_production_bonus": 0.04,
			"material_production_bonus": 0.04
		},
		"visual_id": "square_market",
		"preview_path": "res://assets/buildings/variants/square_market.png",
		"preferred_npc_id": "kobi_mercante",
		"dialogue_id": "building_variant_square_market_kobi",
		"fallback_dialogue_id": "building_variant_square_market_mimo",
		"event_interaction_ids": [
			"variant_market_merchant",
			"variant_market_dispute"
		]
	},
	{
		"id": "public_garden",
		"building_id": "square",
		"name": "Jardim Público",
		"short_name": "JARDIM",
		"identity": "Transforma a praça em área verde para repouso e celebrações.",
		"event_hint": "Pode fortalecer festivais e proteger polinizadores mágicos.",
		"effect_text": "+2,3 de felicidade por dia e soluções comunitárias em acontecimentos.",
		"effects": {
			"daily_happiness_bonus": 2.30
		},
		"visual_id": "square_garden",
		"preview_path": "res://assets/buildings/variants/square_garden.png",
		"preferred_npc_id": "rubra_meio_demonia",
		"dialogue_id": "building_variant_square_garden_rubra",
		"fallback_dialogue_id": "building_variant_square_garden_mimo",
		"event_interaction_ids": [
			"variant_garden_festival",
			"variant_garden_pollinators"
		]
	},
	{
		"id": "stone_bastion",
		"building_id": "palisade",
		"name": "Bastião de Pedra",
		"short_name": "BASTIÃO",
		"identity": "Concentra pedra e mão de obra em defesa física duradoura.",
		"event_hint": "Pode absorver ameaças nos portões e danos das estradas de inverno.",
		"effect_text": "-46% no custo diário de manutenção e opções de proteção pesada.",
		"effects": {
			"maintenance_reduction": 0.46
		},
		"visual_id": "palisade_bastion",
		"preview_path": "res://assets/buildings/variants/palisade_bastion.png",
		"preferred_npc_id": "brunna_ana_barbara",
		"dialogue_id": "building_variant_palisade_bastion_brunna",
		"fallback_dialogue_id": "building_variant_palisade_bastion_mimo",
		"event_interaction_ids": [
			"variant_bastion_gate",
			"variant_bastion_winter_road"
		]
	},
	{
		"id": "vigilant_gates",
		"building_id": "palisade",
		"name": "Portões Vigilantes",
		"short_name": "PORTÕES",
		"identity": "Prefere observação, resposta rápida e controle de entrada.",
		"event_hint": "Pode antecipar visitantes suspeitos e invasões de animais.",
		"effect_text": "-32% no custo diário de manutenção e opções preventivas contra ameaças.",
		"effects": {
			"maintenance_reduction": 0.32
		},
		"visual_id": "palisade_gates",
		"preview_path": "res://assets/buildings/variants/palisade_gates.png",
		"preferred_npc_id": "brunna_ana_barbara",
		"dialogue_id": "building_variant_palisade_gates_brunna",
		"fallback_dialogue_id": "building_variant_palisade_gates_mimo",
		"event_interaction_ids": [
			"variant_gates_stranger",
			"variant_gates_boar"
		]
	}
]


static func get_variants_for_building(building_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for variant: Dictionary in VARIANTS:
		if String(variant.get("building_id", "")) == building_id:
			result.append(variant.duplicate(true))
	return result


static func get_variant(variant_id: String) -> Dictionary:
	for variant: Dictionary in VARIANTS:
		if String(variant.get("id", "")) == variant_id:
			return variant.duplicate(true)
	return {}


static func is_valid_for_building(variant_id: String, building_id: String) -> bool:
	var variant: Dictionary = get_variant(variant_id)
	return (
		not variant.is_empty()
		and String(variant.get("building_id", "")) == building_id
	)


static func get_effects(variant_id: String) -> Dictionary:
	var variant: Dictionary = get_variant(variant_id)
	var effects_value: Variant = variant.get("effects", {})
	return (
		(effects_value as Dictionary).duplicate(true)
		if effects_value is Dictionary
		else {}
	)


static func validate_catalog() -> Dictionary:
	var errors: Array[String] = []
	var ids: Dictionary = {}
	var counts: Dictionary = {}
	for variant: Dictionary in VARIANTS:
		var variant_id: String = String(variant.get("id", ""))
		var building_id: String = String(variant.get("building_id", ""))
		if variant_id.is_empty():
			errors.append("Variante sem ID.")
		elif ids.has(variant_id):
			errors.append("Variante duplicada: %s." % variant_id)
		else:
			ids[variant_id] = true
		if building_id.is_empty():
			errors.append("%s não informa construção." % variant_id)
		counts[building_id] = int(counts.get(building_id, 0)) + 1
		if String(variant.get("name", "")).is_empty():
			errors.append("%s não possui nome." % variant_id)
		if String(variant.get("effect_text", "")).is_empty():
			errors.append("%s não descreve o efeito." % variant_id)
		if not variant.get("effects", {}) is Dictionary:
			errors.append("%s não possui efeitos válidos." % variant_id)
	for building_id: String in ["barn", "sawmill", "well", "square", "palisade"]:
		if int(counts.get(building_id, 0)) != 2:
			errors.append("%s precisa de exatamente duas variantes." % building_id)
	return {
		"success": errors.is_empty(),
		"variants": VARIANTS.size(),
		"errors": errors
	}
