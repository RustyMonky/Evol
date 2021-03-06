extends Node

var player = {
	battle_sprite = "res://assets/sprites/forms/backs/baseFormBack.png",
	current_hp = 15,
	elemental_type = null,
	form = null,
	items = [],
	level = 1,
	max_hp = 15,
	moves = [
		{
			name = "Rush",
			damage = 1,
			desc = "Charge at an enemy for 1 base damage.",
			elementalType = null
		}
	],
	moves_known = [],
	pos = Vector2(1, 1),
	stats = {
		defense = 5,
		speed = 5,
		strength = 5
	},
	stats_sprite = "res://assets/sprites/forms/sheets-48x48/baseSheet.png",
	sprite_frame = Rect2(0, 0, 48, 48),
	sprite_path = "res://assets/sprites/forms/sheets-48x48/baseSheet.png",
	total_mobs_killed = 0,
	xp = 0
}

var items_data
var mob_data
var moves_data

var xp_required_array = []

func _ready():
	# Populate xp array
	for n in range(1, 101):
		var xp_req = (n * 10) * n
		xp_required_array.append(xp_req)

	# Retrieve all mob data
	var mob_file = File.new()
	mob_file.open("res://data/mobs.json", File.READ)
	var mob_file_text = mob_file.get_as_text()
	mob_data = parse_json(mob_file_text)
	mob_file.close()

	# Retrieve all move data
	var moves_file = File.new()
	moves_file.open("res://data/moves.json", File.READ)
	var moves_file_text = moves_file.get_as_text()
	moves_data = parse_json(moves_file_text)
	moves_file.close()

	for move in self.player.moves:
		self.player.moves_known.append(move.name)

	# Retrieve all item data
	var items_file = File.new()
	items_file.open("res://data/items.json", File.READ)
	var items_file_text = items_file.get_as_text()
	items_data = parse_json(items_file_text)
	items_file.close()

# Globally accessible function to generate a new random number
func get_random_number(limit):
	randomize()

	if (randi() % int(limit)) == 0:
		return 1

	return (randi() % int(limit))

# level_up
# Increases base stats -- roguelike choice-making in separate scene
func level_up():
	player.level += 1
	player.current_hp += 2
	player.max_hp += 2
	player.stats.defense += 1
	player.stats.speed += 1
	player.stats.strength += 1

func start_new_game():
	player = {
		battle_sprite = "res://assets/sprites/forms/backs/baseFormBack.png",
		current_hp = 15,
		elemental_type = null,
		form = null,
		items = [],
		level = 1,
		max_hp = 15,
		moves = [
			{ name = 'Rush', damage = 3, desc = "Charge at an enemy" }
		],
		moves_known = ["Rush"],
		pos = Vector2(1, 1),
		stats = {
			defense = 5,
			speed = 5,
			strength = 5
		},
		stats_sprite = "res://assets/sprites/forms/sheets-48x48/baseSheet.png",
		sprite_frame = Rect2(0, 0, 48, 48),
		sprite_path = "res://assets/sprites/forms/sheets-48x48/baseSheet.png",
		total_mobs_killed = 0,
		xp = 0
	}
