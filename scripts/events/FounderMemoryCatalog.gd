class_name FounderMemoryCatalog
extends RefCounted


const CHAIN_IDS: Array[String] = [
	"recognition",
	"responsibility",
	"belonging",
	"convictions"
]

const START_DAYS: Dictionary = {
	"recognition": 8,
	"responsibility": 28,
	"belonging": 48,
	"convictions": 68
}


static func get_chain_ids() -> Array[String]:
	return CHAIN_IDS.duplicate()


static func get_start_day(chain_id: String) -> int:
	return int(START_DAYS.get(chain_id, 1))


static func get_chain_name(chain_id: String) -> String:
	match chain_id:
		"recognition": return "Reconhecimento"
		"responsibility": return "Responsabilidade"
		"belonging": return "Pertencimento"
		"convictions": return "Convicções"
		_: return "Memória"


static func score_compatibility(chain_id: String, founder: Dictionary) -> int:
	var attributes: Dictionary = founder.get("attributes", {})
	var personality_id: String = String(founder.get("personality_id", ""))
	var passive_id: String = String(founder.get("passive_id", ""))
	var score: int = 0

	match chain_id:
		"recognition":
			score = int(attributes.get("charisma", 1)) * 4
			score += int(attributes.get("intelligence", 1))
			if personality_id in ["ambitious", "optimistic", "kind"]:
				score += 8
			if passive_id in ["dedicado", "motivador", "veterano"]:
				score += 5
		"responsibility":
			score = int(attributes.get("intelligence", 1)) * 3
			score += int(attributes.get("strength", 1)) * 2
			if personality_id in ["cautious", "practical", "stubborn"]:
				score += 8
			if passive_id in ["protetor", "organizador", "improvisador"]:
				score += 5
		"belonging":
			score = int(attributes.get("charisma", 1)) * 3
			score += int(attributes.get("agility", 1)) * 2
			if personality_id in ["kind", "playful", "pessimistic"]:
				score += 8
			if passive_id in ["autossuficiente", "versatil", "mediador", "faz_tudo"]:
				score += 5
		"convictions":
			score = int(attributes.get("intelligence", 1)) * 3
			score += int(attributes.get("charisma", 1)) * 2
			if personality_id in ["stubborn", "ambitious", "practical"]:
				score += 8
			if passive_id in ["economico", "rival_produtivo", "inquieto"]:
				score += 5

	return score


static func build_event(
	chain_id: String,
	stage: String,
	context: Dictionary,
	opening_choice_id: String = ""
) -> Dictionary:
	var event_data: Dictionary = (
		_build_opening_event(chain_id, context)
		if stage == "opening"
		else _build_consequence_event(chain_id, context, opening_choice_id)
	)
	if event_data.is_empty():
		return {}

	event_data["is_founder_memory"] = true
	event_data["memory_chain_id"] = chain_id
	event_data["memory_stage"] = stage
	event_data["memory_founder_id"] = String(context.get("founder_id", ""))
	event_data["fixed_actor_id"] = String(context.get("founder_id", ""))
	return event_data


