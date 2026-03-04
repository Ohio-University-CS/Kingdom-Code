extends Node

 #id is what type of block, like MoveBlock, value is the value attached to the block like direction, rank is how many blocks down it was added, node is the node   
signal block_added(id: int, value: Vector2, rank: int, node: Node)
