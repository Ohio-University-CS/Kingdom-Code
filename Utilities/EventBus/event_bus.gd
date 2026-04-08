extends Node

signal block_added(newNode: Node2D, attachingTo: Area2D)
signal level_loaded
signal next_block
signal next_block_two ## used to run after next_block

var movementDirection = Vector2.ZERO
var multiplier = 1
var activeBlock = null

var playing = false
