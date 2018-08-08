extends Control

enum battle_state { EVOLVING, GAMEOVER, INTRO, ITEMS, MENU, MOVES, LEVEL_UP, RUN, TURN, VICTORY }

var click_player
var current_effects = {
	mob = [],
	player = []
}
var current_move = 0
var current_option = 0
var current_state = battle_state.INTRO

var fight_options

var is_text_done = false

var menu_frame
var menu_options = []
var menu_prompt
var mob_info
var moves = []
var moves_font
var moves_grid
var player_info
var prompt_text = ""
var prompt_text_batch = []
var prompt_text_index = 0

func _ready():
	click_player = $clickPlayer
	menu_frame = $frame
	menu_prompt = $frame/menuPrompt
	moves_font = load("res://assets/fonts/standardFont.tres")
	moves_grid = $frame/fightOptions/movesScroll/movesGrid

	for move in gameData.player.moves:
		var label = Label.new()
		moves_grid.add_child(label)
		label.set("custom_fonts/font", moves_font)
		label.set("custom_colors/color", Color("#f9f9f9"))
		label.set_text(move.name)

	fight_options = $frame/fightOptions
	fight_options.hide()

	menu_options = $frame/menuOptions.get_children()
	for op in menu_options:
		op.hide()

	moves = moves_grid.get_children()

	set_process_input(true)
	uiLogic.update_current_object(menu_options, 0)
	uiLogic.update_current_object(moves, 0)

	 # Begin the encounter introduction
	set_prompt_text(["A " + battleData.mob.name + " appeared!", "What will you do?"], 0)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		click_player.play()

		if is_text_done:

			if not current_state == battle_state.GAMEOVER && player_info.current_hp <= 0:
				set_prompt_text(["You've lost all of your HP...", "You've been vanquished!"], 0)
				current_state = battle_state.GAMEOVER

			elif current_state == battle_state.TURN:
				current_state = battle_state.MENU
				hide_fight_controls(true)

			elif current_state == battle_state.VICTORY:
				var text_array = ["You consumed " + battleData.mob.name + "!", "You gained " + String(battleData.mob.xp) + " experience points."]

				gameData.player.xp += battleData.mob.xp
				gameData.player.total_mobs_killed += 1

				# Check if the player can level up
				# But first, reset any battle temporary stat gains
				var resetStats = {
					defense = 0,
					speed = 0,
					strength = 0
				}
				battleData.player.statsChanged = resetStats
				battleData.mob.statsChanged = resetStats

				if gameData.player.xp >= gameData.xp_required_array[gameData.player.level]:
					current_state = battle_state.LEVEL_UP
					gameData.level_up()
					text_array.append("You reached level " + String(gameData.player.level) + "!")

				if gameData.player.level == 5 && gameData.player.form == null && gameData.player.elemental_type == null:
					current_state = battle_state.EVOLVING

				set_prompt_text(text_array, 0)

			# Intro concluded, start battle sequence
			elif current_state == battle_state.INTRO:
				current_state = battle_state.MENU

				for op in menu_options:
					op.show()

			elif current_state == battle_state.MENU:

				if current_option == 0:
					hide_fight_controls(false)

				elif current_option == 1:
					current_state = battle_state.RUN
					set_prompt_text(["You ran away!"], 0)

				elif current_option == 2:
					if (gameData.player.items.size() == 0):
						set_prompt_text(["You currently have no items!"], 0)
					else:
						current_state = battle_state.ITEMS

			# If the user selects an attack whose text is clearly visible...
			elif current_state == battle_state.MOVES && moves[current_move].is_visible():
				process_turn_with_move()

			elif current_state == battle_state.RUN:
				sceneManager.goto_scene("res://grid/grid.tscn")

		else:
			if menu_prompt.get_visible_characters() >= menu_prompt.get_total_character_count():
				set_prompt_text(prompt_text_batch, prompt_text_index)

	elif event.is_action_pressed("ui_left"):
		if current_state == battle_state.MENU:
			if (current_option <= 0):
				return
			current_option -= 1
			uiLogic.update_current_object(menu_options, current_option)

		elif current_state == battle_state.MOVES:
			if current_move - 1 < 0:
				current_move = 4
			elif (current_move - 1) > gameData.player.moves.size():
				current_move = gameData.player.moves.size() - 1
			else:
				current_move -= 1
			uiLogic.update_current_object(moves, current_move)

	elif event.is_action_pressed("ui_right"):
		if current_state == battle_state.MENU:
			if (current_option >= 2):
				return
			current_option += 1
			uiLogic.update_current_object(menu_options, current_option)

		elif current_state == battle_state.MOVES:
			if current_move + 1 > (moves.size() - 1):
				current_move = 0
			elif current_move + 1 > (gameData.player.moves.size() - 1):
				current_move = 4
			else:
				current_move += 1
			uiLogic.update_current_object(moves, current_move)

	elif event.is_action_pressed("ui_cancel"):
		if current_state == battle_state.MOVES:
			hide_fight_controls(true)
			current_state = battle_state.MENU

		elif current_state == battle_state.ITEMS:
			current_state = battle_state.MENU


