class_name VillageStoryChapterCatalog
extends RefCounted


const CHAPTER_DAYS: Array[int] = [15, 30, 45, 60, 75, 90, 105, 120]


static func create_chapters() -> Array[Dictionary]:
	return [
		{
			"id": "capitulo_01_forja",
			"day": 15,
			"title": "A FORJA DAS BRASAS CLARAS",
			"npc_id": "aelric_ferreiro",
			"intro_dialogue_id": "chapter_15_intro",
			"event_id": "story_day15_aelric_forge"
		},
		{
			"id": "capitulo_02_contrato",
			"day": 30,
			"title": "O CONTRATO DE COBRE-FINO",
			"npc_id": "kobi_mercante",
			"intro_dialogue_id": "chapter_30_intro",
			"event_id": "story_day30_kobi_contract"
		},
		{
			"id": "capitulo_03_fissura",
			"day": 45,
			"title": "A FISSURA QUE SONHAVA",
			"npc_id": "orion_draconato",
			"intro_dialogue_id": "chapter_45_intro",
			"event_id": "story_day45_orion_rift"
		},
		{
			"id": "capitulo_04_arquivo",
			"day": 60,
			"title": "O ARQUIVO SOB AS FOLHAS",
			"npc_id": "rubra_meio_demonia",
			"intro_dialogue_id": "chapter_60_intro",
			"event_id": "story_day60_rubra_archive"
		},
		{
			"id": "capitulo_05_cacada",
			"day": 75,
			"title": "A CAÇADA DA NEVE RÚNICA",
			"npc_id": "brunna_ana_barbara",
			"intro_dialogue_id": "chapter_75_intro",
			"event_id": "story_day75_brunna_hunt"
		},
		{
			"id": "capitulo_06_vigilia",
			"day": 90,
			"title": "A CANÇÃO DEPOIS DA MEIA-NOITE",
			"npc_id": "meio_vampiro_emo_gotico",
			"intro_dialogue_id": "chapter_90_intro",
			"event_id": "story_day90_silas_concert"
		},
		{
			"id": "capitulo_07_sementes",
			"day": 105,
			"title": "A HORTA QUE BATIA À PORTA",
			"npc_id": "bruxinha_ruiva",
			"intro_dialogue_id": "chapter_105_intro",
			"event_id": "story_day105_dalia_garden"
		},
		{
			"id": "capitulo_06_auditoria",
			"day": 120,
			"title": "A AUDITORIA DAS QUATRO ESTAÇÕES",
			"npc_id": "",
			"intro_dialogue_id": "chapter_120_intro",
			"event_id": "story_day120_divine_audit"
		}
	]


static func create_story_events() -> Array[Dictionary]:
	return [
		_create_day15_event(),
		_create_day30_event(),
		_create_day45_event(),
		_create_day60_event(),
		_create_day75_event(),
		_create_day90_event(),
		_create_day105_event(),
		_create_day120_event()
	]


static func get_chapter_for_day(day: int) -> Dictionary:
	for chapter: Dictionary in create_chapters():
		if int(chapter.get("day", 0)) == day:
			return chapter.duplicate(true)
	return {}


static func get_chapter_by_id(chapter_id: String) -> Dictionary:
	for chapter: Dictionary in create_chapters():
		if String(chapter.get("id", "")) == chapter_id:
			return chapter.duplicate(true)
	return {}


static func get_story_event(event_id: String) -> Dictionary:
	for event_data: Dictionary in create_story_events():
		if String(event_data.get("id", "")) == event_id:
			return event_data.duplicate(true)
	return {}


static func is_chapter_day(day: int) -> bool:
	return CHAPTER_DAYS.has(day)


