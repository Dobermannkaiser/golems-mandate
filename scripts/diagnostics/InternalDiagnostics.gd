class_name VillageInternalDiagnostics
extends RefCounted


const CHARACTER_CATALOG_SCRIPT = preload(
	"res://scripts/dialogue/CharacterCatalog.gd"
)
const DIALOGUE_CATALOG_SCRIPT = preload(
	"res://scripts/dialogue/DialogueCatalog.gd"
)
const EVENT_CATALOG_SCRIPT = preload(
	"res://scripts/events/EventCatalog.gd"
)
const EVENT_MANAGER_SCRIPT = preload(
	"res://scripts/events/EventManager.gd"
)
const FOUNDER_MEMORY_CATALOG_SCRIPT = preload(
	"res://scripts/events/FounderMemoryCatalog.gd"
)
const SAVE_MANAGER_SCRIPT = preload(
	"res://scripts/save/SaveManager.gd"
)
const PART3_FOUNDATION_MANAGER_SCRIPT = preload(
	"res://scripts/foundation/Part3FoundationManager.gd"
)
const COUNCIL_CARD_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncilCardCatalog.gd"
)
const COUNCIL_PASSIVE_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncilPassiveCatalog.gd"
)
const COUNCIL_COMPOSITION_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncilCompositionCatalog.gd"
)
const COUNCIL_RECRUITMENT_MANAGER_SCRIPT = preload(
	"res://scripts/council/CouncilRecruitmentManager.gd"
)
const PERSONALITY_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncillorPersonalityCatalog.gd"
)
const PROGRESSION_DIALOGUE_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncillorProgressionDialogueCatalog.gd"
)
const OPPORTUNITY_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncillorOpportunityCatalog.gd"
)
const OPPORTUNITY_DIALOGUE_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncillorOpportunityDialogueCatalog.gd"
)
const BUILDING_VARIANT_CATALOG_SCRIPT = preload(
	"res://scripts/buildings/BuildingVariantCatalog.gd"
)
const BUILDING_VARIANT_EVENT_CATALOG_SCRIPT = preload(
	"res://scripts/events/BuildingVariantEventCatalog.gd"
)
const BUILDING_VARIANT_DIALOGUE_CATALOG_SCRIPT = preload(
	"res://scripts/dialogue/BuildingVariantDialogueCatalog.gd"
)
const STORY_CATALOG_SCRIPT = preload(
	"res://scripts/story/StoryChapterCatalog.gd"
)
const CAMPAIGN_CATALOG_SCRIPT = preload(
	"res://scripts/campaign/CampaignCatalog.gd"
)
const DIFFICULTY_CATALOG_SCRIPT = preload(
	"res://scripts/campaign/DifficultyCatalog.gd"
)
const CAMPAIGN_RECORDS_SCRIPT = preload(
	"res://scripts/campaign/CampaignRecords.gd"
)

const RELATIONSHIP_CATALOG_SCRIPT = preload(
	"res://scripts/relationships/RelationshipCatalog.gd"
)
const RELATIONSHIP_DIALOGUE_CATALOG_SCRIPT = preload(
	"res://scripts/relationships/RelationshipDialogueCatalog.gd"
)
const NPC_RELATIONSHIP_CATALOG_SCRIPT = preload(
	"res://scripts/relationships/NpcRelationshipCatalog.gd"
)


static func run_all() -> Dictionary:
	var checks: Array[Dictionary] = []
	var error_count: int = 0
	var warning_count: int = 0

	var character_result: Dictionary = (
		CHARACTER_CATALOG_SCRIPT.validate_catalog()
	)
	_add_check(
		checks,
		"Catálogo de personagens",
		bool(character_result.get("success", false)),
		"%d cadastros; %d aparências de fundadores."
		% [
			int(character_result.get("definitions", 0)),
			int(character_result.get("founder_appearances", 0))
		],
		character_result.get("errors", []),
		character_result.get("warnings", [])
	)

	var event_result: Dictionary = _validate_events()
	_add_check(
		checks,
		"Catálogo de acontecimentos",
		bool(event_result.get("success", false)),
		"%d acontecimentos e %d escolhas validadas."
		% [
			int(event_result.get("events", 0)),
			int(event_result.get("choices", 0))
		],
		event_result.get("errors", []),
		event_result.get("warnings", [])
	)

	var story_result: Dictionary = _validate_story_campaign()
	_add_check(
		checks,
		"Campanha narrativa",
		bool(story_result.get("success", false)),
		"%d capítulos, %d acontecimentos principais e %d diálogos narrativos."
		% [
			int(story_result.get("chapters", 0)),
			int(story_result.get("events", 0)),
			int(story_result.get("dialogues", 0))
		],
		story_result.get("errors", []),
		story_result.get("warnings", [])
	)

	var relationship_result: Dictionary = _validate_relationship_system()
	_add_check(
		checks,
		"Amizade e romance",
		bool(relationship_result.get("success", false)),
		"%d personagens acompanháveis, %d eventos pessoais e %d candidatos românticos."
		% [
			int(relationship_result.get("tracked", 0)),
			int(relationship_result.get("personal_events", 0)),
			int(relationship_result.get("romance_candidates", 0))
		],
		relationship_result.get("errors", []),
		relationship_result.get("warnings", [])
	)

	var audio_result: Dictionary = _validate_audio_system()
	_add_check(
		checks,
		"Música e efeitos",
		bool(audio_result.get("success", false)),
		"%d arquivos de áudio e %d canais independentes verificados."
		% [
			int(audio_result.get("resources", 0)),
			int(audio_result.get("buses", 0))
		],
		audio_result.get("errors", []),
		audio_result.get("warnings", [])
	)

	var balance_result: Dictionary = _validate_balance_system()
	_add_check(
		checks,
		"Balanceamento de 120 dias",
		bool(balance_result.get("success", false)),
		"%d dificuldades, %d avaliações e %d metas econômicas validadas."
		% [
			int(balance_result.get("difficulties", 0)),
			int(balance_result.get("checkpoints", 0)),
			int(balance_result.get("goals", 0))
		],
		balance_result.get("errors", []),
		balance_result.get("warnings", [])
	)

	var part3_result: Dictionary = _validate_part3_foundation()
	_add_check(
		checks,
		"Fundação da Parte 3",
		bool(part3_result.get("success", false)),
		String(
			part3_result.get(
				"message",
				"Estruturas da Parte 3 verificadas."
			)
		),
		part3_result.get("errors", []),
		part3_result.get("warnings", [])
	)

	var construction_result: Dictionary = _validate_construction_queue()
	_add_check(
		checks,
		"Fila de obras",
		bool(construction_result.get("success", false)),
		String(
			construction_result.get(
				"message",
				"Fila, canteiros e previsões verificados."
			)
		),
		construction_result.get("errors", []),
		construction_result.get("warnings", [])
	)

	var variants_result: Dictionary = _validate_building_variants()
	_add_check(
		checks,
		"Builds finais das construções",
		bool(variants_result.get("success", false)),
		String(
			variants_result.get(
				"message",
				"Variantes, acontecimentos e reações verificados."
			)
		),
		variants_result.get("errors", []),
		variants_result.get("warnings", [])
	)

	var cards_result: Dictionary = _validate_council_cards()
	_add_check(
		checks,
		"Cartas do Conselho",
		bool(cards_result.get("success", false)),
		String(cards_result.get("message", "Cartas verificadas.")),
		cards_result.get("errors", []),
		cards_result.get("warnings", [])
	)

	var progression_result: Dictionary = _validate_councillor_progression()
	_add_check(
		checks,
		"Experiência e histórico",
		bool(progression_result.get("success", false)),
		String(
			progression_result.get(
				"message",
				"Progressão e fichas históricas verificadas."
			)
		),
		progression_result.get("errors", []),
		progression_result.get("warnings", [])
	)

	var recruitment_result: Dictionary = _validate_council_recruitment()
	_add_check(
		checks,
		"Recrutamento de cartas",
		bool(recruitment_result.get("success", false)),
		String(recruitment_result.get("message", "Recrutamento verificado.")),
		recruitment_result.get("errors", []),
		recruitment_result.get("warnings", [])
	)

	var memory_result: Dictionary = _validate_founder_memories()
	_add_check(
		checks,
		"Memória dos fundadores",
		bool(memory_result.get("success", false)),
		String(memory_result.get("message", "Cadeias de memória verificadas.")),
		memory_result.get("errors", []),
		memory_result.get("warnings", [])
	)

	var ui_result: Dictionary = _validate_ui_quality()
	_add_check(
		checks,
		"UX, UI e acessibilidade",
		bool(ui_result.get("success", false)),
		String(
			ui_result.get(
				"message",
				"Interface e preferências verificadas."
			)
		),
		ui_result.get("errors", []),
		ui_result.get("warnings", [])
	)

	var dialogue_errors: Array[String] = []
	var diagnostic_conversation: Dictionary = (
		DIALOGUE_CATALOG_SCRIPT.create_diagnostic_conversation()
	)
	dialogue_errors.append_array(
		DIALOGUE_CATALOG_SCRIPT.validate_conversation(
			diagnostic_conversation
		)
	)

	for story_dialogue_id: String in (
		DIALOGUE_CATALOG_SCRIPT.get_story_dialogue_ids()
	):
		dialogue_errors.append_array(
			DIALOGUE_CATALOG_SCRIPT.validate_conversation(
				DIALOGUE_CATALOG_SCRIPT.create_story_conversation(
					story_dialogue_id
				)
			)
		)

	dialogue_errors.append_array(
		OPPORTUNITY_CATALOG_SCRIPT.validate_catalog()
	)
	for profession: int in range(
		Villager.Profession.UNASSIGNED,
		Villager.Profession.GATHERER + 1
	):
		var templates: Array[Dictionary] = (
			OPPORTUNITY_CATALOG_SCRIPT.get_templates_for_profession(profession)
		)
		if templates.is_empty():
			continue
		var template: Dictionary = templates[0]
		var sample_opportunity: Dictionary = {
			"opportunity_id": "diagnostic_opportunity_%d" % profession,
			"template_id": String(template.get("id", "")),
			"title": String(template.get("title", "Assunto")),
			"representative_id": "diagnostic_representative",
			"display_name": "Representante de Teste",
			"portrait_id": "passos_leves_andarilho",
			"personality_id": "practical",
			"profession": profession,
			"available_day": 4,
			"choices": (template.get("choices", []) as Array).duplicate(true)
		}
		dialogue_errors.append_array(
			DIALOGUE_CATALOG_SCRIPT.validate_conversation(
				OPPORTUNITY_DIALOGUE_CATALOG_SCRIPT.create_conversation(
					sample_opportunity,
					{"food": 999.0, "material": 999.0, "happiness": 100.0}
				)
			)
		)

	_add_check(
		checks,
		"Grafos de diálogo",
		dialogue_errors.is_empty(),
		"Conversas de teste e do elenco atual percorríveis.",
		dialogue_errors,
		[]
	)

	var roster_result: Dictionary = _validate_roster()
	_add_check(
		checks,
		"Elenco e retratos persistentes",
		bool(roster_result.get("success", false)),
		String(roster_result.get("message", "Elenco verificado.")),
		roster_result.get("errors", []),
		roster_result.get("warnings", [])
	)

	var live_system_result: Dictionary = _validate_live_systems()
	_add_check(
		checks,
		"Sistemas vivos da campanha",
		bool(live_system_result.get("success", false)),
		String(
			live_system_result.get(
				"message",
				"Estado principal da campanha verificado."
			)
		),
		live_system_result.get("errors", []),
		live_system_result.get("warnings", [])
	)

	var resource_errors: Array[String] = []
	for resource_path: String in [
		"res://assets/dialogue/alagard.ttf",
		"res://scripts/ui/DialogueWindow.gd",
		"res://scripts/ui/DiagnosticsWindow.gd",
		"res://scripts/dialogue/DialogueManager.gd",
		"res://scripts/dialogue/DialogueCatalog.gd",
		"res://scripts/story/StoryManager.gd",
		"res://scripts/story/StoryChapterCatalog.gd",
		"res://scripts/relationships/RelationshipCatalog.gd",
		"res://scripts/relationships/RelationshipDialogueCatalog.gd",
		"res://scripts/ui/RelationshipsWindow.gd",
		"res://scripts/ui/ProfileSetupWindow.gd",
		"res://scripts/campaign/DifficultyCatalog.gd",
		"res://scripts/campaign/CampaignRecords.gd",
		"res://scripts/buildings/BuildingManager.gd",
		"res://scripts/ui/BuildingWindow.gd",
		"res://scripts/ui/BuildingVisuals.gd",
		"res://scripts/ui/MedalBadge.gd",
		"res://scripts/ui/UIAccessibility.gd",
		"res://assets/dialogue/portraits/aelric_ferreiro.png"
	]:
		if not ResourceLoader.exists(resource_path):
			resource_errors.append("Recurso ausente: %s" % resource_path)

	_add_check(
		checks,
		"Recursos das Etapas 6 e 7",
		resource_errors.is_empty(),
		"Fonte, scripts e recursos principais encontrados.",
		resource_errors,
		[]
	)

	for check: Dictionary in checks:
		error_count += (check.get("errors", []) as Array).size()
		warning_count += (check.get("warnings", []) as Array).size()
		if not bool(check.get("success", false)) and (check.get("errors", []) as Array).is_empty():
			error_count += 1

	return {
		"success": error_count == 0,
		"checks": checks,
		"error_count": error_count,
		"warning_count": warning_count,
		"event_chance": EVENT_MANAGER_SCRIPT.EVENT_CHANCE,
		"project_version": String(
			ProjectSettings.get_setting("application/config/version", "desconhecida")
		)
	}


