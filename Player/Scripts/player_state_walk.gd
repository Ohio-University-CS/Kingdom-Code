class_name PlayerPawnStateWalk extends State

@onready var idle: State = $"../Idle"

func enter() -> void:
	pawn.animation_player.play("walk")

func process_state(delta: float) -> State:
	if EventBus.movementDirection == Vector2.ZERO:
		return idle

	
	return self
