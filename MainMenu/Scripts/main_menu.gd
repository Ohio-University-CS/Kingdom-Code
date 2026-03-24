extends Control

const GAME_SCENE_PATH := "res://Main.tscn"

@onready var save_manager: SaveManager = get_node("/root/SaveManager") as SaveManager
@onready var status_label: Label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/StatusLabel
@onready var new_game_button: Button = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/NewGameButton
@onready var load_button: Button = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/LoadButton
@onready var quit_button: Button = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/QuitButton

func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_button.pressed.connect(_on_load_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	_refresh_load_state()

func _refresh_load_state() -> void:
	var has_save: bool = save_manager.has_save()
	load_button.disabled = not has_save

	if has_save:
		status_label.text = "Continue from %s." % save_manager.get_saved_level_name()
	else:
		status_label.text = "No saved game found."

func _on_new_game_pressed() -> void:
	save_manager.start_new_game()
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_load_pressed() -> void:
	if not save_manager.request_load_game():
		_refresh_load_state()
		return

	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_quit_pressed() -> void:
	get_tree().quit()