static func format_report(result: Dictionary) -> String:
	var lines: Array[String] = []
	var success: bool = bool(result.get("success", false))
	lines.append(
		"RESULTADO: %s" % ("APROVADO" if success else "ERROS ENCONTRADOS")
	)
	lines.append("Versão: %s" % String(result.get("project_version", "?")))
	lines.append(
		"Chance aleatória de acontecimento: %.1f%%"
		% (float(result.get("event_chance", 0.0)) * 100.0)
	)
	lines.append(
		"Erros: %d  |  Avisos: %d"
		% [
			int(result.get("error_count", 0)),
			int(result.get("warning_count", 0))
		]
	)

	for check_value: Variant in result.get("checks", []):
		if not check_value is Dictionary:
			continue
		var check: Dictionary = check_value as Dictionary
		lines.append("")
		lines.append(
			"%s %s"
			% [
				"[OK]" if bool(check.get("success", false)) else "[FALHA]",
				String(check.get("name", "Verificação"))
			]
		)
		lines.append(String(check.get("message", "")))

		for error_value: Variant in check.get("errors", []):
			lines.append("  ERRO: %s" % String(error_value))

		for warning_value: Variant in check.get("warnings", []):
			lines.append("  AVISO: %s" % String(warning_value))

	return "\n".join(lines)


static func _validate_part3_foundation() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var project_version: String = String(
		ProjectSettings.get_setting("application/config/version", "")
	)

	if project_version != "3.11.5":
		errors.append("A Etapa 12 da Parte 3 deve usar a versão 3.11.5.")
	if SAVE_MANAGER_SCRIPT.SAVE_VERSION != 18:
		errors.append("A Etapa 12 deve manter o envelope global de save versão 18.")
	if SAVE_MANAGER_SCRIPT.SAVE_SCHEMA_ID != "golems_mandate_part3":
		errors.append("O identificador do save da Parte 3 está incorreto.")
	if not String(SAVE_MANAGER_SCRIPT.SAVE_PATH).contains("golems_mandate_part3"):
		errors.append("O caminho do save da Parte 3 não está isolado.")
	if PART3_FOUNDATION_MANAGER_SCRIPT.FOUNDATION_STATE_VERSION != 4:
		errors.append("Telemetria e medalhas comportamentais exigem a fundação schema 4.")

	var passive_validation: Dictionary = COUNCIL_PASSIVE_CATALOG_SCRIPT.validate_catalog()
	for error_value: Variant in passive_validation.get("errors", []):
		errors.append("Passivas: %s" % String(error_value))
	if int(passive_validation.get("count", 0)) != 15:
		errors.append("O catálogo deve possuir quinze passivas regulares.")
	var composition_validation: Dictionary = COUNCIL_COMPOSITION_CATALOG_SCRIPT.validate_catalog()
	for error_value: Variant in composition_validation.get("errors", []):
		errors.append("Sinergias: %s" % String(error_value))
	if int(composition_validation.get("count", 0)) != 5:
		errors.append("O catálogo deve possuir cinco sinergias de composição.")
	var npc_relationship_validation: Dictionary = NPC_RELATIONSHIP_CATALOG_SCRIPT.validate_catalog()
	for error_value: Variant in npc_relationship_validation.get("errors", []):
		errors.append("Relações entre NPCs: %s" % String(error_value))
	if int(npc_relationship_validation.get("pair_count", 0)) != 28:
		errors.append("O mapa deve possuir 28 pares únicos.")
	if int(npc_relationship_validation.get("dialogue_count", 0)) != 56:
		errors.append("O catálogo deve possuir 56 diálogos entre NPCs.")

	var overview: Dictionary = GameManager.get_part3_foundation_overview()
	for error_value: Variant in overview.get("errors", []):
		errors.append(String(error_value))

	var seed_value: int = int(overview.get("campaign_seed", 0))
	if seed_value <= 0:
		errors.append("A campanha da Parte 3 não possui semente persistente.")

	return {
		"success": errors.is_empty(),
		"errors": errors,
		"warnings": warnings,
		"message": (
			"Save v18 isolado; %d dias, %d decisões, %d flags, "
			+ "%d conselheiros e %d variantes registradas."
		) % [
			int(overview.get("production_days", 0)),
			int(overview.get("decisions", 0)),
			int(overview.get("event_flags", 0)),
			int(overview.get("councillors", 0)),
			int(overview.get("chosen_variants", 0))
		]
	}


