class_name LevelManager extends Node2D

const MAIN_MENU_SCENE_PATH := "res://MainMenu/MainMenu.tscn"

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var level_root: Node2D = $LevelRoot
@onready var congrats_screen: CanvasLayer = $CongratsScreen
@onready var congrats_message: Label = $CongratsScreen/Message
@onready var loading_screen: CanvasLayer = $LoadingScreen
@onready var back_to_menu_button: Button = $MenuUi/BackToMenuButton
@onready var save_manager: SaveManager = get_node("/root/SaveManager") as SaveManager

var current_level_path: String = "res://Levels/Level01.tscn"
var current_level: Level = null
var _transitioning: bool = false
var _level_complete_armed: bool = false
var _death_armed: bool = false
var _level_load_id: int = 0
var _death_areas: Array[Area2D] = []
var _death_bodies: Array[PhysicsBody2D] = []

func _ready() -> void:
	back_to_menu_button.pressed.connect(_on_back_to_menu_pressed)
	current_level_path = save_manager.consume_pending_level_path(current_level_path)
	load_level(current_level_path)

func _process(_delta: float) -> void:
	if EventBus.playing == false:
		#player.set_process(false)
		#player.set_physics_process(false)
		player.animation_player.pause()
	else:
		#player.set_process(true)
		#player.set_physics_process(true)
		player.animation_player.play()

func _physics_process(_delta: float) -> void:
	if _transitioning or not _death_armed:
		return
	if _is_touching_any_death_body():
		_on_player_death(player)

func load_level(level_path: String) -> void:
	# Unload current level
	if level_root.get_child_count() > 0:
		level_root.get_child(0).queue_free()

	# Load new level
	var new_level_scene := load(level_path) as PackedScene
	if new_level_scene:
		var new_level_instance := new_level_scene.instantiate() as Level
		level_root.add_child(new_level_instance)
		current_level = new_level_instance
		current_level_path = level_path
		save_manager.save_progress(current_level_path)
		player.position = new_level_instance.player_spawn.position
		_update_camera_bounds(new_level_instance)
		if not current_level.level_complete_area.body_entered.is_connected(_on_level_complete):
			current_level.level_complete_area.body_entered.connect(_on_level_complete)

		_death_areas = _find_death_areas(current_level)
		_death_bodies = _find_death_bodies(current_level)
		for death_area in _death_areas:
			if not death_area.body_entered.is_connected(_on_player_death):
				death_area.body_entered.connect(_on_player_death)

		# Arm completion only after level settles and player is clear of the finish area.
		_level_complete_armed = false
		_death_armed = false
		_level_load_id += 1
		_arm_level_complete(_level_load_id)
		_arm_death(_level_load_id)

	loading_screen.visible = false
	EventBus.level_loaded.emit()

func _find_death_areas(level: Node) -> Array[Area2D]:
	var areas: Array[Area2D] = []

	var direct := level.get_node_or_null("Death") as Area2D
	if direct:
		areas.append(direct)

	for child in level.find_children("*", "Area2D", true, false):
		var area := child as Area2D
		if area and area.name.to_lower().contains("death") and not areas.has(area):
			areas.append(area)

	return areas

func _find_death_bodies(level: Node) -> Array[PhysicsBody2D]:
	var bodies: Array[PhysicsBody2D] = []

	for child in level.find_children("*", "PhysicsBody2D", true, false):
		var body := child as PhysicsBody2D
		if body and body.name.to_lower().contains("death"):
			bodies.append(body)

	return bodies

func _disconnect_death_areas() -> void:
	for death_area in _death_areas:
		if death_area and death_area.body_entered.is_connected(_on_player_death):
			death_area.body_entered.disconnect(_on_player_death)

