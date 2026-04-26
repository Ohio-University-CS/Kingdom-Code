extends Area2D


func _pull_switch():
		for i in range(2, get_child_count()):
			if !get_child(i).get_child(0).visible: #swaps to visible
				get_child(i).get_child(0).visible = true
				get_child(i).get_child(0).get_child(0).get_child(0).disabled = false
				get_child(i).get_child(1).visible = false
				get_child(0).set_frame(0)
				print("door ", i, "visible")
			else: #swaps to invisible
				get_child(i).get_child(0).visible = false
				get_child(i).get_child(0).get_child(0).get_child(0).disabled = true
				get_child(i).get_child(1).visible = true
				get_child(0).set_frame(2)
				print("door ", i, "hidden")
