class_name BlockManager extends Node2D


@onready var timer = $Timer
var currentBlock = self

func _ready() -> void:
	EventBus.block_added.connect(insert_after)
	timer.wait_time = 0.5

var playing = false
func _on_play_button_pressed() -> void:
	playing = !playing
	#if blocks.size() == 0: #cannot play with zero blocks - ben
		#playing = false
	print("playing", playing)
	IntermediaryMangager.playing = playing
	$Control/PausePlay.set_frame(playing)
	if playing:
		currentBlock = self
		_on_timer_timeout()
		timer.start()
		
	else:
		timer.stop()
	


var nextNode = null

# =========================
# LINKING
# =========================

func insert_after(newNode: Node2D, attachingArea: Area2D):
	var newParent = attachingArea.get_parent()
	if newParent is Sprite2D:
		newParent = self

	if newNode == newParent:
		print("brokwnsuwu")
		return
	# Prevent cyclic parenting
	#if newParent.is_ancestor_of(newNode):
		#print("parent is the parent to new")
		#return
	
	if attachingArea.is_ancestor_of(newNode):
		print("its already a kid")
		return
	
	if !newParent.nextNode:
		print("parented to bottom")
		newNode.call_deferred("reparent", attachingArea)
		newNode.lastNode = newParent
		newParent.nextNode = newNode
	else:
		print("parented in the middles")
		newNode.call_deferred("reparent", attachingArea)
		newNode.lastNode = newParent
		newNode.nextNode = newParent.nextNode
		newParent.nextNode = newNode
		newNode.nextNode.lastNode = newNode
		newNode.nextNode.call_deferred("reparent", newNode.get_child(5))
		newNode.nextNode.call_deferred("_update_position")

func _on_timer_timeout() -> void:
	if currentBlock.nextNode == null: #loops the code blocks
		currentBlock = self
	else:
		currentBlock = currentBlock.nextNode
	
	if currentBlock.name == "MoveBlock":
		IntermediaryMangager.movementDirection = currentBlock._check_for_direction()
		print(IntermediaryMangager.movementDirection)
	
