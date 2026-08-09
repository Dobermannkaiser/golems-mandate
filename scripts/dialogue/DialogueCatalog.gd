class_name VillageDialogueCatalog
extends RefCounted


const PERSONALITY_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncillorPersonalityCatalog.gd"
)
const BUILDING_VARIANT_DIALOGUE_CATALOG_SCRIPT = preload(
	"res://scripts/dialogue/BuildingVariantDialogueCatalog.gd"
)


static func create_for_villager(_villager: Villager) -> Dictionary:
	# Conversas decorativas foram removidas na v3.3.1. Uma carta só abre
	# diálogo quando existe uma oportunidade mecânica persistida.
	return {}


static func create_diagnostic_conversation() -> Dictionary:
	return {
		"id": "diagnostic_dialogue",
		"title": "Teste do Oráculo de Interface",
		"start": "start",
		"nodes": {
			"start": {
				"speaker_id": "mimo",
				"speaker_name": "Mimo",
				"expression": "surprised",
				"text": (
					"Teste mágico iniciado! Se você consegue ler isto, "
					+ "a caixa de diálogo não virou um sapo. Ainda."
				),
				"choices": [
					{
						"id": "continue",
						"text": "Continue o teste, Mimo.",
						"next": "finish"
					},
					{
						"id": "stop",
						"text": "Já vi o bastante.",
						"next": "finish_short"
					}
				]
			},
			"finish": {
				"speaker_id": "mimo",
				"speaker_name": "Mimo",
				"expression": "happy",
				"text": (
					"O cristal guardou nossa conversa, minha imagem não virou fumaça "
					+ "e o feitiço respondeu sem explodir. Eu chamaria isso de sucesso!"
				)
			},
			"finish_short": {
				"speaker_id": "mimo",
				"speaker_name": "Mimo",
				"expression": "neutral",
				"text": "Entendido. Vou desligar o feitiço antes que ele cobre aluguel."
			}
		}
	}


static func create_story_conversation(
	dialogue_id: String
) -> Dictionary:
	if dialogue_id.begins_with("building_variant_"):
		return BUILDING_VARIANT_DIALOGUE_CATALOG_SCRIPT.create(dialogue_id)
	match dialogue_id:
		"prologue_reincarnation":
			return _create_prologue_conversation()
		"chapter_15_intro":
			return _create_chapter_intro_15()
		"chapter_30_intro":
			return _create_chapter_intro_30()
		"chapter_45_intro":
			return _create_chapter_intro_45()
		"chapter_60_intro":
			return _create_chapter_intro_60()
		"chapter_75_intro":
			return _create_chapter_intro_75()
		"chapter_90_intro":
			return _create_chapter_intro_90()
		"chapter_105_intro":
			return _create_chapter_intro_105()
		"chapter_120_intro":
			return _create_chapter_intro_120()

	if dialogue_id.begins_with("chapter_15_outro_"):
		return _create_chapter_outro_15(
			dialogue_id.trim_prefix("chapter_15_outro_")
		)
	if dialogue_id.begins_with("chapter_30_outro_"):
		return _create_chapter_outro_30(
			dialogue_id.trim_prefix("chapter_30_outro_")
		)
	if dialogue_id.begins_with("chapter_45_outro_"):
		return _create_chapter_outro_45(
			dialogue_id.trim_prefix("chapter_45_outro_")
		)
	if dialogue_id.begins_with("chapter_60_outro_"):
		return _create_chapter_outro_60(
			dialogue_id.trim_prefix("chapter_60_outro_")
		)
	if dialogue_id.begins_with("chapter_75_outro_"):
		return _create_chapter_outro_75(
			dialogue_id.trim_prefix("chapter_75_outro_")
		)
	if dialogue_id.begins_with("chapter_90_outro_"):
		return _create_chapter_outro_90(
			dialogue_id.trim_prefix("chapter_90_outro_")
		)
	if dialogue_id.begins_with("chapter_105_outro_"):
		return _create_chapter_outro_105(
			dialogue_id.trim_prefix("chapter_105_outro_")
		)
	if dialogue_id.begins_with("chapter_120_outro_"):
		return _create_chapter_outro_120(
			dialogue_id.trim_prefix("chapter_120_outro_")
		)

	return {}


static func get_story_dialogue_ids() -> Array[String]:
	var result: Array[String] = [
		"prologue_reincarnation",
		"chapter_15_intro",
		"chapter_30_intro",
		"chapter_45_intro",
		"chapter_60_intro",
		"chapter_75_intro",
		"chapter_90_intro",
		"chapter_105_intro",
		"chapter_120_intro"
	]
	for day: int in [15, 30, 45, 60, 75, 90]:
		for variant: String in ["safe", "special", "risky"]:
			result.append("chapter_%d_outro_%s" % [day, variant])
	for variant: String in ["safe", "special", "romance", "risky"]:
		result.append("chapter_105_outro_%s" % variant)
	for variant: String in ["people", "work", "special"]:
		result.append("chapter_120_outro_%s" % variant)
	result.append_array(
		BUILDING_VARIANT_DIALOGUE_CATALOG_SCRIPT.get_dialogue_ids()
	)
	return result


