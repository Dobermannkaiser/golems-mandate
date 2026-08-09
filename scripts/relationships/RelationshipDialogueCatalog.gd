class_name VillageRelationshipDialogueCatalog
extends RefCounted


const RELATIONSHIP_CATALOG_SCRIPT = preload(
	"res://scripts/relationships/RelationshipCatalog.gd"
)
const EXPANSION_CATALOG_SCRIPT = preload(
	"res://scripts/relationships/RelationshipExpansionCatalog.gd"
)
const CAMPAIGN_IDENTITY_CATALOG_SCRIPT = preload(
	"res://scripts/campaign/CampaignIdentityCatalog.gd"
)


const CHARACTER_DATA: Dictionary = {
	"passos_leves_faz_tudo": {
		"name": "Mimo",
		"portrait_id": "mimo",
		"winter_warning": "Eu contei os sacos de comida para o inverno. Depois contei de novo porque um deles parecia menor. Eu só provei um pouquinho para garantir que não estava enfeitiçado!",
		"season_lines": {
			"spring": "As flores estão abrindo! Eu tentei ajudar uma delas com uma colher. Ela não pareceu agradecer, mas continua viva.",
			"summer": "O verão é ótimo porque o sol seca a roupa. Também seca o peixe. E às vezes seca a roupa com o peixe dentro.",
			"autumn": "As folhas caem porque as árvores estão trocando de roupa. É ciência. Ou moda. Talvez as duas.",
			"winter": "Eu fiz uma sopa quente para todo mundo. A panela virou um pouco consciente, mas está sendo educada."
		},
		"good": ["Você sempre encontra um jeito gentil de ajudar.", "Sua alegria deixa a vila mais leve."],
		"neutral": ["Pelo menos ninguém se machucou, certo?", "Isso foi... surpreendentemente eficiente."],
		"bad": ["Talvez seja melhor você não tocar em mais nada hoje.", "Mimo, isso não faz sentido nenhum."],
		"good_reply": "Mimo abre um sorriso enorme. Por um instante, até a panela ao lado parece orgulhosa.",
		"neutral_reply": "Mimo inclina a cabeça, pensa bastante e decide que aquilo provavelmente foi um elogio.",
		"bad_reply": "As orelhas de Mimo abaixam um pouco. Ela tenta rir, mas o riso sai pequeno."
	},
	"aelric_ferreiro": {
		"name": "Aelric Brasa-Clara",
		"portrait_id": "aelric_ferreiro",
		"winter_warning": "Uma forja sobrevive ao frio porque o combustível foi separado antes da neve. A vila não é diferente: encha o celeiro agora, Prefeito, ou o inverno cobrará em pratos vazios.",
		"season_lines": {
			"spring": "A umidade da primavera torna o carvão caprichoso. Ainda assim, o metal responde bem quando a vila está esperançosa.",
			"summer": "O calor da forja no verão separa artesãos de pessoas sensatas. Nunca afirmei pertencer ao segundo grupo.",
			"autumn": "O outono é a estação ideal para ferramentas novas. O frio se aproxima e o metal aprende a levar o trabalho a sério.",
			"winter": "No inverno, cada prego bem feito protege uma casa. É quando um ferreiro descobre se trabalhou por orgulho ou por pessoas."
		},
		"partner_lines": {
			"spring": "A forja anda mais clara quando você aparece. Não é metáfora. Verifiquei as runas três vezes.",
			"summer": "Fique perto, Prefeito. Não por segurança. A oficina apenas parece menos quente quando você está aqui.",
			"autumn": "Guardei a primeira folha dourada que caiu sobre a bigorna. Pensei em transformar em amuleto para você.",
			"winter": "Minhas mãos suportam o frio, mas prefiro quando você as segura mesmo assim."
		},
		"good": ["Sua dedicação protege muito mais que ferramentas.", "Quero aprender a ouvir o metal como você."],
		"neutral": ["A forja parece estar funcionando bem.", "Talvez devêssemos produzir mais ferramentas."],
		"bad": ["Você leva seu trabalho a sério demais.", "Qualquer ferreiro poderia fazer isso."],
		"good_reply": "Aelric desvia os olhos para a forja, mas o rubor nas pontas das orelhas é impossível de esconder.",
		"neutral_reply": "Aelric concorda com um gesto profissional e retorna à bigorna.",
		"bad_reply": "O martelo para no ar por um segundo. Aelric responde com uma educação mais fria que o metal apagado."
	},
	"kobi_mercante": {
		"name": "Kobi Cobre-Fino",
		"portrait_id": "kobi_mercante",
		"winter_warning": "No inverno, comida vale mais que ouro e estradas fechadas não aceitam negociação. Compre, produza e armazene no outono; depois agradeça ao meu excelente conselho sem taxa adicional.",
		"season_lines": {
			"spring": "Primavera: quando flores, viajantes e oportunidades aparecem sem aviso. Duas dessas coisas podem ser tributadas.",
			"summer": "Mercadoria derrete no verão, contratos não. É por isso que prefiro investir em papel.",
			"autumn": "O outono deixa todos preocupados com reservas. Preocupação é apenas demanda usando um capuz dramático.",
			"winter": "No inverno, moedas ficam frias e pessoas ficam sinceras. Ambas devem ser mantidas perto do peito."
		},
		"partner_lines": {
			"spring": "Preparei um contrato de passeio sem taxas, letras pequenas ou cláusulas ocultas. Estou assustado comigo mesmo.",
			"summer": "Você é meu investimento favorito. Não porque dá lucro — o que torna tudo estranhamente mais valioso.",
			"autumn": "Separei a melhor parte da colheita para nós. Não registrei como despesa. Guarde este segredo.",
			"winter": "Uma parceria boa divide riscos. Uma parceria excelente divide também o cobertor."
		},
		"good": ["Você sabe que confiança vale mais que moedas.", "Gosto quando você abandona as letras pequenas."],
		"neutral": ["Qual é a margem de lucro disso?", "Esse contrato parece aceitável."],
		"bad": ["Você só pensa em dinheiro.", "Não confio em nada que você escreve."],
		"good_reply": "Kobi fecha o livro-caixa devagar. Pela primeira vez, parece feliz com algo que não pode contabilizar.",
		"neutral_reply": "Kobi responde com números, porcentagens e um sorriso profissional cuidadosamente medido.",
		"bad_reply": "Kobi guarda a pena. A cordialidade permanece, mas agora parece uma porta trancada."
	},
	"orion_draconato": {
		"name": "Orion Escamagelo",
		"portrait_id": "orion_draconato",
		"winter_warning": "Minhas projeções mostram queda na produção e aumento do consumo durante o inverno. Em termos não acadêmicos: precisamos de um celeiro cheio antes que a primeira neve altere a mana das plantações.",
		"season_lines": {
			"spring": "A mana da primavera corre como água curiosa. Ela entra em raízes, sonhos e, lamentavelmente, em minhas anotações.",
			"summer": "O céu de verão amplifica magia solar. Recomendo não encarar diretamente nenhuma nuvem que pisque de volta.",
			"autumn": "Folhas guardam ecos mágicos. Ouvi uma recitar poesia antiga antes de ser levada pelo vento.",
			"winter": "O frio desacelera a mana, tornando seus padrões visíveis. É belo... e uma excelente desculpa para permanecer junto ao fogo."
		},
		"partner_lines": {
			"spring": "Sua presença altera a leitura dos cristais. Eles dizem 'segurança'. Não conhecia essa frequência.",
			"summer": "Mapeei constelações para nosso próximo encontro. Uma delas insiste em ter a forma do seu rosto.",
			"autumn": "Alguns fenômenos não precisam ser explicados. Ainda estou aprendendo a aceitar que nós somos um deles.",
			"winter": "Minhas escamas retêm pouco calor. É uma observação científica e, talvez, um pedido."
		},
		"good": ["Você não precisa entender tudo sozinho.", "Sua curiosidade torna o mundo mais bonito."],
		"neutral": ["Continue registrando os fenômenos.", "Isso parece magicamente complicado."],
		"bad": ["Talvez sua pesquisa seja inútil.", "Você complica coisas simples demais."],
		"good_reply": "Orion tenta responder com uma teoria, mas perde o fio da frase e sorri de um jeito raro.",
		"neutral_reply": "Orion registra a observação e promete produzir um relatório menos complicado. Ele não produzirá.",
		"bad_reply": "As pupilas de Orion se estreitam. Ele retorna aos cristais, usando a pesquisa como abrigo."
	},
	"rubra_meio_demonia": {
		"name": "Rubra Verbum",
		"portrait_id": "rubra_meio_demonia",
		"winter_warning": "Os registros antigos são claros: vilas não caem na primeira nevasca, mas na última refeição que não foi guardada. Faça do outono um capítulo de preparação, não um prólogo de fome.",
		"season_lines": {
			"spring": "Livros de botânica ficam inquietos na primavera. Um deles tentou plantar o próprio índice.",
			"summer": "Calor e pergaminho são inimigos antigos. Passei a tarde negociando com um grimório que exigia sombra.",
			"autumn": "O outono é feito para histórias. Até folhas mortas parecem cartas que o mundo esqueceu de enviar.",
			"winter": "No inverno, a biblioteca fica silenciosa o bastante para ouvir pensamentos antigos entre as páginas."
		},
		"partner_lines": {
			"spring": "Encontrei um poema sobre recomeços. O autor não conhecia você, mas claramente estava tentando descrevê-lo.",
			"summer": "Reservei um canto fresco da biblioteca para nós. Os livros receberam ordens de não interromper.",
			"autumn": "Quero registrar nossa história, mas temo torná-la pequena ao colocá-la em palavras.",
			"winter": "Venha ler perto de mim. Não precisa dizer nada. Alguns silêncios são declarações completas."
		},
		"good": ["Seu conhecimento não torna você perigosa; suas escolhas definem isso.", "Quero conhecer as histórias que você guarda."],
		"neutral": ["Precisamos catalogar melhor esses livros.", "Conhecimento sempre tem riscos."],
		"bad": ["Talvez fosse melhor selar tudo que você sabe.", "Não confio em magia proibida."],
		"good_reply": "Rubra segura o livro contra o peito. Seu sorriso é pequeno, mas possui a força de uma porta finalmente aberta.",
		"neutral_reply": "Rubra concorda e começa a explicar um sistema de catalogação com doze alfabetos.",
		"bad_reply": "Rubra fecha o livro. Por um instante, parece alguém acostumada demais a ser temida."
	},
	"brunna_ana_barbara": {
		"name": "Brunna Ana",
		"portrait_id": "brunna_ana_barbara",
		"winter_warning": "Já atravessei invernos com um machado, uma manta e péssimas decisões. A vila merece coisa melhor. Estoque comida agora; coragem não enche barriga.",
		"season_lines": {
			"spring": "A primavera deixa trilhas enlameadas e monstros otimistas. É uma combinação excelente para aventuras.",
			"summer": "Treinar sob o sol fortalece o corpo. Reclamar fortalece a conversa. Posso fazer os dois.",
			"autumn": "O vento de outono traz cheiro de jornada. Pela primeira vez, não sinto necessidade de segui-lo.",
			"winter": "Neve registra pegadas e escolhas. Uma boa guardiã aprende quais seguir e quais proteger."
		},
		"partner_lines": {
			"spring": "Planejei uma caminhada romântica. Há flores, um riacho e apenas uma criatura moderadamente hostil.",
			"summer": "Você pode descansar à minha sombra. Tecnicamente é a sombra do meu machado, mas funciona.",
			"autumn": "Já percorri cem estradas. Ainda assim, voltar para você é o caminho que mais gosto.",
			"winter": "Se o frio piorar, fique perto. Tenho força para proteger a vila e espaço para proteger você."
		},
		"good": ["Força também é saber quando permanecer.", "A vila se sente segura porque você escolheu ficar."],
		"neutral": ["Seu treinamento está dando resultado.", "Talvez devêssemos reforçar as patrulhas."],
		"bad": ["Você só sabe resolver tudo com um machado.", "Ficar aqui deve ser entediante para você."],
		"good_reply": "Brunna ri alto, mas a voz suaviza quando promete continuar voltando para a vila — e para você.",
		"neutral_reply": "Brunna concorda e transforma a conversa em um plano de treinamento detalhado.",
		"bad_reply": "Brunna apoia o machado no ombro. O sorriso desaparece, embora ela tente fingir que não se importou."
	}
}


