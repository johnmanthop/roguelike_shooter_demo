extends CharacterBody2D

const TILE_SIZE:		int = 16
var SCREEN_SIZE: 		Vector2
var health:				int = 5
var speed: int			= 50
var bullet_scene:		PackedScene

var walk_timer:	 		int
var bullet_timer:		int
var killed:				bool
var navigation_setting:	String
var bullet_ready:		bool

func is_killed() -> bool:
	return killed

func animate_up():
	$AnimatedSprite2D.animation = "walk-up"
	
func animate_down():
	$AnimatedSprite2D.animation = "walk-down"
	
func animate_left():
	$AnimatedSprite2D.animation = "walk-left"
	
func animate_right():
	$AnimatedSprite2D.animation = "walk-right"

func hit_with_bullet(bullet: Sprite2D):
	if bullet.source == "player":
		$HitSound.play()
		health -= 1
		if health == 0:
			killed = true

func is_bullet_ready():
	return bullet_ready

func set_ready_to_shoot():
	bullet_ready = true

func construct_bullet(bullet: Sprite2D):
	bullet_ready = false
	bullet_timer = 0
	
	bullet.position = position
	bullet.source = "enemy"
	bullet.speed = 0.7
	bullet.max_distance = 120
	
	if $AnimatedSprite2D.animation == "walk-right":
		bullet.direction = Vector2(1, 0)
	elif $AnimatedSprite2D.animation == "walk-left":
		bullet.direction = Vector2(-1, 0)
	elif $AnimatedSprite2D.animation == "walk-up":
		bullet.direction = Vector2(0, -1)
		bullet.rotate(PI/2)
	else:
		bullet.direction = Vector2(0, 1)
		bullet.rotate(PI/2)
	
	bullet.position += bullet.direction * 15

func animate_to_direction(d: Vector2):
	# dominant axis is x
	if abs(d.x) > abs(d.y):
		if d.x > 0: animate_right()
		else:		animate_left()
	else:
		if d.y > 0: animate_down()
		else:		animate_up()

func _process(delta):
	if killed: return
	
	$AnimatedSprite2D.speed_scale = 1.5
	$AnimatedSprite2D.play()
	
	position = position.clamp(Vector2(TILE_SIZE / 2, TILE_SIZE / 2), SCREEN_SIZE - Vector2(2*TILE_SIZE, 2*TILE_SIZE))

func _ready():
	navigation_setting	= "random"
	SCREEN_SIZE 	  	= get_viewport_rect().size
	killed 				= false
	walk_timer			= 0
	bullet_timer		= 0
	bullet_scene		= preload("res://scenes/bullet.tscn")
