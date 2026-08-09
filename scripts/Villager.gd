class_name Villager
extends Node2D


const COUNCIL_CARD_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncilCardCatalog.gd"
)

const MAX_LEVEL: int = 6
const MAX_ATTRIBUTE_VALUE: int = 8


signal profession_changed(new_profession: int)
signal council_status_changed(is_active: bool)
signal progression_changed(result: Dictionary)


enum Profession {
	UNASSIGNED,
	FARMER,
	BLACKSMITH,
	CIVIL_SERVANT,
	GUARD,
	GATHERER
}


const POSSIBLE_NAMES: Array[String] = [
	"Ana",
	"Bruno",
	"Clara",
	"Daniel",
	"Elisa",
	"Felipe",
	"Gabriela",
	"Henrique",
	"Isabela",
	"João",
	"Larissa",
	"Mateus",
	"Nina",
	"Otávio",
	"Paula",
	"Rafael",
	"Sofia",
	"Tiago",
	"Vitória",
	"Yuri",
	"Amora",
	"Bento",
	"Canela",
	"Dengo",
	"Estrela",
	"Fagulha",
	"Garoa",
	"Íris",
	"Jasmim",
	"Lua",
	"Mingau",
	"Nimbo",
	"Orvalho",
	"Pipoca",
	"Runa",
	"Salem",
	"Tâmara",
	"Umi",
	"Vésper",
	"Zéfiro"
]


@export var randomize_on_ready: bool = true
@export var representative_id: String = "representante"
@export var villager_name: String = "Habitante"
@export var species_name: String = "Passos-Leves"
@export var is_council_active: bool = true
@export var is_special_npc: bool = false
@export var is_recruited_card: bool = false
@export var specialization: int = Profession.UNASSIGNED
@export var passive_id: String = ""
@export var portrait_id: String = ""
@export var passive_name: String = "Sem passiva"
@export_multiline var passive_description: String = ""
@export var personality_id: String = "optimistic"
@export var personality_name: String = "Otimista"
@export_multiline var personality_description: String = ""
@export_range(1, 6, 1) var level: int = 1
@export_range(0, 10000, 1) var xp: int = 0
@export_range(0, 1000000, 1) var lifetime_xp: int = 0
@export_range(0, 10, 1) var unspent_attribute_points: int = 0
@export_range(0, 10, 1) var attribute_points_spent: int = 0
@export_range(0, 10000, 1) var profession_streak_days: int = 0
@export_range(0, 10000, 1) var profession_change_count: int = 0
@export_range(0, 10000, 1) var mediator_last_trigger_day: int = 0

@export_range(1, 8, 1) var strength: int = 1
@export_range(1, 8, 1) var intelligence: int = 1
@export_range(1, 8, 1) var charisma: int = 1
@export_range(1, 8, 1) var agility: int = 1

@export_enum(
	"Sem profissão",
	"Agricultor",
	"Ferreiro",
	"Servidor Público",
	"Guarda",
	"Coletor"
)
var current_profession: int = Profession.UNASSIGNED


@onready var body: ColorRect = $Body
@onready var name_label: Label = $NameLabel


var _random: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	if randomize_on_ready:
		_random.randomize()
		generate_random_data()

	visible = is_council_active
	_refresh_visual()

	# O próprio habitante se cadastra no sistema do jogo.
	GameManager.register_villager(self)


func _exit_tree() -> void:
	# Retira o habitante do cadastro quando ele sai da cena.
	GameManager.unregister_villager(self)


func generate_random_data() -> void:
	var names: Array[String] = COUNCIL_CARD_CATALOG_SCRIPT.get_unique_names(
		"Passos-Leves",
		1,
		_random
	)
	if not names.is_empty():
		villager_name = names[0]

	var attributes: Dictionary = (
		COUNCIL_CARD_CATALOG_SCRIPT.generate_attributes(_random)
	)
	strength = int(attributes.get("strength", 1))
	intelligence = int(attributes.get("intelligence", 1))
	charisma = int(attributes.get("charisma", 1))
	agility = int(attributes.get("agility", 1))
	level = COUNCIL_CARD_CATALOG_SCRIPT.STARTING_LEVEL
	xp = COUNCIL_CARD_CATALOG_SCRIPT.STARTING_XP
	current_profession = Profession.UNASSIGNED


func set_council_active(value: bool) -> void:
	if is_council_active == value:
		return
	is_council_active = value
	visible = value
	council_status_changed.emit(value)


func get_specialization_name() -> String:
	if passive_id == "faz_tudo":
		return "Polivalente"
	return get_profession_name(specialization)


