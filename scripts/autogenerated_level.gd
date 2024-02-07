extends Node2D

const TILE_SIZE:			int = 16
var SCREEN_SIZE:			Vector2
const W_LEVEL_SIZE:			int = 17
const H_LEVEL_SIZE:			int = 11
const NO_OF_ROOMS:		int = 4
var half_tile_offset:		Vector2
var level_matrix:			Array
var w_tile_count:			int
var h_tile_count:			int
var player_starting_point: 	Vector2
var enemy_room_positions: 	Array
var player
var active_room_position:	Vector2

enum TILE
{
	TREE_T,
	ROAD_T,
	STARTING_POINT_T,
	ROOM_ENTRANCE_T
}

func get_random_pos_global() -> Vector2:
	return Vector2(randi_range(0, W_LEVEL_SIZE - 1), randi_range(0, H_LEVEL_SIZE - 1))

func get_random_pos_local() -> Vector2:
	return Vector2(randi_range(0, w_tile_count - 1), randi_range(0, h_tile_count - 1))

func init_level_matrix():
	for h in H_LEVEL_SIZE:
		level_matrix.append([])
		level_matrix[h] = []
		
		for w in W_LEVEL_SIZE:
			level_matrix[h].append([])
			level_matrix[h][w] = TILE.TREE_T

func construct_starting_point_in_matrix():
	player_starting_point = get_random_pos_global()
	level_matrix[player_starting_point.y][player_starting_point.x] = TILE.ROAD_T

func construct_enemy_rooms_in_matrix():
	for i in NO_OF_ROOMS:
		var random_pos = get_random_pos_global()
		while random_pos == player_starting_point:
			random_pos = get_random_pos_global()
		
		enemy_room_positions.append(random_pos)
		level_matrix[random_pos.y][random_pos.x] = TILE.ROOM_ENTRANCE_T

func find_path(a: Vector2, b: Vector2) -> Array:
	var path 				= []
	var current_point 		= a 
	
	var dir_x: int
	if a.x < b.x:
		dir_x = 1
	else:
		dir_x = -1
		
	var dir_y: int
	if a.y < b.y:
		dir_y = 1
	else:
		dir_y = -1

	path.append(current_point)
	
	if randi_range(0, 1) == 0:
		for w in abs(a.x - b.x):
			current_point.x += dir_x
			path.append(current_point)
		
		for h in abs(a.y - b.y):
			current_point.y += dir_y
			path.append(current_point)
	else:
		for h in abs(a.y - b.y):
			current_point.y += dir_y
			path.append(current_point)
		
		for w in abs(a.x - b.x):
			current_point.x += dir_x
			path.append(current_point)
	
	path.pop_front()
	path.pop_back()
	
	return path
	
func construct_roads_in_matrix():
	var points_to_connect = [player_starting_point]
	points_to_connect += enemy_room_positions
	
	for i in points_to_connect.size() - 1:
		var point_1 = points_to_connect[i]
		var point_2 = points_to_connect[i + 1]
		var path 	= find_path(point_1, point_2)

		for point in path:
			if level_matrix[point.y][point.x] != TILE.ROOM_ENTRANCE_T:
				level_matrix[point.y][point.x] = TILE.ROAD_T

func convert_matrix_to_tilemap():
	for i in level_matrix.size():
		for j in level_matrix[0].size():
			if level_matrix[i][j] == TILE.ROAD_T:
				var road_tile = Sprite2D.new()
				road_tile.texture = load("res://game_assets/tiles/road_tile.png")
				road_tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				road_tile.position = Vector2(j, i) * TILE_SIZE
				road_tile.position += half_tile_offset
				add_child(road_tile)
			elif level_matrix[i][j] == TILE.TREE_T:
				var tree_tile = preload("res://scenes/tree_scene.tscn").instantiate()
				tree_tile.position = Vector2(j, i) * TILE_SIZE
				tree_tile.position += half_tile_offset
				add_child(tree_tile)
			elif level_matrix[i][j] == TILE.ROOM_ENTRANCE_T:
				var road_tile = Sprite2D.new()
				road_tile.texture = load("res://game_assets/tiles/enemy_room_entrance.png")
				road_tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				road_tile.position = Vector2(j, i) * TILE_SIZE
				road_tile.position += half_tile_offset
				add_child(road_tile)

func handle_player_transfer():
	active_room_position = Vector2(-1, -1)
	for room_position in enemy_room_positions:
		if (player.position).distance_to(room_position * TILE_SIZE + half_tile_offset) < 12:
			active_room_position = room_position

func get_active_enemy_room():
	return active_room_position

func set_player_pointer(p):
	player = p

func _process(delta):
	handle_player_transfer()

func _ready():
	SCREEN_SIZE 		= get_viewport_rect().size
	half_tile_offset 	= Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
	w_tile_count 		= SCREEN_SIZE.x / TILE_SIZE
	h_tile_count		= SCREEN_SIZE.y / TILE_SIZE
	active_room_position = Vector2(-1, -1)

	init_level_matrix()
	construct_starting_point_in_matrix()
	construct_enemy_rooms_in_matrix()
	construct_roads_in_matrix()
	convert_matrix_to_tilemap()
