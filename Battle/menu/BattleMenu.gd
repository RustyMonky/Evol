extends Control

var click_player
var current_effects = {
    mob = [],
    player = []
}
var current_move = 0
var current_option = 0
var fight_back_btn

var is_evolving = false
var is_intro = true
var is_player_dead = false # Boolean that dictates routing to gameover state
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
func calculate_damage(attack, entity):
    var damage = 0
    var current_enemy
    var current_entity = gameData[entity]
    var selected_attack = gameData[entity].moves[attack]

    if entity == "player":
        current_enemy = gameData.mob
    elif entity == "mob":
        current_enemy = gameData.player

    if selected_attack.damage > 0:

        damage = floor(selected_attack.damage * (current_entity.stats.strength + current_entity.statsChanged.strength) / (current_enemy.stats.defense + current_enemy.statsChanged.defense))

        # But if it's so weak it's floored to 0, bump to 1
        if (damage == 0): damage = 1

    if selected_attack.has('stat'):

        if selected_attack.stat.has('strength'):
            current_entity.statsChanged.strength += selected_attack.stat.strength

        if selected_attack.stat.has('defense'):
            current_entity.statsChanged.defense += selected_attack.stat.defense

        if selected_attack.stat.has('speed'):
            current_entity.statsChanged.speed += selected_attack.stat.speed

        if selected_attack.stat.has('hp'):
            current_entity.current_hp += selected_attack.stat.hp

    if selected_attack.has('effect'):
        if selected_attack.effect.has('burn') and current_effects[current_enemy].size() == 0:
            current_effects[current_enemy].append('burn')

        if selected_attack.effect.has('slow') and current_effects[current_enemy].size() == 0:
            current_effects[current_enemy].append('slow')

        if selected_attack.effect.has('poison') and current_effects[current_enemy].size() == 0:
            current_effects[current_enemy].append('poison')

    return damage

# calculate_effect
# Implements effect of the provided status change
func calculate_effect(entity, effect):
    if effect == 'burn':
        gameData[entity].current_hp -= 2
        gameData[entity].statsChanged.defense -= 1
    elif effect == 'slow':
        gameData[entity].statsChanged.speed -= 1
        gameData[entity].statsChanged.strength -= 1
    elif effect == 'poison':
        gameData[entity].current_hp -= 3


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
        var turn_owner
        var move

        if turn == "player":
            turn_owner = "You"
            move = current_move
        elif turn == "mob":
            turn_owner = gameData.mob.name
            move = mob_attack

        process_text_array.append(turn_owner + " used " + gameData[turn].moves[move].name + "!")

        var damage_dealt = calculate_damage(current_move, turn)

        if turn == "player":
            process_text_array.append(gameData.mob.name + " took " + String(damage_dealt) + " damage!")
            gameData.mob.current_hp -= damage_dealt
            mob_info.current_hp = gameData.mob.current_hp
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

        if mob_info.current_hp <= 0 || player_info.current_hp <= 0:
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
