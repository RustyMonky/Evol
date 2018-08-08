extends Control

var current_hp
var hp_bar
var hp_text
var hp_tween
var max_hp
var type

func _ready():
	hp_bar = $infoBox/hp
	hp_tween = $hpTween
	hp_text = $infoBox/hpText

	if type == "mob":
		$infoBox/name.set_text(battleData.mob.name)
		$infoBox/lvl.set_text("Lvl. " + String(battleData.mob.level))
	elif type == "player":
		$infoBox/name.set_text("You")
		$infoBox/lvl.set_text("Lvl. " + String(gameData.player.level))

	hp_bar.set_max(max_hp)
	hp_bar.set_value(current_hp)
	hp_text.set_text(String(current_hp) + " / " + String(max_hp))

	set_process(true)

func _process(delta):

	if hp_bar.get_value() != current_hp:
		hp_tween.interpolate_property(hp_bar, "value", hp_bar.get_value(), current_hp, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
		hp_tween.start()

		if current_hp < 0:
			current_hp = 0
		hp_text.set_text(String(current_hp) + " / " + String(max_hp))

	if current_hp > (max_hp / 4) && current_hp <= (max_hp / 2):
		hp_bar.set_progress_texture(load("res://assets/GUI/hp/hpMid.png"))
	elif current_hp <= (max_hp / 4):
		hp_bar.set_progress_texture(load("res://assets/GUI/hp/hpLow.png"))
