extends GutTest
## Unit tests for SaveManager (res://Utilities/Save/save_manager.gd).
##
## SETUP: Install the GUT plugin (Godot Unit Testing) from the Godot Asset
## Library (search "GUT"), enable it under Project > Project Settings > Plugins,
## then run these tests via the GUT panel or the gutconfig.json at the repo root.
##
## All tests manipulate a real save file in user://.  after_each() cleans up so
## each test starts from a known, empty-save state.

const TEST_LEVEL_01 := "res://Levels/Level01.tscn"
const TEST_LEVEL_02 := "res://Levels/Level02.tscn"
const SAVE_FILE     := "save_game.cfg"          # filename inside user://


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

## Opens user:// and deletes the save file if it exists.
func _delete_save() -> void:
	var dir := DirAccess.open("user://")
	if dir and dir.file_exists(SAVE_FILE):
		dir.remove(SAVE_FILE)


# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func after_each() -> void:
	_delete_save()
	SaveManager._pending_level_path = ""


# ---------------------------------------------------------------------------
# Test 1 – save_progress() / has_save()
# ---------------------------------------------------------------------------
## Verifies that saving a valid path creates a detectable save, that an empty
## path is a silent no-op, and that deleting the file makes has_save() false.
func test_save_progress_and_has_save() -> void:
	# Normal case: a valid path produces a save readable by has_save().
	SaveManager.save_progress(TEST_LEVEL_01)
	assert_true(
		SaveManager.has_save(),
		"has_save() must return true after save_progress() with a valid path"
	)

	# Edge case: passing an empty path must NOT erase an existing save.
	SaveManager.save_progress("")
	assert_true(
		SaveManager.has_save(),
		"save_progress('') must leave an existing save untouched"
	)

	# Error case: deleting the save file makes has_save() return false.
	_delete_save()
	assert_false(
		SaveManager.has_save(),
		"has_save() must return false when the save file does not exist"
	)


# ---------------------------------------------------------------------------
# Test 2 – consume_pending_level_path()
# ---------------------------------------------------------------------------
## Verifies the path is returned and cleared on first call, that the fallback
## is used when no pending path exists, and that an empty fallback is allowed.
func test_consume_pending_level_path() -> void:
	# Normal case: consume returns the pending path and clears the field.
	SaveManager._pending_level_path = TEST_LEVEL_02
	var result := SaveManager.consume_pending_level_path(TEST_LEVEL_01)
	assert_eq(
		result, TEST_LEVEL_02,
		"consume_pending_level_path must return the pending path"
	)
	assert_eq(
		SaveManager._pending_level_path, "",
		"_pending_level_path must be cleared to '' after consumption"
	)

	# Edge case: no pending path → the provided fallback is returned.
	var fallback_result := SaveManager.consume_pending_level_path(TEST_LEVEL_01)
	assert_eq(
		fallback_result, TEST_LEVEL_01,
		"consume_pending_level_path must return the fallback when pending is empty"
	)

	# Error case: both pending and fallback are empty → returns empty string.
	var empty_result := SaveManager.consume_pending_level_path("")
	assert_eq(
		empty_result, "",
		"consume_pending_level_path must return '' when both pending and fallback are empty"
	)


# ---------------------------------------------------------------------------
# Test 3 – get_saved_level_name()
# ---------------------------------------------------------------------------
## Verifies the basename-without-extension is extracted correctly for a
## standard path, for a deeply nested path, and that "" is returned when no
## save exists.
func test_get_saved_level_name() -> void:
	# Normal case: a standard level path returns just the file basename.
	SaveManager.save_progress(TEST_LEVEL_01)
	assert_eq(
		SaveManager.get_saved_level_name(), "Level01",
		"get_saved_level_name must return the file basename without extension"
	)

	# Edge case: a deeply nested path returns only the final filename stem.
	SaveManager.save_progress("res://Levels/SubFolder/Level99.tscn")
	assert_eq(
		SaveManager.get_saved_level_name(), "Level99",
		"get_saved_level_name must handle nested paths correctly"
	)

	# Error case: no save file → empty string returned.
	_delete_save()
	assert_eq(
		SaveManager.get_saved_level_name(), "",
		"get_saved_level_name must return '' when no save file exists"
	)


# ---------------------------------------------------------------------------
# Test 4 – start_new_game()
# ---------------------------------------------------------------------------
## Verifies that start_new_game() sets the pending path to the default level,
## persists a save file, and resets back to the default even if a custom path
## was previously pending.
func test_start_new_game() -> void:
	# Normal case: pending path is set to the built-in default level.
	SaveManager.start_new_game()
	assert_eq(
		SaveManager._pending_level_path,
		SaveManager.DEFAULT_LEVEL_PATH,
		"start_new_game must set _pending_level_path to DEFAULT_LEVEL_PATH"
	)

	# Normal case: a save file is written to disk so has_save() is true.
	assert_true(
		SaveManager.has_save(),
		"start_new_game must persist the default level to disk"
	)

	# Edge case: calling it again resets a previously customised pending path.
	SaveManager._pending_level_path = TEST_LEVEL_02
	SaveManager.start_new_game()
	assert_eq(
		SaveManager._pending_level_path,
		SaveManager.DEFAULT_LEVEL_PATH,
		"start_new_game must always reset pending path to DEFAULT_LEVEL_PATH"
	)


# ---------------------------------------------------------------------------
# Test 5 – request_load_game()
# ---------------------------------------------------------------------------
## Verifies that request_load_game() returns false with no save, returns true
## and populates _pending_level_path when a save exists, and that the loaded
## path is then correctly consumable.
func test_request_load_game() -> void:
	# Error case: no save file → must return false.
	assert_false(
		SaveManager.request_load_game(),
		"request_load_game must return false when no save file exists"
	)

	# Normal case: a save exists → returns true and sets pending path.
	SaveManager.save_progress(TEST_LEVEL_02)
	var success := SaveManager.request_load_game()
	assert_true(success,
		"request_load_game must return true when a save file exists"
	)
	assert_eq(
		SaveManager._pending_level_path, TEST_LEVEL_02,
		"request_load_game must populate _pending_level_path with the saved path"
	)

	# Edge case: the pending path set by request_load_game is consumable once.
	var consumed := SaveManager.consume_pending_level_path("")
	assert_eq(
		consumed, TEST_LEVEL_02,
		"The path loaded by request_load_game must be consumable exactly once"
	)
	assert_eq(
		SaveManager._pending_level_path, "",
		"_pending_level_path must be empty after the loaded path is consumed"
	)