const CONVERSATION_TOPICS: Dictionary = {
	"passos_leves_faz_tudo": [
		{
			"id": "mimo_deposito",
			"line": "Eu organizei o depósito por cheiro. Madeira fica perto de cheiro de árvore, comida perto de cheiro de almoço e ferramentas perto de cheiro de dedo machucado. É um sistema muito avançado.",
			"good": "A ideia é criativa. Vamos colocar etiquetas para todo mundo conseguir acompanhar.",
			"neutral": "Talvez seja melhor voltar a organizar por prateleiras.",
			"bad": "Você nunca deveria organizar nada importante.",
			"good_reply": "Mimo comemora a promoção do sistema e começa a desenhar etiquetas com pequenas árvores, panelas e dedos enfaixados.",
			"neutral_reply": "Mimo concorda, embora ainda pareça convencida de que o nariz era uma ferramenta administrativa subestimada.",
			"bad_reply": "Mimo recolhe as etiquetas improvisadas e tenta esconder que ficou magoada."
		},
		{
			"id": "mimo_espantalho",
			"line": "O espantalho da plantação parecia sozinho, então eu dei a ele um nome, um chapéu e autoridade para fiscalizar corvos. Agora os corvos estão exigindo uma reunião.",
			"good": "Você percebe quando alguém parece sozinho. Vamos ouvir os corvos também.",
			"neutral": "Só garanta que a reunião não atrase a colheita.",
			"bad": "É apenas palha. Pare de inventar problemas.",
			"good_reply": "Mimo anota solenemente uma audiência entre aves e espantalho, orgulhosa de sua diplomacia rural.",
			"neutral_reply": "Mimo promete uma reunião curta, embora já tenha preparado biscoitos para quatro horas de negociação.",
			"bad_reply": "Mimo olha para a plantação e murmura que até coisas de palha merecem um pouco de gentileza."
		},
		{
			"id": "mimo_panela",
			"line": "A panela consciente voltou a falar. Ela diz que eu coloco sal demais, mas também diz que acredita no meu potencial. Acho que estamos crescendo juntas.",
			"good": "Escutar críticas sem perder a alegria é uma qualidade rara, Mimo.",
			"neutral": "Talvez devêssemos verificar se a panela é segura.",
			"bad": "A panela provavelmente cozinha melhor que você.",
			"good_reply": "Mimo sorri para a panela, que borbulha de um jeito estranhamente satisfeito.",
			"neutral_reply": "Mimo concorda em chamar Orion, mas pede que ninguém transforme a panela em objeto de laboratório.",
			"bad_reply": "Mimo ri por educação. A panela, porém, bate a tampa com força."
		},
		{
			"id": "mimo_crianca",
			"line": "Uma criança perdeu um brinquedo e eu procurei com ela até anoitecer. Não encontramos o brinquedo, mas encontramos uma família de vaga-lumes e ela disse que foi melhor assim.",
			"good": "Você transformou uma perda em uma lembrança boa. Isso importa muito.",
			"neutral": "Ainda precisamos procurar o brinquedo amanhã.",
			"bad": "Você deveria ter procurado direito em vez de se distrair.",
			"good_reply": "As orelhas de Mimo se erguem. Ela decide guardar um pote vazio para mostrar os vaga-lumes sem prendê-los.",
			"neutral_reply": "Mimo concorda e prepara um mapa de busca com desenhos pouco precisos, mas muito entusiasmados.",
			"bad_reply": "Mimo baixa os olhos e diz que tentou fazer o melhor que conseguia."
		},
		{
			"id": "mimo_inseguranca",
			"line": "Às vezes eu acho que todo mundo ri porque sou engraçada. Outras vezes acho que ri porque eu estraguei alguma coisa. É difícil saber a diferença.",
			"good": "Você pode ser engraçada sem ser motivo de desprezo. Eu valorizo quem você é.",
			"neutral": "Talvez você devesse perguntar quando ficar em dúvida.",
			"bad": "Se você errasse menos, não precisaria se preocupar com isso.",
			"good_reply": "Mimo respira aliviada e pergunta, com um sorriso cauteloso, se pode continuar contando suas piadas ruins.",
			"neutral_reply": "Mimo considera a ideia seriamente e começa a planejar perguntas para situações futuras.",
			"bad_reply": "Mimo tenta sorrir, mas a alegria habitual não volta por algum tempo."
		}
	],
	"aelric_ferreiro": [
		{
			"id": "aelric_ferramenta",
			"line": "Esta enxada foi a primeira ferramenta que forjei aqui. O equilíbrio está ruim e a lâmina é pesada, mas ninguém passou fome por causa dela. Não consigo decidir se devo refazê-la.",
			"good": "Guarde-a como lembrança e faça outra melhor. O valor dela não está na perfeição.",
			"neutral": "Se ainda funciona, não há urgência em substituí-la.",
			"bad": "Um ferreiro respeitável não deveria exibir um trabalho tão ruim.",
			"good_reply": "Aelric passa o polegar pelo cabo gasto e decide pendurar a enxada acima da entrada da forja.",
			"neutral_reply": "Aelric concorda, mas continua avaliando cada imperfeição com evidente desconforto.",
			"bad_reply": "Aelric guarda a ferramenta longe da vista e encerra o assunto com frieza."
		},
		{
			"id": "aelric_aprendiz",
			"line": "Um jovem pediu para aprender comigo. Tem entusiasmo, pouca disciplina e uma capacidade impressionante de deixar martelos onde ninguém deveria pisar.",
			"good": "Paciência também faz parte do ofício. Você pode ensinar o que ninguém ensinou a você.",
			"neutral": "Estabeleça regras claras antes de aceitar.",
			"bad": "Recuse. Gente inexperiente só atrasa o trabalho.",
			"good_reply": "Aelric finge ponderar, mas já começa a separar uma bigorna pequena para o aprendiz.",
			"neutral_reply": "Aelric prepara uma lista rígida de segurança e parece satisfeito com a solução.",
			"bad_reply": "Aelric fecha a expressão. A resposta parece lembrar portas que já foram fechadas para ele."
		},
		{
			"id": "aelric_descanso",
			"line": "A forja não para porque eu não paro. Isso costuma soar admirável até minhas mãos começarem a tremer no fim do dia.",
			"good": "Descansar também protege a vila. Seu trabalho não vale mais que sua saúde.",
			"neutral": "Talvez você possa reduzir o turno por alguns dias.",
			"bad": "Todos estão cansados. Continue até o trabalho acabar.",
			"good_reply": "Aelric solta o ar devagar, como se tivesse recebido permissão para admitir um cansaço antigo.",
			"neutral_reply": "Aelric aceita ajustar o horário, tratando o descanso como mais uma tarefa técnica.",
			"bad_reply": "Aelric volta à bigorna sem discutir, mas os golpes perdem precisão."
		},
		{
			"id": "aelric_runa",
			"line": "As runas da forja brilham quando alguém entra com uma intenção sincera. Hoje elas acenderam antes mesmo de você abrir a porta.",
			"good": "Talvez elas reconheçam o quanto confio em você e no que construímos aqui.",
			"neutral": "Devemos registrar esse comportamento para evitar acidentes.",
			"bad": "Provavelmente é apenas uma falha na gravação.",
			"good_reply": "Aelric encara as runas e depois você. O brilho nas orelhas dele compete com o da forja.",
			"neutral_reply": "Aelric anota a ocorrência, embora pareça um pouco decepcionado por transformar o momento em relatório.",
			"bad_reply": "Aelric apaga uma das runas com o avental e muda de assunto."
		},
		{
			"id": "aelric_proteger",
			"line": "Forjar armas é fácil. Difícil é decidir quando uma lâmina protege alguém e quando apenas oferece uma desculpa para ferir.",
			"good": "A responsabilidade de fazer essa pergunta é justamente o que torna seu trabalho digno de confiança.",
			"neutral": "A decisão final pertence a quem usa a lâmina.",
			"bad": "Seu trabalho é produzir. Pensar demais só reduz a eficiência.",
			"good_reply": "Aelric assente com respeito e ajusta o desenho para que a arma também possa servir como ferramenta de resgate.",
			"neutral_reply": "Aelric aceita a lógica, mas continua claramente inquieto.",
			"bad_reply": "O olhar de Aelric endurece. Para ele, uma forja sem responsabilidade é apenas outra forma de perigo."
		}
	],
	"kobi_mercante": [
		{
			"id": "kobi_contrato_claro",
			"line": "Reescrevi um contrato inteiro sem letras pequenas. Ele ficou duas páginas mais curto e, estranhamente, as pessoas passaram a confiar mais em mim.",
			"good": "Confiança duradoura vale mais que uma vantagem escondida.",
			"neutral": "Desde que o contrato continue lucrativo, parece uma boa mudança.",
			"bad": "Você está desperdiçando oportunidades de proteger seus próprios interesses.",
			"good_reply": "Kobi tenta calcular o valor da confiança e acaba fechando o livro-caixa com um sorriso.",
			"neutral_reply": "Kobi concorda e começa a comparar margens com a versão antiga.",
			"bad_reply": "Kobi volta a folhear o contrato, dividido entre velhos hábitos e a pessoa que tenta se tornar."
		},
		{
			"id": "kobi_presente",
			"line": "Recebi uma cesta de pães como agradecimento. Não é pagamento, não é investimento e não possui valor de revenda. Ainda assim, não consigo parar de olhar para ela.",
			"good": "Talvez seja valiosa justamente porque foi dada sem obrigação.",
			"neutral": "Você pode registrar como presente comunitário.",
			"bad": "Pão estraga. Teria sido melhor pedir moedas.",
			"good_reply": "Kobi separa um pão para compartilhar e admite que algumas coisas rendem melhor quando não são vendidas.",
			"neutral_reply": "Kobi cria uma nova categoria contábil e parece aliviado por encontrar uma gaveta para o sentimento.",
			"bad_reply": "Kobi guarda a cesta, mas a alegria discreta desaparece do rosto."
		},
		{
			"id": "kobi_caravana",
			"line": "Uma caravana rival ofereceu uma rota muito lucrativa, mas ela deixaria duas aldeias pequenas sem abastecimento durante o inverno.",
			"good": "Lucro que abandona comunidades vulneráveis cobra um preço maior depois.",
			"neutral": "Negocie uma rota que preserve parte do abastecimento.",
			"bad": "Aceite antes que outro mercador perceba a oportunidade.",
			"good_reply": "Kobi rasga a proposta e começa a desenhar uma rota menos lucrativa, mas muito mais justa.",
			"neutral_reply": "Kobi abre mapas e calcula uma solução intermediária com entusiasmo profissional.",
			"bad_reply": "Kobi segura a pena sobre o contrato, mas não parece orgulhoso da escolha sugerida."
		},
		{
			"id": "kobi_pobreza",
			"line": "Quando eu era pequeno, uma semana ruim significava não comer. Às vezes acumulo moedas porque parte de mim ainda acredita que o vazio voltará amanhã.",
			"good": "Você não precisa enfrentar esse medo sozinho. Segurança também pode vir das pessoas.",
			"neutral": "Manter uma reserva razoável pode ajudar.",
			"bad": "Esse medo é útil. Ele mantém você produtivo.",
			"good_reply": "Kobi permanece em silêncio por um momento e deixa uma moeda sobre a mesa, em vez de guardá-la imediatamente.",
			"neutral_reply": "Kobi concorda e começa a calcular uma reserva que talvez finalmente pareça suficiente.",
			"bad_reply": "Kobi fecha o cofre com duas voltas extras na chave."
		},
		{
			"id": "kobi_parceria",
			"line": "Sempre achei que parceria fosse apenas dividir risco e lucro. Esta vila insiste em incluir confiança, cuidado e pessoas aparecendo sem agendamento.",
			"good": "Talvez a melhor parceria seja aquela em que ninguém precisa enfrentar tudo sozinho.",
			"neutral": "Podemos estabelecer horários para reduzir as interrupções.",
			"bad": "Você deveria manter negócios e sentimentos completamente separados.",
			"good_reply": "Kobi ri e admite que está começando a gostar das cláusulas que ninguém escreveu.",
			"neutral_reply": "Kobi considera criar um calendário de visitas, embora saiba que Mimo jamais o seguirá.",
			"bad_reply": "Kobi reorganiza os papéis entre vocês, usando o trabalho como distância."
		}
	],
	"orion_draconato": [
		{
			"id": "orion_cristal",
			"line": "Este cristal muda de cor perto de emoções fortes. Com Mimo ficou amarelo, com Brunna ficou vermelho e perto de você decidiu usar uma cor que não existe nos meus registros.",
			"good": "Nem tudo precisa caber em um registro para ser verdadeiro.",
			"neutral": "Talvez seja necessário recalibrar o cristal.",
			"bad": "Sua pesquisa provavelmente está errada.",
			"good_reply": "Orion observa a cor impossível e, pela primeira vez, não tenta nomeá-la.",
			"neutral_reply": "Orion prepara instrumentos, satisfeito por transformar o mistério em procedimento.",
			"bad_reply": "Orion recolhe o cristal e fica mais silencioso que o normal."
		},
		{
			"id": "orion_erro",
			"line": "Minha última experiência transformou três páginas de anotações em mariposas. Os dados foram perdidos, mas elas possuem padrões de mana fascinantes nas asas.",
			"good": "Um erro também pode revelar algo novo. Observe antes de se culpar.",
			"neutral": "Tente reproduzir o experimento com mais controle.",
			"bad": "Você deveria parar antes de causar um problema sério.",
			"good_reply": "Orion acompanha as mariposas com um sorriso e começa um novo caderno chamado 'Acidentes Promissores'.",
			"neutral_reply": "Orion instala barreiras extras e prepara uma repetição metódica.",
			"bad_reply": "Orion fecha os instrumentos e passa a revisar o erro sozinho."
		},
		{
			"id": "orion_duvida",
			"line": "As pessoas esperam que um pesquisador tenha respostas. Quanto mais aprendo, mais percebo quantas perguntas nem sequer sei formular.",
			"good": "Admitir o que não sabe torna sua busca mais honesta, não menos valiosa.",
			"neutral": "Você pode apresentar apenas conclusões confirmadas.",
			"bad": "Talvez você não seja tão preparado quanto todos pensam.",
			"good_reply": "Orion relaxa os ombros e admite que gostaria de compartilhar mais dúvidas com você.",
			"neutral_reply": "Orion organiza as notas em categorias de certeza e incerteza.",
			"bad_reply": "Orion retorna aos livros, determinado a esconder qualquer nova dúvida."
		},
		{
			"id": "orion_criaturas",
			"line": "Descobri uma espécie de espírito que se alimenta de sonhos ruins. Publicar a localização ajudaria pesquisadores, mas também atrairia caçadores.",
			"good": "Proteja as criaturas. Conhecimento sem responsabilidade pode virar exploração.",
			"neutral": "Compartilhe apenas com estudiosos de confiança.",
			"bad": "A descoberta pertence a você. Publique antes que alguém leve o crédito.",
			"good_reply": "Orion sela as coordenadas e agradece por confirmar uma decisão que já desejava tomar.",
			"neutral_reply": "Orion cria uma lista curta de pesquisadores e acrescenta várias camadas de proteção.",
			"bad_reply": "Orion encara o mapa, desconfortável com a ideia de trocar vidas por reconhecimento."
		},
		{
			"id": "orion_estrelas",
			"line": "As constelações mudam um pouco quando alguém encontra um lugar ao qual pertence. É quase imperceptível, mas o céu sobre a vila está diferente desde que chegamos.",
			"good": "Talvez o céu esteja refletindo que você também encontrou um lugar aqui.",
			"neutral": "Registre as mudanças para comparar no próximo ano.",
			"bad": "Você está atribuindo sentimentos a estrelas.",
			"good_reply": "Orion olha para o céu e depois para você, como se ambas as observações confirmassem a mesma teoria.",
			"neutral_reply": "Orion abre o mapa celeste e começa a marcar posições com precisão.",
			"bad_reply": "Orion fecha o telescópio antes do previsto."
		}
	],
	"rubra_meio_demonia": [
		{
			"id": "rubra_livro_vivo",
			"line": "Um grimório pediu autorização antes de abrir sozinho. Isso é progresso. Na semana passada ele apenas mordeu um leitor e alegou liberdade acadêmica.",
			"good": "Ensinar limites sem destruir a curiosidade parece um trabalho digno de você.",
			"neutral": "Talvez devêssemos guardar o livro em uma estante trancada.",
			"bad": "Queime antes que ele machuque alguém de novo.",
			"good_reply": "Rubra sorri e acrescenta uma regra de convivência ao marcador do grimório.",
			"neutral_reply": "Rubra concorda com uma quarentena temporária e prepara selos de segurança.",
			"bad_reply": "Rubra segura o livro com mais força, dividida entre segurança e o medo de ver conhecimento destruído."
		},
		{
			"id": "rubra_preconceito",
			"line": "Um visitante recusou minha ajuda quando percebeu minha linhagem. Depois voltou escondido para pedir exatamente o mesmo conselho.",
			"good": "A ignorância dele não diminui seu valor. Você decide se merece uma segunda chance.",
			"neutral": "Ajude apenas se isso beneficiar a vila.",
			"bad": "Talvez seja melhor esconder sua origem diante de visitantes.",
			"good_reply": "Rubra ergue o queixo e parece aliviada por não precisar diminuir a si mesma para ser aceita.",
			"neutral_reply": "Rubra avalia o pedido de forma prática, mantendo distância emocional.",
			"bad_reply": "Rubra fica em silêncio. A sugestão soa parecida demais com conselhos cruéis do passado."
		},
		{
			"id": "rubra_poema",
			"line": "Escrevi um poema e escondi dentro de um livro de contabilidade. Ninguém procura sentimentos entre despesas de manutenção.",
			"good": "Eu gostaria de ler, mas apenas quando você se sentir pronta para mostrar.",
			"neutral": "Esse realmente parece um esconderijo eficiente.",
			"bad": "Poesia não combina muito com você.",
			"good_reply": "Rubra entrega uma página dobrada, ainda sem encarar você diretamente.",
			"neutral_reply": "Rubra concorda e anota que Kobi é a maior ameaça à segurança do esconderijo.",
			"bad_reply": "Rubra guarda a página no bolso e muda de assunto."
		},
		{
			"id": "rubra_memoria",
			"line": "Alguns livros guardam memórias de antigos leitores. Um deles me mostrou uma família feliz que nunca conheci. Não sei se foi consolo ou crueldade.",
			"good": "Uma memória emprestada não substitui o passado, mas pode lembrar que você ainda pode construir algo seu.",
			"neutral": "Talvez seja melhor limitar o contato com esse livro.",
			"bad": "Você não deveria se apegar a vidas que nunca foram suas.",
			"good_reply": "Rubra fecha os olhos e admite que gostaria de criar lembranças que um dia valessem ser guardadas.",
			"neutral_reply": "Rubra envolve o livro em tecido protetor e registra seus efeitos.",
			"bad_reply": "Rubra devolve o livro à estante, parecendo ainda mais sozinha."
		},
		{
			"id": "rubra_historia",
			"line": "Toda história muda dependendo de quem segura a pena. Passei anos deixando outras pessoas escreverem quem eu era.",
			"good": "Então escreva sua própria versão. Eu quero conhecê-la pela sua voz.",
			"neutral": "Registrar os fatos com precisão pode ajudar.",
			"bad": "Talvez existam motivos para tantas pessoas contarem a mesma coisa sobre você.",
			"good_reply": "Rubra abre um caderno novo e escreve o próprio nome na primeira página.",
			"neutral_reply": "Rubra começa uma cronologia cuidadosa, protegendo-se atrás de datas e referências.",
			"bad_reply": "Rubra fecha o caderno sem escrever nada."
		}
	],
	"brunna_ana_barbara": [
		{
			"id": "brunna_treinamento",
			"line": "Os moradores querem aprender defesa. Metade segura lanças pelo lado errado e a outra metade acha que gritar é uma formação tática.",
			"good": "Ensine com paciência. Coragem cresce melhor quando ninguém precisa ter vergonha de aprender.",
			"neutral": "Comece pelos mais habilidosos e deixe que ajudem os demais.",
			"bad": "Quem não aprende rápido não serve para defender a vila.",
			"good_reply": "Brunna sorri e decide transformar cada erro em parte do treinamento, sem humilhar ninguém.",
			"neutral_reply": "Brunna organiza grupos por experiência e começa a planejar exercícios.",
			"bad_reply": "Brunna franze a testa. Para ela, força que despreza os fracos não merece respeito."
		},
		{
			"id": "brunna_descanso",
			"line": "Passei a manhã sem lutar, patrulhar ou levantar nada pesado. Foi desconfortável. Acho que o banco da praça venceu o duelo.",
			"good": "Descansar não apaga sua força. Também é parte de permanecer pronta.",
			"neutral": "Talvez uma caminhada leve ajude.",
			"bad": "Você está ficando preguiçosa.",
			"good_reply": "Brunna aceita a derrota para o banco e promete uma revanche apenas na próxima semana.",
			"neutral_reply": "Brunna parte para uma caminhada tranquila que provavelmente se tornará uma corrida.",
			"bad_reply": "Brunna se levanta imediatamente, escondendo o cansaço atrás de orgulho."
		},
		{
			"id": "brunna_companhia",
			"line": "Minha antiga companhia enviou uma caneca com nossos símbolos. Senti saudade das estradas, mas não da sensação de nunca pertencer a lugar algum.",
			"good": "Sentir saudade não significa que você escolheu o lar errado.",
			"neutral": "Você pode visitá-los quando a vila estiver segura.",
			"bad": "Talvez você devesse partir antes de criar raízes demais.",
			"good_reply": "Brunna coloca a caneca na cozinha comunitária, transformando uma lembrança de viagem em parte da casa atual.",
			"neutral_reply": "Brunna considera uma visita curta e começa a traçar rotas.",
			"bad_reply": "Brunna observa a estrada por tempo demais."
		},
		{
			"id": "brunna_cicatriz",
			"line": "Cicatrizes viram histórias porque as pessoas têm medo de admitir que algumas dores não trazem glória nenhuma.",
			"good": "Você não precisa transformar toda dor em lenda para que ela mereça cuidado.",
			"neutral": "Nem todas as histórias precisam ser contadas.",
			"bad": "Uma guerreira deveria carregar cicatrizes com orgulho, não questioná-las.",
			"good_reply": "Brunna toca uma cicatriz antiga e agradece por não exigir que ela sorria ao falar disso.",
			"neutral_reply": "Brunna concorda e guarda a história para outro momento.",
			"bad_reply": "Brunna ri alto demais e encerra a conversa."
		},
		{
			"id": "brunna_lar",
			"line": "Quando volto de uma patrulha e vejo as luzes da vila, meus passos aceleram. Antes eu fazia isso apenas quando havia batalha adiante.",
			"good": "Talvez agora você esteja correndo em direção a um lar, não a uma luta.",
			"neutral": "É bom que as patrulhas tenham um ponto de retorno seguro.",
			"bad": "Cuidado para não ficar sentimental demais.",
			"good_reply": "Brunna sorri com uma suavidade rara e admite que prefere esse tipo de pressa.",
			"neutral_reply": "Brunna concorda e transforma a emoção em comentário sobre segurança.",
			"bad_reply": "Brunna cruza os braços e volta a falar apenas de patrulhas."
		}
	]
}


