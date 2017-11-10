extends Control

var cursor
var cursor_is_moving
var fight_cursor_is_moving
var menu_frame
var menu_prompt

var current_option = 0
var options = []
var current_move = 0
var moves = []

var show_moves = false

var fight_back_btn
var fight_cursor

func _ready():
    menu_frame = get_node("BattleMenuFrame")

    menu_prompt = menu_frame.get_node("BattleMenuPrompt")

    moves = menu_frame.get_node("FightOptions").get_children()

    options = menu_frame.get_node("BattleMenuOptions").get_children()

    cursor = menu_frame.get_node("Cursor")
    cursor_update()
    cursor_is_moving = false

    show_moves = false

    fight_back_btn = menu_frame.get_node("FightBackButton")

    fight_cursor = menu_frame.get_node("FightCursor")
    fight_cursor_is_moving = false

    # Make the options and cursor invisible until all the introductory prompts are done
    cursor.set_hidden(true)
    for op in options:
        op.set_hidden(true)
        
    set_fixed_process(true)

func _fixed_process(delta):
    # Run
    if Input.is_action_pressed("ui_accept") && current_option == 1 && !menu_prompt.must_leave:

        menu_prompt.set_run_text("Got away safely!")

    # Fight
    elif Input.is_action_pressed("ui_accept") && current_option == 0 && !menu_prompt.must_leave && !show_moves && !menu_prompt.is_intro && menu_prompt.is_text_done:
        show_moves = true

        menu_prompt.toggle_hidden(true)
        menu_frame.get_node("TextCursor").set_hidden(true)
        # The above hides children, this hides the prompt itself
        menu_prompt.set_hidden(true)

        for move in moves:
            var index = moves.find(move);
            move.set_text(global.player.moves[index].name)
            move.set_hidden(false)

        fight_back_btn.set_hidden(false)
        fight_cursor_update()
        fight_cursor.set_hidden(false)

    # Move between "Fight" and "Run"
    if (!show_moves):
        if Input.is_action_pressed("ui_left") && !cursor_is_moving:

            cursor_is_moving = true
            update_current_option("left")
            cursor_update()

        elif Input.is_action_pressed("ui_right") && !cursor_is_moving:

            cursor_is_moving = true
            update_current_option("right")
            cursor_update()

    # Exit fight menu
    elif show_moves:
        if Input.is_action_pressed("ui_cancel"):

            show_moves = false
            fight_back_btn.set_hidden(true)
            menu_prompt.toggle_hidden(false)
            menu_prompt.set_hidden(false)
            for move in moves:
                move.set_hidden(true)
            fight_cursor.set_hidden(true)

        elif Input.is_action_pressed("ui_left") && !fight_cursor_is_moving:
            fight_cursor_is_moving = true
            update_current_move("left")
            fight_cursor_update()

        elif Input.is_action_pressed("ui_right") && !fight_cursor_is_moving:
            fight_cursor_is_moving = true
            update_current_move("right")
            fight_cursor_update()

        elif Input.is_action_pressed("ui_up") && !fight_cursor_is_moving:
            fight_cursor_is_moving = true
            update_current_move("up")
            fight_cursor_update()

        elif Input.is_action_pressed("ui_down") && !fight_cursor_is_moving:
            fight_cursor_is_moving = true
            update_current_move("down")
            fight_cursor_update()


# ---------------
# Class Functions
# ---------------

# cursor_update
# Updates the position of the cursor based on the currently selected menu option
func cursor_update():
    cursor.set_global_pos(Vector2(options[current_option].get_global_pos().x - 8, cursor.get_global_pos().y))

# fight_cursor_update
# Updates the position of the cursor based on the currently selected move
func fight_cursor_update():
    fight_cursor.set_global_pos(Vector2(moves[current_move].get_global_pos().x - 8, moves[current_move].get_global_pos().y + 4))

# update_current_move
# Updates the currently selected fight cursor move
func update_current_move(direction):
    if fight_cursor_is_moving == false:
        return false

    # In order to have the cursor move cleanly, instead of in rapid flashes
    # hard set the current option as opposed to incrementing or decrementing
    # Also cannot move left from zero or right from three (start and end)

    if direction == "left":

        if current_move == 1:
            current_move = 0
        elif current_move == 2:
            current_move = 1
        elif current_move == 3:
            current_move = 2

    elif direction == "right":

        if current_move == 0:
            current_move = 1
        elif current_move == 1:
            current_move = 2
        elif current_move == 2:
            current_move = 3

    elif direction == "up":

        if current_move == 2:
            current_move = 0
        elif current_move == 3:
            current_move = 1

    elif direction == "down":
        if current_move == 0:
            current_move = 2
        elif current_move == 1:
            current_move = 3

    fight_cursor_is_moving = false

# update_current_option
# Updates the currently selected cursor option
func update_current_option(direction):
    if cursor_is_moving == false:
        return false

    # Simplified menu logic until more options are added
    if direction == "left":
        current_option = 0
    elif direction == "right":
        current_option = 1
    cursor_is_moving = false
