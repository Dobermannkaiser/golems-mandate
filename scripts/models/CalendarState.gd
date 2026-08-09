class_name VillageCalendarState
extends RefCounted


var current_day: int = 1
var completed_checkpoint_days: Array[int] = []
var free_play_unlocked: bool = false


func setup() -> void:
	current_day = 1
	completed_checkpoint_days.clear()
	free_play_unlocked = false


func synchronize_with_game_day(game_day: int) -> void:
	current_day = maxi(1, game_day)
	var completed_days: int = maxi(0, current_day - 1)

	completed_checkpoint_days.clear()

	for checkpoint_day: int in (
		VillageCampaignCatalog.CHECKPOINT_DAYS
	):
		if checkpoint_day <= completed_days:
			completed_checkpoint_days.append(
				checkpoint_day
			)

	free_play_unlocked = (
		VillageCampaignCatalog.FREE_PLAY_ENABLED
		and (
			completed_days
			>= VillageCampaignCatalog.CAMPAIGN_TOTAL_DAYS
		)
	)


func export_save_data() -> Dictionary:
	var season: Dictionary = (
		VillageCampaignCatalog.get_season_for_day(
			current_day
		)
	)

	var next_checkpoint: Dictionary = (
		VillageCampaignCatalog.get_next_checkpoint(
			maxi(0, current_day - 1)
		)
	)

	return {
		"catalog_version": (
			VillageCampaignCatalog.CATALOG_VERSION
		),
		"current_day": current_day,
		"campaign_total_days": (
			VillageCampaignCatalog.CAMPAIGN_TOTAL_DAYS
		),
		"season_id": String(
			season.get("id", "")
		),
		"season_name": String(
			season.get("display_name", "")
		),
		"day_in_season": (
			VillageCampaignCatalog.get_day_in_season(
				current_day
			)
		),
		"completed_checkpoint_days": (
			completed_checkpoint_days.duplicate()
		),
		"next_checkpoint_day": int(
			next_checkpoint.get("day", 0)
		),
		"free_play_unlocked": free_play_unlocked
	}


func import_save_data(save_data: Dictionary) -> bool:
	if not VillageCampaignCatalog.is_supported_catalog_version(
		int(
			save_data.get(
				"catalog_version",
				0
			)
		)
	):
		return false

	var saved_day: int = int(
		save_data.get("current_day", 0)
	)

	if saved_day < 1:
		return false

	var checkpoint_days_value: Variant = save_data.get(
		"completed_checkpoint_days",
		null
	)

	if not checkpoint_days_value is Array:
		return false

	var validated_days: Array[int] = []

	for day_value: Variant in checkpoint_days_value:
		var checkpoint_day: int = int(day_value)

		if (
			not VillageCampaignCatalog.is_valid_checkpoint_day(
				checkpoint_day
			)
			or validated_days.has(checkpoint_day)
			or checkpoint_day >= saved_day
		):
			return false

		validated_days.append(checkpoint_day)

	current_day = saved_day
	completed_checkpoint_days = validated_days
	free_play_unlocked = bool(
		save_data.get(
			"free_play_unlocked",
			false
		)
	)

	if (
		free_play_unlocked
		and (
			current_day
			<= VillageCampaignCatalog.CAMPAIGN_TOTAL_DAYS
		)
	):
		return false

	return true
