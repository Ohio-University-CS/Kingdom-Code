extends Node

const SAVE_PATH := "user://save_game.cfg"
const DEFAULT_LEVEL_PATH := "res://Levels/Level01.tscn"

var _pending_level_path: String = ""

func start_new_game() -> void:
	_pending_level_path = DEFAULT_LEVEL_PATH
	save_progress(DEFAULT_LEVEL_PATH)

func request_load_game() -> bool:
	var saved_level_path := get_saved_level_path()
	if saved_level_path.is_empty():
		return false

	_pending_level_path = saved_level_path
	return true

func consume_pending_level_path(fallback: String = DEFAULT_LEVEL_PATH) -> String:
	if _pending_level_path.is_empty():
		return fallback

	var level_path := _pending_level_path
	_pending_level_path = ""
	return level_path

func save_progress(level_path: String) -> void:
	if level_path.is_empty():
		return

	var config := ConfigFile.new()
	config.set_value("progress", "level_path", level_path)
	config.save(SAVE_PATH)

func has_save() -> bool:
	return not get_saved_level_path().is_empty()

func get_saved_level_path() -> String:
	var config := ConfigFile.new()
	var error := config.load(SAVE_PATH)
	if error != OK:
		return ""

	var saved_level: String = String(config.get_value("progress", "level_path", ""))
	return String(saved_level)

func get_saved_level_name() -> String:
	var saved_level_path := get_saved_level_path()
	if saved_level_path.is_empty():
		return ""

	return saved_level_path.get_file().get_basename()