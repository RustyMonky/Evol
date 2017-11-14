extends TextureFrame

var current_option = 0
var cursor
var menu_options
var options_count

func _ready():
	menu_options = get_node("PauseMenuOptions").get_children()
	options_count = menu_options.size() - 1

	cursor = get_node("Cursor")
	cursor_update()

	set_process_input(true)

func _input(event):

	# Move up and down in the pause menu
	if event.is_action_pressed("ui_up"):

		if current_option >= options_count:
			current_option = 0
		elif current_option != 0:
			current_option -= 1

		cursor_update()

	elif event.is_action_pressed("ui_down"):

		if current_option <= 0:
			current_option = 0
		elif current_option != options_count:
			current_option += 1

		cursor_update()

	# Accept the current option
	elif event.is_action_pressed("ui_accept"):
		return

# cursor_update
# Updates the position of the cursor based on the currently selected menu option
func cursor_update():
    cursor.set_pos(Vector2(cursor.get_pos().x, menu_options[current_option].get_pos().y + 8))
