class_name LevelManager extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var level_root: Node2D = $LevelRoot

var current_level_path: String  = "res://Levels/Level01.tscn"
var current_level: Level = null

func _ready() -> void:
	# Load the initial level
	load_level(current_level_path)

func _process(_delta: float) -> void:
	if EventBus.playing == false:
		player.set_process(false)
		player.set_physics_process(false)
		player.animation_player.pause()

	else:
		player.set_process(true)
		player.set_physics_process(true)
		player.animation_player.play()

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
		player.position = new_level_instance.player_spawn.position

	# wire level complete signal
		current_level.level_complete_area.body_entered.connect(_on_level_complete)
		

func _on_level_complete(_body: Node2D) -> void:
	call_deferred("load_level", current_level.next_level_path)
