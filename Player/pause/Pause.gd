extends NinePatchRect

var current_option = 0
var menu_options
var options_count

func _ready():
    menu_options = $menuOptions.get_children()
    options_count = menu_options.size() - 1

    update_label_colors()

    set_process_input(true)

func _input(event):
	# Move up and down in the pause menu
	if event.is_action_pressed("ui_up"):

		if current_option <= 0:
			current_option = options_count
		else:
			current_option -= 1

		update_label_colors()

	elif event.is_action_pressed("ui_down"):

		if current_option >= options_count:
			current_option = 0
		else:
			current_option += 1

		update_label_colors()

	# Accept the current option
	elif event.is_action_pressed("ui_select"):

		if current_option == 0:
			sceneManager.goto_scene("res://Player/stats/Stats.tscn")
	
		elif current_option == 1:
			save.save_game()
	
		elif current_option == 2:
			sceneManager.goto_scene("res://Grid/Grid.tscn")
	
		elif current_option == 3:
			sceneManager.goto_scene("res://Player/About.tscn")

	# Just close
	elif event.is_action_pressed("ui_cancel"):
		sceneManager.goto_scene("res://Grid/Grid.tscn")

# update_label_colors
# Updates menu label colors for selection
func update_label_colors():
	for label in menu_options:
		if menu_options[current_option] == label:
			label.get_child(0).set("custom_colors/font_color", Color("#f9f9f9"))
		else:
			label.get_child(0).set("custom_colors/font_color", Color("#5b315b"))