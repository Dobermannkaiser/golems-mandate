class_name CouncillorProgressionDialogueCatalog
extends RefCounted


const RESOURCE_NAMES: Dictionary = {
	"food": "alimentação",
	"material": "material",
	"happiness": "felicidade"
}

const PERSONALITY_SCENES: Dictionary = {
	"optimistic": {
		"level_lines": {
			2: "Eu já consigo enxergar a vila um pouco além do próximo problema. Antes eu só ajudava a manter o dia de pé; agora sinto que também posso ajudar a construir o amanhã.",
			3: "Olhei para tudo o que fizemos e percebi uma coisa: esta vila não está apenas sobrevivendo. Ela está aprendendo a acreditar que merece continuar existindo.",
			4: "Hoje alguém me procurou para pedir conselho. Eu quase olhei para trás, pensando que falavam com outra pessoa. Depois percebi que eu realmente tinha uma resposta.",
			5: "Cada crise que atravessamos deixou uma cicatriz, mas também abriu espaço para alguma coisa nova. Acho que finalmente aprendi a procurar essa abertura sem ignorar a dor.",
			6: "Hoje percebi que já não preciso provar que consigo ajudar. O que importa agora é usar tudo o que aprendi com responsabilidade, principalmente quando a vila estiver cansada demais para acreditar em si mesma."
		},
		"best_reply": "Essa esperança tem valor porque você a transforma em trabalho. Continue mostrando possibilidades sem esconder os riscos.",
		"neutral_reply": "Você amadureceu. Continue transformando essa esperança em trabalho que a vila possa sentir.",
		"poor_reply": "Otimismo só atrapalha. Pare de procurar um lado bom e espere o pior.",
		"best_response": "É isso. Não quero fingir que tudo ficará bem; quero ajudar a criar motivos para que fique. Vou guardar essas palavras.",
		"neutral_response": "Entendido. Ainda assim, espero que um dia os registros consigam medir aquilo que fazemos as pessoas sentirem.",
		"poor_response": "Eu consigo encarar o pior, mas não quero aprender a viver como se ele já tivesse vencido."
	},
	"cautious": {
		"level_lines": {
			2: "Revisei minhas decisões dos últimos dias. Cometi menos erros do que esperava, mas encontrei três riscos que quase passaram despercebidos. Isso me deixou... estranhamente satisfeito.",
			3: "Estou começando a distinguir prudência de medo. A prudência prepara uma saída; o medo apenas fica parado olhando para a porta.",
			4: "As pessoas agora confiam nos meus alertas. Isso torna cada palavra mais pesada. Se eu exagerar, paraliso a vila; se me calar, posso deixá-la vulnerável.",
			5: "Passei tanto tempo protegendo o que tínhamos que quase esqueci que reservas existem para permitir escolhas, não apenas para serem guardadas.",
			6: "Conheço melhor meus limites e os riscos de ultrapassá-los. Pela primeira vez, isso não me diminui. Dá forma ao que ainda posso proteger."
		},
		"best_reply": "Sua cautela é mais útil quando prepara decisões, não quando as impede. Continue apontando riscos e também caminhos seguros.",
		"neutral_reply": "Continue avaliando os riscos, mas não deixe que a prudência impeça toda tentativa.",
		"poor_reply": "Pare de questionar. Um bom conselheiro obedece sem pensar nas consequências.",
		"best_response": "Então meu dever não é dizer apenas 'não'. É mostrar o preço, preparar alternativas e permitir que a vila escolha de olhos abertos.",
		"neutral_response": "Farei isso. Mas uma avaliação sem espaço para agir pode acabar sendo apenas uma lista elegante de medos.",
		"poor_response": "Ignorar consequências não é coragem. É apenas entregar o futuro ao acaso."
	},
	"practical": {
		"level_lines": {
			2: "Trabalhei, medi o resultado e corrigi o que estava errado. Não parece uma história grandiosa, mas a vila terminou o dia melhor do que começou.",
			3: "Já não preciso testar três soluções para encontrar a que funciona. Agora geralmente erro apenas uma vez. É um avanço mensurável.",
			4: "As pessoas começaram a trazer problemas antes que virem desastres. Gosto disso. Problemas pequenos cabem em ferramentas comuns.",
			5: "Aprendi que eficiência não é fazer tudo depressa. É saber o que merece tempo, o que pode esperar e o que nunca deveria ter sido feito.",
			6: "Repetir o trabalho já não basta para me ensinar. Daqui em diante, cada melhoria precisa ter uma razão e servir a alguém, não apenas tornar um resultado maior."
		},
		"best_reply": "Seu resultado importa porque melhora a vida da vila. Continue medindo o trabalho, mas não esqueça para quem ele serve.",
		"neutral_reply": "Seu trabalho melhorou. Continue, mas não transforme cada conquista em apenas mais uma tarefa.",
		"poor_reply": "Resultados não importam; o importante é parecer ocupado.",
		"best_response": "Justo. Um número só vale alguma coisa quando representa comida, abrigo ou tranquilidade para alguém. Vou manter isso na conta.",
		"neutral_response": "Já tenho uma próxima tarefa. Só espero que não transformemos progresso em uma fila sem fim.",
		"poor_response": "Parecer ocupado é a maneira mais cara de não produzir nada. Não conte comigo para isso."
	},
	"ambitious": {
		"level_lines": {
			2: "Finalmente começo a sentir que meu trabalho deixa marca. Não quero apenas ocupar uma cadeira no Conselho; quero que esta vila seja lembrada pelo que fizermos aqui.",
			3: "Nossas metas antigas já parecem pequenas. Isso não é ingratidão. É a prova de que crescemos o bastante para desejar algo maior.",
			4: "Agora tenho influência de verdade. Posso usá-la para abrir caminhos — ou para ocupar espaço demais. Preciso decidir que tipo de força quero ser.",
			5: "Vencer deixou de ser suficiente. Quero construir algo que continue funcionando quando ninguém mais lembrar quem recebeu o crédito.",
			6: "Já provei que consigo crescer. Agora preciso escolher quais barreiras realmente merecem ser derrubadas e quais existem para proteger pessoas que não costumam ser ouvidas."
		},
		"best_reply": "Busque algo grande, mas faça a vila crescer junto com você. Uma conquista que deixa todos para trás é apenas solidão bem decorada.",
		"neutral_reply": "Continue buscando algo maior, sem esquecer de quem cresce ao seu lado.",
		"poor_reply": "Você nunca será importante. Aceite um papel pequeno e não incomode.",
		"best_response": "Quero chegar longe, não chegar sozinho. Vou cobrar mais de mim sem transformar as outras pessoas em degraus.",
		"neutral_response": "Metas maiores eu já tenho. O difícil é garantir que elas tenham significado quando forem alcançadas.",
		"poor_response": "Não preciso que diminuam meu espaço para saber quanto valho. Vou provar isso pelo que construir."
	},
	"kind": {
		"level_lines": {
			2: "Hoje reconheci o cansaço de alguém antes que a pessoa precisasse pedir ajuda. Parece pouco, mas talvez experiência seja aprender a notar o que não aparece nos relatórios.",
			3: "Tenho pensado nas consequências das nossas decisões depois que os números param de mudar. Sempre existe alguém que continua carregando o resultado.",
			4: "As pessoas confiam em mim para mediar conflitos. Isso me honra, mas também assusta. Ser gentil não significa conseguir salvar todos de toda dor.",
			5: "Aprendi a dizer não sem abandonar ninguém. Demorei para entender que limites também podem ser uma forma de cuidado.",
			6: "Hoje entendo que não fui forte apesar da gentileza. Fui forte por causa dela — quando tive coragem de usá-la com honestidade, inclusive para dizer não."
		},
		"best_reply": "Seu cuidado é valioso porque não foge das decisões difíceis. Continue ouvindo as pessoas sem prometer que toda dor pode ser evitada.",
		"neutral_reply": "Continue ajudando, mas cuide também dos seus próprios limites.",
		"poor_reply": "Sentimentos são fraqueza. Ignore as pessoas e concentre-se apenas nos recursos.",
		"best_response": "Obrigada. Quero oferecer presença e verdade, não promessas vazias. Às vezes cuidar é permanecer quando não existe solução perfeita.",
		"neutral_response": "Ajudarei. Só não quero que 'quem precisar' vire uma forma de nunca enxergar quem sempre fica em silêncio.",
		"poor_response": "Recursos sustentam corpos. Vínculos sustentam comunidades. Uma vila que esquece isso pode sobreviver e ainda assim deixar de existir."
	},
	"stubborn": {
		"level_lines": {
			2: "Disseram que eu demoraria para aprender. Estavam errados. Eu não demorei; apenas me recusei a aceitar uma explicação ruim.",
			3: "Mudei de ideia sobre uma coisa hoje. Não faça essa expressão. Eu continuo certo sobre quase todo o resto — apenas encontrei uma razão melhor.",
			4: "Agora minhas decisões têm peso. Preciso tomar cuidado para não confundir firmeza com o prazer infantil de nunca ceder.",
			5: "Descobri que manter uma promessa pode exigir mudar o método. O objetivo continua firme; o caminho é que não precisa ser uma parede.",
			6: "Cheguei até aqui porque não abandonei o que importava. Também cheguei porque, algumas vezes, alguém teve coragem suficiente para me fazer parar e escutar."
		},
		"best_reply": "Sua firmeza é uma força quando protege princípios, não quando protege seu orgulho. Continue difícil de derrubar e capaz de mudar por uma boa razão.",
		"neutral_reply": "Continue firme, mas lembre por que escolheu essa posição.",
		"poor_reply": "Você só causa problemas. Concorde com tudo e pare de discutir.",
		"best_response": "Aceito. Não prometo ser fácil de convencer, mas prometo ouvir uma razão que mereça o esforço.",
		"neutral_response": "Manter posição sem lembrar por quê é apenas ficar parado. Posso fazer melhor do que isso.",
		"poor_response": "Uma vila sem discordância não é organizada; é apenas silenciosa. Não vou colaborar com esse tipo de paz."
	},
	"playful": {
		"level_lines": {
			2: "Descobri que experiência é quando a mesma explosão acontece e você já sabe qual balde pegar. Também descobri que precisamos de mais baldes.",
			3: "As pessoas começaram a rir antes do fim das minhas histórias. Ou estou ficando melhor, ou elas aprenderam a identificar o momento exato em que tudo dá errado.",
			4: "Agora me procuram em situações sérias. Eu ainda faço piadas, mas aprendi que humor deve abrir espaço para respirar — não empurrar o problema para debaixo do tapete.",
			5: "Consegui fazer alguém sorrir num dia terrível e depois fiquei para ajudar quando o sorriso acabou. Acho que essa segunda parte é a que realmente importa.",
			6: "Eu tinha preparado confetes para comemorar o quanto aprendi, mas usei o papel para consertar um relatório. Isso se chama maturidade. Ou falta de planejamento."
		},
		"best_reply": "Sua leveza ajuda porque você não a usa para fugir. Continue fazendo a vila respirar e fique quando chegar a parte difícil.",
		"neutral_reply": "Continue trazendo leveza, principalmente quando ela precisar vir acompanhada de presença.",
		"poor_reply": "Pare com as brincadeiras. Ninguém leva você a sério.",
		"best_response": "Combinado. Posso contar a piada, guardar o chapéu e ainda ajudar a carregar o peso depois. Uma coisa não precisa apagar a outra.",
		"neutral_response": "Manter o ânimo não é apertar um botão de sorriso. Às vezes é só lembrar alguém de que não está sozinho.",
		"poor_response": "Seriedade sem humanidade vira pose. Eu sei a hora de parar de brincar; espero que você saiba a hora de começar a ouvir."
	},
	"pessimistic": {
		"level_lines": {
			2: "Eu esperava que alguma coisa desse errado. Algumas deram. A diferença é que desta vez eu estava preparado e nenhuma delas destruiu o dia inteiro.",
			3: "Continuo vendo os riscos primeiro. Mas agora também consigo distinguir um perigo real de uma catástrofe que só existe na minha cabeça.",
			4: "As pessoas passaram a ouvir meus alertas. Isso significa que preciso escolher melhor quais medos merecem ser compartilhados e quais devo examinar antes de espalhar.",
			5: "Não acredito que tudo dará certo. Aprendi algo mais útil: algumas coisas podem dar errado sem que isso seja o fim.",
			6: "Ainda consigo listar vinte maneiras de perdermos tudo. A novidade é que agora conheço vinte e uma maneiras de impedir — e já não guardo todas elas só para mim."
		},
		"best_reply": "Você enxerga riscos que outros ignoram. Use isso para preparar a vila, não para convencê-la de que tentar é inútil.",
		"neutral_reply": "Continue enxergando os riscos cedo, mas traga também um caminho para enfrentá-los.",
		"poor_reply": "Ninguém quer ouvir más notícias. Finja que está tudo bem.",
		"best_response": "Posso fazer isso. Não preciso prometer um final feliz; basta transformar meus receios em planos que deem às pessoas uma chance real.",
		"neutral_response": "Procurar problemas sem procurar respostas é apenas colecionar motivos para desistir. Não quero voltar a fazer isso.",
		"poor_response": "Fingir segurança não elimina o perigo. Só garante que ele nos encontre despreparados."
	}
}


