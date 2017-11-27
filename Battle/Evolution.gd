extends ColorFrame

var current_option = 0
var cursor
var evo_text
var options

func _ready():
    cursor = get_node("Cursor")

    evo_text = get_node("EvoTextBox").get_node("EvoText")
    evo_text.set_visible_characters(0)
    evo_text.set_bbcode("You're ready to evolve! Choose your next form carefully!")

    options = get_node("EvoChoices").get_children()

    set_process_input(true)

func _on_EvoTextTimer_timeout():
    evo_text.set_visible_characters(evo_text.get_visible_characters() + 1)

    if evo_text.get_visible_characters() == evo_text.get_total_character_count():
        cursor.show()

func _input(event):
    if event.is_action_pressed("ui_left"):
        if current_option == 0:
            current_option = 1
        else:
            current_option -= 1
        update_cursor_pos()

    elif event.is_action_pressed("ui_right"):
        if current_option == 2:
            current_option = 0
        else:
            current_option += 1
        update_cursor_pos()

func update_cursor_pos():
    cursor.set_global_pos(Vector2(options[current_option].get_global_pos().x + 20, 100))
