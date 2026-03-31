extends GutTest
## Unit tests for MainMenu (res://MainMenu/MainMenu.tscn).
##
## These tests instantiate the real scene so that @onready wiring and signal
## connections that happen in _ready() are exercised exactly as they are at
## runtime.  SaveManager (an autoload) is available in the GUT runtime, so we
## drive UI state by manipulating save files rather than mocking.

const MAIN_MENU_SCENE := "res://MainMenu/MainMenu.tscn"
const TEST_LEVEL_02   := "res://Levels/Level02.tscn"
const SAVE_FILE       := "save_game.cfg"   # filename inside user://

# Node paths inside the MainMenu scene (mirrors @onready in main_menu.gd).
const PATH_LOAD_BTN    := "MarginContainer/PanelContainer/MarginContainer/VBoxContainer/LoadButton"
const PATH_STATUS_LBL  := "MarginContainer/PanelContainer/MarginContainer/VBoxContainer/StatusLabel"


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _delete_save() -> void:
	var dir := DirAccess.open("user://")
	if dir and dir.file_exists(SAVE_FILE):
		dir.remove(SAVE_FILE)

## Instantiates the MainMenu scene, adds it to the test tree (autofree'd), and
## waits one frame so that _ready() and all @onready assignments complete.
func _load_menu() -> Control:
	var menu: Control = load(MAIN_MENU_SCENE).instantiate()
	add_child_autofree(menu)
	await get_tree().process_frame
	return menu


# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func after_each() -> void:
	_delete_save()
	SaveManager._pending_level_path = ""


# ---------------------------------------------------------------------------
# Test 6 – Load button disabled / enabled based on save presence
# ---------------------------------------------------------------------------
## Verifies the Load button is disabled on a clean start (no save), is enabled
## after a save is written and _refresh_load_state() is called, and is disabled
## again when the save is deleted and the state is refreshed.
func test_load_button_disabled_state() -> void:
	# Normal case: no save file → _ready() leaves Load button disabled.
	var menu  := await _load_menu()
	var load_btn := menu.get_node(PATH_LOAD_BTN) as Button
	assert_true(
		load_btn.disabled,
		"Load button must start disabled when there is no save file"
	)

	# Edge case: creating a save and calling _refresh_load_state enables it.
	SaveManager.save_progress(TEST_LEVEL_02)
	menu._refresh_load_state()
	assert_false(
		load_btn.disabled,
		"Load button must be enabled after a save file is created"
	)

	# Error case: deleting the save and refreshing disables it again.
	_delete_save()
	menu._refresh_load_state()
	assert_true(
		load_btn.disabled,
		"Load button must be disabled again once the save file is removed"
	)


# ---------------------------------------------------------------------------
# Test 7 – StatusLabel text reflects save state
# ---------------------------------------------------------------------------
## Verifies the StatusLabel shows "No saved game found." when no save exists,
## updates to "Continue from <name>." when a save is present, and reverts
## when the save is removed.
func test_status_label_text() -> void:
	# Normal case: no save → label shows the no-save message.
	var menu  := await _load_menu()
	var label := menu.get_node(PATH_STATUS_LBL) as Label
	assert_eq(
		label.text, "No saved game found.",
		"StatusLabel must show the no-save message when no save file exists"
	)

	# Edge case: saving Level02 makes the label announce it.
	SaveManager.save_progress(TEST_LEVEL_02)
	menu._refresh_load_state()
	assert_true(
		label.text.begins_with("Continue from"),
		"StatusLabel must begin with 'Continue from' when a save exists"
	)
	assert_true(
		label.text.contains("Level02"),
		"StatusLabel must include the saved level name ('Level02')"
	)

	# Error case: removing the save reverts the label to the no-save message.
	_delete_save()
	menu._refresh_load_state()
	assert_eq(
		label.text, "No saved game found.",
		"StatusLabel must revert to the no-save message after the save is deleted"
	)
