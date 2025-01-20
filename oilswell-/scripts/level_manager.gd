extends Node2D

@onready var score_label = $HUD/ScoreLabel
@onready var enemy_1 = $enemy_1

const ENEMY_8 = preload("res://scenes/Enemies/enemy_8.tscn")


func _ready():
	GameManager.oil_count = get_tree().get_nodes_in_group("oil_nodes").size()
	GameManager.score_label = score_label
	GameManager.score_label.text = str(GameManager.score)
	
	


func _process(delta):
	if !has_node("enemy_8"):
		pass
		
		
	if get_tree().root.has_node("enemy_8"):
		print("Child scene is active in the main tree!")

func spawn_monster(enemy):
	var instance = enemy.instantiate()
	#instance.global_position = pos
	add_child(instance) 
	
	
