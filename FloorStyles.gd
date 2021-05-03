extends Node

var patternType = {
	Box = "box"
}


var floorStyles = {
	"EmptySquare": [{
		"type": patternType.Box,
		"descriptors": {
			"topLeft": { "x":{"from": "topLeft", "mod": 3}, "y": {"from": "topLeft", "mod": 4}},
			"bottomRight": { "x":{"from": "bottomRight", "mod": -3}, "y": {"from": "bottomRight", "mod": -2}}
			},
		"filler":  Globals.FloorTiles.DirtyBlank
	}],
	"FourSquare":[
		{
		"type": patternType.Box,
		"descriptors": {
			"topLeft": { "x":{"from": "topLeft", "mod": 2}, "y": {"from": "topLeft", "mod": 3}},
			"bottomRight": { "x":{"from": "center", "mod": -1}, "y": {"from": "center", "mod": -1}}
			},
		"filler":  Globals.FloorTiles.Four
	},
	{
		"type": patternType.Box,
		"descriptors": {
			"topLeft": { "x":{"from": "center", "mod": 1}, "y": {"from": "topLeft", "mod": 3}},
			"bottomRight": { "x":{"from": "topRight", "mod": -2}, "y": {"from": "center", "mod": -1}}
			},
		"filler":  Globals.FloorTiles.Four
	},
	{
		"type": patternType.Box,
		"descriptors": {
			"topLeft": { "x":{"from": "topLeft", "mod": 2}, "y": {"from": "center", "mod": 1}},
			"bottomRight": { "x":{"from": "center", "mod": -1}, "y": {"from": "bottomRight", "mod": -1}}
			},
		"filler":  Globals.FloorTiles.Four
	},{
		"type": patternType.Box,
		"descriptors": {
			"topLeft": { "x":{"from": "center", "mod": 1}, "y": {"from": "center", "mod": 1}},
			"bottomRight": { "x":{"from": "bottomRight", "mod": -2}, "y": {"from": "bottomRight", "mod": -1}}
			},
		"filler":  Globals.FloorTiles.Four
	}],
	"ThreeStripes":[
		{
		"type": patternType.Box,
		"descriptors": {
			"topLeft": { "x":{"from": "topLeft", "mod": 2}, "y": {"from": "topLeft", "mod": 3}},
			"bottomRight": { "x":{"from": "topRight", "mod": -2}, "y": {"from": "topRight", "mod": 3}}
			},
		"filler":  Globals.FloorTiles.AltFourTop
	},
	{
		"type": patternType.Box,
		"descriptors": {
			"topLeft": { "x":{"from": "topLeft", "mod": 2}, "y": {"from": "center", "mod": 0}},
			"bottomRight": { "x":{"from": "topRight", "mod": -2}, "y": {"from": "center", "mod": 0}}
			},
		"filler":  Globals.FloorTiles.Four
	},
	{
		"type": patternType.Box,
		"descriptors": {
			"topLeft": { "x":{"from": "bottomLeft", "mod": 2}, "y": {"from": "bottomLeft", "mod": -1}},
			"bottomRight": { "x":{"from": "bottomRight", "mod": -2}, "y": {"from": "bottomRight", "mod": -1}}
			},
		"filler":  Globals.FloorTiles.AltFourTop,
		"flipY": true,
	}]
}


