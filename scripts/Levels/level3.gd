# Level 3

extends Node2D

@onready var score_label = $HUD/ScoreLabel
@onready var player = $Player
@onready var time_stop = $Pickups/TimeStop


# Sets active rows on current level
const MAP_ROWS = [
	GameManager.MAP_ROWS["row_13"],
	GameManager.MAP_ROWS["row_16"],
	GameManager.MAP_ROWS["row_19"],
	GameManager.MAP_ROWS["row_22"],
	GameManager.MAP_ROWS["row_24"],
	GameManager.MAP_ROWS["row_26"],
	GameManager.MAP_ROWS["row_28"],
]

var map_column_left = -32
var map_column_right = 830

func _ready():
	#GameManager.player = player
	GameManager.timestop_node = time_stop
	GameManager.life_icon = $HUD/Life
	GameManager.oil_count = get_tree().get_nodes_in_group("oil_nodes").size()
	GameManager.score_label = score_label
	GameManager.score_label.text = str(GameManager.score)
	
	
	# Start spawning bombs and cups
	GameManager.enable_cups_and_bombs()
	
		# Define enemy spawn data in an array.
	# Each dictionary holds all the parameters needed to spawn an enemy.
	var spawn_data = [
		# Enemies on screen when level starts
		{
			"enemy": GameManager.ENEMIES["enemy_7"],
			"start_pos": Vector2(14 * GameManager.tile_size, MAP_ROWS[5]["y_pos"]),
			"target_pos": Vector2(GameManager.MAP_COLUMN_LEFT, MAP_ROWS[5]["y_pos"]),
			"spawn_pos": Vector2(GameManager.MAP_COLUMN_RIGHT, MAP_ROWS[5]["y_pos"]),
			"first_spawn_time": 0,
			"spawn_time": 20
		},
		{
			"enemy": GameManager.ENEMIES["enemy_3"],
			"start_pos": Vector2(5 * GameManager.tile_size, MAP_ROWS[3]["y_pos"]),
			"target_pos": Vector2(GameManager.MAP_COLUMN_LEFT, MAP_ROWS[3]["y_pos"]),
			"spawn_pos": Vector2(GameManager.MAP_COLUMN_RIGHT, MAP_ROWS[3]["y_pos"]),
			"first_spawn_time": 0,
			"spawn_time": 22
		},
		# Enemies that spawn after that
		
	]

	# Loop through the spawn_data array to spawn each enemy.
	for spawn in spawn_data:
		spawn_monster(
			spawn["enemy"],
			spawn["start_pos"],
			spawn["target_pos"],
			spawn["spawn_pos"],
			spawn["first_spawn_time"],
			spawn["spawn_time"]
		)



func spawn_monster(enemy, start_pos, target_pos, spawn_pos, first_spawn_time, spawn_time):
	var instance = enemy.instantiate()
	instance.start_pos = start_pos
	instance.target_pos = target_pos
	instance.spawn_pos = spawn_pos
	instance.first_spawn_time = first_spawn_time
	instance.spawn_time = spawn_time
	
	add_child(instance) 
