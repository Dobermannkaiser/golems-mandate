class_name VillageNpcRelationshipCatalog
extends RefCounted


const NPCS: Dictionary = {
	"passos_leves_faz_tudo": {"name": "Mimo", "portrait_id": "mimo", "arrival": 1},
	"aelric_ferreiro": {"name": "Aelric", "portrait_id": "aelric_ferreiro", "arrival": 15},
	"kobi_mercante": {"name": "Kobi", "portrait_id": "kobi_mercante", "arrival": 30},
	"orion_draconato": {"name": "Orion", "portrait_id": "orion_draconato", "arrival": 45},
	"rubra_meio_demonia": {"name": "Rubra", "portrait_id": "rubra_meio_demonia", "arrival": 60},
	"brunna_ana_barbara": {"name": "Brunna", "portrait_id": "brunna_ana_barbara", "arrival": 75},
	"meio_vampiro_emo_gotico": {"name": "Silas", "portrait_id": "meio_vampiro_emo_gotico", "arrival": 90},
	"bruxinha_ruiva": {"name": "Dália", "portrait_id": "bruxinha_ruiva", "arrival": 105}
}

# Cada entrada define uma combinação única. Os dois assuntos são continuações
# persistentes, nunca encontros aleatórios repetíveis.
static func _build_pairs() -> Array[Dictionary]:
	return [
	_pair("passos_leves_faz_tudo", "aelric_ferreiro", 5, 15, "Etiquetas na oficina", "Mimo reorganizou pequenas ferramentas por desenhos; Aelric teme perder o controle da forja.", "Ferramentas para aprendizes", "Aelric quer regras rígidas; Mimo propõe uma bancada segura para quem está começando."),
	_pair("passos_leves_faz_tudo", "kobi_mercante", 10, 30, "Preço ou presente", "Mimo distribuiu parte de uma encomenda que Kobi pretendia vender.", "Feira de trocas", "Kobi quer registros claros; Mimo defende uma mesa onde vizinhos possam trocar sem moedas."),
	_pair("aelric_ferreiro", "kobi_mercante", -5, 32, "Prazo da encomenda", "Kobi prometeu ferramentas antes de consultar o ritmo da forja.", "Qualidade e custo", "Aelric recusa metal barato; Kobi teme que o preço afaste moradores."),
	_pair("passos_leves_faz_tudo", "orion_draconato", 15, 45, "A panela curiosa", "Orion quer estudar a panela falante de Mimo; ela exige que ele a trate como convidada.", "Experimento no jardim", "Um cristal de Orion fez as abóboras cantar e Mimo quer transformar isso em apresentação."),
	_pair("aelric_ferreiro", "orion_draconato", -15, 47, "Runas na forja", "Orion propõe runas experimentais; Aelric não aceita riscos perto dos aprendizes.", "Precisão ou experiência", "As medições de Orion contradizem o método tradicional de têmpera de Aelric."),
	_pair("kobi_mercante", "orion_draconato", 0, 49, "Cristais à venda", "Kobi vê mercado nos cristais de Orion; o pesquisador teme promessas exageradas.", "Financiamento da pesquisa", "Orion precisa de materiais; Kobi quer um relatório de resultados antes de investir."),
	_pair("passos_leves_faz_tudo", "rubra_meio_demonia", 20, 60, "Livro com migalhas", "Rubra encontrou migalhas num grimório emprestado a Mimo.", "Histórias para todos", "Mimo quer leituras na praça; Rubra teme danificar livros raros fora da biblioteca."),
	_pair("aelric_ferreiro", "rubra_meio_demonia", 5, 62, "Manual antigo", "Rubra encontrou uma técnica esquecida; Aelric desconfia de instruções nunca testadas.", "Memória da oficina", "Rubra quer registrar cada método; Aelric acredita que parte do ofício vive nas mãos."),
	_pair("kobi_mercante", "rubra_meio_demonia", 10, 64, "Taxa de cópia", "Kobi propõe cobrar por cópias; Rubra quer acesso público ao conhecimento essencial.", "Contrato arquivado", "Rubra exige linguagem simples; Kobi insiste que detalhes evitam disputas futuras."),
	_pair("orion_draconato", "rubra_meio_demonia", 35, 66, "Fonte conflitante", "Os livros de Rubra contradizem uma leitura mágica de Orion.", "Conhecimento perigoso", "Orion quer testar um ritual antigo; Rubra considera que ainda faltam salvaguardas."),
	_pair("passos_leves_faz_tudo", "brunna_ana_barbara", 25, 75, "Treino de espantalho", "Brunna usou o espantalho favorito de Mimo num treino de machado.", "Patrulha com sinos", "Mimo criou alarmes barulhentos; Brunna teme que também avisem intrusos."),
	_pair("aelric_ferreiro", "brunna_ana_barbara", 30, 77, "Machado lascado", "Brunna quer conserto imediato; Aelric diz que o uso descuidado causará outra quebra.", "Equipamento pesado", "Aelric prioriza proteção; Brunna precisa de mobilidade nas trilhas."),
	_pair("kobi_mercante", "brunna_ana_barbara", -10, 79, "Escolta comercial", "Kobi planejou uma rota longa; Brunna considera a recompensa pequena para o risco.", "Suprimentos de patrulha", "Brunna quer reservas extras; Kobi teme esvaziar o estoque da vila."),
	_pair("orion_draconato", "brunna_ana_barbara", 0, 81, "Atalho instável", "Orion sugere um portal curto; Brunna prefere uma trilha que possa inspecionar.", "Teoria e prática", "Brunna interrompe medições para resolver o problema diretamente; Orion pede observação antes da ação."),
	_pair("rubra_meio_demonia", "brunna_ana_barbara", 20, 83, "Relato de aventura", "Rubra quer detalhes precisos; Brunna melhora a história sempre que a conta.", "Ruína protegida", "Brunna quer explorar uma ruína; Rubra acredita que inscrições devem ser preservadas primeiro."),
	_pair("passos_leves_faz_tudo", "meio_vampiro_emo_gotico", 30, 90, "Ensaio noturno", "Mimo quer acompanhar a música de Silas com panelas; ele pede uma apresentação mais discreta.", "Canção da praça", "Silas escreveu algo melancólico; Mimo quer um refrão que todos possam cantar."),
	_pair("aelric_ferreiro", "meio_vampiro_emo_gotico", 0, 92, "Silêncio da madrugada", "Silas ensaia tarde; Aelric começa a forjar antes do amanhecer e ambos culpam o ruído do outro.", "Metal em harmonia", "Silas quer usar sons da forja numa música; Aelric teme atrapalhar o trabalho."),
	_pair("kobi_mercante", "meio_vampiro_emo_gotico", -5, 94, "Música patrocinada", "Kobi oferece divulgação; Silas não quer que sua canção pareça propaganda.", "Ingresso ou praça", "Kobi propõe bilhetes; Silas prefere uma apresentação aberta à comunidade."),
	_pair("orion_draconato", "meio_vampiro_emo_gotico", 20, 96, "Eco mágico", "Orion quer medir um eco na voz de Silas; ele não quer ser tratado como fenômeno.", "Música das estrelas", "Orion fornece cálculos; Silas diz que uma canção precisa respirar fora das fórmulas."),
	_pair("rubra_meio_demonia", "meio_vampiro_emo_gotico", 40, 98, "Poema musicado", "Rubra oferece um poema antigo; Silas quer alterar versos para que funcionem como canção.", "Arquivo de canções", "Rubra deseja registrar cada versão; Silas valoriza mudanças feitas ao vivo."),
	_pair("brunna_ana_barbara", "meio_vampiro_emo_gotico", 5, 100, "Volume na taverna", "Brunna pede uma música mais animada; Silas não quer abandonar seu estilo.", "Vigília na muralha", "Silas quer tocar durante a vigília; Brunna teme distração na patrulha."),
	_pair("passos_leves_faz_tudo", "bruxinha_ruiva", 45, 105, "Composto aventureiro", "Mimo deu nome à pilha de composto; Dália precisa que ninguém a alimente com objetos aleatórios.", "Sementes viajantes", "Dália separou sementes raras; Mimo já prometeu algumas a todos os vizinhos."),
	_pair("aelric_ferreiro", "bruxinha_ruiva", 10, 107, "Cinzas da forja", "Dália quer usar cinzas no cultivo; Aelric teme que resíduos prejudiquem o solo.", "Ferramentas de cultivo", "Aelric prioriza durabilidade; Dália pede ferramentas leves para trabalho cuidadoso."),
	_pair("kobi_mercante", "bruxinha_ruiva", 0, 109, "Ervas no mercado", "Kobi quer padronizar preços; Dália reserva parte das ervas para remédios comunitários.", "Colheita antecipada", "Kobi vê demanda imediata; Dália diz que as plantas precisam de mais tempo."),
	_pair("orion_draconato", "bruxinha_ruiva", 35, 111, "Mana nas raízes", "Orion quer isolar a causa de um crescimento incomum; Dália prefere observar o ciclo completo.", "Estufa experimental", "Orion propõe cristais de calor; Dália exige proteção para o equilíbrio do solo."),
	_pair("rubra_meio_demonia", "bruxinha_ruiva", 50, 113, "Receita incompleta", "Rubra confia num herbário antigo; Dália percebe que a receita ignora o clima local.", "Histórias das sementes", "Rubra quer catalogar origens; Dália prefere que os agricultores também contem suas versões."),
	_pair("brunna_ana_barbara", "bruxinha_ruiva", 15, 115, "Trilha medicinal", "Brunna quer abrir uma passagem rápida; Dália teme destruir ervas que só crescem ali.", "Horta protegida", "Brunna propõe uma cerca robusta; Dália quer passagem para pequenos animais úteis."),
	_pair("meio_vampiro_emo_gotico", "bruxinha_ruiva", 40, 117, "Música para brotos", "Dália diz que música ajuda o cultivo; Silas não quer transformar toda apresentação em ferramenta de trabalho.", "Festival ao entardecer", "Silas prefere luz baixa; Dália quer um horário em que agricultores ainda possam participar.")
]


