class_name StateMachine extends Node

var states: Array[State] = []
var current_state: State 


#*                             Godot Functions                                *#
#*############################################################################*#
## description:		disables process mode
## return:			NA
func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED


#*                              Class Functions                               *#
#*############################################################################*#
## description:		initializes the state machine with a pawn, and
##					adds all children of type State to the states list
## new_pawn:		the pawn to attach to the state machine
## return:			NA
func init(new_pawn) -> void:

	# adds all children of type State to the list of states
	for child in get_children():
		if child is State:
			states.append(child)
			child.pawn = new_pawn

	# if the states list isnt empty, set the current state to the first state
	if states.size() > 0:
		current_state = states[0]
		current_state.enter()

################################################################################
## description:	    updates the current state by calling its process_state func
## delta:			the delta time since the last frame
## return:			NA
func process_update(delta: float) -> void:
	change_state(current_state.process_state(delta))

################################################################################
## description:		changes the current state to a new state if it is different
## new_state:		the new state to change to
## return:			NA
func change_state(new_state: State) -> void:
	# If the new state is null or the same as the current state, do nothing
	if new_state == null || new_state == current_state:
		return
	
	# first, exit the current state
	if current_state:
		current_state.exit()

	# then, set the current state to the new state and enter
	current_state = new_state
	current_state.enter()