func get_specialization_bonus() -> float:
	if passive_id == "faz_tudo":
		return 0.05 if current_profession != Profession.UNASSIGNED else 0.0
	if specialization == Profession.UNASSIGNED:
		return 0.0
	if specialization == current_profession:
		return 0.05
	return 0.0


func set_profession(new_profession: int) -> void:
	if (
		new_profession < Profession.UNASSIGNED
		or new_profession > Profession.GATHERER
	):
		push_warning("Foi recebida uma profissão inválida.")
		return

	if current_profession == new_profession:
		return

	if (
		current_profession != Profession.UNASSIGNED
		and new_profession != Profession.UNASSIGNED
	):
		profession_change_count += 1
	profession_streak_days = 0
	current_profession = new_profession
	_refresh_visual()
	profession_changed.emit(current_profession)


func export_save_data() -> Dictionary:
	return {
		"representative_id": representative_id,
		"name": villager_name,
		"strength": strength,
		"intelligence": intelligence,
		"charisma": charisma,
		"agility": agility,
		"profession": current_profession,
		"species_name": species_name,
		"is_council_active": is_council_active,
		"is_special_npc": is_special_npc,
		"is_recruited_card": is_recruited_card,
		"specialization": specialization,
		"specialization_name": get_specialization_name(),
		"passive_id": passive_id,
		"portrait_id": portrait_id,
		"passive_name": passive_name,
		"passive_description": passive_description,
		"personality_id": personality_id,
		"personality_name": personality_name,
		"personality_description": personality_description,
		"level": level,
		"xp": xp,
		"lifetime_xp": lifetime_xp,
		"unspent_attribute_points": unspent_attribute_points,
		"attribute_points_spent": attribute_points_spent,
		"profession_streak_days": profession_streak_days,
		"profession_change_count": profession_change_count,
		"mediator_last_trigger_day": mediator_last_trigger_day
	}


func import_save_data(save_data: Dictionary) -> bool:
	if save_data.is_empty():
		return false

	representative_id = String(
		save_data.get(
			"representative_id",
			""
		)
	).strip_edges()

	if representative_id.is_empty():
		return false

	villager_name = String(
		save_data.get(
			"name",
			"Habitante"
		)
	).strip_edges()

	if villager_name.is_empty():
		villager_name = "Habitante"

	strength = clampi(
		int(save_data.get("strength", 1)),
		1,
		MAX_ATTRIBUTE_VALUE
	)

	intelligence = clampi(
		int(save_data.get("intelligence", 1)),
		1,
		MAX_ATTRIBUTE_VALUE
	)

	charisma = clampi(
		int(save_data.get("charisma", 1)),
		1,
		MAX_ATTRIBUTE_VALUE
	)

	agility = clampi(
		int(save_data.get("agility", 1)),
		1,
		MAX_ATTRIBUTE_VALUE
	)

	species_name = String(save_data.get("species_name", "Passos-Leves"))
	is_council_active = bool(save_data.get("is_council_active", true))
	is_special_npc = bool(save_data.get("is_special_npc", false))
	is_recruited_card = bool(save_data.get("is_recruited_card", false))
	specialization = clampi(
		int(
			save_data.get(
				"specialization",
				Profession.UNASSIGNED
			)
		),
		Profession.UNASSIGNED,
		Profession.GATHERER
	)
	passive_id = String(save_data.get("passive_id", ""))
	portrait_id = String(save_data.get("portrait_id", "")).strip_edges()
	passive_name = String(save_data.get("passive_name", "Sem passiva"))
	passive_description = String(save_data.get("passive_description", ""))
	personality_id = String(
		save_data.get("personality_id", "optimistic")
	).strip_edges()
	personality_name = String(
		save_data.get("personality_name", "Otimista")
	).strip_edges()
	personality_description = String(
		save_data.get("personality_description", "")
	)
	level = clampi(int(save_data.get("level", 1)), 1, MAX_LEVEL)
	xp = maxi(0, int(save_data.get("xp", 0)))
	lifetime_xp = maxi(
		0,
		int(save_data.get("lifetime_xp", xp))
	)
	unspent_attribute_points = maxi(
		0,
		int(save_data.get("unspent_attribute_points", 0))
	)
	attribute_points_spent = maxi(
		0,
		int(save_data.get("attribute_points_spent", 0))
	)
	profession_streak_days = maxi(
		0,
		int(save_data.get("profession_streak_days", 0))
	)
	profession_change_count = maxi(
		0,
		int(save_data.get("profession_change_count", 0))
	)
	mediator_last_trigger_day = maxi(
		0,
		int(save_data.get("mediator_last_trigger_day", 0))
	)

	current_profession = clampi(
		int(
			save_data.get(
				"profession",
				Profession.UNASSIGNED
			)
		),
		Profession.UNASSIGNED,
		Profession.GATHERER
	)

	visible = is_council_active
	_refresh_visual()
	return true


