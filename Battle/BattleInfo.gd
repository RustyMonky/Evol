extends Control

var name_label
var level_label
var hp_bar
var current_hp
var max_hp

func _ready():
    name_label = get_node("NameLabel")
    level_label = get_node("LevelLabel")
    hp_bar = get_node("HpBar")

    hp_bar.set_max(max_hp)
    hp_bar.set_value(current_hp)

    # Hide upon encounter initialization
    # This will be changed once the mob sprite is in place
    name_label.set_hidden(true)
    level_label.set_hidden(true)
    hp_bar.set_hidden(true)

    set_fixed_process(true)

func _fixed_process(delta):

    if current_hp > (max_hp / 4) && current_hp <= (max_hp / 2):
        hp_bar.set_progress_texture(load("res://Battle/hpMid.tex"))
    elif current_hp <= (max_hp / 4):
        hp_bar.set_progress_texture(load("res://Battle/hpLow.tex"))
