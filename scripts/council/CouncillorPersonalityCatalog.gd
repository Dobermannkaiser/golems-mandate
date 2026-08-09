class_name CouncillorPersonalityCatalog
extends RefCounted


const DEFINITIONS: Array[Dictionary] = [
	{
		"id": "optimistic",
		"name": "Otimista",
		"description": "Procura possibilidades e trata crises como problemas recuperáveis.",
		"intro": "Há algo estranho acontecendo, mas talvez possamos transformar isso em uma oportunidade para a vila.",
		"practical": "Certo. Vou resolver com cuidado e registrar o que funcionar; assim teremos uma solução e uma boa história para contar.",
		"curious": "Ótimo! Mesmo que seja perigoso, descobrir algo novo pode abrir um caminho melhor do que o esperado.",
		"cautious": "Podemos esperar um pouco. Só não quero que o medo nos faça perder uma chance que ainda pode ser boa.",
		"winter": "O inverno será duro, mas ainda temos tempo para preparar reservas e atravessá-lo juntos.",
		"prepare": "Sabia que conseguiríamos agir a tempo. Preparação não torna o frio agradável, mas torna a recuperação possível.",
		"watch": "Acompanhar os números é um começo. Vamos usar cada melhora como sinal de que o plano está funcionando.",
		"ignore": "Espero que tenha razão. Ainda assim, vou separar uma reserva pequena; prefiro uma surpresa boa a uma tragédia evitável."
	},
	{
		"id": "cautious",
		"name": "Cauteloso",
		"description": "Valoriza reservas, preparação e decisões com risco conhecido.",
		"intro": "Encontrei sinais incomuns perto da vila. Antes de agir, precisamos medir o risco e preparar uma saída.",
		"practical": "É a escolha correta. Vou isolar a área, registrar cada etapa e interromper ao primeiro sinal de perigo real.",
		"curious": "Posso investigar, mas com distância, ferramentas e uma rota de retorno. Curiosidade sem precaução é só imprudência.",
		"cautious": "Concordo. Observar primeiro preserva recursos e evita que uma descoberta pequena vire uma crise grande.",
		"winter": "As reservas atuais não deixam margem para erro. Precisamos preparar comida antes que o frio limite nossas opções.",
		"prepare": "Ótimo. Quanto antes estocarmos, menor será a chance de uma única perda comprometer toda a vila.",
		"watch": "Monitorar ajuda, mas precisamos de um limite claro para agir. Não quero esperar até a previsão ficar vermelha.",
		"ignore": "Não vou discutir, mas manterei uma reserva de emergência. O inverno pune excesso de confiança."
	},
	{
		"id": "practical",
		"name": "Prático",
		"description": "Prefere soluções diretas, mensuráveis e que possam ser executadas agora.",
		"intro": "Temos um problema concreto perto da vila. Preciso de uma decisão simples: resolver, investigar ou bloquear a área.",
		"practical": "Perfeito. Vou eliminar o risco, anotar o custo e voltar com um resultado que possamos usar.",
		"curious": "Investigarei só o necessário para descobrir se isso tem utilidade. Se não tiver, encerro e sigo o trabalho.",
		"cautious": "Fecharei o acesso e voltarei quando houver informação suficiente para uma decisão objetiva.",
		"winter": "A conta é direta: produziremos menos e consumiremos mais. Precisamos guardar comida agora.",
		"prepare": "Bom. Estoque suficiente resolve o problema antes que ele precise de discurso.",
		"watch": "A previsão serve para decidir. Defina um limite e, quando atingirmos, começamos a estocar sem atraso.",
		"ignore": "Isso não muda a conta. Vou reservar o mínimo necessário para evitar uma falha previsível."
	},
	{
		"id": "ambitious",
		"name": "Ambicioso",
		"description": "Defende crescimento, expansão e resultados acima do mínimo necessário.",
		"intro": "Uma força desconhecida apareceu perto da vila. Se a dominarmos, pode acelerar nosso crescimento.",
		"practical": "Vou garantir o controle primeiro. Depois veremos como transformar o resultado em vantagem para a vila.",
		"curious": "Essa é a resposta que eu esperava. Descobertas grandes exigem coragem para ir além do caminho seguro.",
		"cautious": "Esperarei, mas não por muito tempo. Oportunidades também desaparecem quando ninguém se move.",
		"winter": "Não quero apenas sobreviver ao inverno. Quero sair dele com reservas e capacidade para crescer antes dos outros.",
		"prepare": "Excelente. Vamos preparar mais que o mínimo; vantagem acumulada agora vira expansão depois do frio.",
		"watch": "Observe, mas com uma meta de crescimento. Se só reagirmos ao risco, nunca construiremos algo maior.",
		"ignore": "Subestimar o inverno pode destruir meses de avanço. Vou proteger pelo menos o que já conquistamos."
	},
	{
		"id": "kind",
		"name": "Gentil",
		"description": "Prioriza cooperação, bem-estar e o impacto das decisões sobre as pessoas.",
		"intro": "Algo assustou moradores perto da estrada. Quero resolver sem colocar ninguém — nem a criatura — em perigo desnecessário.",
		"practical": "Vou cuidar disso com segurança e avisar as famílias próximas. Uma solução só é boa se ninguém pagar o preço escondido.",
		"curious": "Investigarei com respeito. Talvez exista uma forma de ajudar a vila sem ferir o que vive ali.",
		"cautious": "Manter distância é sensato. Também vou sinalizar o caminho para que ninguém se aproxime por engano.",
		"winter": "O frio pesa mais sobre quem já tem pouco. Precisamos guardar comida para que ninguém seja deixado para trás.",
		"prepare": "Obrigada. Uma reserva bem organizada dá segurança para todos, principalmente para quem não consegue se proteger sozinho.",
		"watch": "Vamos acompanhar e conversar com as famílias. Os números mostram a tendência; as pessoas mostram onde a falta começa.",
		"ignore": "Talvez seja leve, mas não quero apostar o bem-estar da vila nisso. Vou separar alguma comida para emergência."
	},
	{
		"id": "stubborn",
		"name": "Teimoso",
		"description": "Mantém convicções, resiste a mudanças rápidas e valoriza consistência.",
		"intro": "Eu disse que havia algo errado naquela estrada. Agora preciso saber se vamos resolver ou continuar fingindo que não está lá.",
		"practical": "Finalmente. Vou fazer do jeito seguro e terminar o que comecei, sem mudar o plano no meio por causa de um susto.",
		"curious": "Investigarei, mas porque quero provar o que venho dizendo. Não vou abandonar a trilha na primeira dificuldade.",
		"cautious": "Esperar é aceitável, desde que ninguém decida esquecer o problema amanhã. Vou continuar vigiando.",
		"winter": "Todo ano o frio chega e todo ano alguém age como se fosse surpresa. Desta vez vamos guardar comida antes.",
		"prepare": "Era isso que eu vinha pedindo. Agora mantenha o plano até termos reserva suficiente, sem cortar pela metade.",
		"watch": "Observe, mas não use a previsão como desculpa para adiar. Quando o limite for atingido, agimos sem outra discussão.",
		"ignore": "Você pode ignorar; o inverno não vai. Vou separar uma reserva e não pretendo pedir desculpas por estar preparado."
	},
	{
		"id": "playful",
		"name": "Brincalhão",
		"description": "Usa humor para aliviar tensão, sem perder a noção da gravidade da situação.",
		"intro": "Tem alguma coisa mágica perto da estrada. A boa notícia: ainda não pediu cargo público. A ruim: está chegando perto.",
		"practical": "Certo. Vou levar corda, ferramentas e zero formulários de adoção de criatura encantada.",
		"curious": "Excelente. Se eu voltar transformado em bule, coloque uma placa dizendo que ainda faço parte do Conselho.",
		"cautious": "Vou manter distância. Heroísmo é bonito, mas conservar todas as patas também tem seu charme.",
		"winter": "O inverno vem aí, e infelizmente piadas não contam como alimento. Precisamos encher o estoque.",
		"prepare": "Perfeito. Com comida guardada, poderemos reclamar do frio de barriga cheia, como manda a tradição.",
		"watch": "Vamos observar. Só lembre que uma linha vermelha na previsão não é decoração festiva.",
		"ignore": "Admiro a confiança. Mesmo assim, vou esconder uma reserva onde nem o frio nem os lanches noturnos encontrem."
	},
	{
		"id": "pessimistic",
		"name": "Pessimista",
		"description": "Identifica riscos e perdas antes dos demais, esperando que planos falhem se não houver preparo.",
		"intro": "Há algo errado perto da vila. Pode ser inofensivo, mas normalmente é assim que os problemas começam.",
		"practical": "É a opção menos arriscada. Vou resolver e documentar tudo, porque provavelmente precisaremos lidar com isso novamente.",
		"curious": "Investigarei, embora eu espere encontrar algo caro, perigoso ou ambos. Pelo menos saberemos cedo.",
		"cautious": "Boa escolha. Se tivermos sorte, o problema irá embora. Se não, ao menos não estaremos no alcance dele.",
		"winter": "As reservas não serão suficientes se qualquer coisa sair errada — e alguma coisa sempre sai. Precisamos estocar.",
		"prepare": "Isso reduz a chance de desastre. Não elimina, mas já é melhor que atravessar o inverno contando com sorte.",
		"watch": "Observe de perto. Quando os números piorarem, provavelmente já teremos perdido tempo demais.",
		"ignore": "Espero estar errado. Como isso raramente me conforta, vou separar uma reserva por conta própria."
	}
]


