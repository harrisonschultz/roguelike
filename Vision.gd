extends Node
class_name Vision

var walls

func _init(w):
	walls = w

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func projectTile(x, y):
	x = float(x)
	y = float(y)
	var topLeft = x / (y + 2)
	var bottomRight = (x + 1) / (y + 1)
	return Shadow.new(topLeft, bottomRight)
	

func look(pos: Vector2, radius: int):
	var shadows = []
	var revealedPoints = []
	for octant in 8:
		var line = ShadowLine.new()
		var fullShadow = false
		for y in range(1, radius):
			# todo: check bounds y
			var horizontalRange = y + 1
			if horizontalRange == radius:
				horizontalRange -= 2
			for x in horizontalRange:
				
				# todo: check bounds x
				var position = pos + transformOctant(x, y, octant)
				
				if !fullShadow:
					var projection = projectTile(x, y)
					var visible = !line.isInShadow(projection)
					if visible:
						revealedPoints.append(position)
						var wallTile = walls.get_cell(position.x, position.y)
						if wallTile != -1 && wallTile != Globals.WallTiles.Wall && wallTile != Globals.WallTiles.Bottom && wallTile != Globals.WallTiles.BottomInnerLeft && wallTile != Globals.WallTiles.BottomInnerRight:
							line.add(projection)
							fullShadow = line.isFullShadow()
	return revealedPoints
			
func transformOctant(x: int, y: int , octant: int):
	match octant:
		0:
			return Vector2(x, -y)
		1:
			return Vector2(y, -x)
		2:
			return Vector2(y, x)
		3:
			return Vector2(x, y)
		4:
			return Vector2(-x, y)
		5:
			return Vector2(-y, x)
		6:
			return Vector2(-y, -x)
		7:
			return Vector2(-x, -y)