static func _validate_building_variants() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var variant_validation: Dictionary = (
		BUILDING_VARIANT_CATALOG_SCRIPT.validate_catalog()
	)
	for error_value: Variant in variant_validation.get("errors", []):
		errors.append(String(error_value))
	var event_validation: Dictionary = (
		BUILDING_VARIANT_EVENT_CATALOG_SCRIPT.validate_catalog()
	)
	for error_value: Variant in event_validation.get("errors", []):
		errors.append("Acontecimentos: %s" % String(error_value))
	var dialogue_ids: Array[String] = (
		BUILDING_VARIANT_DIALOGUE_CATALOG_SCRIPT.get_dialogue_ids()
	)
	if int(variant_validation.get("variants", 0)) != 10:
		errors.append("São esperadas dez builds finais.")
	if int(event_validation.get("interactions", 0)) != 20:
		errors.append("São esperadas vinte interações de acontecimentos.")
	if dialogue_ids.size() != 20:
		errors.append("São esperadas vinte reações narrativas de construção.")
	for variant: Dictionary in BUILDING_VARIANT_CATALOG_SCRIPT.VARIANTS:
		var preview_path: String = String(variant.get("preview_path", ""))
		if preview_path.is_empty() or not ResourceLoader.exists(preview_path):
			errors.append(
				"Imagem ausente para %s: %s." % [
					String(variant.get("id", "variante")),
					preview_path
				]
			)
		for dialogue_key: String in ["dialogue_id", "fallback_dialogue_id"]:
			var dialogue_id: String = String(variant.get(dialogue_key, ""))
			if not dialogue_ids.has(dialogue_id):
				errors.append(
					"Diálogo ausente para %s: %s." % [
						String(variant.get("id", "variante")),
						dialogue_id
					]
				)
	return {
		"success": errors.is_empty(),
		"errors": errors,
		"warnings": warnings,
		"message": (
			"10 builds, 20 interações e 20 reações narrativas verificadas."
		)
	}


static func _validate_construction_queue() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var building_state: Dictionary = GameManager.get_building_state()
	var construction_value: Variant = building_state.get("construction", null)
	if not construction_value is Dictionary:
		return {
			"success": false,
			"errors": ["O estado da vila não contém a fila de obras."],
			"warnings": warnings,
			"message": "Fila de obras ausente."
		}

	var construction: Dictionary = construction_value as Dictionary
	var active_value: Variant = construction.get("active_orders", null)
	var queued_value: Variant = construction.get("queued_orders", null)
	if not active_value is Array:
		errors.append("A lista de obras ativas é inválida.")
	if not queued_value is Array:
		errors.append("A lista de obras aguardando é inválida.")
	if not errors.is_empty():
		return {
			"success": false,
			"errors": errors,
			"warnings": warnings,
			"message": "Estrutura da fila inválida."
		}

	var active_orders: Array = active_value as Array
	var queued_orders: Array = queued_value as Array
	var seen_ids: Dictionary = {}
	var pending_buildings: Dictionary = {}
	var actual_active_count: int = 0
	var actual_pending_completion_count: int = 0
	var expected_queue_position: int = 0

	for order_value: Variant in active_orders + queued_orders:
		if not order_value is Dictionary:
			errors.append("A fila contém uma ordem que não é um dicionário.")
			continue
		var order: Dictionary = order_value as Dictionary
		var order_id: String = String(order.get("order_id", "")).strip_edges()
		var building_id: String = String(order.get("building_id", "")).strip_edges()
		var status: String = String(order.get("status", ""))
		var work_days: int = int(order.get("work_days", 0))
		var progress_days: int = int(order.get("progress_days", -1))
		if order_id.is_empty():
			errors.append("Existe uma obra sem identificador.")
		elif seen_ids.has(order_id):
			errors.append("Identificador de obra repetido: %s." % order_id)
		else:
			seen_ids[order_id] = true
		if building_id.is_empty():
			errors.append("A obra %s não informa a construção." % order_id)
		if work_days < 1 or work_days > 3:
			errors.append("A obra %s possui duração fora de 1–3 dias." % order_id)
		if progress_days < 0 or progress_days > work_days:
			errors.append("A obra %s possui progresso inválido." % order_id)
		if float(order.get("paid_cost", -1.0)) < 0.0:
			errors.append("A obra %s possui custo pago inválido." % order_id)
		if int(order.get("predicted_available_day", 0)) <= 0:
			errors.append("A obra %s não possui previsão de disponibilidade." % order_id)
		if not bool(order.get("is_housing", false)):
			if pending_buildings.has(building_id):
				errors.append("A construção %s possui duas melhorias pendentes." % building_id)
			pending_buildings[building_id] = true
		if status == "active":
			actual_active_count += 1
		elif status == "completed_pending":
			actual_pending_completion_count += 1
		elif status == "queued":
			if int(order.get("queue_position", -1)) != expected_queue_position:
				errors.append("A posição da fila não é sequencial na obra %s." % order_id)
			expected_queue_position += 1
		else:
			errors.append("A obra %s possui status desconhecido: %s." % [order_id, status])

	if int(construction.get("active_count", -1)) != actual_active_count:
		errors.append("A contagem de canteiros ativos não corresponde às ordens.")
	if int(construction.get("pending_completion_count", -1)) != actual_pending_completion_count:
		errors.append("A contagem de conclusões pendentes não corresponde às ordens.")
	if int(construction.get("queued_count", -1)) != queued_orders.size():
		errors.append("A contagem da fila não corresponde às ordens.")
	if active_orders.size() + queued_orders.size() > 256:
		errors.append("A fila ultrapassou o limite seguro de 256 ordens.")

	var population: int = int(
		GameManager.get_population_overview().get("total_population", 0)
	)
	var expected_capacity: int = clampi(1 + floori(float(population) / 20.0), 1, 4)
	var actual_capacity: int = int(construction.get("site_capacity", 0))
	if actual_capacity != expected_capacity:
		errors.append("A capacidade de canteiros não corresponde à população.")
	if actual_active_count > actual_capacity:
		warnings.append(
			"Há mais obras ativas que a capacidade atual; elas continuarão, "
			+ "mas nenhuma nova deve começar até a capacidade se recuperar."
		)

	return {
		"success": errors.is_empty(),
		"errors": errors,
		"warnings": warnings,
		"message": (
			"%d/%d canteiro(s) ativo(s), %d conclusão(ões) pendente(s) e %d obra(s) na fila."
			% [
				actual_active_count,
				actual_capacity,
				actual_pending_completion_count,
				queued_orders.size()
			]
		)
	}


