extends Container

enum CHOICE_TYPES {ITEM, MOVE, STAT}

var current_choice_state = null

var desc

var current_option = 0
var options

var moves_list = []
var moves_options = []

func _ready():
    desc = $optionDesc

    options = $options.get_children()
    for label in options:
        uiLogic.update_current_object(options, current_option)

    var moves_file = File.new()
    moves_file.open("res://data/moves.json", File.READ)
    var moves_file_text = moves_file.get_as_text()
    moves_list = parse_json(moves_file_text)
    moves_file.close()

    set_process_input(true)

func _input(event):
    if event.is_action_pressed("ui_left"):
        if current_option <= 0:
            current_option = options.size() - 1
        else:
            current_option -= 1
        uiLogic.update_current_object(options, current_option)

        if current_choice_state == MOVE:
            desc.set_text(moves_options[current_option].desc)

    elif event.is_action_pressed("ui_right"):
        if current_option >= (options.size() - 1):
            current_option = 0
        else:
            current_option += 1
        uiLogic.update_current_object(options, current_option)

        if current_choice_state == MOVE:
            desc.set_text(moves_options[current_option].desc)

    elif event.is_action_pressed("ui_accept") && current_choice_state == null:
        if current_option == 0:
            # Item
            pass
        elif current_option == 1:
            current_choice_state = MOVE
            current_option = 0

            for i in range(3):
                add_move_option(i)

            uiLogic.update_current_object(options, current_option)
            desc.set_text(moves_options[current_option].desc)
            
        elif current_option == 2:
            # Stat
            pass

    elif event.is_action_pressed("ui_accept") && current_choice_state == MOVE:
        gameData.player.moves.append(moves_options[current_option])
        sceneManager.goto_scene("res://grid/grid.tscn")

func add_move_option(index):
    var new_choice_index = gameData.get_random_number(moves_list.moves.size() - 1)
    var new_choice = moves_list.moves[new_choice_index]

    if moves_options.has(new_choice) || gameData.player.moves.has(new_choice):
        add_move_option(index)
        return
    elif new_choice.elementalType == null || new_choice.elementalType == gameData.player.elemental_type:
        moves_options.append(new_choice)
        options[index].set_text(new_choice.name)
    else:
        add_move_option(index)
        return