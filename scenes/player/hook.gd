extends Node2D

@onready var links = $Links		# A slightly easier reference to the links
var direction := Vector2(0,0)	# The direction in which the chain was shot
var tip := Vector2(0,0)			# The global position the tip should be in
								# We use an extra var for this, because the chain is 
								# connected to the player and thus all .position
								# properties would get messed with when the player
								# moves.

const SPEED = 15	# The speed with which the chain moves

var is_flying = false	# Whether the chain is moving through the air
var is_hooked = false	# Whether the chain has connected to a wall

# shoot() shoots the chain in a given direction
func shoot(dir: Vector2) -> void:
	direction = dir.normalized()	# Normalize the direction and save it
	is_flying = true					# Keep track of our current scan
	tip = self.global_position		# reset the tip position to the player's position

# release() the chain
func release() -> void:
	is_flying = false	# Not flying anymore	
	is_hooked = false	# Not attached anymore

# Every graphics frame we update the visuals
func _process(_delta: float) -> void:
	self.visible = is_flying or is_hooked	# Only visible if flying or attached to something
	if not self.visible:
		return	# Not visible -> nothing to draw
	var tip_loc = to_local(tip)	# Easier to work in local coordinates
	# We rotate the links (= chain) and the tip to fit on the line between self.position (= origin = player.position) and the tip
	links.rotation = self.position.angle_to_point(tip_loc) - deg_to_rad(90)
	$Tip.rotation = self.position.angle_to_point(tip_loc) - deg_to_rad(90)
	#links.position = tip_loc						# The links are moved to start at the tip
	links.region_rect.size.y = tip_loc.length() * 3.3		# and get extended for the distance between (0,0) and the tip
															# 3.3 is just a magic number making chain be normal length

# Every physics frame we update the tip position
func _physics_process(_delta: float) -> void:
	$Tip.global_position = tip	# The player might have moved and thus updated the position of the tip -> reset it
	if is_flying:
		# `if move_and_collide()` always moves, but returns true if we did collide
		if $Tip.move_and_collide(direction * SPEED):
			is_hooked = true	# Got something!
			is_flying = false	# Not flying anymore
	tip = $Tip.global_position	# set `tip` as starting position for next frame
