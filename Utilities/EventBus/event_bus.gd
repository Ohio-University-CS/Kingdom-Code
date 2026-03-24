extends Node

 #id is what type of block, like MoveBlock, value is the value attached to the block like direction, rank is how many blocks down it was added, node is the node   
signal block_added(newNode: Node2D, attachingTo: Area2D)
signal level_loaded
