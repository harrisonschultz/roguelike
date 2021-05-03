extends Node


var RoomTypes = {
	"start": {
		"permanent":[{
				"location": { "x": {"from": "center", "mod": 0}, "y": {"from": "center", "mod": 0}},
				"asset": Globals.Props.StairUp
			},
			{
				"location": {"x": {"from": "topLeft", "mod": 2}, "y": {"from": "topLeft", "mod": 1}},
				"asset": Globals.Props.Prisoner
			},
		],
		"walls":[
			{
				"location": { "x": {"from": "topLeft", "mod": 3}, "y": {"from": "topLeft", "mod": 1}},
				"asset": Globals.WallTiles.Crack
			},{
				"location": { "x": {"from": "topRight", "mod": -2}, "y": {"from": "topLeft", "mod": 1}},
				"asset": Globals.WallTiles.WallMissingBricks
			}
			],
		"floors":[
			{
				"location": { "x": {"from": "topLeft", "mod": 2}, "y": {"from": "topLeft", "mod": 2}},
				"asset": Globals.FloorTiles.DirtyBlank
			},
			{
				"location": { "x": {"from": "topLeft", "mod": 1}, "y": {"from": "topLeft", "mod": 2}},
				"asset": Globals.FloorTiles.BrokenOne
			},
			{
				"location": { "x": {"from": "topLeft", "mod": 3}, "y": {"from": "topLeft", "mod": 2}},
				"asset": Globals.FloorTiles.Three
			},
			{
				"location": { "x": {"from": "topLeft", "mod": 3}, "y": {"from": "topLeft", "mod": 3}},
				"asset": Globals.FloorTiles.BrokenTwo,
				"flipX": true,
			},
			{
				"location": { "x": {"from": "topLeft", "mod": 2}, "y": {"from": "topLeft", "mod": 3}},
				"asset": Globals.FloorTiles.BrokenOne
			},
			{
				"location": { "x": {"from": "topRight", "mod": -2}, "y": {"from": "topLeft", "mod": 2}},
				"asset":  Globals.FloorTiles.DirtyBlank
			},
			{
				"location": { "x": {"from": "topRight", "mod": -1}, "y": {"from": "topLeft", "mod": 2}},
				"asset": Globals.FloorTiles.BrokenTwo
			}
		]
	}
}