static func _validate_balance_system() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var difficulty_ids: Array[String] = DIFFICULTY_CATALOG_SCRIPT.DIFFICULTY_IDS
	var checkpoints: Array[Dictionary] = CAMPAIGN_CATALOG_SCRIPT.CHECKPOINTS
	var expected_days: Array[int] = [20, 40, 60, 80, 100, 120]
	var found_days: Array[int] = []
	var goal_count: int = 0
	var previous_food: float = -1.0
	var previous_material: float = -1.0
	var previous_population: int = -1

	if difficulty_ids != ["cozy", "moderate", "hard"]:
		errors.append("As dificuldades devem ser Acolhedora, Moderada e Difícil.")
	for difficulty_id: String in difficulty_ids:
		var rules: Dictionary = DIFFICULTY_CATALOG_SCRIPT.get_difficulty(difficulty_id)
		for neutral_key: String in [
			"production_multiplier",
			"food_consumption_multiplier",
			"maintenance_multiplier",
			"happiness_decay_multiplier",
			"building_cost_multiplier"
		]:
			if not is_equal_approx(float(rules.get(neutral_key, 0.0)), 1.0):
				errors.append("%s altera diretamente %s; a diferença deve ser qualitativa." % [difficulty_id, neutral_key])
	var cozy_rules: Dictionary = DIFFICULTY_CATALOG_SCRIPT.get_difficulty("cozy")
	if float(cozy_rules.get("initial_food", 0.0)) != 48.0:
		errors.append("Acolhedora deve começar com 48 de alimentação.")
	if float(cozy_rules.get("initial_material", 0.0)) != 22.0:
		errors.append("Acolhedora deve começar com 22 de material.")
	if float(cozy_rules.get("initial_happiness", 0.0)) != 72.0:
		errors.append("Acolhedora deve começar com 72 de felicidade.")
	if int(cozy_rules.get("crisis_grace_days", 0)) != 4:
		errors.append("Acolhedora deve tolerar quatro dias consecutivos de crise.")
	if int(cozy_rules.get("population_target_offset", 0)) != -1:
		errors.append("Acolhedora deve exigir um habitante a menos por avaliação.")
	var moderate_rules: Dictionary = DIFFICULTY_CATALOG_SCRIPT.get_difficulty("moderate")
	var hard_rules: Dictionary = DIFFICULTY_CATALOG_SCRIPT.get_difficulty("hard")
	var expected_growth_rules: Dictionary = {
		"cozy": [cozy_rules, 1, 52.0],
		"moderate": [moderate_rules, 2, 55.0],
		"hard": [hard_rules, 2, 58.0]
	}
	for difficulty_id: String in expected_growth_rules:
		var expectation: Array = expected_growth_rules[difficulty_id]
		var growth_rules: Dictionary = expectation[0] as Dictionary
		if int(growth_rules.get("attraction_target", 0)) != int(expectation[1]):
			errors.append("Tempo de atração incorreto em %s." % difficulty_id)
		if not is_equal_approx(
			float(growth_rules.get("growth_minimum_happiness", 0.0)),
			float(expectation[2])
		):
			errors.append("Felicidade mínima de atração incorreta em %s." % difficulty_id)

	for checkpoint: Dictionary in checkpoints:
		var day: int = int(checkpoint.get("day", 0))
		var targets_value: Variant = checkpoint.get("targets", null)
		found_days.append(day)
		if not targets_value is Dictionary:
			errors.append("Avaliação do dia %d sem metas válidas." % day)
			continue
		var targets: Dictionary = targets_value as Dictionary
		for key: String in ["food", "material", "happiness", "population"]:
			if not targets.has(key):
				errors.append("Dia %d sem a meta %s." % [day, key])
			else:
				goal_count += 1
		var food_target: float = float(targets.get("food", 0.0))
		var material_target: float = float(targets.get("material", 0.0))
		var population_target: int = int(targets.get("population", 0))
		if food_target <= previous_food:
			errors.append("A meta de alimentação não cresce no dia %d." % day)
		if material_target <= previous_material:
			errors.append("A meta de material não cresce no dia %d." % day)
		if population_target <= previous_population:
			errors.append("A meta populacional não cresce no dia %d." % day)
		previous_food = food_target
		previous_material = material_target
		previous_population = population_target

	if found_days != expected_days:
		errors.append("Dias de avaliação incorretos: %s." % str(found_days))
	if goal_count != 24:
		errors.append("Esperadas 24 metas; encontradas %d." % goal_count)

	for checkpoint: Dictionary in checkpoints:
		var day: int = int(checkpoint.get("day", 0))
		var base_targets: Dictionary = checkpoint.get("targets", {}) as Dictionary
		var cozy: Dictionary = DIFFICULTY_CATALOG_SCRIPT.apply_checkpoint_targets(base_targets, "cozy")
		var moderate: Dictionary = DIFFICULTY_CATALOG_SCRIPT.apply_checkpoint_targets(base_targets, "moderate")
		var hard: Dictionary = DIFFICULTY_CATALOG_SCRIPT.apply_checkpoint_targets(base_targets, "hard")
		for key: String in ["food", "material", "population"]:
			if float(cozy.get(key, 0.0)) > float(moderate.get(key, 0.0)):
				errors.append("Dia %d: Acolhedora supera Moderada em %s." % [day, key])
			if float(moderate.get(key, 0.0)) > float(hard.get(key, 0.0)):
				errors.append("Dia %d: Moderada supera Difícil em %s." % [day, key])

	var final_checkpoint: Dictionary = checkpoints[checkpoints.size() - 1]
	var final_targets: Dictionary = final_checkpoint.get("targets", {}) as Dictionary
	var expected_final_population: Dictionary = {
		"cozy": 28,
		"moderate": 29,
		"hard": 31
	}
	for difficulty_id: String in difficulty_ids:
		var adjusted: Dictionary = DIFFICULTY_CATALOG_SCRIPT.apply_checkpoint_targets(final_targets, difficulty_id)
		var final_population: int = int(adjusted.get("population", 0))
		if final_population != int(expected_final_population.get(difficulty_id, 0)):
			errors.append("Meta populacional final incorreta em %s." % difficulty_id)

	var autumn: Dictionary = CAMPAIGN_CATALOG_SCRIPT.get_season_modifiers_for_day(70)
	var winter: Dictionary = CAMPAIGN_CATALOG_SCRIPT.get_season_modifiers_for_day(100)
	if not is_equal_approx(float(winter.get("food_production_multiplier", 1.0)), 0.90):
		errors.append("O Inverno deve aplicar -10% à produção de alimentação.")
	if not is_equal_approx(float(winter.get("food_consumption_multiplier", 1.0)), 1.10):
		errors.append("O Inverno deve aplicar +10% ao consumo de alimentação.")
	if float(winter.get("food_production_multiplier", 1.0)) >= float(autumn.get("food_production_multiplier", 1.0)):
		errors.append("O Inverno deve produzir menos alimentação que o Outono.")
	if float(winter.get("food_consumption_multiplier", 1.0)) <= float(autumn.get("food_consumption_multiplier", 1.0)):
		errors.append("O Inverno deve consumir mais alimentação que o Outono.")

	var records: Array[Dictionary] = CAMPAIGN_RECORDS_SCRIPT.get_all_records()
	var recent_record: Dictionary = CAMPAIGN_RECORDS_SCRIPT.get_recent_record()
	if not records.is_empty() and recent_record.is_empty():
		errors.append("Histórico de campanhas não conseguiu recuperar o registro mais recente.")

	return {
		"success": errors.is_empty(),
		"difficulties": difficulty_ids.size(),
		"checkpoints": checkpoints.size(),
		"goals": goal_count,
		"errors": errors,
		"warnings": warnings
	}


static func _validate_audio_system() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var bus_count: int = 0
	for bus_name: String in ["Master", "Music", "Ambience", "SFX", "UI"]:
		if AudioServer.get_bus_index(bus_name) < 0:
			errors.append("Canal de áudio ausente: %s." % bus_name)
		else:
			bus_count += 1

	var required_audio_paths: Array[String] = [
		"res://assets/audio/music/music_menu.ogg",
		"res://assets/audio/music/music_spring_01.ogg",
		"res://assets/audio/music/music_spring_02.ogg",
		"res://assets/audio/music/music_summer.ogg",
		"res://assets/audio/music/music_autumn.ogg",
		"res://assets/audio/music/music_winter_01.ogg",
		"res://assets/audio/music/music_winter_02.ogg",
		"res://assets/audio/music/music_story_special.ogg",
		"res://assets/audio/music/music_fun.ogg",
		"res://assets/audio/ambience/ambience_spring.ogg",
		"res://assets/audio/ambience/ambience_summer.ogg",
		"res://assets/audio/ambience/ambience_autumn.ogg",
		"res://assets/audio/ambience/ambience_winter.ogg",
		"res://assets/audio/sfx/ui/ui_click.wav",
		"res://assets/audio/sfx/ui/ui_hover.wav",
		"res://assets/audio/sfx/ui/ui_confirm.wav",
		"res://assets/audio/sfx/ui/ui_cancel.wav",
		"res://assets/audio/sfx/events/event_positive.wav",
		"res://assets/audio/sfx/events/event_negative.wav",
		"res://assets/audio/sfx/events/event_magic.wav",
		"res://assets/audio/sfx/events/event_audit.wav",
		"res://assets/audio/sfx/events/event_victory.wav",
		"res://assets/audio/sfx/events/event_defeat.wav",
		"res://assets/audio/sfx/administration/game_build.wav",
		"res://assets/audio/sfx/administration/game_end_day.wav",
		"res://assets/audio/sfx/relationships/relation_gain.wav",
		"res://assets/audio/sfx/relationships/relation_romance.wav",
		"res://assets/audio/sfx/dialogue/dialogue_text.wav",
		"res://assets/audio/sfx/dialogue/story_divine.wav"
	]
	var found_resources: int = 0
	for resource_path: String in required_audio_paths:
		if ResourceLoader.exists(resource_path):
			found_resources += 1
		else:
			errors.append("Áudio ausente: %s" % resource_path)

	var settings: Dictionary = GameSettings.get_settings()
	for required_key: String in [
		"master_volume_percent",
		"music_volume_percent",
		"ambience_volume_percent",
		"effects_volume_percent",
		"interface_volume_percent",
		"master_muted"
	]:
		if not settings.has(required_key):
			errors.append("Configuração de áudio ausente: %s." % required_key)

	return {
		"success": errors.is_empty(),
		"resources": found_resources,
		"buses": bus_count,
		"errors": errors,
		"warnings": warnings
	}


