class_name EnemyAI extends Node

const TILE_SIZE:				int = 16
var SCREEN_SIZE:				Vector2
var walk_duration:				int			= 60
var interval_between_bullets: 	int 		= 120
var enemy_scene:				PackedScene = preload("res://scenes/enemy.tscn")

func distance(p1: Vector2, p2: Vector2):
	return sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))

func get_random_direction():
	var d = randi() % 4
	if d == 0: 		return Vector2(0, 1)
	elif d == 1: 	return Vector2(0, -1)
	elif d == 2: 	return Vector2(1, 0)
	else:			return Vector2(-1, 0)

func get_random_position(level_matrix: Array):
	var w_tile_count: int = SCREEN_SIZE.x / TILE_SIZE
	var h_tile_count: int = SCREEN_SIZE.y / TILE_SIZE
	var position = Vector2(randi() % w_tile_count, randi() % h_tile_count)
	while level_matrix[position.y][position.x] != 0:
		position = Vector2(randi() % w_tile_count, randi() % h_tile_count)
	
	return position

func init_enemy_bots(no_of_enemies: int, level_matrix: Array):
	var enemies: Array
	
	for i in no_of_enemies:
		var enemy 		= enemy_scene.instantiate()
		enemy.speed 	= 30
		enemy.velocity  = get_random_direction()
		enemy.position  = get_random_position(level_matrix) * TILE_SIZE
		enemies.append(enemy)
		
	return enemies

func set_navigation_setting(enemy_bot, target_position):
	var distance_to_target = distance(enemy_bot.position, target_position)
	if distance_to_target >= 50:
		enemy_bot.navigation_setting = "random"
	else:
		enemy_bot.navigation_setting = "targeted"    

func move_bot(enemy_bot, target_position):
	if enemy_bot.navigation_setting == "random":
		if enemy_bot.walk_timer == walk_duration:
			var d = get_random_direction()
			enemy_bot.velocity = d * enemy_bot.speed
			enemy_bot.animate_to_direction(d)
			enemy_bot.walk_timer = 0
		else:
			enemy_bot.walk_timer += 1
			enemy_bot.move_and_slide()
	else:
		# see vector algebra to understand this
		var direction_to_target = target_position - enemy_bot.position
		enemy_bot.animate_to_direction(direction_to_target)

func handle_bot_shooting(enemy_bot):
	if enemy_bot.navigation_setting != "targeted": return
	
	if enemy_bot.bullet_timer == interval_between_bullets:
		enemy_bot.set_ready_to_shoot()
	else:
		enemy_bot.bullet_timer += 1
		
func handle_dead_bot(enemy_bot):
	if enemy_bot.is_killed():
		enemy_bot.position = Vector2(500, 500)
		enemy_bot.hide()
		
func handle_bot(enemy_bot, target_position):
	handle_dead_bot(enemy_bot)
	set_navigation_setting(enemy_bot, target_position)
	move_bot(enemy_bot, target_position)
	handle_bot_shooting(enemy_bot)
	
func set_screen_size(s: Vector2):
	SCREEN_SIZE = s

func _ready():
	pass
