extends Node2D

var buttonHeld = false
@onready var centerOfBlock = $Center.position
var connectToBlock = null
var blockAttachingTo
var inTrash = false

@onready var clickTimer = $ClickTimer
var cycles = 1

var direction = Vector2.RIGHT

func _process(_delta: float) -> void:
	if buttonHeld:
		global_position = get_global_mouse_position() - centerOfBlock


func _on_button_button_down() -> void:
	clickTimer.start()


func _on_button_button_up() -> void:
	if !buttonHeld:
		if cycles < 15:
			cycles += 1
		else:
			cycles = 1
		$MultiplierBlock.set_frame(cycles - 1)
	
	if inTrash:
		queue_free()
	clickTimer.stop()
	buttonHeld = false
	call_deferred("reparent", get_tree().current_scene.get_child(0).get_child(0))
	if connectToBlock != null:
		global_position = connectToBlock
		if blockAttachingTo != null:
			var tmpParent = blockAttachingTo.get_parent()
			if tmpParent.is_in_group("MoveBlock") || tmpParent.is_in_group("DashBlock"):
				call_deferred("reparent", blockAttachingTo)
			else:
				print("not attachable")
				self.queue_free()


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
		inTrash = false

func _on_click_timer_timeout() -> void:
	buttonHeld = true # button is considered held when timer runs out
