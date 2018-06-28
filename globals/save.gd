extends Node

const SAVE_PATH = "res://save.json"

func _ready():
    load_game()

func save_game():
    var save_dictionary = {
        player = {
            battle_sprite = gameData.player.battle_sprite,
            current_hp = gameData.player.current_hp,
            elemental_type = gameData.player.elemental_type,
            form = gameData.player.form,
            level = gameData.player.level,
            max_hp = gameData.player.max_hp,
            moves = gameData.player.moves,
            moves_known = gameData.player.moves_known,
            pos = {
                x = gameData.player.pos.x,
                y = gameData.player.pos.y
            },
            sprite_path = gameData.player.sprite_path,
            sprite_frame = {
                x = gameData.player.sprite_frame.position.x,
                y = gameData.player.sprite_frame.position.y,
                w = gameData.player.sprite_frame.size.x,
                h = gameData.player.sprite_frame.size.y
            },
            stats = gameData.player.stats,
            stats_sprite = gameData.player.stats_sprite,
            total_mobs_killed = gameData.player.total_mobs_killed,
            xp = gameData.player.xp

        }
    }

    var save_file = File.new()
    save_file.open(SAVE_PATH, File.WRITE)
    save_file.store_line(to_json(save_dictionary))
    save_file.close()

func load_game():
    var save_file = File.new()
    var data

    if not save_file.file_exists(SAVE_PATH):
        return false

    save_file.open(SAVE_PATH, File.READ)
    data = parse_json(save_file.get_as_text())

    if data == null:
        return false

    var saved = data["player"]

    gameData.player.battle_sprite = saved["battle_sprite"]
    gameData.player.current_hp = saved["current_hp"]
    gameData.player.elemental_type = saved["elemental_type"]
    gameData.player.form = saved["form"]
    gameData.player.level = saved["level"]
    gameData.player.max_hp = saved["max_hp"]
    gameData.player.moves = saved["moves"]
    gameData.player.moves_known = saved["moves_known"]
    gameData.player.pos = Vector2(saved["pos"]["x"], saved["pos"]["y"])
    gameData.player.sprite_path = saved["sprite_path"]
    gameData.player.sprite_frame = Rect2(saved["sprite_frame"]["x"], saved["sprite_frame"]["y"], saved["sprite_frame"]["w"], saved["sprite_frame"]["h"])
    gameData.player.stats = saved["stats"]
    gameData.player.stats_sprite = saved["stats_sprite"]
    gameData.player.total_mobs_killed = saved["total_mobs_killed"]
    gameData.player.xp = saved["xp"]

    return true
