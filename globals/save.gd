extends Node

const SAVE_PATH = "res://save.json"

func _ready():
	load_game()

func save_game():

	var save_dictionary = {
		player = {
			battle_sprite = gameData.player.battle_sprite,
			current_hp = gameData.player.current_hp,
			level = gameData.player.level,
			max_hp = gameData.player.max_hp,
			moves = gameData.player.moves,
			pos = {
				x = gameData.player.pos.x,
				y = gameData.player.pos.y
			},
			sprite_path = gameData.player.sprite_path,
			sprite_frame = gameData.player.sprite_frame,
			stats = gameData.player.stats,
			stats_sprite = gameData.player.stats_sprite,
			total_mobs_killed = gameData.player.total_mobs_killed,
			xp = gameData.player.xp

		}
	}

	var save_file = File.new()
	save_file.open(SAVE_PATH, File.WRITE)
	save_file.store_line(save_dictionary.to_json())
	save_file.close()

	gameData.game_state.is_saving = false

func load_game():
	var save_file = File.new()
	var data

	if not save_file.file_exists(SAVE_PATH):
		return

	save_file.open(SAVE_PATH, File.READ)
	data = parse_json(save_file.get_as_text())

	gameData.player.battle_sprite = data["player"]["battle_sprite"]
	gameData.player.current_hp = data["player"]["current_hp"]
	gameData.player.level = data["player"]["level"]
	gameData.player.max_hp = data["player"]["max_hp"]
	gameData.player.moves = data["player"]["moves"]
	gameData.player.pos = Vector2(data["player"]["pos"]["x"], data["player"]["pos"]["y"])
	gameData.player.sprite_path = data["player"]["sprite_path"]
	gameData.player.sprite_frame = data["player"]["sprite_frame"]
	gameData.player.stats = data["player"]["stats"]
	gameData.player.stats_sprite = data["player"]["stats_sprite"]
	gameData.player.total_mobs_killed = data["player"]["total_mobs_killed"]
	gameData.player.xp = data["player"]["xp"]