const PERSONAL_EVENTS: Dictionary = {
	"passos_leves_faz_tudo": [
		{"title": "A Lista Perfeitamente Organizada", "premise": "Mimo decidiu organizar os suprimentos sozinha. A lista mistura farinha, telhas, três abraços e 'uma coisa redonda que parecia importante'.", "good": "Vamos organizar juntos. Sua ideia de ajudar é o que importa.", "neutral": "Vou conferir a lista antes que alguém use telhas na sopa.", "bad": "Você não deveria tentar tarefas importantes sozinha."},
		{"title": "O Pequeno Feitiço de Coragem", "premise": "Mimo encontrou um encanto que promete coragem. O feitiço funciona, mas somente quando ela admite do que sente medo.", "good": "Coragem não é não ter medo. É confiar em alguém enquanto ele existe.", "neutral": "Talvez seja melhor devolver o feitiço.", "bad": "Você tem medo de coisas bobas demais."},
		{"title": "A Festa que Quase Virou Portal", "premise": "Uma decoração feita por Mimo abriu uma fenda minúscula para um salão feérico. Música e borboletas invadem a praça.", "good": "Vamos transformar o acidente em uma festa inesquecível.", "neutral": "Feche o portal antes que piore.", "bad": "Você estraga tudo em que toca."},
		{"title": "A Melhor Amiga do Prefeito", "premise": "Mimo pergunta, sem conseguir olhar diretamente para você, se ainda será importante quando a vila estiver cheia de heróis, estudiosos e pessoas elegantes.", "good": "Você foi minha primeira amiga neste mundo. Nada substitui isso.", "neutral": "Você sempre terá trabalho na vila.", "bad": "Talvez seja hora de você amadurecer."}
	],
	"aelric_ferreiro": [
		{"title": "O Martelo sem Brasão", "premise": "Aelric revela que apagou o brasão da família de seu martelo ao abandonar uma forja que valorizava linhagem acima de talento.", "good": "O valor do martelo vem das mãos que o usam, não do brasão.", "neutral": "Você pode gravar um novo símbolo quando estiver pronto.", "bad": "Talvez sua família tivesse razão em cobrar mais de você."},
		{"title": "A Lâmina que Não Queria Ferir", "premise": "Uma lâmina rúnica se recusa a ser afiada para guerra. Aelric teme que sua magia esteja enfraquecendo.", "good": "Talvez a lâmina esteja lembrando que seu trabalho também pode proteger.", "neutral": "Podemos estudar a runa antes de decidir.", "bad": "Uma arma que não fere é apenas metal desperdiçado."},
		{"title": "A Forja do Próprio Nome", "premise": "Aelric recebe uma proposta para reabrir sua antiga oficina, longe da vila, com prestígio e riqueza.", "good": "Escolha o lugar onde seu trabalho tem significado, não onde seu nome soa maior.", "neutral": "Analise a proposta com calma.", "bad": "Seria tolice recusar prestígio por esta vila pequena."},
		{"title": "Brasa Guardada", "premise": "Aelric entrega a você um pequeno amuleto forjado com a primeira brasa da oficina da vila. Ele admite que não consegue mais separar seu futuro do seu.", "good": "Quero construir esse futuro ao seu lado.", "neutral": "Quero guardar este momento sem apressar o que sentimos.", "bad": "Eu não sinto o mesmo por você."}
	],
	"kobi_mercante": [
		{"title": "Uma Dívida sem Juros", "premise": "Kobi ajuda uma família sem cobrar nada e tenta esconder a ação dos próprios registros.", "good": "Generosidade não reduz seu talento. Ela mostra quem você escolhe ser.", "neutral": "Podemos registrar como investimento comunitário.", "bad": "Você perdeu uma oportunidade de lucro."},
		{"title": "O Contrato da Primeira Mentira", "premise": "Um antigo mentor oferece a Kobi um grande negócio baseado em enganar uma comunidade distante.", "good": "Você não precisa repetir as regras de quem ensinou você.", "neutral": "Negocie termos menos prejudiciais.", "bad": "Se o contrato é lucrativo, assine antes que outro assine."},
		{"title": "A Moeda sem Valor", "premise": "Kobi mostra uma moeda de madeira recebida quando criança, pagamento por salvar uma pequena caravana.", "good": "Essa parece ser a coisa mais valiosa que você possui.", "neutral": "É uma lembrança curiosa.", "bad": "Guardar madeira inútil não combina com um mercador."},
		{"title": "Cláusula do Coração", "premise": "Kobi apresenta um contrato com uma única frase: 'Gostaria de continuar escolhendo você, sem garantias de lucro'.", "good": "Eu aceito — sem letras pequenas.", "neutral": "Quero continuar próximo, mas ainda preciso de tempo.", "bad": "Nossa relação deve permanecer apenas profissional."}
	],
	"orion_draconato": [
		{"title": "O Sonho que Observava", "premise": "Orion sonha repetidamente com uma estrela que o chama pelo nome e teme estar sendo usado como passagem por alguma inteligência celeste.", "good": "Você não precisa enfrentar o desconhecido sozinho.", "neutral": "Registre o sonho e procure padrões.", "bad": "Talvez seja só sua imaginação exagerada."},
		{"title": "Escamas de Inverno", "premise": "Orion admite que sua família via suas escamas frias como sinal de mau presságio.", "good": "O frio em suas escamas não define o calor que você oferece aos outros.", "neutral": "Superstições familiares podem ser difíceis de abandonar.", "bad": "Talvez eles soubessem algo que você não sabe."},
		{"title": "A Teoria Incompleta", "premise": "Uma descoberta poderia tornar Orion famoso, mas ele percebe que publicar cedo colocaria criaturas mágicas em risco.", "good": "Conhecimento responsável vale mais que reconhecimento rápido.", "neutral": "Espere até ter dados mais seguros.", "bad": "A fama pode trazer recursos para corrigir os danos depois."},
		{"title": "Constelação Compartilhada", "premise": "Orion nomeou uma constelação provisória em homenagem a vocês dois e pergunta se pode torná-la oficial em seus mapas.", "good": "Quero olhar para esse céu ao seu lado por muitos anos.", "neutral": "Guarde o nome entre nós por enquanto.", "bad": "Prefiro não misturar sentimentos com sua pesquisa."}
	],
	"rubra_meio_demonia": [
		{"title": "O Livro que Sussurrava Culpa", "premise": "Um grimório repete antigos insultos dirigidos a Rubra. Ela sabe como silenciá-lo, mas hesita em destruir conhecimento.", "good": "Conhecimento que só produz crueldade não merece autoridade sobre você.", "neutral": "Sele o livro até encontrar uma solução melhor.", "bad": "Talvez ele apenas diga verdades difíceis."},
		{"title": "A Carta Nunca Enviada", "premise": "Rubra escreveu uma carta para a família que a rejeitou, mas nunca decidiu se deveria enviá-la.", "good": "Escreva por você. Enviar ou não deve servir à sua paz.", "neutral": "Espere até ter certeza.", "bad": "Eles não merecem ouvir nada de você."},
		{"title": "O Nome Verdadeiro", "premise": "Uma página encantada oferece revelar o verdadeiro nome mágico de Rubra em troca de uma memória feliz.", "good": "Nenhum segredo vale apagar uma parte boa de quem você é.", "neutral": "Pesquise outra forma de ler a página.", "bad": "Sacrifique a memória. Poder pode criar outras."},
		{"title": "Capítulo sem Final", "premise": "Rubra entrega um livro vazio intitulado 'Nós' e diz que gostaria de escrevê-lo com você, se seus sentimentos forem correspondidos.", "good": "Vamos escrever essa história juntos.", "neutral": "Quero continuar lendo devagar, sem fechar o livro.", "bad": "Prefiro que nossa história permaneça amizade."}
	],
	"brunna_ana_barbara": [
		{"title": "A Cicatriz sem Batalha", "premise": "Brunna revela que sua cicatriz mais visível veio de um acidente banal, não de uma batalha lendária, e teme parecer menos heroica.", "good": "Sobreviver não precisa ser uma lenda para ter valor.", "neutral": "Você não deve explicações a ninguém.", "bad": "Talvez seja melhor inventar uma história mais impressionante."},
		{"title": "O Machado Cansado", "premise": "O machado de Brunna começa a perder suas runas. Restaurá-las exigiria admitir que ela precisa da ajuda de outros.", "good": "Aceitar ajuda também é uma forma de força.", "neutral": "Aelric pode avaliar as runas.", "bad": "Uma guerreira deveria cuidar do próprio equipamento."},
		{"title": "A Estrada que Chamava", "premise": "Uma antiga companhia convida Brunna para uma expedição gloriosa e perigosa que pode durar anos.", "good": "Você pode escolher uma casa sem deixar de ser aventureira.", "neutral": "Talvez uma viagem curta ajude você a decidir.", "bad": "Você nunca foi feita para permanecer em um lugar."},
		{"title": "Promessa diante da Neve", "premise": "Brunna pergunta se pode chamar a vila de lar e você de razão para sempre retornar, mesmo quando novas estradas aparecerem.", "good": "Volte para mim. Este será nosso lar.", "neutral": "Quero continuar descobrindo isso ao seu lado.", "bad": "Não posso prometer esperar por você."}
	]
}


