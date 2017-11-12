extends Control

var current_hp
var hp_bar
var level_label
var max_hp
var name_label
var type

func _ready():
    name_label = get_node("NameLabel")
    level_label = get_node("LevelLabel")
    hp_bar = get_node("HpBar")

    if type == "mob":
        name_label.set_text(global.mob.name)
        level_label.set_text("Lvl. " + String(global.mob.level))
    elif type == "player":
        name_label.set_text("Evol")
        level_label.set_text("Lvl. " + String(global.player.level))

    hp_bar.set_max(max_hp)
    hp_bar.set_value(current_hp)

    # Hide upon encounter initialization
    # This will be changed once the mob sprite is in place
    name_label.set_hidden(true)
    level_label.set_hidden(true)
    hp_bar.set_hidden(true)

    set_fixed_process(true)

func _fixed_process(delta):

    hp_bar.set_value(current_hp)

    if current_hp > (max_hp / 4) && current_hp <= (max_hp / 2):
        hp_bar.set_progress_texture(load("res://Battle/hpMid.tex"))
    elif current_hp <= (max_hp / 4):
        hp_bar.set_progress_texture(load("res://Battle/hpLow.tex"))
