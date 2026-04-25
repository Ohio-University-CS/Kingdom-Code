class_name PlayerPawnStateIdle extends State

@onready var walk: State = $"../Walk"

func enter() -> void:
	if EventBus.currentBlock != null:
		if !EventBus.currentBlock.is_in_group("DashBlock"):
			pawn.animation_player.play("idle")
			print("standing idle")

func process_state(delta: float) -> State:
	if EventBus.movementDirection != Vector2.ZERO:
		return walk 
	return self
