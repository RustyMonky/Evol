extends Control

var click_player
var current_option = 1
var fade_rect
var fade_tween
var has_saved_game = false
var options

func _ready():
    click_player = $clickPlayer

    options = $canvasLayer/container/options.get_children()

    fade_rect = $canvasLayer/fadeRect
    fade_tween = $fadeTween

    uiLogic.update_current_object(options, current_option)

    has_saved_game = save.load_game()

    if !has_saved_game:
        options[0].hide()

    set_process_input(true)

func _input(event):
    if event.is_action_pressed("ui_up") && has_saved_game:
        current_option = 0
        uiLogic.update_current_object(options, current_option)

    elif event.is_action_pressed("ui_down"):
        current_option = 1
        uiLogic.update_current_object(options, current_option)

    if event.is_action_pressed("ui_accept"):
        click_player.play()

        if current_option == 0:
            save.load_game()

        elif current_option == 1:
            start_new_game()

        fade_tween.interpolate_property(fade_rect, "modulate", Color(1,1,1,0), Color(1,1,1,1), 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
        fade_tween.start()

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
        moves_known = ["Rush"],
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

func _on_fadeTween_tween_completed(object, key):
    sceneManager.goto_scene("res://grid/grid.tscn")
