extends Node

func _ready():
    pass

# update_current_object
# Updates the currently selected object in a collection via its font color
func update_current_object(collection, index):
    for obj in collection:
        if collection[index] == obj:
            obj.set("custom_colors/font_color", Color("#f9f9f9"))
        else:
            obj.set("custom_colors/font_color", Color("#5b315b"))