static func create_conversation(
	npc_id: String,
	season_id: String,
	relationship_data: Dictionary,
	player_profile: Dictionary,
	world_context: Dictionary = {},
	internal_test_mode: bool = false,
	campaign_seed: int = 1
) -> Dictionary:
	var data: Dictionary = _get_character_data(npc_id)
	if data.is_empty():
		return {}
	var is_partner: bool = bool(relationship_data.get("official_partner", false))
	var name: String = String(data.get("name", "Personagem"))
	var portrait_id: String = String(data.get("portrait_id", npc_id))
	var player_name: String = String(player_profile.get("name", "Prefeito"))
	var topic: Dictionary = _select_conversation_topic(
		npc_id,
		season_id,
		is_partner,
		String(relationship_data.get("last_conversation_topic_id", "")),
		world_context,
		campaign_seed
	)
	if topic.is_empty():
		return {}
	var topic_id: String = String(topic.get("id", "topic"))
	var line: String = String(topic.get("line", "A vila parece diferente hoje."))
	line = line.replace("{player_name}", player_name)
	var seasonal_key: String = "%s_%s_%s_%s" % [
		npc_id,
		season_id,
		"partner" if is_partner else "friendship",
		topic_id
	]
	var choices: Array[Dictionary] = [
		_make_choice(
			"good",
			String(topic.get("good", "...")),
			"good_reply",
			npc_id,
			"good",
			18,
			seasonal_key,
			topic_id,
			internal_test_mode
		),
		_make_choice(
			"neutral",
			String(topic.get("neutral", "...")),
			"neutral_reply",
			npc_id,
			"neutral",
			0,
			seasonal_key,
			topic_id,
			internal_test_mode
		),
		_make_choice(
			"bad",
			String(topic.get("bad", "...")),
			"bad_reply",
			npc_id,
			"bad",
			-10,
			seasonal_key,
			topic_id,
			internal_test_mode
		)
	]
	_shuffle_choices(choices, "%d|talk|%s|%s|%s|%d" % [
		campaign_seed,
		npc_id,
		season_id,
		topic_id,
		int(world_context.get("day", 1))
	])

	return {
		"id": "relationship_talk_%s_%s_%s" % [npc_id, season_id, topic_id],
		"title": "Conversa com %s" % name,
		"start": "opening",
		"allow_close": true,
		"relationship_npc_id": npc_id,
		"conversation_mode": "relationship_talk",
		"nodes": {
			"opening": {
				"speaker_id": portrait_id,
				"speaker_name": name,
				"expression": String(topic.get("expression", "neutral")),
				"text": line,
				"choices": choices
			},
			"good_reply": _reply_node(
				portrait_id,
				name,
				String(topic.get("good_reply", data.get("good_reply", ""))),
				"happy"
			),
			"neutral_reply": _reply_node(
				portrait_id,
				name,
				String(topic.get("neutral_reply", data.get("neutral_reply", ""))),
				"neutral"
			),
			"bad_reply": _reply_node(
				portrait_id,
				name,
				String(topic.get("bad_reply", data.get("bad_reply", ""))),
				"sad"
			)
		}
	}


