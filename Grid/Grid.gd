extends TileMap

var tile_size = get_cell_size()
var half_tile_size = tile_size / 2

# Modify grid size below for testing purposes
# THESE ARE CONSTANTLY CHANGING BASED ON TILEMAP EDITS
var grid_size = Vector2(10, 5)
var grid = []

enum ENTITY_TYPES {PLAYER, ENCOUNTER}

func _ready():
	# Create grid array
	for x in range(grid_size.x):
		grid.append([])

		for y in range(grid_size.y):
			grid[x].append(null)

	var encounter_positions = []

	for n in range(int(grid_size.x / 3)):
		randomize()
		var grid_pos = Vector2(randi() % int(grid_size.x), randi() % int(grid_size.y))

		if not grid_pos in encounter_positions:
			encounter_positions.append(grid_pos)

	for pos in encounter_positions:
		grid[pos.x][pos.y] = ENCOUNTER

	# Finally, add an instance of the player
	var player_instance = load("res://player/player.tscn").instance()
	add_child(player_instance)
	player_instance.position = map_to_world(gameData.player.pos)

	print(encounter_positions)

# ---------------
# Class Functions
# ---------------

# is_cell_vacant
# Determines if the cell the player is moving to is vacant in the grid
func is_cell_vacant(pos, direction):
	var grid_pos = world_to_map(pos) + direction

	if grid_pos.x < grid_size.x and grid_size.x >= 0 and grid_pos.x > 0:

		if abs(grid_pos.y) < grid_size.y and grid_pos.y >= 0:

			if grid[grid_pos.x][grid_pos.y] == null:
				gameData.player.pos = Vector2(grid_pos.x, grid_pos.y)
				return true

			elif grid[grid_pos.x][grid_pos.y] == ENCOUNTER:
				# Remove the encounter from the grid position to allow movement after the encounter
				grid[grid_pos.x][grid_pos.y] = null
				gameData.player.pos = Vector2(grid_pos.x, grid_pos.y)
				sceneManager.goto_scene("res://battle/battle.tscn")

	return false

# update_child_pos
# Updates the player's position on the grid
func update_child_pos(child_node):
	# Move a child to a new position in the grid Array
	# Returns the new target world position of the child
	var grid_pos = world_to_map(child_node.position)
	grid[grid_pos.x][grid_pos.y] = null

	var new_grid_pos = grid_pos + child_node.direction
	grid[new_grid_pos.x][new_grid_pos.y] = child_node.type

	var target_pos = map_to_world(new_grid_pos) + half_tile_size
	print("New position is " + String(world_to_map(target_pos)))

	return target_pos
