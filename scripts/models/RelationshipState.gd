class_name VillageRelationshipState
extends RefCounted


const MIN_RELATIONSHIP_POINTS: int = 0
const MAX_RELATIONSHIP_POINTS: int = 1000
const LEVEL_THRESHOLDS: Array[int] = [
	0, 50, 120, 220, 340, 480, 620, 740, 840, 920, 1000
]
const MAX_LEVEL: int = 10


var npc_id: String = ""
var relationship_points: int = MIN_RELATIONSHIP_POINTS
var romance_available: bool = false
var romance_interest: bool = false
var romance_interest_markers: Array[String] = []
var official_partner: bool = false
var romance_declined: bool = false
var last_management_passive_day: int = 0
var last_conversation_day: int = 0
var last_date_day: int = 0
var conversations_total: int = 0
var dates_total: int = 0
var last_response_quality: String = ""
var last_conversation_topic_id: String = ""
var response_counts: Dictionary = {
	"good": 0,
	"neutral": 0,
	"bad": 0
}
var completed_personal_event_ids: Array[String] = []
var seen_seasonal_dialogue_keys: Array[String] = []


func setup(target_npc_id: String, can_romance: bool) -> bool:
	var clean_npc_id: String = target_npc_id.strip_edges()
	if clean_npc_id.is_empty():
		return false

	npc_id = clean_npc_id
	romance_available = can_romance
	relationship_points = MIN_RELATIONSHIP_POINTS
	romance_interest = false
	romance_interest_markers.clear()
	official_partner = false
	romance_declined = false
	last_management_passive_day = 0
	last_conversation_day = 0
	last_date_day = 0
	conversations_total = 0
	dates_total = 0
	last_response_quality = ""
	last_conversation_topic_id = ""
	response_counts = {"good": 0, "neutral": 0, "bad": 0}
	completed_personal_event_ids.clear()
	seen_seasonal_dialogue_keys.clear()
	return true


func export_save_data() -> Dictionary:
	return {
		"npc_id": npc_id,
		"relationship_points": relationship_points,
		"relationship_level": get_relationship_level(),
		"romance_available": romance_available,
		"romance_interest": romance_interest,
		"romance_interest_markers": romance_interest_markers.duplicate(),
		"official_partner": official_partner,
		"romance_declined": romance_declined,
		"last_management_passive_day": last_management_passive_day,
		"last_conversation_day": last_conversation_day,
		"last_date_day": last_date_day,
		"conversations_total": conversations_total,
		"dates_total": dates_total,
		"last_response_quality": last_response_quality,
		"last_conversation_topic_id": last_conversation_topic_id,
		"response_counts": response_counts.duplicate(true),
		"completed_personal_event_ids": completed_personal_event_ids.duplicate(),
		"seen_seasonal_dialogue_keys": seen_seasonal_dialogue_keys.duplicate(),
		"relationship_kind": get_relationship_kind()
	}


func import_save_data(save_data: Dictionary) -> bool:
	var saved_npc_id: String = String(save_data.get("npc_id", "")).strip_edges()
	if saved_npc_id.is_empty():
		return false

	npc_id = saved_npc_id
	romance_available = bool(save_data.get("romance_available", false))

	if save_data.has("relationship_points"):
		relationship_points = clampi(
			int(save_data.get("relationship_points", 0)),
			MIN_RELATIONSHIP_POINTS,
			MAX_RELATIONSHIP_POINTS
		)
	else:
		var legacy_level: int = clampi(int(save_data.get("relationship_level", 1)), 1, 15)
		relationship_points = clampi((legacy_level - 1) * 45, 0, 700)

	romance_interest = bool(save_data.get("romance_interest", false))
	romance_interest_markers.clear()
	if not _read_unique_string_array(
		save_data.get("romance_interest_markers", []),
		romance_interest_markers
	):
		return false
	if romance_interest and romance_interest_markers.is_empty():
		romance_interest_markers = [
			"legacy_level4_interest",
			"legacy_level6_interest"
		]
	official_partner = bool(save_data.get("official_partner", false))
	romance_declined = bool(save_data.get("romance_declined", false))
	last_management_passive_day = maxi(
		0,
		int(save_data.get("last_management_passive_day", 0))
	)
	last_conversation_day = maxi(0, int(save_data.get("last_conversation_day", 0)))
	last_date_day = maxi(0, int(save_data.get("last_date_day", 0)))
	conversations_total = maxi(0, int(save_data.get("conversations_total", 0)))
	dates_total = maxi(0, int(save_data.get("dates_total", 0)))
	last_response_quality = String(save_data.get("last_response_quality", ""))
	last_conversation_topic_id = String(save_data.get("last_conversation_topic_id", ""))

	response_counts = {"good": 0, "neutral": 0, "bad": 0}
	var counts_value: Variant = save_data.get("response_counts", {})
	if counts_value is Dictionary:
		for quality: String in ["good", "neutral", "bad"]:
			response_counts[quality] = maxi(0, int((counts_value as Dictionary).get(quality, 0)))

	completed_personal_event_ids.clear()
	if not _read_unique_string_array(
		save_data.get("completed_personal_event_ids", []),
		completed_personal_event_ids
	):
		return false

	seen_seasonal_dialogue_keys.clear()
	if not _read_unique_string_array(
		save_data.get("seen_seasonal_dialogue_keys", []),
		seen_seasonal_dialogue_keys
	):
		return false

	if official_partner and not romance_available:
		return false
	return true


