extends RichTextLabel

var prompt_text
var battle_menu
var battle_menu_options
var cursor
var is_running
var is_intro

func _ready():
    battle_menu = get_parent().get_parent()
    battle_menu_options = get_parent().get_node("BattleMenuOptions")
    cursor = get_parent().get_node("Cursor")

    is_running = false
    is_intro = true

    prompt_text = "A " + global.mob_name + " appeared!"
    set_prompt_text(prompt_text)

    set_fixed_process(true)

func _on_BattleMenuPromptTimer_timeout():
    set_visible_characters(get_visible_characters() + 1)

    if get_visible_characters() == get_total_character_count() && not is_intro:
        if is_running:
            get_node("/root/global").goto_scene("res://Grid/Grid.tscn")
        else:
            toggle_hidden(false)
    elif get_visible_characters() == get_total_character_count() && is_intro:
        is_intro = false
        set_prompt_text("What will you do?")

# ---------------
# Class Functions
# ---------------

# set_prompt_text
# Sets the prompt text and reset its visibility to 0
func set_prompt_text(text):
    prompt_text = text
    set_bbcode(text)
    set_visible_characters(0)

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

