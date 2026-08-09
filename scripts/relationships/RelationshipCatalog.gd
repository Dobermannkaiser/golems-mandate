class_name VillageRelationshipCatalog
extends RefCounted


const MIMO_ID: String = "passos_leves_faz_tudo"
const DALIA_ID: String = "bruxinha_ruiva"
const SILAS_ID: String = "meio_vampiro_emo_gotico"
const ROMANCE_IDS: Array[String] = [
	"aelric_ferreiro",
	"kobi_mercante",
	"orion_draconato",
	"rubra_meio_demonia",
	"brunna_ana_barbara",
	DALIA_ID,
	SILAS_ID
]
const TRACKED_IDS: Array[String] = [
	MIMO_ID,
	"aelric_ferreiro",
	"kobi_mercante",
	"orion_draconato",
	"rubra_meio_demonia",
	"brunna_ana_barbara",
	DALIA_ID,
	SILAS_ID
]

const PERSONAL_EVENT_POINT_THRESHOLDS: Array[int] = [200, 400, 600, 800]
const PERSONAL_EVENT_STAGE_NAMES: Array[String] = [
	"Amizade",
	"Confiança",
	"Intimidade",
	"Decisão"
]
const SCENE_800_IMAGE_PATHS: Dictionary = {
	MIMO_ID: "res://assets/relationships/scenes_800/mimo.jpg",
	"aelric_ferreiro": "res://assets/relationships/scenes_800/aelric.jpg",
	"kobi_mercante": "res://assets/relationships/scenes_800/kobi.jpg",
	"orion_draconato": "res://assets/relationships/scenes_800/orion.jpg",
	"rubra_meio_demonia": "res://assets/relationships/scenes_800/rubra.jpg",
	"brunna_ana_barbara": "res://assets/relationships/scenes_800/brunna.jpg",
	DALIA_ID: "res://assets/relationships/scenes_800/dalia.jpg",
	SILAS_ID: "res://assets/relationships/scenes_800/silas.jpg"
}


static func is_tracked(npc_id: String) -> bool:
	return TRACKED_IDS.has(npc_id)


static func is_romance_candidate(npc_id: String) -> bool:
	return ROMANCE_IDS.has(npc_id)


static func get_portrait_id(npc_id: String) -> String:
	if npc_id == MIMO_ID:
		return "mimo"
	return npc_id


static func get_relationship_title(level: int, kind: String) -> String:
	if kind == "partner":
		return "PARCEIRO"
	if kind == "romantic_interest":
		return "LAÇO ROMÂNTICO"
	if kind == "romance_available":
		return "ROMANCE DISPONÍVEL"
	var titles: Array[String] = [
		"DESCONHECIDO",
		"CONHECIDO",
		"COLEGA",
		"COMPANHEIRO",
		"AMIGO",
		"AMIGO PRÓXIMO",
		"CONFIDENTE",
		"LAÇO ESPECIAL",
		"CORAÇÃO ABERTO",
		"COMPROMISSO",
		"COMPANHEIRO DE VIDA"
	]
	return titles[clampi(level, 0, titles.size() - 1)]


static func get_next_personal_event_id(npc_id: String, relationship_data: Dictionary) -> String:
	var points: int = int(relationship_data.get("relationship_points", 0))
	var completed: Array = relationship_data.get("completed_personal_event_ids", []) as Array
	for index: int in range(4):
		var event_id: String = "%s_personal_%d" % [npc_id, index + 1]
		if points >= PERSONAL_EVENT_POINT_THRESHOLDS[index] and not completed.has(event_id):
			return event_id
	return ""


static func get_next_personal_event_threshold(relationship_data: Dictionary) -> int:
	var npc_id: String = String(relationship_data.get("npc_id", ""))
	var completed: Array = relationship_data.get("completed_personal_event_ids", []) as Array
	if npc_id.is_empty():
		return 0
	for index: int in range(PERSONAL_EVENT_POINT_THRESHOLDS.size()):
		var event_id: String = "%s_personal_%d" % [npc_id, index + 1]
		if not completed.has(event_id):
			return PERSONAL_EVENT_POINT_THRESHOLDS[index]
	return 0


