extends ColorFrame

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_node("/root/global").goto_scene("res://Grid/Grid.tscn")

