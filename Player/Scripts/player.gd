extends CharacterBody2D

var speed = 50 ## this is test movement code to experiment with, not the users movement code 
var movement = Vector2.ZERO
var gravity = 9.8
func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	#if Input.is_action_pressed("ui_right"): #moves right and left
		#velocity.x = speed
	#elif Input.is_action_pressed("ui_left"):
		#velocity.x = -speed
	#else:
		#velocity.x = 0
	#
	#if is_on_floor(): #applies gravity if not on floor (y up is negative(
		#velocity.y = 0
	#else:
		#velocity.y += gravity
	#
	#if Input.is_action_pressed("ui_up") and is_on_floor(): #jump code
		#velocity.y = -speed * 2
	
	# Apply gravity when not on floor
	if not is_on_floor():
		velocity.y += gravity
	else:
		velocity.y = 0
	
	if IntermediaryMangager.playing == true:
		#print("working", IntermediaryMangager.movementDirection * speed)
		velocity.x = IntermediaryMangager.movementDirection.x * speed
		# Keep the vertical velocity (gravity) separate
		move_and_slide()
