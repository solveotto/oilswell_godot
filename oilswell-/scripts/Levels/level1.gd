extends Node2D

@onready var score_label = $HUD/ScoreLabel
@onready var enemy_1 = $enemy_1
@onready var player = $Player
@onready var time_stop = $Pickups/TimeStop


const ENEMY_1 = preload("res://scenes/Enemies/enemy_1.tscn")
const ENEMY_3 = preload("res://scenes/Enemies/enemy_3.tscn")
const ENEMY_5 = preload("res://scenes/Enemies/enemy_5.tscn")
const ENEMY_6 = preload("res://scenes/Enemies/enemy_6.tscn")
const ENEMY_8 = preload("res://scenes/Enemies/enemy_8.tscn")
const ENEMY_12 = preload("res://scenes/Enemies/enemy_12.tscn")
const ENEMY_13 = preload("res://scenes/Enemies/enemy_13.tscn")

func _ready():
	GameManager.player = player
	GameManager.timestop_node = time_stop

	GameManager.oil_count = get_tree().get_nodes_in_group("oil_nodes").size()
	GameManager.score_label = score_label
	GameManager.score_label.text = str(GameManager.score)
	
	
	
	# Spawn Monsters. 
	# Inputs: enemy, start_pos, target_pos, spawn_pos, first_spawn_time, spawn_time
	# Row 1 Left
	spawn_monster(ENEMY_8, Vector2(GameManager.map_column_right, GameManager.map_row_1),
					Vector2(GameManager.map_column_left, GameManager.map_row_1),
					Vector2(GameManager.map_column_right, GameManager.map_row_1),
					20, 22)
	# Row 2 Right
	spawn_monster(ENEMY_12, Vector2(GameManager.map_column_left, GameManager.map_row_1),
				Vector2(GameManager.map_column_right, GameManager.map_row_1),
				Vector2(GameManager.map_column_left, GameManager.map_row_1),
				23, 20)
	# Row 2 Left
	spawn_monster(ENEMY_3, Vector2(700, GameManager.map_row_2),
					Vector2(GameManager.map_column_right, GameManager.map_row_2),
					Vector2(GameManager.map_column_left, GameManager.map_row_2),
					0, 35)
	# Row 3 Right
	spawn_monster(ENEMY_5, Vector2(300, GameManager.map_row_3),
					Vector2(GameManager.map_column_left, GameManager.map_row_3),
					Vector2(GameManager.map_column_right, GameManager.map_row_3),
					0, 15)
	# Row 4 Right
	spawn_monster(ENEMY_6, Vector2(80, GameManager.map_row_4),
					Vector2(GameManager.map_column_left, GameManager.map_row_4),
					Vector2(GameManager.map_column_right, GameManager.map_row_4),
					0, 18)
	# Row 5 Right
	spawn_monster(ENEMY_13, Vector2(500, GameManager.map_row_5),
					Vector2(GameManager.map_column_left, GameManager.map_row_5),
					Vector2(GameManager.map_column_right, GameManager.map_row_5),
					0, 3)
	# Row 6 Left
	spawn_monster(ENEMY_1, Vector2(GameManager.map_column_left, GameManager.map_row_6),
					Vector2(GameManager.map_column_right, GameManager.map_row_6),
					Vector2(GameManager.map_column_left, GameManager.map_row_6),
					4, 2)

func spawn_monster(enemy, start_pos, target_pos, spawn_pos, first_spawn_time, spawn_time):
	var instance = enemy.instantiate()
	instance.start_pos = start_pos
	instance.target_pos = target_pos
	instance.spawn_pos = spawn_pos
	instance.first_spawn_time = first_spawn_time
	instance.spawn_time = spawn_time
	add_child(instance) 
	
	
