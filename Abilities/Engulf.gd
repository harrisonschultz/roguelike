extends Ability

func _ready():
	affect()
	pass # Replace with function body.
	
	
func affect():
	core.performAbility('Burn', source, target)
	pass

func _on_AnimatedSprite_animation_finished():
	self.queue_free()
	pass # Replace with function body.