# ---------------
# Class Functions
# ---------------
func calculate_damage(attack, entity):
	var damage = 0
	var current_enemy
	var current_entity = battleData[entity]
	var other_entity
	var pre_text = ""
	var process_text_array = []
	var selected_attack = battleData[entity].moves[attack]

	if entity == "player":
		current_enemy = battleData.mob
		other_entity = "mob"
		pre_text = "You"
	elif entity == "mob":
		current_enemy = battleData.player
		other_entity = "player"
		pre_text = battleData.mob.name

	if selected_attack.damage > 0:

		damage = floor(selected_attack.damage * (current_entity.stats.strength + current_entity.statsChanged.strength) / (current_enemy.stats.defense + current_enemy.statsChanged.defense))

		# But if it's so weak it's floored to 0, bump to 1
		if (damage == 0): damage = 1

	if selected_attack.has('stat'):

		if selected_attack.stat.has('strength'):
			current_entity.statsChanged.strength += selected_attack.stat.strength
			process_text_array.append(pre_text + " increased in strength!")

		if selected_attack.stat.has('defense'):
			current_entity.statsChanged.defense += selected_attack.stat.defense
			process_text_array.append(pre_text + " increased defenses!")

		if selected_attack.stat.has('speed'):
			current_entity.statsChanged.speed += selected_attack.stat.speed
			process_text_array.append(pre_text + " picked up speed!")

		if selected_attack.stat.has('hp'):
			current_entity.current_hp += selected_attack.stat.hp
			process_text_array.append(pre_text + " recovered " + String(selected_attack.stat.hp) + " HP!")

	if selected_attack.has('effect'):
		if selected_attack.effect.has('burn') and current_effects[other_entity].size() == 0:
			current_effects[other_entity].append('burn')
			process_text_array.append(pre_text + " received a burn!")

		if selected_attack.effect.has('slow') and current_effects[other_entity].size() == 0:
			current_effects[other_entity].append('slow')
			process_text_array.append(pre_text + " became slowed!")

		if selected_attack.effect.has('poison') and current_effects[other_entity].size() == 0:
			current_effects[other_entity].append('poison')
			process_text_array.append(pre_text + " became poisoned!")

	if process_text_array.size() > 0:
		set_prompt_text(process_text_array, 0)
	return {
		"damage": damage,
		"text": process_text_array
	}

# calculate_effect
# Implements effect of the provided status change
func calculate_effect(entity, effect):
	if effect == 'burn':
		gameData[entity].current_hp -= 2
		battleData[entity].statsChanged.defense -= 1
	elif effect == 'slow':
		battleData[entity].statsChanged.speed -= 1
		battleData[entity].statsChanged.strength -= 1
	elif effect == 'poison':
		gameData[entity].current_hp -= 3


