extends NinePatchRect

var current_option = 0
var has_saved = false
var is_saving = false
var menu_options
var options_count
var save_confirm_text

func _ready():
	menu_options = $menuOptions.get_children()
	options_count = menu_options.size() - 1
	save_confirm_text = $saveConfirm

	update_label_colors()

	set_process_input(true)

func _input(event):
	# Move up and down in the pause menu
	if event.is_action_pressed("ui_up") && !is_saving:

		if current_option <= 0:
			current_option = options_count
		else:
			current_option -= 1

		update_label_colors()

	elif event.is_action_pressed("ui_down") && !is_saving:

		if current_option >= options_count:
			current_option = 0
		else:
			current_option += 1

		update_label_colors()

	# Accept the current option
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):

		if current_option == 0:
			sceneManager.goto_scene("res://player/stats/stats.tscn")

		elif current_option == 1:
			var item_child_scene = load("res://items/items.tscn").instance()
			self.get_parent().add_child(item_child_scene)

		elif current_option == 3 || has_saved:
			sceneManager.goto_scene("res://grid/grid.tscn")

		elif current_option == 2 && !is_saving:
			save.save_game()
			is_saving = true
			$menuOptions.hide()
			get_parent().get_node("saveTimer").start()

	# Just close
	elif event.is_action_pressed("ui_cancel"):
		sceneManager.goto_scene("res://grid/grid.tscn")

# update_label_colors
# Updates menu label colors for selection
func update_label_colors():
	for label in menu_options:
		if menu_options[current_option] == label:
			label.get_child(0).set("custom_colors/font_color", Color("#f9f9f9"))
		else:
			label.get_child(0).set("custom_colors/font_color", Color("#5b315b"))

func _on_saveTimer_timeout():
	$saveConfirm.show()
	has_saved = true
