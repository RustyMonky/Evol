extends Control

var change_turn = false
var click_player
var current_option = 0
var current_move = 0
var fight_back_btn

var is_evolving = false
var is_intro = true
var is_player_dead = false # Boolean that dictates routing to gameover state
var is_player_turn = false
var is_text_done = false
var level_up = false

var menu_frame
var menu_options = []
var menu_prompt
var mob_info
var moves = []
var must_leave = false
var player_info
var prompt_text = ""
var prompt_text_batch = []
var prompt_text_index = 0
var show_moves = false

func _ready():
    click_player = $clickPlayer
    fight_back_btn = $frame/fightOptions/back
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
    set_process_input(true)
    uiLogic.update_current_object(menu_options, 0)
    uiLogic.update_current_object(moves, 0)

     # Begin the encounter introduction
    set_prompt_text(["A " + gameData.mob.name + " appeared!", "What will you do?"], 0)

func _input(event):
    if event.is_action_pressed("ui_accept") && not must_leave && not show_moves:
        click_player.play()

        if is_text_done:
            # Player is dead, queue gameover state
            if is_player_dead:
                sceneManager.goto_scene("res://gameover/gameover.tscn")

            elif gameData.player.current_hp <= 0 && not is_player_dead:
                set_prompt_text(["You've lost all of your HP...", "You've been vanquished!"], 0)
                is_player_dead = true

            elif is_evolving:
                sceneManager.goto_scene("res://battle/evolution/evolution.tscn")

            elif level_up:
                sceneManager.goto_scene("res://victory/victory.tscn")

            # If the mob died, prepare victory text
            elif gameData.mob.current_hp <= 0:
                var text_array = ["You consumed " + gameData.mob.name + "!", "You gained " + String(gameData.mob.xp) + " experience points."]

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
                    gameData.level_up()
                    text_array.append("You reached level " + String(gameData.player.level) + "!")
                    level_up = true

                if gameData.player.level == 5:
                    is_evolving = true

                set_prompt_text(text_array, 0)

            # Intro concluded, start battle sequence
            elif is_intro:
                is_intro = false
                for op in menu_options:
                    op.show()

            # If the user clicks to continue on the Run option, display text before allowing them to leave
            elif current_option == 1:
                must_leave = true
                set_prompt_text(["You ran away!"], 0)

            # Otherwise, if the user clicks to continue and the intro is completed, they'll be choosing fight by default
            # Tl,dr: start the battle
            elif current_option == 0 && not is_intro:
                hide_fight_controls(false)

        else:
            if menu_prompt.get_visible_characters() >= menu_prompt.get_total_character_count():
                set_prompt_text(prompt_text_batch, prompt_text_index)
    elif event.is_action_pressed("ui_accept") && must_leave:
            click_player.play()
            if is_text_done:
                sceneManager.goto_scene("res://grid/grid.tscn")
            else:
                set_prompt_text(prompt_text_batch, prompt_text_index)

    # Move between "Fight" and "Run"
    elif event.is_action_pressed("ui_left") && not show_moves:
        uiLogic.update_current_object(menu_options, 0)
        current_option = 0

    elif event.is_action_pressed("ui_right") && not show_moves:
        uiLogic.update_current_object(menu_options, 1)
        current_option = 1

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
            uiLogic.update_current_object(moves, current_move)

        elif event.is_action_pressed("ui_right"):
            if current_move + 1 > (moves.size() - 1):
                current_move = 0
            elif current_move + 1 > (gameData.player.moves.size() - 1):
                current_move = 4
            else:
                current_move += 1
            uiLogic.update_current_object(moves, current_move)

        # If the user selects an attack whose text is clearly visible...
        elif event.is_action_pressed("ui_accept") && moves[current_move].is_visible():
            click_player.play()

            if current_move == 4:
                hide_fight_controls(true)

            else:
                process_turn()


