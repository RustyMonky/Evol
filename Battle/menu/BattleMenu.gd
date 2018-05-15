extends Control

var current_option = 0
var current_move = 0

var fight_back_btn

var is_attacking = false
var is_player_turn
var is_turn_done = false

var menu_frame
var menu_prompt

var mob_info

var moves = []
var options = []

var player_info

var show_moves = false

func _ready():
    menu_frame = $frame

    menu_prompt = $frame/menuPrompt

    moves = $frame/fightOptions.get_children()

    for move in moves:
        var index = moves.find(move)

        if gameData.player.moves.size() > index:
            move.set_text(gameData.player.moves[index].name)

    options = $frame/menuOptions.get_children()

    show_moves = false

    fight_back_btn = $frame/back

    for op in options:
        op.visible = true
        
    set_process_input(true)

func _input(event):
    if event.is_action_pressed("ui_accept") && not menu_prompt.must_leave && not show_moves:

        # If the user clicks to continue on the Run option, display text before allowing them to leave
        if current_option == 1 && !show_moves:
            menu_prompt.must_leave = true
            menu_prompt.set_run_text("Got away safely!")

        # Otherwise, if the user clicks to continue and the intro is completed, they'll be choosing fight by default
        # Tl,dr: start the battle
        elif current_option == 0 && not menu_prompt.is_intro && menu_prompt.is_text_done && not is_attacking:
            show_moves = true
            for move in moves:
                move.set_hidden(false)

            menu_prompt.toggle_hidden(true)

            # The above hides children, this hides the prompt itself
            menu_prompt.set_hidden(true)

            fight_back_btn.set_hidden(false)

    # Move between "Fight" and "Run"
    #if not show_moves:

        # TODO - Replace cursor implementation with text highlighting

    # Exit fight menu
    if show_moves:
        # Cancel "Fight"
        if event.is_action_pressed("ui_cancel"):

            hide_fight_controls(true)
            show_moves = false

        # Movement Options
        elif event.is_action_pressed("ui_left") or event.is_action_pressed("player_left"):
            update_current_move("left")
            # Replace cursor implementaiton with text highlighting

        elif event.is_action_pressed("ui_right") or event.is_action_pressed("player_right"):
            update_current_move("right")
            # Replace cursor implementaiton with text highlighting

        elif event.is_action_pressed("ui_up") or event.is_action_pressed("player_up"):
            update_current_move("up")
            # Replace cursor implementaiton with text highlighting

        elif event.is_action_pressed("ui_down") or event.is_action_pressed("player_down"):
            update_current_move("down")
            # Replace cursor implementaiton with text highlighting

        # If the user selects an attack whose text is clearly visible...
        elif event.is_action_pressed("ui_accept") && moves[current_move].is_visible():
            if (is_attacking):
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
    fight_back_btn.set_hidden(hide)

    menu_prompt.toggle_hidden(!hide)
    menu_prompt.set_hidden(!hide)

    for move in moves:
        move.set_hidden(hide)

# mob_attack
# Prepares the mob's attack
func mob_attack():
    is_player_turn = false

    var mob_attack = floor(rand_range(0, gameData.mob.moves.size()))
    calculate_damage(mob_attack)

    hide_fight_controls(true)

    menu_prompt.toggle_hidden(true)
    menu_prompt.set_prompt_text(gameData.mob.name + " used " + gameData.mob.moves[mob_attack].name + "!")

# player_attack
# Prepares the player's attack
func player_attack():
    is_player_turn = true

    calculate_damage(current_move)

    hide_fight_controls(true)

    menu_prompt.toggle_hidden(true)
    menu_prompt.set_prompt_text("You used " + gameData.player.moves[current_move].name + "!")

# update_current_move
# Updates the currently selected fight cursor move
func update_current_move(direction):

    # In order to have the cursor move cleanly, instead of in rapid flashes
    # hard set the current option as opposed to incrementing or decrementing
    # Also cannot move left from zero or right from three (start and end)

    if direction == "left":

        if current_move == 1:
            current_move = 0
        elif current_move == 2:
            current_move = 1
        elif current_move == 3:
            current_move = 2

    elif direction == "right":

        if current_move == 0:
            current_move = 1
        elif current_move == 1:
            current_move = 2
        elif current_move == 2:
            current_move = 3

    elif direction == "up":

        if current_move == 2:
            current_move = 0
        elif current_move == 3:
            current_move = 1

    elif direction == "down":
        if current_move == 0:
            current_move = 2
        elif current_move == 1:
            current_move = 3

    if moves[current_move].get_text() == '':
        current_move = 0

# update_current_option
# Updates the currently selected cursor option
func update_current_option(direction):

    # Simplified menu logic until more options are added
    if direction == "left":
        current_option = 0
    elif direction == "right":
        current_option = 1
