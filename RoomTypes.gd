extends Node


var RoomTypes = {
	"start": {
		"props":[{
				"location": { "x": {"from": "center", "mod": 0}, "y": {"from": "center", "mod": 0}},
				"prop": Globals.Props.StairUp
			},
			{
				"location": {"x": {"from": "topLeft", "mod": 2}, "y": {"from": "topLeft", "mod": 1}},
				"prop": Globals.Props.Prisoner
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
	},
	"library": {
		"props":[{
				"location": { "x": {"from": "center", "mod": -2}, "y": {"from": "center", "mod": -2}},
				"prop": Globals.Props.Bookcase
			},
			{
				"location": { "x": {"from": "center", "mod": -1}, "y": {"from": "center", "mod": -2}},
				"prop": Globals.Props.Bookcase
			},
			{
				"location": { "x": {"from": "center", "mod": 1}, "y": {"from": "center", "mod": -2}},
				"prop": Globals.Props.Bookcase
			},
			{
				"location": { "x": {"from": "center", "mod": 2}, "y": {"from": "center", "mod": -2}},
				"prop": Globals.Props.Bookcase
			},
			{
				"location": { "x": {"from": "center", "mod": -2}, "y": {"from": "center", "mod": 2}},
				"prop": Globals.Props.Bookcase
			},
			{
				"location": { "x": {"from": "center", "mod": -1}, "y": {"from": "center", "mod": 2}},
				"prop": Globals.Props.Bookcase
			},
			{
				"location": { "x": {"from": "center", "mod": 1}, "y": {"from": "center", "mod": 2}},
				"prop": Globals.Props.Bookcase
			},
			{
				"location": { "x": {"from": "center", "mod": 2}, "y": {"from": "center", "mod": 2}},
				"prop": Globals.Props.Bookcase
			},
			{
				"location": { "x": {"from": "center", "mod": 2}, "y": {"from": "topLeft", "mod": 1}},
				"prop": Globals.Props.Torch
			},
			{
				"location": { "x": {"from": "center", "mod": -2}, "y": {"from": "topLeft", "mod": 1}},
				"prop": Globals.Props.Torch
			}
		],
	},
	"chest": {
		"requirements": {
			"exclude": {
				"exits": [Globals.Sides.Top]
			}
		},
		"props":[
			{
				"location": { "x": {"from": "center", "mod": -1}, "y": {"from": "topLeft", "mod": 2}},
				"prop": Globals.Props.RugRuined
			},
			{
				"location": { "x": {"from": "center", "mod": 0}, "y": {"from": "topLeft", "mod": 2}},
				"prop": Globals.Props.Chest
			},
			{
				"location": { "x": {"from": "center", "mod": 1}, "y": {"from": "topLeft", "mod": 1}},
				"prop": Globals.Props.Torch
			},
			{
				"location": { "x": {"from": "center", "mod": -1}, "y": {"from": "topLeft", "mod": 1}},
				"prop": Globals.Props.Torch
			}]
	},
	"dining": {
		"props":[{
				"location": { "x": {"from": "center", "mod": -2}, "y": {"from": "center", "mod": -2}},
				"prop": Globals.Props.TableRed
			},
			{
				"location": { "x": {"from": "center", "mod": 2}, "y": {"from": "center", "mod": -2}},
				"prop": Globals.Props.TableRed
			},
			{
				"location": { "x": {"from": "center", "mod": 1}, "y": {"from": "center", "mod": 0}},
				"prop": Globals.Props.TableGreen
			},
			{
				"location": { "x": {"from": "center", "mod": -2}, "y": {"from": "center", "mod": 0}},
				"prop": Globals.Props.TableGreen
			},
			{
				"location": { "x": {"from": "center", "mod": -2}, "y": {"from": "center", "mod": 2}},
				"prop": Globals.Props.TableRed
			},
			{
				"location": { "x": {"from": "center", "mod": 2}, "y": {"from": "center", "mod": 2}},
				"prop": Globals.Props.TableRed
			},
			{
				"location": { "x": {"from": "topRight", "mod": -1}, "y": {"from": "topLeft", "mod": 1}},
				"prop": Globals.Props.Torch
			},
			{
				"location": { "x": {"from": "topLeft", "mod": 1}, "y": {"from": "topLeft", "mod": 1}},
				"prop": Globals.Props.Torch
			},
			{
				"location": { "x": {"from": "center", "mod": 2}, "y": {"from": "topLeft", "mod": 1}},
				"prop": Globals.Props.FlagRed
			},
			{
				"location": { "x": {"from": "center", "mod": -2}, "y": {"from": "topLeft", "mod": 1}},
				"prop": Globals.Props.FlagRed
			},
		],
	}
}

