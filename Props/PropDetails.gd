extends Node

var PropsFolder = "res://assets/props/"
var assets = { 
	"Chest": PropsFolder + "chest_spritesheet.png", 
	"Bookcase": PropsFolder + "bookshelf.png", 
	"StairUp": PropsFolder + "stairUp.png", 
	"Prisoner": PropsFolder + "prisoner.png", 
	"Barrel": PropsFolder + "barrel_spritesheet.png",
	"Torch": PropsFolder + "torch_spritesheet.png",
	"TableRed": PropsFolder + "table.png",
	"TableGreen": PropsFolder + "table_2.png",
	"FlagGreen": PropsFolder + "flag_green.png",
	"FlagRed": PropsFolder + "flag_red.png",
	"Rug": PropsFolder + "rug.png",
	"RugRuined": PropsFolder + "rug_ruined.png",
}

var props = {
	"Prisoner": {
		"identity": Globals.Things.Prop,
		"collision": false,
		"spritesheet": {"asset":assets.Prisoner, "size": Vector2(1, 1)},
		"animations": [{ "name": "default"}]
	},
	"StairUp": {
		"identity": Globals.Things.Prop,
		"collision": false,
		"spritesheet": {"asset":assets.StairUp, "size": Vector2(1, 1)},
		"animations": [{ "name": "default"}]
	},
	"StairDown": {
		"identity": Globals.Things.Prop,
		"collision": false,
		"spritesheet": {"asset":assets.StairUp, "size": Vector2(1, 1)},
		"animations": [{ "name": "default"}]
	},
	"Bookcase": {
		"identity": Globals.Things.Prop,
		"collision": true,
		"spritesheet": {"asset":assets.Bookcase, "size": Vector2(1, 1)},
		"animations": [{ "name": "default"}]
	},
	"Barrel": {
		"identity": Globals.Things.DestroyableProp,
		"collision": true,
		"spritesheet": {"asset":assets.Barrel, "size": Vector2(11, 3)},
		"animations": [{ "name": "default"}, 
		{ "name": "death", "row": 1, "frames": 11, "speed": 12, "length": 0.2, "loop": false, "cubic": true},
		{ "name": "corpse", "row": 2 }],
		"loot":{
			"gold": [1, 3, 25],
		},
	},
	"Chest": {
		"identity": Globals.Things.InteractableProp,
		"collision": true,
		"spritesheet": {"asset": assets.Chest, "size": Vector2(128, 2)},
		"animations": [{ "name": "default", "frames": 128, "speed": 48}, 
		{ "name": "interact", "row": 1}],
		"loot":{
			"gold": [5, 10, 100],
		},
	},
	"Torch": {
		"identity": Globals.Things.Prop,
		"collision": false,
		"spritesheet": {"asset": assets.Torch, "size": Vector2(6, 1)},
		"animations": [{ "name": "default", "frames": 6, "speed": 10}],
	},
	"TableRed": {
		"identity": Globals.Things.Prop,
		"collision": true,
		"spritesheet": {"asset":assets.TableRed, "size": Vector2(1, 1)},
		"animations": [{ "name": "default"}]
	},
	"TableGreen": {
		"collisionSize": Vector2(2,1),
		"identity": Globals.Things.Prop,
		"collision": true,
		"spritesheet": {"asset":assets.TableGreen, "size": Vector2(1, 1)},
		"animations": [{ "name": "default"}]
	},
	"FlagRed": {
		"identity": Globals.Things.Prop,
		"collision": false,
		"spritesheet": {"asset":assets.FlagRed, "size": Vector2(1, 1)},
		"animations": [{ "name": "default"}]
	},
	"FlagGreen": {
		"identity": Globals.Things.Prop,
		"collision": false,
		"spritesheet": {"asset":assets.FlagGreen, "size": Vector2(1, 1)},
		"animations": [{ "name": "default"}]
	},
	"Rug": {
		"identity": Globals.Things.Prop,
		"collision": false,
		"collisionSize": Vector2(3,3),
		"spritesheet": {"asset":assets.Rug, "size": Vector2(1, 1)},
		"animations": [{ "name": "default"}]
	},
	"RugRuined": {
		"identity": Globals.Things.Prop,
		"collision": false,
		"collisionSize": Vector2(3,3),
		"spritesheet": {"asset":assets.RugRuined, "size": Vector2(1, 1)},
		"animations": [{ "name": "default"}]
	},
}
