extends Area2D

signal kill

var tile_size = 16

#var start_pos = Vector2(GameManager.monster_right_x, GameManager.row_1_y)
#var target_pos = Vector2(GameManager.monster_left_x, GameManager.row_1_y)



var start_pos: Vector2
var target_pos: Vector2
var moving = false
var spawning = true
var spawn_time: int
var spawn_pos: Vector2
var initial_spawn_time: int
var first_spawn_time: float
var collision_handled = false  # Prevents multiple collisions


@onready var timestop_timer = $TimeStopTimer
@onready var spawn_timer = $SpawnTimer
@onready var sprite = $Sprite2D
@onready var collision_shape_2d = $CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready():
	position = start_pos
	initial_spawn_time = spawn_time
	await get_tree().create_timer(first_spawn_time).timeout
	spawn_timer.connect("timeout", Callable(self, "_on_SpawnTimer_timeout"))
	spawn_timer.start()
	
	# Connect to timestop signal
	var timestop_node = get_tree().get_nodes_in_group("Timestop")
	for timestop in timestop_node:
		if timestop.has_signal("timestop"):
			timestop.connect("timestop", Callable(self, "_on_timestop"))

func _process(delta):
	if moving:
		position = position.move_toward(target_pos, GameManager.monster_speed * delta)
		if position == target_pos:
			moving = false  # Stop when reaching the target
			spawning = true
			spawn_timer.wait_time = spawn_time
			position = spawn_pos
			var random_spawn_time = randf_range(1,4)
			spawn_timer.wait_time = spawn_time + int(random_spawn_time)
			spawn_timer.start()
	
	### FUNKER DÅRLIG
	if GameManager.timestop == true:
		spawn_time = 999
	elif GameManager.timestop == false:
		spawn_time = initial_spawn_time
	

func _on_SpawnTimer_timeout():
	spawning = false
	moving = true


func _on_body_entered(body):
	if collision_handled:
		return  # Ignore extra collisions
	
	if body.name == "Player":
		collision_handled = true
		moving = false
		spawning = true
		position = spawn_pos
		spawn_timer.wait_time = spawn_time
		spawn_timer.start()
		
	elif body.name == "PipeBody_TileMap":
		collision_handled = true
		emit_signal("kill")
	
	# Reset collision handling after a short delay
	await get_tree().create_timer(0.1).timeout
	collision_handled = false