static func create_personal_event(
	npc_id: String,
	event_id: String,
	relationship_data: Dictionary,
	official_partner_id: String,
	campaign_seed: int = 1,
	day_value: int = 1
) -> Dictionary:
	var data: Dictionary = _get_character_data(npc_id)
	var events: Array = _get_personal_events(npc_id)
	if data.is_empty() or events.is_empty():
		return {}
	var index: int = _event_index_from_id(event_id)
	if index < 0 or index >= events.size():
		return {}
	var event_data: Dictionary = events[index]
	var name: String = String(data.get("name", "Personagem"))
	var portrait_id: String = String(data.get("portrait_id", npc_id))
	var is_final_event: bool = index == 3
	var is_romance_final: bool = is_final_event and RELATIONSHIP_CATALOG_SCRIPT.is_romance_candidate(npc_id)
	var another_partner: bool = not official_partner_id.is_empty() and official_partner_id != npc_id
	var interest_markers: Array = relationship_data.get(
		"romance_interest_markers",
		[]
	) as Array
	var romance_ready: bool = (
		interest_markers.size() >= 2
		and not bool(relationship_data.get("romance_declined", false))
	)
	var good_action: String = ""
	var neutral_action: String = ""
	var bad_action: String = ""
	var good_text: String = String(event_data.get("good", ""))
	var neutral_text: String = String(event_data.get("neutral", ""))
	var bad_text: String = String(event_data.get("bad", ""))
	if is_final_event:
		var final_choices: Array[Dictionary] = []
		if is_romance_final and not another_partner and romance_ready:
			final_choices.append(
				_make_event_choice(
					"choose_romance",
					"Quero iniciar um romance e construir esse futuro ao seu lado.",
					"romance_reply",
					npc_id,
					event_id,
					"good",
					45,
					"commit_romance"
				)
			)
		final_choices.append(
			_make_event_choice(
				"choose_friendship",
				(
					"Quero que este vínculo se torne uma amizade profunda, inteira e escolhida."
					if not (is_romance_final and another_partner)
					else "Você é muito importante para mim. Quero preservar uma amizade profunda e respeitar meu compromisso atual."
				),
				"friendship_reply",
				npc_id,
				event_id,
				"good",
				25,
				"respectful_friendship"
			)
		)
		final_choices.append(
			_make_event_choice(
				"decide_later",
				"Ainda não estou pronto para definir nosso caminho. Quero decidir depois.",
				"defer_reply",
				npc_id,
				event_id,
				"neutral",
				0,
				"defer_relationship_decision"
			)
		)
		return _create_final_personal_event(
			npc_id,
			event_id,
			name,
			portrait_id,
			event_data,
			final_choices
		)

	var choices: Array[Dictionary] = [
		_make_event_choice("good", good_text, "good_reply", npc_id, event_id, "good", 35 if not is_romance_final else 45, good_action),
		_make_event_choice(
			"neutral",
			neutral_text,
			"neutral_reply",
			npc_id,
			event_id,
			"neutral",
			0 if is_romance_final else 10,
			neutral_action
		),
		_make_event_choice("bad", bad_text, "bad_reply", npc_id, event_id, "bad", -15, bad_action)
	]
	if index in [1, 2] and RELATIONSHIP_CATALOG_SCRIPT.is_romance_candidate(npc_id):
		var interest_text: String = EXPANSION_CATALOG_SCRIPT.get_interest_choice(
			npc_id,
			index - 1
		)
		if not interest_text.is_empty() and not interest_markers.has(event_id):
			choices.append(
				_make_event_choice(
					"show_interest",
					interest_text,
					"interest_reply",
					npc_id,
					event_id,
					"good",
					25,
					"record_romance_interest",
					event_id
				)
			)
	_shuffle_choices(choices, "%d|personal|%s|%s|%d" % [
		campaign_seed,
		npc_id,
		event_id,
		day_value
	])

	return {
		"id": event_id,
		"title": String(event_data.get("title", "Evento pessoal")),
		"start": "opening",
		"allow_close": false,
		"relationship_npc_id": npc_id,
		"conversation_mode": "personal_event",
		"personal_event_id": event_id,
		"nodes": {
			"opening": {
				"speaker_id": "",
				"speaker_name": "Narrador",
				"hide_portrait": true,
				"text": String(event_data.get("premise", "")),
				"choices": choices
			},
			"good_reply": _reply_node(portrait_id, name, _event_reply_text(npc_id, index, "good", good_action), "happy"),
			"neutral_reply": _reply_node(portrait_id, name, _event_reply_text(npc_id, index, "neutral", neutral_action), "neutral"),
			"bad_reply": _reply_node(portrait_id, name, _event_reply_text(npc_id, index, "bad", bad_action), "sad"),
			"interest_reply": _reply_node(
				portrait_id,
				name,
				"A sinceridade muda a proximidade entre vocês. O interesse foi compreendido sem transformar o momento em compromisso.",
				"affectionate"
			)
		}
	}


