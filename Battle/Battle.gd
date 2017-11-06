extends Node2D

var mobs = ["slime"]
var mob_to_fight
var mob_node
var mob_sprite

var battle_background

const MOB_MOVE_SPEED = 200

func _ready():
    battle_background = get_node("BattleControl").get_node("BattleBackground")

    mob_node = get_node("BattleMob")
    mob_sprite = mob_node.get_node("MobSprite")
    mob_node.set_pos(Vector2(battle_background.get_pos().x - 32, battle_background.get_pos().y + 32))

    # Update in the future to randomize mob selection
    mob_to_fight = mobs[0]
    if mob_to_fight == "slime":
        mob_sprite.set_texture(load("res://Mobs/shadedSlime.tex"))
        global.mob_name = "Shaded Slime"

    set_fixed_process(true)

func _fixed_process(delta):
    if mob_node.get_pos().x < (battle_background.get_size().x  / 2):
        mob_node.move(Vector2(MOB_MOVE_SPEED * delta, 0))