static func create_level_up_conversation(request: Dictionary) -> Dictionary:
	var conversation_id: String = String(request.get("conversation_id", "")).strip_edges()
	var representative_id: String = String(request.get("representative_id", "")).strip_edges()
	var display_name: String = String(request.get("display_name", "Conselheiro")).strip_edges()
	var portrait_id: String = String(request.get("portrait_id", "")).strip_edges()
	var personality_id: String = String(request.get("personality_id", "practical")).strip_edges()
	var new_level: int = clampi(int(request.get("level", 2)), 2, 6)
	var resource_id: String = String(request.get("dominant_resource", "material")).strip_edges()
	var resource_name: String = String(RESOURCE_NAMES.get(resource_id, "recurso"))
	var has_personal_production: bool = bool(
		request.get("has_personal_production", true)
	)
	var contribution_line: String = (
		"Entre tudo o que fiz pela vila, foi em %s que deixei a marca mais clara."
		% resource_name
		if has_personal_production
		else (
			"Ainda estou descobrindo onde meu trabalho faz mais diferença. "
			+ "Por enquanto, quero usar este aprendizado para melhorar em "
			+ resource_name
			+ "."
		)
	)
	var profile: Dictionary = PERSONALITY_SCENES.get(
		personality_id,
		PERSONALITY_SCENES["practical"]
	)
	var level_lines: Dictionary = profile.get("level_lines", {})
	var opening: String = String(level_lines.get(new_level, level_lines.get(2, "Sinto que aprendi algo importante.")))
	var choices: Array[Dictionary] = [
		{
			"id": "best",
			"text": String(profile.get("best_reply", "Reconheça o que aprendeu e use isso pela vila.")),
			"next": "best_response",
			"level_up_conversation_id": conversation_id,
			"level_up_representative_id": representative_id,
			"level_up_quality": "best",
			"level_up_resource_id": resource_id
		},
		{
			"id": "neutral",
			"text": String(profile.get("neutral_reply", "Continue trabalhando.")),
			"next": "neutral_response",
			"level_up_conversation_id": conversation_id,
			"level_up_representative_id": representative_id,
			"level_up_quality": "neutral",
			"level_up_resource_id": resource_id
		},
		{
			"id": "poor",
			"text": String(profile.get("poor_reply", "Isso não significa nada.")),
			"next": "poor_response",
			"level_up_conversation_id": conversation_id,
			"level_up_representative_id": representative_id,
			"level_up_quality": "poor",
			"level_up_resource_id": resource_id
		}
	]
	_shuffle_choices(choices, conversation_id.hash())
	return {
		"id": conversation_id,
		"title": "Conquista de %s — Nível %d" % [display_name, new_level],
		"start": "opening",
		"allow_close": false,
		"nodes": {
			"opening": {
				"speaker_id": portrait_id,
				"speaker_name": display_name,
				"expression": "happy",
				"text": (
					opening
					+ "\n\n"
					+ contribution_line
					+ " Antes de voltar ao trabalho, quero saber o que você espera de mim daqui em diante."
				),
				"choices": choices
			},
			"best_response": {
				"speaker_id": portrait_id,
				"speaker_name": display_name,
				"expression": "happy",
				"text": String(
					profile.get("best_response", "Vou lembrar disso.")
				)
			},
			"neutral_response": {
				"speaker_id": portrait_id,
				"speaker_name": display_name,
				"expression": "neutral",
				"text": String(profile.get("neutral_response", "Entendido."))
			},
			"poor_response": {
				"speaker_id": portrait_id,
				"speaker_name": display_name,
				"expression": "neutral",
				"text": String(profile.get("poor_response", "Não concordo."))
			}
		}
	}


