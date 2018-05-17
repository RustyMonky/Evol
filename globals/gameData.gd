extends Node

var game_state = {
    is_saving = false
}

var player = {
    battle_sprite = "",
    current_hp = 15,
    elemental_type = null,
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
    stats_sprite = "res://Assets/sprites/forms/typeSheet.png",
    sprite_frame = Rect2(0, 0, 32, 32),
    sprite_path = "res://Assets/sprites/forms/typeSheet.png",
    total_mobs_killed = 0,
    xp = 0
}

var mob = {
    current_hp = 10,
    stats = {},
    statsChanged = {
        defense = 0,
        speed = 0,
        strength = 0
    }
}

var xp_required_array = []

func _ready():
    # Populate xp array
    for n in range(1, 101):
        var xp_req = (n * 10) * n
        xp_required_array.append(xp_req)

# Globally accessible function to generate a new random number
func get_random_number(limit):
    randomize()

    if (randi() % int(limit)) == 0:
        return 1

    return (randi() % int(limit))

# Level up function when can be called from anywhere
# TODO - Replace this with player choice -- new move, item, or stat increase
func level_up():
    player.level += 1
    player.current_hp += 2
    player.max_hp += 2
    player.stats.defense += 1
    player.stats.speed += 1
    player.stats.strength += 1

    # Learn moves
    if player.level == 2:
        player.moves.append({
            name = "Buff Up",
            damage = 0,
            desc = "Increases STR",
            stat = {
                strength = 1
            }
        })
    elif player.level == 3:
        player.moves.append({
            name = "Raise Guard",
            damage = 0,
            desc = "Increases DEF",
            stat = {
                defense = 1
            }
        })
    elif player.level == 4:
        player.moves.append({
            name = "Speed Up",
            damage = 0,
            desc = "Increases SPD",
            stat = {
                speed = 1
            }
        })
    elif player.level == 5:
        sceneManager.goto_scene("res://battle/evolution.tscn")