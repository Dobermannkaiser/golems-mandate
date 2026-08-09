class_name VillageRelationshipExpansionCatalog
extends RefCounted


const SILAS_ID: String = "meio_vampiro_emo_gotico"
const DALIA_ID: String = "bruxinha_ruiva"


const CHARACTER_DATA: Dictionary = {
	SILAS_ID: {
		"name": "Silas Nocturno",
		"portrait_id": SILAS_ID,
		"winter_warning": "O frio não me incomoda. O silêncio de uma despensa vazia, sim. Guardem comida agora; fome é um refrão que ninguém merece repetir.",
		"season_lines": {
			"spring": "A primavera deixa a vila barulhenta. Pássaros, martelos, gente esperançosa... surpreendentemente, a mistura tem ritmo.",
			"summer": "No verão eu durmo mal durante o dia. Antes que pergunte: cortinas ajudam mais que caixões.",
			"autumn": "O vento de outono afina as cordas sozinho. É útil, embora tenha péssimo gosto musical.",
			"winter": "A noite de inverno é longa o bastante para uma canção inteira e curta demais para deixar alguém vigiando sozinho."
		},
		"partner_lines": {
			"spring": "Compus algo sobre recomeços. Não tem seu nome, mas qualquer pessoa com ouvidos perceberia.",
			"summer": "Você pode ficar aqui até o sol baixar. Não é um convite dramático; só prefiro o silêncio quando você está nele.",
			"autumn": "Guardei o melhor acorde para quando você chegasse. Irritante como isso virou hábito.",
			"winter": "Não preciso do seu calor para sobreviver. Só descobri que gosto dele, o que é bem mais inconveniente."
		},
		"good": ["Sua música diz o que você tenta esconder.", "Você observa a vila porque se importa com ela."],
		"neutral": ["A canção ficou boa.", "A vigília parece tranquila hoje."],
		"bad": ["Você se esforça demais para parecer indiferente.", "Talvez devesse tocar em outro lugar."],
		"good_reply": "Silas olha para o lado, mas a ponta da presa aparece num sorriso breve e sincero.",
		"neutral_reply": "Silas responde com um aceno curto e volta a ajustar as cordas do instrumento.",
		"bad_reply": "Silas guarda o instrumento no estojo. O humor seco desaparece, deixando apenas distância."
	},
	DALIA_ID: {
		"name": "Dália Folhaverde",
		"portrait_id": DALIA_ID,
		"winter_warning": "Raízes dormem no frio, mas pessoas não podem dormir de fome. Vamos secar ervas, guardar sementes e encher o celeiro antes da neve.",
		"season_lines": {
			"spring": "A terra acordou com fome de sementes. Eu entendo; também fico animada quando o café da manhã chega.",
			"summer": "As ervas crescem depressa no calor. Algumas até dão conselho sem serem chamadas. Tento não incentivar.",
			"autumn": "Colher é agradecer à terra sem fazer discurso. Ainda faço o discurso, mas as abóboras são pacientes.",
			"winter": "No inverno, uma horta parece vazia para quem só olha folhas. Debaixo da terra, todo mundo está planejando voltar."
		},
		"partner_lines": {
			"spring": "Plantei duas dálias perto da janela. Uma é por mim. A outra pode adivinhar.",
			"summer": "Trouxe chá gelado e uma manta. Sim, manta no verão. Encontros bons precisam de opções.",
			"autumn": "A melhor parte da colheita é escolher com quem dividir. Trouxe a cesta grande.",
			"winter": "As sementes descansam juntas para atravessar o frio. Acho uma estratégia excelente para nós também."
		},
		"good": ["Você faz cuidado parecer uma coisa prática.", "Quero aprender a ouvir a terra com você."],
		"neutral": ["As plantas estão crescendo bem.", "Precisamos organizar as sementes."],
		"bad": ["Você procura significado onde não existe.", "Cultivar ervas não resolve problemas de verdade."],
		"good_reply": "Dália sorri sem diminuir a própria alegria e oferece um punhado de sementes como se compartilhasse um segredo.",
		"neutral_reply": "Dália concorda e transforma a conversa em uma lista prática de tarefas para a horta.",
		"bad_reply": "Dália fecha a bolsa de ervas. A confiança permanece, mas o convite para compartilhá-la desaparece."
	}
}


