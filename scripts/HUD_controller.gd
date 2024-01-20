extends Node2D

var   SCREEN_SIZE:			Vector2
const MYSTERY_OFFSET:		float = 19.5
const SCALE:				float = 1.5
const Y_OFFSET:				int = 6
const HEALTH_BLOCKS: 		int = 14
const HEALTH_BLOCK_WIDTH: 	int = 2
var health_blocks:			Array
var health_bar_container

func init_bar_container():
	health_bar_container = Sprite2D.new()
	health_bar_container.texture = load("res://game_assets/hud/hud_life_container.png")
	health_bar_container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	health_bar_container.scale = Vector2(SCALE, SCALE)
	health_bar_container.position = Vector2(SCREEN_SIZE.x / 2, Y_OFFSET)
	health_bar_container.z_index = 3
	add_child(health_bar_container)
	
func init_bar_blocks():
	var x_offset: int = 0
	for i in HEALTH_BLOCKS:
		var health_block 		= Sprite2D.new()
		health_block.scale 		= Vector2(SCALE, SCALE)
		health_block.z_index 	= 3
		health_block.texture 	= load("res://game_assets/hud/hud_life_block.png")
		# no idea why, but mystey offset is needed
		health_block.position 	= Vector2(health_bar_container.position.x + x_offset - MYSTERY_OFFSET, Y_OFFSET)
		add_child(health_block)
		health_blocks.append(health_block)
		x_offset += HEALTH_BLOCK_WIDTH * SCALE

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
