extends Node

var current_scene = null

var game_state = {
    is_battling = false,
    is_paused = false,
    is_saving = false
}

var player = {
    battle_sprite = "res://Assets/Battle/baseBattleSprite.tex",
    current_hp = 15,
    level = 1,
    max_hp = 15,
    moves = [
        { name = 'Rush', damage = 3, desc = "Charge at an enemy" }
    ],
    pos = Vector2(200, 200),
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
    stats_sprite = "res://Assets/GUI/statsBaseSprite.png",
    sprite_frame = 0,
    sprite_path = "res://Player/baseEvolSheet.tex",
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
    var root = get_tree().get_root()
    current_scene = root.get_child(root.get_child_count() - 1)

    # Populate xp array
    for n in range(1, 101):
        var xp_req = (n * 10) * n
        xp_required_array.append(xp_req)

func goto_scene(path):
    # This function will usually be called from a signal callback,
    # or some other function from the running scene.
    # Deleting the current scene at this point might be
    # a bad idea, because it may be inside of a callback or function of it.
    # The worst case will be a crash or unexpected behavior.

    # The way around this is deferring the load to a later time, when
    # it is ensured that no code from the current scene is running:

    call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
    # Immediately free the current scene,
    # there is no risk here.
    current_scene.free()

    # Load new scene
    var s = ResourceLoader.load(path)

    # Instance the new scene
    current_scene = s.instance()

    # Add it to the active scene, as child of root
    get_tree().get_root().add_child(current_scene)

    # optional, to make it compatible with the SceneTree.change_scene() API
    get_tree().set_current_scene(current_scene)

# Globally accessible function to generate a new random number
func get_random_number(limit):
    randomize()
    if (randi() % int(limit)) == 0:
        return 1
    return (randi() % int(limit))

# Level up function when can be called from anywhere
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
        game_state.is_battling = false;
        goto_scene("res://Battle/Evolution.tscn")