const CONVERSATION_TOPICS: Dictionary = {
	SILAS_ID: [
		{
			"id": "silas_primeira_cancao",
			"line": "Uma criança pediu uma canção sobre monstros gentis. Escrevi três versos antes de perceber que talvez ela estivesse falando de mim.",
			"good": "Talvez ela tenha reconhecido que aparência e caráter não são a mesma coisa.",
			"neutral": "Parece um bom tema para uma canção.",
			"bad": "As crianças provavelmente deveriam manter distância.",
			"good_reply": "Silas anota um quarto verso e finge que a ideia já era dele.",
			"neutral_reply": "Silas testa a melodia outra vez, satisfeito com a utilidade da resposta.",
			"bad_reply": "Silas fecha o caderno. A frase encontrou um medo antigo com precisão demais."
		},
		{
			"id": "silas_vigilia",
			"line": "Ouvi passos perto do celeiro durante a madrugada. Era só alguém escondendo comida para a família. Não denunciei; ajudei a reorganizar as reservas.",
			"good": "Você protegeu a família e a vila. Quero entender por que sentiram que precisavam esconder.",
			"neutral": "Precisamos conferir o inventário pela manhã.",
			"bad": "Você deveria ter punido o roubo imediatamente.",
			"good_reply": "Silas relaxa os ombros. Vigilância, para ele, nunca significou deixar de enxergar pessoas.",
			"neutral_reply": "Silas entrega uma contagem precisa e mantém para si a parte humana da história.",
			"bad_reply": "Silas responde que obediência sem contexto é apenas outra forma de cegueira."
		},
		{
			"id": "silas_estereotipo",
			"line": "Alguém deixou alho na minha porta. Pelo menos estava fresco. Fiz molho e devolvi o pote com a receita.",
			"good": "Você não deveria precisar transformar preconceito em piada para deixá-los confortáveis.",
			"neutral": "A receita ficou boa?",
			"bad": "Talvez tenham tido motivos para desconfiar.",
			"good_reply": "O sorriso de Silas é pequeno, mas aliviado por não precisar explicar o óbvio.",
			"neutral_reply": "Silas admite que o molho ficou excelente e oferece uma porção.",
			"bad_reply": "Silas responde apenas que já ouviu essa frase antes."
		},
		{
			"id": "silas_palco",
			"line": "A praça tem acústica péssima e público excelente. É um problema raro.",
			"good": "Podemos melhorar o palco sem perder o que torna o público especial.",
			"neutral": "Talvez baste mudar as caixas de lugar.",
			"bad": "Música não é prioridade para a vila.",
			"good_reply": "Silas começa a medir a praça, animado demais para sustentar a pose indiferente.",
			"neutral_reply": "Silas concorda e testa a sugestão com um acorde curto.",
			"bad_reply": "Silas guarda a palheta e encerra o ensaio mais cedo."
		}
	],
	DALIA_ID: [
		{
			"id": "dalia_horta_comum",
			"line": "Algumas famílias querem cercar pequenos canteiros. Outras preferem uma horta comum. A terra não opinou, mas as minhocas parecem sindicalizadas.",
			"good": "Vamos reservar espaço individual e manter uma área partilhada.",
			"neutral": "Organize uma votação entre as famílias.",
			"bad": "Decida sozinha; não precisamos ouvir todo mundo.",
			"good_reply": "Dália desenha um plano que cabe gente, sementes e até o sindicato informal das minhocas.",
			"neutral_reply": "Dália prepara a votação e insiste que as crianças também possam participar.",
			"bad_reply": "Dália lembra que cultivo coletivo sem escuta vira apenas trabalho imposto."
		},
		{
			"id": "dalia_erva_teimosa",
			"line": "Uma erva rara nasceu no meio do caminho. Posso transplantá-la, mas ela floresceu justamente onde todos precisam passar.",
			"good": "Vamos protegê-la até encontrarmos um lugar onde possa continuar crescendo.",
			"neutral": "Transplante antes que alguém pise nela.",
			"bad": "Arranque. É só uma planta.",
			"good_reply": "Dália improvisa uma pequena proteção e agradece por você ter visto valor antes de conveniência.",
			"neutral_reply": "Dália prepara o solo novo com cuidado e aceita a solução prática.",
			"bad_reply": "Dália remove a planta em silêncio, guardando as sementes longe de você."
		},
		{
			"id": "dalia_compostagem",
			"line": "A compostagem está funcionando tão bem que começou a aquecer o galpão ao lado. Metade da vila chama de milagre; a outra metade quer uma tampa melhor.",
			"good": "Vamos aproveitar o calor e melhorar a cobertura sem desperdiçar o adubo.",
			"neutral": "Mova a pilha para mais longe do galpão.",
			"bad": "Feche tudo e pare de usar compostagem.",
			"good_reply": "Dália reúne madeira, palha e voluntários para transformar o acaso num projeto útil para todos.",
			"neutral_reply": "Dália aceita a solução prática e começa a procurar um terreno mais adequado.",
			"bad_reply": "Dália desmonta a pilha, mas lamenta perder uma solução em vez de tentar melhorá-la."
		},
		{
			"id": "dalia_sementes",
			"line": "Separei sementes resistentes para as famílias novas. Quero que cada chegada encontre algo que possa plantar e chamar de seu.",
			"good": "Isso transforma acolhimento em algo que continuará crescendo.",
			"neutral": "Registre quantas sementes cada família recebe.",
			"bad": "É melhor guardar tudo para emergências.",
			"good_reply": "Dália organiza pequenos envelopes com nomes, instruções e espaço para uma promessa.",
			"neutral_reply": "Dália aceita o registro, desde que ele não vire uma barreira para quem precisa.",
			"bad_reply": "Dália guarda parte das sementes, mas discorda de tratar toda esperança como desperdício."
		}
	]
}


