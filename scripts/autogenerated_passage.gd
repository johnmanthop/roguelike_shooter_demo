extends Node2D

enum TILE
{
	TREE_T,
	ROAD_T,
	BUILDING_T
}

const PROX_ZONE:		float = 2
const TILE_SIZE:		int = 16
var tree_tile: 			Sprite2D
var level_matrix: 		Array
var h_tile_count: 		int
var w_tile_count:		int 
var SCREEN_SIZE:		Vector2
var half_tile_offset = 	Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
var player
var entry_point_left: 		Vector2
var entry_point_right:		Vector2

func init_level_map():
	for h in h_tile_count:
		level_matrix.append([])
		level_matrix[h] = []
		
		for w in w_tile_count:
			level_matrix[h].append([])
			level_matrix[h][w] = TILE.TREE_T

func construct_tree_tiles():
	var tree_scene: PackedScene = preload("res://scenes/tree_scene.tscn")
	for i in level_matrix.size():
		for j in level_matrix[0].size():
			if level_matrix[i][j] == TILE.TREE_T or level_matrix[i][j] == TILE.BUILDING_T:
				var tree_tile = tree_scene.instantiate()
				tree_tile.position = Vector2(j, i) * TILE_SIZE
				tree_tile.position += half_tile_offset
				add_child(tree_tile)

func construct_road_in_matrix():
	entry_point_left.y = h_tile_count / 2
	entry_point_left.x = 0
	
	var current_point = entry_point_left
	while current_point.x < w_tile_count - 1:
		var horizontal_length 	= randi_range(2, 4)
		var vertical_length 	= randi_range(2, 4)
		var direction: int
		
		if randi_range(0, 1) == 0: 	direction = 1
		else:						direction = -1
		
		for l in horizontal_length:
			level_matrix[clamp(current_point.y, 0, h_tile_count - 1)][clamp(current_point.x + l, 0, w_tile_count - 1)] = TILE.ROAD_T
		current_point.x += horizontal_length
		current_point = current_point.clamp(Vector2(0, 0), Vector2(w_tile_count - 1, h_tile_count - 1))
		
		if current_point.x >= w_tile_count - 2:
			break
		
		for l in vertical_length:
			level_matrix[clamp(current_point.y + direction * l, 0, h_tile_count - 1)][clamp(current_point.x, 0, w_tile_count - 1)] = TILE.ROAD_T
		current_point.y += direction * vertical_length
		current_point = current_point.clamp(Vector2(0, 0), Vector2(w_tile_count - 1, h_tile_count - 1))
	
	for l in 3:
		level_matrix[clamp(current_point.y, 0, h_tile_count - 1)][clamp(current_point.x + l, 0, w_tile_count - 1)] = TILE.ROAD_T
	current_point.x += 3
	current_point = current_point.clamp(Vector2(0, 0), Vector2(w_tile_count - 1, h_tile_count - 1))
		
	entry_point_right = current_point
	
func construct_road_tiles():
	for i in level_matrix.size():
		for j in level_matrix[0].size():
			if level_matrix[i][j] == TILE.ROAD_T:
				var road_tile = Sprite2D.new()
				road_tile.texture = load("res://game_assets/tiles/road_tile.png")
				road_tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				road_tile.position = Vector2(j, i) * TILE_SIZE
				road_tile.position += half_tile_offset
				add_child(road_tile) 

func construct_building_in_matrix():
	var is_free = true
	var root_position
	for i in 10:
		root_position = Vector2(randi_range(0, w_tile_count - 5), randi_range(0, h_tile_count - 3))
		for w in 5:
			for h in 3:
				if level_matrix[root_position.y + h][root_position.x + w] != TILE.TREE_T:
					is_free = false
		var is_above_road = false
		for h in h_tile_count - 1 - root_position.y:
			if level_matrix[root_position.y + h][root_position.x] == TILE.ROAD_T:
				is_above_road = true
		if !is_above_road:
			is_free = false
		if is_free:
			break
	if is_free:
		for w in 5:
			for h in 3:
				level_matrix[root_position.y + h][root_position.x + w] = TILE.BUILDING_T
		for h in h_tile_count - 1 - root_position.y:
			if level_matrix[root_position.y + h][root_position.x + 1] == TILE.ROAD_T:
				break
			else:
				level_matrix[root_position.y + h][root_position.x + 1] = TILE.ROAD_T

func construct_building_tiles():
	for i in level_matrix.size():
		for j in level_matrix[0].size():
			if level_matrix[i][j] == TILE.BUILDING_T:
				var road_tile = Sprite2D.new()
				road_tile.texture = load("res://game_assets/buildings/forest_house.png")
				road_tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				road_tile.position = Vector2(j + 2, i + 1) * TILE_SIZE
				road_tile.position += half_tile_offset
				add_child(road_tile)
				return

func is_player_at_left_entry():
	return player.position.distance_to(entry_point_left * TILE_SIZE + half_tile_offset) <= PROX_ZONE

func is_player_at_right_entry():
	return player.position.distance_to(entry_point_right * TILE_SIZE + half_tile_offset) <= PROX_ZONE

func set_player(p):
	player = p

func get_starting_position(left: bool):
	if left: return entry_point_left * TILE_SIZE
	else:	 return entry_point_right * TILE_SIZE
	
func tick():
	pass
	
func _ready():
	SCREEN_SIZE = get_viewport_rect().size
	w_tile_count = SCREEN_SIZE.x / TILE_SIZE
	h_tile_count = SCREEN_SIZE.y / TILE_SIZE

	init_level_map()
	construct_road_in_matrix()
	construct_building_in_matrix()
	construct_tree_tiles()
	construct_road_tiles()
	construct_building_tiles()