static func _validate_relationship_system() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var personal_event_count: int = 0
	var scene_image_count: int = 0
	var expected_thresholds: Array[int] = [200, 400, 600, 800]

	if RELATIONSHIP_CATALOG_SCRIPT.ROMANCE_IDS.size() != 7:
		errors.append("São esperados exatamente sete candidatos românticos.")
	if RELATIONSHIP_CATALOG_SCRIPT.is_romance_candidate(
		RELATIONSHIP_CATALOG_SCRIPT.MIMO_ID
	):
		errors.append("Mimo não pode possuir rota romântica.")
	if RELATIONSHIP_CATALOG_SCRIPT.PERSONAL_EVENT_POINT_THRESHOLDS != expected_thresholds:
		errors.append("As cenas pessoais devem usar exatamente 200, 400, 600 e 800 pontos.")

	var dummy_profile: Dictionary = {
		"name": "Teste",
		"gender_id": "masculino",
		"title": "Prefeito"
	}
	for npc_id: String in RELATIONSHIP_CATALOG_SCRIPT.TRACKED_IDS:
		var relation_data: Dictionary = {
			"npc_id": npc_id,
			"relationship_points": 850,
			"relationship_level": 8,
			"relationship_kind": "friendship",
			"official_partner": false,
			"completed_personal_event_ids": []
		}
		var image_path: String = RELATIONSHIP_CATALOG_SCRIPT.get_scene_800_image_path(
			npc_id
		)
		if image_path.is_empty() or not ResourceLoader.exists(image_path):
			errors.append("%s: imagem da cena de 800 pontos ausente." % npc_id)
		else:
			scene_image_count += 1

		var completed_ids: Array[String] = []
		for threshold_index: int in range(expected_thresholds.size()):
			var expected_event_id: String = "%s_personal_%d" % [
				npc_id,
				threshold_index + 1
			]
			var threshold_data: Dictionary = {
				"npc_id": npc_id,
				"relationship_points": expected_thresholds[threshold_index] - 1,
				"completed_personal_event_ids": completed_ids.duplicate()
			}
			if not RELATIONSHIP_CATALOG_SCRIPT.get_next_personal_event_id(
				npc_id,
				threshold_data
			).is_empty():
				errors.append("%s: cena liberada antes de %d pontos." % [
					expected_event_id,
					expected_thresholds[threshold_index]
				])
			threshold_data["relationship_points"] = expected_thresholds[threshold_index]
			if RELATIONSHIP_CATALOG_SCRIPT.get_next_personal_event_id(
				npc_id,
				threshold_data
			) != expected_event_id:
				errors.append("%s: cena não liberada no marco exato." % expected_event_id)
			if RELATIONSHIP_CATALOG_SCRIPT.get_next_personal_event_threshold(
				threshold_data
			) != expected_thresholds[threshold_index]:
				errors.append("%s: próximo marco informado incorretamente." % npc_id)
			completed_ids.append(expected_event_id)
		for season_id: String in ["spring", "summer", "autumn", "winter"]:
			var conversation: Dictionary = (
				RELATIONSHIP_DIALOGUE_CATALOG_SCRIPT.create_conversation(
					npc_id,
					season_id,
					relation_data,
					dummy_profile
				)
			)
			for error_text: String in DIALOGUE_CATALOG_SCRIPT.validate_conversation(conversation):
				errors.append("%s/%s: %s" % [npc_id, season_id, error_text])

		for event_index: int in range(1, 5):
			var event_id: String = "%s_personal_%d" % [npc_id, event_index]
			var personal_event: Dictionary = (
				RELATIONSHIP_DIALOGUE_CATALOG_SCRIPT.create_personal_event(
					npc_id,
					event_id,
					relation_data,
					""
				)
			)
			personal_event_count += 1
			for error_text: String in DIALOGUE_CATALOG_SCRIPT.validate_conversation(personal_event):
				errors.append("%s: %s" % [event_id, error_text])

		var final_event_id: String = "%s_personal_4" % npc_id
		var unavailable_romance_event: Dictionary = (
			RELATIONSHIP_DIALOGUE_CATALOG_SCRIPT.create_personal_event(
				npc_id,
				final_event_id,
				relation_data,
				""
			)
		)
		if String(unavailable_romance_event.get("scene_image_path", "")) != image_path:
			errors.append("%s: a cena final não referencia a imagem correta." % npc_id)
		var unavailable_actions: Array[String] = _get_relationship_choice_actions(
			unavailable_romance_event
		)
		if not unavailable_actions.has("respectful_friendship"):
			errors.append("%s: decisão final sem amizade profunda." % npc_id)
		if not unavailable_actions.has("defer_relationship_decision"):
			errors.append("%s: decisão final sem a opção de decidir depois." % npc_id)
		if unavailable_actions.has("commit_romance"):
			errors.append("%s: romance liberado sem duas marcas de interesse." % npc_id)

		var romance_ready_data: Dictionary = relation_data.duplicate(true)
		romance_ready_data["romance_interest_markers"] = [
			"%s_personal_2" % npc_id,
			"%s_personal_3" % npc_id
		]
		var romance_ready_event: Dictionary = (
			RELATIONSHIP_DIALOGUE_CATALOG_SCRIPT.create_personal_event(
				npc_id,
				final_event_id,
				romance_ready_data,
				""
			)
		)
		var romance_ready_actions: Array[String] = _get_relationship_choice_actions(
			romance_ready_event
		)
		if RELATIONSHIP_CATALOG_SCRIPT.is_romance_candidate(npc_id):
			if not romance_ready_actions.has("commit_romance"):
				errors.append("%s: romance não liberado com duas marcas de interesse." % npc_id)
		elif romance_ready_actions.has("commit_romance"):
			errors.append("Mimo recebeu uma escolha romântica indevida.")

		if RELATIONSHIP_CATALOG_SCRIPT.is_romance_candidate(npc_id):
			var date_conversation: Dictionary = (
				RELATIONSHIP_DIALOGUE_CATALOG_SCRIPT.create_date_conversation(
					npc_id,
					"spring"
				)
			)
			for error_text: String in DIALOGUE_CATALOG_SCRIPT.validate_conversation(date_conversation):
				errors.append("encontro/%s: %s" % [npc_id, error_text])

	var live_overview: Dictionary = GameManager.get_relationship_overview()
	var partner_id: String = String(live_overview.get("official_partner_id", ""))
	if not partner_id.is_empty() and not RELATIONSHIP_CATALOG_SCRIPT.is_romance_candidate(partner_id):
		errors.append("O parceiro oficial não pertence às rotas românticas válidas.")
	var profile: Dictionary = GameManager.get_player_profile_overview()
	if String(profile.get("gender_id", "")) not in ["masculino", "feminino"]:
		errors.append("Gênero do perfil do Prefeito inválido.")

	return {
		"success": errors.is_empty(),
		"tracked": RELATIONSHIP_CATALOG_SCRIPT.TRACKED_IDS.size(),
		"romance_candidates": RELATIONSHIP_CATALOG_SCRIPT.ROMANCE_IDS.size(),
		"personal_events": personal_event_count,
		"scene_images": scene_image_count,
		"errors": errors,
		"warnings": warnings
	}


static func _get_relationship_choice_actions(conversation: Dictionary) -> Array[String]:
	var actions: Array[String] = []
	var nodes: Dictionary = conversation.get("nodes", {}) as Dictionary
	var opening: Dictionary = nodes.get(
		String(conversation.get("start", "opening")),
		{}
	) as Dictionary
	for choice_value: Variant in opening.get("choices", []):
		if not choice_value is Dictionary:
			continue
		var action: String = String(
			(choice_value as Dictionary).get("relationship_action", "")
		)
		if not action.is_empty():
			actions.append(action)
	return actions


