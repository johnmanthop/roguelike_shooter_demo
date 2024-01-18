extends Node2D

const TILE_SIZE:		int = 16
var tree_tile: 			Sprite2D
var level_matrix: 		Array
var h_tile_count: 		int
var w_tile_count:		int 
var SCREEN_SIZE:		Vector2
var half_tile_offset = 	Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
var player
var start_point: 		Vector2
var end_point:			Vector2

func init_level_map():
	for h in h_tile_count:
		level_matrix.append([])
		level_matrix[h] = []
		
		for w in w_tile_count:
			level_matrix[h].append([])
			level_matrix[h][w] = 0

func construct_tree_tiles():
	var tree_scene: PackedScene = preload("res://scenes/tree_scene.tscn")
	for i in level_matrix.size():
		for j in level_matrix[0].size():
			if level_matrix[i][j] == 0:
				var tree_tile = tree_scene.instantiate()
				tree_tile.position = Vector2(j, i) * TILE_SIZE
				tree_tile.position += half_tile_offset
				add_child(tree_tile)

func construct_road_in_matrix():
	start_point.y = h_tile_count / 2
	start_point.x = 0
	
	var current_point = start_point
	while current_point.x < w_tile_count - 1:
		var horizontal_length 	= randi_range(2, 4)
		var vertical_length 	= randi_range(2, 4)
		var direction: int
		if randi_range(0, 1) == 0: 	direction = 1
		else:						direction = -1
		
		for l in horizontal_length:
			level_matrix[clamp(current_point.y, 0, h_tile_count - 1)][clamp(current_point.x + l, 0, w_tile_count - 1)] = 1
		current_point.x += horizontal_length
		current_point = current_point.clamp(Vector2(0, 0), Vector2(w_tile_count - 1, h_tile_count - 1))
		
		for l in vertical_length:
			level_matrix[clamp(current_point.y + direction * l, 0, h_tile_count - 1)][clamp(current_point.x, 0, w_tile_count - 1)] = 1
		current_point.y += direction * vertical_length
		current_point = current_point.clamp(Vector2(0, 0), Vector2(w_tile_count - 1, h_tile_count - 1))
	
	end_point = current_point
	
func construct_road_tiles():
	for i in level_matrix.size():
		for j in level_matrix[0].size():
			if level_matrix[i][j] == 1:
				var road_tile = Sprite2D.new()
				road_tile.texture = load("res://game_assets/tiles/road_tile.png")
				road_tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				road_tile.position = Vector2(j, i) * TILE_SIZE
				road_tile.position += half_tile_offset
				add_child(road_tile) 

func is_player_at_entrance():
	return (player.position / TILE_SIZE).distance_to(start_point) < 1.5

func is_player_at_exit():
	return (player.position / TILE_SIZE).distance_to(end_point) < 2

func set_player(p):
	player = p

func get_starting_position():
	return start_point * TILE_SIZE

func tick():
	pass

func _ready():
	SCREEN_SIZE = get_viewport_rect().size
	w_tile_count = SCREEN_SIZE.x / TILE_SIZE
	h_tile_count = SCREEN_SIZE.y / TILE_SIZE

	init_level_map()
	construct_road_in_matrix()
	construct_tree_tiles()
	construct_road_tiles()

