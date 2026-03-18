extends Node

signal block_added(newNode: Node2D, attachingTo: Area2D)

var movementDirection = Vector2.ZERO

var playing = false
