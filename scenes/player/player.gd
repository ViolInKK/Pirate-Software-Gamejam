extends RigidBody2D

const ACCELERATION: int = 100	
const CHAIN_PULL = 1005
const MOVE_SPEED = 500	

var chain_velocity := Vector2(0,0)

func is_on_floor() -> bool:
	if $Area2D.has_overlapping_bodies():
		return true
	return false

func handle_movement(state: PhysicsDirectBodyState2D) -> void:
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	var grounded = is_on_floor()
	var walk = (Input.get_action_strength("right") - Input.get_action_strength("left")) * MOVE_SPEED
	if $Hook.is_hooked:
		chain_velocity = to_local($Hook.tip).normalized() * CHAIN_PULL
		if chain_velocity.y > 0:
			chain_velocity.y *= 0.55
		else:
			chain_velocity.y *= 1.65
		if sign(chain_velocity.x) != sign(walk):
			chain_velocity.x *= 0.7
		state.apply_force(chain_velocity)
	else:
		state.apply_force(direction * ACCELERATION)
		

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	handle_movement(state)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			$Hook.shoot(get_global_mouse_position() - position)
		else:
			$Hook.release()


func _process(delta: float) -> void:
	print(to_local($Hook.tip).normalized())
