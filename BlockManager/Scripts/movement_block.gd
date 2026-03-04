extends Node2D

#data for list
var lastNode = null
var nextNode = null


var buttonHeld = false
@onready var centerOfBlock = $Center.position
var connectToBlock = null
var blockAttachingTo = null



func _process(_delta: float = 1) -> void:
	if buttonHeld:
		global_position = get_global_mouse_position() - centerOfBlock


func _on_button_button_down() -> void:
	buttonHeld = true


func _on_button_button_up() -> void:
	buttonHeld = false
	
	var tmpParent = get_parent().get_parent() #this code is to have the last parent stop registering this node as its child
	if tmpParent is Sprite2D:
		tmpParent = tmpParent.get_parent()
	if tmpParent.get("nextNode"):
		tmpParent.nextNode = null
	
	
	call_deferred("reparent", get_tree().current_scene.get_child(0).get_child(0)) #reattached node to canvasLayer
	lastNode = null
	
	if connectToBlock != null:
		global_position = connectToBlock
		if blockAttachingTo != null:
			EventBus.block_added.emit(self, blockAttachingTo)
			print("added to list")


func _on_connect_to_last_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("ConnectAbove"):
		connectToBlock = area.global_position
		blockAttachingTo = area
		print("connecting blockattachingto and connecttoblock")

func _on_connect_to_last_detector_area_exited(area: Area2D) -> void: 
	if area.is_in_group("ConnectAbove"):
		connectToBlock = null



func _on_connect_to_next_detector_area_entered(area: Area2D) -> void:# These will be used to register the direction blocks
	if area.is_in_group("ConnectFrom"):
		pass


func _on_connect_to_next_detector_area_exited(area: Area2D) -> void:
	if buttonHeld:
		return
	if area.is_in_group("ConnectFrom"):
		pass
	

func _check_for_direction():
	if has_node("RightBlock"):
		print("Direction is right", Vector2.RIGHT)
		return Vector2.RIGHT
	return Vector2.ZERO

func _update_position():
	position = Vector2.ZERO