static func _build_opening_event(chain_id: String, context: Dictionary) -> Dictionary:
	var founder_name: String = String(context.get("founder_name", "Conselheiro"))
	var situation: String = _situation_text(context)

	match chain_id:
		"recognition":
			return {
				"id": "founder_memory_recognition_opening",
				"title": "O TRABALHO QUE NINGUÉM NOMEIA",
				"description": (
					"%s espera o salão esvaziar antes de falar. Diz que os resultados "
					+ "do Conselho aparecem nos relatórios, mas raramente carregam o nome "
					+ "de quem os tornou possíveis. %s\n\nA fala não é uma cobrança direta, "
					+ "mas deixa claro que a resposta será lembrada."
				) % [founder_name, situation],
				"choices": [
					_choice(
						"recognition_public", "Reconhecer diante da vila",
						"Torna o mérito visível agora. Ganha 2 de felicidade.",
						{"happiness": 2.0},
						"%s agradece, mas pergunta em voz baixa se o reconhecimento continuará quando o trabalho deixar de ser conveniente." % founder_name
					),
					_choice(
						"recognition_private", "Agradecer em particular",
						"Uma resposta pessoal, sem efeito imediato nos recursos.",
						{},
						"%s aceita o agradecimento e diz que observará se as próximas decisões confirmarão aquelas palavras." % founder_name
					),
					_choice(
						"recognition_results", "Pedir mais resultados primeiro",
						"Prioriza produtividade: +2 materiais, -2 felicidade.",
						{"material": 2.0, "happiness": -2.0},
						"%s volta ao trabalho sem discutir. O silêncio deixa a conversa inacabada." % founder_name
					)
				]
			}
		"responsibility":
			return {
				"id": "founder_memory_responsibility_opening",
				"title": "UM PLANO COM NOME E ROSTO",
				"description": (
					"%s apresenta um plano para reagir à próxima pressão sobre a vila e "
					+ "pede responsabilidade real sobre a execução. %s\n\nA proposta revela "
					+ "confiança, mas também o medo de receber toda a culpa se algo falhar."
				) % [founder_name, situation],
				"choices": [
					_choice(
						"responsibility_trust", "Confiar no plano",
						"Dá autonomia. Não altera recursos agora.", {},
						"%s assume a tarefa e promete não esconder um erro atrás do cargo." % founder_name
					),
					_choice(
						"responsibility_safeguards", "Exigir salvaguardas",
						"Consome 3 materiais para preparar reservas e rotas alternativas.",
						{"material": -3.0},
						"%s considera a precaução justa e registra cada limite antes de começar." % founder_name
					),
					_choice(
						"responsibility_control", "Manter controle direto",
						"Evita entregar autonomia. Perde 2 de felicidade.",
						{"happiness": -2.0},
						"%s concorda com a cabeça, mas lembra que responsabilidade sem poder de decisão é apenas exposição." % founder_name
					)
				]
			}
		"belonging":
			return {
				"id": "founder_memory_belonging_opening",
				"title": "UM LUGAR QUE MUDA",
				"description": (
					"Com novas cartas e funções surgindo, %s pergunta se ser fundador ainda "
					+ "significa ter um lugar próprio ou apenas ter chegado antes. %s\n\nA "
					+ "pergunta parece casual, mas acompanha cada mudança do Conselho."
				) % [founder_name, situation],
				"choices": [
					_choice(
						"belonging_affirm", "Afirmar que seu lugar permanece",
						"Ganha 2 de felicidade.", {"happiness": 2.0},
						"%s sorri, mas responde que pertencimento precisa sobreviver às mudanças para ser verdadeiro." % founder_name
					),
					_choice(
						"belonging_adapt", "Dizer que todos precisam se adaptar",
						"Resposta franca, sem efeito imediato.", {},
						"%s aceita a resposta e decide observar quem terá espaço quando a composição mudar." % founder_name
					),
					_choice(
						"belonging_earn", "Dizer que o lugar depende dos resultados",
						"Aumenta a pressão: +2 materiais, -2 felicidade.",
						{"material": 2.0, "happiness": -2.0},
						"%s não protesta. Apenas pergunta se a mesma medida será usada para todos." % founder_name
					)
				]
			}
		"convictions":
			return {
				"id": "founder_memory_convictions_opening",
				"title": "PEDRA, MADEIRA E PRINCÍPIOS",
				"description": (
					"%s discorda da direção que uma próxima obra pode impor à vila. Não é "
					+ "uma recusa ao crescimento, mas uma dúvida sobre o que ficará normal "
					+ "depois da construção. %s\n\nA decisão futura poderá transformar a "
					+ "discordância em confiança ou ressentimento."
				) % [founder_name, situation],
				"choices": [
					_choice(
						"convictions_principle", "Prometer preservar o princípio",
						"Prioriza coerência. Ganha 1 de felicidade.",
						{"happiness": 1.0},
						"%s diz que guardará a promessa, sobretudo quando cumprir for inconveniente." % founder_name
					),
					_choice(
						"convictions_compromise", "Buscar um compromisso na obra",
						"Reserva 2 materiais para adaptações.",
						{"material": -2.0},
						"%s aceita negociar, desde que o compromisso apareça na vila e não apenas no discurso." % founder_name
					),
					_choice(
						"convictions_need", "Priorizar a necessidade da vila",
						"Ganha 2 materiais, perde 2 de felicidade.",
						{"material": 2.0, "happiness": -2.0},
						"%s reconhece a urgência, mas avisa que necessidades repetidas também viram valores permanentes." % founder_name
					)
				]
			}
	return {}


