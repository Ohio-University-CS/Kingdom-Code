class_name BlockManager extends Node2D

#current bugs, , moving the blocks in a certain way makes the code stop detecting them ( this is because the stating block sometimes doesnt have a nextnode when it should, blocks cannot be inserted as the start of the stack when a block is alreadty there. up block does not work
var currentBlock = self

@onready var errorTimer = $ErrorTimer

var lastNode = null
var nextNode = null

func _ready() -> void:
	EventBus.block_added.connect(insert_after)
	EventBus.level_loaded.connect(_on_level_loaded)
	EventBus.next_block.connect(go_next)

var playing = false

func _on_level_loaded() -> void:
	playing = false
	EventBus.playing = false
	currentBlock = self
	$CanvasLayer/PausePlay.set_frame(0)

func _on_play_button_pressed() -> void:
	playing = !playing
	#if blocks.size() == 0: #cannot play with zero blocks - ben
		#playing = false
	print("playing", playing)
	EventBus.playing = playing
	if has_node("CanvasLayer/PausePlay"):
		$CanvasLayer/PausePlay.set_frame(playing)
	if playing:
		if currentBlock.nextNode != null:
			currentBlock = self
			EventBus.movementDirection = Vector2.ZERO
			go_next()
			#print("test")
	


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
		#print("parented to bottom")
		newNode.reparent(attachingArea)
		newNode.lastNode = newParent
		newParent.nextNode = newNode
		#print("new node is ", newNode)
	else:
		#print("parented in the middles")
		newNode.reparent(attachingArea)
		newNode.lastNode = newParent
		newNode.nextNode = newParent.nextNode
		newParent.nextNode = newNode
		newNode.nextNode.lastNode = newNode
		newNode.nextNode.reparent(newNode.get_child(5))
		newNode.nextNode.call_deferred("_update_position")



var testing = 0
func go_next():
	if currentBlock.nextNode == null: #loops the code blocks
		
		_on_play_button_pressed()
		#print(currentBlock)
		if currentBlock.nextNode == null:
			currentBlock = self
			return
	currentBlock = currentBlock.nextNode
	var player = get_parent().get_child(1).get_child(1)
	errorTimer.start()
	print("running a block ", currentBlock.name)
	if currentBlock.is_in_group("MoveBlock"):
		EventBus.movementDirection = currentBlock._check_for_direction()
		#print(player.global_position.x - testing)
		testing = player.global_position.x
		print(EventBus.movementDirection)
	elif currentBlock.is_in_group("DashBlock"):
		EventBus.movementDirection = currentBlock._check_for_direction()
		var raycast = player.get_child(5) #raycast position leftcast
		if EventBus.movementDirection == Vector2.RIGHT:
			raycast = player.get_child(6) #raycast position leftcast
		if raycast.is_colliding():
			var newPos = abs(raycast.global_position - raycast.get_collision_point()) * EventBus.movementDirection.x #dist to move
			player.global_position.x += newPos.x
		else:
			player.global_position.x += 48 * EventBus.movementDirection.x #size of raycast, change if target position changes
		EventBus.next_block.emit()
		return
	else:
		print("not detecting a block ", currentBlock.name)


func _on_error_timer_timeout() -> void: ## if a block runs for more than a timer length (1 second) it is assumed to be an error and will go to the next block
	EventBus.next_block.emit()