static func _create_prologue_conversation() -> Dictionary:
	return {
		"id": "prologue_reincarnation",
		"title": "Prólogo — Uma Prefeitura Depois da Vida",
		"start": "wake",
		"allow_close": false,
		"nodes": {
			"wake": {
				"speaker_id": "",
				"speaker_name": "Narrador",
				"hide_portrait": true,
				"text": (
					"Sua última lembrança do mundo antigo envolve chuva, "
					+ "uma faixa de pedestres e um caminhão com a placa: "
					+ "TRANSPORTES ISEKAI — ENTREGAS EM OUTROS MUNDOS."
				),
				"next": "office"
			},
			"office": {
				"speaker_id": "deusa_auditoria",
				"speaker_name": "Sanctuary-Void",
				"text": (
					"Bem-vindo ao Departamento Celestial de Reencarnações, "
					+ "Ressarcimentos e Pequenos Desastres Administrativos. "
					+ "Eu sou Sanctuary-Void. Antes de tudo: desculpe."
				),
				"choices": [
					{
						"id": "ask_dead",
						"text": "Eu morri?",
						"next": "dead_answer"
					},
					{
						"id": "ask_sorry",
						"text": "Por que uma deusa começou pedindo desculpas?",
						"next": "mistake_answer"
					}
				]
			},
			"dead_answer": {
				"speaker_id": "deusa_auditoria",
				"speaker_name": "Sanctuary-Void",
				"text": (
					"Tecnicamente, sim. Em minha defesa, o caminhão estava "
					+ "devidamente licenciado para acidentes narrativamente convenientes."
				),
				"next": "form_error"
			},
			"mistake_answer": {
				"speaker_id": "deusa_auditoria",
				"speaker_name": "Sanctuary-Void",
				"text": (
					"Porque seu formulário de nova espécie foi preenchido com tinta "
					+ "profética e eu espirrei exatamente sobre a opção escolhida."
				),
				"next": "form_error"
			},
			"form_error": {
				"speaker_id": "deusa_auditoria",
				"speaker_name": "Sanctuary-Void",
				"text": (
					"Você deveria renascer como um herói de linhagem lendária. "
					+ "O sistema registrou: Golem de Pedregulho, qualidade municipal."
				),
				"choices": [
					{
						"id": "complain",
						"text": "Isso não parece uma compensação justa.",
						"next": "gift"
					},
					{
						"id": "accept_rock",
						"text": "Pedregulhos são resistentes. Eu acho.",
						"next": "gift"
					}
				]
			},
			"gift": {
				"speaker_id": "deusa_auditoria",
				"speaker_name": "Sanctuary-Void",
				"text": (
					"Como reparação, concedo a habilidade PREFEITO PERFEITO. "
					+ "Ela prevê custos, riscos e consequências. Não faz milagres, "
					+ "mas organiza planilhas com brilho dourado."
				),
				"next": "arrival"
			},
			"arrival": {
				"speaker_id": "",
				"speaker_name": "Narrador",
				"hide_portrait": true,
				"text": (
					"Uma luz celestial o deixa cair no centro de uma vila esquecida. "
					+ "Duas casas tortas, caminhos de barro e pequenos felinos bípedes "
					+ "encaram o novo golem com curiosidade."
				),
				"next": "mimo_intro"
			},
			"mimo_intro": {
				"speaker_id": "mimo",
				"speaker_name": "Mimo",
				"text": (
					"Oi! Você caiu do céu, então deve ser importante. Eu sou Mimo. "
					+ "Nós somos Passos-Leves! O nome vem do fato de pisarmos leve. "
					+ "Exceto quando carregamos panela."
				),
				"next": "village_problem"
			},
			"village_problem": {
				"speaker_id": "mimo",
				"speaker_name": "Mimo",
				"text": (
					"Nossa vila está sem prefeito, quase sem comida e com uma placa "
					+ "amaldiçoada dizendo 'em reforma' há quarenta e sete anos. "
					+ "Você gostaria do cargo? Já fizemos uma eleição. Você ganhou por cinco a zero."
				),
				"choices": [
					{
						"id": "accept_mayor",
						"text": "Aceito ser Prefeito.",
						"next": "audit_warning"
					},
					{
						"id": "ask_election",
						"text": "Como fui candidato se acabei de chegar?",
						"next": "election_answer"
					}
				]
			},
			"election_answer": {
				"speaker_id": "mimo",
				"speaker_name": "Mimo",
				"text": (
					"Escrevemos 'o próximo ser que cair do céu'. Foi uma campanha muito objetiva. "
					+ "Também não apareceu nenhum outro ser, então você venceu sem segundo turno!"
				),
				"next": "audit_warning"
			},
			"audit_warning": {
				"speaker_id": "deusa_auditoria",
				"speaker_name": "Sanctuary-Void",
				"text": (
					"Há uma condição. A vila passará por avaliações a cada vinte dias. "
					+ "Você terá cento e vinte dias para provar que esta comunidade pode sobreviver. "
					+ "Falhar em uma auditoria encerra sua administração."
				),
				"next": "mimo_end"
			},
			"mimo_end": {
				"speaker_id": "mimo",
				"speaker_name": "Mimo",
				"text": (
					"Ótimo! Eu sabia que escolher uma pedra mágica para organizar a vila daria certo. "
					+ "Vamos começar antes que a despensa perceba que está vazia!"
				)
			}
		}
	}