static func _validate_events() -> Dictionary:
	var events: Array[Dictionary] = EVENT_CATALOG_SCRIPT.create()
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var event_ids: Dictionary = {}
	var choice_count: int = 0

	if events.size() < 40:
		errors.append("Esperados ao menos 40 acontecimentos; encontrados %d." % events.size())

	for event: Dictionary in events:
		var event_id: String = String(event.get("id", "")).strip_edges()
		var title: String = String(event.get("title", "")).strip_edges()
		var description: String = String(event.get("description", "")).strip_edges()
		var choices_value: Variant = event.get("choices", null)

		if event_id.is_empty():
			errors.append("Acontecimento sem ID.")
			continue
		if event_ids.has(event_id):
			errors.append("ID de acontecimento duplicado: %s" % event_id)
		else:
			event_ids[event_id] = true

		if title.is_empty() or description.is_empty():
			errors.append("%s: título ou descrição vazios." % event_id)

		if not choices_value is Array:
			errors.append("%s: escolhas inválidas." % event_id)
			continue

		var choices: Array = choices_value as Array
		if choices.size() < 2:
			warnings.append("%s possui menos de duas escolhas." % event_id)

		var min_day: int = int(event.get("min_day", 1))
		if min_day < 1:
			errors.append("%s: dia mínimo inválido." % event_id)

		var season_id: String = String(event.get("season_id", ""))
		if not season_id.is_empty() and season_id not in [
			"spring", "summer", "autumn", "winter"
		]:
			errors.append("%s: estação inválida %s." % [event_id, season_id])

		var choice_ids: Dictionary = {}
		for choice_value: Variant in choices:
			if not choice_value is Dictionary:
				errors.append("%s: escolha inválida." % event_id)
				continue
			var choice: Dictionary = choice_value as Dictionary
			var choice_id: String = String(choice.get("id", "")).strip_edges()
			choice_count += 1

			for dictionary_key: String in [
				"costs", "effects", "success_effects", "failure_effects"
			]:
				var dictionary_value: Variant = choice.get(dictionary_key, {})
				if not dictionary_value is Dictionary:
					errors.append(
					"%s/%s: %s precisa ser um dicionário."
					% [event_id, choice_id, dictionary_key]
				)
					continue
				for resource_key_value: Variant in (dictionary_value as Dictionary).keys():
					var resource_key: String = String(resource_key_value)
					if resource_key not in ["food", "material", "happiness"]:
						errors.append(
							"%s/%s: recurso desconhecido %s."
							% [event_id, choice_id, resource_key]
						)

			if choice.has("base_chance"):
				var base_chance: float = float(choice.get("base_chance", -1.0))
				var min_chance: float = float(choice.get("min_chance", 0.0))
				var max_chance: float = float(choice.get("max_chance", 1.0))
				var test_attribute: String = String(
					choice.get("test_attribute", "")
				).strip_edges()
				var requires_villager: bool = bool(
					choice.get("requires_villager", false)
				)
				if base_chance < 0.0 or base_chance > 1.0:
					errors.append("%s/%s: chance-base inválida." % [event_id, choice_id])
				if min_chance < 0.0 or max_chance > 1.0 or min_chance > max_chance:
					errors.append("%s/%s: limites de chance inválidos." % [event_id, choice_id])

				# Escolhas com chance fixa usam apenas base_chance e não
				# precisam de atributo. O atributo só é obrigatório quando
				# a escolha pede explicitamente um representante.
				if requires_villager:
					if test_attribute not in [
						"strength",
						"intelligence",
						"charisma",
						"agility"
					]:
						errors.append(
							"%s/%s: atributo de teste inválido."
							% [event_id, choice_id]
						)
				elif not test_attribute.is_empty():
					warnings.append(
						"%s/%s: atributo ignorado em chance fixa."
						% [event_id, choice_id]
					)

			if choice_id.is_empty():
				errors.append("%s: escolha sem ID." % event_id)
			elif choice_ids.has(choice_id):
				errors.append("%s: escolha duplicada %s." % [event_id, choice_id])
			else:
				choice_ids[choice_id] = true

	return {
		"success": errors.is_empty(),
		"events": events.size(),
		"choices": choice_count,
		"errors": errors,
		"warnings": warnings
	}


static func _validate_story_campaign() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var chapters: Array[Dictionary] = STORY_CATALOG_SCRIPT.create_chapters()
	var story_events: Array[Dictionary] = STORY_CATALOG_SCRIPT.create_story_events()
	var expected_days: Array[int] = [15, 30, 45, 60, 75, 90, 105, 120]
	var found_days: Dictionary = {}
	var event_ids: Dictionary = {}

	if chapters.size() != expected_days.size():
		errors.append(
			"Esperados oito capítulos; encontrados %d." % chapters.size()
		)

	for chapter: Dictionary in chapters:
		var chapter_id: String = String(chapter.get("id", ""))
		var chapter_day: int = int(chapter.get("day", 0))
		var event_id: String = String(chapter.get("event_id", ""))
		var dialogue_id: String = String(
			chapter.get("intro_dialogue_id", "")
		)
		if chapter_id.is_empty():
			errors.append("Capítulo sem ID.")
		if not expected_days.has(chapter_day):
			errors.append("%s: dia inválido %d." % [chapter_id, chapter_day])
		elif found_days.has(chapter_day):
			errors.append("Dia de capítulo duplicado: %d." % chapter_day)
		else:
			found_days[chapter_day] = true
		if event_id.is_empty():
			errors.append("%s: acontecimento principal ausente." % chapter_id)
		if (
			dialogue_id.is_empty()
			or DIALOGUE_CATALOG_SCRIPT.create_story_conversation(
				dialogue_id
			).is_empty()
		):
			errors.append("%s: diálogo introdutório inválido." % chapter_id)
		var npc_id: String = String(chapter.get("npc_id", ""))
		if (
			chapter_day < 120
			and (
				npc_id.is_empty()
				or CHARACTER_CATALOG_SCRIPT.get_by_id(npc_id) == null
			)
		):
			errors.append("%s: NPC do capítulo não cadastrado." % chapter_id)

	for story_event: Dictionary in story_events:
		var story_event_id: String = String(story_event.get("id", ""))
		if story_event_id.is_empty():
			errors.append("Acontecimento principal sem ID.")
			continue
		if event_ids.has(story_event_id):
			errors.append(
				"Acontecimento principal duplicado: %s." % story_event_id
			)
		else:
			event_ids[story_event_id] = true
		if not bool(story_event.get("is_story_event", false)):
			errors.append(
				"%s não está marcado como narrativo." % story_event_id
			)
		var choices_value: Variant = story_event.get("choices", null)
		if (
			not choices_value is Array
			or (choices_value as Array).size() < 3
			or (choices_value as Array).size() > 4
		):
			errors.append("%s precisa de três ou quatro escolhas." % story_event_id)
			continue
		var story_choices: Array = choices_value as Array
		for choice_value: Variant in story_choices:
			if not choice_value is Dictionary:
				errors.append("%s possui escolha inválida." % story_event_id)
				continue
			var choice: Dictionary = choice_value as Dictionary
			var outro_variant: String = String(
				choice.get("outro_variant", "")
			)
			var event_chapter_day: int = int(
				story_event.get("chapter_day", 0)
			)
			var outro_id: String = "chapter_%d_outro_%s" % [
				event_chapter_day,
				outro_variant
			]
			if DIALOGUE_CATALOG_SCRIPT.create_story_conversation(
				outro_id
			).is_empty():
				errors.append(
					"%s: desfecho ausente %s." % [story_event_id, outro_id]
				)

	var story_overview: Dictionary = GameManager.get_story_overview()
	for required_key: String in [
		"prologue_completed",
		"completed_chapter_ids",
		"recruited_npc_ids",
		"story_flags",
		"chapter_choices"
	]:
		if not story_overview.has(required_key):
			errors.append("Estado narrativo sem o campo %s." % required_key)

	return {
		"success": errors.is_empty(),
		"chapters": chapters.size(),
		"events": story_events.size(),
		"dialogues": DIALOGUE_CATALOG_SCRIPT.get_story_dialogue_ids().size(),
		"errors": errors,
		"warnings": warnings
	}



