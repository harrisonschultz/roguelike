extends AnimatedSprite

class_name Ability


var source
var target
var core

func _ready():
	core = get_tree().get_root().get_node("Root");

func init(src, trg):
	source = src
	target = trg
	self.position = target.position + Vector2(8, 8)
	self.z_index = Globals.Layer.Ability
	self.play('default')

func remove():
	self.queue_free()
