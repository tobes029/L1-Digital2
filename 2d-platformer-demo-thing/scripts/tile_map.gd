extends TileMapLayer

# Define grid coordinates and source parameters
# source_id: 0 refers to the first tilesheet added to your TileSet atlas
# atlas_coords: Vector2i(x, y) represents the column and row of the tile in your tilesheet
@export var source_id: int = 0
@export var ground_tile_coords: Vector2i = Vector2i(0, 0)
@export var wall_tile_coords: Vector2i = Vector2i(1, 0)

func _ready() -> void:
	# Clear any existing tiles on load
	clear()
	
	# Generate a simple 5x5 test room programmatically
	generate_sample_room(5, 5)

func generate_sample_room(width: int, height: int) -> void:
	for x in range(width):
		for y in range(height):
			var grid_position = Vector2i(x, y)
			
			# Place walls on the outer border, ground tiles on the interior
			if x == 0 or x == width - 1 or y == 0 or y == height - 1:
				set_cell(grid_position, source_id, wall_tile_coords)
			else:
				set_cell(grid_position, source_id, ground_tile_coords)

func place_single_tile(grid_pos: Vector2i, tile_coords: Vector2i) -> void:
	# Utility function to place a specific tile at runtime
	set_cell(grid_pos, source_id, tile_coords)

func remove_single_tile(grid_pos: Vector2i) -> void:
	# Erase a tile by setting its source_id to -1
	set_cell(grid_pos, -1)