static func _create_chapter_intro_15() -> Dictionary:
	return _linear_story_conversation(
		"chapter_15_intro",
		"Capítulo I — A Forja das Brasas Claras",
		[
			_story_node("mimo", "Mimo", "Prefeito! Um elfo enorme apareceu carregando uma bigorna. Eu ofereci ajuda, mas a bigorna me ofereceu dor nas costas."),
			_story_node("aelric_ferreiro", "Aelric Brasa-Clara", "Aelric Brasa-Clara. Mestre ferreiro, runista e atual proprietário de uma oficina destruída. Preciso de abrigo para minha forja antes que a chama presa na bigorna consuma o que resta dela."),
			_story_node("aelric_ferreiro", "Aelric Brasa-Clara", "Mostre-me como esta vila administra seus recursos, Prefeito. Uma forja revela o caráter de uma comunidade tão bem quanto revela impurezas no metal.")
		]
	)


static func _create_chapter_intro_30() -> Dictionary:
	return _linear_story_conversation(
		"chapter_30_intro",
		"Capítulo II — O Contrato de Cobre-Fino",
		[
			_story_node("kobi_mercante", "Kobi Cobre-Fino", "Saudações, investidores comunitários! Trago especiarias, mapas e um contrato absolutamente incapaz de criar dentes. Na maior parte do tempo."),
			_story_node("mimo", "Mimo", "O pergaminho tentou morder meu dedo, Prefeito. Acho que ele gostou de mim."),
			_story_node("kobi_mercante", "Kobi Cobre-Fino", "Uma rota comercial pode transformar esta vila. Basta escolhermos termos que deixem felizes vocês, eu e a pequena fada contadora que mora no tinteiro.")
		]
	)


static func _create_chapter_intro_45() -> Dictionary:
	return _linear_story_conversation(
		"chapter_45_intro",
		"Capítulo III — A Fissura que Sonhava",
		[
			_story_node("orion_draconato", "Orion Escamagelo", "Não pisem na rachadura luminosa. Ela está sonhando e, estatisticamente, sonhos geológicos raramente respeitam limites de propriedade."),
			_story_node("mimo", "Mimo", "Eu só encostei a orelha uma vez. Ela disse que eu seria rainha das colheres. Pareceu confiável."),
			_story_node("orion_draconato", "Orion Escamagelo", "Sou Orion Escamagelo, pesquisador arcano. Com sua autorização, estudarei a fenda. Com uma boa decisão, talvez ela ajude a vila em vez de engoli-la.")
		]
	)


static func _create_chapter_intro_60() -> Dictionary:
	return _linear_story_conversation(
		"chapter_60_intro",
		"Capítulo IV — O Arquivo sob as Folhas",
		[
			_story_node("deusa_auditoria", "Sanctuary-Void", "Aviso celestial de pré-inverno, formulário 91-B: a produção de comida cairá, o consumo aumentará e pedidos de socorro enviados depois da primeira neve estarão sujeitos a cento e vinte dias úteis. Em termos simples: encham o celeiro agora."),
			_story_node("rubra_meio_demonia", "Rubra Verbum", "Sob aquela árvore existe um arquivo anterior ao próprio reino. Por favor, não abram o livro vermelho. Ele é sensível e morde quando se sente julgado."),
			_story_node("mimo", "Mimo", "Eu disse que gostei da capa. Ele só mordeu um pouquinho, de amizade."),
			_story_node("rubra_meio_demonia", "Rubra Verbum", "Os textos podem proteger a vila ou despertar segredos antigos. A diferença dependerá de como seu Conselho tratar o conhecimento, Prefeito.")
		]
	)