func _update_camera_bounds(level: Level) -> void:
	var min_x := INF
	var min_y := INF
	var max_x := -INF
	var max_y := -INF

	for node in level.find_children("*", "TileMapLayer", true, false):
		var layer := node as TileMapLayer
		if layer == null or not layer.has_method("get_used_rect"):
			continue

		var used_rect := layer.get_used_rect() as Rect2i
		if used_rect.size == Vector2i.ZERO:
			continue

		var tile_size := Vector2(16, 16)
		if layer.tile_set:
			tile_size = Vector2(layer.tile_set.tile_size)

		var top_left_local := Vector2(used_rect.position) * tile_size
		var bottom_right_local := Vector2(used_rect.position + used_rect.size) * tile_size
		var top_left_global := layer.to_global(top_left_local)
		var bottom_right_global := layer.to_global(bottom_right_local)

		min_x = min(min_x, top_left_global.x)
		min_y = min(min_y, top_left_global.y)
		max_x = max(max_x, bottom_right_global.x)
		max_y = max(max_y, bottom_right_global.y)

	# Fallback for non-tilemap levels: derive bounds from background art.
	if min_x == INF:
		var background_sprite := level.get_node_or_null("Background/ParallaxLayer/Sprite2D") as Sprite2D
		if background_sprite and background_sprite.texture:
			var size := background_sprite.texture.get_size() * background_sprite.scale.abs()
			var top_left_global := background_sprite.global_position
			if background_sprite.centered:
				top_left_global -= size * 0.5
			var bottom_right_global := top_left_global + size

			min_x = top_left_global.x
			min_y = top_left_global.y
			max_x = bottom_right_global.x
			max_y = bottom_right_global.y

	if min_x == INF:
		return

	camera.limit_left = int(min_x)
	camera.limit_top = int(min_y)
	camera.limit_right = int(max_x)
	camera.limit_bottom = int(max_y)

func _arm_level_complete(load_id: int) -> void:
	await get_tree().physics_frame
	await get_tree().create_timer(0.4).timeout

	# If another level loaded while waiting, abort this arm attempt.
	if load_id != _level_load_id or current_level == null:
		return

	var attempts := 0
	while attempts < 120 and current_level.level_complete_area.get_overlapping_bodies().has(player):
		await get_tree().physics_frame
		if load_id != _level_load_id or current_level == null:
			return
		attempts += 1

	_level_complete_armed = true

func _arm_death(load_id: int) -> void:
	await get_tree().physics_frame
	await get_tree().create_timer(0.2).timeout

	if load_id != _level_load_id or current_level == null:
		return
	if _death_areas.is_empty():
		_death_armed = true
		return

	var attempts := 0
	while attempts < 120 and _is_player_overlapping_any_death_area():
		await get_tree().physics_frame
		if load_id != _level_load_id or current_level == null:
			return
		attempts += 1

	_death_armed = true

func _is_player_overlapping_any_death_area() -> bool:
	for death_area in _death_areas:
		if death_area and death_area.get_overlapping_bodies().has(player):
			return true
	return false

func _is_touching_any_death_body() -> bool:
	for i in range(player.get_slide_collision_count()):
		var collision := player.get_slide_collision(i)
		if collision == null:
			continue
		var collider := collision.get_collider() as Node
		if collider == null:
			continue
		if collider is PhysicsBody2D and _death_bodies.has(collider):
			return true

	return false

func _on_level_complete(body: Node2D) -> void:
	# Only the player should complete the level.
	if body != player:
		return
	if not _level_complete_armed:
		return

	if _transitioning:
		return
	_transitioning = true
	_level_complete_armed = false

	# Disarm this level's trigger immediately to prevent duplicate enters.
	if current_level and current_level.level_complete_area.body_entered.is_connected(_on_level_complete):
		current_level.level_complete_area.body_entered.disconnect(_on_level_complete)
	_disconnect_death_areas()

	# Capture path before awaits/load so we don't rely on mutable state later.
	var next_path := current_level.next_level_path

	# Pause the game
	EventBus.playing = false

	# Show congratulations screen
	congrats_message.text = "Level Complete!"
	congrats_screen.visible = true
	await get_tree().create_timer(2.0).timeout
	congrats_screen.visible = false

	# Show loading screen for a moment, then load next level
	loading_screen.visible = true
	await get_tree().create_timer(1.5).timeout
	load_level(next_path)
	await get_tree().physics_frame
	_transitioning = false

func _on_player_death(body: Node2D) -> void:
	if body != player:
		return
	if not _death_armed:
		return
	if _transitioning:
		return
	_transitioning = true
	_level_complete_armed = false
	_death_armed = false

	if current_level and current_level.level_complete_area.body_entered.is_connected(_on_level_complete):
		current_level.level_complete_area.body_entered.disconnect(_on_level_complete)
	_disconnect_death_areas()

	EventBus.playing = false

	congrats_message.text = "You Died"
	congrats_screen.visible = true
	await get_tree().create_timer(1.2).timeout
	congrats_screen.visible = false

	loading_screen.visible = true
	await get_tree().create_timer(0.6).timeout
	load_level(current_level_path)
	await get_tree().physics_frame
	_transitioning = false

func _on_back_to_menu_pressed() -> void:
	EventBus.playing = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
