extends Control

var cursor
var menu_frame
var menu_prompt

var current_option = 0
var options

func _ready():
    menu_frame = get_node("BattleMenuFrame")
    menu_prompt = menu_frame.get_node("BattleMenuPrompt")
    menu_prompt.set_text("What will you do?")

    options = menu_frame.get_node("BattleMenuOptions").get_children()

    cursor = menu_frame.get_node("Cursor")
    cursor_update()
    set_fixed_process(true)

func _fixed_process(delta):
    if Input.is_action_pressed("ui_accept") && current_option == 1:
        self.queue_free()
        get_tree().change_scene("res://Grid/Grid.tscn")
    elif Input.is_action_pressed("ui_left"):
        update_current_option("left")
        cursor_update()
    elif Input.is_action_pressed("ui_right"):
        update_current_option("right")
        cursor_update()
        

func cursor_update():
    cursor.set_global_pos(Vector2(options[current_option].get_global_pos().x - 8, cursor.get_global_pos().y))

# param direction cursor direction
func update_current_option(direction):
    if direction == "left":
        if current_option == 0:
            current_option = options.size() - 1
        else:
            current_option -= 1
    elif direction == "right":
        if current_option == options.size() - 1:
            current_option = 0
        else:
            current_option += 1