static func _build_consequence_event(
	chain_id: String,
	context: Dictionary,
	opening_choice_id: String
) -> Dictionary:
	var founder_name: String = String(context.get("founder_name", "Conselheiro"))
	var observer_text: String = String(context.get("observer_text", ""))
	var condition_text: String = String(context.get("condition_text", "A vila mudou."))
	var remembered_choice: String = _opening_choice_summary(opening_choice_id)

	match chain_id:
		"recognition":
			return {
				"id": "founder_memory_recognition_consequence",
				"title": "QUANDO O MÉRITO VOLTA À MESA",
				"description": (
					"%s voltou ao assunto depois de novos dias de trabalho: %s A decisão "
					+ "anterior — %s — agora pode se tornar prática, correção ou apenas uma "
					+ "lembrança amarga.%s"
				) % [founder_name, condition_text, remembered_choice, observer_text],
				"choices": [
					_choice_with_marker(
						"recognition_leave_mark", "Registrar o mérito na praça",
						"Consome 4 materiais e ganha 8 de felicidade. Deixa um estandarte de memória na vila.",
						{"material": -4.0, "happiness": 8.0},
						"%s vê o próprio trabalho nomeado diante da comunidade e diz que agora a lembrança pertence à vila inteira." % founder_name,
						"founder_banner"
					),
					_choice(
						"recognition_share_reward", "Dividir uma recompensa prática",
						"Transforma o resultado em reservas: +6 alimentos e +2 felicidade.",
						{"food": 6.0, "happiness": 2.0},
						"%s prefere que o reconhecimento chegue à mesa de quem sustentou o trabalho." % founder_name
					),
					_choice(
						"recognition_admit_delay", "Admitir que demorou para reconhecer",
						"Uma reparação direta. Ganha 4 de felicidade.",
						{"happiness": 4.0},
						"%s aceita a franqueza e responde que uma lembrança corrigida ainda vale mais que um elogio automático." % founder_name
					)
				]
			}
		"responsibility":
			return {
				"id": "founder_memory_responsibility_consequence",
				"title": "A PRESSÃO ENCONTRA O PLANO",
				"description": (
					"A pressão finalmente chegou: %s %s lembra que você decidiu %s. O "
					+ "problema é sério, mas ainda pode ser reparado sem condenar a campanha.%s"
				) % [condition_text, founder_name, remembered_choice, observer_text],
				"choices": [
					_choice_with_marker(
						"responsibility_repair_mark", "Reparar e preservar a lição",
						"Consome 5 materiais e ganha 6 de felicidade. Deixa um marco de reparação na vila.",
						{"material": -5.0, "happiness": 6.0},
						"%s coordena o reparo e empilha as primeiras pedras como lembrança de que assumir um erro também constrói confiança." % founder_name,
						"repair_cairn"
					),
					_choice(
						"responsibility_back_plan", "Sustentar o plano até o fim",
						"Perde 4 alimentos e ganha 7 de felicidade.",
						{"food": -4.0, "happiness": 7.0},
						"%s recebe recursos e autonomia suficientes para estabilizar a situação sem esconder o custo." % founder_name
					),
					_choice(
						"responsibility_demand_result", "Cobrar reposição imediata",
						"Recupera 6 materiais, mas perde 5 de felicidade.",
						{"material": 6.0, "happiness": -5.0},
						"%s recompõe parte das perdas, mas a vila percebe que a responsabilidade foi tratada como culpa." % founder_name
					)
				]
			}
		"belonging":
			return {
				"id": "founder_memory_belonging_consequence",
				"title": "QUEM CONTINUA À MESA",
				"description": (
					"A composição do Conselho mudou desde a conversa. %s %s recorda que "
					+ "você decidiu %s e pergunta como essa resposta funciona agora.%s"
				) % [condition_text, founder_name, remembered_choice, observer_text],
				"choices": [
					_choice_with_marker(
						"belonging_shared_place", "Criar um lugar compartilhado",
						"Consome 5 materiais e ganha 8 de felicidade. Deixa um banco comunitário na vila.",
						{"material": -5.0, "happiness": 8.0},
						"%s ajuda a erguer um banco onde fundadores e recém-chegados passam a conversar sem posições marcadas." % founder_name,
						"shared_bench"
					),
					_choice(
						"belonging_define_role", "Definir uma responsabilidade própria",
						"Ganha 4 materiais e 2 de felicidade.",
						{"material": 4.0, "happiness": 2.0},
						"%s aceita o novo papel porque ele esclarece contribuição sem transformar pertencimento em privilégio." % founder_name
					),
					_choice(
						"belonging_open_choice", "Permitir que escolha onde contribuir",
						"Ganha 5 de felicidade.", {"happiness": 5.0},
						"%s escolhe permanecer disponível para a função em que a vila mais precisar, sem tratar a reserva como abandono." % founder_name
					)
				]
			}
		"convictions":
			return {
				"id": "founder_memory_convictions_consequence",
				"title": "O QUE A OBRA PASSOU A SIGNIFICAR",
				"description": (
					"Uma mudança concreta na vila devolveu a discussão: %s %s lembra que "
					+ "você decidiu %s. A construção resolve uma necessidade, mas também "
					+ "torna visível qual princípio venceu.%s"
				) % [condition_text, founder_name, remembered_choice, observer_text],
				"choices": [
					_choice_with_marker(
						"convictions_keep_symbol", "Preservar um símbolo do acordo",
						"Consome 5 materiais e ganha 7 de felicidade. Deixa uma lanterna do Conselho na vila.",
						{"material": -5.0, "happiness": 7.0},
						"%s acende a lanterna e diz que obras mudam, mas compromissos precisam continuar visíveis." % founder_name,
						"council_lantern"
					),
					_choice(
						"convictions_practical_adjustment", "Fazer um ajuste prático",
						"Ganha 6 materiais e perde 3 de felicidade.",
						{"material": 6.0, "happiness": -3.0},
						"%s aceita a eficiência, mas registra no histórico o princípio que foi deixado de lado." % founder_name
					),
					_choice(
						"convictions_community_voice", "Ouvir a comunidade antes de concluir",
						"Consome 4 alimentos e ganha 6 de felicidade.",
						{"food": -4.0, "happiness": 6.0},
						"%s vê a decisão distribuída entre moradores e reconhece que convicções também podem ser compartilhadas." % founder_name
					)
				]
			}
	return {}


