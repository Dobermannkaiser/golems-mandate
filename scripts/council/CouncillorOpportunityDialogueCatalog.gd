class_name CouncillorOpportunityDialogueCatalog
extends RefCounted


const OPPORTUNITY_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncillorOpportunityCatalog.gd"
)


static func create_conversation(
	opportunity: Dictionary,
	resources: Dictionary = {}
) -> Dictionary:
	if opportunity.is_empty():
		return {}
	var opportunity_id: String = String(
		opportunity.get("opportunity_id", "")
	).strip_edges()
	var representative_id: String = String(
		opportunity.get("representative_id", "")
	).strip_edges()
	var template_id: String = String(opportunity.get("template_id", "")).strip_edges()
	if opportunity_id.is_empty() or representative_id.is_empty() or template_id.is_empty():
		return {}
	var template: Dictionary = OPPORTUNITY_CATALOG_SCRIPT.get_template(template_id)
	if template.is_empty():
		return {}
	var display_name: String = String(
		opportunity.get("display_name", "Conselheiro")
	)
	var portrait_id: String = String(opportunity.get("portrait_id", ""))
	var personality_id: String = String(
		opportunity.get("personality_id", "practical")
	)
	var choices_value: Variant = opportunity.get("choices", [])
	if not choices_value is Array:
		return {}
	var dialogue_choices: Array[Dictionary] = []
	var nodes: Dictionary = {}
	for choice_value: Variant in choices_value as Array:
		if not choice_value is Dictionary:
			continue
		var choice: Dictionary = choice_value as Dictionary
		var choice_id: String = String(choice.get("id", "")).strip_edges()
		if choice_id.is_empty():
			continue
		var result_node_id: String = "result_%s" % choice_id
		var immediate: Dictionary = choice.get("immediate", {})
		var disabled_reason: String = _get_unaffordable_reason(immediate, resources)
		dialogue_choices.append(
			{
				"id": choice_id,
				"text": String(choice.get("text", "Escolher este caminho.")),
				"next": result_node_id,
				"disabled": not disabled_reason.is_empty(),
				"disabled_reason": disabled_reason,
				"councillor_opportunity_id": opportunity_id,
				"councillor_representative_id": representative_id,
				"councillor_choice_id": choice_id
			}
		)
		nodes[result_node_id] = {
			"speaker_id": portrait_id,
			"speaker_name": display_name,
			"expression": "neutral",
			"text": (
				String(choice.get("result", "Vou cuidar disso."))
				+ "\n\n"
				+ OPPORTUNITY_CATALOG_SCRIPT.get_personality_commitment(
					personality_id
				)
			)
		}
	if dialogue_choices.size() != 3:
		return {}
	nodes["context"] = {
		"speaker_id": "",
		"speaker_name": "Narrador",
		"hide_portrait": true,
		"text": String(template.get("intro", "Há uma decisão a tomar.")),
		"next": "intro"
	}
	nodes["intro"] = {
		"speaker_id": portrait_id,
		"speaker_name": display_name,
		"expression": "neutral",
		"text": OPPORTUNITY_CATALOG_SCRIPT.get_personality_opening(
			personality_id
		),
		"choices": dialogue_choices
	}
	return {
		"id": opportunity_id,
		"title": String(template.get("title", "ASSUNTO DO CONSELHO")),
		"start": "context",
		"allow_close": true,
		"nodes": nodes
	}


static func _get_unaffordable_reason(
	immediate: Dictionary,
	resources: Dictionary
) -> String:
	var missing: Array[String] = []
	for row: Dictionary in [
		{"id": "food", "name": "alimentação"},
		{"id": "material", "name": "material"},
		{"id": "happiness", "name": "felicidade"}
	]:
		var resource_id: String = String(row.get("id", ""))
		var delta: float = float(immediate.get(resource_id, 0.0))
		if delta >= 0.0:
			continue
		var available: float = float(resources.get(resource_id, 0.0))
		if available + delta < 0.0:
			missing.append(
				"%.0f de %s" % [-delta, String(row.get("name", resource_id))]
			)
	return (
		"Recursos insuficientes: %s." % ", ".join(missing)
		if not missing.is_empty()
		else ""
	)
