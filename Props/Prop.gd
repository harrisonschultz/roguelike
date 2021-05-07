extends Sprite

class_name Prop

var collision = false
var identity = Globals.Things.Prop
var details
var health = 1
var loot
var defenses = {}
var ready = false
var animationPlayer
var collisionSize = Vector2(1,1)

func _init():
	self.z_index = Globals.Layer.Prop
	self.centered = false
	self.vframes = 1
	self.hframes = 1
	
func _ready():
	ready = true
	animationPlayer = AnimationPlayer.new()
	self.add_child(animationPlayer)
	initializeAnimations()
	
func init(name, loc):
	details = PropDetails.props[name]
	identity = PropDetails.props[name].identity
	self.position = loc
	
	
	if 'health' in details:
		health = details['health']
	if 'defenses' in details:
		defenses = details['defenses']
	if 'loot' in details:
		loot = details['loot']
	if 'collisionSize' in details:
		collisionSize = details['collisionSize']
		
	setCollision()
	initializeAnimations()

func initializeAnimations():
	if 'animations' in details && ready && animationPlayer.get_animation_list().size() < 1:
		self.vframes = details.spritesheet.size.y
		self.hframes = details.spritesheet.size.x
		var image = load(details.spritesheet.asset)
		image.flags = image.FLAG_MIPMAPS 
		self.texture = image
		addAnimations(details['animations'])
		playAnimation('default')

func playAnimation(animation):
	animationPlayer.set_current_animation(animation)
	animationPlayer.play(animation)	
	
func addAnimations(animations):
	for animation in animations:
		addAnimation(animation)
		
func addAnimation(animation):
	var ani = Animation.new()
	ani.add_track(0)
	ani.track_set_path(0, str(self.get_path()) + ":frame") 
		
	var loop = true
	var speed = 1
	var frames = 1
	var row = 0
	
	if 'loop' in animation:
		loop = animation.loop
	if 'speed' in animation:
		speed = animation.speed
	if 'frames' in animation:
		frames = animation.frames
	if 'row' in animation:
		row = animation.row
		
	ani.length = float(frames)/float(speed)
	if 'length' in animation:
		ani.length = animation.length
		
	for x in frames:
		var frameTime = float(x) * 1.0/float(speed)
		ani.track_insert_key(0, frameTime, row * self.hframes + x)
	
	ani.set_loop(loop)
	ani.value_track_set_update_mode(0, Animation.UPDATE_DISCRETE)
	if "cubic" in animation && animation.cubic == true:
		ani.track_set_interpolation_type (0, Animation.INTERPOLATION_CUBIC)
	
	animationPlayer.add_animation(animation.name, ani)

	
func isCollidable():
	return collision

func setCollision():
	collision = details['collision']
	if collision:
		var nodeMapPosition = Movement.worldToMap(self.position)
		
		if collisionSize > Vector2(1,1):
			for y in collisionSize.y:
				for x in collisionSize.x:
					var occupiedTile = Vector2(nodeMapPosition.x + x, nodeMapPosition.y + y)
					Globals.registerPosition(occupiedTile, true)
		else:
			Globals.registerPosition(self.position)


	
func die():
	Globals.removePosition(self.position)
	playAnimation('death')
	if animationPlayer.has_animation('corpse'):
		animationPlayer.queue('corpse')
		
	if details['loot']:
		Loot.dropLoot(self)
		