static func _create_day15_event() -> Dictionary:
	return {
		"id": "story_day15_aelric_forge",
		"title": "A FORJA SEM FOGO",
		"description": (
			"Aelric revela que a centelha rúnica de sua forja está presa em uma bigorna "
			+ "amaldiçoada. A vila precisa escolher como libertá-la antes da avaliação."
		),
		"min_day": 15,
		"is_story_event": true,
		"chapter_id": "capitulo_01_forja",
		"chapter_day": 15,
		"recruit_npc_id": "aelric_ferreiro",
		"choices": [
			{
				"id": "rebuild_forge",
				"title": "Erguer uma forja segura",
				"description": "Custo: 12 materiais. Resultado garantido e grande aprovação de Aelric.",
				"costs": {"material": 12.0},
				"effects": {"happiness": 5.0},
				"story_flag": "aelric_forge_rebuilt",
				"outro_variant": "safe",
				"relationship_delta": 2,
				"result_text": "A vila ergueu uma forja de pedra e cobre. Aelric aceitou permanecer como mestre ferreiro."
			},
			{
				"id": "rune_timber",
				"title": "Usar madeira rúnica da Serraria",
				"description": "Opção especial: exige Serraria nível 1. Economiza material e fortalece a produção.",
				"required_building": "sawmill",
				"required_building_level": 1,
				"effects": {"material": 6.0, "happiness": 3.0},
				"story_flag": "aelric_rune_timber",
				"outro_variant": "special",
				"relationship_delta": 3,
				"result_text": "As vigas da serraria absorveram as runas. A forja acendeu com fogo azul e sem consumir as reservas."
			},
			{
				"id": "break_curse",
				"title": "Quebrar a maldição da bigorna",
				"description": "Teste de Inteligência. Sucesso recupera material; falha danifica ferramentas.",
				"requires_villager": true,
				"test_attribute": "intelligence",
				"base_chance": 0.22,
				"chance_per_point": 0.075,
				"min_chance": 0.30,
				"max_chance": 0.92,
				"success_effects": {"material": 8.0, "happiness": 4.0},
				"failure_effects": {"material": -5.0, "happiness": -2.0},
				"story_flag": "aelric_curse_attempted",
				"outro_variant": "risky",
				"relationship_delta": 1,
				"success_text": "decifrou a runa invertida e libertou uma chama ancestral da bigorna.",
				"failure_text": "quebrou a maldição, mas também metade das ferramentas. Aelric suspirou e decidiu ficar para consertá-las."
			}
		]
	}


static func _create_day30_event() -> Dictionary:
	return {
		"id": "story_day30_kobi_contract",
		"title": "O CONTRATO QUE SE REESCREVE",
		"description": (
			"Kobi Cobre-Fino oferece abrir uma rota comercial. O pergaminho muda as cláusulas "
			+ "quando ninguém está olhando e uma pequena fada contadora mora no tinteiro."
		),
		"min_day": 30,
		"is_story_event": true,
		"chapter_id": "capitulo_02_contrato",
		"chapter_day": 30,
		"recruit_npc_id": "kobi_mercante",
		"choices": [
			{
				"id": "pay_clear_contract",
				"title": "Pagar por um contrato simples",
				"description": "Custo: 10 alimentos e 6 materiais. Atrai um novo morador.",
				"costs": {"food": 10.0, "material": 6.0},
				"effects": {"happiness": 4.0},
				"population_delta": 1,
				"story_flag": "kobi_fair_contract",
				"outro_variant": "safe",
				"relationship_delta": 2,
				"result_text": "Kobi aceitou termos claros, ainda que tenha chorado um pouco ao riscar as letras miúdas."
			},
			{
				"id": "festival_market",
				"title": "Assinar na Praça da Vila",
				"description": "Opção especial: exige Praça nível 1. Testemunhas impedem cláusulas sorrateiras.",
				"required_building": "square",
				"required_building_level": 1,
				"effects": {"food": 8.0, "material": 8.0, "happiness": 5.0},
				"population_delta": 1,
				"story_flag": "kobi_public_market",
				"outro_variant": "special",
				"relationship_delta": 3,
				"result_text": "A assinatura pública transformou a praça em um pequeno mercado encantado."
			},
			{
				"id": "outsmart_ink_fairy",
				"title": "Negociar com a fada do tinteiro",
				"description": "Teste de Carisma. Pode render uma excelente rota ou uma multa feérica.",
				"requires_villager": true,
				"test_attribute": "charisma",
				"base_chance": 0.20,
				"chance_per_point": 0.08,
				"min_chance": 0.28,
				"max_chance": 0.92,
				"success_effects": {"food": 12.0, "material": 7.0, "happiness": 2.0},
				"failure_effects": {"food": -7.0, "happiness": -3.0},
				"story_flag": "kobi_fairy_bargain",
				"outro_variant": "risky",
				"relationship_delta": 1,
				"success_text": "convenceu a fada a aceitar elogios, três botões brilhantes e uma assinatura honesta.",
				"failure_text": "pronunciou uma vírgula como ponto e a fada cobrou uma taxa por gramática ofensiva."
			}
		]
	}


