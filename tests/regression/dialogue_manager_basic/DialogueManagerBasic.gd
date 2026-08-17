extends Node


const DialogueManagerScript = preload("res://scripts/dialogue/DialogueManager.gd")


func _ready() -> void:
	var linear_ok: bool = _run_linear_case()
	var choice_ok: bool = _run_choice_case()
	if linear_ok and choice_ok:
		print("DIALOGUE_MANAGER_BASIC_OK")
	else:
		print(
			"DIALOGUE_MANAGER_BASIC_FAILED linear=%s choice=%s"
			% [linear_ok, choice_ok]
		)


func _run_linear_case() -> bool:
	var manager = DialogueManagerScript.new()
	var conversation: Dictionary = {
		"id": "dialogue_basic_linear",
		"title": "Fluxo linear",
		"start": "intro",
		"nodes": {
			"intro": {
				"speaker_name": "Narrador",
				"text": "Início",
				"next": "ending"
			},
			"ending": {
				"speaker_name": "Narrador",
				"text": "Fim"
			}
		}
	}
	var started: bool = manager.start_conversation(conversation)
	var start_text: String = String(manager.get_current_node().get("text", ""))
	var moved: Dictionary = manager.advance()
	var ending_text: String = String(manager.get_current_node().get("text", ""))
	var finished: Dictionary = manager.advance()
	return (
		started
		and start_text == "Início"
		and bool(moved.get("advanced", false))
		and ending_text == "Fim"
		and bool(finished.get("advanced", false))
		and bool(finished.get("finished", false))
		and manager.get_history().size() == 2
		and not manager.is_active()
	)


func _run_choice_case() -> bool:
	var manager = DialogueManagerScript.new()
	var conversation: Dictionary = {
		"id": "dialogue_basic_choice",
		"title": "Fluxo com escolha",
		"start": "question",
		"player_speaker_name": "Prefeito de Teste",
		"nodes": {
			"question": {
				"speaker_name": "Conselheira",
				"text": "Pergunta",
				"choices": [
					{"id": "right", "text": "Escolha correta", "next": "accepted"},
					{"id": "other", "text": "Outra escolha", "next": "rejected"}
				]
			},
			"accepted": {"speaker_name": "Conselheira", "text": "Destino correto"},
			"rejected": {"speaker_name": "Conselheira", "text": "Destino alternativo"}
		}
	}
	var started: bool = manager.start_conversation(conversation)
	var choices: Array[Dictionary] = manager.get_current_choices()
	var rejected: Dictionary = manager.choose("missing_choice")
	var still_on_question: bool = String(manager.get_current_node().get("text", "")) == "Pergunta"
	var chosen: Dictionary = manager.choose("right")
	var destination_ok: bool = String(manager.get_current_node().get("text", "")) == "Destino correto"
	var history: Array[Dictionary] = manager.get_history()
	var player_entry_ok: bool = (
		history.size() == 3
		and bool(history[1].get("is_player", false))
		and String(history[1].get("speaker_name", "")) == "Prefeito de Teste"
		and String(history[1].get("text", "")) == "Escolha correta"
	)
	var finished: Dictionary = manager.advance()
	return (
		started
		and choices.size() == 2
		and not bool(rejected.get("chosen", false))
		and still_on_question
		and bool(chosen.get("chosen", false))
		and destination_ok
		and player_entry_ok
		and bool(finished.get("finished", false))
		and not manager.is_active()
	)
