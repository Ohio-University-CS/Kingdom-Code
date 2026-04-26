class_name PlayerPawnStateWalk extends State

@onready var idle: State = $"../Idle"

func enter() -> void:
	if EventBus.currentBlock != null:
		if !EventBus.currentBlock.is_in_group("DashBlock"):
			pawn.animation_player.play("walk")
			#print("walking forwards")

func process_state(delta: float) -> State:
	if EventBus.movementDirection == Vector2.ZERO:
		return idle

	
	return self