static func _create_day45_event() -> Dictionary:
	return {
		"id": "story_day45_orion_rift",
		"title": "A FISSURA QUE SONHAVA",
		"description": (
			"Uma rachadura de mana abriu-se sob o caminho central. Ela sussurra sonhos dos moradores "
			+ "e faz a chuva subir. Orion Escamagelo chegou para estudar o fenômeno."
		),
		"min_day": 45,
		"is_story_event": true,
		"chapter_id": "capitulo_03_fissura",
		"chapter_day": 45,
		"recruit_npc_id": "orion_draconato",
		"choices": [
			{
				"id": "seal_rift",
				"title": "Selar a fissura com pedra e sal",
				"description": "Custo: 14 materiais. Solução segura.",
				"costs": {"material": 14.0},
				"effects": {"happiness": 4.0},
				"story_flag": "orion_rift_sealed",
				"outro_variant": "safe",
				"result_text": "A fissura adormeceu sob um círculo de pedras. Orion decidiu ficar para vigiar seus sonhos."
			},
			{
				"id": "cool_with_well",
				"title": "Conduzir água encantada do Poço",
				"description": "Opção especial: exige Poço nível 2. Converte a fissura em fonte de mana estável.",
				"required_building": "well",
				"required_building_level": 2,
				"effects": {"food": 6.0, "material": 6.0, "happiness": 6.0},
				"story_flag": "orion_mana_spring",
				"outro_variant": "special",
				"relationship_delta": 2,
				"result_text": "A água esfriou a fenda e criou uma fonte de mana que canta apenas às terças-feiras."
			},
			{
				"id": "map_rift_dreams",
				"title": "Mapear os sonhos da fissura",
				"description": "Teste de Inteligência. Pode revelar recursos ou espalhar pesadelos.",
				"requires_villager": true,
				"test_attribute": "intelligence",
				"base_chance": 0.18,
				"chance_per_point": 0.08,
				"min_chance": 0.26,
				"max_chance": 0.94,
				"success_effects": {"food": 10.0, "material": 10.0, "happiness": 3.0},
				"failure_effects": {"happiness": -8.0},
				"story_flag": "orion_dream_map",
				"outro_variant": "risky",
				"relationship_delta": 1,
				"success_text": "desenhou um mapa dos sonhos e encontrou veios de cristal sob a vila.",
				"failure_text": "escutou a fissura por tempo demais; naquela noite, toda a vila sonhou com formulários infinitos."
			}
		]
	}


