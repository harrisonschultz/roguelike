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
		"defenses": {"physical": 0},
		"attacks": {
			"basic": {
				"damage": [{ "type": "physical", "damage": 1}]
			}
		}	
	}
}

