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

    if gameData.game_state.is_paused and not gameData.game_state.is_saving:
        # Move up and down in the pause menu
        if event.is_action_pressed("ui_up") or event.is_action_pressed("player_up"):

            if current_option <= 0:
                current_option = options_count
            else:
                current_option -= 1

            update_label_colors()

        elif event.is_action_pressed("ui_down") or event.is_action_pressed("player_down"):

            if current_option >= options_count:
                current_option = 0
            else:
                current_option += 1

            update_label_colors()

        # Accept the current option
        elif event.is_action_pressed("ui_accept"):

            if current_option == 0:
                sceneManager.goto_scene("res://Player/Stats.tscn")

            elif current_option == 1:
                save.save_game()
                get_parent().hide()
                gameData.game_state.is_paused = false

            elif current_option == 2:
                get_parent().set_hidden(true)
                gameData.game_state.is_paused = false

            elif current_option == 3:
                sceneManager.goto_scene("res://Player/About.tscn")

        # Just close
        elif event.is_action_pressed("ui_cancel"):
            get_parent().hide()
            gameData.game_state.is_paused = false

# update_label_colors
# Updates menu label colors for selection
func update_label_colors():
	for label in menu_options:
		if menu_options[current_option] == label:
			label.set("custom_colors/font_color", Color("#f9f9f9"))
		else:
			label.set("custom_colors/font_color", Color("#5b315b"))