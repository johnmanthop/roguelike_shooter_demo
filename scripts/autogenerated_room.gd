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
	BOX_T,
	ENTRANCE_T
}

const PROX:				float = 12
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
var entry_point:		Vector2
var has_left_entry:		bool

func set_player_pointer(p):
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
			elif level_matrix[i][j] == TILE.ENTRANCE_T:
				floor_tile.texture = load("res://game_assets/tiles/entrance_tile.png")
			
			floor_tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			floor_tile.position = Vector2(j, i) * TILE_SIZE
			floor_tile.position += half_tile_offset
			add_child(floor_tile)

func fix_possible_player_trap():
	for j in level_matrix[0].size(): 
		level_matrix[0][j] = TILE.FLOOR_T_B3
	for i in level_matrix.size(): 
		level_matrix[i][0] = TILE.FLOOR_T_B1
		level_matrix[i][level_matrix[0].size() - 1] = TILE.FLOOR_T_B2
		
func construct_boxes_into_matrix():
	var level_autogen = LevelAutogen.new()
	var points = level_autogen.generate_tiles(w_tile_count, h_tile_count, NO_OF_BOXES)
	for point in points:
		if level_matrix[point.y][point.x] != TILE.ENTRANCE_T:
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
	player.position = player.position.clamp(Vector2(TILE_SIZE / 2, TILE_SIZE / 2), SCREEN_SIZE - Vector2(TILE_SIZE / 2, TILE_SIZE / 2))
	if player.position.distance_to(entry_point * TILE_SIZE + half_tile_offset) > PROX + 2:
		has_left_entry = true
		
func init_level_matrix():
	for h in h_tile_count:
		level_matrix.append([])
		level_matrix[h] = []
		
		for w in w_tile_count:
			level_matrix[h].append([])
			level_matrix[h][w] = TILE.FLOOR_T # lay all the basic floor blocks
	
	# lay the entrance tile
	entry_point = Vector2(level_matrix[0].size() / 2, level_matrix.size() / 2)
	level_matrix[entry_point.y][entry_point.x] = TILE.ENTRANCE_T
	for i in entry_point.x:
		level_matrix[entry_point.y][i] = TILE.FLOOR_T
	# lay the left/right/up/bottom tiles
	for i in level_matrix.size():
		level_matrix[i][0] = TILE.FLOOR_T_B1
		level_matrix[i][level_matrix[0].size() - 1] = TILE.FLOOR_T_B2
	
	for j in level_matrix[0].size():
		level_matrix[0][j] = TILE.FLOOR_T_B3
		level_matrix[level_matrix.size() - 1][j] = TILE.FLOOR_T_B4
		
	# lay the border / corner tiles
	level_matrix[0][0] 							= TILE.FLOOR_T_BC1
	level_matrix[0][level_matrix[0].size() - 1] = TILE.FLOOR_T_BC2
	level_matrix[level_matrix.size() - 1][0] 	= TILE.FLOOR_T_BC4
	level_matrix[level_matrix.size() - 1][level_matrix[0].size() - 1] = TILE.FLOOR_T_BC3

func handle_camera():
	$Camera.position = player.position
	
func init_camera():
	$Camera.make_current()
	$Camera.set_limit(SIDE_LEFT, 0)
	$Camera.set_limit(SIDE_TOP, 0)
	$Camera.set_limit(SIDE_RIGHT, w_tile_count * TILE_SIZE)
	$Camera.set_limit(SIDE_BOTTOM, h_tile_count * TILE_SIZE)

func get_camera_position():
	return $Camera.get_screen_center_position()

func get_starting_position():
	return entry_point * TILE_SIZE + half_tile_offset

func get_activated_entrance():
	if has_left_entry and player.position.distance_to(entry_point * TILE_SIZE + half_tile_offset) <= PROX:
		return [true, "free_roam_level"]
	else:
		return [false]

func reset():
	has_left_entry = false

func _process(delta):
	if game_over: return
	
	var v = player.velocity 
	handle_input(v)
	handle_bullets()
	handle_enemies()
	handle_player()
	handle_camera()

func _ready():
	half_tile_offset 		= Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
	enemy_ai 				= EnemyAI.new()
	bullet_scene 			= preload("res://scenes/bullet.tscn")
	SCREEN_SIZE 			= get_viewport_rect().size
	w_tile_count 			= SCREEN_SIZE.x / TILE_SIZE
	h_tile_count			= SCREEN_SIZE.y / TILE_SIZE
	has_left_entry			= false
	enemy_ai.set_screen_size(SCREEN_SIZE)
	
	var box_scene: 		PackedScene = preload("res://scenes/box.tscn")
	var enemy_scene:	PackedScene = preload("res://scenes/enemy.tscn")
	
	init_level_matrix()
	construct_floor_tiles()
	construct_boxes_into_matrix()
	fix_possible_player_trap() # fix the case that the level is split from the random boxes
	construct_boxes_tiles(box_scene)
	construct_enemies(enemy_scene)
	init_camera()
