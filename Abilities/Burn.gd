extends Ability

func _ready():
	get_parent().remove_child(self)	
	target.add_child(self)
	self.position = Vector2(8,8)
	print(target)

func affect():
	pass

func _on_AnimatedSprite_animation_finished():
	affect()
	pass # Replace with function body.
