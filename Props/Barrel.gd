extends Prop

class_name DestroyableProp

var health

func _init():
	health = 1
	frames.add_animation('death')
	

	
func hurt(dmg):
	var newHealth = health - dmg
	if newHealth < 1:
		die()
		
func die():
	self.play('death')
