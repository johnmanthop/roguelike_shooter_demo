extends CharacterBody2D

const TILE_SIZE:		int = 16
var health:				int = 5
var bullet_scene:		PackedScene
var speed: 				int
var SCREEN_SIZE: 		Vector2
var direction: 	 		int
var walk_time:	 		int
var walk_duration: 		int
var bullet_time:		int
var bullet_duration:	int
var killed:				bool
var my_bullets:			int

func is_killed() -> bool:
	return killed

func move_up():
	$AnimatedSprite2D.animation = "walk-up"
	self.velocity = Vector2(0, -1) * speed;
	move_and_slide()
	
func move_down():
	$AnimatedSprite2D.animation = "walk-down"
	self.velocity = Vector2(0, 1) * speed;
	move_and_slide()
	
func move_left():
	$AnimatedSprite2D.animation = "walk-left"
	self.velocity = Vector2(-1, 0) * speed;
	move_and_slide()
	
func move_right():
	$AnimatedSprite2D.animation = "walk-right"
	self.velocity = Vector2(1, 0) * speed;
	move_and_slide()

func move_to_path():
	if direction == 0: move_up()
	elif direction == 1: move_down()
	elif direction == 2: move_left()
	else:				move_right()

func hit_with_bullet(bullet: Sprite2D):
	if bullet.source == "player":
		$HitSound.play()
		health -= 1
		if health == 0:
			killed = true

func is_bullet_ready():
	return bullet_time == bullet_duration
	
func construct_bullet(bullet: Sprite2D):
	bullet.position = position
	bullet.source = "enemy"
	bullet.speed = 0.7
	bullet.max_distance = 120
	
	if direction == 0:
		bullet.direction = Vector2(0, -1)
		bullet.rotate(PI/2)
	elif direction == 1:
		bullet.direction = Vector2(0, 1)
		bullet.rotate(PI/2)
	elif direction == 2:
		bullet.direction = Vector2(-1, 0)
	else:
		bullet.direction = Vector2(1, 0)
		
	bullet.position += bullet.direction * 15
	
func _process(delta):
	if killed: return
	
	$AnimatedSprite2D.speed_scale = 1.5
	$AnimatedSprite2D.play()
	
	if bullet_time == bullet_duration + 1:
		bullet_time = 0
	else:
		bullet_time += 1
	
	if walk_time == walk_duration:
		walk_time = 0
		direction = randi() % 4
	else:
		walk_time += 1
		move_to_path()
		position = position.clamp(Vector2.ZERO, SCREEN_SIZE - Vector2(2*TILE_SIZE, 2*TILE_SIZE))

func _ready():
	SCREEN_SIZE 	= get_viewport_rect().size
	direction 		= randi() % 4
	killed 			= false
	speed			= 50
	walk_time		= 0
	walk_duration 	= 60
	bullet_time		= 0
	bullet_duration = 60
	my_bullets		= 0
	bullet_scene	= preload("res://scenes/bullet.tscn")
