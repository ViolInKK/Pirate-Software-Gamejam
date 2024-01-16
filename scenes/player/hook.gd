extends Node2D

@onready var links = $Links
var direction := Vector2(0,0)
var tip := Vector2(0,0)

const SPEED = 20	

var is_flying = false	
var is_hooked = false	

func shoot(dir: Vector2) -> void:
	direction = dir.normalized()	
	is_flying = true
	tip = self.global_position	
	$Despawn.start()

func release() -> void:
	is_flying = false
	is_hooked = false

func _process(_delta: float) -> void:
	self.visible = is_flying or is_hooked
	if not is_flying:
		$Despawn.stop()
	if not self.visible:
		return
	var tip_loc = to_local(tip)
	links.rotation = self.position.angle_to_point(tip_loc) - deg_to_rad(90)
	$Tip.rotation = self.position.angle_to_point(tip_loc) - deg_to_rad(90)
	links.region_rect.size.y = tip_loc.length() * 3.3

func _physics_process(_delta: float) -> void:
	$Tip.global_position = tip
	if is_flying:
		if $Tip.move_and_collide(direction * SPEED):
			is_hooked = true
			is_flying = false
	tip = $Tip.global_position


func _on_despawn_timeout():
	is_flying = false
	is_hooked = false
