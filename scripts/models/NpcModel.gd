class_name VillageNpcModel
extends RefCounted


const MAX_ID_LENGTH: int = 64
const MAX_DISPLAY_NAME_LENGTH: int = 48


var npc_id: String = ""
var display_name: String = "Personagem"
var species_id: String = ""
var profession_id: String = ""
var passive_id: String = ""
var portrait_set_id: String = ""
var arrival_checkpoint_day: int = 0
var romance_available: bool = false
var known: bool = false


func export_save_data() -> Dictionary:
	return {
		"npc_id": npc_id,
		"display_name": display_name,
		"species_id": species_id,
		"profession_id": profession_id,
		"passive_id": passive_id,
		"portrait_set_id": portrait_set_id,
		"arrival_checkpoint_day": arrival_checkpoint_day,
		"romance_available": romance_available,
		"known": known
	}


func import_save_data(save_data: Dictionary) -> bool:
	var saved_id: String = _sanitize_id(
		save_data.get("npc_id", "")
	)

	if saved_id.is_empty():
		return false

	var saved_arrival_day: int = int(
		save_data.get(
			"arrival_checkpoint_day",
			0
		)
	)

	if (
		saved_arrival_day < 0
		or saved_arrival_day > VillageCampaignCatalog.CAMPAIGN_TOTAL_DAYS
	):
		return false

	npc_id = saved_id
	display_name = _sanitize_display_name(
		save_data.get(
			"display_name",
			"Personagem"
		)
	)
	species_id = _sanitize_id(
		save_data.get("species_id", "")
	)
	profession_id = _sanitize_id(
		save_data.get("profession_id", "")
	)
	passive_id = _sanitize_id(
		save_data.get("passive_id", "")
	)
	portrait_set_id = _sanitize_id(
		save_data.get("portrait_set_id", "")
	)
	arrival_checkpoint_day = saved_arrival_day
	romance_available = bool(
		save_data.get(
			"romance_available",
			false
		)
	)
	known = bool(save_data.get("known", false))
	return true


func _sanitize_id(value: Variant) -> String:
	var text: String = String(value).strip_edges()

	if text.length() > MAX_ID_LENGTH:
		text = text.substr(0, MAX_ID_LENGTH)

	return text


func _sanitize_display_name(
	value: Variant
) -> String:
	var text: String = String(value).strip_edges()

	if text.is_empty():
		text = "Personagem"

	if text.length() > MAX_DISPLAY_NAME_LENGTH:
		text = text.substr(
			0,
			MAX_DISPLAY_NAME_LENGTH
		)

	return text
