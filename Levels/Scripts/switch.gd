extends Area2D


func _pull_switch():
		for i in range(1, get_child_count()):
			if !get_child(i).visible:
				get_child(i).visible = true
				get_child(i).get_child(0).get_child(0).disabled = false
				print("door ", i, "visible")
			else:
				get_child(i).visible = false
				get_child(i).get_child(0).get_child(0).disabled = true
				print("door ", i, "hidden")
