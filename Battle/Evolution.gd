extends ColorFrame

var choice_desc
var choice_name
var confirm_option = 0
var confirm_options
var current_option = 0
var cursor
var evo_text
var is_confirming = false
var is_selecting = false
var text_cursor
var options

func _ready():
    choice_desc = get_node("ChoiceInfo").get_node("ChoiceDesc")
    choice_name = get_node("ChoiceInfo").get_node("ChoiceName")

    confirm_options = [get_node("EvoTextBox").get_node("EvoConfirm"), get_node("EvoTextBox").get_node("EvoReject")]

    cursor = get_node("Cursor")

    evo_text = get_node("EvoTextBox").get_node("EvoText")
    evo_text.set_visible_characters(0)
    evo_text.set_bbcode("You're ready to evolve! Choose your next form carefully!")

    options = get_node("EvoChoices").get_children()

    text_cursor = get_node("EvoTextBox").get_node("TextCursor")

    set_process_input(true)

func _on_EvoTextTimer_timeout():
    evo_text.set_visible_characters(evo_text.get_visible_characters() + 1)

    if evo_text.get_visible_characters() == evo_text.get_total_character_count() and not is_confirming:
        cursor.show()
        is_selecting = true
        update_choice_text()

func _input(event):
    if is_selecting and not is_confirming:
        if event.is_action_pressed("ui_left"):
            if current_option == 0:
                current_option = 1
            else:
                current_option -= 1
            update_cursor_pos()
            update_choice_text()

        elif event.is_action_pressed("ui_right"):
            if current_option == 2:
                current_option = 0
            else:
                current_option += 1
            update_cursor_pos()
            update_choice_text()

        elif event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
            evo_text.set_visible_characters(0)
            evo_text.set_bbcode("Are you sure you want this form?")
            is_confirming_choice(true)

    elif is_confirming and not is_selecting:
        print("yep")
        if event.is_action_pressed("ui_left"):
            confirm_option = 0
            update_text_cursor_pos()
        elif event.is_action_pressed("ui_right"):
            confirm_option = 1
            update_text_cursor_pos()

        elif event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
            if confirm_option == 0:
                evolve()
            elif confirm_option == 1:
                is_confirming_choice(false)
                evo_text.set_visible_characters(0)
                evo_text.set_bbcode("You're ready to evolve! Choose your next form carefully!")

# ----------------
# Class Functions
# ----------------

# is_confirming_choice
# Toggles visibility of nodes for confirming evolution choice
func is_confirming_choice(b):
    for co in confirm_options:
        co.set_hidden(!b)
    update_text_cursor_pos()
    text_cursor.set_hidden(!b)
    is_selecting = !b
    is_confirming = b

# update_choice_text
# Updates text describing currently selected evolution
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

# update_cursor_pos
# Updates current cursor position to newly selected evolution
func update_cursor_pos():
    cursor.set_global_pos(Vector2(options[current_option].get_global_pos().x + 20, 100))

func update_text_cursor_pos():
    text_cursor.set_pos(Vector2(confirm_options[confirm_option].get_global_pos().x - 10, 55))