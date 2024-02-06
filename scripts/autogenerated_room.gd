extends Node2D

enum TILE
{
	FLOOR_T, 
	FLOOR_T_B1, 
	FLOOR_T_B2,
	FLOOR_T_B3,
	FLOOR_T_B4,
	FLOOR_T_BC1,
	FLOOR_T_BC2,
	FLOOR_T_BC3,
	FLOOR_T_BC4,
	BOX_T
}

const PROX_ZONE:		float = 2
var NO_OF_ENEMIES: 		int = 8
var NO_OF_BOXES: 		int = 20
var SCREEN_SIZE: 		Vector2
const TILE_SIZE:		int = 16
var active_enemies: 	Array
var active_bullets: 	Array
var bullet_scene:		PackedScene
var w_tile_count:		int
var h_tile_count:		int
var game_over:			bool = false
var level_matrix:		Array # 2d level description array
var half_tile_offset	= Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
var enemy_ai
var player
var entry_point_left:		Vector2
var entry_point_right:		Vector2

func set_player(p):
	player = p

func construct_floor_tiles():
	for i in level_matrix.size():
		for j in level_matrix[0].size():
			var floor_tile = Sprite2D.new()
			if level_matrix[i][j] == TILE.FLOOR_T:
				floor_tile.texture = load("res://game_assets/tiles/floor_rock_tile.png")
			elif level_matrix[i][j] == TILE.FLOOR_T_B1:
				floor_tile.texture = load("res://game_assets/tiles/floor_b1_rock_tile.png")
			elif level_matrix[i][j] == TILE.FLOOR_T_B2:
				floor_tile.texture = load("res://game_assets/tiles/floor_b2_rock_tile.png")
			elif level_matrix[i][j] == TILE.FLOOR_T_B3:
				floor_tile.texture = load("res://game_assets/tiles/floor_b3_rock_tile.png")
			elif level_matrix[i][j] == TILE.FLOOR_T_B4:
				floor_tile.texture = load("res://game_assets/tiles/floor_b4_rock_tile.png")
			elif level_matrix[i][j] == TILE.FLOOR_T_BC1:
				floor_tile.texture = load("res://game_assets/tiles/floor_bc1_rock_tile.png")
			elif level_matrix[i][j] == TILE.FLOOR_T_BC2:
				floor_tile.texture = load("res://game_assets/tiles/floor_bc2_rock_tile.png")
			elif level_matrix[i][j] == TILE.FLOOR_T_BC3:
				floor_tile.texture = load("res://game_assets/tiles/floor_bc3_rock_tile.png")
			elif level_matrix[i][j] == TILE.FLOOR_T_BC4:
				floor_tile.texture = load("res://game_assets/tiles/floor_bc4_rock_tile.png")
			
			floor_tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			floor_tile.position = Vector2(j, i) * TILE_SIZE
			floor_tile.position += half_tile_offset
			add_child(floor_tile)

func fix_possible_player_trap():
	for j in level_matrix[0].size(): level_matrix[0][j] = TILE.FLOOR_T_B3
	for i in level_matrix.size(): 
		level_matrix[i][0] = TILE.FLOOR_T_B1
		level_matrix[i][level_matrix[0].size() - 1] = TILE.FLOOR_T_B2
		
func construct_boxes_into_matrix():
	var level_autogen = LevelAutogen.new()
	var points = level_autogen.generate_tiles(w_tile_count, h_tile_count, NO_OF_BOXES)
	for point in points:
		level_matrix[point.y][point.x] = TILE.BOX_T

func construct_boxes_tiles(box_scene: PackedScene):
	for h in h_tile_count:
		for w in w_tile_count:
			if level_matrix[h][w] == TILE.BOX_T:
				var box_tile = box_scene.instantiate()
				box_tile.position = Vector2(w, h) * TILE_SIZE
				box_tile.position += half_tile_offset
				add_child(box_tile)

