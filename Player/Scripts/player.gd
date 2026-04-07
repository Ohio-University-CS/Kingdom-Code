extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine

var speed = 50 ## this is test movement code to experiment with, not the users movement code 
var gravity = 9.8
var pixels = 16 -1

func _ready() -> void:
	state_machine.init(self)
	EventBus.next_block.connect(next_block)

var moved = 0
var distance_to_move = pixels
var start = global_position.x
func next_block():
	moved = 0
	start = global_position.x
	distance_to_move = start + (pixels * EventBus.movementDirection.x)


func _physics_process(delta: float) -> void:
	state_machine.process_update(delta)
	global_position = global_position.round()
	
	if not is_on_floor():
		velocity.y += gravity
	else:
		if EventBus.movementDirection.y != 0:
			velocity.y = EventBus.movementDirection.y * 150 ## jump height
			
			EventBus.next_block.emit() #Goes to next block directly after starting the jump
			return
	
	if (start < distance_to_move and EventBus.movementDirection.x == 1) or (start > distance_to_move and EventBus.movementDirection.x == -1):
		velocity.x = EventBus.movementDirection.x * speed
		
		start = global_position.x
	elif ((start < distance_to_move and EventBus.movementDirection.x == 2) or (start > distance_to_move and EventBus.movementDirection.x == -2)) and EventBus.playing == true:
		pass
	else:
		velocity.x = 0
		#velocity.y += gravity
		if EventBus.playing == true:
			EventBus.next_block.emit()
	
	if EventBus.playing == false:
		velocity.x = 0
	move_and_slide()
	