static func _create_chapter_intro_75() -> Dictionary:
	return _linear_story_conversation(
		"chapter_75_intro",
		"Capítulo V — A Caçada da Neve Rúnica",
		[
			_story_node("brunna_ana_barbara", "Brunna Ana", "A criatura que ronda suas casas não é cruel. Uma runa de fúria foi gravada em seu chifre. Ainda assim, se atacar, responderei com extrema delicadeza e um machado."),
			_story_node("mimo", "Mimo", "Ela falou 'delicadeza' enquanto partia uma pedra ao meio. Gosto dela."),
			_story_node("brunna_ana_barbara", "Brunna Ana", "Prepare sua vila. Armadilhas, muralhas ou coragem: cada escolha dirá se vocês merecem sobreviver ao inverno.")
		]
	)


static func _create_chapter_intro_90() -> Dictionary:
	return _linear_story_conversation(
		"chapter_90_intro",
		"Capítulo VI — A Canção depois da Meia-Noite",
		[
			_story_node("meio_vampiro_emo_gotico", "Silas Nocturno", "Eu sou Silas. Vim tocar, não beber o sangue de ninguém. Também trouxe chá, caso a segunda informação pareça mais convincente com uma xícara."),
			_story_node("rubra_meio_demonia", "Rubra Verbum", "Os boatos que chegaram antes dele repetem uma acusação antiga sem apresentar prova. Conheço bem esse tipo de texto."),
			_story_node("meio_vampiro_emo_gotico", "Silas Nocturno", "Não espero confiança gratuita, Prefeito. Só uma decisão que veja o que fiz, em vez do monstro que alguém decidiu escrever.")
		]
	)


static func _create_chapter_intro_105() -> Dictionary:
	return _linear_story_conversation(
		"chapter_105_intro",
		"Capítulo VII — A Horta que Batia à Porta",
		[
			_story_node("bruxinha_ruiva", "Dália Folhaverde", "Olá! Sou Dália. A horta atrás de mim decidiu parar aqui. Ela costuma ser sensata, embora tenha péssimo respeito por cercas."),
			_story_node("mimo", "Mimo", "Uma abóbora bateu na porta e pediu cidadania. Eu disse que precisava falar com o Prefeito."),
			_story_node("bruxinha_ruiva", "Dália Folhaverde", "As raízes podem alimentar a vila, mas não quero que escolham por cima das pessoas. Preciso de um acordo que deixe espaço para todo mundo crescer.")
		]
	)


static func _create_chapter_intro_120() -> Dictionary:
	return _linear_story_conversation(
		"chapter_120_intro",
		"Capítulo Final — A Auditoria das Quatro Estações",
		[
			_story_node("deusa_auditoria", "Sanctuary-Void", "Chegamos ao centésimo vigésimo dia. Trouxe a pasta final, três carimbos e um escriba celestial que se recusou a descer por causa do barro."),
			_story_node("mimo", "Mimo", "Eu limpei o barro! Quer dizer, espalhei palha em cima. Agora é barro elegante."),
			_story_node("deusa_auditoria", "Sanctuary-Void", "Antes de verificar as metas, responda: o que transformou esta comunidade esquecida em uma vila digna de continuar existindo?")
		]
	)


static func _create_chapter_outro_15(variant: String) -> Dictionary:
	var line: String = "A forja está acesa. Permanecerei na vila e colocarei minhas mãos a serviço desta comunidade."
	if variant == "special":
		line = "Madeira rúnica, planejamento e nenhuma ferramenta perdida. Confesso que estou impressionado, Prefeito. Não se acostume a ouvir isso."
	elif variant == "risky":
		line = "Foi imprudente... mas corajoso. Ficarei para reparar as ferramentas e talvez ensinar seu Conselho a respeitar uma bigorna."
	return _outro_conversation("chapter_15_outro_%s" % variant, "Aelric Brasa-Clara", "aelric_ferreiro", line)


static func _create_chapter_outro_30(variant: String) -> Dictionary:
	var line: String = "Contrato assinado. A rota Cobre-Fino agora inclui esta vila e apenas sete taxas perfeitamente razoáveis."
	if variant == "special":
		line = "Um mercado público, testemunhas e termos claros! Vocês transformaram honestidade em espetáculo. Isso pode ser muito lucrativo."
	elif variant == "risky":
		line = "A fada do tinteiro ainda está discutindo a pontuação, mas o contrato vale. Ficarei para impedir que ela cobre imposto sobre vírgulas."
	return _outro_conversation("chapter_30_outro_%s" % variant, "Kobi Cobre-Fino", "kobi_mercante", line)


static func _create_chapter_outro_45(variant: String) -> Dictionary:
	var line: String = "A fissura estabilizou. Permanecerei para observá-la e registrar qualquer sonho que tente se tornar clima."
	if variant == "special":
		line = "Vocês transformaram uma anomalia em fonte de mana. Cientificamente brilhante. Administrativamente, surpreendente."
	elif variant == "risky":
		line = "O mapa dos sonhos é valioso, mesmo com as margens tentando sussurrar. Vou ficar até entendermos o que existe sob a vila."
	return _outro_conversation("chapter_45_outro_%s" % variant, "Orion Escamagelo", "orion_draconato", line)