const PERSONAL_EVENTS: Dictionary = {
	SILAS_ID: [
		{"title": "O Nome que Não Era Monstro", "premise": "Silas encontra um cartaz antigo que oferece recompensa por um meio-vampiro com sua descrição. Ele não sabe se ri, foge ou confronta a lembrança.", "good": "Esse cartaz descreve o medo de outras pessoas, não quem você é.", "neutral": "Podemos guardar o cartaz como registro do passado.", "bad": "Talvez seja melhor não chamar atenção para isso."},
		{"title": "A Canção Interrompida", "premise": "Silas tenta terminar uma música escrita pela mãe humana, mas a última estrofe foi apagada pelo tempo.", "good": "Você pode terminar a canção sem fingir que sabe exatamente o que ela diria.", "neutral": "Talvez Rubra encontre uma cópia antiga.", "bad": "Algumas canções devem permanecer inacabadas."},
		{"title": "A Noite sem Plateia", "premise": "Silas recebe convite para tocar numa cidade onde seria famoso, desde que esconda sua origem e transforme a própria imagem em personagem.", "good": "Quero ouvir a música que é sua, não a versão que venderiam de você.", "neutral": "Negocie termos que preservem sua identidade.", "bad": "Fama exige sacrifícios. Aceite antes que mudem de ideia."},
		{"title": "Último Acorde antes do Amanhecer", "premise": "Silas toca uma composição que só existe quando você está presente e pergunta que nome deveria dar àquilo que construíram.", "good": "Dê o nosso nome. Quero continuar esta música com você.", "neutral": "Quero que nossa amizade continue sendo um lugar seguro.", "bad": "Prefiro que esta seja a última vez que tocamos sobre isso."}
	],
	DALIA_ID: [
		{"title": "O Jardim que Escolhia Donos", "premise": "Um círculo de ervas mágicas aceita algumas famílias e rejeita outras. Dália teme que a magia transforme a horta em mais uma fronteira.", "good": "Nenhuma magia decide quem merece pertencer. Vamos replantar o círculo juntos.", "neutral": "Estude o padrão antes de agir.", "bad": "Se a magia escolheu, talvez devamos respeitar."},
		{"title": "A Receita sem Medida", "premise": "Dália revela um caderno de remédios herdado da avó. As receitas registram sentimentos e lembranças, mas nenhuma quantidade exata.", "good": "Você não precisa copiar sua avó; pode continuar o cuidado do seu próprio jeito.", "neutral": "Vamos testar cada receita com cautela.", "bad": "Sem medidas, esse caderno não tem utilidade."},
		{"title": "Raízes em Movimento", "premise": "Um círculo itinerante convida Dália a partir e levar consigo sementes capazes de recuperar terras distantes.", "good": "Você pode ajudar outras terras sem fingir que esta vila não criou raízes em você.", "neutral": "Talvez uma viagem curta esclareça o que deseja.", "bad": "Ficar seria desperdiçar seu talento."},
		{"title": "Duas Sementes para o Mesmo Futuro", "premise": "Dália entrega duas sementes de uma planta que só floresce quando cultivada por pessoas que escolheram permanecer juntas.", "good": "Vamos plantá-las lado a lado e cuidar do que vier.", "neutral": "Quero plantar uma amizade que continue profunda e inteira.", "bad": "Não quero prometer nada com você."}
	]
}


