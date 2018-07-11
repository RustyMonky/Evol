extends Node2D

var battle_menu
var container

var items_grid

var mob_to_fight
var mob_node
var mob_info
var mob_tween

var player_info
var player_sprite

const MOB_MOVE_SPEED = 200

func _ready():
	container = $control/container
	battle_menu = load("res://battle/menu/BattleMenu.tscn").instance()
	container.call_deferred("add_child", battle_menu)
	battle_menu.set_position(Vector2(0, 352)) # Display height - menu frame height

	mob_node = $mob
	mob_tween = $mobTween

	# Randomize mob selection
	var mob_index = gameData.get_random_number(gameData.mob_data.mobs.size())

	mob_to_fight = gameData.mob_data.mobs[mob_index]
	mob_node.set_texture(load(mob_to_fight.sprite))
	mob_node.position = Vector2(0 - mob_node.get_texture().get_size().x, mob_node.get_texture().get_size().y / 2)

	gameData.mob = mob_to_fight
	gameData.mob.current_hp = mob_to_fight.maxHp
	gameData.mob.level = (gameData.get_random_number(gameData.player.level) + 1)
	gameData.mob.stats.defense += gameData.mob.level
	gameData.mob.stats.speed += gameData.mob.level
	gameData.mob.stats.strength += gameData.mob.level
	gameData.mob.statsChanged = {
		defense = 0,
		speed = 0,
		strength = 0
	}
	gameData.mob.xp = mob_to_fight.xp * gameData.mob.level

	# Add mob info instance
	mob_info = load("res://Battle/info/BattleInfo.tscn").instance();
	container.call_deferred("add_child", mob_info)
	mob_info.type = "mob"
	mob_info.max_hp = mob_to_fight.maxHp
	mob_info.current_hp = gameData.mob.current_hp
	mob_info.set_position(Vector2(0, 0))

	battle_menu.mob_info = mob_info

	# Add player info instance
	player_info = load("res://Battle/info/BattleInfo.tscn").instance();
	container.call_deferred("add_child", player_info)
	player_info.type = "player"
	player_info.max_hp = gameData.player.max_hp
	player_info.current_hp = gameData.player.current_hp
	player_info.set_position(Vector2(332, 264))

	battle_menu.player_info = player_info
	player_sprite = $playerBack
	var player_sprite_texture = load(gameData.player.battle_sprite)
	player_sprite.set_texture(player_sprite_texture)

	mob_tween.interpolate_property(mob_node, "position", mob_node.position, Vector2(480 - mob_node.get_texture().get_size().x, mob_node.position.y), 1.5, Tween.TRANS_BACK, Tween.EASE_OUT)
	mob_tween.start()

	items_grid = load("res://items/items.tscn").instance()

	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_accept") && battle_menu.show_items:
		self.add_child(items_grid)

	elif event.is_action_pressed("ui_cancel") && battle_menu.show_items:
		self.remove_child(items_grid)
		items_grid.queue_free()
		battle_menu.show_items = false