static func _create_chapter_outro_60(variant: String) -> Dictionary:
	var line: String = "O arquivo está protegido. Ficarei como sua guardiã e ensinarei os livros a pedir licença antes de morder."
	if variant == "special":
		line = "Registrar grimórios como cidadãos foi uma solução absurdamente elegante. Eles já exigiram carteiras de biblioteca e férias."
	elif variant == "risky":
		line = "O verdadeiro nome da vila reagiu a vocês. Permanecerei para descobrir se isso foi uma bênção ou uma advertência."
	return _outro_conversation("chapter_60_outro_%s" % variant, "Rubra Verbum", "rubra_meio_demonia", line)


static func _create_chapter_outro_75(variant: String) -> Dictionary:
	var line: String = "As casas estão seguras e a besta não precisa morrer. Ficarei para proteger as trilhas durante o restante do inverno."
	if variant == "special":
		line = "Sua muralha virou parte da caçada sem transformar a criatura em inimiga. Há força em saber quando não golpear."
	elif variant == "risky":
		line = "Enfrentar a fera de frente foi insensato, heroico e eficiente o bastante. Considero isso uma apresentação adequada."
	return _outro_conversation("chapter_75_outro_%s" % variant, "Brunna Ana", "brunna_ana_barbara", line)


static func _create_chapter_outro_90(variant: String) -> Dictionary:
	var line: String = "A apresentação terminou sem máscaras. Se houver espaço, fico para as próximas vigílias — e talvez para alguns refrões durante o dia."
	if variant == "special":
		line = "Rubra encontrou o documento que os boatos apagaram. Obrigado por me deixarem existir sem transformar toda conversa num julgamento."
	elif variant == "risky":
		line = "A investigação não foi perfeita, mas ninguém usou a dúvida como desculpa para crueldade. Já encontrei lugares piores para chamar de lar."
	return _outro_conversation("chapter_90_outro_%s" % variant, "Silas Nocturno", "meio_vampiro_emo_gotico", line)


static func _create_chapter_outro_105(variant: String) -> Dictionary:
	var line: String = "Os canteiros têm espaço para raízes, famílias e mudanças de ideia. A horta fica — e eu também."
	if variant == "special":
		line = "As runas de Aelric perguntam antes de mover a água. É a primeira irrigação educada que conheço. Quero ajudar esta vila a crescer."
	elif variant == "romance":
		line = "O ritual respondeu a um compromisso que já existia, sem dizer que só ele cria raízes. É exatamente a magia que eu queria cultivar aqui."
	elif variant == "risky":
		line = "Algumas sementes ficaram de cabeça para baixo, mas nenhuma comunidade nasce sabendo cultivar junta. Ficarei para a próxima tentativa."
	return _outro_conversation("chapter_105_outro_%s" % variant, "Dália Folhaverde", "bruxinha_ruiva", line)


static func _create_chapter_outro_120(variant: String) -> Dictionary:
	var line: String = "Uma comunidade é mais do que suas reservas. Registrarei sua resposta antes que o formulário discorde."
	if variant == "work":
		line = "Cada construção guarda trabalho, medo e esperança. Isso não aparece na contabilidade celestial, mas deveria."
	elif variant == "special":
		line = "Vocês reuniram pessoas que jamais deveriam caber na mesma planilha — e fizeram delas uma família. Esta é uma irregularidade que pretendo aprovar."
	return _outro_conversation("chapter_120_outro_%s" % variant, "Sanctuary-Void", "deusa_auditoria", line)


static func _linear_story_conversation(
	conversation_id: String,
	title: String,
	story_nodes: Array[Dictionary]
) -> Dictionary:
	var nodes: Dictionary = {}
	for index: int in range(story_nodes.size()):
		var node_id: String = "line_%02d" % (index + 1)
		var node: Dictionary = story_nodes[index].duplicate(true)
		if index + 1 < story_nodes.size():
			node["next"] = "line_%02d" % (index + 2)
		nodes[node_id] = node
	return {
		"id": conversation_id,
		"title": title,
		"start": "line_01",
		"allow_close": false,
		"nodes": nodes
	}


static func _story_node(
	speaker_id: String,
	speaker_name: String,
	text: String
) -> Dictionary:
	return {
		"speaker_id": speaker_id,
		"speaker_name": speaker_name,
		"expression": "neutral",
		"text": text
	}


