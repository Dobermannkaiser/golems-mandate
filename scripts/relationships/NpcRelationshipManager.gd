class_name VillageNpcRelationshipManager
extends RefCounted


const CATALOG = preload("res://scripts/relationships/NpcRelationshipCatalog.gd")
const STATE_VERSION: int = 1

var pair_scores: Dictionary = {}
var resolved_dialogues: Dictionary = {}
var memories: Dictionary = {}
var pending_dialogue: Dictionary = {}


func setup() -> void:
	pair_scores.clear()
	resolved_dialogues.clear()
	memories.clear()
	pending_dialogue.clear()
	for pair: Dictionary in CATALOG.get_all_pairs():
		var key: String = CATALOG.get_pair_key(String(pair.get("a", "")), String(pair.get("b", "")))
		pair_scores[key] = int(pair.get("initial_score", 0))


func export_save_data() -> Dictionary:
	return {
		"state_version": STATE_VERSION,
		"pair_scores": pair_scores.duplicate(true),
		"resolved_dialogues": resolved_dialogues.duplicate(true),
		"memories": memories.duplicate(true),
		"pending_dialogue": pending_dialogue.duplicate(true)
	}


func import_save_data(data: Dictionary) -> bool:
	if int(data.get("state_version", 0)) != STATE_VERSION:
		return false
	var scores_value: Variant = data.get("pair_scores", null)
	var resolved_value: Variant = data.get("resolved_dialogues", null)
	var memories_value: Variant = data.get("memories", null)
	var pending_value: Variant = data.get("pending_dialogue", null)
	if not scores_value is Dictionary or not resolved_value is Dictionary or not memories_value is Dictionary or not pending_value is Dictionary:
		return false
	setup()
	for key_value: Variant in (scores_value as Dictionary).keys():
		var key: String = String(key_value)
		if not pair_scores.has(key):
			continue
		pair_scores[key] = clampi(int((scores_value as Dictionary).get(key, 0)), -100, 100)
	for id_value: Variant in (resolved_value as Dictionary).keys():
		var dialogue_id: String = String(id_value)
		var resolution: Variant = (resolved_value as Dictionary).get(dialogue_id)
		if resolution is Dictionary:
			resolved_dialogues[dialogue_id] = (resolution as Dictionary).duplicate(true)
	for key_value: Variant in (memories_value as Dictionary).keys():
		var key: String = String(key_value)
		var entries: Variant = (memories_value as Dictionary).get(key)
		if entries is Array:
			memories[key] = (entries as Array).duplicate(true)
	pending_dialogue = (pending_value as Dictionary).duplicate(true)
	return pending_dialogue.is_empty() or _pending_is_valid()


func has_pending_dialogue() -> bool:
	return not pending_dialogue.is_empty()


func prepare_for_completed_day(day: int, context: Dictionary) -> Dictionary:
	if has_pending_dialogue():
		return get_pending_conversation()
	var definition: Dictionary = CATALOG.get_dialogue_for_day(day)
	if definition.is_empty() or resolved_dialogues.has(String(definition.get("id", ""))):
		return {}
	var a: String = String(definition.get("a", ""))
	var b: String = String(definition.get("b", ""))
	var known: Dictionary = context.get("known_npcs", {}) as Dictionary
	if not bool(known.get(a, false)) or not bool(known.get(b, false)):
		return {}
	var requirement: Dictionary = _build_reconciliation_requirement(definition, context)
	pending_dialogue = definition.duplicate(true)
	pending_dialogue["requirement"] = requirement
	pending_dialogue["completed_day"] = day
	return get_pending_conversation()


