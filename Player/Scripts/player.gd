extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine

var speed = 50 ## this is test movement code to experiment with, not the users movement code 
var gravity = 9.8

func _ready() -> void:
	state_machine.init(self)

var moved = 0
var distance_to_move = 16
var testing = global_position.x
func _physics_process(delta: float) -> void:
	state_machine.process_update(delta)
	global_position = global_position.round()
	
	if not is_on_floor():
		velocity.y += gravity
	else:
		velocity.y = EventBus.movementDirection.y * 150 ## jump height

	velocity.x = EventBus.movementDirection.x * speed
	move_and_slide()
	
	#if moved < distance_to_move:
		#var step = speed * delta
		#step = min(step, distance_to_move - moved)
		#velocity.x = step / delta
		#
		#move_and_slide()
		#
		#moved += step
	#else:
		#velocity.x = 0
		#print(global_position.x - testing)
		#testing = global_position.x
		#if EventBus.movementDirection != Vector2.ZERO:
			#moved = 0
	
	
