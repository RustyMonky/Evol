extends Patch9Frame

var cam_pos
var current_option = 0
var cursor
var menu_options
var options_count
var player
var player_camera

func _ready():
    menu_options = get_node("PauseMenuOptions").get_children()
    options_count = menu_options.size() - 1

    cursor = get_node("Cursor")
    cursor_update()

    player = get_tree().get_root().get_node("Grid").get_node("TileMap").get_node("Player")
    player_camera = player.camera

    set_process_input(true)

func _input(event):

    if global.game_state.is_paused and not global.game_state.is_saving:
        # Move up and down in the pause menu
        if event.is_action_pressed("ui_up") or event.is_action_pressed("player_up"):

            if current_option <= 0:
                current_option = options_count
            else:
                current_option -= 1

            cursor_update()

        elif event.is_action_pressed("ui_down") or event.is_action_pressed("player_down"):

            if current_option >= options_count:
                current_option = 0
            else:
                current_option += 1

            cursor_update()

        # Accept the current option
        elif event.is_action_pressed("ui_accept"):

            if current_option == 0:
                get_node("/root/global").goto_scene("res://Player/Stats.tscn")

            elif current_option == 1:
                save.save_game()
                get_parent().hide()
                global.game_state.is_paused = false

            elif current_option == 2:
                get_parent().set_hidden(true)
                global.game_state.is_paused = false

            elif current_option == 3:
                get_node("/root/global").goto_scene("res://Player/About.tscn")

        # Just close
        elif event.is_action_pressed("ui_cancel"):
            get_parent().hide()
            global.game_state.is_paused = false

# cursor_update
# Updates the position of the cursor based on the currently selected menu option
func cursor_update():
    cursor.set_pos(Vector2(cursor.get_pos().x, menu_options[current_option].get_pos().y + 8))
