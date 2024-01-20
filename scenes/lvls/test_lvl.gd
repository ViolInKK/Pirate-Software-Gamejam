extends Node2D

#directions are going clockwise: top, right, bottom, left
const TRAIL_ATLAS_CORDS: Array[Vector2i] = [Vector2i(5, 3), Vector2i(4, 2), Vector2i(5, 1), Vector2i(6, 2)]
const TILESET_DIRECTION_LAYERS: Array[int] = [1,2,3,4]

const SCORE_ADDITION = 100

var player_projectile: PackedScene = preload("res://scenes/player/projectile.tscn")

var top_ground_particle: PackedScene = preload("res://scenes/particles/top_ground_particles.tscn")
var right_ground_particle: PackedScene = preload("res://scenes/particles/right_ground_particles.tscn")
var bottom_ghround_particle: PackedScene = preload("res://scenes/particles/bottom_ground_particles.tscn")
var left_ground_particle: PackedScene = preload("res://scenes/particles/left_ground_particles.tscn")
var projectile_explosion_particles: PackedScene = preload("res://scenes/particles/projectile_explosion_particle.tscn")

var seconds: int = 8

func _ready():
	$UI/Time.text = str(seconds)
	$UI/Score.text = str(Globals.score)
	
	
func update_score():
	$UI/Score.text = str(Globals.score)

func _on_player_player_shot(direction: Vector2, player_position: Vector2):
	var player_projectile_instance = player_projectile.instantiate() as Area2D
	player_projectile_instance.position = player_position
	player_projectile_instance.rotation_degrees = rad_to_deg(direction.angle()) + 90
	player_projectile_instance.direction = direction
	player_projectile_instance.connect("paint_tile", on_projectione_touched_tile)
	$Projectiles.add_child(player_projectile_instance, true)
	
func emit_particles(tile_pos, particles: PackedScene):
	var global_pos = $TileMap.map_to_local(tile_pos)
	var particles_instance = particles.instantiate() as GPUParticles2D
	particles_instance.position = global_pos
	$Particles.add_child(particles_instance, true)

func on_projectione_touched_tile(paintable_directions: Array[bool], tile_cords: Vector2i):
	emit_particles(tile_cords, projectile_explosion_particles)
	for i in TILESET_DIRECTION_LAYERS.size():
		if paintable_directions[i] and not $TileMap.get_cell_tile_data(TILESET_DIRECTION_LAYERS[i], tile_cords):
			Globals.score += SCORE_ADDITION
			$TileMap.set_cell(TILESET_DIRECTION_LAYERS[i], tile_cords, 0, TRAIL_ATLAS_CORDS[i])
			update_score()
		
func _on_player_touched_top_tile(tile_pos):
	var tile_data = $TileMap.get_cell_tile_data(TILESET_DIRECTION_LAYERS[0], tile_pos)
	if not tile_data:
		Globals.score += SCORE_ADDITION	
		$TileMap.set_cell(TILESET_DIRECTION_LAYERS[0], tile_pos, 0, TRAIL_ATLAS_CORDS[0])
		update_score()		
	emit_particles(tile_pos, top_ground_particle)

func _on_player_touched_right_tile(tile_pos):
	var tile_data = $TileMap.get_cell_tile_data(TILESET_DIRECTION_LAYERS[1], tile_pos)
	if not tile_data:
		Globals.score += SCORE_ADDITION
		$TileMap.set_cell(TILESET_DIRECTION_LAYERS[1], tile_pos, 0, TRAIL_ATLAS_CORDS[1])
		update_score()		
	emit_particles(tile_pos, right_ground_particle)	

func _on_player_touched_bottom_tile(tile_pos):
	var tile_data = $TileMap.get_cell_tile_data(TILESET_DIRECTION_LAYERS[2], tile_pos)
	if not tile_data:
		Globals.score += SCORE_ADDITION
		$TileMap.set_cell(TILESET_DIRECTION_LAYERS[2], tile_pos, 0, TRAIL_ATLAS_CORDS[2])
		update_score()				
	emit_particles(tile_pos, bottom_ghround_particle)

func _on_player_touched_left_tile(tile_pos):
	var tile_data = $TileMap.get_cell_tile_data(TILESET_DIRECTION_LAYERS[3], tile_pos)
	if not tile_data:
		Globals.score += SCORE_ADDITION
		$TileMap.set_cell(TILESET_DIRECTION_LAYERS[3], tile_pos, 0, TRAIL_ATLAS_CORDS[3])
		update_score()				
	emit_particles(tile_pos, left_ground_particle)


func _on_timer_timeout():
	seconds -= 1
	if seconds <= 0:
		get_tree().change_scene_to_file("res://scenes/ui/end_screen.tscn")
	$UI/Time.text = str(seconds)
