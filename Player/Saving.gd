extends RichTextLabel

var choices = []
var current_choice = 0
var cursor

var is_open = true

var has_made_choice = false

func _ready():
    choices = get_parent().get_node("Choices").get_children()

    cursor = get_parent().get_node("Cursor")
    cursor.set_pos(Vector2(choices[current_choice].get_pos().x - 8, choices[current_choice].get_pos().y + 4))

    set_visible_characters(0)
    set_saving_text("Would you like to save the game?")

    set_process_input(true)

func _on_SavingTextTimer_timeout():

    set_visible_characters(get_visible_characters() + 1)

    if get_visible_characters() == get_total_character_count():
        if not has_made_choice:
            cursor.set_hidden(false)

            for choice in choices:
                choice.set_hidden(false)

func _input(event):

    if event.is_action_pressed("ui_accept"):
        if not has_made_choice:
            has_made_choice = true

            # save
            if current_choice == 0:
                save.save_game()
                set_saving_text("Your game has been saved.")
            # close
            elif current_choice == 1:
                done_saving()
        elif has_made_choice and not global.game_state.is_saving:
            done_saving()

    if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") and not has_made_choice:
        if current_choice == 0:
            current_choice = 1
        elif current_choice == 1:
            current_choice = 0
        cursor_update()

# done_saving
# Closes savings box
func done_saving():
    is_open = false
    global.game_state.is_saving = false
    get_parent().get_parent().set_hidden(true)
    self.queue_free()
    get_tree().get_root().get_node("PauseMenu").get_node("PauseFrame").set_hidden(true)

# cursor_update
# Updates the position of the cursor based on the currently selected menu option
func cursor_update():
    cursor.set_pos(Vector2(choices[current_choice].get_pos().x - 8, cursor.get_pos().y))

# set_saving_text
# param text
# Sets the bbcode within the saving text box
func set_saving_text(text):
    set_visible_characters(0)
    set_bbcode(text)

    for choice in choices:
        choice.set_hidden(true)

    cursor.set_hidden(true)
