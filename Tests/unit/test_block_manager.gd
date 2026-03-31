extends GutTest
## Unit tests for BlockManager (res://BlockManager.gd).
##
## These tests instantiate a minimal BlockManager node and simulate its
## linking and execution behavior. Because BlockManager depends on scene
## structure (Timer, CanvasLayer, etc.), we construct only the required
## minimal hierarchy to avoid runtime errors while still testing logic.


const BLOCK_MANAGER_SCRIPT := "res://BlockManager/Scripts/block_manager.gd"
const TEST_BLOCK := "res://Tests/unit/test_block.gd"


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

## Creates a minimal BlockManager instance with required children so that
## _ready() and dependent calls do not crash during testing.
func _create_block_manager() -> Node2D:
	var bm = load(BLOCK_MANAGER_SCRIPT).new()

	# Required Timer node
	var timer = Timer.new()
	timer.name = "Timer"
	bm.add_child(timer)

	# Minimal PausePlay node to avoid crashes
	var canvas = CanvasLayer.new()
	canvas.name = "CanvasLayer"
	var pause_play = Sprite2D.new()
	pause_play.name = "PausePlay"
	pause_play.hframes = 2
	pause_play.vframes = 1
	canvas.add_child(pause_play)
	bm.add_child(canvas)

	add_child_autofree(bm)
	return bm


## Creates a dummy node that behaves like a block
func _create_block(name: String = "Block", parent: Node = null) -> Node2D:
	var node = TestBlock.new()
	node.name = name
	if parent:
		parent.add_child(node)
	return node


## Creates an Area2D with a given parent
func _create_area_with_parent(parent: Node2D) -> Area2D:
	var area = Area2D.new()
	parent.add_child(area)
	return area



# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func before_each() -> void:
	pass


func after_each() -> void:
	pass


# ---------------------------------------------------------------------------
# Test 1 – Insert After (Empty Chain)
# ---------------------------------------------------------------------------
## Verifies that inserting a node when no nextNode exists correctly links
## the new node as the next node.
func test_insert_after_empty_chain() -> void:
	var bm = _create_block_manager()

	var parent = _create_block("Parent")
	var new_node = _create_block("NewNode")

	var area = _create_area_with_parent(parent)

	parent.nextNode = null

	bm.insert_after(new_node, area)

	assert_eq(parent.nextNode, new_node,
		"Parent.nextNode should reference the newly inserted node")
	assert_eq(new_node.lastNode, parent,
		"New node should reference parent as lastNode")


# ---------------------------------------------------------------------------
# Test 2 – Insert After (Middle Insertion)
# ---------------------------------------------------------------------------
## Verifies inserting a node between two existing nodes correctly rewires
## nextNode and lastNode references.
func test_insert_after_middle_chain() -> void:
	var bm = _create_block_manager()
	var parent = _create_block("Parent")
	var middle = _create_block("Middle")
	var new_node = _create_block("Inserted")
	
	# Add dummy children so get_child(5) exists
	for i in range(6):
		new_node.add_child(Node2D.new())
	
	parent.nextNode = middle
	middle.lastNode = parent
	
	var area = _create_area_with_parent(parent)
	bm.insert_after(new_node, area)

	assert_eq(parent.nextNode, new_node,
		"Parent should now point to inserted node")
	assert_eq(new_node.lastNode, parent,
		"Inserted node should link back to parent")
	assert_eq(new_node.nextNode, middle,
		"Inserted node should point to former next node")
	assert_eq(middle.lastNode, new_node,
		"Former next node should link back to inserted node")


# ---------------------------------------------------------------------------
# Test 3 – Prevent Self Parenting (Error Case)
# ---------------------------------------------------------------------------
## Verifies that attempting to insert a node into itself does not corrupt
## the chain structure.
func test_insert_after_self_parenting() -> void:
	var bm = _create_block_manager()

	var parent = _create_block("Parent")
	var area = _create_area_with_parent(parent)

	bm.insert_after(parent, area)

	assert_ne(parent.nextNode, parent,
		"A node should never be linked as its own nextNode")


# ---------------------------------------------------------------------------
# Test 4 – Prevent Ancestor Re-insertion (Edge Case)
# ---------------------------------------------------------------------------
## Verifies that a node cannot be inserted into one of its descendants,
## preventing cyclic hierarchy issues.
func test_insert_after_ancestor_check() -> void:
	var bm = _create_block_manager()

	var parent = _create_block("Parent")
	var child = _create_block("Child")

	parent.add_child(child)
	var area = _create_area_with_parent(parent)

	bm.insert_after(parent, area)

	assert_null(parent.lastNode,
		"Parent should not gain a lastNode from invalid insertion")


# ---------------------------------------------------------------------------
# Test 5 – Timer Traversal (Normal Case)
# ---------------------------------------------------------------------------
## Verifies that _on_timer_timeout advances to the next block when available.
func test_timer_moves_to_next_block() -> void:
	var bm = _create_block_manager()

	var node1 = _create_block("Node1")
	var node2 = _create_block("Node2")

	bm.nextNode = node1
	node1.nextNode = node2

	bm.currentBlock = bm

	bm._on_timer_timeout()

	assert_eq(bm.currentBlock, node1,
		"Current block should advance to first node in chain")


# ---------------------------------------------------------------------------
# Test 6 – Timer Traversal (Edge Case: No Nodes)
# ---------------------------------------------------------------------------
## Verifies that calling _on_timer_timeout with no nodes does not crash
## or change state.
func test_timer_no_nodes() -> void:
	var bm = _create_block_manager()

	bm.nextNode = null
	bm.currentBlock = bm

	bm._on_timer_timeout()

	assert_eq(bm.currentBlock, bm,
		"Current block should remain unchanged when no nodes exist")


# ---------------------------------------------------------------------------
# Test 7 – Play Button Toggle Behavior
# ---------------------------------------------------------------------------
## Verifies that pressing the play button toggles the playing state on and off.
func test_play_button_toggle() -> void:
	var bm = _create_block_manager()

	bm.playing = false

	bm._on_play_button_pressed()
	assert_true(bm.playing,
		"Playing should be true after first button press")

	bm._on_play_button_pressed()
	assert_false(bm.playing,
		"Playing should be false after second button press")
