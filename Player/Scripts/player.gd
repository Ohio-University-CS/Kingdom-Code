extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine

var speed = 50 ## this is test movement code to experiment with, not the users movement code 
var gravity = 9.8
var pixels = 16

#var posChanged = false ## this is used for fixing final player position when not moving

func _ready() -> void:
	state_machine.init(self)
	EventBus.next_block_two.connect(next_block)

var moved = 0
var start = global_position.x
var distance_to_move = start
func next_block():
	moved = 0
	start = global_position.x
	distance_to_move = start + (pixels * EventBus.movementDirection.x * EventBus.multiplier)
	#print(distance_to_move - start)

func _physics_process(delta: float) -> void:
	state_machine.process_update(delta)
	global_position = global_position.round()
	
	
	if not is_on_floor():
		velocity.y += gravity
	else:
		if EventBus.movementDirection.y != 0:
			velocity.y = EventBus.movementDirection.y * 150 ## jump height
			EventBus.movementDirection.y = 0
			#EventBus.next_block.emit() #Goes to next block directly after starting the jump
			#return
	
	if (start < distance_to_move and EventBus.movementDirection.x == 1) or (start > distance_to_move and EventBus.movementDirection.x == -1):
		velocity.x = EventBus.movementDirection.x * speed
		#posChanged = true
		start = global_position.x
	else:
		velocity.x = 0
		#velocity.y += gravity
		#if posChanged:
		global_position.x = round((global_position.x - 8)/16)*16 + 8
			#posChanged = false
		print("updating final position to", global_position.x)
		
		if EventBus.playing == true:
			EventBus.next_block.emit()
	
	if EventBus.playing == false:
		velocity.x = 0
	move_and_slide()
	
