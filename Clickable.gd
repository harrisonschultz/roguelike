extends Area2D

func _input_event(viewport, event, shape_idx):
	if event.is_action("LeftClick") && !event.pressed:
		get_parent().onClick()