# ---------------
# Class Functions
# ---------------
func calculate_mob_damage(attack):
    var damage = 0

    if gameData.mob.moves[attack].damage > 0:

        damage = floor(gameData.mob.moves[attack].damage * (gameData.mob.stats.strength + gameData.mob.statsChanged.strength) / (gameData.player.stats.defense + gameData.player.statsChanged.defense))

        # But if it's so weak it's floored to 0, bump to 1
        if (damage == 0): damage = 1

    if gameData.mob.moves[attack].has('stat'):

        if gameData.mob.moves[attack].stat.has('strength'):
            gameData.mob.statsChanged.strength += gameData.mob.moves[attack].stat.strength

        if gameData.mob.moves[attack].stat.has('defense'):
            gameData.mob.statsChanged.defense += gameData.mob.moves[attack].stat.defense

        if gameData.mob.moves[attack].stat.has('speed'):
            gameData.mob.statsChanged.speed += gameData.mob.moves[attack].stat.speed

        if gameData.mob.moves[attack].stat.has('hp'):
            gameData.mob.current_hp += gameData.mob.moves[attack].stat.hp

    return damage

# calculate_player_damage
func calculate_player_damage(attack):
    var damage = 0

    if gameData.player.moves[attack].damage > 0:

            damage = floor(gameData.player.moves[attack].damage * (gameData.player.stats.strength + gameData.player.statsChanged.strength) / (gameData.mob.stats.defense + gameData.mob.statsChanged.defense))

            if (damage == 0): damage = 1

    if gameData.player.moves[attack].has('stat'):

        if gameData.player.moves[attack].stat.has('strength'):
            gameData.player.statsChanged.strength += gameData.player.moves[attack].stat.strength

        if gameData.player.moves[attack].stat.has('defense'):
            gameData.player.statsChanged.defense += gameData.player.moves[attack].stat.defense

        if gameData.player.moves[attack].stat.has('speed'):
            gameData.player.statsChanged.speed += gameData.player.moves[attack].stat.speed

        if gameData.player.moves[attack].stat.has('hp'):
            gameData.player.current_hp += gameData.player.moves[attack].stat.hp

    return damage

# hide_fight_controls
# Toggles visibility of various fight controls
func hide_fight_controls(hide):
    if hide:
        show_moves = false
        fight_back_btn.hide()
        toggle_hidden(false)
        menu_prompt.show()

        for move in moves:
            move.hide()

    else:
        show_moves = true
        fight_back_btn.show()
        toggle_hidden(true)
        menu_prompt.hide()

        for move in moves:
            move.show()

func process_turn():
    var process_text_array = []
    var process_turns_array = []

    hide_fight_controls(true)
    toggle_hidden(true)

    # First, get the mob's move selection as well
    var mob_attack = floor(rand_range(0, gameData.mob.moves.size()))

    # Then, create our turn order
    if gameData.player.stats.speed >= gameData.mob.stats.speed:
        process_turns_array = ["player", "mob"]
    else:
        process_turns_array = ["mob", "player"]

    # Now, to process the turn, loop thru the array and based on the string, calculate for that entity
    for turn in process_turns_array:

        if turn == "player":
            process_text_array.append("You used " + gameData.player.moves[current_move].name + "!")
            var player_damage = calculate_player_damage(current_move)
            process_text_array.append(gameData.mob.name + " took " + String(player_damage) + " damage!")
            gameData.mob.current_hp -= player_damage
            mob_info.current_hp = gameData.mob.current_hp

            if mob_info.current_hp <= 0:
                break

        else:
            process_text_array.append(gameData.mob.name + " used " + gameData.mob.moves[mob_attack].name + "!")
            var mob_damage = calculate_mob_damage(mob_attack)
            process_text_array.append("You took " + String(mob_damage) + " damage!")
            gameData.player.current_hp -= mob_damage
            player_info.current_hp = gameData.player.current_hp

            if player_info.current_hp <= 0:
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
