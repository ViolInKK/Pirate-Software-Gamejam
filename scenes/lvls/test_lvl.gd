extends Node2D

var player_projectile: PackedScene = preload("res://scenes/player/projectile.tscn")

const trail_atlas_cords: Array[Vector2i] = [Vector2i(5, 3), Vector2i(4, 2), Vector2i(5, 1), Vector2i(6, 2)]

func _on_player_player_shot(direction: Vector2, position: Vector2):
	var player_projectile_instance = player_projectile.instantiate() as Area2D
	player_projectile_instance.position = position
	player_projectile_instance.rotation_degrees = rad_to_deg(direction.angle()) + 90
	player_projectile_instance.direction = direction
	$Projectiles.add_child(player_projectile_instance, true)
	
func emit_particles(tile_pos):
	var global_pos = $TileMap.map_to_local(tile_pos)
	$Particles.position = global_pos
	$Particles.emitting = true
					
func _on_player_touched_top_tile(tile_pos):
	$TileMap.set_cell(1, tile_pos, 0, trail_atlas_cords[0])
	var global_pos = $TileMap.map_to_local(tile_pos)
	$Particles/TopParticles.position = global_pos
	$Particles/TopParticles.emitting = true

func _on_player_touched_right_tile(tile_pos):
	$TileMap.set_cell(2, tile_pos, 0, trail_atlas_cords[1])

func _on_player_touched_bottom_tile(tile_pos):
	$TileMap.set_cell(3, tile_pos, 0, trail_atlas_cords[2])
	
func _on_player_touched_left_tile(tile_pos):
	$TileMap.set_cell(4, tile_pos, 0, trail_atlas_cords[3])
	
