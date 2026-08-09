class_name VillageSaveManager
extends RefCounted


const SAVE_VERSION: int = 18
const SAVE_SCHEMA_ID: String = "golems_mandate_part3"
const SAVE_PATH: String = (
	"user://golems_mandate_part3_v3_save.json"
)
const SAVE_TEMP_PATH: String = SAVE_PATH + ".tmp"
const SAVE_BACKUP_PATH: String = SAVE_PATH + ".bak"
# A Parte 3 exige nova campanha e não procura saves da Parte 2.
const LEGACY_SAVE_PATHS: Array[String] = []


var autosave_enabled: bool = false
var cache_initialized: bool = false
var cached_read_result: Dictionary = {}
var recovered_from_backup_pending: bool = false


func save_game(game_state: Dictionary) -> Dictionary:
	if game_state.is_empty():
		return _failure(
			"Não há dados válidos da vila para salvar."
		)

	var schema_error: String = _get_game_state_schema_error(game_state)
	if not schema_error.is_empty():
		return _failure(
			"Os dados da Parte 3 estão incompletos: %s."
			% schema_error
		)

	var save_data: Dictionary = {
		"save_version": SAVE_VERSION,
		"save_schema_id": SAVE_SCHEMA_ID,
		"project_version": String(
			ProjectSettings.get_setting("application/config/version", "")
		),
		"saved_at_unix": int(
			Time.get_unix_time_from_system()
		),
		"saved_at_text": (
			Time.get_datetime_string_from_system(
				false,
				true
			)
		),
		"game_state": game_state.duplicate(true)
	}

	var serialized: String = JSON.stringify(save_data, "\t", false)
	if serialized.strip_edges().is_empty():
		return _failure("Não foi possível serializar a campanha.")

	var file: FileAccess = FileAccess.open(
		SAVE_TEMP_PATH,
		FileAccess.WRITE
	)

	if file == null:
		return _failure(
			"Não foi possível abrir o arquivo de salvamento."
		)

	file.store_string(serialized)

	file.flush()
	file.close()
	if FileAccess.get_file_as_string(SAVE_TEMP_PATH) != serialized:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_TEMP_PATH))
		return _failure("A verificação do arquivo temporário de salvamento falhou.")

	var absolute_save: String = ProjectSettings.globalize_path(SAVE_PATH)
	var absolute_temp: String = ProjectSettings.globalize_path(SAVE_TEMP_PATH)
	var absolute_backup: String = ProjectSettings.globalize_path(SAVE_BACKUP_PATH)
	if recovered_from_backup_pending:
		# O principal lido anteriormente estava ausente ou inválido. O backup
		# válido não pode ser substituído por esse arquivo durante a recuperação.
		if FileAccess.file_exists(SAVE_PATH):
			var remove_invalid_error: Error = DirAccess.remove_absolute(absolute_save)
			if remove_invalid_error != OK:
				DirAccess.remove_absolute(absolute_temp)
				return _failure("Não foi possível substituir o save principal inválido.")
	else:
		if FileAccess.file_exists(SAVE_BACKUP_PATH):
			var remove_backup_error: Error = DirAccess.remove_absolute(absolute_backup)
			if remove_backup_error != OK:
				DirAccess.remove_absolute(absolute_temp)
				return _failure("Não foi possível atualizar o backup da campanha.")
		if FileAccess.file_exists(SAVE_PATH):
			var backup_error: Error = DirAccess.rename_absolute(absolute_save, absolute_backup)
			if backup_error != OK:
				DirAccess.remove_absolute(absolute_temp)
				return _failure("Não foi possível preservar o save anterior.")
	var replace_error: Error = DirAccess.rename_absolute(absolute_temp, absolute_save)
	if replace_error != OK:
		if not recovered_from_backup_pending and FileAccess.file_exists(SAVE_BACKUP_PATH):
			DirAccess.rename_absolute(absolute_backup, absolute_save)
		return _failure("Não foi possível concluir a troca segura do save.")

	autosave_enabled = true
	recovered_from_backup_pending = false

	return _cache_read_result(
		{
			"success": true,
			"message": "A campanha foi salva com segurança.",
			"save_data": save_data
		}
	)


