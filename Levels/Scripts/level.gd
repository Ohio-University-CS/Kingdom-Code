class_name Level extends Node2D

@export var level_name: String = "Level 01"
@export var level_number: int = 1
@onready var level_complete_area: Area2D = $LevelComplete

@onready var player_spawn: Marker2D = $PlayerSpawn

var next_level_path: String = ""

func _ready() -> void:
	next_level_path = get_next_level_path()

## Get the path to the next level
func get_next_level_path() -> String:
	# Simple progression logic
	var next_level_number := level_number + 1
	return "res://levels/Level%02d.tscn" % next_level_number

	