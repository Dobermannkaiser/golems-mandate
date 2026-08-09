class_name VillageCharacterCatalog
extends RefCounted


const CHARACTER_DIRECTORY: String = "res://characters"
const FALLBACK_PORTRAIT_ID: String = "passos_leves_andarilho"

# O catálogo é imutável durante uma campanha. Mantê-lo em cache evita
# reabrir a pasta e recarregar todos os .tres sempre que uma carta,
# diálogo ou janela de relacionamento solicita um retrato.
static var _cache_ready: bool = false
static var _definitions_cache: Array[CharacterDefinition] = []
static var _definitions_by_id: Dictionary = {}
static var _founder_appearance_ids_cache: Array[String] = []
static var _portrait_texture_cache: Dictionary = {}


static func invalidate_cache() -> void:
	_cache_ready = false
	_definitions_cache.clear()
	_definitions_by_id.clear()
	_founder_appearance_ids_cache.clear()
	_portrait_texture_cache.clear()


static func _ensure_cache() -> void:
	if _cache_ready:
		return

	_cache_ready = true
	_definitions_cache.clear()
	_definitions_by_id.clear()
	_founder_appearance_ids_cache.clear()

	var directory: DirAccess = DirAccess.open(CHARACTER_DIRECTORY)
	if directory == null:
		push_error("Não foi possível abrir o catálogo de personagens.")
		return

	var filenames: PackedStringArray = directory.get_files()
	filenames.sort()

	for filename: String in filenames:
		if not filename.ends_with(".tres"):
			continue

		var path: String = "%s/%s" % [CHARACTER_DIRECTORY, filename]
		var resource: Resource = ResourceLoader.load(path)

		if not resource is CharacterDefinition:
			push_warning("Cadastro inválido ignorado: %s" % path)
			continue

		var definition: CharacterDefinition = resource as CharacterDefinition
		_definitions_cache.append(definition)

		var character_id: String = definition.character_id.strip_edges()
		if not character_id.is_empty() and not _definitions_by_id.has(character_id):
			_definitions_by_id[character_id] = definition

		if definition.is_founder_appearance:
			_founder_appearance_ids_cache.append(character_id)


static func load_all() -> Array[CharacterDefinition]:
	_ensure_cache()
	var definitions: Array[CharacterDefinition] = []
	for definition: CharacterDefinition in _definitions_cache:
		definitions.append(definition)
	return definitions


static func get_by_id(character_id: String) -> CharacterDefinition:
	_ensure_cache()
	var clean_id: String = character_id.strip_edges()
	var value: Variant = _definitions_by_id.get(clean_id)
	if value is CharacterDefinition:
		return value as CharacterDefinition
	return null


static func get_founder_appearance_ids() -> Array[String]:
	_ensure_cache()
	var result: Array[String] = []
	for character_id: String in _founder_appearance_ids_cache:
		result.append(character_id)
	return result


static func get_portrait_path(
	character_id: String,
	expression: String = "neutral"
) -> String:
	var definition: CharacterDefinition = get_by_id(character_id)

	if definition == null:
		definition = get_by_id(FALLBACK_PORTRAIT_ID)

	if definition == null:
		return ""

	return definition.get_portrait_path(expression)


static func get_portrait_texture(
	character_id: String,
	expression: String = "neutral"
) -> Texture2D:
	var path: String = get_portrait_path(character_id, expression)

	if path.is_empty() or not ResourceLoader.exists(path):
		return null

	var cached_value: Variant = _portrait_texture_cache.get(path)
	if cached_value is Texture2D:
		return cached_value as Texture2D

	var texture: Texture2D = ResourceLoader.load(path) as Texture2D
	if texture != null:
		_portrait_texture_cache[path] = texture
	return texture


static func validate_catalog() -> Dictionary:
	var definitions: Array[CharacterDefinition] = load_all()
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var ids: Dictionary = {}
	var founder_count: int = 0

	for definition: CharacterDefinition in definitions:
		var character_id: String = definition.character_id.strip_edges()

		if ids.has(character_id):
			errors.append("ID de personagem duplicado: %s" % character_id)
		else:
			ids[character_id] = true

		for validation_error: String in definition.validate():
			errors.append("%s: %s" % [character_id, validation_error])

		if definition.is_founder_appearance:
			founder_count += 1

	if definitions.is_empty():
		errors.append("Nenhum personagem foi cadastrado.")

	if founder_count < 4:
		errors.append(
			"São necessários ao menos quatro bustos genéricos de fundadores."
		)
	elif founder_count == 4:
		warnings.append(
			"Existem quatro bustos genéricos de fundadores; cartas adicionais usam retratos cadastrados por espécie."
		)

	if not ids.has("mimo"):
		errors.append("O cadastro fixo de Mimo está ausente.")

	return {
		"success": errors.is_empty(),
		"definitions": definitions.size(),
		"founder_appearances": founder_count,
		"errors": errors,
		"warnings": warnings
	}
