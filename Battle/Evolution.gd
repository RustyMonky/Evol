extends ColorFrame

var choice_desc
var choice_name
var current_option = 0
var cursor
var evo_text
var is_selecting = false
var options

func _ready():
    choice_desc = get_node("ChoiceInfo").get_node("ChoiceDesc")
    choice_name = get_node("ChoiceInfo").get_node("ChoiceName")

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
        is_selecting = true
        update_choice_text()

func _input(event):
    if event.is_action_pressed("ui_left") and is_selecting:
        if current_option == 0:
            current_option = 1
        else:
            current_option -= 1
        update_cursor_pos()
        update_choice_text()

    elif event.is_action_pressed("ui_right") and is_selecting:
        if current_option == 2:
            current_option = 0
        else:
            current_option += 1
        update_cursor_pos()
        update_choice_text()

func update_choice_text():
    if current_option == 0:
        choice_desc.set_text("A durable form that excels at absorbing damage. Sacrifices speed.")
        choice_name.set_text("DEF Form")

    elif current_option == 1:
        choice_desc.set_text("A nimble form for priority strikes and evasion. Sacrifices raw power.")
        choice_name.set_text("SPD Form")

    elif current_option == 2:
        choice_desc.set_text("A powerful form for crushing weaker foes. Sacrifices defense.")
        choice_name.set_text("STR Form")

func update_cursor_pos():
    cursor.set_global_pos(Vector2(options[current_option].get_global_pos().x + 20, 100))
