class_name VillagePlayerProfile
extends RefCounted


const DEFAULT_NAME: String = "Alex"
const DEFAULT_TITLE: String = "Prefeito"
const DEFAULT_GENDER: String = "masculino"
const DEFAULT_GOLEM_FORM: String = "golem_pedregulho"
const DEFAULT_DIFFICULTY_ID: String = "moderate"
const DEFAULT_VILLAGE_NAME: String = "Vila das Quatro Estações"
const MAX_TEXT_LENGTH: int = 48


var player_name: String = DEFAULT_NAME
var gender_id: String = DEFAULT_GENDER
var pronouns: String = "ele/dele"
var title: String = DEFAULT_TITLE
var golem_form: String = DEFAULT_GOLEM_FORM
var difficulty_id: String = DEFAULT_DIFFICULTY_ID
var village_name: String = DEFAULT_VILLAGE_NAME
var campaign_created_at_unix: int = 0
var campaign_created_at_text: String = ""
var created_project_version: String = ""


func setup(
	custom_name: String = DEFAULT_NAME,
	custom_gender: String = DEFAULT_GENDER,
	custom_difficulty_id: String = DEFAULT_DIFFICULTY_ID,
	custom_village_name: String = DEFAULT_VILLAGE_NAME
) -> void:
	player_name = _sanitize_text(custom_name, DEFAULT_NAME)
	set_gender(custom_gender)
	difficulty_id = VillageDifficultyCatalog.sanitize_difficulty_id(custom_difficulty_id)
	village_name = _sanitize_text(custom_village_name, DEFAULT_VILLAGE_NAME)
	campaign_created_at_unix = int(Time.get_unix_time_from_system())
	campaign_created_at_text = Time.get_datetime_string_from_system(false, true)
	created_project_version = String(
		ProjectSettings.get_setting("application/config/version", "")
	)
	title = DEFAULT_TITLE
	golem_form = DEFAULT_GOLEM_FORM


func set_gender(value: String) -> void:
	gender_id = value if value in ["masculino", "feminino"] else DEFAULT_GENDER
	pronouns = "ela/dela" if gender_id == "feminino" else "ele/dele"


func export_save_data() -> Dictionary:
	return {
		"name": player_name,
		"gender_id": gender_id,
		"pronouns": pronouns,
		"title": title,
		"golem_form": golem_form,
		"difficulty_id": difficulty_id,
		"village_name": village_name,
		"campaign_created_at_unix": campaign_created_at_unix,
		"campaign_created_at_text": campaign_created_at_text,
		"created_project_version": created_project_version
	}


func import_save_data(save_data: Dictionary) -> bool:
	if save_data.is_empty():
		return false

	player_name = _sanitize_text(save_data.get("name", DEFAULT_NAME), DEFAULT_NAME)
	var saved_gender: String = String(save_data.get("gender_id", ""))
	if saved_gender.is_empty():
		var legacy_pronouns: String = String(save_data.get("pronouns", "")).to_lower()
		saved_gender = "feminino" if "ela" in legacy_pronouns else DEFAULT_GENDER
	set_gender(saved_gender)
	title = DEFAULT_TITLE
	golem_form = _sanitize_text(save_data.get("golem_form", DEFAULT_GOLEM_FORM), DEFAULT_GOLEM_FORM)
	difficulty_id = VillageDifficultyCatalog.sanitize_difficulty_id(
		String(save_data.get("difficulty_id", DEFAULT_DIFFICULTY_ID))
	)
	village_name = _sanitize_text(
		save_data.get("village_name", DEFAULT_VILLAGE_NAME),
		DEFAULT_VILLAGE_NAME
	)
	campaign_created_at_unix = maxi(
		0,
		int(save_data.get("campaign_created_at_unix", 0))
	)
	campaign_created_at_text = _sanitize_text(
		save_data.get("campaign_created_at_text", "Data não registrada"),
		"Data não registrada"
	)
	created_project_version = _sanitize_text(
		save_data.get("created_project_version", "3.10.1"),
		"3.10.1"
	)
	return true


func get_display_address() -> String:
	return "%s %s" % [title, player_name]


func _sanitize_text(value: Variant, fallback: String) -> String:
	var text: String = String(value).strip_edges()
	if text.is_empty():
		text = fallback
	if text.length() > MAX_TEXT_LENGTH:
		text = text.substr(0, MAX_TEXT_LENGTH)
	return text