func get_pending_conversation() -> Dictionary:
	if not has_pending_dialogue() or not _pending_is_valid():
		return {}
	var a: String = String(pending_dialogue.get("a", ""))
	var b: String = String(pending_dialogue.get("b", ""))
	var a_data: Dictionary = CATALOG.get_npc(a)
	var b_data: Dictionary = CATALOG.get_npc(b)
	var requirement: Dictionary = pending_dialogue.get("requirement", {}) as Dictionary
	var dialogue_id: String = String(pending_dialogue.get("id", ""))
	var previous: String = _get_previous_memory_text(String(pending_dialogue.get("pair_key", "")))
	var opening_text: String = String(pending_dialogue.get("premise", ""))
	if not previous.is_empty():
		opening_text = "%s\n\nEles ainda se lembram da conversa anterior: %s" % [opening_text, previous]
	var choices: Array[Dictionary] = [
		_choice("support_a", "Apoiar %s." % String(a_data.get("name", "A")), a, b, 20, -10, -20, "support_a"),
		_choice("support_b", "Apoiar %s." % String(b_data.get("name", "B")), a, b, -10, 20, -20, "support_b"),
		_choice("neutral", "Permanecer neutro e pedir que continuem a conversa.", a, b, 0, 0, 2, "neutral"),
		_choice("reconcile", "Conciliar: %s" % String(requirement.get("action_text", "propor um acordo")), a, b, 10, 10, 18, "reconcile")
	]
	choices[3]["disabled"] = not bool(requirement.get("met", false))
	choices[3]["disabled_reason"] = String(requirement.get("description", "Requisito não cumprido."))
	return {
		"id": "npc_relation_%s" % dialogue_id,
		"title": "Relação entre NPCs — %s" % String(pending_dialogue.get("title", "Conversa")),
		"start": "opening",
		"allow_close": false,
		"npc_relationship_dialogue": true,
		"nodes": {
			"opening": {"speaker_id": "", "speaker_name": "Narrador", "hide_portrait": true, "text": opening_text, "choices": choices},
			"reply": {"speaker_id": String(a_data.get("portrait_id", a)), "speaker_name": "%s e %s" % [a_data.get("name", "A"), b_data.get("name", "B")], "expression": "neutral", "text": "A decisão é compreendida pelos dois. O efeito ficará registrado no mapa de relações."}
		}
	}


func resolve_choice(choice: Dictionary) -> Dictionary:
	if not has_pending_dialogue():
		return {"success": false, "message": "Não há conversa obrigatória pendente."}
	var dialogue_id: String = String(pending_dialogue.get("id", ""))
	if resolved_dialogues.has(dialogue_id):
		return {"success": false, "message": "Esta conversa já foi resolvida."}
	var choice_id: String = String(choice.get("npc_relationship_choice", ""))
	if choice_id not in ["support_a", "support_b", "neutral", "reconcile"]:
		return {"success": false, "message": "Resposta inválida."}
	if choice_id == "reconcile" and not bool((pending_dialogue.get("requirement", {}) as Dictionary).get("met", false)):
		return {"success": false, "message": "O requisito de conciliação não foi cumprido."}
	var pair_key: String = String(pending_dialogue.get("pair_key", ""))
	var previous_score: int = int(pair_scores.get(pair_key, 0))
	var pair_delta: int = int(choice.get("npc_pair_delta", 0))
	pair_scores[pair_key] = clampi(previous_score + pair_delta, -100, 100)
	var resolution: Dictionary = {
		"choice_id": choice_id,
		"day": int(pending_dialogue.get("completed_day", 0)),
		"a": String(pending_dialogue.get("a", "")),
		"b": String(pending_dialogue.get("b", "")),
		"player_a_delta": int(choice.get("player_a_delta", 0)),
		"player_b_delta": int(choice.get("player_b_delta", 0)),
		"pair_delta": pair_delta,
		"title": String(pending_dialogue.get("title", "Conversa"))
	}
	resolved_dialogues[dialogue_id] = resolution.duplicate(true)
	var pair_memories: Array = memories.get(pair_key, []) as Array
	pair_memories.append(_choice_memory_text(choice_id, resolution))
	memories[pair_key] = pair_memories
	var completed_day: int = int(pending_dialogue.get("completed_day", 0))
	pending_dialogue.clear()
	return {"success": true, "resolution": resolution, "completed_day": completed_day, "overview": get_overview(), "message": _choice_memory_text(choice_id, resolution)}


func get_overview() -> Dictionary:
	var pairs: Array[Dictionary] = []
	var positive_count: int = 0
	for definition: Dictionary in CATALOG.get_all_pairs():
		var a: String = String(definition.get("a", ""))
		var b: String = String(definition.get("b", ""))
		var key: String = CATALOG.get_pair_key(a, b)
		var score: int = int(pair_scores.get(key, int(definition.get("initial_score", 0))))
		var state: String = get_state_id(score)
		var pair_memories: Array = memories.get(key, []) as Array
		if not pair_memories.is_empty() and state in ["affinity", "strong_bond"]:
			positive_count += 1
		pairs.append({
			"pair_key": key, "a": a, "b": b,
			"a_name": String(CATALOG.get_npc(a).get("name", a)),
			"b_name": String(CATALOG.get_npc(b).get("name", b)),
			"state_id": state, "state_name": get_state_name(state),
			"known": not pair_memories.is_empty(),
			"cause": String(pair_memories.back()) if not pair_memories.is_empty() else "Ainda não compreendido.",
			"resolved_count": pair_memories.size()
		})
	return {"pairs": pairs, "positive_pair_count": positive_count, "production_bonus": 0.01 if positive_count > 0 else 0.0}


