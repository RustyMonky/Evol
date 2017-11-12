extends RichTextLabel

var battle_menu
var battle_menu_options
var change_turn = false
var cursor
var is_battle_done = false
var is_intro = true
var is_running = false
var is_text_done = false
var must_leave = false
var prompt_cursor
var prompt_text

func _ready():
    battle_menu = get_parent().get_parent()
    battle_menu_options = get_parent().get_node("BattleMenuOptions")
    cursor = get_parent().get_node("Cursor")
    prompt_cursor = get_parent().get_node("TextCursor")
    prompt_cursor.set_hidden(true)

    set_fixed_process(true)

func _on_BattleMenuPromptTimer_timeout():
    set_visible_characters(get_visible_characters() + 1)

    # If all characters are outputed and the encounter intro is not playing
    if get_visible_characters() == get_total_character_count() && not is_intro:

        text_done(true)

        if not is_running && not battle_menu.is_attacking:
            toggle_hidden(false)
        elif battle_menu.is_attacking:
            change_turn = true
        else:
            must_leave = true

    # If all characters are outputed and the encounter intro is completed, indicate that the text is done
    elif get_visible_characters() > 0 and get_visible_characters() == get_total_character_count() && is_intro:
        text_done(true)

    # If we just began the encounter intro
    elif get_visible_characters() == 0 && is_intro:
        set_prompt_text("A " + global.mob.name + " appeared!")

func _fixed_process(delta):

    # if the text is done and the user clicks to continue...
    if is_text_done && Input.is_action_pressed("ui_accept"):

        # If it was the intro text, start the fight and prompt their choice
        if is_intro:
            is_intro = false
            set_prompt_text("What will you do?")

        # Otherwise, if the encounter must end, return to the grid
        elif is_running && must_leave:
            get_node("/root/global").goto_scene("res://Grid/Grid.tscn")

        # Or, if changing turns in the middle of the battle...
        elif change_turn && prompt_cursor.is_visible():
            battle_menu.is_player_turn = !battle_menu.is_player_turn
            battle_menu.is_turn_done = true
            change_turn = false

    # If the battle is finished but not ready to close because more information must be displayed...
    elif is_text_done && is_battle_done && not must_leave:

        # If it's because the mob is defeated, give the user xp
        if (global.mob.current_hp <= 0):
            set_run_text("You gained " + String(global.mob.xp) + " experience points.")
            global.player.xp += global.mob.xp
            # We can now leave
            must_leave = true

# ---------------
# Class Functions
# ---------------

# set_prompt_text
# Sets the prompt text and reset its visibility to 0
func set_prompt_text(text):
    prompt_text = text
    set_bbcode(text)
    set_visible_characters(0)
    text_done(false)

# set_run_text
# Indicates the user is running, hides the menu controls, and sets the prompt text
func set_run_text(text):
    is_running = true
    toggle_hidden(true)
    set_prompt_text(text)

# toggle_hidden
# Toggles visibility of cursor and battle menu options
func toggle_hidden(is_visible):
    cursor.set_hidden(is_visible)

    for opt in battle_menu.options:
        opt.set_hidden(is_visible)

    prompt_cursor.set_hidden(!is_visible)

# text_done
# Updates node visibilities when prompt text is complete
func text_done(is_done):
    is_text_done = is_done
    prompt_cursor.set_hidden(!is_done)

