extends Node

class_name PropAPI

static func spawnProp(propName, location):
	var identity = PropDetails.props[propName].identity
	var prop
	if identity == Globals.Things.InteractableProp:
		prop = InteractableProp.new()
	else:
		prop = Prop.new()
		
	prop.init(propName, Movement.mapToWorld(location))
	return prop
