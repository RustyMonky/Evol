extends RichTextLabel

var can_reload = false

func _ready():

    if get_visible_characters() == 0:
        set_bbcode("Would you like to continue from your last save point?")
        set_visible_characters(0)

    set_fixed_process(true)

func _on_GameoverTimer_timeout():
    set_visible_characters(get_visible_characters() + 1)

    if get_visible_characters() == get_total_character_count():
        can_reload = true


func _fixed_process(delta):

    if can_reload and Input.is_action_pressed("ui_accept"):
        # Replace this with loading of saved file
        get_node("/root/global").goto_scene("res://Grid/Grid.tscn")