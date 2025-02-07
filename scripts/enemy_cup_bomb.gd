extends Area2D

signal kill

@onready var spawn_timer = $SpawnTimer
@onready var sprite_2d = $Sprite2D
@onready var collision_shape_2d = $CollisionShape2D

var start_pos: Vector2
var target_pos: Vector2



var colors = [
	Color.WHITE_SMOKE,   
	Color.SADDLE_BROWN,   
	Color.STEEL_BLUE,   
	Color.SEA_GREEN,
	Color.MEDIUM_PURPLE,
	Color.BLUE,
	Color.YELLOW
	]
# The current color index and how long (in seconds) each color is displayed.
var current_index = 0
var cycle_time = 0.06  # Change color every 0.1 seconds (adjust as needed)
var elapsed_time = 0.0

var speed := 100


# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.active_cup_bomb = true
	add_to_group("Enemies")
	print("Cup Bomb spawned")
	
	var random_left_right = randi_range(0,1)
	var random_row = GameManager.map_rows[randi_range(0, 5)]["y_pos"]
	
	if random_left_right == 0:
		start_pos = Vector2(GameManager.map_column_left, random_row)
		target_pos = Vector2(GameManager.map_column_right, random_row)
	else:
		start_pos = Vector2(GameManager.map_column_right, random_row)
		target_pos = Vector2(GameManager.map_column_left, random_row)
	
	position = start_pos



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	elapsed_time += delta
	if elapsed_time >= cycle_time:
		elapsed_time = 0.0
		# Cycle to the next color.
		current_index = (current_index + 1) % colors.size()
		modulate = colors[current_index]
		
	position = position.move_toward(target_pos, speed * delta)
	if position == target_pos:
		remove_from_group("Enemies")
		queue_free()
		GameManager.active_cup_bomb = false

	

func _on_body_entered(body):
	if body.name == "Player":
		if self.name == "enemy_cup":
			remove_from_group("Enemies")
			queue_free()
			GameManager.active_cup_bomb = false
			GameManager.add_cup_points()
		else:
			emit_signal("kill")
			remove_from_group("Enemies")
			queue_free()
			GameManager.active_cup_bomb = false
