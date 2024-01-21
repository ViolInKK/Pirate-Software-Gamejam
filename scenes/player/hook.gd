extends Node2D

@onready var links = $Links

const SPEED = 20	

var direction := Vector2(0,0)
var tip := Vector2(0,0)
var is_flying = false	
var is_hooked = false
var can_shoot = true

func shoot(dir: Vector2) -> void:
	if can_shoot:
		can_shoot = false
		direction = dir
		tip = self.global_position	
		is_flying = true
		$Despawn.start()
		$Reload.start()

func release() -> void:
	is_flying = false
	is_hooked = false

func _process(_delta: float) -> void:
	self.visible = is_flying or is_hooked
	if not self.visible:
		return
	if not is_flying:
		$Despawn.stop()
	var tip_loc = to_local(tip)
	links.rotation = self.position.angle_to_point(tip_loc) - deg_to_rad(90)
	$Tip.rotation = self.position.angle_to_point(tip_loc) - deg_to_rad(90)
	links.region_rect.size.y = tip_loc.length() * 0.75

func _physics_process(_delta: float) -> void:
	$Tip.global_position = tip
	if is_flying:
		if $Tip.move_and_collide(direction * SPEED):
			is_hooked = true
			can_shoot = true
			$Reload.stop()
			is_flying = false
	tip = $Tip.global_position


func _on_despawn_timeout():
	is_flying = false
	is_hooked = false

func _on_reload_timeout():
	can_shoot = true
