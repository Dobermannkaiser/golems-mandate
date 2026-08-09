class_name CouncillorOpportunityCatalog
extends RefCounted


const OPPORTUNITIES: Array[Dictionary] = [
	{
		"id": "sementes_luminosas",
		"profession": Villager.Profession.FARMER,
		"title": "SEMENTES QUE BRILHAM SOB A CHUVA",
		"intro": (
			"Depois da chuva, uma fileira de sementes começou a emitir uma luz verde sob a terra. "
			+ "Elas estão crescendo depressa demais e podem alimentar a vila — ou esgotar o solo."
		),
		"choices": [
			{
				"id": "canteiro_controlado",
				"text": "Isolar um canteiro e observar o crescimento. [3 dias: +10% de alimentação]",
				"result": "Vou limitar as sementes a um único canteiro e registrar cada mudança. Cresceremos menos agora, mas sem apostar o celeiro inteiro numa magia que ainda não entendemos.",
				"duration_days": 3,
				"immediate": {},
				"modifiers": {"food_production_multiplier": 1.10},
				"completion": "O canteiro luminoso foi estabilizado e deixou uma colheita segura."
			},
			{
				"id": "plantio_amplo",
				"text": "Preparar o campo inteiro para o plantio. [Agora: -4 material; 3 dias: +20% de alimentação]",
				"result": "Então abriremos sulcos novos antes que o brilho desapareça. Vai custar ferramentas e cercas, mas a próxima colheita pode mudar o tamanho de nossas reservas.",
				"duration_days": 3,
				"immediate": {"material": -4.0},
				"modifiers": {"food_production_multiplier": 1.20},
				"completion": "O plantio amplo terminou; as sementes mágicas renderam uma colheita excepcional."
			},
			{
				"id": "mudas_comunitarias",
				"text": "Distribuir as mudas entre as famílias. [Agora: -3 alimentação; 3 dias: +5% alimentação e +0,6 felicidade/dia]",
				"result": "Cada família receberá uma pequena muda e instruções claras. Não será a maior colheita, mas todos terão algo próprio para cuidar enquanto a vila aprende com a experiência.",
				"duration_days": 3,
				"immediate": {"food": -3.0},
				"modifiers": {
					"food_production_multiplier": 1.05,
					"daily_happiness_bonus": 0.6
				},
				"completion": "As mudas comunitárias criaram pequenos cultivos e aproximaram os moradores."
			}
		]
	},
	{
		"id": "praga_de_vidro",
		"profession": Villager.Profession.FARMER,
		"title": "A PRAGA DE ASAS DE VIDRO",
		"intro": (
			"Insetos transparentes apareceram nas folhas durante a madrugada. Eles comem pouco, "
			+ "mas deixam para trás um pó que acelera o amadurecimento das plantas."
		),
		"choices": [
			{
				"id": "queimar_focos",
				"text": "Eliminar os focos antes que se espalhem. [Agora: -3 material; 2 dias: +12% alimentação]",
				"result": "Vou proteger os campos primeiro. O pó que já caiu ainda ajudará a colheita, mas não deixaremos a infestação decidir o futuro das plantações.",
				"duration_days": 2,
				"immediate": {"material": -3.0},
				"modifiers": {"food_production_multiplier": 1.12},
				"completion": "Os focos foram eliminados antes que a praga tomasse os campos."
			},
			{
				"id": "atrair_passaros",
				"text": "Atrair pássaros para controlar os insetos. [Agora: -2 alimentação; 3 dias: +8% alimentação e +0,4 felicidade/dia]",
				"result": "Espalharemos grãos perto das cercas e deixaremos a natureza fazer parte do trabalho. Será menos previsível, mas o campo ficará vivo em vez de silencioso.",
				"duration_days": 3,
				"immediate": {"food": -2.0},
				"modifiers": {
					"food_production_multiplier": 1.08,
					"daily_happiness_bonus": 0.4
				},
				"completion": "Os pássaros reduziram a praga e passaram a fazer parte da paisagem da vila."
			},
			{
				"id": "estudar_po",
				"text": "Coletar o pó e estudar seu efeito. [3 dias: +18% alimentação]",
				"result": "Vou separar uma área pequena e descobrir quanto desse pó pode ser usado sem destruir o solo. Se der certo, teremos uma técnica nova; se não, ao menos conheceremos o limite sem alarmar a vila inteira.",
				"duration_days": 3,
				"immediate": {},
				"modifiers": {"food_production_multiplier": 1.18},
				"completion": "O estudo definiu uma dose segura do pó e melhorou a colheita."
			}
		]
	},
	{
		"id": "ferramentas_cantoras",
		"profession": Villager.Profession.BLACKSMITH,
		"title": "FERRAMENTAS QUE CANTAM NA FORJA",
		"intro": (
			"Um lote de martelos começou a vibrar no mesmo tom quando o fogo da forja é aceso. "
			+ "O metal parece responder ao ritmo do trabalho e pode tornar as equipes mais eficientes."
		),
		"choices": [
			{
				"id": "reforcar_ferramentas",
				"text": "Reforçar as ferramentas de toda a vila. [Agora: -4 material; 3 dias: +8% em toda produção]",
				"result": "Usarei o metal melhor nas ferramentas que passam por mais mãos. Não será um trabalho vistoso, mas cada turno sentirá a diferença.",
				"duration_days": 3,
				"immediate": {"material": -4.0},
				"modifiers": {
					"food_production_multiplier": 1.08,
					"material_production_multiplier": 1.08,
					"happiness_production_multiplier": 1.08
				},
				"completion": "As ferramentas reforçadas atravessaram os turnos sem quebrar e elevaram o rendimento geral."
			},
			{
				"id": "lote_para_obras",
				"text": "Produzir um lote exclusivo para as obras. [2 dias: +22% de material]",
				"result": "Vou concentrar a forja em cunhas, pregos e lâminas de corte. Durante dois dias, tudo o que sair daqui terá um único destino: acelerar as obras.",
				"duration_days": 2,
				"immediate": {},
				"modifiers": {"material_production_multiplier": 1.22},
				"completion": "O lote especial de ferramentas foi entregue e reduziu o desperdício nas obras."
			},
			{
				"id": "pecas_comunitarias",
				"text": "Forjar utensílios pedidos pelos moradores. [Agora: -2 material; 3 dias: +0,8 felicidade/dia]",
				"result": "Panelas, dobradiças, agulhas e facas não viram estátuas, mas mudam o dia de quem as usa. Vou abrir a lista de pedidos e trabalhar pelo que está faltando nas casas.",
				"duration_days": 3,
				"immediate": {"material": -2.0},
				"modifiers": {"daily_happiness_bonus": 0.8},
				"completion": "Os utensílios foram distribuídos e resolveram dezenas de pequenos problemas domésticos."
			}
		]
	},
	{
		"id": "metal_com_memoria",
		"profession": Villager.Profession.BLACKSMITH,
		"title": "O METAL QUE LEMBRA GOLPES",
		"intro": (
			"Uma barra de minério reaproveitado repete sozinha as marcas do último martelo que a tocou. "
			+ "Com cuidado, ela pode ensinar um padrão de forja inteiro às equipes."
		),
		"choices": [
			{
				"id": "molde_seguro",
				"text": "Usar o metal como molde de treinamento. [3 dias: +12% material]",
				"result": "Vou gravar um padrão simples e deixar o metal demonstrá-lo aos aprendizes. O ganho será constante, sem exigir que ninguém arrisque as mãos numa peça instável.",
				"duration_days": 3,
				"immediate": {},
				"modifiers": {"material_production_multiplier": 1.12},
				"completion": "O molde ensinou um ritmo comum aos aprendizes e melhorou a produção da forja."
			},
			{
				"id": "forja_intensiva",
				"text": "Explorar a memória do metal ao limite. [Agora: -2 felicidade; 2 dias: +25% material]",
				"result": "Faremos turnos curtos e intensos enquanto a barra ainda responde. Vai ser barulhento e cansativo, mas nenhum golpe será desperdiçado.",
				"duration_days": 2,
				"immediate": {"happiness": -2.0},
				"modifiers": {"material_production_multiplier": 1.25},
				"completion": "A forja intensiva terminou antes que o metal perdesse a memória."
			},
			{
				"id": "guardar_amostra",
				"text": "Produzir peças úteis e guardar uma amostra. [Agora: +3 material; 3 dias: +5% material e +0,4 felicidade/dia]",
				"result": "Não precisamos escolher entre lucro imediato e aprendizado. Farei peças simples agora e preservarei um fragmento para que a vila continue estudando depois.",
				"duration_days": 3,
				"immediate": {"material": 3.0},
				"modifiers": {
					"material_production_multiplier": 1.05,
					"daily_happiness_bonus": 0.4
				},
				"completion": "A amostra foi preservada e as primeiras peças já estão em uso."
			}
		]
	},
	{
		"id": "cadernos_atrasados",
		"profession": Villager.Profession.CIVIL_SERVANT,
		"title": "OS CADERNOS QUE NINGUÉM ATUALIZOU",
		"intro": (
			"Os registros de estoque divergem entre o celeiro, a cozinha e a praça. "
			+ "Há desperdício escondido nas diferenças, mas corrigi-las exigirá mexer na rotina de todos."
		),
		"choices": [
			{
				"id": "racionamento_justo",
				"text": "Criar cotas claras por família. [Agora: -1 felicidade; 3 dias: -8% consumo de alimentação]",
				"result": "Vou publicar as regras e aplicar a mesma medida a todos. Ninguém gosta de ver uma cota na porta, mas é melhor do que descobrir tarde demais que o celeiro estava vazio.",
				"duration_days": 3,
				"immediate": {"happiness": -1.0},
				"modifiers": {"food_consumption_multiplier": 0.92},
				"completion": "As cotas organizaram o consumo e revelaram onde a comida estava sendo desperdiçada."
			},
			{
				"id": "turnos_transparentes",
				"text": "Reorganizar os turnos com registros públicos. [3 dias: +8% em toda produção]",
				"result": "Cada equipe saberá quando começa, o que recebe e a quem entrega. A eficiência não virá de trabalhar mais, mas de parar de esperar por ordens contraditórias.",
				"duration_days": 3,
				"immediate": {},
				"modifiers": {
					"food_production_multiplier": 1.08,
					"material_production_multiplier": 1.08,
					"happiness_production_multiplier": 1.08
				},
				"completion": "Os turnos públicos reduziram atrasos e retrabalho em toda a vila."
			},
			{
				"id": "assembleia_aberta",
				"text": "Ouvir as famílias antes de alterar as regras. [Agora: -2 material; 3 dias: +1 felicidade/dia]",
				"result": "Montaremos bancos, lanternas e uma mesa grande o bastante para ninguém falar de fora da roda. A decisão será mais lenta, mas a vila reconhecerá sua própria voz nela.",
				"duration_days": 3,
				"immediate": {"material": -2.0},
				"modifiers": {"daily_happiness_bonus": 1.0},
				"completion": "A assembleia terminou com novas regras aceitas pela maioria dos moradores."
			}
		]
	},
	{
		"id": "rumores_da_praca",
		"profession": Villager.Profession.CIVIL_SERVANT,
		"title": "RUMORES ESCRITOS COMO DECRETOS",
		"intro": (
			"Bilhetes anônimos estão aparecendo na praça com ordens falsas, assinaturas inventadas "
			+ "e acusações contra equipes de trabalho. A confusão já começa a atrasar entregas."
		),
		"choices": [
			{
				"id": "mural_oficial",
				"text": "Criar um mural oficial de decisões. [Agora: -3 material; 3 dias: +6% produção e +0,4 felicidade/dia]",
				"result": "Toda decisão verdadeira terá data, selo e responsável. Não impediremos as pessoas de falar, mas ninguém confundirá fofoca com ordem da prefeitura.",
				"duration_days": 3,
				"immediate": {"material": -3.0},
				"modifiers": {
					"food_production_multiplier": 1.06,
					"material_production_multiplier": 1.06,
					"happiness_production_multiplier": 1.06,
					"daily_happiness_bonus": 0.4
				},
				"completion": "O mural oficial encerrou a maior parte da confusão e virou referência diária."
			},
			{
				"id": "investigar_autores",
				"text": "Rastrear quem espalha os bilhetes. [Agora: -1 felicidade; 2 dias: +15% produção]",
				"result": "Vou comparar papel, tinta e horários. Durante dois dias, os responsáveis trabalharão sob instruções diretas enquanto descobrimos de onde vieram as ordens falsas.",
				"duration_days": 2,
				"immediate": {"happiness": -1.0},
				"modifiers": {
					"food_production_multiplier": 1.15,
					"material_production_multiplier": 1.15,
					"happiness_production_multiplier": 1.15
				},
				"completion": "A investigação identificou a origem dos bilhetes e restaurou a cadeia de ordens."
			},
			{
				"id": "responder_publicamente",
				"text": "Responder aos rumores em praça aberta. [3 dias: +0,9 felicidade/dia]",
				"result": "Lerei cada acusação em voz alta e responderei com os registros na mesa. Se existe medo real por trás dos boatos, ele precisa ser ouvido; se existe mentira, precisa ser exposta.",
				"duration_days": 3,
				"immediate": {},
				"modifiers": {"daily_happiness_bonus": 0.9},
				"completion": "A sessão pública esvaziou os rumores e aumentou a confiança nos registros."
			}
		]
	},
	{
		"id": "pegadas_no_limite",
		"profession": Villager.Profession.GUARD,
		"title": "PEGADAS ALÉM DAS ÚLTIMAS CASAS",
		"intro": (
			"Pegadas grandes circulam as últimas casas, mas não se aproximam das portas. "
			+ "Podem pertencer a uma fera cautelosa, a um viajante ferido ou a alguém estudando nossas rotas."
		),
		"choices": [
			{
				"id": "patrulha_dupla",
				"text": "Dobrar as patrulhas e reforçar cercas. [Agora: -1 felicidade; 3 dias: -10% manutenção de material]",
				"result": "As rondas serão visíveis e as cercas serão verificadas antes do anoitecer. Talvez pareça severo, mas cada reparo antecipado custa menos do que reconstruir depois de um ataque.",
				"duration_days": 3,
				"immediate": {"happiness": -1.0},
				"modifiers": {"material_maintenance_multiplier": 0.90},
				"completion": "As patrulhas mapearam as pegadas e corrigiram pontos frágeis antes de qualquer invasão."
			},
			{
				"id": "rotas_seguras",
				"text": "Abrir rotas vigiadas para trabalhadores. [3 dias: +8% alimentação e material]",
				"result": "Em vez de fechar a vila, acompanharemos as equipes nos caminhos mais expostos. O trabalho continua, mas ninguém precisará escolher entre produzir e voltar vivo para casa.",
				"duration_days": 3,
				"immediate": {},
				"modifiers": {
					"food_production_multiplier": 1.08,
					"material_production_multiplier": 1.08
				},
				"completion": "As rotas vigiadas mantiveram as equipes em movimento e não registraram incidentes."
			},
			{
				"id": "vigilia_comunitaria",
				"text": "Organizar uma vigília comunitária. [Agora: -2 alimentação; 3 dias: +0,8 felicidade/dia]",
				"result": "Faremos turnos curtos, comida quente e sinais simples. A vigília não será um desfile de medo; será a prova de que ninguém precisa observar a escuridão sozinho.",
				"duration_days": 3,
				"immediate": {"food": -2.0},
				"modifiers": {"daily_happiness_bonus": 0.8},
				"completion": "A vigília terminou sem ataque e fortaleceu a confiança entre vizinhos."
			}
		]
	},
	{
		"id": "sino_sem_vento",
		"profession": Villager.Profession.GUARD,
		"title": "O SINO QUE TOCA SEM VENTO",
		"intro": (
			"O sino de alerta tocou três vezes durante a madrugada sem que ninguém puxasse a corda. "
			+ "Cada toque coincidiu com uma luz distante nas colinas."
		),
		"choices": [
			{
				"id": "postos_de_observacao",
				"text": "Erguer postos temporários de observação. [Agora: -4 material; 3 dias: -12% manutenção]",
				"result": "Dois postos simples bastam para cobrir as colinas e o caminho sul. Veremos qualquer movimento cedo o bastante para agir sem pânico.",
				"duration_days": 3,
				"immediate": {"material": -4.0},
				"modifiers": {"material_maintenance_multiplier": 0.88},
				"completion": "Os postos localizaram a origem das luzes e evitaram rondas desperdiçadas."
			},
			{
				"id": "seguir_luzes",
				"text": "Enviar uma equipe leve atrás das luzes. [Agora: -1 felicidade; 2 dias: +12% alimentação e material]",
				"result": "Iremos em silêncio, sem armaduras pesadas, e marcaremos uma rota de retorno. Se as luzes escondem perigo, saberemos; se escondem recursos, também.",
				"duration_days": 2,
				"immediate": {"happiness": -1.0},
				"modifiers": {
					"food_production_multiplier": 1.12,
					"material_production_multiplier": 1.12
				},
				"completion": "A equipe retornou com rotas mais seguras e pontos úteis marcados no mapa."
			},
			{
				"id": "acalmar_vila",
				"text": "Manter guardas discretos e acalmar a vila. [3 dias: +1 felicidade/dia]",
				"result": "A segurança continuará, mas sem transformar cada ruído em ameaça. Falarei com as famílias e deixarei as rondas acontecerem fora do centro das atenções.",
				"duration_days": 3,
				"immediate": {},
				"modifiers": {"daily_happiness_bonus": 1.0},
				"completion": "A vila atravessou as noites seguintes sem pânico, enquanto as rondas mantiveram o controle."
			}
		]
	},
	{
		"id": "bosque_oferece_caminho",
		"profession": Villager.Profession.GATHERER,
		"title": "O BOSQUE ABRIU UM CAMINHO NOVO",
		"intro": (
			"Uma trilha coberta de flores surgiu onde ontem havia mata fechada. "
			+ "Ela leva a árvores carregadas e pedras ricas em minério, mas desaparece ao anoitecer."
		),
		"choices": [
			{
				"id": "colheita_cuidadosa",
				"text": "Fazer uma coleta limitada e marcar o caminho. [Agora: +5 alimentação; 2 dias: +8% alimentação]",
				"result": "Traremos apenas o que podemos carregar sem ferir as árvores e deixaremos marcas que não dependem das flores. O bosque ofereceu uma chance, não uma licença para saqueá-lo.",
				"duration_days": 2,
				"immediate": {"food": 5.0},
				"modifiers": {"food_production_multiplier": 1.08},
				"completion": "A coleta limitada terminou e o caminho seguro foi registrado."
			},
			{
				"id": "mapear_recursos",
				"text": "Priorizar o mapeamento de tudo que existe na trilha. [3 dias: +10% alimentação e material]",
				"result": "Hoje voltaremos com menos nas mochilas e mais no mapa. Durante três dias, cada equipe saberá exatamente onde procurar e quanto retirar.",
				"duration_days": 3,
				"immediate": {},
				"modifiers": {
					"food_production_multiplier": 1.10,
					"material_production_multiplier": 1.10
				},
				"completion": "O mapa do novo caminho passou a orientar coletores e equipes de material."
			},
			{
				"id": "deixar_oferendas",
				"text": "Agradecer ao bosque antes de coletar. [Agora: -2 alimentação; 3 dias: +5% recursos e +0,6 felicidade/dia]",
				"result": "Deixaremos pão, água e sementes antes de tocar em qualquer fruto. Mesmo que o bosque não entenda oferendas, os moradores entenderão que prosperidade não precisa começar com ganância.",
				"duration_days": 3,
				"immediate": {"food": -2.0},
				"modifiers": {
					"food_production_multiplier": 1.05,
					"material_production_multiplier": 1.05,
					"daily_happiness_bonus": 0.6
				},
				"completion": "As oferendas foram respeitadas e o bosque continuou acessível nos dias seguintes."
			}
		]
	},
	{
		"id": "pedras_que_sussurram",
		"profession": Villager.Profession.GATHERER,
		"title": "PEDRAS QUE SUSSURRAM DIREÇÕES",
		"intro": (
			"Pequenas pedras encontradas junto ao rio sussurram nomes de lugares quando seguradas. "
			+ "Algumas indicam depósitos reais; outras parecem tentar afastar os coletores da vila."
		),
		"choices": [
			{
				"id": "testar_rotas",
				"text": "Testar cada direção com equipes pequenas. [3 dias: +8% material]",
				"result": "Nenhuma pedra guiará uma equipe inteira antes de provar que sabe para onde aponta. Faremos rotas curtas, compararemos mapas e manteremos sinais de retorno.",
				"duration_days": 3,
				"immediate": {},
				"modifiers": {"material_production_multiplier": 1.08},
				"completion": "As direções confiáveis foram separadas das armadilhas e adicionadas aos mapas."
			},
			{
				"id": "seguir_melhor_promessa",
				"text": "Seguir a direção que promete o maior depósito. [Agora: -2 felicidade; 2 dias: +22% material]",
				"result": "Escolheremos a voz mais consistente e iremos preparados para voltar depressa. É uma aposta, mas não uma aposta cega.",
				"duration_days": 2,
				"immediate": {"happiness": -2.0},
				"modifiers": {"material_production_multiplier": 1.22},
				"completion": "A expedição encontrou um veio útil e retornou antes que as pedras mudassem de direção."
			},
			{
				"id": "usar_como_guias",
				"text": "Distribuir as pedras como guias de curto alcance. [Agora: +2 material; 3 dias: +6% recursos e +0,4 felicidade/dia]",
				"result": "Cada equipe receberá uma pedra e uma regra: nunca confiar nela mais do que no próprio mapa. Assim aproveitamos a ajuda sem entregar o caminho inteiro a uma voz desconhecida.",
				"duration_days": 3,
				"immediate": {"material": 2.0},
				"modifiers": {
					"food_production_multiplier": 1.06,
					"material_production_multiplier": 1.06,
					"daily_happiness_bonus": 0.4
				},
				"completion": "As pedras serviram como guias auxiliares sem substituir os mapas da vila."
			}
		]
	},
	{
		"id": "talento_sem_destino",
		"profession": Villager.Profession.UNASSIGNED,
		"title": "UM TALENTO SEM TAREFA DEFINIDA",
		"intro": (
			"Há equipes pedindo ajuda ao mesmo tempo no celeiro, nas obras e na praça. "
			+ "Sem uma função fixa, esta carta pode assumir um esforço temporário onde a vila mais precisa."
		),
		"choices": [
			{
				"id": "ajudar_celeiro",
				"text": "Concentrar o esforço no celeiro. [2 dias: +14% alimentação]",
				"result": "Vou organizar recebimento, secagem e armazenamento. Talvez ainda não seja minha profissão, mas durante dois dias ninguém perderá uma cesta por falta de mãos.",
				"duration_days": 2,
				"immediate": {},
				"modifiers": {"food_production_multiplier": 1.14},
				"completion": "O reforço temporário evitou perdas e deixou o celeiro em ordem."
			},
			{
				"id": "ajudar_obras",
				"text": "Concentrar o esforço nas obras. [2 dias: +14% material]",
				"result": "Vou carregar, separar e registrar o material que chega. Não preciso dominar todas as ferramentas para impedir que metade do turno seja perdida procurando uma peça.",
				"duration_days": 2,
				"immediate": {},
				"modifiers": {"material_production_multiplier": 1.14},
				"completion": "O reforço temporário organizou as equipes e aumentou o rendimento das obras."
			},
			{
				"id": "ajudar_praca",
				"text": "Concentrar o esforço na praça. [2 dias: +1 felicidade/dia]",
				"result": "Vou ouvir pedidos, resolver filas e ajudar quem está passando de um balcão para outro sem resposta. Às vezes a vila precisa menos de uma especialidade e mais de alguém que permaneça presente.",
				"duration_days": 2,
				"immediate": {},
				"modifiers": {"daily_happiness_bonus": 1.0},
				"completion": "A presença constante na praça resolveu pequenas pendências e melhorou o ânimo."
			}
		]
	},
	{
		"id": "pedidos_cruzados",
		"profession": Villager.Profession.UNASSIGNED,
		"title": "TRÊS PEDIDOS, UM ÚNICO TURNO",
		"intro": (
			"Três equipes deixaram pedidos urgentes na mesma manhã. Atender todas superficialmente "
			+ "não resolverá nada; escolher uma prioridade pode destravar o restante da vila."
		),
		"choices": [
			{
				"id": "priorizar_reservas",
				"text": "Priorizar armazenamento e consumo. [3 dias: -7% consumo de alimentação]",
				"result": "Vou revisar perdas, porções e rotas entre cozinha e celeiro. Não produziremos mais comida, mas faremos cada unidade durar o que deveria.",
				"duration_days": 3,
				"immediate": {},
				"modifiers": {"food_consumption_multiplier": 0.93},
				"completion": "A revisão de reservas reduziu desperdícios e estabilizou o consumo."
			},
			{
				"id": "priorizar_manutencao",
				"text": "Priorizar reparos preventivos. [3 dias: -9% manutenção de material]",
				"result": "Vou acompanhar as equipes de reparo e resolver falhas pequenas antes que se tornem obras inteiras. O material economizado aparecerá nos dias seguintes.",
				"duration_days": 3,
				"immediate": {},
				"modifiers": {"material_maintenance_multiplier": 0.91},
				"completion": "Os reparos preventivos evitaram desperdício de material nas estruturas da vila."
			},
			{
				"id": "priorizar_moral",
				"text": "Priorizar conflitos entre equipes. [Agora: -2 material; 3 dias: +0,9 felicidade/dia]",
				"result": "Usaremos material para preparar um espaço neutro e reunir as equipes. O problema não é falta de trabalho; é gente trabalhando contra gente.",
				"duration_days": 3,
				"immediate": {"material": -2.0},
				"modifiers": {"daily_happiness_bonus": 0.9},
				"completion": "Os conflitos foram mediados e as equipes retomaram o trabalho com acordos claros."
			}
		]
	}
]


