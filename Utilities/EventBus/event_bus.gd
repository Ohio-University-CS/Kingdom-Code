extends Node

signal block_added(newNode: Node2D, attachingTo: Area2D)
signal level_loaded

var movementDirection = Vector2.ZERO

var playing = false
