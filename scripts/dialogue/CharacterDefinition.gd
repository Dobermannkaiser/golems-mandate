class_name CharacterDefinition
extends Resource


@export var character_id: String = ""
@export var display_name: String = "Personagem"
@export var species_name: String = ""
@export var pronouns: String = ""
@export var role_name: String = ""
@export_multiline var personality: String = ""
@export_multiline var biography: String = ""
@export_file("*.png") var portrait_path: String = ""
@export var expression_portrait_paths: Dictionary = {}
@export var fallback_color: Color = Color("#6E8064")
@export var is_founder_appearance: bool = false
@export var is_special_npc: bool = false
@export var romance_available: bool = false
@export var hidden_until_story: bool = false


func validate() -> Array[String]:
	var errors: Array[String] = []
	var clean_id: String = character_id.strip_edges()

	if clean_id.is_empty():
		errors.append("O ID do personagem está vazio.")

	if display_name.strip_edges().is_empty():
		errors.append("O nome de exibição está vazio.")

	if species_name.strip_edges().is_empty():
		errors.append("A espécie não foi informada.")

	if portrait_path.strip_edges().is_empty():
		errors.append("O caminho do retrato está vazio.")
	elif not ResourceLoader.exists(portrait_path):
		errors.append("Retrato não encontrado: %s" % portrait_path)

	for expression_value: Variant in expression_portrait_paths.keys():
		var expression: String = String(expression_value).strip_edges()
		var expression_path: String = String(
			expression_portrait_paths.get(expression_value, "")
		).strip_edges()
		if expression.is_empty() or expression_path.is_empty():
			errors.append("Expressão de retrato inválida.")
		elif not ResourceLoader.exists(expression_path):
			errors.append(
				"Retrato da expressão %s não encontrado: %s" % [
					expression,
					expression_path
				]
			)

	return errors


func get_portrait_path(expression: String = "neutral") -> String:
	var clean_expression: String = expression.strip_edges().to_lower()
	var expression_path: String = String(
		expression_portrait_paths.get(clean_expression, "")
	).strip_edges()
	if not expression_path.is_empty():
		return expression_path
	return portrait_path
