class_name PlayerPawnStateIdle extends State

@onready var walk: State = $"../Walk"

func enter() -> void:
	pawn.animation_player.play("idle")

func process_state(delta: float) -> State:
	if EventBus.movementDirection != Vector2.ZERO:
		return walk 

	process_position(delta)
	
	return self

func process_position(_delta: float) -> void:
	if not pawn.is_on_floor():
		pawn.velocity.y += pawn.gravity
	else:
		pawn.velocity.y = 0

	pawn.move_and_slide()
