extends Node2D

#data for list
var lastNode = null
var nextNode = null


var buttonHeld = false
@onready var centerOfBlock = $Center.position
var connectToBlock = null
var blockAttachingTo = null

var inTrash = false

func _process(_delta: float = 1) -> void:
	if buttonHeld:
		global_position = get_global_mouse_position() - centerOfBlock


func _on_button_button_down() -> void:
	buttonHeld = true


func _on_button_button_up() -> void:
	buttonHeld = false
	
	if inTrash:
		queue_free()
	
	var tmpParent = get_parent().get_parent() #this code is to have the last parent stop registering this node as its child
	if tmpParent.name == "StartingBlock":
		tmpParent = tmpParent.get_parent().get_parent()
		print("current parent is ", tmpParent)
	if tmpParent.get("nextNode"):
		if tmpParent.nextNode == self:
			tmpParent.nextNode = null
			print(self, " fully detached from ", tmpParent)
	
	
	call_deferred("reparent", get_tree().current_scene.get_child(0).get_child(0)) #reattached node to canvasLayer
	lastNode = null
	
	if connectToBlock != null:
		global_position = connectToBlock
		if blockAttachingTo != null:
			if lastNode == null:
				EventBus.block_added.emit(self, blockAttachingTo)
				print("added to list")


func _on_connect_to_last_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("ConnectAbove"):
		connectToBlock = area.global_position
		blockAttachingTo = area
		print("connecting blockattachingto and connecttoblock")
	elif area.is_in_group("TrashCan"):
		inTrash = true

func _on_connect_to_last_detector_area_exited(area: Area2D) -> void: 
	
	if area.is_in_group("ConnectAbove"):
		connectToBlock = null
	elif area.is_in_group("TrashCan"):
		inTrash = false



func _on_connect_to_next_detector_area_entered(area: Area2D) -> void:# These will be used to register the direction blocks
	if area.is_in_group("ConnectFrom"):
		pass


func _on_connect_to_next_detector_area_exited(area: Area2D) -> void:
	if buttonHeld:
		return
	if area.is_in_group("ConnectFrom"):
		pass
	

var directionNode = null
func _check_for_direction():
	if has_node("RightBlock"):
		directionNode = get_node("RightBlock")
		return Vector2.RIGHT
	elif has_node("LeftBlock"):
		directionNode = get_node("LeftBlock")
		return Vector2.LEFT
	elif has_node("UpBlock"):
		directionNode = get_node("UpBlock")
		return Vector2.UP
	elif has_node("DownBlock"):
		directionNode = get_node("DownBlock")
		return Vector2.DOWN
	return Vector2.ZERO

func _check_for_multiplier():
	if directionNode.has_node("MultiplierBlock"):
		print("found it")
		var cycles = directionNode.get_node("MultiplierBlock").cycles
		return cycles
	print("didnt find the multiplier block")
	return 1;

func _update_position():
	position = Vector2.ZERO
