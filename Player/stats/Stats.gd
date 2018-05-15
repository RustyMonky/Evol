extends Control

var moves_list
var player_sprite

func _ready():
	$lvlLabel.set_text("Lvl. " + String(gameData.player.level))

	moves_list = $movesContainer/knownMoves.get_children()

	$statsContainer/statHBox/values/hp.set_text(String(gameData.player.current_hp) + "/" + String(gameData.player.max_hp))
	$statsContainer/statHBox/values/defense.set_text(String(gameData.player.stats.defense))
	$statsContainer/statHBox/values/speed.set_text(String(gameData.player.stats.speed))
	$statsContainer/statHBox/values/strength.set_text(String(gameData.player.stats.strength))
	$statsContainer/statHBox/values/xp.set_text(String(gameData.player.xp))

	for move in gameData.player.moves:
	    var index = gameData.player.moves.find(move)
	    moves_list[index].set_text("-- " + move.name + ": " + move.desc)

	player_sprite = load(gameData.player.stats_sprite)
	$playerSprite.set_texture(player_sprite)
	$playerSprite.set_region_rect(Rect2(0, 0, 32, 32))

	set_process_input(true)

func _input(event):
    if event.is_action_pressed("ui_cancel"):
        sceneManager.goto_scene("res://Grid/Grid.tscn")
