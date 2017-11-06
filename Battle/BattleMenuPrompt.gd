extends RichTextLabel

var promptText
var battle_menu
var battle_menu_options
var cursor
var is_running

func _ready():
    battle_menu = get_parent().get_parent()
    battle_menu_options = get_parent().get_node("BattleMenuOptions")
    cursor = get_parent().get_node("Cursor")
    is_running = false
    promptText = "What will you do?"
    set_prompt_text(promptText)

func _on_BattleMenuPromptTimer_timeout():
    set_visible_characters(get_visible_characters() + 1)

    if get_visible_characters() == get_total_character_count():
        if is_running:
            get_node("/root/global").goto_scene("res://Grid/Grid.tscn")
        else:
            toggle_hidden(false)


func set_prompt_text(text):
    set_bbcode(text)
    set_visible_characters(0)

func set_run_text(text):
    is_running = true
    toggle_hidden(true)
    set_prompt_text(text)

# Toggles visibility of cursor and battle menu options
func toggle_hidden(is_visible):
    cursor.set_hidden(is_visible)
    for opt in battle_menu.options:
        opt.set_hidden(is_visible)

