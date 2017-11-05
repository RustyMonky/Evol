extends TileMap

var tile_size = get_cell_size()
var half_tile_size = tile_size / 2

# Modify grid size below for testing purposes
# THESE ARE CONSTANTLY CHANGING BASED ON TILEMAP EDITS
var grid_size = Vector2(7, 5)
var grid = []

onready var Encounter = preload("res://Test/TestEncounter.tscn")

enum ENTITY_TYPES {PLAYER, ENCOUNTER}

func _ready():
    # Create grid array
    for x in range(grid_size.x):
        grid.append([])
        for y in range(grid_size.y):
            grid[x].append(null)

    var Player = get_node("Player")
    Player.set_pos(global.player_pos)
    Player.get_node("PlayerSprite").set_frame(global.player_sprite_frame)

    var encounter_positions = []

    for n in range(5):
        var grid_pos = Vector2(randi() % int(grid_size.x), randi() % int(grid_size.y))
        if not grid_pos in encounter_positions:
            encounter_positions.append(grid_pos)

    for pos in encounter_positions:
        var new_encounter = Encounter.instance()
        new_encounter.set_pos(map_to_world(pos) + half_tile_size)
        grid[pos.x][pos.y] = ENCOUNTER
        add_child(new_encounter)

func is_cell_vacant(pos, direction):
    var grid_pos = world_to_map(pos) + direction

    if grid_pos.x < grid_size.x and grid_size.x >= 0 and grid_pos.x > 0:
        if abs(grid_pos.y) < grid_size.y and grid_size.y >= 0:
            if grid[grid_pos.x][grid_pos.y] == null:
                return true
            elif grid[grid_pos.x][grid_pos.y] == ENCOUNTER:
                # Remove the encounter from the grid position to allow movement after the encounter
                grid[grid_pos.x][grid_pos.y] = null
                get_node("/root/global").goto_scene("res://Battle/Battle.tscn")
                return false
    return false

func update_child_pos(child_node):
    # Move a child to a new position in the grid Array
    # Returns the new target world position of the child
    var grid_pos = world_to_map(child_node.get_pos())
    grid[grid_pos.x][grid_pos.y] = null

    var new_grid_pos = grid_pos + child_node.direction
    grid[new_grid_pos.x][new_grid_pos.y] = child_node.type

    var target_pos = map_to_world(new_grid_pos) + half_tile_size
    return target_pos
