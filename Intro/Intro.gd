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
			gameData.start_new_game()

		fade_tween.interpolate_property(fade_rect, "modulate", Color(1,1,1,0), Color(1,1,1,1), 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		fade_tween.start()

func _on_fadeTween_tween_completed(object, key):
	sceneManager.goto_scene("res://grid/grid.tscn")
