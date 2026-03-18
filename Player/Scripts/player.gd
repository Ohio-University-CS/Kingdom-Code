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
	
	if IntermediaryMangager.playing == true:
		velocity.x = IntermediaryMangager.movementDirection.x * speed
		if is_on_floor():
			velocity.y = IntermediaryMangager.movementDirection.y * 400
		else:
			velocity.y += gravity
			
		move_and_slide()
