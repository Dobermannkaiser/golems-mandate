class_name VillageEventCatalog
extends RefCounted


const MAGICAL_EVENT_CATALOG_SCRIPT = preload(
	"res://scripts/events/MagicalEventCatalog.gd"
)
const BUILDING_VARIANT_EVENT_CATALOG_SCRIPT = preload(
	"res://scripts/events/BuildingVariantEventCatalog.gd"
)


static func create() -> Array[Dictionary]:
	var events: Array[Dictionary] = []

	events.append({
		"id": "barn_storm",
		"title": "TEMPESTADE RÚNICA NO CELEIRO",
		"description": (
			"O vento arrancou parte do telhado do celeiro. "
			+ "A chuva ameaça a alimentação armazenada."
		),
		"min_day": 1,
		"choices": [
			{
				"id": "repair_barn",
				"title": "Consertar imediatamente",
				"description": (
					"Custo: 6 materiais. Solução garantida."
				),
				"costs": {"material": 6.0},
				"effects": {"happiness": 2.0},
				"result_text": (
					"O telhado foi reforçado antes que "
					+ "a chuva alcançasse os mantimentos."
				)
			},
			{
				"id": "improvise_barn",
				"title": "Improvisar uma cobertura",
				"description": (
					"Teste de Inteligência. Não consome material."
				),
				"requires_villager": true,
				"test_attribute": "intelligence",
				"base_chance": 0.25,
				"chance_per_point": 0.07,
				"min_chance": 0.25,
				"max_chance": 0.95,
				"success_effects": {"happiness": 3.0},
				"failure_effects": {
					"food": -8.0,
					"happiness": -2.0
				},
				"success_text": (
					"a cobertura improvisada resistiu "
					+ "e salvou todo o estoque."
				),
				"failure_text": (
					"a cobertura cedeu e parte da "
					+ "alimentação foi perdida."
				)
			},
			{
				"id": "move_barn_food",
				"title": "Mover os mantimentos",
				"description": (
					"Perde 3 alimentos durante a mudança."
				),
				"costs": {"food": 3.0},
				"effects": {},
				"result_text": (
					"Os mantimentos foram levados para casas "
					+ "secas, embora parte tenha se perdido."
				)
			}
		]
	})

	events.append({
		"id": "unknown_berries",
		"title": "BAGAS DE MANA",
		"description": (
			"Os coletores retornaram com cestos de bagas "
			+ "que ninguém na vila reconhece."
		),
		"min_day": 1,
		"choices": [
			{
				"id": "study_berries",
				"title": "Examinar as bagas",
				"description": (
					"Teste de Inteligência para confirmar "
					+ "se são seguras."
				),
				"requires_villager": true,
				"test_attribute": "intelligence",
				"base_chance": 0.30,
				"chance_per_point": 0.07,
				"min_chance": 0.30,
				"max_chance": 0.95,
				"success_effects": {
					"food": 8.0,
					"happiness": 2.0
				},
				"failure_effects": {
					"food": -2.0,
					"happiness": -4.0
				},
				"success_text": (
					"identificou as bagas com segurança "
					+ "e elas reforçaram o estoque."
				),
				"failure_text": (
					"confundiu as espécies e alguns "
					+ "moradores passaram mal."
				)
			},
			{
				"id": "taste_berries",
				"title": "Experimentar uma pequena porção",
				"description": (
					"55% de chance. Pode render 6 alimentos "
					+ "ou causar mal-estar."
				),
				"base_chance": 0.55,
				"min_chance": 0.55,
				"max_chance": 0.55,
				"success_effects": {"food": 6.0},
				"failure_effects": {"happiness": -5.0},
				"success_text": (
					"as bagas eram comestíveis e foram "
					+ "adicionadas às reservas."
				),
				"failure_text": (
					"as bagas causaram uma noite de "
					+ "dores e preocupação."
				)
			},
			{
				"id": "discard_berries",
				"title": "Descartar tudo",
				"description": (
					"Solução segura. Perde 1 felicidade."
				),
				"effects": {"happiness": -1.0},
				"result_text": (
					"As bagas foram queimadas. Alguns "
					+ "lamentaram o desperdício."
				)
			}
		]
	})

	events.append({
		"id": "traveling_merchant",
		"title": "MERCADOR KOBOLD VIAJANTE",
		"description": (
			"Uma carroça colorida estacionou junto ao portão. "
			+ "O mercador oferece três negócios."
		),
		"min_day": 1,
		"choices": [
			{
				"id": "buy_material",
				"title": "Comprar ferramentas",
				"description": (
					"Troca 6 alimentos por 5 materiais."
				),
				"costs": {"food": 6.0},
				"effects": {"material": 5.0},
				"result_text": (
					"A despensa ficou mais leve, mas a oficina "
					+ "recebeu boas ferramentas."
				)
			},
			{
				"id": "buy_food",
				"title": "Comprar provisões",
				"description": (
					"Troca 5 materiais por 10 alimentos."
				),
				"costs": {"material": 5.0},
				"effects": {"food": 10.0},
				"result_text": (
					"A vila recebeu sacos de grãos "
					+ "para os próximos dias."
				)
			},
			{
				"id": "host_merchant",
				"title": "Receber o mercador",
				"description": (
					"Custo: 3 alimentos. Ganha 5 felicidade."
				),
				"costs": {"food": 3.0},
				"effects": {"happiness": 5.0},
				"result_text": (
					"Histórias de terras distantes animaram "
					+ "a noite na taverna."
				)
			}
		]
	})

	events.append({
		"id": "wild_boar",
		"title": "JAVALI FEÉRICO NA PLANTAÇÃO",
		"description": (
			"Um javali enorme atravessou a cerca e está "
			+ "destruindo a plantação."
		),
		"min_day": 2,
		"choices": [
			{
				"id": "chase_boar",
				"title": "Perseguir o javali",
				"description": (
					"Teste de Agilidade. Uma captura bem-sucedida "
					+ "também rende alimento."
				),
				"requires_villager": true,
				"test_attribute": "agility",
				"base_chance": 0.25,
				"chance_per_point": 0.07,
				"min_chance": 0.25,
				"max_chance": 0.95,
				"success_effects": {
					"food": 4.0,
					"happiness": 2.0
				},
				"failure_effects": {
					"food": -5.0,
					"happiness": -3.0
				},
				"success_text": (
					"alcançou o javali antes que ele "
					+ "destruísse o restante da plantação."
				),
				"failure_text": (
					"não conseguiu acompanhar o animal, "
					+ "que arrasou vários canteiros."
				)
			},
			{
				"id": "face_boar",
				"title": "Enfrentar o javali",
				"description": (
					"Teste de Força para expulsá-lo."
				),
				"requires_villager": true,
				"test_attribute": "strength",
				"base_chance": 0.25,
				"chance_per_point": 0.07,
				"min_chance": 0.25,
				"max_chance": 0.95,
				"success_effects": {"happiness": 4.0},
				"failure_effects": {
					"food": -4.0,
					"happiness": -4.0
				},
				"success_text": (
					"afugentou o javali e virou assunto "
					+ "na vila inteira."
				),
				"failure_text": (
					"foi derrubado e o javali continuou "
					+ "a devastar a plantação."
				)
			},
			{
				"id": "build_boar_fence",
				"title": "Reforçar a cerca",
				"description": (
					"Custo: 5 materiais. Solução garantida."
				),
				"costs": {"material": 5.0},
				"effects": {"happiness": 1.0},
				"result_text": (
					"Uma cerca robusta protege agora "
					+ "todos os canteiros."
				)
			}
		]
	})

	events.append({
		"id": "harvest_festival",
		"title": "PEDIDO DE FESTIVAL",
		"description": (
			"Depois de dias de trabalho, os moradores pedem "
			+ "uma noite de música e comida."
		),
		"min_day": 2,
		"choices": [
			{
				"id": "grand_festival",
				"title": "Preparar um grande festival",
				"description": (
					"Custo: 8 alimentos. Ganha 10 felicidade."
				),
				"costs": {"food": 8.0},
				"effects": {"happiness": 10.0},
				"result_text": (
					"A praça ficou iluminada até tarde "
					+ "e todos voltaram para casa sorrindo."
				)
			},
			{
				"id": "simple_festival",
				"title": "Organizar uma festa simples",
				"description": (
					"Custo: 3 alimentos e teste de Carisma."
				),
				"costs": {"food": 3.0},
				"requires_villager": true,
				"test_attribute": "charisma",
				"base_chance": 0.30,
				"chance_per_point": 0.07,
				"min_chance": 0.30,
				"max_chance": 0.95,
				"success_effects": {"happiness": 9.0},
				"failure_effects": {"happiness": 2.0},
				"success_text": (
					"transformou poucos recursos em uma "
					+ "celebração inesquecível."
				),
				"failure_text": (
					"não conseguiu animar a praça, mas "
					+ "a pausa ainda fez algum bem."
				)
			},
			{
				"id": "postpone_festival",
				"title": "Adiar a celebração",
				"description": (
					"Preserva recursos, mas perde 3 felicidade."
				),
				"effects": {"happiness": -3.0},
				"result_text": (
					"Os moradores aceitaram a decisão, "
					+ "embora a decepção fosse visível."
				)
			}
		]
	})

	events.append({
		"id": "stranger_at_gate",
		"title": "DESCONHECIDO NO PORTÃO",
		"description": (
			"Um viajante exausto pede abrigo por uma noite "
			+ "e afirma conhecer rotas comerciais."
		),
		"min_day": 2,
		"choices": [
			{
				"id": "question_stranger",
				"title": "Conversar antes de decidir",
				"description": (
					"Teste de Carisma para conquistar "
					+ "a confiança do viajante."
				),
				"requires_villager": true,
				"test_attribute": "charisma",
				"base_chance": 0.25,
				"chance_per_point": 0.07,
				"min_chance": 0.25,
				"max_chance": 0.95,
				"success_effects": {
					"food": 4.0,
					"happiness": 4.0
				},
				"failure_effects": {
					"food": -3.0,
					"happiness": -3.0
				},
				"success_text": (
					"ganhou a confiança do viajante, "
					+ "que revelou um esconderijo de provisões."
				),
				"failure_text": (
					"foi enganado; o viajante desapareceu "
					+ "com parte das provisões."
				)
			},
			{
				"id": "welcome_stranger",
				"title": "Oferecer abrigo e comida",
				"description": (
					"Custo: 3 alimentos. Recebe 2 materiais "
					+ "e 3 felicidade."
				),
				"costs": {"food": 3.0},
				"effects": {
					"material": 2.0,
					"happiness": 3.0
				},
				"result_text": (
					"Em agradecimento, o viajante reparou "
					+ "ferramentas antes de partir."
				)
			},
			{
				"id": "refuse_stranger",
				"title": "Manter o portão fechado",
				"description": (
					"Não gasta recursos. Perde 2 felicidade."
				),
				"effects": {"happiness": -2.0},
				"result_text": (
					"O viajante seguiu pela estrada, "
					+ "sob o olhar desconfortável da vila."
				)
			}
		]
	})

	events.append({
		"id": "broken_bridge",
		"title": "PONTE DANIFICADA",
		"description": (
			"As chuvas deslocaram as vigas da ponte usada "
			+ "pelos coletores. A passagem está perigosa."
		),
		"min_day": 3,
		"choices": [
			{
				"id": "repair_bridge",
				"title": "Reconstruir a passagem",
				"description": (
					"Custo: 7 materiais. Ganha 3 felicidade."
				),
				"costs": {"material": 7.0},
				"effects": {"happiness": 3.0},
				"result_text": (
					"A ponte foi reconstruída e a rota "
					+ "voltou a ser segura."
				)
			},
			{
				"id": "lift_bridge_beam",
				"title": "Reposicionar as vigas",
				"description": (
					"Teste de Força sem custo inicial."
				),
				"requires_villager": true,
				"test_attribute": "strength",
				"base_chance": 0.25,
				"chance_per_point": 0.07,
				"min_chance": 0.25,
				"max_chance": 0.95,
				"success_effects": {"happiness": 4.0},
				"failure_effects": {
					"material": -4.0,
					"happiness": -2.0
				},
				"success_text": (
					"recolocou as vigas no lugar e "
					+ "restaurou a passagem."
				),
				"failure_text": (
					"derrubou parte da estrutura; novas "
					+ "peças serão necessárias."
				)
			},
			{
				"id": "bridge_detour",
				"title": "Usar a rota longa",
				"description": (
					"Perde 5 alimentos e 2 felicidade."
				),
				"costs": {
					"food": 5.0
				},
				"effects": {"happiness": -2.0},
				"result_text": (
					"A coleta continuou, mas o longo caminho "
					+ "consumiu tempo e provisões."
				)
			}
		]
	})

	events.append({
		"id": "lost_child",
		"title": "CRIANÇA DESAPARECIDA",
		"description": (
			"Uma criança não voltou antes do anoitecer. "
			+ "Pegadas seguem em direção à mata."
		),
		"min_day": 3,
		"choices": [
			{
				"id": "track_child",
				"title": "Seguir as pegadas",
				"description": (
					"Teste de Agilidade para alcançá-la "
					+ "antes da noite."
				),
				"requires_villager": true,
				"test_attribute": "agility",
				"base_chance": 0.25,
				"chance_per_point": 0.07,
				"min_chance": 0.25,
				"max_chance": 0.95,
				"success_effects": {"happiness": 8.0},
				"failure_effects": {
					"food": -2.0,
					"happiness": -5.0
				},
				"success_text": (
					"encontrou a criança junto ao riacho "
					+ "e voltou antes da escuridão."
				),
				"failure_text": (
					"perdeu a trilha. A busca atravessou "
					+ "a noite e abalou a vila."
				)
			},
			{
				"id": "organized_search",
				"title": "Organizar uma grande busca",
				"description": (
					"Custo: 4 alimentos. Ganha 6 felicidade."
				),
				"costs": {"food": 4.0},
				"effects": {"happiness": 6.0},
				"result_text": (
					"Dezenas de lanternas iluminaram a mata "
					+ "até a criança ser encontrada."
				)
			},
			{
				"id": "wait_child",
				"title": "Esperar pelo amanhecer",
				"description": (
					"Não gasta recursos. Perde 6 felicidade."
				),
				"effects": {"happiness": -6.0},
				"result_text": (
					"A criança retornou pela manhã, mas "
					+ "a longa espera deixou marcas."
				)
			}
		]
	})

	events.append({
		"id": "contaminated_well",
		"title": "ÁGUA TURVA",
		"description": (
			"A água do poço amanheceu com cheiro de terra "
			+ "e uma coloração incomum."
		),
		"min_day": 4,
		"choices": [
			{
				"id": "inspect_well",
				"title": "Investigar a contaminação",
				"description": (
					"Teste de Inteligência para descobrir "
					+ "a causa."
				),
				"requires_villager": true,
				"test_attribute": "intelligence",
				"base_chance": 0.25,
				"chance_per_point": 0.07,
				"min_chance": 0.25,
				"max_chance": 0.95,
				"success_effects": {"happiness": 4.0},
				"failure_effects": {
					"food": -6.0,
					"happiness": -6.0
				},
				"success_text": (
					"descobriu uma infiltração e isolou "
					+ "o problema a tempo."
				),
				"failure_text": (
					"não encontrou a origem e vários "
					+ "moradores adoeceram."
				)
			},
			{
				"id": "build_filter",
				"title": "Construir um filtro",
				"description": (
					"Custo: 6 materiais. Ganha 3 felicidade."
				),
				"costs": {"material": 6.0},
				"effects": {"happiness": 3.0},
				"result_text": (
					"Camadas de pedra, areia e carvão "
					+ "deixaram a água limpa novamente."
				)
			},
			{
				"id": "ration_water",
				"title": "Racionar a água",
				"description": (
					"Perde 3 alimentos e 2 felicidade."
				),
				"costs": {
					"food": 3.0
				},
				"effects": {"happiness": -2.0},
				"result_text": (
					"A vila atravessou o problema usando "
					+ "água guardada e refeições menores."
				)
			}
		]
	})

	events.append({
		"id": "stuck_caravan",
		"title": "CARAVANA ATOLADA",
		"description": (
			"Uma caravana comercial ficou presa na lama "
			+ "perto da vila e pede ajuda."
		),
		"min_day": 4,
		"choices": [
			{
				"id": "pull_caravan",
				"title": "Puxar as carroças",
				"description": (
					"Teste de Força. O pagamento será "
					+ "feito em materiais."
				),
				"requires_villager": true,
				"test_attribute": "strength",
				"base_chance": 0.25,
				"chance_per_point": 0.07,
				"min_chance": 0.25,
				"max_chance": 0.95,
				"success_effects": {
					"material": 6.0,
					"happiness": 3.0
				},
				"failure_effects": {
					"food": -2.0,
					"happiness": -3.0
				},
				"success_text": (
					"libertou as carroças e recebeu "
					+ "ferragens como recompensa."
				),
				"failure_text": (
					"não moveu as carroças e o trabalho "
					+ "consumiu as provisões da equipe."
				)
			},
			{
				"id": "feed_caravan",
				"title": "Alimentar os viajantes",
				"description": (
					"Custo: 4 alimentos. Recebe 4 materiais "
					+ "e 2 felicidade."
				),
				"costs": {"food": 4.0},
				"effects": {
					"material": 4.0,
					"happiness": 2.0
				},
				"result_text": (
					"Alimentados, os viajantes cavaram "
					+ "as rodas e deixaram ferramentas."
				)
			},
			{
				"id": "ignore_caravan",
				"title": "Seguir com o trabalho",
				"description": (
					"Não gasta recursos. Perde 1 felicidade."
				),
				"effects": {"happiness": -1.0},
				"result_text": (
					"A caravana partiu horas depois, "
					+ "sem esquecer a indiferença da vila."
				)
			}
		]
	})

	events.append({
		"id": "forest_ruins",
		"title": "RUÍNAS NA FLORESTA",
		"description": (
			"Caçadores encontraram degraus de pedra cobertos "
			+ "por raízes em uma clareira distante."
		),
		"min_day": 5,
		"choices": [
			{
				"id": "study_ruins",
				"title": "Estudar as inscrições",
				"description": (
					"Teste de Inteligência para abrir "
					+ "uma antiga câmara."
				),
				"requires_villager": true,
				"test_attribute": "intelligence",
				"base_chance": 0.25,
				"chance_per_point": 0.07,
				"min_chance": 0.25,
				"max_chance": 0.95,
				"success_effects": {
					"material": 7.0,
					"happiness": 3.0
				},
				"failure_effects": {
					"food": -3.0,
					"happiness": -3.0
				},
				"success_text": (
					"decifrou os símbolos e encontrou "
					+ "ferramentas antigas ainda úteis."
				),
				"failure_text": (
					"não abriu a câmara e a expedição "
					+ "voltou cansada e sem provisões."
				)
			},
			{
				"id": "explore_ruins",
				"title": "Explorar as passagens",
				"description": (
					"Teste de Agilidade. Pode render "
					+ "alimento e material."
				),
				"requires_villager": true,
				"test_attribute": "agility",
				"base_chance": 0.25,
				"chance_per_point": 0.07,
				"min_chance": 0.25,
				"max_chance": 0.95,
				"success_effects": {
					"food": 5.0,
					"material": 4.0
				},
				"failure_effects": {"food": -4.0},
				"success_text": (
					"atravessou as passagens e trouxe "
					+ "suprimentos esquecidos."
				),
				"failure_text": (
					"se perdeu por horas e consumiu "
					+ "as provisões da expedição."
				)
			},
			{
				"id": "forbid_ruins",
				"title": "Proibir a exploração",
				"description": (
					"Não gasta recursos. Perde 1 felicidade."
				),
				"effects": {"happiness": -1.0},
				"result_text": (
					"As ruínas foram marcadas como perigosas, "
					+ "para frustração dos curiosos."
				)
			}
		]
	})

	events.append({
		"id": "market_dispute",
		"title": "DISCUSSÃO NA FEIRA",
		"description": (
			"Dois grupos de comerciantes disputam espaço "
			+ "na praça e a multidão começa a se agitar."
		),
		"min_day": 5,
		"choices": [
			{
				"id": "mediate_dispute",
				"title": "Mediar a discussão",
				"description": (
					"Teste de Carisma para chegar "
					+ "a um acordo justo."
				),
				"requires_villager": true,
				"test_attribute": "charisma",
				"base_chance": 0.25,
				"chance_per_point": 0.07,
				"min_chance": 0.25,
				"max_chance": 0.95,
				"success_effects": {"happiness": 7.0},
				"failure_effects": {"happiness": -5.0},
				"success_text": (
					"encontrou uma divisão justa e recebeu "
					+ "aplausos de toda a praça."
				),
				"failure_text": (
					"não conteve os ânimos e a discussão "
					+ "terminou em empurrões."
				)
			},
			{
				"id": "compensate_merchants",
				"title": "Ampliar as bancas",
				"description": (
					"Custo: 3 materiais. Ganha 4 felicidade."
				),
				"costs": {"material": 3.0},
				"effects": {"happiness": 4.0},
				"result_text": (
					"Novas bancas deram espaço a todos "
					+ "e encerraram a disputa."
				)
			},
			{
				"id": "close_market",
				"title": "Encerrar a feira",
				"description": (
					"Perde 3 alimentos e 2 felicidade."
				),
				"costs": {
					"food": 3.0
				},
				"effects": {"happiness": -2.0},
				"result_text": (
					"A praça esvaziou, mas alguns produtos "
					+ "estragaram sem compradores."
				)
			}
		]
	})

	# Acontecimentos sazonais: dois para cada estação.
	events.append({
		"id": "spring_flooded_gardens",
		"title": "CANTEIROS ALAGADOS",
		"description": (
			"As chuvas da Primavera encharcaram os canteiros. "
			+ "A água precisa escoar antes de apodrecer as raízes."
		),
		"min_day": 1,
		"season_id": "spring",
		"choices": [
			{
				"id": "spring_drain_channels",
				"title": "Abrir canais de drenagem",
				"description": (
					"Custo: 4 materiais. Salva a plantação "
					+ "e ganha 2 felicidade."
				),
				"costs": {"material": 4.0},
				"effects": {
					"food": 5.0,
					"happiness": 2.0
				},
				"result_text": (
					"A água correu para longe dos canteiros "
					+ "e a colheita continuou crescendo."
				)
			},
			{
				"id": "spring_redirect_water",
				"title": "Redirecionar a água",
				"description": (
					"Teste de Inteligência. Um bom projeto "
					+ "transforma a chuva em reserva."
				),
				"requires_villager": true,
				"test_attribute": "intelligence",
				"base_chance": 0.25,
				"chance_per_point": 0.07,
				"min_chance": 0.25,
				"max_chance": 0.95,
				"success_effects": {
					"food": 8.0,
					"happiness": 2.0
				},
				"failure_effects": {
					"food": -6.0,
					"happiness": -2.0
				},
				"success_text": (
					"criou valas eficientes e salvou cada muda."
				),
				"failure_text": (
					"abriu a vala no lugar errado e a água "
					+ "levou parte das sementes."
				)
			},
			{
				"id": "spring_replant_gardens",
				"title": "Replantar as áreas baixas",
				"description": (
					"Custo: 3 alimentos. Evita riscos."
				),
				"costs": {"food": 3.0},
				"effects": {"happiness": 1.0},
				"result_text": (
					"As mudas foram levadas para solo alto "
					+ "antes que a chuva piorasse."
				)
			}
		]
	})

	events.append({
		"id": "spring_pollinator_swarm",
		"title": "ENXAME DE POLINIZADORES",
		"description": (
			"Um enxame dourado cobriu as flores da vila. "
			+ "Ele pode favorecer a colheita ou assustar moradores."
		),
		"min_day": 2,
		"season_id": "spring",
		"choices": [
			{
				"id": "spring_build_hives",
				"title": "Construir abrigos para o enxame",
				"description": (
					"Custo: 3 materiais. Ganha 7 alimentos."
				),
				"costs": {"material": 3.0},
				"effects": {"food": 7.0},
				"result_text": (
					"Os insetos ocuparam os novos abrigos "
					+ "e polinizaram os campos."
				)
			},
			{
				"id": "spring_guide_swarm",
				"title": "Guiar o enxame aos pomares",
				"description": (
					"Teste de Agilidade. Pode render uma "
					+ "grande colheita."
				),
				"requires_villager": true,
				"test_attribute": "agility",
				"base_chance": 0.25,
				"chance_per_point": 0.07,
				"min_chance": 0.25,
				"max_chance": 0.95,
				"success_effects": {
					"food": 10.0,
					"happiness": 2.0
				},
				"failure_effects": {"happiness": -5.0},
				"success_text": (
					"conduziu o enxame com cuidado e os "
					+ "pomares floresceram."
				),
				"failure_text": (
					"irritou os insetos e a praça precisou "
					+ "ser evacuada às pressas."
				)
			},
			{
				"id": "spring_drive_swarm_away",
				"title": "Afastar o enxame",
				"description": (
					"Solução segura. Perde 2 felicidade."
				),
				"effects": {"happiness": -2.0},
				"result_text": (
					"O enxame partiu sem causar feridos, "
					+ "mas os agricultores lamentaram a oportunidade."
				)
			}
		]
	})

	events.append({
		"id": "summer_heat_wave",
		"title": "ONDA DE CALOR",
		"description": (
			"O calor do Verão tornou o trabalho quase impossível. "
			+ "A vila precisa decidir como atravessar o dia."
		),
		"min_day": 31,
		"season_id": "summer",
		"choices": [
			{
				"id": "summer_build_shade",
				"title": "Montar áreas de sombra",
				"description": (
					"Custo: 4 materiais. Ganha 4 felicidade."
				),
				"costs": {"material": 4.0},
				"effects": {"happiness": 4.0},
				"result_text": (
					"Toldos cobriram os locais de trabalho "
					+ "e devolveram o ânimo aos moradores."
				)
			},
			{
				"id": "summer_organize_shifts",
				"title": "Organizar turnos noturnos",
				"description": (
					"Teste de Inteligência para evitar "
					+ "perdas de produção."
				),
				"requires_villager": true,
				"test_attribute": "intelligence",
				"base_chance": 0.25,
				"chance_per_point": 0.07,
				"min_chance": 0.25,
				"max_chance": 0.95,
				"success_effects": {
					"food": 5.0,
					"material": 4.0
				},
				"failure_effects": {"happiness": -4.0},
				"success_text": (
					"distribuiu os turnos e manteve a vila "
					+ "produtiva nas horas frescas."
				),
				"failure_text": (
					"criou horários confusos e deixou todos "
					+ "ainda mais cansados."
				)
			},
			{
				"id": "summer_rest_day",
				"title": "Declarar um dia de descanso",
				"description": (
					"Custo: 4 alimentos. Ganha 5 felicidade."
				),
				"costs": {"food": 4.0},
				"effects": {"happiness": 5.0},
				"result_text": (
					"Uma tarde à sombra restaurou as forças "
					+ "da comunidade."
				)
			}
		]
	})

	events.append({
		"id": "summer_firefly_night",
		"title": "NOITE DOS VAGA-LUMES ARCANOS",
		"description": (
			"Milhares de vaga-lumes iluminam os campos. "
			+ "Os moradores querem transformar a noite em celebração."
		),
		"min_day": 32,
		"season_id": "summer",
		"choices": [
			{
				"id": "summer_host_lantern_feast",
				"title": "Preparar uma ceia ao ar livre",
				"description": (
					"Custo: 5 alimentos. Ganha 8 felicidade."
				),
				"costs": {"food": 5.0},
				"effects": {"happiness": 8.0},
				"result_text": (
					"A praça brilhou até tarde e a noite "
					+ "se tornou uma lembrança querida."
				)
			},
			{
				"id": "summer_guide_fireflies",
				"title": "Guiar os vaga-lumes até a vila",
				"description": (
					"Teste de Carisma. O espetáculo pode "
					+ "animar toda a comunidade."
				),
				"requires_villager": true,
				"test_attribute": "charisma",
				"base_chance": 0.25,
				"chance_per_point": 0.07,
				"min_chance": 0.25,
				"max_chance": 0.95,
				"success_effects": {"happiness": 7.0},
				"failure_effects": {"happiness": -2.0},
				"success_text": (
					"organizou uma procissão luminosa "
					+ "que encantou a vila."
				),
				"failure_text": (
					"falou alto demais e dispersou os "
					+ "vaga-lumes antes do espetáculo."
				)
			},
			{
				"id": "summer_keep_working",
				"title": "Manter o turno de trabalho",
				"description": (
					"Ganha 3 materiais, mas perde 3 felicidade."
				),
				"effects": {
					"material": 3.0,
					"happiness": -3.0
				},
				"result_text": (
					"A oficina aproveitou a noite fresca, "
					+ "embora muitos preferissem ter celebrado."
				)
			}
		]
	})

	events.append({
		"id": "autumn_harvest_winds",
		"title": "VENTOS DA COLHEITA",
		"description": (
			"Rajadas de Outono arrancam frutos maduros e "
			+ "ameaçam espalhar a colheita pelos campos."
		),
		"min_day": 61,
		"season_id": "autumn",
		"choices": [
			{
				"id": "autumn_reinforce_baskets",
				"title": "Reforçar cestos e depósitos",
				"description": (
					"Custo: 4 materiais. Ganha 7 alimentos."
				),
				"costs": {"material": 4.0},
				"effects": {"food": 7.0},
				"result_text": (
					"Os depósitos resistiram às rajadas "
					+ "e preservaram a colheita."
				)
			},
			{
				"id": "autumn_race_the_wind",
				"title": "Colher antes da próxima rajada",
				"description": (
					"Teste de Agilidade. Pode salvar "
					+ "uma grande quantidade de alimento."
				),
				"requires_villager": true,
				"test_attribute": "agility",
				"base_chance": 0.25,
				"chance_per_point": 0.07,
				"min_chance": 0.25,
				"max_chance": 0.95,
				"success_effects": {
					"food": 11.0,
					"happiness": 2.0
				},
				"failure_effects": {"food": -7.0},
				"success_text": (
					"coordenou uma colheita veloz e encheu "
					+ "os cestos a tempo."
				),
				"failure_text": (
					"não alcançou os pomares antes que o "
					+ "vento espalhasse os frutos."
				)
			},
			{
				"id": "autumn_accept_losses",
				"title": "Proteger apenas o depósito",
				"description": (
					"Perde 4 alimentos, mas evita outros custos."
				),
				"effects": {"food": -4.0},
				"result_text": (
					"Parte da colheita se perdeu, mas as "
					+ "reservas antigas permaneceram seguras."
				)
			}
		]
	})

	events.append({
		"id": "autumn_leaf_market",
		"title": "FEIRA DAS FOLHAS",
		"description": (
			"Artesãos viajantes chegaram para a tradicional "
			+ "feira de Outono, trazendo ferramentas e provisões."
		),
		"min_day": 62,
		"season_id": "autumn",
		"choices": [
			{
				"id": "autumn_trade_food",
				"title": "Vender parte da colheita",
				"description": (
					"Troca 6 alimentos por 7 materiais."
				),
				"costs": {"food": 6.0},
				"effects": {"material": 7.0},
				"result_text": (
					"A fartura da estação rendeu novas "
					+ "ferramentas para a oficina."
				)
			},
			{
				"id": "autumn_negotiate_bundle",
				"title": "Negociar um lote completo",
				"description": (
					"Teste de Carisma. Um acordo bem-sucedido "
					+ "traz alimento, material e alegria."
				),
				"requires_villager": true,
				"test_attribute": "charisma",
				"base_chance": 0.25,
				"chance_per_point": 0.07,
				"min_chance": 0.25,
				"max_chance": 0.95,
				"success_effects": {
					"food": 5.0,
					"material": 5.0,
					"happiness": 3.0
				},
				"failure_effects": {
					"material": -3.0,
					"happiness": -2.0
				},
				"success_text": (
					"fechou o melhor negócio da feira."
				),
				"failure_text": (
					"aceitou mercadorias defeituosas e "
					+ "precisou compensar os compradores."
				)
			},
			{
				"id": "autumn_host_market",
				"title": "Patrocinar a feira",
				"description": (
					"Custo: 3 materiais. Ganha 6 felicidade."
				),
				"costs": {"material": 3.0},
				"effects": {"happiness": 6.0},
				"result_text": (
					"A vila ganhou música, bancas e uma "
					+ "tarde inteira de celebração."
				)
			}
		]
	})

	events.append({
		"id": "winter_blocked_road",
		"title": "ESTRADA BLOQUEADA PELA NEVE",
		"description": (
			"Uma nevasca de Inverno fechou a estrada. "
			+ "Uma carroça de provisões ficou presa do lado de fora."
		),
		"min_day": 91,
		"season_id": "winter",
		"choices": [
			{
				"id": "winter_clear_road",
				"title": "Abrir caminho na força",
				"description": (
					"Teste de Força. Pode recuperar "
					+ "todas as provisões."
				),
				"requires_villager": true,
				"test_attribute": "strength",
				"base_chance": 0.25,
				"chance_per_point": 0.07,
				"min_chance": 0.25,
				"max_chance": 0.95,
				"success_effects": {
					"food": 10.0,
					"happiness": 2.0
				},
				"failure_effects": {
					"food": -4.0,
					"happiness": -3.0
				},
				"success_text": (
					"abriu passagem e conduziu a carroça "
					+ "até o depósito."
				),
				"failure_text": (
					"não venceu a neve e consumiu provisões "
					+ "durante a tentativa."
				)
			},
			{
				"id": "winter_build_shelter",
				"title": "Construir um abrigo na estrada",
				"description": (
					"Custo: 5 materiais. Salva 6 alimentos."
				),
				"costs": {"material": 5.0},
				"effects": {"food": 6.0},
				"result_text": (
					"O abrigo protegeu a carga até a "
					+ "nevasca enfraquecer."
				)
			},
			{
				"id": "winter_abandon_cart",
				"title": "Esperar o degelo",
				"description": (
					"Perde 5 alimentos e 2 felicidade."
				),
				"effects": {
					"food": -5.0,
					"happiness": -2.0
				},
				"result_text": (
					"Parte da carga congelou antes que a "
					+ "estrada pudesse ser reaberta."
				)
			}
		]
	})

	events.append({
		"id": "winter_frozen_lake",
		"title": "LAGO CONGELADO",
		"description": (
			"O lago congelou durante a noite. Há peixes sob "
			+ "o gelo, mas ninguém sabe se a superfície é segura."
		),
		"min_day": 92,
		"season_id": "winter",
		"choices": [
			{
				"id": "winter_inspect_ice",
				"title": "Examinar a espessura do gelo",
				"description": (
					"Teste de Inteligência. Uma avaliação "
					+ "correta permite pescar com segurança."
				),
				"requires_villager": true,
				"test_attribute": "intelligence",
				"base_chance": 0.25,
				"chance_per_point": 0.07,
				"min_chance": 0.25,
				"max_chance": 0.95,
				"success_effects": {"food": 9.0},
				"failure_effects": {
					"food": -3.0,
					"happiness": -4.0
				},
				"success_text": (
					"marcou uma área segura e organizou "
					+ "uma boa pescaria."
				),
				"failure_text": (
					"escolheu uma área frágil e a pescaria "
					+ "terminou em um resgate gelado."
				)
			},
			{
				"id": "winter_ice_festival",
				"title": "Criar um festival no gelo",
				"description": (
					"Custo: 4 alimentos. Ganha 7 felicidade."
				),
				"costs": {"food": 4.0},
				"effects": {"happiness": 7.0},
				"result_text": (
					"Jogos e esculturas transformaram o frio "
					+ "em motivo de festa."
				)
			},
			{
				"id": "winter_forbid_lake",
				"title": "Proibir o acesso ao lago",
				"description": (
					"Solução segura. Perde 1 felicidade."
				),
				"effects": {"happiness": -1.0},
				"result_text": (
					"A margem foi isolada. Ninguém se feriu, "
					+ "mas os moradores reclamaram da cautela."
				)
			}
		]
	})

	events.append_array(MAGICAL_EVENT_CATALOG_SCRIPT.create())
	BUILDING_VARIANT_EVENT_CATALOG_SCRIPT.apply_to_events(events)
	return events
