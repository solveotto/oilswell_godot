extends Area2D

signal kill

var tile_size = 16
var start_pos_x = 830
var end_pos_x = -16
var start_pos_y = 214
var animation_speed = 15
var spawn_time = 6

var start_pos = Vector2(GameManager.monster_right_x, GameManager.row_1_y)
var target_pos = Vector2(GameManager.monster_left_x, GameManager.row_1_y)
var speed = 100
var moving = false
var spawning = true

@onready var spawn_timer = $SpawnTimer
@onready var tween = $Tween
@onready var sprite = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(GameManager.monster_right_x, GameManager.row_1_y)
	spawn_timer.connect("timeout", Callable(self, "_on_SpawnTimer_timeout"))
	spawn_timer.start()



func _process(delta):
	if moving:
		position = position.move_toward(target_pos, speed * delta)
		if position == target_pos:
			moving = false  # Stop when reaching the target
			spawning = true
			spawn_timer.wait_time = spawn_time
			position = start_pos
			spawn_timer.wait_time = 20
			spawn_timer.start()



func _on_SpawnTimer_timeout():
	spawning = false
	moving = true


func _on_body_entered(body):
	#print("Collided with: ", body.name)
	if body.name == "Player":
		print("Collided with: ", body.name)
		spawning = true
		moving = false
		position = start_pos
		spawn_timer.wait_time = 10
		spawn_timer.start()
	else:
		emit_signal("kill")
