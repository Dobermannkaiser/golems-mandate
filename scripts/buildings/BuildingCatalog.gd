class_name VillageBuildingCatalog
extends RefCounted


# O catálogo contém somente dados. As regras de compra e os efeitos
# permanentes ficam em BuildingManager.gd.
static func create() -> Array[Dictionary]:
	var buildings: Array[Dictionary] = []

	buildings.append(
		{
			"id": "barn",
			"name": "Celeiro",
			"short_name": "CELEIRO",
			"flavor": (
				"Armazena e preserva melhor cada colheita."
			),
			"effect_key": "food_production_bonus",
			"color": "#B98A4A",
			"levels": [
				{
					"level": 1,
					"title": "Depósito de Grãos",
					"cost": 6.0,
					"value": 0.10,
					"effect_text": (
						"+10% na produção de alimentação."
					)
				},
				{
					"level": 2,
					"title": "Celeiro Reforçado",
					"cost": 11.0,
					"value": 0.22,
					"effect_text": (
						"+22% na produção de alimentação."
					)
				},
				{
					"level": 3,
					"title": "Grande Celeiro",
					"cost": 18.0,
					"value": 0.35,
					"effect_text": (
						"+35% na produção de alimentação."
					)
				}
			]
		}
	)

	buildings.append(
		{
			"id": "sawmill",
			"name": "Serraria",
			"short_name": "SERRARIA",
			"flavor": (
				"Transforma madeira e minério em peças úteis."
			),
			"effect_key": "material_production_bonus",
			"color": "#A46745",
			"levels": [
				{
					"level": 1,
					"title": "Bancada de Corte",
					"cost": 8.0,
					"value": 0.12,
					"effect_text": (
						"+12% na produção de material."
					)
				},
				{
					"level": 2,
					"title": "Serraria Comunitária",
					"cost": 13.0,
					"value": 0.25,
					"effect_text": (
						"+25% na produção de material."
					)
				},
				{
					"level": 3,
					"title": "Oficina de Madeira",
					"cost": 20.0,
					"value": 0.40,
					"effect_text": (
						"+40% na produção de material."
					)
				}
			]
		}
	)

	buildings.append(
		{
			"id": "well",
			"name": "Poço",
			"short_name": "POÇO",
			"flavor": (
				"Água limpa torna a rotina menos desgastante."
			),
			"effect_key": "happiness_decay_reduction",
			"color": "#5C8C8C",
			"levels": [
				{
					"level": 1,
					"title": "Poço Raso",
					"cost": 5.0,
					"value": 0.10,
					"effect_text": (
						"-10% na redução diária de felicidade."
					)
				},
				{
					"level": 2,
					"title": "Poço de Pedra",
					"cost": 10.0,
					"value": 0.22,
					"effect_text": (
						"-22% na redução diária de felicidade."
					)
				},
				{
					"level": 3,
					"title": "Fonte Comunitária",
					"cost": 16.0,
					"value": 0.35,
					"effect_text": (
						"-35% na redução diária de felicidade."
					)
				}
			]
		}
	)

	buildings.append(
		{
			"id": "square",
			"name": "Praça",
			"short_name": "PRAÇA",
			"flavor": (
				"Um lugar seguro para encontros e celebrações."
			),
			"effect_key": "daily_happiness_bonus",
			"color": "#7E9258",
			"levels": [
				{
					"level": 1,
					"title": "Pátio Comunal",
					"cost": 7.0,
					"value": 0.6,
					"effect_text": (
						"+0,6 de felicidade por dia."
					)
				},
				{
					"level": 2,
					"title": "Praça da Vila",
					"cost": 12.0,
					"value": 1.3,
					"effect_text": (
						"+1,3 de felicidade por dia."
					)
				},
				{
					"level": 3,
					"title": "Praça do Festival",
					"cost": 18.0,
					"value": 2.1,
					"effect_text": (
						"+2,1 de felicidade por dia."
					)
				}
			]
		}
	)

	buildings.append(
		{
			"id": "palisade",
			"name": "Muralha",
			"short_name": "MURALHA",
			"flavor": (
				"Protege casas e reduz reparos emergenciais."
			),
			"effect_key": "maintenance_reduction",
			"color": "#77726B",
			"levels": [
				{
					"level": 1,
					"title": "Cerca Reforçada",
					"cost": 9.0,
					"value": 0.12,
					"effect_text": (
						"-12% no custo diário de manutenção."
					)
				},
				{
					"level": 2,
					"title": "Paliçada de Madeira",
					"cost": 15.0,
					"value": 0.25,
					"effect_text": (
						"-25% no custo diário de manutenção."
					)
				},
				{
					"level": 3,
					"title": "Muralha da Comunidade",
					"cost": 22.0,
					"value": 0.40,
					"effect_text": (
						"-40% no custo diário de manutenção."
					)
				}
			]
		}
	)

	return buildings
