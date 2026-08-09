class_name CouncilCardCatalog
extends RefCounted


const PASSIVE_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncilPassiveCatalog.gd"
)


const ATTRIBUTE_TOTAL: int = 10
const ATTRIBUTE_MINIMUM: int = 1
const ATTRIBUTE_INITIAL_MAXIMUM: int = 5
const STARTING_LEVEL: int = 1
const STARTING_XP: int = 0

const SPECIES_NAMES: Dictionary = {
	"Passos-Leves": [
		"Nilo Brisa-Mansa",
		"Tiri Musgo-Claro",
		"Luma Pata-Leve",
		"Pico Trilha-Fina",
		"Vela Dedo-Ágil",
		"Rino Salta-Orvalho"
	],
	"Elfo": [
		"Elarin Vale-Luz",
		"Sylwen Folha-Prata",
		"Caelor Vento-Sereno",
		"Ilyra Alba-Raiz",
		"Thaelis Lua-Verde",
		"Nymor Galho-Dourado"
	],
	"Anã": [
		"Dagna Pedra-Firme",
		"Rurik Martelo-Bronze",
		"Helga Forja-Clara",
		"Bromm Rocha-Funda",
		"Nóra Brasa-Curta",
		"Thordin Cobre-Rijo"
	],
	"Draconato": [
		"Varkesh Brasagelo",
		"Saryx Escama-Forte",
		"Kaeroth Cinza-Rubro",
		"Myrka Dente-de-Ferro",
		"Tharok Chama-Longa",
		"Zerath Pedra-Ígnea"
	],
	"Meio-demônia": [
		"Seris Umbra-Rubra",
		"Velka Noite-Branda",
		"Malek Véspera-Cinza",
		"Nyra Brasa-Viva",
		"Dária Sombra-Mansa",
		"Iskrael Véu-Escarlate"
	],
	"Kobold": [
		"Rikki Cobre-Rápido",
		"Tika Engreninha",
		"Biko Faísca-Torta",
		"Nix Latão-Leve",
		"Krell Garra-de-Lona",
		"Zupi Parafuso-Curto"
	],
	"Bruxa": [
		"Amara Erva-Lume",
		"Círia Caldeirão-Manso",
		"Elowen Lua-de-Sálvia",
		"Mirta Ramo-Rubro",
		"Selene Bruma-Verde",
		"Tália Fio-de-Alecrim"
	],
	"Meio-vampiro": [
		"Dorian Véu-Carmesim",
		"Lysander Noite-Clara",
		"Véspera Rosa-Negra",
		"Mirel Lua-Pálida",
		"Caio Sombra-Viva",
		"Nádia Sangue-de-Orvalho"
	]
}

const SPECIES_ID_TO_NAME: Dictionary = {
	"passos_leves": "Passos-Leves",
	"elfo": "Elfo",
	"ana": "Anã",
	"draconato": "Draconato",
	"meio_demonia": "Meio-demônia",
	"kobold": "Kobold",
	"bruxa": "Bruxa",
	"meio_vampiro": "Meio-vampiro"
}

const SPECIES_PORTRAIT_IDS: Dictionary = {
	"Passos-Leves": [
		"passos_leves_andarilho",
		"passos_leves_artifice",
		"passos_leves_batedor",
		"felix_pescador",
		"lumi_cozinheira",
		"passos_leves_bolseiro",
		"passos_leves_cronista"
	],
	"Elfo": ["carta_elfo_homem", "carta_elfo_mulher"],
	"Anã": ["carta_ana_homem", "carta_ana_mulher"],
	"Draconato": ["carta_draconato_homem", "carta_draconato_mulher"],
	"Meio-demônia": [
		"carta_meio_demonio_homem",
		"carta_meio_demonio_mulher"
	],
	"Kobold": ["carta_kobold_homem", "carta_kobold_mulher"],
	"Bruxa": ["carta_bruxo_homem", "carta_bruxa_mulher"],
	"Meio-vampiro": [
		"carta_meio_vampiro_homem",
		"carta_meio_vampiro_mulher"
	]
}



static func create_rng(seed_value: int) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = maxi(1, seed_value)
	return rng


