extends Node2D

var NO_OF_ENEMIES: 		int = 5
var NO_OF_BOXES: 		int = 5
var SCREEN_SIZE: 		Vector2
var TILE_SIZE:			int = 16
var active_enemies: 	Array
var active_bullets: 	Array
var bullet_scene:		PackedScene
var w_tile_count:		int
var h_tile_count:		int
var game_over:			bool = false
var level_matrix:		Array # 2d level description array
var half_tile_offset	= Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
var enemy_ai

func construct_floor_tiles(floor_scene: PackedScene):
	for i in level_matrix.size():
		for j in level_matrix[0].size():
			var floor_tile = floor_scene.instantiate()
			floor_tile.position = Vector2(j, i) * TILE_SIZE
			floor_tile.position += half_tile_offset
			add_child(floor_tile)
			
func construct_boxes_into_matrix():
	var level_autogen = LevelAutogen.new()
	var points = level_autogen.generate_tiles(w_tile_count, h_tile_count, 10)
	for point in points:
		level_matrix[point.y][point.x] = 1

func construct_boxes_tiles(box_scene: PackedScene):
	for h in h_tile_count:
		for w in w_tile_count:
			if level_matrix[h][w] == 1:
				var box_tile = box_scene.instantiate()
				box_tile.position = Vector2(w, h) * TILE_SIZE
				box_tile.position += half_tile_offset
				add_child(box_tile)
					
func construct_enemies(enemy_scene: PackedScene):
	for i in NO_OF_ENEMIES:
		var enemy: CharacterBody2D = enemy_scene.instantiate()
		
		add_child(enemy)
		enemy.position = Vector2((randi() % int(SCREEN_SIZE.x) + 10) + 10, (randi() % int(SCREEN_SIZE.y) + 10) + 10)
		active_enemies.append(enemy)
		enemy.speed = 30
		
		
func handle_input(v: Vector2):
	if Input.is_action_just_pressed("space"):
		var bullet = bullet_scene.instantiate()
		
		add_child(bullet)
		$player.construct_bullet(bullet)
		bullet.show()
		
		active_bullets.append(bullet)
		
func handle_bullets():
	for bullet in active_bullets:
		if bullet.is_erased():
			active_bullets.erase(bullet)
			remove_child(bullet)
	
func handle_enemies():
	for enemy in active_enemies:
		if enemy.is_killed():
			enemy.position = Vector2(500, 500)
			enemy.hide()
			active_enemies.erase(enemy)
		elif enemy.is_bullet_ready():
			var bullet = bullet_scene.instantiate()
			
			add_child(bullet)
			enemy.construct_bullet(bullet)
			bullet.show()
			
			active_bullets.append(bullet)

func handle_player():
	if $player.is_killed():
		remove_child($player)
		game_over = true

func construct_astar_configuration():
	for h in h_tile_count:
		for w in w_tile_count:
			pass

func init_level_matrix():
	for h in h_tile_count:
		level_matrix.append([])
		level_matrix[h] = []
		
		for w in w_tile_count:
			level_matrix[h].append([])
			level_matrix[h][w] = 0

func _process(delta):
	if game_over: return
	
	var v = $player.velocity 
	handle_input(v)
	handle_bullets()
	handle_enemies()
	handle_player()

func _ready():
	half_tile_offset = Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
	enemy_ai 		= EnemyAI.new()
	bullet_scene 	= preload("res://scenes/bullet.tscn")
	SCREEN_SIZE 	= get_viewport_rect().size
	w_tile_count 	= SCREEN_SIZE.x / TILE_SIZE
	h_tile_count	= SCREEN_SIZE.y / TILE_SIZE
	
	var box_scene: 		PackedScene = preload("res://scenes/box.tscn")
	var floor_scene: 	PackedScene = preload("res://scenes/floor_tile.tscn")
	var enemy_scene:	PackedScene = preload("res://scenes/enemy.tscn")
	
	init_level_matrix()
	construct_floor_tiles(floor_scene)
	construct_boxes_into_matrix()
	construct_boxes_tiles(box_scene)
	construct_enemies(enemy_scene)
	construct_astar_configuration()
