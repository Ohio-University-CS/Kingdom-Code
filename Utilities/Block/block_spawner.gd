extends Node2D

@export var block_scene = preload("res://BlockManager/Blocks/move_block.tscn")

func _ready() -> void:
	var block = block_scene.instantiate()
	add_child(block)
	block.position = Vector2.ZERO


func _physics_process(_delta: float) -> void:
	if get_child_count() == 0:
		var block = block_scene.instantiate()
		add_child(block)
		block.position = Vector2.ZERO
