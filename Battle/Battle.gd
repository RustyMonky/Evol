extends Node2D

var mobs = ["slime"]
var mob_to_fight
var mob_node
var mob_sprite
var mob_info

var battle_background

var player_info

var show_info

const MOB_MOVE_SPEED = 200

func _ready():
    battle_background = get_node("BattleControl").get_node("BattleBackground")

    show_info = false

    mob_node = get_node("BattleMob")
    mob_sprite = mob_node.get_node("MobSprite")
    mob_node.set_pos(Vector2(battle_background.get_pos().x - 32, battle_background.get_pos().y + 32))

    # Update in the future to randomize mob selection
    mob_to_fight = mobs[0]
    if mob_to_fight == "slime":
        mob_sprite.set_texture(load("res://Mobs/shadedSlime.tex"))
        global.mob.name = "Shaded Slime"
        global.mob.max_hp = 10
        global.mob.current_hp = 10

    # Add mob info instance
    mob_info = load("res://Battle/BattleInfo.tscn").instance();
    mob_info.get_node("NameLabel").set_pos(Vector2(-140, -128))
    mob_info.get_node("LevelLabel").set_pos(Vector2(-140, -112))
    mob_info.get_node("HpBar").set_pos(Vector2(-140, -96))

    mob_info.max_hp = global.mob.max_hp
    mob_info.current_hp = global.mob.max_hp

    get_node("BattleControl").call_deferred("add_child", mob_info)

    # Add player info instance
    player_info = load("res://Battle/BattleInfo.tscn").instance();

    player_info.get_node("NameLabel").set_pos(Vector2(0, -48))
    player_info.get_node("LevelLabel").set_pos(Vector2(0, -32))
    player_info.get_node("HpBar").set_pos(Vector2(0, -16))

    player_info.max_hp = global.player.max_hp
    player_info.current_hp = global.player.max_hp

    get_node("BattleControl").call_deferred("add_child", player_info)

    set_fixed_process(true)

func _fixed_process(delta):
    if round(mob_node.get_pos().x) < (battle_background.get_size().x  / 2 - 64):
        mob_node.move(Vector2(MOB_MOVE_SPEED * delta, 0))
    elif not show_info:
        show_info = true

    if show_info:
        mob_info.get_node("NameLabel").set_hidden(false)
        mob_info.get_node("LevelLabel").set_hidden(false)
        mob_info.get_node("HpBar").set_hidden(false)

