class_name BlockManager extends Node2D

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
		#print("blockmanager old next node should be ", nextNode)
	
	if newNode == newParent: #has yet to be used, can probably get removed
		print("brokwnsuwu")
		return
	if attachingArea.is_ancestor_of(newNode):
		print("its already a kid")
		newNode.reparent(get_tree().current_scene.get_child(0).get_child(0)) ## changes parent to the canvas layer temporarally
	
	
	if newNode.lastNode:
		newNode.lastNode.nextNode = null
	
	var oldNext = null # gets the old next incase putting a block in the middle
	if newParent.nextNode != null:
		print("calling oldNext")
		oldNext = newParent.nextNode
	
	var newBottomNode = newNode ##newBottomNode is the lowest node in the added stack of newNode, the oldNext should attach to the bottom of this
	while newBottomNode.nextNode: #if adding more than one node this gets the bottom, else its the same as newNode
		newBottomNode = newBottomNode.nextNode
	
	newParent.nextNode = newNode #changing all of the paths
	newNode.lastNode = newParent
	newBottomNode.nextNode = oldNext
	print("old next is", oldNext)
	if oldNext: #incase it doesn't exist
		oldNext.lastNode = newNode
	
	
	newNode.call_deferred("reparent", attachingArea) #reparrenting everything ## calling deffered so that it runs after other nodes unparent themselves
	newNode.global_position = attachingArea.global_position
	if oldNext:
		oldNext.call_deferred("reparent", newBottomNode.get_child(5)) #  5 is the attaching area
		oldNext.global_position = newBottomNode.get_child(5).global_position
	


var testing = 0
var step = null
#var cycles = 0
#var checkedForCycles = false
func go_next():
	if step != null:
		print("(run aftr) step is: ", step)
		step = null
		if step.has_children():
			step.get_child(0).disabled = false
	if currentBlock.nextNode == null: #loops the code blocks
		if currentBlock.has_node("Star"): 
			currentBlock.get_node("Star").visible = false #removing star when ended
		_on_play_button_pressed()
		#print(currentBlock)
		if currentBlock.nextNode == null:
			currentBlock = self
			return
	currentBlock = currentBlock.nextNode
	var player = get_parent().get_child(1).get_child(1)
	
	if currentBlock.has_node("Star"): # puts a star next to the running node
		currentBlock.get_node("Star").visible = true
	if currentBlock.lastNode:
		if currentBlock.lastNode.has_node("Star"):
			currentBlock.lastNode.get_node("Star").visible = false
	
	print("running a block ", currentBlock.name)
	if currentBlock.is_in_group("MoveBlock"):
		EventBus.movementDirection = currentBlock._check_for_direction()
		#print(player.global_position.x - testing)
		EventBus.multiplier = currentBlock._check_for_multiplier()
		testing = player.global_position.x
		print(EventBus.movementDirection, "this thing - block manager")
		
		
		if player.get_child(7).is_colliding() and EventBus.movementDirection == Vector2.DOWN:
			step = player.get_child(7).get_collider()
			print("(run before) step is: ", step, EventBus.movementDirection)
		
		if step:
			print("it should be existing rn")
			if step.is_in_group("Step"):
				step.get_child(0).disabled = true
				print("should be dropping right nowwwwwwwww", EventBus.movementDirection)
				errorTimer.wait_time = 1
				errorTimer.start()
			else:
				EventBus.next_block_two.emit() ## calls for player to get pos to move to
				print("pushed block, missed the step")
		else:
			EventBus.next_block_two.emit() ## calls for player to get pos to move to
			
		#if !checkedForCycles:
			#cycles = currentBlock._check_for_multiplier() #replays the one block for amount of multiplier
			#print("counting the amount of cycles, ", cycles)
			#checkedForCycles = true
		#if cycles > 1:
			#print("tell code to run the code again")
			#currentBlock = currentBlock.lastNode
			#cycles -= 1
		#else:
			#print("done running the code")
			#checkedForCycles = false
			#cycles = 0
		
		
	elif currentBlock.is_in_group("DashBlock"):
		EventBus.movementDirection = currentBlock._check_for_direction()
		var raycast = player.get_child(5) #raycast position leftcast
		if EventBus.movementDirection == Vector2.RIGHT:
			raycast = player.get_child(6) #raycast position leftcast
		if raycast.is_colliding():
			var newPos = abs(raycast.global_position - raycast.get_collision_point()) * EventBus.movementDirection.x #dist to move
			player.global_position.x += newPos.x
		else:
			player.global_position.x += 64 * EventBus.movementDirection.x #size of raycast, change if target position changes
		#player.global_position.x = ceil((player.global_position.x - 8)/16)*16 + 8 ## fixing position incase a few pixels off
		EventBus.next_block.emit()
		
	elif currentBlock.is_in_group("WaitBlock"): #Waits for 1 second
		errorTimer.wait_time = 1
		errorTimer.start()
	elif currentBlock.is_in_group("SwitchBlock"): # pulls levers
		if player.currentSwitch != null:
			print("pulling switch")
			player.currentSwitch._pull_switch()
			errorTimer.wait_time = 1
			errorTimer.start()
		else:
			print("switch not found")
	else:
		print("not detecting a block ", currentBlock.name)
		errorTimer.wait_time = 1 * EventBus.multiplier
		errorTimer.start()


func _on_error_timer_timeout() -> void: ## if a block runs for more than a timer length (1 second) it is assumed to be an error and will go to the next block
	if EventBus.playing:
		EventBus.next_block.emit()
