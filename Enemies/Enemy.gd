extends Unit

class_name Enemy

func searchForPlayer():
	var visibleTiles = vision.look(self.position, visionRange)
	
	for tile in visibleTile:
		if tile == player.position:
			lastKnownPlayerPosition = player.position
			
func step():
	searchForPlayer()
	if lastKnownPlayerPosition:
		Core.move(lastKnownPlayerPosition.x, lastKnownPlayerPosition.y)