const INTEREST_CHOICES: Dictionary = {
	"aelric_ferreiro": ["Quero ser alguém com quem você possa baixar a guarda, não apenas dividir trabalho.", "Se escolher ficar, quero que saiba que meus sentimentos também fazem parte desta escolha."],
	"kobi_mercante": ["Confio em você além de qualquer contrato — e quero descobrir aonde isso pode nos levar.", "Não quero ser apenas um bom negócio em sua vida. Quero estar ao seu lado."],
	"orion_draconato": ["Quero conhecer o desconhecido com você, não apenas ouvir seus relatórios.", "Se existe um futuro para nós, quero observá-lo de perto."],
	"rubra_meio_demonia": ["Quero conhecer você além dos livros e medos que outros escreveram.", "Quando penso no próximo capítulo, espero encontrar nós dois nele."],
	"brunna_ana_barbara": ["Você não precisa escolher entre aventura e proximidade; quero descobrir isso com você.", "Quando você imagina um lar, quero que saiba que também imagino você."],
	SILAS_ID: ["Quero ouvir o que você não consegue dizer em voz alta — e ficar para responder.", "Não quero que esta vila seja apenas mais um palco do qual você parte. Quero estar perto de você."],
	DALIA_ID: ["Quero conhecer todas as formas de cuidado que podemos cultivar juntos.", "Quando você fala em criar raízes, percebo que desejo um futuro ao seu lado."]
}


static func get_character_data(npc_id: String) -> Dictionary:
	return (CHARACTER_DATA.get(npc_id, {}) as Dictionary).duplicate(true)


static func get_conversation_topics(npc_id: String) -> Array:
	return (CONVERSATION_TOPICS.get(npc_id, []) as Array).duplicate(true)


static func get_personal_events(npc_id: String) -> Array:
	return (PERSONAL_EVENTS.get(npc_id, []) as Array).duplicate(true)


static func get_interest_choice(npc_id: String, marker_index: int) -> String:
	var choices: Array = INTEREST_CHOICES.get(npc_id, []) as Array
	if marker_index < 0 or marker_index >= choices.size():
		return ""
	return String(choices[marker_index])


static func get_village_topic(
	npc_id: String,
	world_context: Dictionary
) -> Dictionary:
	if world_context.is_empty():
		return {}
	var food_balance: float = float(world_context.get("food_balance", 0.0))
	var happiness: float = float(world_context.get("happiness", 50.0))
	if npc_id == DALIA_ID and food_balance < 0.0:
		return {
			"id": "dalia_vila_alimento_baixo",
			"line": "A previsão de alimentação está negativa. Posso reorganizar a horta partilhada, mas também precisamos decidir o que a vila prioriza agora.",
			"good": "Mostre o plano e vamos proteger primeiro quem tem menos reserva.",
			"neutral": "Aumente a produção antes do próximo dia.",
			"bad": "Não precisamos alarmar ninguém por causa de uma previsão.",
			"good_reply": "Dália abre os registros e transforma preocupação em um plano que todos conseguem compreender.",
			"neutral_reply": "Dália aceita a urgência, mas lembra que produção sem distribuição ainda deixa pratos vazios.",
			"bad_reply": "Dália guarda a previsão, preocupada com o custo de ignorar um aviso claro."
		}
	if npc_id == SILAS_ID and happiness < 30.0:
		return {
			"id": "silas_vila_felicidade_baixa",
			"line": "A vila está silenciosa de um jeito ruim. Não falta música; falta gente acreditando que amanhã merece uma canção.",
			"good": "Vamos ouvir o que está pesando sobre as pessoas antes de tentar animá-las.",
			"neutral": "Talvez uma apresentação ajude.",
			"bad": "A felicidade volta sozinha quando o trabalho melhora.",
			"good_reply": "Silas concorda e começa a vigília conversando, não tocando.",
			"neutral_reply": "Silas prepara uma apresentação pequena, sem confundir distração com cura.",
			"bad_reply": "Silas responde que silêncio ignorado costuma voltar mais alto."
		}
	return {}
