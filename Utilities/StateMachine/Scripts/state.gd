class_name State extends Node

var pawn = null


func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED

#*                              Class Functions                               *#
#*############################################################################*#
## description:		what happens when the player enters the state
## return:			NA
func enter() -> void:
	pass

################################################################################
## description:		what happens when the player exits the state
## return:			NA
func exit() -> void:
	pass

################################################################################
## description:		what happens when the player is in the state
## delta:			the delta time since the last frame
## return:			the next state to change to, or self if no change is needed
func process_state(_delta: float) -> State:
	return null

