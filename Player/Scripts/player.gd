extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine

var speed = 50 ## this is test movement code to experiment with, not the users movement code 
var gravity = 9.8

func _ready() -> void:
	state_machine.init(self)

func _physics_process(delta: float) -> void:
		state_machine.process_update(delta)
