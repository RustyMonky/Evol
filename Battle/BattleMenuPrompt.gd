extends RichTextLabel

var promptText
var battle_menu
var battle_menu_options
var cursor

func _ready():
    battle_menu = get_parent().get_parent()
    battle_menu_options = get_parent().get_node("BattleMenuOptions")
    cursor = get_parent().get_node("Cursor")
    promptText = "What will you do?"
    set_prompt_text(promptText)

func _on_BattleMenuPromptTimer_timeout():
    set_visible_characters(get_visible_characters() + 1)

    if get_visible_characters() == get_total_character_count():
        cursor.set_hidden(false)
        for opt in battle_menu.options:
            opt.set_hidden(false)


func set_prompt_text(text):
    set_bbcode(text)
    set_visible_characters(0)