# hide_fight_controls
# Toggles visibility of various fight controls
func hide_fight_controls(hide):
	if hide:
		toggle_hidden(false)
		menu_prompt.show()

		fight_options.hide()

	else:
		current_state = battle_state.MOVES
		toggle_hidden(true)
		menu_prompt.hide()

		fight_options.show()

func process_turn_with_item():
	current_state = battle_state.TURN
	var process_text_array = []
	var process_turns_array = []

	hide_fight_controls(true)
	toggle_hidden(true)

	# First, get the mob's move selection as well
	var mob_attack = floor(rand_range(0, battleData.mob.moves.size()))

	# Then, create our turn order
	if gameData.player.stats.speed >= battleData.mob.stats.speed:
		process_turns_array = ["player", "mob"]
	else:
		process_turns_array = ["mob", "player"]

	for turn in process_turns_array:
		var turn_owner

		if turn == "player":
			turn_owner = "You"
		elif turn == "mob":
			turn_owner = battleData.mob.name

		if turn == "player":
			process_text_array.append("You used " + battleData.item_used.name + "!")

			if battleData.item_used.effects.has("hp"):
				var hp_amount = battleData.item_used.effects.hp
				if hp_amount >= 1:
					gameData.player.current_hp += hp_amount
					process_text_array.append("You recovered " + String(hp_amount) + " HP!")
				else:
					var hp_lost = gameData.player.max_hp * hp_amount
					gameData.player.current_hp -= hp_lost
					process_text_array.append("You lost " + String(hp_lost) + " HP!")

			elif battleData.item_used.effects.has("defense"):
				var def_amount = battleData.item_used.effects.defense
				if def_amount >= 0:
					battleData.player.statsChanged.defense += def_amount
					process_text_array.append("You gained " + String(def_amount) + " defense!")
				else:
					battleData.player.statsChanged.defense -= def_amount
					process_text_array.append("You lost " + String(def_amount) + " defense!")

			elif battleData.item_used.effects.has("speed"):
				var spd_amount = battleData.item_used.effects.speed
				if spd_amount >= 0:
					battleData.player.statsChanged.speed += spd_amount
					process_text_array.append("You gained " + String(spd_amount) + " speed!")
				else:
					battleData.player.statsChanged.speed -= spd_amount
					process_text_array.append("You lost " + String(spd_amount) + " speed!")

			elif battleData.item_used.effects.has("strength"):
				var str_amount = battleData.item_used.effects.strength
				if str_amount >= 0:
					battleData.player.statsChanged.strength += str_amount
					process_text_array.append("You gained " + String(str_amount) + " strength!")
				else:
					battleData.player.statsChanged.strength -= str_amount
					process_text_array.append("You lost " + String(str_amount) + " strength!")

			# After item usage, clear gameData of it
			battleData.item_used = null

		elif turn == "mob":
			process_text_array.append(battleData.mob.name + " used " + battleData.mob.moves[mob_attack].name + "!")

			var turn_result = calculate_damage(mob_attack, "mob")
			var damage_dealt = turn_result.damage
			if turn_result.text.size() > 0:
				for text in turn_result.text:
					process_text_array.append(text)

			process_text_array.append("You took " + String(damage_dealt) + " damage!")
			gameData.player.current_hp -= damage_dealt
			player_info.current_hp = gameData.player.current_hp

		if current_effects[turn].size() > 0:
			for effect in current_effects[turn]:
				calculate_effect(turn, effect)
				if effect == 'burn':
					process_text_array.append(turn_owner + " took 2 damage from the burn!")
				elif effect == 'slow':
					process_text_array.append(turn_owner + " remained slowed.")
				elif effect == 'poison':
					process_text_array.append(turn_owner + " took 3 damage from the poison!")

		if mob_info.current_hp <= 0 || player_info.current_hp <= 0:
			break

	set_prompt_text(process_text_array, 0)