const PERSONALITY_COMMITMENTS: Dictionary = {
	"optimistic": "Vou fazer este caminho valer a confiança. Quando terminar, quero que a vila veja o que conseguimos construir a partir de uma escolha difícil.",
	"cautious": "Começarei pelos limites combinados e registrarei qualquer desvio. O projeto só vale a pena se conseguirmos encerrá-lo sem deixar um problema escondido.",
	"practical": "Está decidido. Vou dividir o trabalho por turnos, acompanhar os números e trazer um resultado que possa ser medido.",
	"ambitious": "Não pretendo entregar apenas o mínimo. Esta decisão precisa deixar a vila em posição melhor do que estava antes do problema aparecer.",
	"kind": "Vou explicar a decisão às equipes e ouvir quem será afetado. Um bom resultado não precisa transformar ninguém em custo invisível.",
	"stubborn": "Assumi a responsabilidade e não abandonarei o trabalho pela metade. Se surgir resistência, resolverei sem mudar o objetivo.",
	"playful": "Está bem, vou manter as piadas longe da parte perigosa. Quando tudo terminar, talvez o projeto mereça um nome menos solene.",
	"pessimistic": "Ainda vejo maneiras de isto dar errado. Justamente por isso, vou vigiar cada etapa e impedir que o pior cenário nos pegue desprevenidos."
}