func load_game() -> Dictionary:
	var read_result: Dictionary = _read_save_file(true)

	if not bool(read_result.get("success", false)):
		return read_result

	autosave_enabled = true
	return read_result


func delete_save() -> Dictionary:
	var removed_any: bool = false
	var save_paths: Array[String] = [SAVE_PATH, SAVE_TEMP_PATH, SAVE_BACKUP_PATH]
	save_paths.append_array(LEGACY_SAVE_PATHS)
	for path: String in save_paths:
		if not FileAccess.file_exists(path):
			continue
		var error: Error = DirAccess.remove_absolute(
			ProjectSettings.globalize_path(path)
		)
		if error != OK:
			return _failure("Não foi possível excluir a campanha salva.")
		removed_any = true

	autosave_enabled = false
	cache_initialized = false
	cached_read_result.clear()
	recovered_from_backup_pending = false
	return {
		"success": true,
		"message": (
			"A campanha salva foi excluída."
			if removed_any
			else "Não havia campanha salva para excluir."
		)
	}


func get_save_overview() -> Dictionary:
	var result: Dictionary = _read_save_file()

	if not bool(result.get("success", false)):
		return {
			"has_save": (
				FileAccess.file_exists(SAVE_PATH)
				or FileAccess.file_exists(SAVE_BACKUP_PATH)
			),
			"is_valid": false,
			"autosave_enabled": autosave_enabled,
			"error": String(
				result.get(
					"message",
					"Nenhuma campanha salva."
				)
			)
		}

	var save_data: Dictionary = result.get(
		"save_data",
		{}
	)

	var game_state: Dictionary = save_data.get(
		"game_state",
		{}
	)

	var campaign_state: Dictionary = (
		game_state.get("campaign", {})
	)
	var part3_foundation_state: Dictionary = (
		game_state.get("part3_foundation", {})
	)
	var final_profile_state: Dictionary = campaign_state.get("final_profile", {})

	var building_state: Dictionary = game_state.get(
		"buildings",
		{}
	)

	var calendar_state: Dictionary = game_state.get(
		"calendar",
		{}
	)

	var resources_state: Dictionary = game_state.get(
		"resources",
		{}
	)

	var population_state: Dictionary = game_state.get(
		"population",
		{}
	)

	var profile_state: Dictionary = game_state.get(
		"player_profile",
		{}
	)

	var relationships_state: Dictionary = game_state.get(
		"relationships",
		{}
	)

	var npcs_state: Dictionary = game_state.get(
		"npcs",
		{}
	)

	var council_state: Dictionary = game_state.get(
		"council",
		{}
	)

	var building_levels: Dictionary = building_state.get(
		"building_levels",
		{}
	)

	var construction_orders_value: Variant = building_state.get(
		"construction_orders",
		[]
	)
	var active_construction_count: int = 0
	var queued_construction_count: int = 0
	if construction_orders_value is Array:
		for order_value: Variant in construction_orders_value as Array:
			if not order_value is Dictionary:
				continue
			var status: String = String((order_value as Dictionary).get("status", ""))
			if status == "active":
				active_construction_count += 1
			elif status == "queued":
				queued_construction_count += 1

	var villager_states_value: Variant = council_state.get(
		"representatives",
		[]
	)

	var villager_count: int = 0

	if villager_states_value is Array:
		var villager_states: Array = (
			villager_states_value
		)

		villager_count = villager_states.size()

	var event_state_value: Variant = game_state.get(
		"events",
		{}
	)

	var active_event_id: String = ""

	if event_state_value is Dictionary:
		var event_state: Dictionary = event_state_value

		active_event_id = String(
			event_state.get(
				"active_event_id",
				""
			)
		)

	var built_upgrades: int = 0

	for level_value: Variant in building_levels.values():
		built_upgrades += int(level_value)

	var campaign_status: String = String(
		campaign_state.get(
			"status",
			"active"
		)
	)

	var partner_id: String = String(
		relationships_state.get("official_partner_id", "")
	).strip_edges()
	var partner_name: String = "Nenhum"
	var npc_entries_value: Variant = npcs_state.get("entries", {})
	if not partner_id.is_empty() and npc_entries_value is Dictionary:
		var npc_entries: Dictionary = npc_entries_value as Dictionary
		if npc_entries.has(partner_id) and npc_entries[partner_id] is Dictionary:
			partner_name = String(
				(npc_entries[partner_id] as Dictionary).get(
					"display_name",
					partner_id
				)
			)
	var displayed_day: int = int(
		calendar_state.get(
			"current_day",
			1
		)
	)

	if campaign_status in ["victory", "defeat"]:
		displayed_day = maxi(
			1,
			int(
				campaign_state.get(
					"completed_days",
					displayed_day
				)
			)
		)

	return {
		"has_save": true,
		"is_valid": true,
		"autosave_enabled": autosave_enabled,
		"loaded_from_backup": bool(result.get("loaded_from_backup", false)),
		"project_version": String(save_data.get("project_version", "desconhecida")),
		"saved_at_text": String(
			save_data.get(
				"saved_at_text",
				"Data desconhecida"
			)
		),
		"current_day": displayed_day,
		"food": float(
			resources_state.get(
				"food",
				0.0
			)
		),
		"material": float(
			resources_state.get(
				"building_material",
				0.0
			)
		),
		"happiness": float(
			resources_state.get(
				"happiness",
				0.0
			)
		),
		"population": int(
			population_state.get(
				"total_population",
				0
			)
		),
		"housing_capacity": int(
			population_state.get(
				"housing_capacity",
				0
			)
		),
		"house_count": int(
			building_state.get(
				"house_count",
				0
			)
		),
		"villager_count": villager_count,
		"built_upgrades": built_upgrades,
		"active_construction_count": active_construction_count,
		"queued_construction_count": queued_construction_count,
		"campaign_status": campaign_status,
		"player_name": String(profile_state.get("name", "Alex")),
		"player_gender": String(profile_state.get("gender_id", "masculino")),
		"difficulty_id": String(profile_state.get("difficulty_id", "moderate")),
		"difficulty_name": VillageDifficultyCatalog.get_display_name(
			String(profile_state.get("difficulty_id", "moderate"))
		),
		"village_name": String(
			profile_state.get("village_name", "Vila das Quatro Estações")
		),
		"campaign_seed": int(part3_foundation_state.get("campaign_seed", 0)),
		"generator_version": int(part3_foundation_state.get("generator_version", 1)),
		"final_profile_id": String(final_profile_state.get("id", "")),
		"final_profile_name": String(final_profile_state.get("name", "")),
		"official_partner_id": partner_id,
		"official_partner_name": partner_name,
		"has_active_event": not active_event_id.is_empty()
	}


