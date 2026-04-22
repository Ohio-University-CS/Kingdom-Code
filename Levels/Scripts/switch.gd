extends Area2D

var active = true

func _pull_switch():
	active = !active
	
	if active: # the  switch can change any amount of walls
		for i in range(1, get_child_count()):
			get_child(i).visible = true
	else:
		for i in range(1, get_child_count()):
			get_child(i).visible = false
