extends KinematicBody2D

var camera
var direction = Vector2()
var grid
var speed = 0
var type
var velocity = Vector2()

var is_moving = false
var is_paused = false

var pause_menu

var target_pos = Vector2()
var target_direction = Vector2()

const TOP = Vector2(0, -1)
const DOWN = Vector2(0, 1)
const LEFT = Vector2(-1, 0)
const RIGHT = Vector2(1, 0)

const MAX_SPEED = 100

func _ready():
    grid = get_parent()
    type = grid.PLAYER

    camera = get_node("PlayerCamera")

    pause_menu = preload("res://Player/PauseMenu.tscn").instance()
    pause_menu.set_hidden(true)
    get_tree().get_root().call_deferred("add_child", pause_menu)

    set_fixed_process(true)

    set_process_input(true)

func _fixed_process(delta):
    # Movement
    direction = Vector2()

    # Only pursue movement if the player is not paused
    if not is_paused:
        if Input.is_action_pressed("player_up"):
            direction = TOP
            get_node("PlayerSprite").set_frame(1)
            global.player.sprite_frame = 1
        elif Input.is_action_pressed("player_down"):
            direction = DOWN
            get_node("PlayerSprite").set_frame(0)
            global.player.sprite_frame = 0
        elif Input.is_action_pressed("player_left"):
            direction = LEFT
            get_node("PlayerSprite").set_frame(3)
            global.player.sprite_frame = 3
        elif Input.is_action_pressed("player_right"):
            direction = RIGHT
            get_node("PlayerSprite").set_frame(2)
            global.player.sprite_frame = 2

        if not is_moving and direction != Vector2():
            target_direction = direction
            if grid.is_cell_vacant(get_pos(), target_direction):
                target_pos = grid.update_child_pos(self)
                is_moving = true
        elif is_moving:
            speed = MAX_SPEED
            velocity = speed * target_direction * delta
            move(velocity)

            var pos = get_pos()
            var distance_to_target = Vector2(abs(target_pos.x - pos.x), abs(target_pos.y - pos.y))
            global.player.pos = pos

            if abs(velocity.x) > distance_to_target.x:
                velocity.x = distance_to_target.x * target_direction.x
                is_moving = false
            elif abs(velocity.y) > distance_to_target.y:
                velocity.y = distance_to_target.y * target_direction.y
                is_moving = false

func _input(event):

    if event.is_action_pressed("player_pause"):

        if not is_paused:
            is_paused = true
            var cam_pos = camera.get_camera_pos()
            var pause_pos = Vector2(floor(cam_pos.x) + pause_menu.get_size().x/2, floor(cam_pos.y) - 100)
            pause_menu.set_pos(pause_pos)

            pause_menu.set_hidden(false)
        else:
            pause_menu.set_hidden(true)
            is_paused = false