static func _outro_conversation(
	conversation_id: String,
	speaker_name: String,
	speaker_id: String,
	text: String
) -> Dictionary:
	return {
		"id": conversation_id,
		"title": "Consequências do Capítulo",
		"start": "result",
		"allow_close": false,
		"nodes": {
			"result": {
				"speaker_id": speaker_id,
				"speaker_name": speaker_name,
				"expression": "neutral",
				"text": text,
				"next": "mimo"
			},
			"mimo": {
				"speaker_id": "mimo",
				"speaker_name": "Mimo",
				"expression": "neutral",
				"text": (
					"Mais uma pessoa resolveu ficar! Nossa vila está virando um lugar "
					+ "onde criaturas estranhas chegam e depois não querem ir embora. "
					+ "Isso é progresso, eu acho."
				)
			}
		}
	}


static func validate_conversation(conversation: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var conversation_id: String = String(conversation.get("id", ""))
	var start_id: String = String(conversation.get("start", ""))
	var nodes_value: Variant = conversation.get("nodes", null)

	if conversation_id.is_empty():
		errors.append("Conversa sem ID.")

	if start_id.is_empty():
		errors.append("%s: nó inicial ausente." % conversation_id)

	if not nodes_value is Dictionary:
		errors.append("%s: lista de nós inválida." % conversation_id)
		return errors

	var nodes: Dictionary = nodes_value as Dictionary

	if not nodes.has(start_id):
		errors.append("%s: o nó inicial não existe." % conversation_id)

	for node_id_value: Variant in nodes.keys():
		var node_id: String = String(node_id_value)
		var node_value: Variant = nodes[node_id_value]

		if not node_value is Dictionary:
			errors.append("%s/%s: nó inválido." % [conversation_id, node_id])
			continue

		var node: Dictionary = node_value as Dictionary
		var text: String = String(node.get("text", "")).strip_edges()

		if text.is_empty():
			errors.append("%s/%s: fala vazia." % [conversation_id, node_id])

		var next_id: String = String(node.get("next", "")).strip_edges()
		if not next_id.is_empty() and not nodes.has(next_id):
			errors.append(
				"%s/%s: próximo nó inexistente: %s."
				% [conversation_id, node_id, next_id]
			)

		var choices_value: Variant = node.get("choices", [])
		if not choices_value is Array:
			errors.append("%s/%s: escolhas inválidas." % [conversation_id, node_id])
			continue

		var choice_ids: Dictionary = {}
		for choice_value: Variant in choices_value:
			if not choice_value is Dictionary:
				errors.append("%s/%s: escolha inválida." % [conversation_id, node_id])
				continue

			var choice: Dictionary = choice_value as Dictionary
			var choice_id: String = String(choice.get("id", "")).strip_edges()
			var choice_next: String = String(choice.get("next", "")).strip_edges()

			if choice_id.is_empty():
				errors.append("%s/%s: escolha sem ID." % [conversation_id, node_id])
			elif choice_ids.has(choice_id):
				errors.append("%s/%s: escolha duplicada %s." % [conversation_id, node_id, choice_id])
			else:
				choice_ids[choice_id] = true

			if choice_next.is_empty() or not nodes.has(choice_next):
				errors.append(
					"%s/%s/%s: destino inexistente."
					% [conversation_id, node_id, choice_id]
				)

	return errors


static func _create_mimo_conversation(villager: Villager) -> Dictionary:
	var profession_name: String = Villager.get_profession_name(
		villager.current_profession
	)

	return {
		"id": "mimo_daily_demo",
		"title": "Conversa com Mimo",
		"start": "mimo_intro",
		"nodes": {
			"mimo_intro": {
				"speaker_id": "mimo",
				"speaker_name": "Mimo",
				"expression": "happy",
				"text": (
					"Prefeito! Encontrei um sapo usando chapéu de mago perto do poço. "
					+ "Ele me chamou de jovem aprendiz... ou de jovem aperitivo. "
					+ "A dicção dele era muito úmida."
				),
				"choices": [
					{
						"id": "ask_spell",
						"text": "Ele lançou algum feitiço?",
						"next": "mimo_spell"
					},
					{
						"id": "ask_food",
						"text": "Você tentou alimentá-lo?",
						"next": "mimo_food"
					},
					{
						"id": "praise",
						"text": "Bom trabalho em me avisar.",
						"next": "mimo_praise"
					}
				]
			},
			"mimo_spell": {
				"speaker_id": "mimo",
				"speaker_name": "Mimo",
				"expression": "surprised",
				"text": (
					"Só um pequenininho. Agora três pedras do caminho dizem 'bom dia'. "
					+ "Eu respondi para não parecer mal-educada."
				),
				"next": "mimo_end"
			},
			"mimo_food": {
				"speaker_id": "mimo",
				"speaker_name": "Mimo",
				"expression": "neutral",
				"text": (
					"Sim! Dei uma mosca. Era minha mosca de estimação por quase quatro segundos, "
					+ "mas a diplomacia exige sacrifícios."
				),
				"next": "mimo_end"
			},
			"mimo_praise": {
				"speaker_id": "mimo",
				"speaker_name": "Mimo",
				"expression": "happy",
				"text": (
					"Eu sabia! Meu cérebro fez aquele barulho de ideia. "
					+ "Também pode ter sido fome, mas prefiro a primeira opção."
				),
				"next": "mimo_end"
			},
			"mimo_end": {
				"speaker_id": "mimo",
				"speaker_name": "Mimo",
				"expression": "happy",
				"text": (
					"Vou continuar trabalhando como %s. Se o sapo voltar, "
					+ "prometo não aceitar nenhum contrato escrito em língua de mosca."
				) % profession_name
			}
		}
	}


static func _create_founder_conversation(villager: Villager) -> Dictionary:
	var season_id: String = String(
		GameManager.get_current_season().get("id", "spring")
	)
	if season_id in ["autumn", "winter"]:
		return _create_founder_winter_conversation(villager)

	var portrait_id: String = villager.portrait_id
	var role_line: String = _get_role_line(portrait_id)
	var magic_problem: String = _get_magic_problem(portrait_id)
	var personality_intro: String = PERSONALITY_CATALOG_SCRIPT.get_dialogue_line(
		villager.personality_id,
		"intro"
	)
	var practical_answer: String = PERSONALITY_CATALOG_SCRIPT.get_dialogue_line(
		villager.personality_id,
		"practical"
	)
	var curious_answer: String = PERSONALITY_CATALOG_SCRIPT.get_dialogue_line(
		villager.personality_id,
		"curious"
	)
	var cautious_answer: String = PERSONALITY_CATALOG_SCRIPT.get_dialogue_line(
		villager.personality_id,
		"cautious"
	)
	var name: String = villager.villager_name

	return {
		"id": "founder_%s_demo" % villager.representative_id,
		"title": "Conversa com %s" % name,
		"start": "intro",
		"nodes": {
			"intro": {
				"speaker_id": portrait_id,
				"speaker_name": name,
				"expression": "neutral",
				"text": "%s %s\n\n%s" % [role_line, magic_problem, personality_intro],
				"choices": [
					{
						"id": "practical",
						"text": "Resolva de forma segura e registre o resultado.",
						"next": "practical"
					},
					{
						"id": "curious",
						"text": "Investigue. Talvez isso ajude a vila.",
						"next": "curious"
					},
					{
						"id": "cautious",
						"text": "Mantenha distância até sabermos mais.",
						"next": "cautious"
					}
				]
			},
			"practical": {
				"speaker_id": portrait_id,
				"speaker_name": name,
				"expression": "neutral",
				"text": practical_answer
			},
			"curious": {
				"speaker_id": portrait_id,
				"speaker_name": name,
				"expression": "happy",
				"text": curious_answer
			},
			"cautious": {
				"speaker_id": portrait_id,
				"speaker_name": name,
				"expression": "neutral",
				"text": cautious_answer
			}
		}
	}


static func _create_founder_winter_conversation(villager: Villager) -> Dictionary:
	var portrait_id: String = villager.portrait_id
	var name: String = villager.villager_name
	var warning: String = _get_representative_winter_warning(villager)
	var personality_warning: String = PERSONALITY_CATALOG_SCRIPT.get_dialogue_line(
		villager.personality_id,
		"winter"
	)
	var prepare_reply: String = PERSONALITY_CATALOG_SCRIPT.get_dialogue_line(
		villager.personality_id,
		"prepare"
	)
	var watch_reply: String = PERSONALITY_CATALOG_SCRIPT.get_dialogue_line(
		villager.personality_id,
		"watch"
	)
	var ignore_reply: String = PERSONALITY_CATALOG_SCRIPT.get_dialogue_line(
		villager.personality_id,
		"ignore"
	)
	var choices: Array[Dictionary] = [
		{
			"id": "prepare",
			"text": "Você tem razão. Vamos encher o celeiro antes da neve.",
			"next": "prepare_reply"
		},
		{
			"id": "watch",
			"text": "Vamos observar a previsão por mais alguns dias.",
			"next": "watch_reply"
		},
		{
			"id": "ignore",
			"text": "O inverno não deve ser tão ruim assim.",
			"next": "ignore_reply"
		}
	]
	var dialogue_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	dialogue_rng.seed = VillageCampaignIdentityCatalog.seed_from_text(
		"%d|founder_winter|%s|%d" % [
			int(GameManager.get_campaign_identity().get("campaign_seed", 1)),
			villager.representative_id,
			int(GameManager.get_campaign_progress().get("current_day", 1))
		]
	)
	for index: int in range(choices.size() - 1, 0, -1):
		var swap_index: int = dialogue_rng.randi_range(0, index)
		var temporary: Dictionary = choices[index]
		choices[index] = choices[swap_index]
		choices[swap_index] = temporary
	return {
		"id": "founder_%s_winter_warning" % villager.representative_id,
		"title": "Preparação para o Inverno",
		"start": "intro",
		"nodes": {
			"intro": {
				"speaker_id": portrait_id,
				"speaker_name": name,
				"expression": "neutral",
				"text": "%s\n\n%s" % [warning, personality_warning],
				"choices": choices
			},
			"prepare_reply": {
				"speaker_id": portrait_id,
				"speaker_name": name,
				"expression": "happy",
				"text": prepare_reply
			},
			"watch_reply": {
				"speaker_id": portrait_id,
				"speaker_name": name,
				"expression": "neutral",
				"text": watch_reply
			},
			"ignore_reply": {
				"speaker_id": portrait_id,
				"speaker_name": name,
				"expression": "neutral",
				"text": ignore_reply
			}
		}
	}


static func _get_representative_winter_warning(villager: Villager) -> String:
	var profession_name: String = Villager.get_profession_name(
		villager.current_profession
	)
	var passive_context: String = (
		" Meu jeito %s pode ajudar, mas não substitui um celeiro cheio."
		% villager.passive_name.to_lower()
		if not villager.passive_name.is_empty() and villager.passive_name != "Sem passiva"
		else ""
	)
	var line: String = "O inverno reduz a colheita e aumenta o consumo. Precisamos estocar alimentação durante o outono."
	match villager.current_profession:
		Villager.Profession.FARMER:
			line = "As plantações já estão desacelerando. Como agricultor, prefiro encher o celeiro agora a contar sementes quando a neve chegar."
		Villager.Profession.BLACKSMITH:
			line = "Metal frio ainda pode ser aquecido; uma despensa vazia não. Como ferreiro, recomendo tratar o estoque de comida como tratamos carvão para a forja."
		Villager.Profession.CIVIL_SERVANT:
			line = "Revisei os registros: no inverno produzimos menos e comemos mais. Como servidor, peço uma prioridade oficial para o estoque de alimentação."
		Villager.Profession.GUARD:
			line = "Posso proteger os portões, mas não consigo enfrentar a fome com uma lança. Precisamos guardar comida antes que a neve feche os caminhos."
		Villager.Profession.GATHERER:
			line = "Frutas, raízes e cogumelos ficam escassos no frio. Como coletor, sei que o outono é nossa última chance de formar uma reserva confortável."
		_:
			line = "Ainda não tenho profissão fixa, mas até eu sei que o inverno cobra comida em dobro. Vamos estocar antes da primeira neve."
	return "%s Trabalho atual: %s.%s" % [line, profession_name, passive_context]


static func _get_role_line(portrait_id: String) -> String:
	match portrait_id:
		"passos_leves_artifice":
			return "Minhas ferramentas começaram a vibrar perto do caminho norte."
		"passos_leves_batedor":
			return "Encontrei pegadas que desaparecem sempre que a lua fica atrás das nuvens."
		"felix_pescador":
			return "Os peixes do lago formaram um círculo e começaram a cantar em coro."
		"lumi_cozinheira":
			return "A sopa de hoje desenhou uma runa perfeita na superfície da panela."
		_:
			return "Os amuletos da estrada tilintaram sem vento nesta manhã."


static func _get_magic_problem(portrait_id: String) -> String:
	match portrait_id:
		"passos_leves_artifice":
			return "Pode ser minério encantado... ou uma colher muito determinada."
		"passos_leves_batedor":
			return "A trilha cheira a pinho, ozônio e magia antiga."
		"felix_pescador":
			return "Um deles usava uma coroa minúscula e exigiu imposto sobre minhocas."
		"lumi_cozinheira":
			return "A runa parece significar 'proteção', embora também possa significar 'mais cebola'."
		_:
			return "Algo feérico talvez esteja observando a vila."


static func _get_practical_answer(portrait_id: String) -> String:
	match portrait_id:
		"felix_pescador":
			return "Vou anotar quantos peixes cantam e quantos apenas fingem para impressionar o rei."
		"lumi_cozinheira":
			return "Vou separar a panela encantada e servir o almoço em outra. Segurança antes de tempero."
		_:
			return "Entendido. Vou cercar a área, observar os sinais e não tocar em nada que sussurre meu nome."


static func _get_curious_answer(portrait_id: String) -> String:
	match portrait_id:
		"passos_leves_artifice":
			return "Excelente. Se for uma colher mágica, finalmente teremos tecnologia de sopa automática."
		"passos_leves_batedor":
			return "Vou seguir a trilha com cuidado. Criaturas feéricas respeitam coragem, mas adoram cobrar juros."
		"felix_pescador":
			return "Negociarei com o rei dos peixes. Levarei minhocas, respeito e um contrato que não borre na água."
		"lumi_cozinheira":
			return "Vou copiar a runa. Talvez possamos encantar o celeiro... ou ao menos melhorar o caldo."
		_:
			return "Vou pesquisar os sinais. Talvez a vila esteja sobre uma antiga estrada de mana."
