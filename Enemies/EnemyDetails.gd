extends Node

var enemies = {
	"slime": {
		"actionAnimations": ["Idle", "Move", "Move"],
		"animationDurations": [10, 0.3, 0.3],
		"health": 3,
		"visionRange": 4,
		"attackRange": 1,
		"awards":{
			"experience": 1
		},
		"defenses": { Globals.DamageType.Physical: 0},
		"attacks": {
			"basic": {
					"damage": [{ "type": Globals.DamageType.Physical, "damage": [1,1]}]
			}
		},
		"loot":{
			"gold": [1,3],
			"randomItems": [1,1],
			"rarity": [1,1]
		},
	}
}