static func _create_day60_event() -> Dictionary:
	return {
		"id": "story_day60_rubra_archive",
		"title": "O ARQUIVO DAS FOLHAS VERMELHAS",
		"description": (
			"Sob uma árvore antiga surgiu uma biblioteca enterrada. Os livros mordem dedos curiosos "
			+ "e Rubra Verbum afirma que um deles conhece o verdadeiro nome da vila."
		),
		"min_day": 60,
		"is_story_event": true,
		"chapter_id": "capitulo_04_arquivo",
		"chapter_day": 60,
		"recruit_npc_id": "rubra_meio_demonia",
		"choices": [
			{
				"id": "preserve_archive",
				"title": "Preservar e catalogar o arquivo",
				"description": "Custo: 8 materiais e 5 alimentos para os pesquisadores.",
				"costs": {"material": 8.0, "food": 5.0},
				"effects": {"happiness": 5.0},
				"story_flag": "rubra_archive_preserved",
				"outro_variant": "safe",
				"relationship_delta": 2,
				"result_text": "Os livros receberam capas novas, etiquetas e uma regra explícita contra morder bibliotecários."
			},
			{
				"id": "civil_registry",
				"title": "Registrar os grimórios como cidadãos",
				"description": "Opção especial: exige um Servidor Público no Conselho.",
				"required_profession": 3,
				"effects": {"happiness": 8.0, "material": 5.0},
				"story_flag": "rubra_books_citizens",
				"outro_variant": "special",
				"relationship_delta": 3,
				"result_text": "Os grimórios aceitaram obedecer às leis em troca de carteiras de biblioteca e direito a um feriado anual."
			},
			{
				"id": "translate_true_name",
				"title": "Traduzir o verdadeiro nome da vila",
				"description": "Teste de Inteligência. Conhecimento poderoso, mas instável.",
				"requires_villager": true,
				"test_attribute": "intelligence",
				"base_chance": 0.18,
				"chance_per_point": 0.075,
				"min_chance": 0.25,
				"max_chance": 0.90,
				"success_effects": {"happiness": 10.0, "material": 5.0},
				"failure_effects": {"happiness": -6.0, "food": -4.0},
				"story_flag": "rubra_true_name",
				"outro_variant": "risky",
				"relationship_delta": 1,
				"success_text": "pronunciou o nome antigo e a vila brilhou como uma constelação por um minuto.",
				"failure_text": "errou uma sílaba e deu consciência temporária a todas as colheres da despensa."
			}
		]
	}


static func _create_day75_event() -> Dictionary:
	return {
		"id": "story_day75_brunna_hunt",
		"title": "A BESTA DE GELO E SINOS",
		"description": (
			"Uma criatura coberta de runas ronda as casas e rouba calor das chaminés. "
			+ "Brunna Ana chegou seguindo suas pegadas e exige uma decisão antes da noite."
		),
		"min_day": 75,
		"is_story_event": true,
		"chapter_id": "capitulo_05_cacada",
		"chapter_day": 75,
		"recruit_npc_id": "brunna_ana_barbara",
		"choices": [
			{
				"id": "prepare_traps",
				"title": "Preparar armadilhas e fogueiras",
				"description": "Custo: 10 materiais e 8 alimentos. Proteção garantida.",
				"costs": {"material": 10.0, "food": 8.0},
				"effects": {"happiness": 5.0},
				"story_flag": "brunna_safe_hunt",
				"outro_variant": "safe",
				"relationship_delta": 2,
				"result_text": "As armadilhas cercaram a besta sem feri-la, e Brunna reconheceu a disciplina da vila."
			},
			{
				"id": "palisade_hunt",
				"title": "Conduzir a besta pela Muralha",
				"description": "Opção especial: exige Muralha nível 2. Protege as casas e poupa recursos.",
				"required_building": "palisade",
				"required_building_level": 2,
				"effects": {"happiness": 8.0, "material": 6.0},
				"story_flag": "brunna_palisade_hunt",
				"outro_variant": "special",
				"relationship_delta": 3,
				"result_text": "Os portões guiaram a criatura para um círculo de runas. Ela se rendeu e virou guardiã do bosque."
			},
			{
				"id": "face_beast",
				"title": "Enfrentar a besta de frente",
				"description": "Teste de Força. Vitória rende reservas; falha causa danos.",
				"requires_villager": true,
				"test_attribute": "strength",
				"base_chance": 0.20,
				"chance_per_point": 0.075,
				"min_chance": 0.28,
				"max_chance": 0.90,
				"success_effects": {"food": 12.0, "material": 8.0, "happiness": 4.0},
				"failure_effects": {"material": -10.0, "happiness": -5.0},
				"story_flag": "brunna_direct_hunt",
				"outro_variant": "risky",
				"relationship_delta": 1,
				"success_text": "manteve a posição até Brunna quebrar a runa de fúria no chifre da criatura.",
				"failure_text": "foi arremessado em um monte de neve, mas deu a Brunna tempo para salvar as casas."
			}
		]
	}