static func get_milestone_quote(
	personality_id: String,
	resource_id: String,
	milestone_value: int
) -> String:
	var resource_name: String = String(RESOURCE_NAMES.get(resource_id, "recurso"))
	match personality_id:
		"optimistic":
			return "%d de %s! É uma prova de que pequenos dias podem construir algo enorme." % [milestone_value, resource_name]
		"cautious":
			return "%d de %s registrados. Agora precisamos garantir que essa conquista não nos deixe descuidados." % [milestone_value, resource_name]
		"practical":
			return "%d de %s produzidos. O resultado está claro; a próxima meta também." % [milestone_value, resource_name]
		"ambitious":
			return "%d de %s. Quero que isso pareça apenas o primeiro número de uma história muito maior." % [milestone_value, resource_name]
		"kind":
			return "%d de %s significam dias um pouco melhores para muita gente. É isso que quero lembrar." % [milestone_value, resource_name]
		"stubborn":
			return "%d de %s. Disseram que eu não manteria o ritmo. Os resultados respondem por mim." % [milestone_value, resource_name]
		"playful":
			return "%d de %s! Eu pediria uma estátua, mas provavelmente teríamos de produzi-la também." % [milestone_value, resource_name]
		"pessimistic":
			return "%d de %s ajudam. Não nos tornam invencíveis, mas tornam o próximo desastre menos convincente." % [milestone_value, resource_name]
		_:
			return "%d de %s produzidos para a vila." % [milestone_value, resource_name]


