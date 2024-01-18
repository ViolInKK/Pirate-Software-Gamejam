extends Area2D

signal paint_tile(paintable_directions: Array[bool], collided_tile_cords)

const PLYAER_PROJECTILE_SPEED: int = 700

var direction: Vector2 = Vector2.ZERO 

func _process(delta: float) -> void:
	position += direction * PLYAER_PROJECTILE_SPEED * delta
	
func _on_despawn_timeout() -> void:
	queue_free()

func process_tilemap_collision(body, body_rid):
	var paintable_directions: Array[bool] = []
	var current_tilemap = body
	var collided_tile_cords = current_tilemap.get_coords_for_body_rid(body_rid)
	var tile_data: TileData = current_tilemap.get_cell_tile_data(0, collided_tile_cords)
	if !tile_data is TileData:
		return
	for i in range(0, 7, 2):
		var is_direction_painatble: bool = tile_data.get_custom_data_by_layer_id(i)
		paintable_directions.push_back(is_direction_painatble)
	return paintable_directions
		

func _on_body_shape_entered(body_rid, body, _body_shape_index, _local_shape_index):
	if body is TileMap:
		var paintable_directions = process_tilemap_collision(body, body_rid)
		var tile_cords = body.get_coords_for_body_rid(body_rid)
		paint_tile.emit(paintable_directions, tile_cords)
	queue_free()
	
	
	
#func _on_top_detector_body_shape_entered(body_rid, body, _body_shape_index, _local_shape_index):
	#var collided_tile_cords = process_tilemap_collision(body, body_rid, tileset_direction_ids["IS_TOP_PAINTABLE"])
	#if collided_tile_cords:
		#touched_top_tile.emit(collided_tile_cords)
