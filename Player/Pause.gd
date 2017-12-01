extends Patch9Frame

var current_option = 0
var cursor
var menu_options
var options_count
var player
var player_camera
var saving_frame
var start_saving = false

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
        if event.is_action_pressed("ui_up"):

            if current_option <= 0:
                current_option = options_count
            else:
                current_option -= 1

            cursor_update()

        elif event.is_action_pressed("ui_down"):

            if current_option >= options_count:
                current_option = 0
            else:
                current_option += 1

            cursor_update()

        # Accept the current option
        elif event.is_action_pressed("ui_accept"):

            if current_option == 0:
                get_node("/root/global").goto_scene("res://Player/Stats.tscn")

            elif current_option == 1 and not start_saving:
                start_saving = true

                var cam_pos = player_camera.get_camera_pos()

                saving_frame = preload("res://Player/SavingFrame.tscn").instance()
                var saving_pos = Vector2(floor(cam_pos.x) - 120, floor(cam_pos.y) + 70)
                saving_frame.set_pos(saving_pos)
                get_tree().get_root().call_deferred("add_child", saving_frame)

                global.game_state.is_saving = true

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