static func _create_final_personal_event(
	npc_id: String,
	event_id: String,
	name: String,
	portrait_id: String,
	event_data: Dictionary,
	choices: Array[Dictionary]
) -> Dictionary:
	var image_path: String = RELATIONSHIP_CATALOG_SCRIPT.get_scene_800_image_path(
		npc_id
	)
	return {
		"id": event_id,
		"title": String(event_data.get("title", "Decisão do vínculo")),
		"start": "opening",
		"allow_close": false,
		"relationship_npc_id": npc_id,
		"conversation_mode": "personal_event_800",
		"personal_event_id": event_id,
		"scene_image_path": image_path,
		"scene_image_alt": (
			"Ilustração da cena de 800 pontos com %s e o Golem-Prefeito."
			% name
		),
		"scene_image_caption": "800 PONTOS — DECISÃO DO VÍNCULO",
		"scene_fallback_portrait_id": portrait_id,
		"scene_fallback_name": name,
		"nodes": {
			"opening": {
				"speaker_id": "",
				"speaker_name": "Narrador",
				"hide_portrait": true,
				"text": (
					String(event_data.get("premise", ""))
					+ "\n\nEsta escolha definirá o caminho do vínculo. Você também pode decidir depois."
				),
				"choices": choices
			},
			"romance_reply": _reply_node(
				portrait_id,
				name,
				"A resposta muda o silêncio entre vocês. Sem cerimônia grandiosa, os dois escolhem iniciar um romance e construir algo juntos.",
				"affectionate"
			),
			"friendship_reply": _reply_node(
				portrait_id,
				name,
				"A escolha é recebida com honestidade e respeito. O vínculo continua como amizade profunda, sem punição e sem apagar o que viveram.",
				"happy"
			),
			"defer_reply": _reply_node(
				portrait_id,
				name,
				"A decisão permanece aberta. Nada é encerrado e a cena continuará disponível quando você quiser retomá-la.",
				"neutral"
			)
		}
	}


