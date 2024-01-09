extends Node2D

var NO_OF_ENEMIES: 	int = 5
var NO_OF_BOXES: 	int = 5
var SCREEN_SIZE: 	Vector2
var TILE_SIZE:		int = 16
var filled_positions: 	Array
var active_enemies: 	Array
var active_bullets: 	Array
var bullet_scene:		PackedScene
var w_tile_count:		int
var h_tile_count:		int
var game_over:			bool = false

func construct_floor(floor_scene: PackedScene):
	for w in  w_tile_count + 1:
		for h in h_tile_count + 1:
			var floor_tile: Node2D = floor_scene.instantiate()
			floor_tile.position = Vector2(w * TILE_SIZE, h * TILE_SIZE)
			add_child(floor_tile)

func construct_boxes(box_scene: PackedScene):
	var level_autogen = LevelAutogen.new()
	var tiles = level_autogen.generate_tiles(w_tile_count, h_tile_count, 10)
	for t in tiles:
		
		add_child(t)
		
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

func _process(delta):
	if game_over: return
	
	var v = $player.velocity 
	handle_input(v)
	handle_bullets()
	handle_enemies()
	handle_player()

func _ready():
	bullet_scene = preload("res://scenes/bullet.tscn")
	SCREEN_SIZE = get_viewport_rect().size
	w_tile_count = SCREEN_SIZE.x / TILE_SIZE + 1
	h_tile_count = SCREEN_SIZE.y / TILE_SIZE + 1
	
	var box_scene: 		PackedScene = preload("res://scenes/box.tscn")
	var floor_scene: 	PackedScene = preload("res://scenes/floor_tile.tscn")
	var enemy_scene:	PackedScene = preload("res://scenes/enemy.tscn")
	
	construct_floor(floor_scene)
	construct_boxes(box_scene)
	construct_enemies(enemy_scene)
