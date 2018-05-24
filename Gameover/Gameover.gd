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
            start_new_game()

        sceneManager.goto_scene("res://grid/grid.tscn")

# start_new_game
# Uses new values for new game - DOES NOT OVERWRITE SAVE
func start_new_game():
    gameData.player = {
        battle_sprite = "",
        current_hp = 15,
        elemental_type = null,
        form = null,
        level = 1,
        max_hp = 15,
        moves = [
            { name = 'Rush', damage = 3, desc = "Charge at an enemy" }
        ],
        pos = Vector2(1, 1),
        stats = {
            defense = 5,
            speed = 5,
            strength = 5
        },
        statsChanged = {
            defense = 0,
            speed = 0,
            strength = 0
        },
        stats_sprite = "res://assets/sprites/forms/sheets-32x32/baseSheet.png",
        sprite_frame = Rect2(0, 0, 32, 32),
        sprite_path = "res://assets/sprites/forms/sheets-32x32/baseSheet.png",
        total_mobs_killed = 0,
        xp = 0
    }