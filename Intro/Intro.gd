extends Control

var current_option = 1
var has_saved_game = false
var options

func _ready():
	options = $canvasLayer/container/options.get_children()

	update_label_colors(current_option)

	has_saved_game = save.load_game()

	if !has_saved_game:
		options[0].visible = false

	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_up") && has_saved_game:
		current_option = 0
		update_label_colors(current_option)

	elif event.is_action_pressed("ui_down"):
		current_option = 1
		update_label_colors(current_option)

	if event.is_action_pressed("ui_accept"):

		if current_option == 0:
			save.load_game()
			sceneManager.goto_scene("res://Grid/Grid.tscn")

		elif current_option == 1:
			start_new_game()

# start_new_game
# Overwrites the save file with a fresh start
func start_new_game():
	gameData.player = {
	    battle_sprite = "res://Assets/Battle/baseBattleSprite.tex",
	    current_hp = 15,
	    level = 1,
	    max_hp = 15,
	    moves = [
	        { name = 'Rush', damage = 3, desc = "Charge at an enemy" }
	    ],
	    # The below value may change and is currently hardset to work with the test grid
	    pos = Vector2(200, 200),
	    stats = {
	        defense = 5,
	        speed = 5,
	        strength = 5
	    },
	    statsChanged = {
	        defense = 0,
	        speed = 0,
	        strength = 0
	    },
	    stats_sprite = "res://Assets/sprites/forms/typeSheet.png",
	    sprite_frame = 0,
	    sprite_path = "res://Assets/sprites/forms/typeSheet.png",
	    total_mobs_killed = 0,
	    xp = 0
	}

	save.save_game()

	sceneManager.goto_scene("res://Grid/Grid.tscn")

# update_label_colors
# int index
# Updates menu label colors for selection
func update_label_colors(index):
	for label in options:
		if options[index] == label:
			label.set("custom_colors/font_color", Color("#f9f9f9"))
		else:
			label.set("custom_colors/font_color", Color("#5b315b"))