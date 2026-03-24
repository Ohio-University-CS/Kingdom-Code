class_name BlockManager extends Node2D

#current bugs, , moving the blocks in a certain way makes the code stop detecting them ( this is because the stating block sometimes doesnt have a nextnode when it should, blocks cannot be inserted as the start of the stack when a block is alreadty there. up block does not work

@onready var timer = $Timer
var currentBlock = self


var lastNode = null
var nextNode = null

func _ready() -> void:
	EventBus.block_added.connect(insert_after)
	EventBus.level_loaded.connect(_on_level_loaded)
	timer.wait_time = 0.5

var playing = false

func _on_level_loaded() -> void:
	playing = false
	IntermediaryMangager.playing = false
	timer.stop()
	currentBlock = self
	$CanvasLayer/PausePlay.set_frame(0)

func _on_play_button_pressed() -> void:
	playing = !playing
	#if blocks.size() == 0: #cannot play with zero blocks - ben
		#playing = false
	print("playing", playing)
	EventBus.playing = playing
	$CanvasLayer/PausePlay.set_frame(playing)
	if playing:
		if currentBlock.nextNode != null:
			currentBlock = self
			EventBus.movementDirection = Vector2.ZERO
			_on_timer_timeout()
			timer.start()
	else:
		timer.stop()
	


# =========================
# LINKING
# =========================

func insert_after(newNode: Node2D, attachingArea: Area2D):
	var newParent = attachingArea.get_parent()
	if newParent is Sprite2D:
		newParent = self

	if newNode == newParent: #has yet to be used, can probably get removed
		print("brokwnsuwu")
		return
	
	
	if attachingArea.is_ancestor_of(newNode):
		print("its already a kid")
		return
	
	if !newParent.nextNode:
		print("parented to bottom")
		newNode.call_deferred("reparent", attachingArea)
		newNode.lastNode = newParent
		newParent.nextNode = newNode
		print("new node is ", newNode)
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
		currentBlock = self.nextNode
		if !self.nextNode:
			return
	else:
		currentBlock = currentBlock.nextNode
	
	print("running a block ", currentBlock.name)
	if currentBlock.is_in_group("MoveBlock"):
		EventBus.movementDirection = currentBlock._check_for_direction()
		print(EventBus.movementDirection)
	else:
		print("not detecting a block ", currentBlock.name)
	
