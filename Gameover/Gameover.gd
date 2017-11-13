extends RichTextLabel

var can_reload = false
var gameover_choice_text

func _ready():

    set_visible_characters(0)

    gameover_choice_text = get_parent().get_node("GameoverChoiceText")

    set_fixed_process(true)

func _on_GameoverTimer_timeout():
    set_visible_characters(get_visible_characters() + 1)

    if get_visible_characters() == get_total_character_count() && get_total_character_count() > 0 && not can_reload:
        can_reload = true
        gameover_choice_text.set_bbcode("Press A to reload, B to exit")
        gameover_choice_text.set_visible_characters(100)


func _fixed_process(delta):

    if can_reload and Input.is_action_pressed("ui_accept"):
        # Replace this with loading of saved file
        get_node("/root/global").goto_scene("res://Grid/Grid.tscn")