static func _create_day90_event() -> Dictionary:
	return {
		"id": "story_day90_silas_concert",
		"title": "O PALCO QUE TEMIA O AMANHECER",
		"description": (
			"Um músico meio-vampiro chamado Silas chegou com uma caixa de instrumentos "
			+ "e uma proposta: tocar durante a vigília, desde que a vila decida como reagir "
			+ "aos boatos que o seguiram pela estrada."
		),
		"min_day": 90,
		"is_story_event": true,
		"chapter_id": "capitulo_06_vigilia",
		"chapter_day": 90,
		"recruit_npc_id": "meio_vampiro_emo_gotico",
		"choices": [
			{
				"id": "silas_open_concert",
				"title": "Abrir a praça para a apresentação",
				"description": "Custo: 6 materiais. A vila prepara um palco seguro e público.",
				"costs": {"material": 6.0},
				"effects": {"happiness": 6.0},
				"story_flag": "silas_public_concert",
				"outro_variant": "safe",
				"relationship_delta": 2,
				"result_text": "A praça recebeu música, luzes baixas e espaço suficiente para que curiosidade substituísse medo."
			},
			{
				"id": "silas_rubra_context",
				"title": "Pedir que Rubra conte a história inteira",
				"description": "Opção de amizade: exige 340 pontos com Rubra. Revela a origem dos boatos antes da decisão pública.",
				"required_relationship_id": "rubra_meio_demonia",
				"required_relationship_name": "Rubra",
				"required_relationship_points": 340,
				"effects": {"happiness": 8.0, "material": 3.0},
				"story_flag": "silas_rubra_testimony",
				"outro_variant": "special",
				"relationship_delta": 3,
				"result_text": "Rubra encontrou os registros que desmontavam a acusação. Silas pôde tocar sem transformar a própria vida em defesa."
			},
			{
				"id": "silas_night_watch",
				"title": "Investigar os passos durante a vigília",
				"description": "Teste de Inteligência. Pode esclarecer os boatos ou alimentar a tensão.",
				"requires_villager": true,
				"test_attribute": "intelligence",
				"base_chance": 0.20,
				"chance_per_point": 0.075,
				"min_chance": 0.28,
				"max_chance": 0.92,
				"success_effects": {"happiness": 7.0, "material": 5.0},
				"failure_effects": {"happiness": -5.0},
				"story_flag": "silas_watch_investigated",
				"outro_variant": "risky",
				"relationship_delta": 1,
				"success_text": "encontrou pegadas de um contrabandista que usava a fama de Silas como disfarce.",
				"failure_text": "seguiu ecos falsos até o amanhecer. Silas ficou para ajudar a vila a reconstruir a confiança."
			}
		]
	}