static func _pair(a: String, b: String, initial_score: int, first_day: int, first_title: String, first_premise: String, second_title: String, second_premise: String) -> Dictionary:
	return {
		"a": a, "b": b, "initial_score": initial_score,
		"dialogues": [
			{"id": "%s__%s__1" % [a, b], "day": first_day, "title": first_title, "premise": first_premise},
			{"id": "%s__%s__2" % [a, b], "day": first_day + 1, "title": second_title, "premise": second_premise}
		]
	}


static func get_pair_key(a: String, b: String) -> String:
	return "%s|%s" % [a, b] if a < b else "%s|%s" % [b, a]


static func get_npc(npc_id: String) -> Dictionary:
	return (NPCS.get(npc_id, {}) as Dictionary).duplicate(true)


static func get_all_pairs() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for pair: Dictionary in _build_pairs():
		result.append(pair.duplicate(true))
	return result


static func get_dialogue_for_day(day: int) -> Dictionary:
	for pair: Dictionary in _build_pairs():
		var dialogues: Array = pair.get("dialogues", []) as Array
		for index: int in range(dialogues.size()):
			var dialogue: Dictionary = dialogues[index] as Dictionary
			if int(dialogue.get("day", 0)) == day:
				var result: Dictionary = dialogue.duplicate(true)
				result["a"] = String(pair.get("a", ""))
				result["b"] = String(pair.get("b", ""))
				result["pair_key"] = get_pair_key(result["a"], result["b"])
				result["index"] = index
				return result
	return {}


