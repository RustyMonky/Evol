extends Container

var current_choice = 0

var evolutions = [
	{
		"name": "Defense",
		"desc": "Relies on battles of attrition and endurance"
	},
	{
		"name": "Speed",
		"desc": "Evolved to end battles quickly and decisively"
	},
	{
		"name": "Strength",
		"desc": "Depends on its overwhelming power"
	},
	{
		"name": "Fire",
		"desc": "Attuned to the flames, burning all in its path"
	},
	{
		"name": "Water",
		"desc": "A viscous and flexible form to flood the world"
	},
	{
		"name": "Plant",
		"desc": "A mimicry of flora, poised to trap its foes"
	}
]

var form_chosen = false

func _ready():
	set_process_input(true)
	update_labels_and_pointer()

func _input(event):
	# Form Consideration
	if event.is_action_pressed("ui_left"):
		if current_choice - 1 < 0:
			current_choice = 5
		else:
			current_choice -= 1
		update_labels_and_pointer()

	elif event.is_action_pressed("ui_right"):
		if current_choice + 1 > 5:
			current_choice = 0
		else:
			current_choice += 1
		update_labels_and_pointer()

	# Form Selection
	elif event.is_action_pressed("ui_accept"):
		if not form_chosen:
			choose_form()
		else:
			sceneManager.goto_scene("res://grid/grid.tscn")

# ----------------
# Class Functions
# ----------------

func choose_form():
	if evolutions[current_choice].name == 'Defense':
		gameData.player.form = "defense"
		gameData.player.battle_sprite = "res://assets/sprites/forms/backs/baseDefBack.png"
		gameData.player.stat_sprite = "res://assets/sprites/forms/sheets-48x48/baseDefSheet.png"
		gameData.player.sprite_path = "res://assets/sprites/forms/sheets-48x48/baseDefSheet.png"
	elif evolutions[current_choice].name == 'Speed':
		gameData.player.form = "speed"
		gameData.player.battle_sprite = "res://assets/sprites/forms/backs/baseSpdBack.png"
		gameData.player.stat_sprite = "res://assets/sprites/forms/sheets-48x48/baseSpdSheet.png"
		gameData.player.sprite_path = "res://assets/sprites/forms/sheets-48x48/baseSpdSheet.png"
	elif evolutions[current_choice].name == 'Strength':
		gameData.player.form = "strength"
		gameData.player.battle_sprite = "res://assets/sprites/forms/backs/baseStrBack.png"
		gameData.player.stat_sprite = "res://assets/sprites/forms/sheets-48x48/baseStrSheet.png"
		gameData.player.sprite_path = "res://assets/sprites/forms/sheets-48x48/baseStrSheet.png"
	elif evolutions[current_choice].name == 'Fire':
		gameData.player.elemental_type = "fire"
		gameData.player.battle_sprite = "res://assets/sprites/forms/backs/baseFireBack.png"
		gameData.player.stat_sprite = "res://assets/sprites/forms/sheets-48x48/baseFireSheet.png"
		gameData.player.sprite_path = "res://assets/sprites/forms/sheets-48x48/baseFireSheet.png"
	elif evolutions[current_choice].name == 'Water':
		gameData.player.elemental_type = "water"
		gameData.player.battle_sprite = "res://assets/sprites/forms/backs/baseWaterBack.png"
		gameData.player.stat_sprite = "res://assets/sprites/forms/sheets-48x48/baseWaterSheet.png"
		gameData.player.sprite_path = "res://assets/sprites/forms/sheets-48x48/baseWaterSheet.png"
	elif evolutions[current_choice].name == 'Plant':
		gameData.player.elemental_type = "plant"
		gameData.player.battle_sprite = "res://assets/sprites/forms/backs/baseGrassBack.png"
		gameData.player.stat_sprite = "res://assets/sprites/forms/sheets-48x48/baseGrassSheet.png"
		gameData.player.sprite_path = "res://assets/sprites/forms/sheets-48x48/baseGrassSheet.png"

	$vBox/confirmLabel.set_text("You've evolved into the " + evolutions[current_choice].name + " form!")

	form_chosen = true


# update_labels_and_pointer
# Updates UI elements according to hovered elemental form
func update_labels_and_pointer():
	$vBox/formName.set_text(evolutions[current_choice].name)
	$vBox/formDesc.set_text(evolutions[current_choice].desc)

	var highlighted_form = $vBox/formsCenter/evolForms.get_children()[current_choice]

	$pointer.position = Vector2(highlighted_form.get_position().x + 126, highlighted_form.get_position().y + 148)
