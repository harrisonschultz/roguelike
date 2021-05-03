extends AnimatedSprite

class_name Prop

var collision = false

func _init():
	self.z_index = Globals.Layer.Prop
	self.centered = false
	frames = SpriteFrames.new()
	frames.add_animation('default')
	

func init(sprite, loc, collide = false):
	var frame = ImageTexture.new()
	var image = Image.new()
	collision = collide	
	image.load(sprite)
	frame.create_from_image(image,frame.FLAG_MIPMAPS)
	frames.add_frame('default', frame, 0)
	self.position = loc
	self.play('default')
	
func isCollidable():
	return collision
	
