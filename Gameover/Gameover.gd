extends Control

var current_option = 0
var options

func _ready():
    options = $canvasLayer/container/options.get_children()

    uiLogic.update_current_object(options, current_option)

    set_process_input(true)

func _input(event):
    if event.is_action_pressed("ui_up"):
        current_option = 0
        uiLogic.update_current_object(options, current_option)
    
    elif event.is_action_pressed("ui_down"):
        current_option = 1
        uiLogic.update_current_object(options, current_option)
    
    if event.is_action_pressed("ui_accept"):
    
        if current_option == 0:
            save.load_game()
    
        elif current_option == 1:
            gameData.start_new_game()

        sceneManager.goto_scene("res://grid/grid.tscn")