static func get_personal_event_stage(event_id: String) -> String:
	var parts: PackedStringArray = event_id.split("_personal_", false)
	if parts.size() != 2 or not parts[1].is_valid_int():
		return "Cena importante"
	var index: int = int(parts[1]) - 1
	if index < 0 or index >= PERSONAL_EVENT_STAGE_NAMES.size():
		return "Cena importante"
	return PERSONAL_EVENT_STAGE_NAMES[index]


static func get_scene_800_image_path(npc_id: String) -> String:
	return String(SCENE_800_IMAGE_PATHS.get(npc_id, ""))


static func get_management_bonus_description(
	npc_id: String,
	level: int,
	is_partner: bool,
	relationship_data: Dictionary = {}
) -> String:
	if level < 4:
		return "O benefício de gestão será liberado no nível 4."
	match npc_id:
		MIMO_ID:
			return "+0,25 de felicidade por dia pela amizade de Mimo."
		"aelric_ferreiro":
			return "+3% de produção de material" + (" e +3% adicional pelo compromisso" if is_partner else "") + "."
		"kobi_mercante":
			return "-3% de manutenção" + (" e -2% de consumo de alimentação pelo compromisso" if is_partner else "") + "."
		"orion_draconato":
			return "+2% de produção de alimentação e material" + (" e +2% adicional pelo compromisso" if is_partner else "") + "."
		"rubra_meio_demonia":
			return "+0,30 de felicidade por dia" + (" e +0,40 adicional pelo compromisso" if is_partner else "") + "."
		"brunna_ana_barbara":
			return "-3% de desgaste de felicidade" + (" e -4% adicional pelo compromisso" if is_partner else "") + "."
		DALIA_ID:
			return "Horta Partilhada: +4% de alimentação quando o saldo diário previsto estiver negativo."
		SILAS_ID:
			var last_day: int = int(
				relationship_data.get("last_management_passive_day", 0)
			)
			return (
				"Canção de Vigília: após uma perda diária de felicidade, recupera 1 ponto; "
				+ "intervalo de 5 dias."
				+ (" Última ativação: dia %d." % last_day if last_day > 0 else " Ainda não ativada.")
			)
		_:
			return "Benefício narrativo."


static func get_management_modifiers(
	npc_id: String,
	level: int,
	is_partner: bool,
	context: Dictionary = {}
) -> Dictionary:
	var result: Dictionary = {
		"food_production_bonus": 0.0,
		"material_production_bonus": 0.0,
		"daily_happiness_bonus": 0.0,
		"food_consumption_reduction": 0.0,
		"maintenance_reduction": 0.0,
		"happiness_decay_reduction": 0.0
	}
	if level < 4:
		return result

	match npc_id:
		MIMO_ID:
			result["daily_happiness_bonus"] = 0.25
		"aelric_ferreiro":
			result["material_production_bonus"] = 0.03 + (0.03 if is_partner else 0.0)
		"kobi_mercante":
			result["maintenance_reduction"] = 0.03
			if is_partner:
				result["food_consumption_reduction"] = 0.02
		"orion_draconato":
			var bonus: float = 0.02 + (0.02 if is_partner else 0.0)
			result["food_production_bonus"] = bonus
			result["material_production_bonus"] = bonus
		"rubra_meio_demonia":
			result["daily_happiness_bonus"] = 0.30 + (0.40 if is_partner else 0.0)
		"brunna_ana_barbara":
			result["happiness_decay_reduction"] = 0.03 + (0.04 if is_partner else 0.0)
		DALIA_ID:
			if bool(context.get("food_balance_negative", false)):
				result["food_production_bonus"] = 0.04
	return result
