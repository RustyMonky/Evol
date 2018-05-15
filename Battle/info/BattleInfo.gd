extends Control

var current_hp
var hp_bar
var max_hp
var type

func _ready():
    hp_bar = $infoBox/hp

    if type == "mob":
        $infoBox/name.set_text(gameData.mob.name)
        $infoBox/lvl.set_text("Lvl. " + String(gameData.mob.level))
    elif type == "player":
        $infoBox/name.set_text("You")
        $infoBox/lvl.set_text("Lvl. " + String(gameData.player.level))

    hp_bar.set_max(max_hp)
    hp_bar.set_value(current_hp)

    # Hide upon encounter initialization
    # This will be changed once the mob sprite is in place
    $infoBox/name.hide()
    $infoBox/lvl.hide()
    hp_bar.hide()

    set_process(true)

func _process(delta):

    hp_bar.set_value(current_hp)

    if current_hp > (max_hp / 4) && current_hp <= (max_hp / 2):
        hp_bar.set_progress_texture(load("res://Assets/GUI/hp/hpMid.png"))
    elif current_hp <= (max_hp / 4):
        hp_bar.set_progress_texture(load("res://Assets/GUI/hp/hpLow.png"))