static func create_date_conversation(
	npc_id: String,
	season_id: String,
	campaign_seed: int = 1,
	day_value: int = 1
) -> Dictionary:
	var data: Dictionary = _get_character_data(npc_id)
	if data.is_empty():
		return {}
	var name: String = String(data.get("name", "Personagem"))
	var portrait_id: String = String(data.get("portrait_id", npc_id))
	var partner_lines: Dictionary = data.get("partner_lines", {}) as Dictionary
	var line: String = String(partner_lines.get(season_id, "É bom ter um momento longe das responsabilidades."))
	var choices: Array[Dictionary] = [
		_make_date_choice("good", "Quero aproveitar este momento apenas com você.", "good_reply", npc_id, "good", 24),
		_make_date_choice("neutral", "É bom descansar um pouco.", "neutral_reply", npc_id, "neutral", 0),
		_make_date_choice("bad", "Precisamos voltar logo ao trabalho.", "bad_reply", npc_id, "bad", -8)
	]
	_shuffle_choices(choices, "%d|date|%s|%s|%d" % [
		campaign_seed,
		npc_id,
		season_id,
		day_value
	])
	return {
		"id": "relationship_date_%s_%s" % [npc_id, season_id],
		"title": "Encontro com %s" % name,
		"start": "opening",
		"allow_close": false,
		"relationship_npc_id": npc_id,
		"conversation_mode": "date",
		"nodes": {
			"opening": {
				"speaker_id": portrait_id,
				"speaker_name": name,
				"expression": "affectionate",
				"text": line,
				"choices": choices
			},
			"good_reply": _reply_node(portrait_id, name, "O encontro termina com uma proximidade tranquila, distante por alguns instantes das planilhas da vila.", "happy"),
			"neutral_reply": _reply_node(portrait_id, name, "O momento é simples e sereno. Nem todo encontro precisa mudar o mundo.", "neutral"),
			"bad_reply": _reply_node(portrait_id, name, "O passeio termina cedo. A responsabilidade permanece, mas o silêncio entre vocês pesa um pouco.", "sad")
		}
	}