func construct_enemies(enemy_scene: PackedScene):
	active_enemies = enemy_ai.init_enemy_bots(NO_OF_ENEMIES, level_matrix)
	for enemy in active_enemies:
		add_child(enemy)

func handle_input(v: Vector2):
	if Input.is_action_just_pressed("space"):
		var bullet = bullet_scene.instantiate()
		
		add_child(bullet)
		player.construct_bullet(bullet)
		bullet.show()
		
		active_bullets.append(bullet)

func handle_bullets():
	for bullet in active_bullets:
		if bullet.is_erased():
			active_bullets.erase(bullet)
			remove_child(bullet)

func handle_enemies():
	for enemy in active_enemies:
		enemy_ai.handle_bot(enemy, player.position)
		
		if enemy.is_bullet_ready():
			var bullet = bullet_scene.instantiate()
			add_child(bullet)
			enemy.construct_bullet(bullet)
			bullet.show()
			active_bullets.append(bullet)

func handle_player():
	game_over = player.is_killed()

func init_level_matrix():
	for h in h_tile_count:
		level_matrix.append([])
		level_matrix[h] = []
		
		for w in w_tile_count:
			level_matrix[h].append([])
			level_matrix[h][w] = TILE.FLOOR_T # lay all the basic floor blocks
	
	# lay the left/right/up/bottom tiles
	for i in level_matrix.size():
		level_matrix[i][0] = TILE.FLOOR_T_B1
		level_matrix[i][level_matrix[0].size() - 1] = TILE.FLOOR_T_B2
	
	for j in level_matrix[0].size():
		level_matrix[0][j] = TILE.FLOOR_T_B3
		level_matrix[level_matrix.size() - 1][j] = TILE.FLOOR_T_B4
	
	# lay the entry/exit tiles
	level_matrix[int(h_tile_count / 2)][0] 		= TILE.FLOOR_T
	level_matrix[int(h_tile_count / 2)][level_matrix[0].size() - 1] 	= TILE.FLOOR_T
	
	entry_point_left  = Vector2(0, int(h_tile_count / 2))
	entry_point_right = Vector2(level_matrix[0].size() - 1, int(h_tile_count / 2))
	
	# lay the border / corner tiles
	level_matrix[0][0] 							= TILE.FLOOR_T_BC1
	level_matrix[0][level_matrix[0].size() - 1] = TILE.FLOOR_T_BC2
	level_matrix[level_matrix.size() - 1][0] 	= TILE.FLOOR_T_BC4
	level_matrix[level_matrix.size() - 1][level_matrix[0].size() - 1] = TILE.FLOOR_T_BC3

func is_player_at_left_entry():
	return player.position.distance_to(entry_point_left * TILE_SIZE + half_tile_offset) <= PROX_ZONE

func is_player_at_right_entry():
	return player.position.distance_to(entry_point_right * TILE_SIZE + half_tile_offset) <= PROX_ZONE

func get_starting_position(left: bool):
	if left: return entry_point_left * TILE_SIZE
	else:	 return entry_point_right * TILE_SIZE

func tick():
	if game_over: return
	
	var v = player.velocity 
	handle_input(v)
	handle_bullets()
	handle_enemies()
	handle_player()

func _ready():
	half_tile_offset 		= Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
	enemy_ai 				= EnemyAI.new()
	bullet_scene 			= preload("res://scenes/bullet.tscn")
	SCREEN_SIZE 			= get_viewport_rect().size
	w_tile_count 			= SCREEN_SIZE.x / TILE_SIZE
	h_tile_count			= SCREEN_SIZE.y / TILE_SIZE
	
	enemy_ai.set_screen_size(SCREEN_SIZE)
	
	var box_scene: 		PackedScene = preload("res://scenes/box.tscn")
	var enemy_scene:	PackedScene = preload("res://scenes/enemy.tscn")
	
	init_level_matrix()
	construct_floor_tiles()
	construct_boxes_into_matrix()
	fix_possible_player_trap() # fix the case that the level is split from the random boxes
	construct_boxes_tiles(box_scene)
	construct_enemies(enemy_scene)
