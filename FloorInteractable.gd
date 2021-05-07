extends Sprite

class_name FloorInteractable

var activateRange = 0

func _init(position, details):
	self.centered = false
	self.position = position
	self.z_index = Globals.Layer.Item

func activate(node):
	pass

func isCollidable():
	return false