static func has_definition(personality_id: String) -> bool:
	for definition: Dictionary in DEFINITIONS:
		if String(definition.get("id", "")) == personality_id:
			return true
	return false


static func get_definition(personality_id: String) -> Dictionary:
	for definition: Dictionary in DEFINITIONS:
		if String(definition.get("id", "")) == personality_id:
			return definition.duplicate(true)
	return DEFINITIONS[0].duplicate(true)


static func get_all_ids() -> Array[String]:
	var result: Array[String] = []
	for definition: Dictionary in DEFINITIONS:
		var personality_id: String = String(definition.get("id", "")).strip_edges()
		if not personality_id.is_empty():
			result.append(personality_id)
	return result


static func get_unique_random_ids(
	count: int,
	rng: RandomNumberGenerator
) -> Array[String]:
	var ids: Array[String] = []
	for definition: Dictionary in DEFINITIONS:
		ids.append(String(definition.get("id", "optimistic")))
	for index: int in range(ids.size() - 1, 0, -1):
		var swap_index: int = rng.randi_range(0, index)
		var temporary: String = ids[index]
		ids[index] = ids[swap_index]
		ids[swap_index] = temporary
	var result: Array[String] = []
	for index: int in range(mini(count, ids.size())):
		result.append(ids[index])
	return result


static func get_dialogue_line(
	personality_id: String,
	line_id: String
) -> String:
	var definition: Dictionary = get_definition(personality_id)
	return String(definition.get(line_id, ""))