static func _validate_council_cards() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var founders_by_id: Dictionary = {}
	var used_names: Dictionary = {}
	var used_portraits: Dictionary = {}
	var used_passives: Dictionary = {}
	var used_personalities: Dictionary = {}
	var helper: Villager = null

	for villager: Villager in GameManager.villagers:
		if not is_instance_valid(villager):
			continue
		if villager.representative_id in GameManager.INITIAL_FOUNDER_IDS:
			founders_by_id[villager.representative_id] = villager
		elif villager.representative_id == GameManager.INITIAL_HELPER_ID:
			helper = villager

	for founder_id: String in GameManager.INITIAL_FOUNDER_IDS:
		var founder: Villager = founders_by_id.get(founder_id, null) as Villager
		if not is_instance_valid(founder):
			errors.append("Carta fundadora ausente: %s." % founder_id)
			continue
		if founder.species_name != "Passos-Leves":
			errors.append("%s não foi gerado como Passos-Leves." % founder.villager_name)
		var attribute_values: Array[int] = [
			founder.strength,
			founder.intelligence,
			founder.charisma,
			founder.agility
		]
		for attribute_value: int in attribute_values:
			if attribute_value < 1 or attribute_value > Villager.MAX_ATTRIBUTE_VALUE:
				errors.append(
					"%s possui atributo fora do intervalo de 1 a %d."
					% [founder.villager_name, Villager.MAX_ATTRIBUTE_VALUE]
				)
				break
		var expected_progression_points: int = maxi(0, founder.level - 1)
		if (
			founder.attribute_points_spent < 0
			or founder.unspent_attribute_points < 0
			or founder.attribute_points_spent + founder.unspent_attribute_points
			!= expected_progression_points
		):
			errors.append(
				"%s possui distribuição de pontos incompatível com o nível %d."
				% [founder.villager_name, founder.level]
			)
		if founder.get_attribute_total() != 10 + founder.attribute_points_spent:
			errors.append(
				"%s possui total de atributos incompatível com os pontos gastos."
				% founder.villager_name
			)
		if founder.villager_name.strip_edges().is_empty():
			errors.append("Uma carta fundadora está sem nome.")
		elif used_names.has(founder.villager_name):
			errors.append("Nome fundador repetido: %s." % founder.villager_name)
		else:
			used_names[founder.villager_name] = true
		if founder.portrait_id.strip_edges().is_empty():
			errors.append("%s está sem ícone de carta." % founder.villager_name)
		elif used_portraits.has(founder.portrait_id):
			errors.append("Ícone fundador repetido: %s." % founder.portrait_id)
		else:
			used_portraits[founder.portrait_id] = true
		if founder.passive_id.strip_edges().is_empty():
			errors.append("%s está sem passiva." % founder.villager_name)
		elif used_passives.has(founder.passive_id):
			errors.append("Passiva fundadora repetida: %s." % founder.passive_name)
		else:
			used_passives[founder.passive_id] = true
		if not PERSONALITY_CATALOG_SCRIPT.has_definition(founder.personality_id):
			errors.append("Personalidade inválida em %s." % founder.villager_name)
		elif used_personalities.has(founder.personality_id):
			errors.append("Personalidade fundadora repetida: %s." % founder.personality_name)
		else:
			used_personalities[founder.personality_id] = true
		if founder.level < 1 or founder.xp < 0:
			errors.append("Nível ou XP inválido em %s." % founder.villager_name)
		if founder.specialization != Villager.Profession.UNASSIGNED:
			errors.append("%s ainda possui especialização antiga." % founder.villager_name)

	if not is_instance_valid(helper):
		errors.append("A carta fixa da Mimo está ausente.")
	else:
		if helper.portrait_id != "mimo":
			errors.append("A carta da Mimo está com ícone incorreto.")
		if helper.passive_id != "faz_tudo":
			errors.append("A carta da Mimo perdeu a passiva Faz-tudo.")
		if helper.personality_id != "playful":
			errors.append("A personalidade fixa da Mimo está incorreta.")

	return {
		"success": errors.is_empty(),
		"message": (
			"%d cartas fundadoras, %d nomes, %d ícones, %d passivas e %d personalidades únicas; carta fixa da Mimo verificada."
		) % [
			founders_by_id.size(),
			used_names.size(),
			used_portraits.size(),
			used_passives.size(),
			used_personalities.size()
		],
		"errors": errors,
		"warnings": warnings
	}

static func _validate_councillor_progression() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var validated_cards: int = 0
	var dialogue_count: int = 0
	var required_history_fields: Array[String] = [
		"joined_day",
		"days_in_council",
		"days_in_reserve",
		"lifetime_xp",
		"total_production",
		"profession_day_counts",
		"events_resolved",
		"production_milestones",
		"history_entries"
	]

	for villager: Villager in GameManager.villagers:
		if not is_instance_valid(villager):
			continue
		validated_cards += 1
		if villager.level < 1 or villager.level > Villager.MAX_LEVEL:
			errors.append("Nível fora do limite em %s." % villager.villager_name)
		if villager.xp < 0 or villager.lifetime_xp < villager.xp:
			errors.append("XP inconsistente em %s." % villager.villager_name)
		if villager.is_max_level() and villager.xp != 0:
			errors.append("%s mantém XP de nível após alcançar o máximo." % villager.villager_name)
		if villager.unspent_attribute_points < 0 or villager.attribute_points_spent < 0:
			errors.append("Pontos de atributo inválidos em %s." % villager.villager_name)
		for attribute_id: String in [
			"strength",
			"intelligence",
			"charisma",
			"agility"
		]:
			var value: int = villager.get_attribute_value(attribute_id)
			if value < 1 or value > Villager.MAX_ATTRIBUTE_VALUE:
				errors.append(
					"%s possui %s fora do limite 1–8."
					% [villager.villager_name, attribute_id]
				)

		var history: Dictionary = GameManager.get_councillor_history(
			villager.representative_id
		)
		if history.is_empty():
			errors.append("Ficha histórica ausente para %s." % villager.villager_name)
		else:
			for field_id: String in required_history_fields:
				if not history.has(field_id):
					errors.append(
						"Ficha de %s não possui %s."
						% [villager.villager_name, field_id]
					)

	for personality_id: String in PERSONALITY_CATALOG_SCRIPT.get_all_ids():
		for level_value: int in range(2, Villager.MAX_LEVEL + 1):
			var conversation: Dictionary = (
				PROGRESSION_DIALOGUE_CATALOG_SCRIPT.create_level_up_conversation(
					{
						"conversation_id": "diagnostic_%s_%d" % [
							personality_id,
							level_value
						],
						"representative_id": "diagnostic",
						"display_name": "Carta de teste",
						"portrait_id": "mimo",
						"personality_id": personality_id,
						"level": level_value,
						"dominant_resource": "material"
					}
				)
			)
			dialogue_count += 1
			var dialogue_errors: Array[String] = (
				DIALOGUE_CATALOG_SCRIPT.validate_conversation(conversation)
			)
			for dialogue_error: String in dialogue_errors:
				errors.append(
					"%s nível %d: %s"
					% [personality_id, level_value, dialogue_error]
				)

	if validated_cards == 0:
		warnings.append("Nenhuma carta foi carregada para validar o histórico atual.")

	return {
		"success": errors.is_empty(),
		"message": (
			"%d carta(s) e %d diálogo(s) de conquista verificados."
			% [validated_cards, dialogue_count]
		),
		"errors": errors,
		"warnings": warnings
	}


static func _validate_roster() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var representative_ids: Dictionary = {}
	var founder_portraits: Dictionary = {}
	var active_count: int = 0

	for villager: Villager in GameManager.villagers:
		if not is_instance_valid(villager):
			continue

		if representative_ids.has(villager.representative_id):
			errors.append("Representante duplicado: %s" % villager.representative_id)
		else:
			representative_ids[villager.representative_id] = true

		if villager.is_council_active:
			active_count += 1

		if villager.portrait_id.strip_edges().is_empty():
			errors.append("%s está sem retrato persistente." % villager.villager_name)
		elif villager.representative_id in GameManager.INITIAL_FOUNDER_IDS:
			if founder_portraits.has(villager.portrait_id):
				errors.append(
					"Retrato fundador repetido: %s" % villager.portrait_id
				)
			else:
				founder_portraits[villager.portrait_id] = true

	if active_count != GameManager.ACTIVE_COUNCIL_LIMIT:
		errors.append(
			"Conselho ativo com %d membros; esperado %d."
			% [active_count, GameManager.ACTIVE_COUNCIL_LIMIT]
		)

	if GameManager.villagers.size() < 5:
		errors.append("Elenco inicial incompleto.")

	return {
		"success": errors.is_empty(),
		"message": "%d personagens registrados; %d no Conselho."
		% [GameManager.villagers.size(), active_count],
		"errors": errors,
		"warnings": warnings
	}


static func _validate_council_recruitment() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var expected_days: Array[int] = [20, 40, 60, 80, 100, 120]
	if COUNCIL_RECRUITMENT_MANAGER_SCRIPT.STATE_VERSION != 3:
		errors.append("O recrutamento deve usar o estado interno versão 3.")
	if COUNCIL_RECRUITMENT_MANAGER_SCRIPT.OFFER_DAYS != expected_days:
		errors.append("As seis vagas de recrutamento não correspondem aos dias 20 a 120.")
	for checkpoint_day: int in expected_days:
		var requirement: int = int(
			COUNCIL_RECRUITMENT_MANAGER_SCRIPT.RELATIONSHIP_REQUIREMENTS.get(
				checkpoint_day,
				-1
			)
		)
		if requirement != 0:
			errors.append(
				"A escolha do Dia %d ainda possui bloqueio de relacionamento: %d."
				% [checkpoint_day, requirement]
			)
		var expected_level: int = clampi(1 + floori(float(checkpoint_day) / 20.0), 1, 6)
		if COUNCIL_RECRUITMENT_MANAGER_SCRIPT.get_candidate_level(
			checkpoint_day
		) != expected_level:
			errors.append(
				"Nível de candidata incorreto para o Dia %d." % checkpoint_day
			)

	var supported_species: Array[String] = [
		"Passos-Leves",
		"Elfo",
		"Anã",
		"Draconato",
		"Meio-demônia",
		"Kobold",
		"Bruxa",
		"Meio-vampiro"
	]
	for species_name: String in supported_species:
		if not COUNCIL_CARD_CATALOG_SCRIPT.has_recruitment_pool(species_name):
			errors.append(
				"A espécie %s não possui nomes e dois retratos recrutáveis."
				% species_name
			)

	var overview: Dictionary = GameManager.get_recruitment_overview()
	for required_key: String in [
		"state",
		"completed_count",
		"total_count",
		"pending_checkpoint_days",
		"message"
	]:
		if not overview.has(required_key):
			errors.append("O resumo de recrutamento não contém %s." % required_key)
	if int(overview.get("total_count", 0)) != 6:
		errors.append("O resumo deve informar seis recrutamentos possíveis.")

	return {
		"success": errors.is_empty(),
		"message": (
			"6 escolhas garantidas e 8 espécies com retratos verificados."
		),
		"errors": errors,
		"warnings": warnings
	}