func record_completed_profession_day() -> void:
	if (
		is_council_active
		and current_profession != Profession.UNASSIGNED
	):
		profession_streak_days += 1


func grant_xp(amount: int) -> Dictionary:
	if amount <= 0:
		return {
			"success": false,
			"amount": 0,
			"levels_gained": 0
		}

	var previous_level: int = level
	lifetime_xp += amount
	if level < MAX_LEVEL:
		xp += amount
	var levels_gained: int = 0
	while level < MAX_LEVEL and xp >= get_xp_required():
		xp -= get_xp_required()
		level += 1
		unspent_attribute_points += 1
		levels_gained += 1
	if level >= MAX_LEVEL:
		xp = 0

	var result: Dictionary = {
		"success": true,
		"amount": amount,
		"previous_level": previous_level,
		"level": level,
		"xp": xp,
		"lifetime_xp": lifetime_xp,
		"levels_gained": levels_gained,
		"unspent_attribute_points": unspent_attribute_points
	}
	progression_changed.emit(result)
	return result


func spend_attribute_point(attribute_id: String) -> Dictionary:
	var clean_id: String = attribute_id.strip_edges()
	if unspent_attribute_points <= 0:
		return {
			"success": false,
			"message": "Esta carta não possui pontos de atributo disponíveis."
		}
	var current_value: int = get_attribute_value(clean_id)
	if current_value <= 0:
		return {
			"success": false,
			"message": "O atributo escolhido não existe."
		}
	if current_value >= MAX_ATTRIBUTE_VALUE:
		return {
			"success": false,
			"message": "Este atributo já alcançou o limite 8."
		}

	match clean_id:
		"strength": strength += 1
		"intelligence": intelligence += 1
		"charisma": charisma += 1
		"agility": agility += 1
		_:
			return {
				"success": false,
				"message": "O atributo escolhido não existe."
			}
	unspent_attribute_points -= 1
	attribute_points_spent += 1
	var result: Dictionary = {
		"success": true,
		"attribute_id": clean_id,
		"attribute_value": get_attribute_value(clean_id),
		"unspent_attribute_points": unspent_attribute_points,
		"attribute_points_spent": attribute_points_spent,
		"message": "Ponto de atributo distribuído."
	}
	progression_changed.emit(result)
	return result


func get_attribute_value(attribute_id: String) -> int:
	match attribute_id:
		"strength": return strength
		"intelligence": return intelligence
		"charisma": return charisma
		"agility": return agility
		_: return 0


func is_max_level() -> bool:
	return level >= MAX_LEVEL


func get_xp_required() -> int:
	return COUNCIL_CARD_CATALOG_SCRIPT.xp_required_for_level(level)


func get_attribute_total() -> int:
	return strength + intelligence + charisma + agility


static func get_unique_random_names(count: int) -> Array[String]:
	var pool: Array[String] = []
	pool.assign(POSSIBLE_NAMES)
	pool.shuffle()
	var result: Array[String] = []
	var safe_count: int = clampi(count, 0, pool.size())

	for index: int in range(safe_count):
		result.append(pool[index])

	return result


static func get_all_professions() -> Array[int]:
	return [
		Profession.UNASSIGNED,
		Profession.FARMER,
		Profession.BLACKSMITH,
		Profession.CIVIL_SERVANT,
		Profession.GUARD,
		Profession.GATHERER
	]


static func get_profession_name(profession: int) -> String:
	match profession:
		Profession.FARMER:
			return "Agricultor"

		Profession.BLACKSMITH:
			return "Ferreiro"

		Profession.CIVIL_SERVANT:
			return "Servidor Público"

		Profession.GUARD:
			return "Guarda"

		Profession.GATHERER:
			return "Coletor"

		_:
			return "Sem profissão"


static func get_profession_color(profession: int) -> Color:
	match profession:
		Profession.FARMER:
			return Color(0.27, 0.76, 0.35)

		Profession.BLACKSMITH:
			return Color(0.90, 0.48, 0.20)

		Profession.CIVIL_SERVANT:
			return Color(0.63, 0.43, 0.88)

		Profession.GUARD:
			return Color(0.84, 0.25, 0.25)

		Profession.GATHERER:
			return Color(0.87, 0.75, 0.22)

		_:
			return Color(0.40, 0.67, 0.88)


func _refresh_visual() -> void:
	name_label.text = "%s\n%s" % [
		villager_name,
		get_profession_name(current_profession)
	]

	body.color = get_profession_color(current_profession)
