extends GutTest
## Unit tests for the Level class (res://Levels/Scripts/level.gd).
##
## Level.get_next_level_path() is a pure string-formatting function and requires
## no scene-tree context, so we test it by constructing a bare Level node and
## calling the method directly without adding it to the tree.

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

## Returns a bare Level node with no @onready vars resolved (no scene-tree
## context is needed for the methods under test).
func _make_level(number: int) -> Level:
	var lvl = autofree(Level.new())
	lvl.level_number = number
	return lvl


# ---------------------------------------------------------------------------
# Test 8 – Level.get_next_level_path() path formatting
# ---------------------------------------------------------------------------
## Verifies that the generated next-level path is correctly zero-padded, that
## double-digit level numbers are formatted without padding, and that level 0
## produces the first level path.
func test_get_next_level_path_formatting() -> void:
	# Normal case: single-digit level produces a zero-padded two-digit path.
	var lvl1 := _make_level(1)
	assert_eq(
		lvl1.get_next_level_path(),
		"res://levels/Level02.tscn",
		"Level 1 must produce the path for Level02"
	)

	# Edge case: level 9 rolls into a double-digit number without extra padding.
	var lvl9 := _make_level(9)
	assert_eq(
		lvl9.get_next_level_path(),
		"res://levels/Level10.tscn",
		"Level 9 must produce Level10 (no triple-digit padding)"
	)

	# Edge case: level 0 produces the first-level path (matches default save).
	var lvl0 := _make_level(0)
	assert_eq(
		lvl0.get_next_level_path(),
		"res://levels/Level01.tscn",
		"Level 0 must produce Level01"
	)
