extends KinematicBody2D

var direction = Vector2()
var speed = 0
var velocity = 0

const TOP = Vector2(0, -1)
const DOWN = Vector2(0, 1)
const LEFT = Vector2(-1, 0)
const RIGHT = Vector2(1, 0)

const MAX_SPEED = 200

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)

func _fixed_process(delta):
	# Movement
	var is_moving = Input.is_action_pressed("player_moving")

	if is_moving:
		speed = MAX_SPEED
		if Input.is_action_pressed("player_up"):
			direction = TOP
			get_node("PlayerSprite").set_frame(1)
		elif Input.is_action_pressed("player_down"):
			direction = DOWN
			get_node("PlayerSprite").set_frame(0)
		elif Input.is_action_pressed("player_left"):
			direction = LEFT
			get_node("PlayerSprite").set_frame(3)
		elif Input.is_action_pressed("player_right"):
			direction = RIGHT
			get_node("PlayerSprite").set_frame(2)
	else:
		speed = 0
	
	velocity = speed * direction * delta
	move(velocity)