extends Control

var moves_list
var player
var stat_values

func _ready():
    moves_list = get_node("KnownMoves").get_children()

    stat_values = get_node("StatValues")

    stat_values.get_node("HpValue").set_text(String(global.player.current_hp) + "/" + String(global.player.max_hp))
    stat_values.get_node("DefenseValue").set_text(String(round(global.player.stats.defense)))
    stat_values.get_node("SpeedValue").set_text(String(round(global.player.stats.speed)))
    stat_values.get_node("StrengthValue").set_text(String(round(global.player.stats.strength)))
    stat_values.get_node("XpValue").set_text(String(round(global.player.xp)))

    for move in global.player.moves:
        var index = global.player.moves.find(move)
        moves_list[index].set_text("-- " + move.name)

    set_process_input(true)

func _input(event):
    if event.is_action_pressed("ui_cancel"):
        get_node("/root/global").goto_scene("res://Grid/Grid.tscn")
