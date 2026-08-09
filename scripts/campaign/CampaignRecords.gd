class_name VillageCampaignRecords
extends RefCounted


const RECORDS_PATH: String = "user://golems_mandate_campaign_records.json"
const RECORDS_TEMP_PATH: String = RECORDS_PATH + ".tmp"
const RECORDS_BACKUP_PATH: String = RECORDS_PATH + ".bak"
const LEGACY_RECORDS_PATH: String = "user://square_village_campaign_records.json"
const MAX_RECORDS: int = 30


static func record_campaign(record_data: Dictionary) -> bool:
	if String(record_data.get("campaign_profile_id", "")).is_empty():
		return false
	var records: Array[Dictionary] = get_all_records()
	var stored: Dictionary = record_data.duplicate(true)
	stored["completed_at_unix"] = int(Time.get_unix_time_from_system())
	stored["completed_at_text"] = Time.get_datetime_string_from_system(false, true)
	records.push_front(stored)
	if records.size() > MAX_RECORDS:
		records.resize(MAX_RECORDS)
	return _write_records(records)


static func get_all_records() -> Array[Dictionary]:
	for path: String in [RECORDS_PATH, RECORDS_BACKUP_PATH, LEGACY_RECORDS_PATH]:
		var read_result: Dictionary = _read_records(path)
		if bool(read_result.get("success", false)):
			var records_value: Variant = read_result.get("records", [])
			if records_value is Array:
				var records: Array[Dictionary] = []
				for value: Variant in records_value as Array:
					if value is Dictionary:
						records.append((value as Dictionary).duplicate(true))
				if path != RECORDS_PATH:
					# Recupera o caminho canônico sem apagar a origem válida: a
					# escrita abaixo preserva um backup bom quando o principal falhou.
					_write_records(records)
				return records
	return []


static func _read_records(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"success": false}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"success": false}
	var text: String = file.get_as_text()
	file.close()
	var parser: JSON = JSON.new()
	if parser.parse(text) != OK or not parser.data is Array:
		return {"success": false}
	var result: Array[Dictionary] = []
	for value: Variant in parser.data:
		if value is Dictionary:
			result.append((value as Dictionary).duplicate(true))
	return {"success": true, "records": result}


static func get_best_record() -> Dictionary:
	# Mantido como alias de leitura para chamadas antigas. A Etapa 12 não
	# classifica campanhas nem seleciona uma campanha "melhor".
	return get_recent_record()


static func get_recent_record() -> Dictionary:
	var records: Array[Dictionary] = get_all_records()
	if records.is_empty():
		return {}
	return records[0].duplicate(true)


static func _write_records(records: Array[Dictionary]) -> bool:
	var serialized: String = JSON.stringify(records, "\t", false)
	if serialized.strip_edges().is_empty():
		return false
	var file: FileAccess = FileAccess.open(RECORDS_TEMP_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(serialized)
	file.flush()
	file.close()
	if FileAccess.get_file_as_string(RECORDS_TEMP_PATH) != serialized:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(RECORDS_TEMP_PATH))
		return false

	var absolute_records: String = ProjectSettings.globalize_path(RECORDS_PATH)
	var absolute_temp: String = ProjectSettings.globalize_path(RECORDS_TEMP_PATH)
	var absolute_backup: String = ProjectSettings.globalize_path(RECORDS_BACKUP_PATH)
	var primary_is_valid: bool = bool(
		_read_records(RECORDS_PATH).get("success", false)
	)
	var backup_is_valid: bool = bool(
		_read_records(RECORDS_BACKUP_PATH).get("success", false)
	)
	var rotated_primary: bool = false
	if FileAccess.file_exists(RECORDS_PATH):
		if not primary_is_valid:
			if DirAccess.remove_absolute(absolute_records) != OK:
				DirAccess.remove_absolute(absolute_temp)
				return false
		else:
			if FileAccess.file_exists(RECORDS_BACKUP_PATH):
				if DirAccess.remove_absolute(absolute_backup) != OK:
					DirAccess.remove_absolute(absolute_temp)
					return false
			if DirAccess.rename_absolute(absolute_records, absolute_backup) != OK:
				DirAccess.remove_absolute(absolute_temp)
				return false
			rotated_primary = true
	if (
		not primary_is_valid
		and FileAccess.file_exists(RECORDS_BACKUP_PATH)
		and not backup_is_valid
	):
		if DirAccess.remove_absolute(absolute_backup) != OK:
			DirAccess.remove_absolute(absolute_temp)
			return false
	var replace_error: Error = DirAccess.rename_absolute(absolute_temp, absolute_records)
	if replace_error != OK:
		if rotated_primary and FileAccess.file_exists(RECORDS_BACKUP_PATH):
			DirAccess.rename_absolute(absolute_backup, absolute_records)
		return false
	return true
