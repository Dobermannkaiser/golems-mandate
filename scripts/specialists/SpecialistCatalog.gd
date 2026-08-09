class_name SpecialistCatalog
extends RefCounted


const MIMO_ID: String = "passos_leves_faz_tudo"
const AELRIC_ID: String = "aelric_ferreiro"
const KOBI_ID: String = "kobi_mercante"
const ORION_ID: String = "orion_draconato"
const RUBRA_ID: String = "rubra_meio_demonia"
const BRUNNA_ID: String = "brunna_ana_barbara"
const SILAS_ID: String = "meio_vampiro_emo_gotico"
const DALIA_ID: String = "bruxinha_ruiva"


static func get_mimo_npc_data() -> Dictionary:
	return {
		"npc_id": MIMO_ID,
		"display_name": "Mimo",
		"species_id": "passos_leves",
		"profession_id": "faz_tudo",
		"passive_id": "faz_tudo",
		"portrait_set_id": "mimo",
		"arrival_checkpoint_day": 0,
		"romance_available": false,
		"known": true
	}


static func get_story_npc_data() -> Array[Dictionary]:
	return [
		{
			"npc_id": AELRIC_ID,
			"display_name": "Aelric Brasa-Clara",
			"species_id": "elfo",
			"profession_id": "ferreiro_runista",
			"passive_id": "brasas_claras",
			"portrait_set_id": AELRIC_ID,
			"arrival_checkpoint_day": 15,
			"romance_available": true,
			"known": false
		},
		{
			"npc_id": KOBI_ID,
			"display_name": "Kobi Cobre-Fino",
			"species_id": "kobold",
			"profession_id": "mercador",
			"passive_id": "olho_para_negocios",
			"portrait_set_id": KOBI_ID,
			"arrival_checkpoint_day": 30,
			"romance_available": true,
			"known": false
		},
		{
			"npc_id": ORION_ID,
			"display_name": "Orion Escamagelo",
			"species_id": "draconato",
			"profession_id": "pesquisador_arcano",
			"passive_id": "leitura_de_mana",
			"portrait_set_id": ORION_ID,
			"arrival_checkpoint_day": 45,
			"romance_available": true,
			"known": false
		},
		{
			"npc_id": RUBRA_ID,
			"display_name": "Rubra Verbum",
			"species_id": "meio_demonia",
			"profession_id": "arquivista_arcana",
			"passive_id": "memoria_proibida",
			"portrait_set_id": RUBRA_ID,
			"arrival_checkpoint_day": 60,
			"romance_available": true,
			"known": false
		},
		{
			"npc_id": BRUNNA_ID,
			"display_name": "Brunna Ana",
			"species_id": "ana",
			"profession_id": "barbara_runista",
			"passive_id": "coragem_ritual",
			"portrait_set_id": BRUNNA_ID,
			"arrival_checkpoint_day": 75,
			"romance_available": true,
			"known": false
		},
		{
			"npc_id": SILAS_ID,
			"display_name": "Silas Nocturno",
			"species_id": "meio_vampiro",
			"profession_id": "musico_noturno",
			"passive_id": "cancao_de_vigilia",
			"portrait_set_id": SILAS_ID,
			"arrival_checkpoint_day": 90,
			"romance_available": true,
			"known": false
		},
		{
			"npc_id": DALIA_ID,
			"display_name": "Dália Folhaverde",
			"species_id": "bruxa",
			"profession_id": "herborista",
			"passive_id": "horta_partilhada",
			"portrait_set_id": DALIA_ID,
			"arrival_checkpoint_day": 105,
			"romance_available": true,
			"known": false
		}
	]


static func get_all_prepared_npc_data() -> Array[Dictionary]:
	var prepared: Array[Dictionary] = [get_mimo_npc_data()]
	prepared.append_array(get_story_npc_data())
	return prepared


static func get_story_npc_ids() -> Array[String]:
	return [
		AELRIC_ID,
		KOBI_ID,
		ORION_ID,
		RUBRA_ID,
		BRUNNA_ID,
		SILAS_ID,
		DALIA_ID
	]
