class_name VillageCampaignIdentityCatalog
extends RefCounted


const GENERATOR_VERSION: int = 1
const MAX_SEED: int = 2147483646
const MAX_VILLAGE_NAME_LENGTH: int = 32

const NAME_PREFIXES: Array[String] = [
	"Vila",
	"Refúgio",
	"Mandato",
	"Vale",
	"Povoado",
	"Comunidade"
]

const NAME_SUFFIXES: Array[String] = [
	"da Brasa Clara",
	"das Quatro Estações",
	"do Carvalho",
	"da Pedra Viva",
	"das Lanternas",
	"do Riacho",
	"da Colheita",
	"do Horizonte"
]


static func generate_seed() -> int:
	var generated: int = int(Time.get_unix_time_from_system())
	generated = generated * 1000 + int(Time.get_ticks_msec() % 1000)
	return sanitize_seed(generated)


static func seed_from_text(value: String) -> int:
	var clean_text: String = value.strip_edges()
	if clean_text.is_empty():
		return generate_seed()
	if clean_text.is_valid_int():
		return sanitize_seed(int(clean_text))

	# Hash próprio e estável: não depende do hash interno do motor.
	var result: int = 17
	for index: int in range(clean_text.length()):
		result = int(
			(result * 31 + clean_text.unicode_at(index))
			% MAX_SEED
		)
	return sanitize_seed(result)


static func sanitize_seed(value: int) -> int:
	var positive: int = absi(value)
	if positive < 1:
		positive = 1
	return ((positive - 1) % MAX_SEED) + 1


static func suggest_village_name(seed_value: int) -> String:
	var sanitized_seed: int = sanitize_seed(seed_value)
	var prefix_index: int = sanitized_seed % NAME_PREFIXES.size()
	var suffix_index: int = (
		floori(float(sanitized_seed) / float(NAME_PREFIXES.size()))
		% NAME_SUFFIXES.size()
	)
	return "%s %s" % [
		NAME_PREFIXES[prefix_index],
		NAME_SUFFIXES[suffix_index]
	]


static func sanitize_village_name(value: String, seed_value: int) -> String:
	var clean_name: String = value.strip_edges()
	if clean_name.is_empty():
		clean_name = suggest_village_name(seed_value)
	if clean_name.length() > MAX_VILLAGE_NAME_LENGTH:
		clean_name = clean_name.substr(0, MAX_VILLAGE_NAME_LENGTH)
	return clean_name
