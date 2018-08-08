extends Control

var current_item = 0
var selected_item = null

var item_font
var item_grid
var item_opts

func _ready():
	item_font = load("res://assets/fonts/somepx24.tres")
	item_grid = $scroll/grid

	for item in gameData.player.items:
		var item_opt = load("res://items/item.tscn").instance()
		var item_label = item_opt.get_node("label")
		item_label.set_text(item.name)
		item_label.set("custom_fonts/font", item_font)
		item_label.set("custom_colors/color", Color("#f9f9f9"))
		item_opt.get_node("sprite").set_texture(load(item.sprite))
		item_grid.add_child(item_opt)

	item_opts = item_grid.get_children()

	uiLogic.update_current_object(item_opts, current_item)

	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_left"):
		if current_item > 0:
			current_item -= 1
			uiLogic.update_current_object(item_opts, current_item)

	elif event.is_action_pressed("ui_right"):
		if current_item < item_opts.size() - 1:
			current_item += 1
			uiLogic.update_current_object(item_opts, current_item)

	elif event.is_action_pressed("ui_accept"):
		selected_item = current_item

		# Store the currently selected item in memory for battle usage,
		# Then remove it from the player's inventory
		battleData.item_used = gameData.player.items[selected_item]
		gameData.player.items.remove(selected_item)

		self.queue_free()