static func get_unique_names(
	species_name: String,
	count: int,
	rng: RandomNumberGenerator,
	excluded_names: Array[String] = []
) -> Array[String]:
	var pool: Array[String] = []
	var source_value: Variant = SPECIES_NAMES.get(species_name, [])
	if source_value is Array:
		for value: Variant in source_value as Array:
			var name_value: String = String(value).strip_edges()
			if (
				not name_value.is_empty()
				and not excluded_names.has(name_value)
			):
				pool.append(name_value)
	_shuffle_with_rng(pool, rng)
	var result: Array[String] = []
	for index: int in range(mini(count, pool.size())):
		result.append(pool[index])
	return result


static func get_species_name_from_id(species_id: String) -> String:
	return String(SPECIES_ID_TO_NAME.get(species_id, ""))


static func get_portrait_ids(species_name: String) -> Array[String]:
	var result: Array[String] = []
	var source_value: Variant = SPECIES_PORTRAIT_IDS.get(species_name, [])
	if source_value is Array:
		for value: Variant in source_value as Array:
			var portrait_id: String = String(value).strip_edges()
			if not portrait_id.is_empty():
				result.append(portrait_id)
	return result


static func has_recruitment_pool(species_name: String) -> bool:
	var names_value: Variant = SPECIES_NAMES.get(species_name, [])
	return (
		names_value is Array
		and (names_value as Array).size() >= 2
		and get_portrait_ids(species_name).size() >= 2
	)


static func get_randomized_passives(
	count: int,
	rng: RandomNumberGenerator,
	excluded_ids: Array[String] = []
) -> Array[Dictionary]:
	return PASSIVE_CATALOG_SCRIPT.get_randomized_passives(
		count,
		rng,
		excluded_ids
	)



static func generate_attributes(
	rng: RandomNumberGenerator
) -> Dictionary:
	var values: Array[int] = [
		ATTRIBUTE_MINIMUM,
		ATTRIBUTE_MINIMUM,
		ATTRIBUTE_MINIMUM,
		ATTRIBUTE_MINIMUM
	]
	var remaining: int = ATTRIBUTE_TOTAL - values.size() * ATTRIBUTE_MINIMUM
	while remaining > 0:
		var available_indices: Array[int] = []
		for index: int in range(values.size()):
			if values[index] < ATTRIBUTE_INITIAL_MAXIMUM:
				available_indices.append(index)
		if available_indices.is_empty():
			break
		var selected_index: int = available_indices[
			rng.randi_range(0, available_indices.size() - 1)
		]
		values[selected_index] += 1
		remaining -= 1
	return {
		"strength": values[0],
		"intelligence": values[1],
		"charisma": values[2],
		"agility": values[3]
	}


static func xp_required_for_level(level: int) -> int:
	return 80 + 20 * maxi(0, level - 1)


static func validate_attribute_set(attributes: Dictionary) -> bool:
	var values: Array[int] = [
		int(attributes.get("strength", 0)),
		int(attributes.get("intelligence", 0)),
		int(attributes.get("charisma", 0)),
		int(attributes.get("agility", 0))
	]
	var total: int = 0
	for value: int in values:
		if value < ATTRIBUTE_MINIMUM or value > ATTRIBUTE_INITIAL_MAXIMUM:
			return false
		total += value
	return total == ATTRIBUTE_TOTAL


static func _shuffle_with_rng(
	values: Array[String],
	rng: RandomNumberGenerator
) -> void:
	for index: int in range(values.size() - 1, 0, -1):
		var swap_index: int = rng.randi_range(0, index)
		var temporary: String = values[index]
		values[index] = values[swap_index]
		values[swap_index] = temporary


static func _shuffle_dictionary_array_with_rng(
	values: Array[Dictionary],
	rng: RandomNumberGenerator
) -> void:
	for index: int in range(values.size() - 1, 0, -1):
		var swap_index: int = rng.randi_range(0, index)
		var temporary: Dictionary = values[index]
		values[index] = values[swap_index]
		values[swap_index] = temporary


static func add_progression_attribute_points(
	attributes: Dictionary,
	points: int,
	rng: RandomNumberGenerator,
	maximum_value: int = 8
) -> Dictionary:
	var result: Dictionary = attributes.duplicate(true)
	var remaining: int = maxi(0, points)
	while remaining > 0:
		var available: Array[String] = []
		for attribute_id: String in [
			"strength",
			"intelligence",
			"charisma",
			"agility"
		]:
			if int(result.get(attribute_id, 1)) < maximum_value:
				available.append(attribute_id)
		if available.is_empty():
			break
		var selected: String = available[
			rng.randi_range(0, available.size() - 1)
		]
		result[selected] = int(result.get(selected, 1)) + 1
		remaining -= 1
	return result