func process_turn_with_move():
	current_state = battle_state.TURN
	var process_text_array = []
	var process_turns_array = []

	hide_fight_controls(true)
	toggle_hidden(true)

	# First, get the mob's move selection as well
	var mob_attack = floor(rand_range(0, battleData.mob.moves.size()))

	# Then, create our turn order
	if gameData.player.stats.speed >= battleData.mob.stats.speed:
		process_turns_array = ["player", "mob"]
	else:
		process_turns_array = ["mob", "player"]

	# Now, to process the turn, loop thru the array and based on the string, calculate for that entity
	for turn in process_turns_array:
		var turn_owner
		var move

		if turn == "player":
			turn_owner = "You"
			move = current_move
		elif turn == "mob":
			turn_owner = battleData.mob.name
			move = mob_attack

		process_text_array.append(turn_owner + " used " + battleData[turn].moves[move].name + "!")

		var turn_result = calculate_damage(move, turn)
		var damage_dealt = turn_result.damage
		if turn_result.text.size() > 0:
			for text in turn_result.text:
				process_text_array.append(text)

		if turn == "player":
			process_text_array.append(battleData.mob.name + " took " + String(damage_dealt) + " damage!")
			battleData.mob.current_hp -= damage_dealt
			mob_info.current_hp = battleData.mob.current_hp
		elif turn == "mob":
			process_text_array.append("You took " + String(damage_dealt) + " damage!")
			gameData.player.current_hp -= damage_dealt
			player_info.current_hp = gameData.player.current_hp

		if current_effects[turn].size() > 0:
			for effect in current_effects[turn]:
				calculate_effect(turn, effect)
				if effect == 'burn':
					process_text_array.append(turn_owner + " took 2 damage from your burn!")
				elif effect == 'slow':
					process_text_array.append(turn_owner + " remained slowed.")
				elif effect == 'poison':
					process_text_array.append(turn_owner + " took 3 damage from the poison!")

		if mob_info.current_hp <= 0:
			current_state = battle_state.VICTORY
			break
		elif player_info.current_hp <= 0:
			current_state = battle_state.GAMEOVER
			set_prompt_text(["You've lost all of your HP...", "You've been vanquished!"], 0)
			break

	set_prompt_text(process_text_array, 0)

# set_prompt_text
# Sets the next batch of prompt text and reset its visibility to 0
func set_prompt_text(text_batch, index):
	prompt_text_batch = text_batch
	prompt_text_index = index
	prompt_text = text_batch[prompt_text_index]
	menu_prompt.set_bbcode(prompt_text)
	menu_prompt.set_visible_characters(0)
	is_text_done = false

# toggle_hidden
# Toggles visibility of menu options
func toggle_hidden(is_hidden):
	for opt in menu_options:
		if is_hidden:
			opt.hide()
		else:
			opt.show()

# _on_menuPromptTimer_timeout
# Dictates menu prompt text output
func _on_menuPromptTimer_timeout():
	menu_prompt.set_visible_characters(menu_prompt.get_visible_characters() + 1)

	if menu_prompt.get_visible_characters() == menu_prompt.get_total_character_count():

		# If more text is in the promp text batch, cycle through it
		if prompt_text_index < (prompt_text_batch.size() - 1):
			prompt_text_index += 1

		# Otherwise, process text batch completion
		else:
			is_text_done = true

func _on_clickPlayer_finished():
	if is_text_done:
		if current_state == battle_state.GAMEOVER:
			sceneManager.goto_scene("res://gameover/gameover.tscn")
		elif current_state == battle_state.EVOLVING:
			sceneManager.goto_scene("res://battle/evolution/evolution.tscn")
		elif current_state == battle_state.LEVEL_UP:
			sceneManager.goto_scene("res://victory/victory.tscn")
