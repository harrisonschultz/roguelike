extends Ability

var duration

func _ready():
	get_parent().remove_child(self)	
	target.add_child(self)
	target.addDebuff(self)
	duration = 1
	self.position = Vector2(8,8)

func affect():
	# just do 1 damage for now
	target.hurt(1)
	pass