static func _select_conversation_topic(
	npc_id: String,
	season_id: String,
	is_partner: bool,
	last_topic_id: String,
	world_context: Dictionary = {},
	campaign_seed: int = 1
) -> Dictionary:
	var data: Dictionary = _get_character_data(npc_id)
	var topic_values: Variant = _get_conversation_topics(npc_id)
	var topics: Array[Dictionary] = []
	if topic_values is Array:
		for topic_value: Variant in topic_values:
			if topic_value is Dictionary:
				topics.append((topic_value as Dictionary).duplicate(true))

	var line_source: Dictionary = (
		data.get("partner_lines", {}) as Dictionary
		if is_partner
		else data.get("season_lines", {}) as Dictionary
	)
	var seasonal_line: String = String(
		line_source.get(season_id, "A vila parece diferente hoje.")
	)
	var seasonal_id: String = "season_%s_%s" % [
		season_id,
		"partner" if is_partner else "friendship"
	]
	topics.append({
		"id": seasonal_id,
		"line": seasonal_line,
		"good": _response_text(data, "good", seasonal_id),
		"neutral": _response_text(data, "neutral", seasonal_id),
		"bad": _response_text(data, "bad", seasonal_id),
		"good_reply": String(data.get("good_reply", "A resposta aproxima vocês.")),
		"neutral_reply": String(data.get("neutral_reply", "A conversa segue sem grande mudança.")),
		"bad_reply": String(data.get("bad_reply", "A resposta cria distância."))
	})

	if season_id in ["autumn", "winter"]:
		var warning_line: String = String(data.get("winter_warning", "")).strip_edges()
		if not warning_line.is_empty():
			var warning_id: String = "winter_preparation_%s" % season_id
			topics.append({
				"id": warning_id,
				"line": warning_line,
				"good": "Vou priorizar as reservas antes que o frio chegue.",
				"neutral": "Vamos acompanhar os números por mais alguns dias.",
				"bad": "O inverno não deve ser tão complicado assim.",
				"good_reply": String(data.get("good_reply", "A resposta transmite segurança.")),
				"neutral_reply": String(data.get("neutral_reply", "A preocupação continua.")),
				"bad_reply": String(data.get("bad_reply", "A resposta causa preocupação."))
			})

	var village_topic: Dictionary = EXPANSION_CATALOG_SCRIPT.get_village_topic(
		npc_id,
		world_context
	)
	if not village_topic.is_empty():
		topics.append(village_topic)

	var available: Array[Dictionary] = []
	for topic: Dictionary in topics:
		if String(topic.get("id", "")) != last_topic_id:
			available.append(topic)
	if available.is_empty():
		available = topics
	if available.is_empty():
		return {}
	var topic_seed: int = CAMPAIGN_IDENTITY_CATALOG_SCRIPT.seed_from_text(
		"%d|topic|%s|%s|%s|%d" % [
			campaign_seed,
			npc_id,
			season_id,
			last_topic_id,
			int(world_context.get("day", 1))
		]
	)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = topic_seed
	var selected_index: int = rng.randi_range(0, available.size() - 1)
	return available[selected_index].duplicate(true)


static func _shuffle_choices(choices: Array[Dictionary], seed_text: String) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = CAMPAIGN_IDENTITY_CATALOG_SCRIPT.seed_from_text(seed_text)
	for index: int in range(choices.size() - 1, 0, -1):
		var swap_index: int = rng.randi_range(0, index)
		var temporary: Dictionary = choices[index]
		choices[index] = choices[swap_index]
		choices[swap_index] = temporary


static func _response_text(data: Dictionary, key: String, seed_text: String) -> String:
	var values_value: Variant = data.get(key, [])
	if not values_value is Array:
		return "..."
	var values: Array = values_value as Array
	if values.is_empty():
		return "..."
	var selected_index: int = abs((key + seed_text).hash()) % values.size()
	return String(values[selected_index])


static func _make_choice(
	id: String,
	text: String,
	next: String,
	npc_id: String,
	quality: String,
	points: int,
	seasonal_key: String,
	topic_id: String,
	internal_test_mode: bool = false
) -> Dictionary:
	return {
		"id": id,
		"text": text,
		"next": next,
		"relationship_npc_id": npc_id,
		"relationship_quality": quality,
		"relationship_points": points,
		"relationship_action": "conversation",
		"seasonal_dialogue_key": seasonal_key,
		"relationship_topic_id": topic_id,
		"relationship_internal_test": internal_test_mode
	}


static func _make_event_choice(
	id: String,
	text: String,
	next: String,
	npc_id: String,
	event_id: String,
	quality: String,
	points: int,
	action: String,
	interest_marker: String = ""
) -> Dictionary:
	var result: Dictionary = {
		"id": id,
		"text": text,
		"next": next,
		"relationship_npc_id": npc_id,
		"relationship_quality": quality,
		"relationship_points": points,
		"relationship_action": action if not action.is_empty() else "personal_event",
		"personal_event_id": event_id
	}
	if not interest_marker.is_empty():
		result["romance_interest_marker"] = interest_marker
	return result


static func _make_date_choice(id: String, text: String, next: String, npc_id: String, quality: String, points: int) -> Dictionary:
	return {"id": id, "text": text, "next": next, "relationship_npc_id": npc_id, "relationship_quality": quality, "relationship_points": points, "relationship_action": "date"}


static func _reply_node(
	portrait_id: String,
	name: String,
	text: String,
	expression: String = "neutral"
) -> Dictionary:
	return {
		"speaker_id": portrait_id,
		"speaker_name": name,
		"expression": expression,
		"text": text
	}


static func _event_index_from_id(event_id: String) -> int:
	var parts: PackedStringArray = event_id.split("_personal_", false)
	if parts.size() != 2 or not parts[1].is_valid_int():
		return -1
	return int(parts[1]) - 1


static func _event_reply_text(npc_id: String, _index: int, quality: String, action: String) -> String:
	if action == "commit_romance":
		return "A resposta muda o silêncio entre vocês. Não há cerimônia grandiosa — apenas a escolha clara de construir algo juntos."
	if action == "romance_interest":
		return "O sentimento permanece aberto, sem promessa apressada. Há carinho e a possibilidade de um futuro diferente."
	if action in ["decline_romance", "respectful_friendship"]:
		return "A conversa dói um pouco, mas termina com honestidade e respeito. A amizade poderá continuar sem punições ou ciúmes."
	var data: Dictionary = _get_character_data(npc_id)
	match quality:
		"good":
			return String(data.get("good_reply", "A resposta aproxima vocês."))
		"bad":
			return String(data.get("bad_reply", "A resposta cria distância."))
		_:
			return String(data.get("neutral_reply", "A conversa segue sem grande mudança."))


static func _get_character_data(npc_id: String) -> Dictionary:
	var data: Dictionary = (CHARACTER_DATA.get(npc_id, {}) as Dictionary).duplicate(true)
	if data.is_empty():
		data = EXPANSION_CATALOG_SCRIPT.get_character_data(npc_id)
	return data


static func _get_conversation_topics(npc_id: String) -> Array:
	var topics: Array = (CONVERSATION_TOPICS.get(npc_id, []) as Array).duplicate(true)
	if topics.is_empty():
		topics = EXPANSION_CATALOG_SCRIPT.get_conversation_topics(npc_id)
	return topics


static func _get_personal_events(npc_id: String) -> Array:
	var events: Array = (PERSONAL_EVENTS.get(npc_id, []) as Array).duplicate(true)
	if events.is_empty():
		events = EXPANSION_CATALOG_SCRIPT.get_personal_events(npc_id)
	return events
