extends Node2D

@onready var score_label = $HUD/ScoreLabel
@onready var enemy_1 = $enemy_1

const ENEMY_1 = preload("res://scenes/Enemies/enemy_1.tscn")
const ENEMY_8 = preload("res://scenes/Enemies/enemy_8.tscn")

func _ready():
	GameManager.oil_count = get_tree().get_nodes_in_group("oil_nodes").size()
	GameManager.score_label = score_label
	GameManager.score_label.text = str(GameManager.score)
	
	# Monster on first row from the right
	spawn_monster(ENEMY_8, Vector2(GameManager.monster_right_x, GameManager.row_2_y),
					Vector2(GameManager.monster_left_x, GameManager.row_2_y),
					15, 15)
	spawn_monster(ENEMY_1, Vector2(GameManager.monster_left_x, GameManager.row_6_y),
					Vector2(GameManager.monster_right_x, GameManager.row_6_y),
					1, 15)


func spawn_monster(enemy, start_pos, target_pos, first_spawn_time, spawn_time):
	var instance = enemy.instantiate()
	instance.start_pos = start_pos
	instance.target_pos = target_pos
	instance.first_spawn_time = first_spawn_time
	instance.spawn_time = spawn_time
	add_child(instance) 
	
	
