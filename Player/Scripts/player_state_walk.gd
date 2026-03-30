class_name PlayerPawnStateWalk extends State

@onready var idle: State = $"../Idle"

func enter() -> void:
	pawn.animation_player.play("walk")

func process_state(delta: float) -> State:
	if EventBus.movementDirection == Vector2.ZERO:
		return idle

	process_position(delta)
	
	return self

func process_position(_delta: float) -> void:
	if not pawn.is_on_floor():
		pawn.velocity.y += pawn.gravity
	else:
		pawn.velocity.y = EventBus.movementDirection.y * 150 ## jump height

	pawn.velocity.x = EventBus.movementDirection.x * pawn.speed
	pawn.move_and_slide()
		