func get_production_bonus() -> float:
	return float(get_overview().get("production_bonus", 0.0))


func get_follow_up_comment(day: int) -> String:
	for value: Variant in resolved_dialogues.values():
		if not value is Dictionary:
			continue
		var resolution: Dictionary = value as Dictionary
		if int(resolution.get("day", 0)) + 1 != day:
			continue
		var pair_key: String = CATALOG.get_pair_key(String(resolution.get("a", "")), String(resolution.get("b", "")))
		var entries: Array = memories.get(pair_key, []) as Array
		if not entries.is_empty():
			return "COMENTÁRIO ENTRE PERSONAGENS — %s" % String(entries.back())
	return ""


static func get_state_id(score: int) -> String:
	if score <= -40:
		return "conflict"
	if score <= -10:
		return "tension"
	if score < 25:
		return "neutral"
	if score < 60:
		return "affinity"
	return "strong_bond"


static func get_state_name(state_id: String) -> String:
	return String({"conflict": "Conflito", "tension": "Tensão", "neutral": "Neutro", "affinity": "Afinidade", "strong_bond": "Vínculo forte"}.get(state_id, "Neutro"))


func _build_reconciliation_requirement(definition: Dictionary, context: Dictionary) -> Dictionary:
	var index: int = int(definition.get("index", 0))
	var pair_key: String = String(definition.get("pair_key", ""))
	if index == 1:
		var prior_memories: Array = memories.get(pair_key, []) as Array
		return {"met": not prior_memories.is_empty(), "description": "Requer recordar a primeira conversa deste par.", "action_text": "usar o que foi aprendido na primeira conversa."}
	var selector: int = abs(pair_key.hash()) % 4
	match selector:
		0:
			var points: Dictionary = context.get("relationship_points", {}) as Dictionary
			var a: String = String(definition.get("a", ""))
			var b: String = String(definition.get("b", ""))
			var met: bool = int(points.get(a, 0)) >= 120 or int(points.get(b, 0)) >= 120
			return {"met": met, "description": "Requer pelo menos 120 pontos de amizade com um dos envolvidos.", "action_text": "lembrar algo que um deles confiou a você."}
		1:
			var met: bool = float(context.get("food", 0.0)) >= 50.0
			return {"met": met, "description": "Requer 50 de alimentação disponível.", "action_text": "propor um pequeno teste comunitário com recursos garantidos."}
		2:
			var met: bool = float(context.get("material", 0.0)) >= 40.0
			return {"met": met, "description": "Requer 40 de material disponível.", "action_text": "montar uma solução prática para os dois métodos."}
		_:
			var met: bool = int(context.get("council_size", 0)) >= 4
			return {"met": met, "description": "Requer um Conselho completo com quatro representantes.", "action_text": "dividir responsabilidades com o Conselho."}


func _choice(id: String, text: String, a: String, b: String, a_delta: int, b_delta: int, pair_delta: int, choice_id: String) -> Dictionary:
	return {"id": id, "text": text, "next": "reply", "npc_relationship_choice": choice_id, "npc_a": a, "npc_b": b, "player_a_delta": a_delta, "player_b_delta": b_delta, "npc_pair_delta": pair_delta}


func _choice_memory_text(choice_id: String, resolution: Dictionary) -> String:
	var a_name: String = String(CATALOG.get_npc(String(resolution.get("a", ""))).get("name", "A"))
	var b_name: String = String(CATALOG.get_npc(String(resolution.get("b", ""))).get("name", "B"))
	match choice_id:
		"support_a": return "Você apoiou %s; %s aceitou a decisão, mas a tensão entre os dois aumentou." % [a_name, b_name]
		"support_b": return "Você apoiou %s; %s aceitou a decisão, mas a tensão entre os dois aumentou." % [b_name, a_name]
		"reconcile": return "Você usou uma informação ou recurso conhecido para aproximar %s e %s." % [a_name, b_name]
		_: return "Você permaneceu neutro e deixou %s e %s continuarem a conversa." % [a_name, b_name]


func _get_previous_memory_text(pair_key: String) -> String:
	var entries: Array = memories.get(pair_key, []) as Array
	return String(entries.back()) if not entries.is_empty() else ""


func _pending_is_valid() -> bool:
	return not String(pending_dialogue.get("id", "")).is_empty() and not String(pending_dialogue.get("pair_key", "")).is_empty()
