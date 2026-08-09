class_name VillageDialogueManager
extends RefCounted


var conversation_id: String = ""
var conversation_title: String = ""
var player_speaker_name: String = "Prefeito"
var nodes: Dictionary = {}
var current_node_id: String = ""
var history: Array[Dictionary] = []
var finished: bool = true


func start_conversation(conversation_data: Dictionary) -> bool:
	reset()

	var start_id: String = String(
		conversation_data.get("start", "")
	).strip_edges()
	var nodes_value: Variant = conversation_data.get("nodes", null)

	if start_id.is_empty() or not nodes_value is Dictionary:
		return false

	nodes = (nodes_value as Dictionary).duplicate(true)

	if not nodes.has(start_id):
		reset()
		return false

	conversation_id = String(conversation_data.get("id", "conversation"))
	conversation_title = String(
		conversation_data.get("title", "Conversa")
	)
	player_speaker_name = String(
		conversation_data.get("player_speaker_name", "Prefeito")
	).strip_edges()
	if player_speaker_name.is_empty():
		player_speaker_name = "Prefeito"
	finished = false
	return _move_to_node(start_id)


func reset() -> void:
	conversation_id = ""
	conversation_title = ""
	player_speaker_name = "Prefeito"
	nodes.clear()
	current_node_id = ""
	history.clear()
	finished = true


func is_active() -> bool:
	return not finished and not current_node_id.is_empty()


func get_current_node() -> Dictionary:
	if not is_active():
		return {}

	var node_value: Variant = nodes.get(current_node_id, {})

	if not node_value is Dictionary:
		return {}

	return (node_value as Dictionary).duplicate(true)


func get_current_choices() -> Array[Dictionary]:
	var current: Dictionary = get_current_node()
	var choices_value: Variant = current.get("choices", [])
	var result: Array[Dictionary] = []

	if not choices_value is Array:
		return result

	for choice_value: Variant in choices_value:
		if choice_value is Dictionary:
			result.append((choice_value as Dictionary).duplicate(true))

	return result


func advance() -> Dictionary:
	if not is_active():
		return {"advanced": false, "finished": true}

	if not get_current_choices().is_empty():
		return {
			"advanced": false,
			"finished": false,
			"requires_choice": true
		}

	var current: Dictionary = get_current_node()
	var next_id: String = String(current.get("next", "")).strip_edges()

	if next_id.is_empty():
		finished = true
		current_node_id = ""
		return {"advanced": true, "finished": true}

	if not _move_to_node(next_id):
		finished = true
		current_node_id = ""
		return {
			"advanced": false,
			"finished": true,
			"error": "O próximo trecho de diálogo não existe."
		}

	return {
		"advanced": true,
		"finished": false,
		"node": get_current_node()
	}


func choose(choice_id: String) -> Dictionary:
	if not is_active():
		return {"chosen": false, "finished": true}

	var clean_choice_id: String = choice_id.strip_edges()
	var selected_choice: Dictionary = {}

	for choice: Dictionary in get_current_choices():
		if String(choice.get("id", "")) == clean_choice_id:
			selected_choice = choice
			break

	if selected_choice.is_empty():
		return {
			"chosen": false,
			"finished": false,
			"error": "A resposta escolhida não existe."
		}

	history.append(
		{
			"speaker_id": "prefeito",
			"speaker_name": player_speaker_name,
			"text": String(selected_choice.get("text", "...")),
			"is_player": true
		}
	)

	var next_id: String = String(
		selected_choice.get("next", "")
	).strip_edges()

	if next_id.is_empty():
		finished = true
		current_node_id = ""
		return {
			"chosen": true,
			"finished": true,
			"choice": selected_choice.duplicate(true)
		}

	if not _move_to_node(next_id):
		finished = true
		current_node_id = ""
		return {
			"chosen": false,
			"finished": true,
			"error": "O destino da resposta não existe."
		}

	return {
		"chosen": true,
		"finished": false,
		"node": get_current_node(),
		"choice": selected_choice.duplicate(true)
	}


func get_history() -> Array[Dictionary]:
	return history.duplicate(true)


func get_history_text() -> String:
	if history.is_empty():
		return "Nenhuma fala foi registrada nesta conversa."

	var lines: Array[String] = []

	for entry: Dictionary in history:
		var speaker_name: String = String(
			entry.get("speaker_name", "Personagem")
		)
		var text: String = String(entry.get("text", ""))
		lines.append("%s\n%s" % [speaker_name.to_upper(), text])

	return "\n\n✦  ✦  ✦\n\n".join(lines)


func _move_to_node(node_id: String) -> bool:
	var clean_node_id: String = node_id.strip_edges()
	var node_value: Variant = nodes.get(clean_node_id, null)

	if clean_node_id.is_empty() or not node_value is Dictionary:
		return false

	current_node_id = clean_node_id
	var node: Dictionary = node_value as Dictionary
	var text: String = String(node.get("text", "")).strip_edges()

	if not text.is_empty():
		history.append(
			{
				"speaker_id": String(node.get("speaker_id", "narrador")),
				"speaker_name": String(
					node.get("speaker_name", "Narrador")
				),
				"text": text,
				"is_player": false
			}
		)

	return true
