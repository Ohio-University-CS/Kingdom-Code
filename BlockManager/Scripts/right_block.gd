extends Node2D

var buttonHeld = false
@onready var centerOfBlock = $Center.position
var connectToBlock = null
var blockAttachingTo = Node2D

var direction = Vector2.RIGHT

var inTrash = false

func _process(_delta: float) -> void:
	if buttonHeld:
		global_position = get_global_mouse_position() - centerOfBlock


func _on_button_button_down() -> void:
	buttonHeld = true
	


func _on_button_button_up() -> void:
	buttonHeld = false
	
	if inTrash:
		queue_free()
	
	call_deferred("reparent", get_tree().current_scene.get_child(0).get_child(0))
	if connectToBlock != null:
		global_position = connectToBlock
		if blockAttachingTo != null:
			call_deferred("reparent", blockAttachingTo)


func _on_connect_to_last_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("ConnectTo"):
		connectToBlock = area.global_position
		blockAttachingTo = area.get_parent()
	elif area.is_in_group("TrashCan"):
		inTrash = true

func _on_connect_to_last_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("ConnectTo"):
		connectToBlock = null
	elif area.is_in_group("TrashCan"):
		inTrash = true
