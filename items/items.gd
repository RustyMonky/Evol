extends Control

var item_font
var item_grid

func _ready():
	item_font = load("res://assets/fonts/somepx32.tres")
	item_grid = $scroll/grid

	for item in gameData.player.items:
		var item_label = Label.new()
		item_label.set_text(item.name)
		item_label.set("custom_fonts/font", item_font)
		item_label.set("custom_colors/color", Color("#f9f9f9"))
		item_grid.add_child(item_label)