const PERSONALITY_OPENINGS: Dictionary = {
	"optimistic": "Há risco, mas também uma oportunidade real. Prefiro decidir antes que a chance passe.",
	"cautious": "Não quero transformar curiosidade em prejuízo. Precisamos escolher um limite claro antes de agir.",
	"practical": "O problema já está afetando o trabalho. Trago três caminhos e as consequências de cada um.",
	"ambitious": "Se tratarmos isto apenas como inconveniente, perderemos uma vantagem que outra vila aproveitaria.",
	"kind": "A decisão mexerá com o trabalho e com as pessoas. Quero uma solução que não trate ninguém como peça descartável.",
	"stubborn": "Não vou fingir que o problema desaparecerá sozinho. Escolha um rumo e eu o levarei até o fim.",
	"playful": "A situação seria engraçada se não estivesse prestes a custar recursos. Ainda pode terminar numa boa história.",
	"pessimistic": "Nenhuma opção é gratuita. Pelo menos podemos escolher qual preço estamos dispostos a pagar."
}


static func get_templates_for_profession(profession: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for template: Dictionary in OPPORTUNITIES:
		if int(template.get("profession", Villager.Profession.UNASSIGNED)) == profession:
			result.append(template.duplicate(true))
	if result.is_empty() and profession != Villager.Profession.UNASSIGNED:
		return get_templates_for_profession(Villager.Profession.UNASSIGNED)
	return result


static func get_template(template_id: String) -> Dictionary:
	var clean_id: String = template_id.strip_edges()
	for template: Dictionary in OPPORTUNITIES:
		if String(template.get("id", "")) == clean_id:
			return template.duplicate(true)
	return {}


static func get_choice(template_id: String, choice_id: String) -> Dictionary:
	var template: Dictionary = get_template(template_id)
	var choices_value: Variant = template.get("choices", [])
	if not choices_value is Array:
		return {}
	for choice_value: Variant in choices_value as Array:
		if not choice_value is Dictionary:
			continue
		var choice: Dictionary = choice_value as Dictionary
		if String(choice.get("id", "")) == choice_id:
			return choice.duplicate(true)
	return {}


static func get_personality_commitment(personality_id: String) -> String:
	return String(
		PERSONALITY_COMMITMENTS.get(
			personality_id,
			PERSONALITY_COMMITMENTS.get(
				"practical",
				"Vou acompanhar o projeto até a conclusão."
			)
		)
	)


static func get_personality_opening(personality_id: String) -> String:
	return String(
		PERSONALITY_OPENINGS.get(
			personality_id,
			PERSONALITY_OPENINGS.get("practical", "Precisamos decidir.")
		)
	)


static func validate_catalog() -> Array[String]:
	var errors: Array[String] = []
	var ids: Dictionary = {}
	var profession_counts: Dictionary = {}
	for template: Dictionary in OPPORTUNITIES:
		var template_id: String = String(template.get("id", "")).strip_edges()
		if template_id.is_empty():
			errors.append("Oportunidade sem ID.")
		elif ids.has(template_id):
			errors.append("Oportunidade duplicada: %s." % template_id)
		else:
			ids[template_id] = true
		var profession: int = int(
			template.get("profession", Villager.Profession.UNASSIGNED)
		)
		profession_counts[profession] = int(profession_counts.get(profession, 0)) + 1
		if String(template.get("title", "")).strip_edges().is_empty():
			errors.append("%s não possui título." % template_id)
		if String(template.get("intro", "")).strip_edges().is_empty():
			errors.append("%s não possui introdução." % template_id)
		var choices_value: Variant = template.get("choices", [])
		if not choices_value is Array or (choices_value as Array).size() != 3:
			errors.append("%s precisa de três escolhas." % template_id)
			continue
		var choice_ids: Dictionary = {}
		for choice_value: Variant in choices_value as Array:
			if not choice_value is Dictionary:
				errors.append("%s possui escolha inválida." % template_id)
				continue
			var choice: Dictionary = choice_value as Dictionary
			var choice_id: String = String(choice.get("id", "")).strip_edges()
			if choice_id.is_empty() or choice_ids.has(choice_id):
				errors.append("%s possui escolha sem ID único." % template_id)
			else:
				choice_ids[choice_id] = true
			var duration: int = int(choice.get("duration_days", 0))
			if duration < 2 or duration > 3:
				errors.append("%s/%s precisa durar 2 ou 3 dias." % [template_id, choice_id])
			if String(choice.get("text", "")).strip_edges().is_empty():
				errors.append("%s/%s não possui texto de decisão." % [template_id, choice_id])
			if String(choice.get("result", "")).strip_edges().is_empty():
				errors.append("%s/%s não possui reação do representante." % [template_id, choice_id])
			if String(choice.get("completion", "")).strip_edges().is_empty():
				errors.append("%s/%s não possui encerramento do projeto." % [template_id, choice_id])
			var immediate_value: Variant = choice.get("immediate", null)
			var modifiers_value: Variant = choice.get("modifiers", null)
			if not immediate_value is Dictionary:
				errors.append("%s/%s não possui efeito imediato válido." % [template_id, choice_id])
			if not modifiers_value is Dictionary:
				errors.append("%s/%s não possui modificadores válidos." % [template_id, choice_id])
			elif (modifiers_value as Dictionary).is_empty():
				errors.append("%s/%s não altera a vila durante o projeto." % [template_id, choice_id])
	for profession: int in range(
		Villager.Profession.UNASSIGNED,
		Villager.Profession.GATHERER + 1
	):
		if int(profession_counts.get(profession, 0)) < 2:
			errors.append("Profissão %d possui menos de duas oportunidades." % profession)
	return errors
