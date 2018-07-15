extends Node

var item_used = null

var mob = {
	current_hp = 10,
	stats = {},
	statsChanged = {
		defense = 0,
		speed = 0,
		strength = 0
	}
}

var player

func _ready():
	player = {
		current_hp = gameData.player.current_hp,
		moves = gameData.player.moves,
		stats = gameData.player.stats,
		statsChanged = {
			defense = 0,
			speed = 0,
			strength = 0
		}
	}