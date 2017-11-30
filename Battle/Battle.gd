extends Node2D

var battle_background
var battle_menu

var mobs = ["slime"]
var mob_to_fight
var mob_node
var mob_sprite
var mob_info

var player_info
var player_sprite

var show_info

const MOB_MOVE_SPEED = 200

func _ready():
    battle_background = get_node("BattleControl").get_node("BattleBackground")
    battle_menu = get_node("BattleControl").get_node("BattleMenu")

    show_info = false

    mob_node = get_node("BattleMob")
    mob_sprite = mob_node.get_node("MobSprite")
    mob_node.set_pos(Vector2(battle_background.get_pos().x - 32, battle_background.get_pos().y + 48))

    # Update in the future to randomize mob selection
    mob_to_fight = mobs[0]
    if mob_to_fight == "slime":
        mob_sprite.set_texture(load("res://Assets/Mobs/slime.png"))
        global.mob.name = "Slime"
        global.mob.max_hp = 10
        global.mob.current_hp = 10

    # Add mob info instance
    mob_info = preload("res://Battle/BattleInfo.tscn").instance();
    mob_info.type = "mob"
    mob_info.get_node("NameLabel").set_pos(Vector2(16, 16))
    mob_info.get_node("LevelLabel").set_pos(Vector2(16, 32))
    mob_info.get_node("HpBar").set_pos(Vector2(16, 48))

    mob_info.max_hp = global.mob.max_hp
    mob_info.current_hp = global.mob.max_hp

    get_node("BattleControl").call_deferred("add_child", mob_info)
    battle_menu.mob_info = mob_info

    # Add player info instance
    player_info = preload("res://Battle/BattleInfo.tscn").instance();

    player_info.get_node("NameLabel").set_pos(Vector2(144, 160))
    player_info.type = "player"
    player_info.get_node("LevelLabel").set_pos(Vector2(144, 176))
    player_info.get_node("HpBar").set_pos(Vector2(144, 192))

    player_info.max_hp = global.player.max_hp
    player_info.current_hp = global.player.current_hp

    get_node("BattleControl").call_deferred("add_child", player_info)
    battle_menu.player_info = player_info

    player_sprite = battle_background.get_node("BattlePlayerSprite")
    var player_texture = load(global.player.battle_sprite)
    player_sprite.set_texture(player_texture)

    set_fixed_process(true)

func _fixed_process(delta):
    if round(mob_node.get_pos().x) < (battle_background.get_size().x - 64):
        mob_node.move(Vector2(MOB_MOVE_SPEED * delta, 0))
    elif not show_info:
        show_info = true

    if show_info:
        mob_info.get_node("NameLabel").set_hidden(false)
        mob_info.get_node("LevelLabel").set_hidden(false)
        mob_info.get_node("HpBar").set_hidden(false)

        player_info.get_node("NameLabel").set_hidden(false)
        player_info.get_node("LevelLabel").set_hidden(false)
        player_info.get_node("HpBar").set_hidden(false)

