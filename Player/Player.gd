extends KinematicBody2D

var direction = Vector2()
var grid
var player_sprite
var speed = 0
var sprite_texture
var target_pos = Vector2()
var target_direction = Vector2()
var type
var velocity = Vector2()

# Booleans
var is_moving = false

# Direction Constants
const TOP = Vector2(0, -1)
const DOWN = Vector2(0, 1)
const LEFT = Vector2(-1, 0)
const RIGHT = Vector2(1, 0)

const MAX_SPEED = 100

func _ready():
    grid = get_parent()
    type = grid.PLAYER

    player_sprite = $sprite

    sprite_texture = load(gameData.player.sprite_path)
    player_sprite.set_texture(sprite_texture)
    player_sprite.set_region_rect(gameData.player.sprite_frame)

    self.position = gameData.player.pos

    set_physics_process(true)

    set_process_input(true)

func _physics_process(delta):
    # Movement
    direction = Vector2()

    if Input.is_action_pressed("player_up") or Input.is_action_pressed("ui_up"):
        direction = TOP
        player_sprite.set_region_rect(Rect2(32, 0, 32, 32))
        gameData.player.sprite_frame = 1

    elif Input.is_action_pressed("player_down") or Input.is_action_pressed("ui_down"):
        direction = DOWN
        player_sprite.set_region_rect(Rect2(0, 0, 32, 32))
        gameData.player.sprite_frame = 0

    elif Input.is_action_pressed("player_left") or Input.is_action_pressed("ui_left"):
        direction = LEFT
        player_sprite.set_region_rect(Rect2(96, 0, 32, 32))
        gameData.player.sprite_frame = 3

    elif Input.is_action_pressed("player_right") or Input.is_action_pressed("ui_right"):
        direction = RIGHT
        player_sprite.set_region_rect(Rect2(64, 0, 32, 32))
        gameData.player.sprite_frame = 2

    if not is_moving and direction != Vector2():
        target_direction = direction

        if grid.is_cell_vacant(self.position, target_direction):
            target_pos = grid.update_child_pos(self)
            is_moving = true

    elif is_moving:
        speed = MAX_SPEED
        velocity = speed * target_direction * delta
        move_and_collide(velocity)

        var distance_to_target = Vector2(abs(target_pos.x - self.position.x), abs(target_pos.y - self.position.y))
        gameData.player.pos = self.position

        if abs(velocity.x) > distance_to_target.x:
            velocity.x = distance_to_target.x * target_direction.x
            is_moving = false

        elif abs(velocity.y) > distance_to_target.y:
            velocity.y = distance_to_target.y * target_direction.y
            is_moving = false

func _input(event):
    if event.is_action_pressed("player_pause"):
        sceneManager.goto_scene("res://Player/pause/PauseMenu.tscn")
