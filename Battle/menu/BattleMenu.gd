extends Control

var change_turn = false

var current_option = 0
var current_move = 0

var fight_back_btn

var is_attacking = false
var is_battle_done = false
var is_intro = true
var is_player_dead = false
var is_player_turn = false
var is_running = false
var is_text_done = false
var is_turn_done = false

var menu_frame
var menu_options = []
var menu_prompt

var mob_info

var moves = []

var must_leave = false

var player_info

var prompt_text = ""

var show_moves = false

func _ready():
    menu_frame = $frame

    menu_prompt = $frame/menuPrompt

    moves = $frame/fightOptions.get_children()

    for move in moves:
        var index = moves.find(move)

        if gameData.player.moves.size() > index:
            move.set_text(gameData.player.moves[index].name)

    menu_options = $frame/menuOptions.get_children()
    for op in menu_options:
        op.hide()

    show_moves = false

    fight_back_btn = $frame/fightOptions/back
        
    set_process_input(true)

    update_current_option(0)
    update_current_move(0)

func _input(event):
    if event.is_action_pressed("ui_accept") && not must_leave && not show_moves:

        if not must_leave and not show_moves:

            if is_text_done:
                # Player is dead, queue gameover state
                if is_player_dead:
                    sceneManager.goto_scene("res://gameover/gameover.tscn")
                # Intro concluded, start battle sequence
                elif is_intro:
                    is_intro = false
                    set_prompt_text("What will you do?")
                    for op in menu_options:
                        op.show()
                # Or, if changing turns in the middle of the battle...
                elif change_turn:
                    is_player_turn = !is_player_turn
                    is_turn_done = true
                    change_turn = false
                # If the user clicks to continue on the Run option, display text before allowing them to leave
                elif current_option == 1:
                    must_leave = true
                    set_run_text("Got away safely!")
                # Otherwise, if the user clicks to continue and the intro is completed, they'll be choosing fight by default
                # Tl,dr: start the battle
                elif current_option == 0 && not is_intro && not is_attacking:
                    show_moves = true

                    for move in moves:
                        move.show()

                    toggle_hidden(true)

                    # The above hides children, this hides the prompt itself
                    menu_prompt.hide()

                    fight_back_btn.show()

    # Otherwise, if the encounter must end, return to the grid
    elif event.is_action_pressed("ui_accept") && is_running && must_leave:
            sceneManager.goto_scene("res://grid/grid.tscn")

    # Move between "Fight" and "Run"
    elif event.is_action_pressed("ui_left") and not show_moves:
        update_current_option(0)

    elif event.is_action_pressed("ui_right") and not show_moves:
        update_current_option(1)

    # Exit fight menu
    elif show_moves:
        # Cancel "Fight"
        if event.is_action_pressed("ui_cancel"):

            hide_fight_controls(true)
            show_moves = false

        # Movement Options
        elif event.is_action_pressed("ui_left"):
            if current_move - 1 < 0:
                current_move = 4
            elif (current_move - 1) > gameData.player.moves.size():
                current_move = gameData.player.moves.size() - 1
            else:
                current_move -= 1
            update_current_move(current_move)

        elif event.is_action_pressed("ui_right"):
            if current_move + 1 > (moves.size() - 1):
                current_move = 0
            elif current_move + 1 > (gameData.player.moves.size() - 1):
                current_move = 4
            else:
                current_move += 1
            update_current_move(current_move)

        # If the user selects an attack whose text is clearly visible...
        elif event.is_action_pressed("ui_accept") && moves[current_move].is_visible():
            if current_move == 4:
                hide_fight_controls(true)
            elif not is_attacking:
                # Whoever is faster attacks first
                if gameData.player.stats.speed >= gameData.mob.stats.speed:
                    player_attack()
                else:
                    mob_attack()
            else:
                is_attacking = true

        # If we're already attacking and the turn is done, switch turns
        if is_attacking && is_turn_done:

            if is_player_turn:
                player_attack()
            else:
                mob_attack()

            is_turn_done = false
            is_attacking = false
            show_moves = false


# ---------------
# Class Functions
# ---------------

# calculate_damage
# param attack
# Calculates the damage of the selected move
func calculate_damage(attack):
    var damage

    if not is_player_turn:

        # If the ability deals damage...
        if gameData.mob.moves[attack].damage > 0:

            damage = floor(gameData.mob.moves[attack].damage * (gameData.mob.stats.strength + gameData.mob.statsChanged.strength) / (gameData.player.stats.defense + gameData.player.statsChanged.defense))

            # But if it's so weak it's floored to 0, bump to 1
            if (damage == 0): damage = 1

            gameData.player.current_hp -= damage
            player_info.current_hp = gameData.player.current_hp

        # Otherwise, if it's stat based...
        else:
            if gameData.mob.moves[attack].stat.has('strength'):
                gameData.mob.statsChanged.strength += gameData.mob.moves[attack].stat.strength
            elif gameData.mob.moves[attack].stat.has('defense'):
                gameData.mob.statsChanged.defense += gameData.mob.moves[attack].stat.defense
            elif gameData.mob.moves[attack].stat.has('speed'):
                gameData.mob.statsChanged.speed += gameData.mob.moves[attack].stat.speed

    elif is_player_turn:

        if gameData.player.moves[attack].damage > 0:

            damage = floor(gameData.player.moves[attack].damage * (gameData.player.stats.strength + gameData.player.statsChanged.strength) / (gameData.mob.stats.defense + gameData.mob.statsChanged.defense))

            if (damage == 0): damage = 1

            gameData.mob.current_hp -= damage
            mob_info.current_hp = gameData.mob.current_hp

        else:
            if gameData.player.moves[attack].stat.has('strength'):
                gameData.player.statsChanged.strength += gameData.player.moves[attack].stat.strength
            elif gameData.player.moves[attack].stat.has('defense'):
                gameData.player.statsChanged.defense += gameData.player.moves[attack].stat.defense
            elif gameData.player.moves[attack].stat.has('speed'):
                gameData.player.statsChanged.speed += gameData.player.moves[attack].stat.speed

    # If mob is dead
    if mob_info.current_hp <= 0:
        is_attacking = false
        show_moves = false
    # But if player is dead
    elif player_info.current_hp <= 0:
        is_attacking = false
        show_moves = false

