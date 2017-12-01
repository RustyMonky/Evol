extends Control

var current_option = 0
var cursor
var options

func _ready():
	cursor = get_node("Cursor")

	options = get_node("Options").get_children()

	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_up"):
		current_option = 0
	elif event.is_action_pressed("ui_down"):
		current_option = 1
	update_cursor_pos()

	if event.is_action_pressed("ui_accept"):
		if current_option == 0:
			save.load_game()
			get_node("/root/global").goto_scene("res://Grid/Grid.tscn")
		elif current_option == 1:
			start_new_game()

# start_new_game
# Overwrites the save file with a fresh start
func start_new_game():
	global.player = {
	    battle_sprite = "res://Assets/Battle/baseBattleSprite.tex",
	    current_hp = 10,
	    level = 1,
	    max_hp = 10,
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
	    stats_sprite = "res://Assets/GUI/statsBaseSprite.png",
	    sprite_frame = 0,
	    sprite_path = "res://Player/baseEvolSheet.tex",
	    total_mobs_killed = 0,
	    xp = 0
	}

	save.save_game()

	get_node("/root/global").goto_scene("res://Grid/Grid.tscn")

# update_cursor_pos
# Updates the cursor position
func update_cursor_pos():
	cursor.set_global_pos(Vector2(110, options[current_option].get_global_pos().y))	
