extends Area2D

signal kill

var tile_size = 16
var start_pos: Vector2
var target_pos: Vector2
var spawn_pos: Vector2
var moving = false
var spawn_time: float
var first_spawn_time: float
var collision_handled = false  # Prevents multiple collisions

@onready var spawn_timer = $SpawnTimer
@onready var sprite = $Sprite2D
@onready var collision_shape_2d = $CollisionShape2D


func _ready():
	position = start_pos
	#await get_tree().create_timer(first_spawn_time).timeout
	
	spawn_timer.connect("timeout", Callable(self, "_on_SpawnTimer_timeout"))
	spawn_timer.start(first_spawn_time)
	
	# Connect to timestop signal
	var timestop_node = get_tree().get_nodes_in_group("Timestop")
	for timestop in timestop_node:
		if timestop.has_signal("timestop"):
			timestop.connect("timestop", Callable(self, "_on_timestop"))
	
	GameManager.player.connect("pipe_fully_retracted", Callable(self, "_on_pipe_fully_retracted"))
	

func _process(delta):
	if moving:
		position = position.move_toward(target_pos, GameManager.monster_speed * delta)
		if position == target_pos:
			moving = false  # Stop when reaching the target
			spawn_timer.wait_time = spawn_time
			position = spawn_pos
			var random_spawn_time = randf_range(1,4)
			spawn_timer.wait_time = spawn_time + int(random_spawn_time)
			spawn_timer.start()
	


func _on_body_entered(body):
	

	if collision_handled:
		return  # Ignore extra collisions
	
	if body.name == "Player":
		MusicManager.monster_sound.play()
		GameManager.add_monster_points()
		collision_handled = true
		moving = false
		position = spawn_pos
		spawn_timer.wait_time = spawn_time
		spawn_timer.start()
		
	elif body.name == "PipeBody_TileMap":
		collision_handled = true
		disable_collsion()
		emit_signal("kill")
	
	# Reset collision handling after a short delay
	await get_tree().create_timer(0.1).timeout
	collision_handled = false



func _on_SpawnTimer_timeout():
	moving = true

func disable_collsion():
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		enemy.collision_shape_2d.set_deferred("disabled", true)

func _on_pipe_fully_retracted():
	collision_shape_2d.set_deferred("disabled", false)
