extends RigidBody2D

signal player_shot(direction: Vector2, position: Vector2)
signal touched_top_tile(tile_pos: Vector2i)
signal touched_right_tile(tile_pos: Vector2i)
signal touched_bottom_tile(tile_pos: Vector2i)
signal touched_left_tile(tile_pos: Vector2i)

const ACCELERATION: int = 2
const CHAIN_PULL: int = 1005	

enum tileset_direction_ids{
	IS_TOP_PAINTABLE = 0,
	IS_RIGHT_PAINTABLE = 2,
	IS_BOTTOM_PAINTABLE = 4,
	IS_LEFT_PAINTABLE = 6,
}

var chain_velocity := Vector2(0,0)
var can_shoot: bool = true

func handle_movement(state: PhysicsDirectBodyState2D) -> void:
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	if $Hook.is_hooked:
		chain_velocity = (position - $Hook.tip).normalized() * CHAIN_PULL * -1
		#Reduce pull down
		if chain_velocity.y > 0:
			chain_velocity.y *= 0.2
		#Increase pull up
		else:
			chain_velocity.y *= 2.3
		#if move opposite of hook direction
		#TODO: fix this abomination if check
		if sign(chain_velocity.x) == 1 and sign(direction.x) == -1 or sign(chain_velocity.x) == -1 and sign(direction.x) == 1:
			chain_velocity.x *= 0.5
		state.apply_central_force(chain_velocity)
	state.apply_central_impulse(direction * ACCELERATION)
		
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	handle_movement(state)

func _input(event: InputEvent) -> void:
	var player_direction = (get_global_mouse_position() - position).normalized()
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 1:
			$Hook.shoot(player_direction)
		else:
			$Hook.release()
			

func _on_reload_timeout() -> void:
	can_shoot = true

func process_tilemap_collision(body, body_rid, is_direction_paintable: int):
	if body is TileMap:
		var current_tilemap = body
		var collided_tile_cords = current_tilemap.get_coords_for_body_rid(body_rid)
		var tile_data: TileData = current_tilemap.get_cell_tile_data(0, collided_tile_cords)
		if !tile_data is TileData:
			return
		if tile_data.get_custom_data_by_layer_id(is_direction_paintable) and !tile_data.get_custom_data_by_layer_id(is_direction_paintable + 1):
			return collided_tile_cords
			
func _on_top_detector_body_shape_entered(body_rid, body, _body_shape_index, _local_shape_index):
	var collided_tile_cords = process_tilemap_collision(body, body_rid, tileset_direction_ids["IS_TOP_PAINTABLE"])
	if collided_tile_cords:
		touched_top_tile.emit(collided_tile_cords)

func _on_right_detector_body_shape_entered(body_rid, body, _body_shape_index, _local_shape_index):
	var collided_tile_cords = process_tilemap_collision(body, body_rid, tileset_direction_ids["IS_RIGHT_PAINTABLE"])
	if collided_tile_cords:
		touched_right_tile.emit(collided_tile_cords)

func _on_bottom_detector_body_shape_entered(body_rid, body, _body_shape_index, _local_shape_index):
	var collided_tile_cords = process_tilemap_collision(body, body_rid, tileset_direction_ids["IS_BOTTOM_PAINTABLE"])
	if collided_tile_cords:
		touched_bottom_tile.emit(collided_tile_cords)

func _on_left_detector_body_shape_entered(body_rid, body, _body_shape_index, _local_shape_index):
	var collided_tile_cords = process_tilemap_collision(body, body_rid, tileset_direction_ids["IS_LEFT_PAINTABLE"])
	if collided_tile_cords:
		touched_left_tile.emit(collided_tile_cords)
	
func _process(_delta):
	if Input.is_action_pressed("secondary action") and can_shoot:
		player_shot.emit((get_global_mouse_position() - position).normalized(), position)
		can_shoot = false
		$Reload.start()