static func validate_catalog() -> Dictionary:
	var errors: Array[String] = []
	var pair_keys: Dictionary = {}
	var dialogue_ids: Dictionary = {}
	var days: Dictionary = {}
	for pair: Dictionary in _build_pairs():
		var a: String = String(pair.get("a", ""))
		var b: String = String(pair.get("b", ""))
		var key: String = get_pair_key(a, b)
		if a == b or not NPCS.has(a) or not NPCS.has(b) or pair_keys.has(key):
			errors.append("Par inválido ou repetido: %s" % key)
		pair_keys[key] = true
		var dialogues: Array = pair.get("dialogues", []) as Array
		if dialogues.size() != 2:
			errors.append("%s não possui dois diálogos." % key)
		for value: Variant in dialogues:
			var dialogue: Dictionary = value as Dictionary
			var dialogue_id: String = String(dialogue.get("id", ""))
			var day: int = int(dialogue.get("day", 0))
			if dialogue_ids.has(dialogue_id) or days.has(day):
				errors.append("Diálogo ou dia repetido: %s / %d" % [dialogue_id, day])
			dialogue_ids[dialogue_id] = true
			days[day] = true
	return {"success": errors.is_empty(), "errors": errors, "pair_count": pair_keys.size(), "dialogue_count": dialogue_ids.size(), "choice_count": dialogue_ids.size() * 4}
