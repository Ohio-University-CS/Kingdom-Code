class_name PlayerPawnStateIdle extends State

@onready var walk: State = $"../Walk"

func enter() -> void:
	pawn.animation_player.play("idle")

func process_state(delta: float) -> State:
	if EventBus.movementDirection != Vector2.ZERO:
		return walk 
	return self
