extends CharacterBody2D

const TILE_SIZE:	int = 16	
var speed: 			int = 75
var SCREEN_SIZE: 	Vector2
const MAX_HEALTH:	int = 60
var health:			int = MAX_HEALTH
var killed:			bool = false

func is_killed():
	return killed

func calculate_normalized_velocity() -> Vector2:
	var v: Vector2 = Vector2.ZERO
	
	if Input.is_action_pressed("A"): v.x = -1
	if Input.is_action_pressed("D"): v.x = 1
	if Input.is_action_pressed("W"): v.y = -1
	if Input.is_action_pressed("S"): v.y = 1
	
	return v.normalized()

func handle_animations(v: Vector2):
	if v.length() != 0: 
		$AnimatedSprite2D.play()
		if v.x > 0: 	$AnimatedSprite2D.animation = "walk-right"
		elif v.x < 0:	$AnimatedSprite2D.animation = "walk-left"
		elif v.y > 0: 	$AnimatedSprite2D.animation = "walk-down"
		elif v.y < 0:	$AnimatedSprite2D.animation = "walk-up"
	else:	
		$AnimatedSprite2D.stop()

func construct_bullet(bullet: Sprite2D):
	$GunSound.play()
	bullet.position = position
	bullet.source = "player"
	bullet.max_distance = 70
	
	if $AnimatedSprite2D.animation == "walk-right":
		bullet.direction = Vector2(1, 0)
	elif $AnimatedSprite2D.animation == "walk-left":
		bullet.direction = Vector2(-1, 0)
	elif $AnimatedSprite2D.animation == "walk-down":
		bullet.direction = Vector2(0, 1)
		bullet.rotate(PI/2)
	elif $AnimatedSprite2D.animation == "walk-up":
		bullet.direction = Vector2(0, -1)
		bullet.rotate(PI/2)
		
	# add a 10*direction vector so the first time the bullet is not inside the player
	bullet.position += bullet.direction * 10

func _ready():
	SCREEN_SIZE = get_viewport_rect().size
	$AnimatedSprite2D.speed_scale = 1.5
	
func _process(delta):
	if health <= 0:
		killed = true
	
	self.velocity = calculate_normalized_velocity() * speed
	
	handle_animations(velocity)
	move_and_slide()
	position = position.clamp(Vector2(TILE_SIZE / 2, TILE_SIZE / 2), SCREEN_SIZE - Vector2(TILE_SIZE / 2, TILE_SIZE / 2))
	
func hit_with_bullet(bullet: Sprite2D):
	if bullet.source == "enemy":
		$HitSound.play()
		health -= 10
		print(health)
		
