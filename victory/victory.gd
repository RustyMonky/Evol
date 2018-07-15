extends Container

enum victory_phase {CHOOSING, DONE}
enum CHOICE_TYPES {ITEM, MOVE, STAT}

var current_choice_state = null

var desc

var current_option = 0
var options
var item_options = []
var moves_options = []
var stat_options = [{
	name = "defense",
	desc = "Increase your defense by 2"
}, {
	name = "speed",
	desc = "Increase your speed by 2"
}, {
	name = "strength",
	desc = "Increase your strength by 2"
}]

var victory_phase = CHOOSING

func _ready():
	desc = $optionDesc

	options = $options.get_children()
	for label in options:
		uiLogic.update_current_object(options, current_option)

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
		elif current_choice_state == STAT:
			desc.set_text(stat_options[current_option].desc)

	elif event.is_action_pressed("ui_right"):
		if current_option >= (options.size() - 1):
			current_option = 0
		else:
			current_option += 1
		uiLogic.update_current_object(options, current_option)

		if current_choice_state == MOVE:
			desc.set_text(moves_options[current_option].desc)
		elif current_choice_state == STAT:
			desc.set_text(stat_options[current_option].desc)
		elif current_choice_state == ITEM:
			desc.set_text(item_options[current_option].desc)

	elif event.is_action_pressed("ui_accept") && current_choice_state == null:
		if current_option == 0:
			current_choice_state = ITEM
			current_option = 0

			for i in range(3):
				add_item_option(i)

			desc.set_text(item_options[current_option].desc)
		elif current_option == 1:
			current_choice_state = MOVE
			current_option = 0

			for i in range(3):
				add_move_option(i)

			desc.set_text(moves_options[current_option].desc)

		elif current_option == 2:
			current_choice_state = STAT
			current_option = 0

			for i in range(3):
				add_stat_option(i)

			desc.set_text(stat_options[current_option].desc)

		uiLogic.update_current_object(options, current_option)

	elif event.is_action_pressed("ui_accept"):
		if victory_phase == CHOOSING:
			if current_choice_state == MOVE:
				gameData.player.moves.append(moves_options[current_option])
				gameData.player.moves_known.append(moves_options[current_option].name)
				desc.set_text("You learned " + moves_options[current_option].name + "!")
			elif current_choice_state == STAT:
				var chosen_stat = stat_options[current_option].name
				gameData.player.stats[chosen_stat] += 2
				desc.set_text("You inscreased your " + stat_options[current_option].name + " by two!")
			elif current_choice_state == ITEM:
				gameData.player.items.append(item_options[current_option])
				desc.set_text("You gained a " + item_options[current_option].name + "!")
			victory_phase = DONE

		elif victory_phase == DONE:
			sceneManager.goto_scene("res://grid/grid.tscn")

	elif event.is_action_pressed("ui_cancel"):
		current_choice_state = null
		reset_options()

# add_item_option
# Prepares labels with item data
func add_item_option(index):
	var new_choice_index = gameData.get_random_number(gameData.items_data.items.size() - 1)
	var new_choice = gameData.items_data.items[new_choice_index]
	item_options.append(new_choice)
	options[index].set_text(new_choice.name)

# add_move_option
# Prepares labels with move data
func add_move_option(index):
	var new_choice_index = gameData.get_random_number(gameData.moves_data.moves.size() - 1)
	var new_choice = gameData.moves_data.moves[new_choice_index]

	if moves_options.has(new_choice) || gameData.player.moves_known.has(new_choice.name):
		add_move_option(index)
		return
	elif new_choice.elementalType == null || new_choice.elementalType == gameData.player.elemental_type:
		moves_options.append(new_choice)
		options[index].set_text(new_choice.name)
	else:
		add_move_option(index)
		return

# add_stat_option
# Prepares labels with stats data
func add_stat_option(index):
	options[index].set_text(stat_options[index].name)

# reset_options
# Returns to first choice menu
func reset_options():
	options[0].set_text("Item")
	options[1].set_text("Move")
	options[2].set_text("Stat")
	desc.set_text("")
