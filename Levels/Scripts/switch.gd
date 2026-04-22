extends Area2D

var active = true

func _pull_switch():
	active = !active
	
	if active: # the  switch can change any amount of walls
		for i in range(1, get_child_count()):
			get_child(i).visible = true
			get_child(i).get_child(0).get_child(0).disabled = false
	else:
		for i in range(1, get_child_count()):
			get_child(i).visible = false
			get_child(i).get_child(0).get_child(0).disabled = true
