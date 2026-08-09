class_name VillageMagicalEventCatalog
extends RefCounted


static func create() -> Array[Dictionary]:
	return [
		{
			"id": "mana_mist",
			"title": "NÉVOA DE MANA",
			"description": "Uma névoa azul cobre os caminhos. As pegadas brilham e pequenos sinos tocam sem vento.",
			"min_day": 2,
			"choices": [
				{
					"id": "mana_mist_study",
					"title": "Mapear as correntes mágicas",
					"description": "Teste de Inteligência. Pode revelar uma rota fértil.",
					"requires_villager": true,
					"test_attribute": "intelligence",
					"base_chance": 0.28,
					"chance_per_point": 0.07,
					"min_chance": 0.28,
					"max_chance": 0.95,
					"success_effects": {"food": 6.0, "material": 3.0},
					"failure_effects": {"happiness": -3.0},
					"success_text": "identificou veios de mana que aceleraram a coleta e o cultivo.",
					"failure_text": "seguiu um eco ilusório e a equipe voltou desorientada."
				},
				{
					"id": "mana_mist_lanterns",
					"title": "Acender lanternas de sal",
					"description": "Custo: 3 materiais. Ganha 3 felicidade.",
					"costs": {"material": 3.0},
					"effects": {"happiness": 3.0},
					"result_text": "As lanternas abriram corredores seguros na névoa encantada."
				},
				{
					"id": "mana_mist_wait",
					"title": "Esperar a névoa passar",
					"description": "Solução segura. Perde 2 felicidade.",
					"effects": {"happiness": -2.0},
					"result_text": "A vila permaneceu dentro de casa até o brilho desaparecer."
				}
			]
		},
		{
			"id": "moonlit_mandrakes",
			"title": "MANDRÁGORAS AO LUAR",
			"description": "Raízes com rostinhos surgiram na horta e começaram a cantar uma canção desafinada para a lua.",
			"min_day": 3,
			"choices": [
				{
					"id": "mandrakes_harvest",
					"title": "Colher com protetores de ouvido",
					"description": "Teste de Agilidade. Pode render muito alimento.",
					"requires_villager": true,
					"test_attribute": "agility",
					"base_chance": 0.30,
					"chance_per_point": 0.065,
					"min_chance": 0.30,
					"max_chance": 0.92,
					"success_effects": {"food": 10.0},
					"failure_effects": {"happiness": -5.0},
					"success_text": "colheu as raízes sem ouvir o grito hipnótico.",
					"failure_text": "tropeçou durante o coro e metade da vila passou a cantar junto."
				},
				{
					"id": "mandrakes_transplant",
					"title": "Transplantar para longe",
					"description": "Custo: 2 materiais. Evita riscos.",
					"costs": {"material": 2.0},
					"effects": {"happiness": 1.0},
					"result_text": "As mandrágoras ganharam um canteiro distante e a vila voltou a dormir."
				},
				{
					"id": "mandrakes_concert",
					"title": "Transformar em apresentação",
					"description": "Custo: 3 alimentos. Ganha 6 felicidade.",
					"costs": {"food": 3.0},
					"effects": {"happiness": 6.0},
					"result_text": "O pior concerto da estação virou a melhor história da semana."
				}
			]
		},
		{
			"id": "wandering_spellbook",
			"title": "GRIMÓRIO FUGITIVO",
			"description": "Um livro com pernas corre pela praça, recitando feitiços domésticos e insultando a caligrafia dos moradores.",
			"min_day": 4,
			"choices": [
				{
					"id": "spellbook_capture",
					"title": "Capturar o grimório",
					"description": "Teste de Agilidade. Pode ensinar um encantamento útil.",
					"requires_villager": true,
					"test_attribute": "agility",
					"base_chance": 0.25,
					"chance_per_point": 0.07,
					"min_chance": 0.25,
					"max_chance": 0.95,
					"success_effects": {"material": 7.0},
					"failure_effects": {"happiness": -3.0},
					"success_text": "prendeu o livro com uma fita rúnica e copiou um feitiço de reparo.",
					"failure_text": "foi atingido por um encanto que fez suas botas discutirem entre si."
				},
				{
					"id": "spellbook_bargain",
					"title": "Negociar com educação",
					"description": "Teste de Carisma. O livro aprecia elogios acadêmicos.",
					"requires_villager": true,
					"test_attribute": "charisma",
					"base_chance": 0.30,
					"chance_per_point": 0.065,
					"min_chance": 0.30,
					"max_chance": 0.90,
					"success_effects": {"happiness": 5.0, "material": 3.0},
					"failure_effects": {"happiness": -2.0},
					"success_text": "convenceu o grimório a compartilhar dois capítulos e uma fofoca arcana.",
					"failure_text": "foi chamado de analfabeto decorativo e o livro fugiu."
				},
				{
					"id": "spellbook_ignore",
					"title": "Deixar o livro partir",
					"description": "Sem custo nem recompensa.",
					"effects": {},
					"result_text": "O grimório desapareceu pela estrada, ainda reclamando de pontuação."
				}
			]
		},
		{
			"id": "tiny_dragon_roost",
			"title": "NINHO DE DRAGÃOZINHO",
			"description": "Um pequeno dragão fez ninho na chaminé do celeiro e aquece os grãos sempre que espirra.",
			"min_day": 5,
			"choices": [
				{
					"id": "dragon_tame",
					"title": "Amansar com comida",
					"description": "Custo: 5 alimentos. Ganha 6 felicidade.",
					"costs": {"food": 5.0},
					"effects": {"happiness": 6.0},
					"result_text": "O dragãozinho aceitou um cesto e passou a dormir perto do forno."
				},
				{
					"id": "dragon_move",
					"title": "Mover o ninho com cuidado",
					"description": "Teste de Força. Pode evitar incêndios.",
					"requires_villager": true,
					"test_attribute": "strength",
					"base_chance": 0.28,
					"chance_per_point": 0.065,
					"min_chance": 0.28,
					"max_chance": 0.92,
					"success_effects": {"material": 4.0},
					"failure_effects": {"food": -5.0, "material": -2.0},
					"success_text": "moveu o ninho para uma torre de pedra sem acordar a criatura.",
					"failure_text": "acordou o filhote, que tostou sacos e uma sobrancelha."
				},
				{
					"id": "dragon_smoke",
					"title": "Aceitar a fumaça por enquanto",
					"description": "Perde 3 alimentos.",
					"effects": {"food": -3.0},
					"result_text": "Os grãos ficaram defumados. Alguns moradores juram que melhorou o sabor."
				}
			]
		},
		{
			"id": "fairy_toll",
			"title": "PEDÁGIO DAS FADAS",
			"description": "Fadas minúsculas ergueram uma cancela de galhos e cobram uma moeda imaginária de quem passa.",
			"min_day": 6,
			"choices": [
				{
					"id": "fairy_negotiate",
					"title": "Negociar o pedágio",
					"description": "Teste de Carisma.",
					"requires_villager": true,
					"test_attribute": "charisma",
					"base_chance": 0.28,
					"chance_per_point": 0.07,
					"min_chance": 0.28,
					"max_chance": 0.95,
					"success_effects": {"happiness": 5.0},
					"failure_effects": {"material": -3.0},
					"success_text": "convenceu as fadas a aceitar canções e elogios como pagamento.",
					"failure_text": "assinou sem perceber um contrato que transformou três tábuas em confete."
				},
				{
					"id": "fairy_offer",
					"title": "Oferecer mel e frutas",
					"description": "Custo: 4 alimentos. Ganha 4 felicidade.",
					"costs": {"food": 4.0},
					"effects": {"happiness": 4.0},
					"result_text": "As fadas aceitaram o tributo e abençoaram o caminho com luzes suaves."
				},
				{
					"id": "fairy_detour",
					"title": "Abrir um desvio",
					"description": "Custo: 3 materiais.",
					"costs": {"material": 3.0},
					"effects": {},
					"result_text": "Um novo caminho contornou a cancela feérica. As fadas pareceram ofendidas."
				}
			]
		},
		{
			"id": "enchanted_well_echo",
			"title": "ECO ENCANTADO NO POÇO",
			"description": "O poço começou a responder perguntas com uma voz antiga, mas só fala em enigmas rimados.",
			"min_day": 7,
			"choices": [
				{
					"id": "well_ask_harvest",
					"title": "Perguntar sobre a próxima colheita",
					"description": "Teste de Inteligência para interpretar a resposta.",
					"requires_villager": true,
					"test_attribute": "intelligence",
					"base_chance": 0.30,
					"chance_per_point": 0.065,
					"min_chance": 0.30,
					"max_chance": 0.92,
					"success_effects": {"food": 8.0},
					"failure_effects": {"food": -3.0},
					"success_text": "decifrou o enigma e antecipou o melhor momento da colheita.",
					"failure_text": "confundiu 'plantar cedo' com 'plantar cedro' e perdeu tempo."
				},
				{
					"id": "well_ask_treasure",
					"title": "Perguntar sobre tesouros",
					"description": "50% de chance de encontrar material ou perder felicidade.",
					"base_chance": 0.50,
					"min_chance": 0.50,
					"max_chance": 0.50,
					"success_effects": {"material": 7.0},
					"failure_effects": {"happiness": -4.0},
					"success_text": "o eco indicou pedras rúnicas escondidas sob uma raiz.",
					"failure_text": "o eco respondeu apenas 'o verdadeiro tesouro era a paciência'."
				},
				{
					"id": "well_cover",
					"title": "Cobrir o poço à noite",
					"description": "Custo: 2 materiais.",
					"costs": {"material": 2.0},
					"effects": {"happiness": 1.0},
					"result_text": "A tampa abafou os enigmas e devolveu silêncio às casas próximas."
				}
			]
		},
		{
			"id": "stone_golem_awakens",
			"title": "GOLEM DA PEDREIRA",
			"description": "Uma pilha de rochas se levantou, espreguiçou-se e perguntou educadamente quem administra o território.",
			"min_day": 8,
			"choices": [
				{
					"id": "golem_welcome",
					"title": "Receber o golem como visitante",
					"description": "Custo: 3 alimentos. Ganha material e felicidade.",
					"costs": {"food": 3.0},
					"effects": {"material": 6.0, "happiness": 3.0},
					"result_text": "O golem ajudou a mover pedras e elogiou a administração do Prefeito."
				},
				{
					"id": "golem_debate",
					"title": "Debater leis de território",
					"description": "Teste de Inteligência.",
					"requires_villager": true,
					"test_attribute": "intelligence",
					"base_chance": 0.28,
					"chance_per_point": 0.07,
					"min_chance": 0.28,
					"max_chance": 0.95,
					"success_effects": {"material": 8.0},
					"failure_effects": {"happiness": -3.0},
					"success_text": "provou que a pedreira faz parte da vila e recebeu ajuda voluntária.",
					"failure_text": "perdeu o debate para uma pedra com memória jurídica milenar."
				},
				{
					"id": "golem_redirect",
					"title": "Indicar uma montanha distante",
					"description": "Sem custo. Perde 1 felicidade.",
					"effects": {"happiness": -1.0},
					"result_text": "O golem partiu em silêncio, claramente decepcionado com a hospitalidade."
				}
			]
		},
		{
			"id": "witch_broom_delivery",
			"title": "ENTREGA DE VASSOURA",
			"description": "Uma vassoura voadora pousou na praça com uma encomenda endereçada a 'Prefeito Pedregulho, Reino dos Gatos'.",
			"min_day": 9,
			"choices": [
				{
					"id": "broom_open",
					"title": "Abrir a encomenda",
					"description": "Pode conter suprimentos ou uma maldição inconveniente.",
					"base_chance": 0.65,
					"min_chance": 0.65,
					"max_chance": 0.65,
					"success_effects": {"food": 5.0, "material": 5.0},
					"failure_effects": {"happiness": -5.0},
					"success_text": "a caixa continha chá, ferramentas e um bilhete de boa sorte.",
					"failure_text": "a caixa soltou um encanto que fez todos falarem em rimas por horas."
				},
				{
					"id": "broom_inspect",
					"title": "Examinar os selos mágicos",
					"description": "Teste de Inteligência.",
					"requires_villager": true,
					"test_attribute": "intelligence",
					"base_chance": 0.32,
					"chance_per_point": 0.065,
					"min_chance": 0.32,
					"max_chance": 0.95,
					"success_effects": {"material": 6.0, "happiness": 2.0},
					"failure_effects": {"material": -2.0},
					"success_text": "removeu uma runa de trote antes de abrir a encomenda.",
					"failure_text": "ativou um feitiço que colou a embalagem em suas mãos."
				},
				{
					"id": "broom_return",
					"title": "Mandar de volta",
					"description": "Solução segura.",
					"effects": {},
					"result_text": "A vassoura partiu com a caixa ainda lacrada."
				}
			]
		},
		{
			"id": "crystal_rain",
			"title": "CHUVA DE CRISTAIS",
			"description": "Pequenos cristais coloridos caem das nuvens e tilintam sobre os telhados sem quebrá-los.",
			"min_day": 10,
			"choices": [
				{
					"id": "crystal_collect",
					"title": "Coletar os cristais",
					"description": "Teste de Agilidade.",
					"requires_villager": true,
					"test_attribute": "agility",
					"base_chance": 0.30,
					"chance_per_point": 0.065,
					"min_chance": 0.30,
					"max_chance": 0.94,
					"success_effects": {"material": 10.0},
					"failure_effects": {"happiness": -3.0},
					"success_text": "recolheu uma boa quantidade antes que os cristais evaporassem.",
					"failure_text": "escorregou no brilho e a maioria dos fragmentos desapareceu."
				},
				{
					"id": "crystal_festival",
					"title": "Celebrar sob a chuva",
					"description": "Custo: 3 alimentos. Ganha 7 felicidade.",
					"costs": {"food": 3.0},
					"effects": {"happiness": 7.0},
					"result_text": "A praça brilhou como um céu invertido e todos dançaram."
				},
				{
					"id": "crystal_shelter",
					"title": "Manter todos abrigados",
					"description": "Perde 1 felicidade.",
					"effects": {"happiness": -1.0},
					"result_text": "A vila observou a chuva pela janela e evitou qualquer risco."
				}
			]
		},
		{
			"id": "ghostly_bard",
			"title": "BARDO FANTASMA",
			"description": "Um músico transparente surgiu na praça e afirma que só poderá partir após receber aplausos sinceros.",
			"min_day": 11,
			"choices": [
				{
					"id": "bard_concert",
					"title": "Organizar um concerto",
					"description": "Custo: 4 alimentos. Ganha 8 felicidade.",
					"costs": {"food": 4.0},
					"effects": {"happiness": 8.0},
					"result_text": "O bardo recebeu uma ovação, fez uma reverência e atravessou a lua."
				},
				{
					"id": "bard_accompany",
					"title": "Acompanhar a melodia",
					"description": "Teste de Carisma.",
					"requires_villager": true,
					"test_attribute": "charisma",
					"base_chance": 0.28,
					"chance_per_point": 0.07,
					"min_chance": 0.28,
					"max_chance": 0.95,
					"success_effects": {"happiness": 7.0},
					"failure_effects": {"happiness": -4.0},
					"success_text": "transformou a canção em um dueto inesquecível.",
					"failure_text": "entrou no tom errado e prolongou a maldição por mais uma noite."
				},
				{
					"id": "bard_ignore",
					"title": "Ignorar a apresentação",
					"description": "Perde 3 felicidade.",
					"effects": {"happiness": -3.0},
					"result_text": "O bardo tocou a mesma balada triste até o amanhecer."
				}
			]
		},
		{
			"id": "rune_sheep",
			"title": "OVELHAS RÚNICAS",
			"description": "Um rebanho coberto de símbolos luminosos atravessou os campos. A lã crepita com magia estática.",
			"min_day": 12,
			"choices": [
				{
					"id": "rune_sheep_shear",
					"title": "Tosquiar com cuidado",
					"description": "Teste de Agilidade. Pode render material encantado.",
					"requires_villager": true,
					"test_attribute": "agility",
					"base_chance": 0.28,
					"chance_per_point": 0.07,
					"min_chance": 0.28,
					"max_chance": 0.95,
					"success_effects": {"material": 9.0},
					"failure_effects": {"happiness": -4.0},
					"success_text": "recolheu lã rúnica sem levar nenhum choque sério.",
					"failure_text": "assustou o rebanho e recebeu uma descarga coletiva."
				},
				{
					"id": "rune_sheep_feed",
					"title": "Alimentar o rebanho",
					"description": "Custo: 4 alimentos. Ganha 5 felicidade.",
					"costs": {"food": 4.0},
					"effects": {"happiness": 5.0},
					"result_text": "As ovelhas passaram a noite nos campos e iluminaram a vila como lanternas."
				},
				{
					"id": "rune_sheep_guide",
					"title": "Guiar o rebanho adiante",
					"description": "Sem custo.",
					"effects": {},
					"result_text": "O rebanho seguiu pela estrada deixando faíscas azuis na poeira."
				}
			]
		},
		{
			"id": "mimic_chest",
			"title": "BAÚ COM DENTES",
			"description": "Um baú apareceu junto à muralha. Ele ronrona quando recebe moedas e rosna quando alguém menciona impostos.",
			"min_day": 13,
			"choices": [
				{
					"id": "mimic_feed",
					"title": "Alimentar o mímico",
					"description": "Custo: 3 alimentos. Pode cuspir tesouros.",
					"costs": {"food": 3.0},
					"base_chance": 0.70,
					"min_chance": 0.70,
					"max_chance": 0.70,
					"success_effects": {"material": 8.0},
					"failure_effects": {"happiness": -3.0},
					"success_text": "o mímico arrotou moedas antigas e uma colher de prata.",
					"failure_text": "o mímico comeu tudo e fingiu estar dormindo."
				},
				{
					"id": "mimic_tame",
					"title": "Treinar como guardião",
					"description": "Teste de Carisma.",
					"requires_villager": true,
					"test_attribute": "charisma",
					"base_chance": 0.25,
					"chance_per_point": 0.07,
					"min_chance": 0.25,
					"max_chance": 0.92,
					"success_effects": {"happiness": 5.0, "material": 3.0},
					"failure_effects": {"material": -4.0},
					"success_text": "ensinou o mímico a morder apenas ladrões e formulários atrasados.",
					"failure_text": "perdeu duas ferramentas durante uma aula de obediência."
				},
				{
					"id": "mimic_chase",
					"title": "Expulsar o baú",
					"description": "Teste de Força.",
					"requires_villager": true,
					"test_attribute": "strength",
					"base_chance": 0.32,
					"chance_per_point": 0.06,
					"min_chance": 0.32,
					"max_chance": 0.90,
					"success_effects": {"happiness": 2.0},
					"failure_effects": {"happiness": -4.0},
					"success_text": "empurrou o mímico para fora da vila.",
					"failure_text": "foi perseguido pelo baú em círculos pela praça."
				}
			]
		},
		{
			"id": "portal_in_pantry",
			"title": "PORTAL NA DESPENSA",
			"description": "Uma porta violeta surgiu atrás dos sacos de farinha. Do outro lado há estrelas, vento e cheiro de canela.",
			"min_day": 14,
			"choices": [
				{
					"id": "portal_explore",
					"title": "Explorar com uma corda",
					"description": "Teste de Agilidade.",
					"requires_villager": true,
					"test_attribute": "agility",
					"base_chance": 0.25,
					"chance_per_point": 0.07,
					"min_chance": 0.25,
					"max_chance": 0.93,
					"success_effects": {"food": 7.0, "material": 5.0},
					"failure_effects": {"food": -4.0, "happiness": -3.0},
					"success_text": "retornou com frutas estelares e madeira leve como ar.",
					"failure_text": "voltou coberto de poeira cósmica e sem alguns mantimentos."
				},
				{
					"id": "portal_stabilize",
					"title": "Estabilizar as bordas",
					"description": "Custo: 5 materiais. Ganha 4 felicidade.",
					"costs": {"material": 5.0},
					"effects": {"happiness": 4.0},
					"result_text": "Runas de contenção tornaram o portal seguro para observação."
				},
				{
					"id": "portal_seal",
					"title": "Selar imediatamente",
					"description": "Custo: 2 materiais.",
					"costs": {"material": 2.0},
					"effects": {},
					"result_text": "A porta desapareceu com um suspiro e deixou apenas cheiro de canela."
				}
			]
		},
		{
			"id": "phoenix_feather",
			"title": "PENA DE FÊNIX",
			"description": "Uma pena flamejante caiu no centro da praça. Ela aquece sem queimar e pulsa como um coração.",
			"min_day": 15,
			"choices": [
				{
					"id": "phoenix_preserve",
					"title": "Guardar em urna de pedra",
					"description": "Custo: 4 materiais. Ganha 5 felicidade.",
					"costs": {"material": 4.0},
					"effects": {"happiness": 5.0},
					"result_text": "A pena virou um símbolo de esperança para a vila."
				},
				{
					"id": "phoenix_use_heat",
					"title": "Usar o calor na produção",
					"description": "Teste de Inteligência.",
					"requires_villager": true,
					"test_attribute": "intelligence",
					"base_chance": 0.30,
					"chance_per_point": 0.065,
					"min_chance": 0.30,
					"max_chance": 0.94,
					"success_effects": {"food": 6.0, "material": 6.0},
					"failure_effects": {"food": -5.0},
					"success_text": "canalizou o calor para secar grãos e endurecer peças.",
					"failure_text": "superaqueceu a oficina e tostou parte das reservas."
				},
				{
					"id": "phoenix_release",
					"title": "Deixar a pena seguir o vento",
					"description": "Ganha 2 felicidade.",
					"effects": {"happiness": 2.0},
					"result_text": "A pena subiu aos céus e desenhou um pássaro de fogo entre as nuvens."
				}
			]
		},
		{
			"id": "sleepy_ogre",
			"title": "OGRO SONOLENTO",
			"description": "Um ogro adormeceu atravessado na estrada. Seu ronco sacode placas e faz maçãs caírem das árvores.",
			"min_day": 16,
			"choices": [
				{
					"id": "ogre_wake",
					"title": "Acordar com cuidado",
					"description": "Teste de Carisma.",
					"requires_villager": true,
					"test_attribute": "charisma",
					"base_chance": 0.30,
					"chance_per_point": 0.065,
					"min_chance": 0.30,
					"max_chance": 0.94,
					"success_effects": {"material": 7.0},
					"failure_effects": {"happiness": -4.0},
					"success_text": "acordou o ogro, que pediu desculpas e moveu troncos para a vila.",
					"failure_text": "recebeu um rugido tão forte que todos perderam o sono."
				},
				{
					"id": "ogre_feed",
					"title": "Preparar um café da manhã gigante",
					"description": "Custo: 7 alimentos. Ganha material e felicidade.",
					"costs": {"food": 7.0},
					"effects": {"material": 5.0, "happiness": 4.0},
					"result_text": "O ogro acordou feliz, comeu e ajudou a liberar a estrada."
				},
				{
					"id": "ogre_detour",
					"title": "Abrir um caminho ao redor",
					"description": "Custo: 4 materiais.",
					"costs": {"material": 4.0},
					"effects": {},
					"result_text": "O tráfego contornou o ogro sem interromper seu cochilo."
				}
			]
		},
		{
			"id": "talking_mushrooms",
			"title": "COGUMELOS CONSELHEIROS",
			"description": "Cogumelos falantes cresceram perto da praça e oferecem conselhos administrativos contraditórios.",
			"min_day": 17,
			"choices": [
				{
					"id": "mushrooms_listen",
					"title": "Ouvir o conselho completo",
					"description": "Teste de Inteligência para separar sabedoria de bobagem.",
					"requires_villager": true,
					"test_attribute": "intelligence",
					"base_chance": 0.30,
					"chance_per_point": 0.065,
					"min_chance": 0.30,
					"max_chance": 0.94,
					"success_effects": {"food": 5.0, "happiness": 3.0},
					"failure_effects": {"material": -3.0},
					"success_text": "descobriu uma técnica de cultivo útil entre horas de discursos.",
					"failure_text": "seguiu a sugestão de construir uma ponte vertical."
				},
				{
					"id": "mushrooms_comedy",
					"title": "Transformar em espetáculo",
					"description": "Ganha 5 felicidade.",
					"effects": {"happiness": 5.0},
					"result_text": "Os cogumelos viraram a atração mais discutida da praça."
				},
				{
					"id": "mushrooms_remove",
					"title": "Remover antes que votem",
					"description": "Ganha 3 alimentos, perde 2 felicidade.",
					"effects": {"food": 3.0, "happiness": -2.0},
					"result_text": "A reunião terminou na panela, para indignação dos cogumelos."
				}
			]
		},
		{
			"id": "spring_unicorn_tracks",
			"title": "PEGADAS DE UNICÓRNIO",
			"description": "Pegadas prateadas surgiram entre as flores da primavera e fazem brotos nascerem onde tocam.",
			"min_day": 2,
			"season_id": "spring",
			"choices": [
				{
					"id": "unicorn_follow",
					"title": "Seguir as pegadas",
					"description": "Teste de Agilidade.",
					"requires_villager": true,
					"test_attribute": "agility",
					"base_chance": 0.30,
					"chance_per_point": 0.065,
					"min_chance": 0.30,
					"max_chance": 0.94,
					"success_effects": {"food": 9.0, "happiness": 3.0},
					"failure_effects": {"happiness": -2.0},
					"success_text": "encontrou um bosque abençoado e colheu frutos sem ferir a criatura.",
					"failure_text": "perdeu a trilha em um círculo de flores encantadas."
				},
				{
					"id": "unicorn_protect",
					"title": "Proteger a trilha",
					"description": "Custo: 2 materiais. Ganha 4 felicidade.",
					"costs": {"material": 2.0},
					"effects": {"happiness": 4.0},
					"result_text": "A área foi preservada e virou um pequeno santuário da primavera."
				},
				{
					"id": "unicorn_harvest",
					"title": "Colher apenas os novos brotos",
					"description": "Ganha 5 alimentos.",
					"effects": {"food": 5.0},
					"result_text": "A vila colheu com cuidado e deixou as pegadas intactas."
				}
			]
		},
		{
			"id": "summer_salamander_furnace",
			"title": "SALAMANDRAS NA FORJA",
			"description": "Salamandras de fogo ocuparam a serraria e aquecem as lâminas com pequenas labaredas felizes.",
			"min_day": 31,
			"season_id": "summer",
			"choices": [
				{
					"id": "salamander_cooperate",
					"title": "Trabalhar com as salamandras",
					"description": "Teste de Inteligência.",
					"requires_villager": true,
					"test_attribute": "intelligence",
					"base_chance": 0.30,
					"chance_per_point": 0.065,
					"min_chance": 0.30,
					"max_chance": 0.94,
					"success_effects": {"material": 11.0},
					"failure_effects": {"material": -4.0},
					"success_text": "organizou o calor e produziu peças de excelente qualidade.",
					"failure_text": "superaqueceu as bancadas e perdeu parte do estoque."
				},
				{
					"id": "salamander_feed_coal",
					"title": "Oferecer carvão e minerais",
					"description": "Custo: 3 materiais. Ganha 6 felicidade.",
					"costs": {"material": 3.0},
					"effects": {"happiness": 6.0},
					"result_text": "As salamandras fizeram desenhos de fogo para as crianças."
				},
				{
					"id": "salamander_cool",
					"title": "Resfriar a oficina",
					"description": "Custo: 2 materiais.",
					"costs": {"material": 2.0},
					"effects": {},
					"result_text": "Baldes e placas frias convenceram as criaturas a procurar outro abrigo."
				}
			]
		},
		{
			"id": "autumn_witch_market",
			"title": "MERCADO DAS BRUXAS",
			"description": "Barracas aparecem entre as folhas do outono vendendo poções, vassouras e compotas que piscam.",
			"min_day": 61,
			"season_id": "autumn",
			"choices": [
				{
					"id": "witch_market_trade",
					"title": "Trocar alimentos por relíquias",
					"description": "Custo: 6 alimentos. Ganha 9 materiais.",
					"costs": {"food": 6.0},
					"effects": {"material": 9.0},
					"result_text": "A vila recebeu ferramentas encantadas e uma chaleira que prevê chuva."
				},
				{
					"id": "witch_market_negotiate",
					"title": "Negociar uma licença temporária",
					"description": "Teste de Carisma.",
					"requires_villager": true,
					"test_attribute": "charisma",
					"base_chance": 0.30,
					"chance_per_point": 0.065,
					"min_chance": 0.30,
					"max_chance": 0.94,
					"success_effects": {"happiness": 7.0, "material": 4.0},
					"failure_effects": {"food": -4.0},
					"success_text": "garantiu uma feira ordeira e recebeu taxas em ingredientes raros.",
					"failure_text": "aceitou uma cláusula escrita em fumaça e perdeu provisões."
				},
				{
					"id": "witch_market_close",
					"title": "Pedir que sigam viagem",
					"description": "Perde 2 felicidade.",
					"effects": {"happiness": -2.0},
					"result_text": "As barracas desapareceram numa nuvem roxa antes do anoitecer."
				}
			]
		},
		{
			"id": "winter_frost_spirit",
			"title": "ESPÍRITO DA GEADA",
			"description": "Uma figura feita de neve pede abrigo e promete proteger a vila das tempestades de inverno.",
			"min_day": 91,
			"season_id": "winter",
			"choices": [
				{
					"id": "frost_spirit_welcome",
					"title": "Preparar um santuário frio",
					"description": "Custo: 5 materiais. Ganha felicidade.",
					"costs": {"material": 5.0},
					"effects": {"happiness": 7.0},
					"result_text": "O espírito aceitou o santuário e fez a neve contornar os telhados."
				},
				{
					"id": "frost_spirit_bargain",
					"title": "Negociar uma bênção",
					"description": "Teste de Carisma.",
					"requires_villager": true,
					"test_attribute": "charisma",
					"base_chance": 0.28,
					"chance_per_point": 0.07,
					"min_chance": 0.28,
					"max_chance": 0.94,
					"success_effects": {"food": 6.0, "happiness": 4.0},
					"failure_effects": {"happiness": -4.0},
					"success_text": "obteve uma bênção que conservou alimentos no frio.",
					"failure_text": "ofendeu o espírito ao chamar neve de lama elegante."
				},
				{
					"id": "frost_spirit_decline",
					"title": "Recusar com respeito",
					"description": "Sem custo.",
					"effects": {},
					"result_text": "O espírito inclinou a cabeça e desapareceu entre os flocos."
				}
			]
		}
	]