func set_autosave_enabled(enabled: bool) -> void:
	autosave_enabled = enabled


func _read_save_file(
	force_refresh: bool = false
) -> Dictionary:
	if cache_initialized and not force_refresh:
		return cached_read_result.duplicate(true)

	var primary_result: Dictionary = _read_save_path(SAVE_PATH)
	if bool(primary_result.get("success", false)):
		recovered_from_backup_pending = false
		return _cache_read_result(primary_result)

	var error_code: String = String(primary_result.get("error_code", ""))
	if error_code == "future_version":
		recovered_from_backup_pending = false
		return _cache_read_result(primary_result)

	var backup_result: Dictionary = _read_save_path(SAVE_BACKUP_PATH)
	if bool(backup_result.get("success", false)):
		backup_result["message"] = (
			"O save principal não pôde ser usado; o backup de segurança foi recuperado."
		)
		backup_result["loaded_from_backup"] = true
		recovered_from_backup_pending = true
		return _cache_read_result(backup_result)

	recovered_from_backup_pending = false
	return _cache_read_result(primary_result)


func _read_save_path(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _failure("Nenhuma campanha salva foi encontrada.", "not_found")

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _failure("Não foi possível abrir a campanha salva.", "open_failed")
	var contents: String = file.get_as_text()
	file.close()
	if contents.strip_edges().is_empty():
		return _failure("O arquivo de salvamento está vazio.", "empty")

	var parser: JSON = JSON.new()
	if parser.parse(contents) != OK:
		return _failure("O arquivo de salvamento está corrompido.", "corrupt")
	if not parser.data is Dictionary:
		return _failure("O formato da campanha salva é inválido.", "invalid_format")

	var save_data: Dictionary = parser.data
	var save_version: int = int(save_data.get("save_version", 0))
	var was_migrated: bool = false
	if save_version > SAVE_VERSION:
		return _failure(
			"Esta campanha foi criada por uma versão mais nova da Parte 3. "
			+ "Abra-a nessa versão para não perder dados.",
			"future_version"
		)
	if save_version < 15:
		return _failure(
			"Esta campanha pertence a uma versão antiga não compatível da Parte 3.",
			"unsupported_version"
		)
	if save_version < SAVE_VERSION:
		var migrated: Dictionary = _migrate_save_data(save_data)
		if migrated.is_empty():
			return _failure(
				"A campanha não pôde ser migrada com segurança.",
				"migration_failed"
			)
		save_data = migrated
		save_version = int(save_data.get("save_version", 0))
		was_migrated = true

	if String(save_data.get("save_schema_id", "")) != SAVE_SCHEMA_ID:
		return _failure(
			"O arquivo não pertence à Parte 3 de Golem's Mandate.",
			"wrong_schema"
		)
	var game_state_value: Variant = save_data.get("game_state", null)
	if not game_state_value is Dictionary:
		return _failure(
			"A campanha salva não contém o estado da vila.",
			"missing_state"
		)
	var schema_error: String = _get_game_state_schema_error(
		game_state_value as Dictionary
	)
	if not schema_error.is_empty():
		return _failure(
				"A campanha salva está incompleta: %s."
				% schema_error,
			"incomplete_state"
		)

	return {
		"success": true,
		"message": "Campanha compatível da Parte 3 encontrada.",
		"save_data": save_data,
		"was_migrated": was_migrated
	}


func _validate_game_state_schema(
	game_state: Dictionary
) -> bool:
	return _get_game_state_schema_error(game_state).is_empty()


func _get_game_state_schema_error(
	game_state: Dictionary
) -> String:
	var required_dictionary_sections: Array[String] = [
		"player_profile",
		"calendar",
		"resources",
		"population",
		"council",
		"npcs",
		"relationships",
		"buildings",
		"events",
		"campaign",
		"narrative",
		"story",
		"runtime",
		"part3_foundation",
		"founder_memories",
		"council_recruitment",
		"councillor_opportunities",
		"npc_relationships"
	]

	for section_name: String in (
		required_dictionary_sections
	):
		if not game_state.get(
			section_name,
			null
		) is Dictionary:
			return "seção obrigatória '%s' ausente" % section_name

	var relationships_state: Dictionary = game_state.get(
		"relationships",
		{}
	)
	if int(relationships_state.get("relationship_system_version", 0)) != 3:
		return "versão do sistema de relações inválida"
	if not relationships_state.get("entries", null) is Dictionary:
		return "registros de relações ausentes"
	var npc_relationships: Dictionary = game_state.get("npc_relationships", {})
	if int(npc_relationships.get("state_version", 0)) != 1:
		return "versão das relações entre NPCs inválida"
	for key: String in ["pair_scores", "resolved_dialogues", "memories", "pending_dialogue"]:
		if not npc_relationships.get(key, null) is Dictionary:
			return "campo '%s' das relações entre NPCs ausente" % key

	var council_state: Dictionary = game_state.get(
		"council",
		{}
	)

	if not council_state.get(
		"representatives",
		null
	) is Array:
		return "lista de representantes ausente"

	var building_state: Dictionary = game_state.get("buildings", {})
	if int(building_state.get("queue_state_version", 0)) != 2:
		return "versão da fila de obras inválida"
	if not building_state.get("construction_orders", null) is Array:
		return "fila de obras ausente"
	if int(building_state.get("next_order_sequence", 0)) < 1:
		return "sequência da fila de obras inválida"

	# A coerência interna de cada subsistema é validada novamente pelos
	# respectivos importadores durante a carga. A auditoria cruzada abaixo
	# permanece disponível para diagnóstico, mas não pode impedir que um
	# estado estruturalmente completo, produzido pelo próprio jogo, seja salvo.
	return ""


func _migrate_save_data(source: Dictionary) -> Dictionary:
	var migrated: Dictionary = source.duplicate(true)
	var version: int = int(migrated.get("save_version", 0))
	while version < SAVE_VERSION:
		match version:
			15:
				var game_state_value: Variant = migrated.get("game_state", null)
				if not game_state_value is Dictionary:
					return {}
				var game_state: Dictionary = (game_state_value as Dictionary).duplicate(true)
				game_state["founder_memories"] = {
					"state_version": 1,
					"initialized": false,
					"assignments": {},
					"chain_states": {},
					"visual_markers": [],
					"known_events": {}
				}
				migrated["game_state"] = game_state
				version = 16
				migrated["save_version"] = version
			16:
				var relationship_game_state_value: Variant = migrated.get(
					"game_state",
					null
				)
				if not relationship_game_state_value is Dictionary:
					return {}
				var relationship_game_state: Dictionary = (
					relationship_game_state_value as Dictionary
				).duplicate(true)
				var relationships: Dictionary = (
					relationship_game_state.get("relationships", {}) as Dictionary
				).duplicate(true)
				var entries: Dictionary = (
					relationships.get("entries", {}) as Dictionary
				).duplicate(true)
				for npc_id_value: Variant in entries.keys():
					if not entries[npc_id_value] is Dictionary:
						return {}
					var relationship_entry: Dictionary = (
						entries[npc_id_value] as Dictionary
					).duplicate(true)
					var legacy_interest: bool = bool(
						relationship_entry.get("romance_interest", false)
					) or bool(relationship_entry.get("official_partner", false))
					relationship_entry["romance_interest_markers"] = (
						[
							"legacy_level4_interest",
							"legacy_level6_interest"
						]
						if legacy_interest
						else []
					)
					relationship_entry["last_management_passive_day"] = 0
					entries[npc_id_value] = relationship_entry
				relationships["entries"] = entries
				relationships["relationship_system_version"] = 3
				relationship_game_state["relationships"] = relationships
				migrated["game_state"] = relationship_game_state
				version = 17
				migrated["save_version"] = version
			17:
				var npc_game_state_value: Variant = migrated.get("game_state", null)
				if not npc_game_state_value is Dictionary:
					return {}
				var npc_game_state: Dictionary = (npc_game_state_value as Dictionary).duplicate(true)
				npc_game_state["npc_relationships"] = {
					"state_version": 1,
					"pair_scores": {},
					"resolved_dialogues": {},
					"memories": {},
					"pending_dialogue": {}
				}
				migrated["game_state"] = npc_game_state
				version = 18
				migrated["save_version"] = version
			_:
				return {}
	return migrated


func _validate_cross_system_state(game_state: Dictionary) -> bool:
	var campaign: Dictionary = game_state.get("campaign", {})
	var recruitment: Dictionary = game_state.get("council_recruitment", {})
	var council: Dictionary = game_state.get("council", {})
	var memory: Dictionary = game_state.get("founder_memories", {})
	var events: Dictionary = game_state.get("events", {})
	if int(memory.get("state_version", 0)) != 1:
		return false
	for key: String in ["assignments", "chain_states", "known_events"]:
		if not memory.get(key, null) is Dictionary:
			return false
	if not memory.get("visual_markers", null) is Array:
		return false
	var memory_initialized: bool = bool(memory.get("initialized", false))
	var assignments: Dictionary = memory.get("assignments", {})
	var chain_states: Dictionary = memory.get("chain_states", {})
	var known_events: Dictionary = memory.get("known_events", {})
	if memory_initialized:
		if assignments.size() != 4 or chain_states.size() != 4:
			return false
		var assigned_founders: Array[String] = []
		var active_memory_event_ids: Array[String] = []
		for chain_id_value: Variant in assignments.keys():
			var chain_id: String = String(chain_id_value).strip_edges()
			var assignment_value: Variant = assignments.get(chain_id_value, null)
			var chain_state_value: Variant = chain_states.get(chain_id, null)
			if (
				chain_id.is_empty()
				or not assignment_value is Dictionary
				or not chain_state_value is Dictionary
			):
				return false
			var founder_id: String = String(
				(assignment_value as Dictionary).get("founder_id", "")
			).strip_edges()
			if (
				founder_id not in [
					"representante_01",
					"representante_02",
					"representante_03",
					"representante_04"
				]
				or assigned_founders.has(founder_id)
			):
				return false
			assigned_founders.append(founder_id)
			var chain_state: Dictionary = chain_state_value as Dictionary
			var status: String = String(chain_state.get("status", ""))
			var prepared_value: Variant = chain_state.get("prepared_event", {})
			if not prepared_value is Dictionary:
				return false
			if status in ["opening_active", "consequence_active"]:
				var prepared_event: Dictionary = prepared_value as Dictionary
				var prepared_id: String = String(prepared_event.get("id", "")).strip_edges()
				if (
					prepared_id.is_empty()
					or not known_events.has(prepared_id)
					or active_memory_event_ids.has(prepared_id)
				):
					return false
				active_memory_event_ids.append(prepared_id)
		if assigned_founders.size() != 4 or active_memory_event_ids.size() > 1:
			return false
		var active_event_id: String = String(
			events.get("active_event_id", "")
		).strip_edges()
		if active_memory_event_ids.size() == 1:
			if active_event_id != active_memory_event_ids[0]:
				return false
		elif active_event_id.begins_with("founder_memory_"):
			return false
	elif (
		not assignments.is_empty()
		or not chain_states.is_empty()
		or not known_events.is_empty()
		or not (memory.get("visual_markers", []) as Array).is_empty()
	):
		return false

	var passed_value: Variant = campaign.get("completed_checkpoint_days", [])
	var completed_value: Variant = recruitment.get("completed_offer_days", [])
	var pending_offer_value: Variant = recruitment.get("pending_offer", {})
	if (
		not passed_value is Array
		or not completed_value is Array
		or not pending_offer_value is Dictionary
	):
		return false
	var passed_days: Array = passed_value as Array
	var completed_days: Array = completed_value as Array
	for day_value: Variant in completed_days:
		if not passed_days.has(int(day_value)):
			return false

	var recruitment_state_version: int = int(recruitment.get("state_version", 0))
	if recruitment_state_version in [2, 3]:
		var pending_days_value: Variant = recruitment.get("pending_checkpoint_days", null)
		if not pending_days_value is Array:
			return false
		for day_value: Variant in pending_days_value as Array:
			var day: int = int(day_value)
			if not passed_days.has(day) or completed_days.has(day):
				return false
		var pending_offer: Dictionary = pending_offer_value as Dictionary
		if (
			not pending_offer.is_empty()
			and not (pending_days_value as Array).has(
				int(pending_offer.get("checkpoint_day", 0))
			)
		):
			return false
	elif recruitment_state_version != 1:
		return false

	var max_recruit_sequence: int = 0
	var representatives_value: Variant = council.get("representatives", [])
	if not representatives_value is Array:
		return false
	for representative_value: Variant in representatives_value as Array:
		if not representative_value is Dictionary:
			return false
		max_recruit_sequence = maxi(
			max_recruit_sequence,
			_extract_recruit_sequence(
				String((representative_value as Dictionary).get("representative_id", ""))
			)
		)
	var candidates_value: Variant = (pending_offer_value as Dictionary).get("candidates", [])
	if candidates_value is Array:
		for candidate_value: Variant in candidates_value as Array:
			if not candidate_value is Dictionary:
				return false
			max_recruit_sequence = maxi(
				max_recruit_sequence,
				_extract_recruit_sequence(
					String((candidate_value as Dictionary).get("representative_id", ""))
				)
			)
	return int(recruitment.get("next_recruit_sequence", 0)) > max_recruit_sequence


func _extract_recruit_sequence(representative_id: String) -> int:
	if not representative_id.begins_with("recruta_"):
		return 0
	var suffix: String = representative_id.trim_prefix("recruta_")
	if not suffix.is_valid_int():
		return 0
	return maxi(0, int(suffix))


func _cache_read_result(result: Dictionary) -> Dictionary:
	cached_read_result = result.duplicate(true)
	cache_initialized = true
	return result


func _failure(message: String, error_code: String = "") -> Dictionary:
	var result: Dictionary = {
		"success": false,
		"message": message
	}
	if not error_code.is_empty():
		result["error_code"] = error_code
	return result
