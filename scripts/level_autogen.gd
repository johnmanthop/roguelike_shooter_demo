class_name LevelAutogen

const TILE_SIZE: int = 16
var box_scene = preload("res://scenes/box.tscn")

var preset_tilesets = [
	[Vector2(0, 0), Vector2(0, 1), Vector2(1, 1)],
	[Vector2(0, 0), Vector2(0, 1), Vector2(-1, 1)],
	[Vector2(0, 0), Vector2(0, 1), Vector2(0, 2)],
	[Vector2(0, 0), Vector2(1, 0), Vector2(2, 0)],
]

func random_tile_construction() -> Array:
	var construct: Array	
	var random_tileset = preset_tilesets[randi() % preset_tilesets.size()]
	
	for position in random_tileset:
		construct.append(box_scene.instantiate())
		construct.back().position = position * TILE_SIZE
	
	return construct

func translate_construct(construct: Array, w_tile_count: int, h_tile_count: int):
	var root_position = Vector2(randi() % (w_tile_count - 1) + 1, randi() % (h_tile_count - 1) + 1) * TILE_SIZE

	for box in construct:
		box.position += root_position

func generate_tiles(w_tile_count, h_tile_count, count) -> Array:
	var tiles: Array
	
	for i in count:
		var construct = random_tile_construction()
		translate_construct(construct, w_tile_count, h_tile_count)
		tiles += construct	
	return tiles 