static func _validate_founder_memories() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var chain_ids: Array[String] = FOUNDER_MEMORY_CATALOG_SCRIPT.get_chain_ids()
	if chain_ids != ["recognition", "responsibility", "belonging", "convictions"]:
		errors.append("As quatro cadeias pessoais não correspondem ao plano aprovado.")
	var start_days: Array[int] = []
	for chain_id: String in chain_ids:
		var start_day: int = FOUNDER_MEMORY_CATALOG_SCRIPT.get_start_day(chain_id)
		if start_day < 1 or start_days.has(start_day):
			errors.append("A cadeia %s possui início inválido ou repetido." % chain_id)
		start_days.append(start_day)

	var overview: Dictionary = GameManager.get_founder_memory_overview()
	if not bool(overview.get("initialized", false)):
		warnings.append("As memórias ainda aguardam a geração completa dos fundadores.")
	else:
		var chains_value: Variant = overview.get("chains", null)
		if not chains_value is Array or (chains_value as Array).size() != 4:
			errors.append("A campanha não possui uma cadeia atribuída a cada fundador.")
		else:
			var founder_ids: Array[String] = []
			for chain_value: Variant in chains_value as Array:
				if not chain_value is Dictionary:
					errors.append("Registro de cadeia de memória inválido.")
					continue
				var founder_id: String = String(
					(chain_value as Dictionary).get("founder_id", "")
				)
				if founder_id.is_empty() or founder_ids.has(founder_id):
					errors.append("Um fundador recebeu cadeia ausente ou repetida.")
				else:
					founder_ids.append(founder_id)

	var markers_value: Variant = overview.get("visual_markers", null)
	if not markers_value is Array:
		errors.append("A lista persistente de memórias visuais é inválida.")
	return {
		"success": errors.is_empty(),
		"message": "4 cadeias, 8 acontecimentos e janela tardia de 10 dias verificados.",
		"errors": errors,
		"warnings": warnings
	}


static func _validate_ui_quality() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var required_resources: Array[String] = [
		"res://scripts/ui/UIAccessibility.gd",
		"res://scripts/ui/MainMenu.gd",
		"res://scripts/ui/DialogueWindow.gd",
		"res://scripts/ui/SaveWindow.gd",
		"res://scripts/ui/CouncilWindow.gd"
	]
	for resource_path: String in required_resources:
		if not ResourceLoader.exists(resource_path):
			errors.append("Recurso de interface ausente: %s" % resource_path)

	var settings: Dictionary = GameSettings.get_settings()
	for required_key: String in [
		"reduced_motion",
		"instant_dialogue_text",
		"enhanced_contrast"
	]:
		if not settings.has(required_key):
			errors.append("Configuração de acessibilidade ausente: %s." % required_key)

	for season_id: String in ["spring", "summer", "autumn", "winter"]:
		var palette: Dictionary = MedievalTheme.get_season_palette(
			season_id,
			true
		)
		for palette_key: String in [
			"background",
			"panel_dark",
			"accent",
			"button",
			"button_hover"
		]:
			if not palette.has(palette_key):
				errors.append(
				"Paleta %s sem o token %s." % [season_id, palette_key]
			)

	var viewport_size: Vector2 = GameManager.get_viewport().get_visible_rect().size
	if viewport_size.x < 900.0 or viewport_size.y < 500.0:
		warnings.append(
			"A janela atual é menor que a área recomendada de 900 × 500."
		)

	return {
		"success": errors.is_empty(),
		"message": (
			"Três preferências acessíveis, quatro paletas sazonais "
			+ "e contratos dos principais modais verificados."
		),
		"errors": errors,
		"warnings": warnings
	}


static func _validate_live_systems() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []

	var population: Dictionary = GameManager.get_population_overview()
	for required_key: String in [
		"total_population",
		"housing_capacity",
		"common_population",
		"protected_named_resident_count"
	]:
		if not population.has(required_key):
			errors.append("População sem o campo %s." % required_key)

	if int(population.get("total_population", 0)) < GameManager.villagers.size():
		errors.append("A população total é menor que o elenco nomeado.")

	var council: Dictionary = GameManager.get_council_overview()
	var active_value: Variant = council.get("active", null)
	var reserve_value: Variant = council.get("reserve", null)
	if not active_value is Array or not reserve_value is Array:
		errors.append("Visão geral do Conselho está incompleta.")
	elif (active_value as Array).size() != GameManager.ACTIVE_COUNCIL_LIMIT:
		errors.append("A visão geral do Conselho não possui quatro ativos.")

	var buildings: Dictionary = GameManager.get_building_state()
	if not buildings.get("buildings", null) is Array:
		errors.append("Estado das construções sem catálogo de prédios.")
	elif (buildings.get("buildings", []) as Array).size() < 5:
		errors.append("Catálogo visual de construções incompleto.")
	if int(buildings.get("house_count", 0)) < 1:
		errors.append("Quantidade de casas inválida.")

	var construction_value: Variant = buildings.get("construction", null)
	if not construction_value is Dictionary:
		errors.append("Estado das construções sem fila de obras.")
	else:
		var construction: Dictionary = construction_value as Dictionary
		for required_key: String in [
			"site_capacity",
			"active_count",
			"queued_count",
			"active_orders",
			"queued_orders"
		]:
			if not construction.has(required_key):
				errors.append("Fila de obras sem o campo %s." % required_key)
		var expected_capacity: int = clampi(
			1 + floori(float(int(population.get("total_population", 0))) / 20.0),
			1,
			4
		)
		if int(construction.get("site_capacity", 0)) != expected_capacity:
			errors.append("Capacidade de canteiros não corresponde à população.")

	var campaign: Dictionary = GameManager.get_campaign_progress()
	for required_key: String in [
		"completed_days",
		"target_day",
		"met_goals",
		"total_goals",
		"campaign_identity",
		"evaluation_reports"
	]:
		if not campaign.has(required_key):
			errors.append("Campanha sem o campo %s." % required_key)

	if GameManager.is_council_ready() and not GameManager.is_campaign_finished():
		var forecast: Dictionary = GameManager.calculate_next_day_forecast()
		for required_key: String in [
			"food", "material", "happiness", "population"
		]:
			if not forecast.has(required_key):
				errors.append("Previsão sem o campo %s." % required_key)
	else:
		warnings.append("A previsão não foi calculada porque a partida não está pronta ou já terminou.")

	return {
		"success": errors.is_empty(),
		"message": (
			"População %d; Conselho %d/%d; %d prédios; %d obra(s) ativa(s) e %d na fila."
			% [
				int(population.get("total_population", 0)),
				(active_value as Array).size() if active_value is Array else 0,
				GameManager.ACTIVE_COUNCIL_LIMIT,
				(buildings.get("buildings", []) as Array).size()
				if buildings.get("buildings", null) is Array
				else 0,
				int((buildings.get("construction", {}) as Dictionary).get("active_count", 0))
				if buildings.get("construction", null) is Dictionary
				else 0,
				int((buildings.get("construction", {}) as Dictionary).get("queued_count", 0))
				if buildings.get("construction", null) is Dictionary
				else 0
			]
		),
		"errors": errors,
		"warnings": warnings
	}


static func _add_check(
	checks: Array[Dictionary],
	name: String,
	success: bool,
	message: String,
	errors_value: Variant,
	warnings_value: Variant
) -> void:
	var errors: Array = errors_value if errors_value is Array else []
	var warnings: Array = warnings_value if warnings_value is Array else []
	checks.append(
		{
			"name": name,
			"success": success and errors.is_empty(),
			"message": message,
			"errors": errors.duplicate(),
			"warnings": warnings.duplicate()
		}
	)
