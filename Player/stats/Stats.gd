extends Control

var moves_list
var player_sprite
var sprite
var stat_font

func _ready():
	sprite = $playerSprite
	$lvlLabel.set_text("Lvl. " + String(gameData.player.level))

	moves_list = $movesContainer/knownMoves/movesList

	$statsContainer/statHBox/values/hp.set_text(String(gameData.player.current_hp) + "/" + String(gameData.player.max_hp))
	$statsContainer/statHBox/values/defense.set_text(String(gameData.player.stats.defense))
	$statsContainer/statHBox/values/speed.set_text(String(gameData.player.stats.speed))
	$statsContainer/statHBox/values/strength.set_text(String(gameData.player.stats.strength))
	$statsContainer/statHBox/values/xp.set_text(String(gameData.player.xp))

	stat_font = load("res://assets/fonts/standardFont.tres")

	for move in gameData.player.moves:
		var move_label = Label.new()

		moves_list.add_child(move_label)
		move_label.set_text("-- " + move.name + ": " + move.desc)
		move_label.set_autowrap(true)
		move_label.set("custom_fonts/font", stat_font)

	player_sprite = load(gameData.player.stats_sprite)
	sprite.set_texture(player_sprite)

	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		sceneManager.goto_scene("res://player/pause/pauseMenu.tscn")