# hide_fight_controls
# Toggles visibility of various fight controls
func hide_fight_controls(hide):
	if hide:
		fight_back_btn.hide()
		toggle_hidden(false)
		menu_prompt.show()

		for move in moves:
			move.hide()

	else:
		fight_back_btn.show()
		toggle_hidden(true)
		menu_prompt.hide()

		for move in moves:
			move.show()

# mob_attack
# Prepares the mob's attack
func mob_attack():
    is_player_turn = false

    var mob_attack = floor(rand_range(0, gameData.mob.moves.size()))
    calculate_damage(mob_attack)

    hide_fight_controls(true)

    toggle_hidden(true)
    set_prompt_text(gameData.mob.name + " used " + gameData.mob.moves[mob_attack].name + "!")

# player_attack
# Prepares the player's attack
func player_attack():
    is_player_turn = true

    calculate_damage(current_move)

    hide_fight_controls(true)

    toggle_hidden(true)
    set_prompt_text("You used " + gameData.player.moves[current_move].name + "!")

# set_prompt_text
# Sets the prompt text and reset its visibility to 0
func set_prompt_text(text):
    prompt_text = text
    menu_prompt.set_bbcode(text)
    menu_prompt.set_visible_characters(0)
    is_text_done = false

# set_run_text
# Indicates the user is running, hides the menu controls, and sets the prompt text
func set_run_text(text):
    is_running = true
    toggle_hidden(true)
    set_prompt_text(text)

# toggle_hidden
# Toggles visibility of menu options
func toggle_hidden(is_hidden):
    for opt in menu_options:
        if is_hidden:
            opt.hide()
        else:
            opt.show()

# update_current_move
# Updates the currently selected fight cursor move
func update_current_move(index):
    for move in moves:
        if moves[index] == move:
            move.set("custom_colors/font_color", Color("#f9f9f9"))
        else:
            move.set("custom_colors/font_color", Color("#5b315b"))

# update_current_option
# Updates the currently selected menu option
func update_current_option(index):
    current_option = index
    for option in menu_options:
        if menu_options[index] == option:
            option.set("custom_colors/font_color", Color("#f9f9f9"))
        else:
            option.set("custom_colors/font_color", Color("#5b315b"))

# _on_menuPromptTimer_timeout
# Dictates menu prompt text output
func _on_menuPromptTimer_timeout():
    menu_prompt.set_visible_characters(menu_prompt.get_visible_characters() + 1)

    # If all characters are outputed and the encounter intro is not playing
    if menu_prompt.get_visible_characters() == menu_prompt.get_total_character_count() && not is_intro:

        is_text_done = true

        if not is_running && not is_attacking:
            # If the mob died, control which text to display before leaving
            if gameData.mob.current_hp <= 0:

                if not is_battle_done:
                    set_prompt_text(gameData.mob.name + " fainted!")
                    is_battle_done = true
                else:
                    var end_battle_text = "You gained " + String(gameData.mob.xp) + " experience points."
                    gameData.player.xp += gameData.mob.xp
                    gameData.player.total_mobs_killed += 1

                    # Check if the player can level up
                    # But first, reset any battle temporary stat gains
                    var resetStats = {
                        defense = 0,
                        speed = 0,
                        strength = 0
                    }
                    gameData.player.statsChanged = resetStats
                    gameData.mob.statsChanged = resetStats

                    if gameData.player.xp >= gameData.xp_required_array[gameData.player.level]:
                        var pre_level_up_moves_count = gameData.player.moves.size()

                        gameData.level_up()

                        end_battle_text += ".. and grew to level " + String(gameData.player.level) +" !"

                        # If the player learned a move, add that info to the text as well
                        if gameData.player.moves.size() > pre_level_up_moves_count:
                            end_battle_text += "... And you learned " + String(gameData.player.moves[-1].name) + " !"

                    set_run_text(end_battle_text)
            # If the player died, show text before switching to game over
            elif gameData.player.current_hp <= 0 && not is_player_dead:
                set_prompt_text("You fainted!")
                is_player_dead = true
            # Otherwise, if player is not dead, just show the menu options
            elif not is_player_dead:
                toggle_hidden(false)
        elif is_attacking:
            change_turn = true
        else:
            must_leave = true

    # If all characters are outputed and the encounter intro is completed, indicate that the text is done
    elif menu_prompt.get_visible_characters() > 0 and menu_prompt.get_visible_characters() == menu_prompt.get_total_character_count() && is_intro:
        is_text_done = true

    # If we just began the encounter intro
    elif menu_prompt.get_visible_characters() == 0 && is_intro:
        set_prompt_text("A " + gameData.mob.name + " appeared!")