static func _create_day105_event() -> Dictionary:
	return {
		"id": "story_day105_dalia_garden",
		"title": "A HORTA QUE CRESCEU DURANTE A NOITE",
		"description": (
			"Uma horta ambulante parou diante da vila e se recusa a seguir viagem. Dália, "
			+ "a bruxinha que a acompanha, afirma que as raízes escolheram ficar — mas "
			+ "precisam de um acordo que inclua toda a comunidade."
		),
		"min_day": 105,
		"is_story_event": true,
		"chapter_id": "capitulo_07_sementes",
		"chapter_day": 105,
		"recruit_npc_id": "bruxinha_ruiva",
		"choices": [
			{
				"id": "dalia_shared_beds",
				"title": "Reservar canteiros partilhados",
				"description": "Custo: 8 materiais. Cria uma solução aberta para famílias antigas e novas.",
				"costs": {"material": 8.0},
				"effects": {"food": 7.0, "happiness": 5.0},
				"story_flag": "dalia_shared_garden",
				"outro_variant": "safe",
				"relationship_delta": 2,
				"result_text": "Dália desenhou canteiros comuns, espaços familiares e um caminho largo o bastante para ninguém ficar de fora."
			},
			{
				"id": "dalia_aelric_irrigation",
				"title": "Combinar raízes e engenharia de Aelric",
				"description": "Opção de amizade: exige 340 pontos com Aelric. Melhora a irrigação sem ferir a horta viva.",
				"required_relationship_id": "aelric_ferreiro",
				"required_relationship_name": "Aelric",
				"required_relationship_points": 340,
				"effects": {"food": 10.0, "material": 4.0, "happiness": 4.0},
				"story_flag": "dalia_runic_irrigation",
				"outro_variant": "special",
				"relationship_delta": 3,
				"result_text": "A confiança de Aelric permitiu adaptar runas de irrigação. Dália aprovou cada canal junto das raízes."
			},
			{
				"id": "dalia_partner_seed",
				"title": "Plantar uma semente de compromisso",
				"description": "Opção de romance: exige um parceiro oficial. A relação do Prefeito inspira um ritual comunitário.",
				"requires_official_partner": true,
				"effects": {"food": 8.0, "happiness": 8.0},
				"story_flag": "dalia_commitment_seed",
				"outro_variant": "romance",
				"relationship_delta": 2,
				"result_text": "A semente reconheceu um compromisso já assumido e espalhou flores pela horta sem transformar romance em obrigação."
			},
			{
				"id": "dalia_follow_roots",
				"title": "Seguir o mapa traçado pelas raízes",
				"description": "Teste de Carisma. Pode unir a vizinhança ou deixar a horta inquieta.",
				"requires_villager": true,
				"test_attribute": "charisma",
				"base_chance": 0.20,
				"chance_per_point": 0.075,
				"min_chance": 0.28,
				"max_chance": 0.92,
				"success_effects": {"food": 12.0, "happiness": 5.0},
				"failure_effects": {"food": -5.0, "happiness": -3.0},
				"story_flag": "dalia_roots_followed",
				"outro_variant": "risky",
				"relationship_delta": 1,
				"success_text": "convenceu as famílias a seguir o desenho das raízes e encontrou solo fértil entre as casas.",
				"failure_text": "organizou o plantio cedo demais. Dália permaneceu para replantar tudo com mais escuta e menos pressa."
			}
		]
	}


static func _create_day120_event() -> Dictionary:
	return {
		"id": "story_day120_divine_audit",
		"title": "A ÚLTIMA PERGUNTA DA DEUSA",
		"description": (
			"A Deusa dos Formulários Celestiais desceu em uma escada de luz. Antes de abrir "
			+ "a pasta da auditoria, ela pergunta o que realmente tornou esta vila digna de existir."
		),
		"min_day": 120,
		"is_story_event": true,
		"chapter_id": "capitulo_06_auditoria",
		"chapter_day": 120,
		"recruit_npc_id": "",
		"choices": [
			{
				"id": "people_answer",
				"title": "As pessoas que escolheram ficar",
				"description": "Resposta sincera. A vila recebe felicidade antes da avaliação final.",
				"effects": {"happiness": 8.0},
				"story_flag": "final_people",
				"outro_variant": "people",
				"result_text": "A deusa fechou a planilha por um instante e admitiu que aquela resposta não cabia em uma célula."
			},
			{
				"id": "work_answer",
				"title": "O trabalho que transformou ruínas em lar",
				"description": "Reconhece a gestão. Recupera material e alimentação antes da avaliação.",
				"effects": {"food": 6.0, "material": 6.0},
				"story_flag": "final_work",
				"outro_variant": "work",
				"result_text": "As construções da vila brilharam, cada prego e cada panela lembrando quem os colocou ali."
			},
			{
				"id": "perfect_mayor_answer",
				"title": "A habilidade Prefeito Perfeito... e muita ajuda",
				"description": "Opção especial: exige os sete NPCs dos capítulos conhecidos.",
				"required_known_npcs": 7,
				"effects": {"happiness": 10.0, "food": 4.0, "material": 4.0},
				"story_flag": "final_found_family",
				"outro_variant": "special",
				"result_text": "Mimo tentou aplaudir com uma colher, Kobi calculou o valor emocional e até Aelric sorriu. Quase."
			}
		]
	}
