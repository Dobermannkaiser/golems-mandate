extends SceneTree


const RELATIONSHIP_STATE_SCRIPT = preload(
	"res://scripts/models/RelationshipState.gd"
)


func _initialize() -> void:
	var relationship = RELATIONSHIP_STATE_SCRIPT.new()
	if not relationship.setup("diagnostic_relationship", true):
		push_error("Não foi possível preparar o vínculo de teste.")
		quit(1)
		return

	for topic_index: int in range(3):
		var applied: int = relationship.register_conversation(
			1,
			"good",
			18,
			"diagnostic_topic_%d" % topic_index,
			true
		)
		if applied != 18:
			push_error("A conversa interna %d aplicou %d ponto(s)." % [topic_index + 1, applied])
			quit(1)
			return

	if relationship.relationship_points != 54:
		push_error("Três conversas internas deveriam somar 54 pontos.")
		quit(1)
		return
	if relationship.last_conversation_day != 0:
		push_error("O Teste Interno consumiu a conversa normal do dia.")
		quit(1)
		return

	var normal_applied: int = relationship.register_conversation(
		1,
		"good",
		18,
		"normal_topic"
	)
	if normal_applied != 18 or relationship.relationship_points != 72:
		push_error("A conversa normal não permaneceu disponível após o teste interno.")
		quit(1)
		return
	if relationship.register_conversation(1, "good", 18, "blocked_topic") != 0:
		push_error("O limite diário do jogo normal deixou de funcionar.")
		quit(1)
		return

	print("Teste Interno de relacionamentos v3.8.2: APROVADO")
	quit(0)