static func get_event_result_quote(
	personality_id: String,
	succeeded: bool,
	was_test: bool
) -> String:
	if succeeded:
		match personality_id:
			"optimistic": return "Conseguimos. Agora precisamos transformar este alívio em confiança, não em descuido."
			"cautious": return "Funcionou. Vou registrar também o que quase deu errado; sucesso é a melhor hora para aprender sem pagar outra vez."
			"practical": return "Problema resolvido. O resultado foi bom e o método pode ser repetido."
			"ambitious": return "Uma decisão como esta muda a forma como a vila enxerga o que é possível."
			"kind": return "Deu certo. Antes de comemorar, quero verificar se ninguém ficou carregando sozinho o preço da solução."
			"stubborn": return "A solução aguentou. Não porque foi fácil, mas porque não cedemos no ponto que importava."
			"playful": return "Vitória confirmada. Posso fazer a piada agora ou ainda há alguma coisa pegando fogo?"
			"pessimistic": return "Sobrevivemos a esta. Vou aceitar a vitória depois de conferir se ela não deixou uma armadilha escondida."
	else:
		match personality_id:
			"optimistic": return "Falhou, mas não terminou aqui. Primeiro entendemos a perda; depois encontramos o próximo caminho."
			"cautious": return "O risco venceu desta vez. Precisamos descobrir qual aviso ignoramos antes de tentar outra coisa."
			"practical": return "Não funcionou. Vamos separar o erro do azar e corrigir apenas o que realmente pode ser corrigido."
			"ambitious": return "Uma derrota não reduz o objetivo. Só aumenta o preço de alcançá-lo sem repetir a mesma arrogância."
			"kind": return "Antes de procurar culpados, precisamos cuidar de quem sofreu as consequências. Depois conversamos sobre o erro."
			"stubborn": return "Eu não gosto de recuar, mas insistir da mesma maneira seria apenas repetir a falha com mais barulho."
			"playful": return "Certo... esta é a parte em que eu guardo a piada e ajudo a recolher os pedaços."
			"pessimistic": return "Era uma possibilidade real. Isso não torna a falha boa, mas significa que ainda podemos ter um plano para o que vem depois."
	if not was_test:
		return "A decisão foi cumprida. Agora veremos o que ela muda para a vila."
	return "O resultado está diante de nós. Cabe aprender com ele e seguir."


static func _shuffle_choices(choices: Array[Dictionary], seed_value: int) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = maxi(1, absi(seed_value))
	for index: int in range(choices.size() - 1, 0, -1):
		var swap_index: int = rng.randi_range(0, index)
		var temporary: Dictionary = choices[index]
		choices[index] = choices[swap_index]
		choices[swap_index] = temporary
