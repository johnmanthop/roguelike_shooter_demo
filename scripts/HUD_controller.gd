extends Node2D

var   SCREEN_SIZE:			Vector2
const HEALTH_BLOCKS: 		int = 14
const HEALTH_BLOCK_WIDTH: 	int = 2
var health_blocks:			Array

func init_bar_container():
	$HealthBarContainer.position = Vector2(SCREEN_SIZE.x / 2, 3)

func init_bar_blocks():
	var x_offset: int = 0
	for i in HEALTH_BLOCKS:
		var health_block 		= Sprite2D.new()
		health_block.z_index 	= 3
		health_block.texture 	= load("res://game_assets/hud/hud_life_block.png")
		health_block.position 	= Vector2($HealthBarContainer.position.x + x_offset - 13, 3)
		add_child(health_block)
		health_blocks.append(health_block)
		x_offset += HEALTH_BLOCK_WIDTH

func init_health_bar():
	init_bar_container()
	init_bar_blocks()

func set_visible_blocks(n: int):
	for health_block in health_blocks: health_block.hide()
	for i in n:
		health_blocks[i].show()

func _ready():
	SCREEN_SIZE = get_viewport_rect().size
	init_health_bar()