static func _choice(
	choice_id: String,
	title: String,
	description: String,
	effects: Dictionary,
	result_text: String
) -> Dictionary:
	return {
		"id": choice_id,
		"title": title,
		"description": description,
		"effects": effects.duplicate(true),
		"result_text": result_text
	}


static func _choice_with_marker(
	choice_id: String,
	title: String,
	description: String,
	effects: Dictionary,
	result_text: String,
	marker_id: String
) -> Dictionary:
	var choice: Dictionary = _choice(choice_id, title, description, effects, result_text)
	choice["memory_marker_id"] = marker_id
	return choice


static func _situation_text(context: Dictionary) -> String:
	return (
		"É %s. %s %s"
		% [
			String(context.get("season_context", "uma estação de mudanças")),
			String(context.get("building_context", "A vila continua em transformação.")),
			String(context.get("council_context", "O Conselho observa em silêncio."))
		]
	)


static func _opening_choice_summary(choice_id: String) -> String:
	match choice_id:
		"recognition_public": return "tornar o mérito público"
		"recognition_private": return "agradecer em particular"
		"recognition_results": return "pedir mais resultados primeiro"
		"responsibility_trust": return "confiar no plano"
		"responsibility_safeguards": return "exigir salvaguardas"
		"responsibility_control": return "manter controle direto"
		"belonging_affirm": return "afirmar que o lugar do fundador permanecia"
		"belonging_adapt": return "dizer que todos precisavam se adaptar"
		"belonging_earn": return "vincular o lugar aos resultados"
		"convictions_principle": return "preservar o princípio"
		"convictions_compromise": return "buscar um compromisso"
		"convictions_need": return "priorizar a necessidade imediata"
		_: return "responder sem prometer um resultado"