func add_relationship_points(amount: int) -> int:
	var previous: int = relationship_points
	relationship_points = clampi(
		relationship_points + amount,
		MIN_RELATIONSHIP_POINTS,
		MAX_RELATIONSHIP_POINTS
	)
	return relationship_points - previous


func get_relationship_level() -> int:
	var level: int = 0
	for index: int in range(LEVEL_THRESHOLDS.size()):
		if relationship_points >= LEVEL_THRESHOLDS[index]:
			level = index
	return clampi(level, 0, MAX_LEVEL)


func get_points_to_next_level() -> int:
	var level: int = get_relationship_level()
	if level >= MAX_LEVEL:
		return 0
	return maxi(0, LEVEL_THRESHOLDS[level + 1] - relationship_points)


func can_gain_conversation_points(day: int) -> bool:
	return day > 0 and last_conversation_day != day


func register_conversation(
	day: int,
	quality: String,
	point_delta: int,
	topic_id: String = "",
	ignore_daily_limit: bool = false
) -> int:
	var clean_quality: String = quality.strip_edges().to_lower()
	if clean_quality not in ["good", "neutral", "bad"]:
		clean_quality = "neutral"

	var applied_delta: int = 0
	if ignore_daily_limit or can_gain_conversation_points(day):
		applied_delta = add_relationship_points(point_delta)
		if not ignore_daily_limit:
			last_conversation_day = day
		conversations_total += 1
		response_counts[clean_quality] = int(response_counts.get(clean_quality, 0)) + 1
	last_response_quality = clean_quality
	if not topic_id.strip_edges().is_empty():
		last_conversation_topic_id = topic_id.strip_edges()
	return applied_delta


func can_go_on_date(day: int) -> bool:
	return official_partner and day > 0 and (last_date_day == 0 or day - last_date_day >= 7)


func register_date(day: int, point_delta: int) -> int:
	if not can_go_on_date(day):
		return 0
	last_date_day = day
	dates_total += 1
	return add_relationship_points(point_delta)


func has_completed_personal_event(event_id: String) -> bool:
	return completed_personal_event_ids.has(event_id)


func complete_personal_event(event_id: String) -> bool:
	var clean_id: String = event_id.strip_edges()
	if clean_id.is_empty() or completed_personal_event_ids.has(clean_id):
		return false
	completed_personal_event_ids.append(clean_id)
	return true


func mark_seasonal_dialogue_seen(key: String) -> bool:
	var clean_key: String = key.strip_edges()
	if clean_key.is_empty() or seen_seasonal_dialogue_keys.has(clean_key):
		return false
	seen_seasonal_dialogue_keys.append(clean_key)
	return true


func set_official_partner(value: bool) -> void:
	official_partner = value and romance_available
	if official_partner:
		romance_interest = true
		if romance_interest_markers.size() < 2:
			romance_interest_markers = [
				"legacy_level4_interest",
				"legacy_level6_interest"
			]
		romance_declined = false
		relationship_points = maxi(relationship_points, LEVEL_THRESHOLDS[9])


func get_relationship_kind() -> String:
	if official_partner:
		return "partner"
	if (
		romance_available
		and has_romance_requirements()
		and get_relationship_level() >= 8
		and not romance_declined
	):
		return "romance_available"
	if romance_available and not romance_interest_markers.is_empty():
		return "romantic_interest"
	return "friendship"


func add_romance_interest_marker(marker_id: String) -> bool:
	var clean_id: String = marker_id.strip_edges()
	if (
		clean_id.is_empty()
		or romance_declined
		or romance_interest_markers.has(clean_id)
	):
		return false
	romance_interest_markers.append(clean_id)
	romance_interest = true
	return true


func has_romance_requirements() -> bool:
	return romance_interest_markers.size() >= 2 and not romance_declined


func can_trigger_management_passive(day: int, cooldown_days: int) -> bool:
	return (
		day > 0
		and (
			last_management_passive_day == 0
			or day - last_management_passive_day >= cooldown_days
		)
	)


func mark_management_passive_triggered(day: int) -> bool:
	if day <= 0:
		return false
	last_management_passive_day = day
	return true


func _read_unique_string_array(value: Variant, output: Array[String]) -> bool:
	if not value is Array:
		return false
	for item_value: Variant in value:
		var item: String = String(item_value).strip_edges()
		if item.is_empty() or output.has(item):
			return false
		output.append(item)
	return true
