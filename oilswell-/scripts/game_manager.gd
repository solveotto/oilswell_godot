extends Node

# System
var level_instance : PackedScene

# User Interface
@onready var score_label: Label 
@onready var player = $Player

# Stats
@export var current_level = "Level_1"
@export var score:int = 0
@export var lives:int = 3
var oil_count: int = 0
var level_counter: int = 1


# Map coordinates
var row_1_y = 214
var row_2_y = 264
var row_3_y = 312
var row_4_y = 360
var row_5_y = 408
var row_6_y = 456
var monster_left_x = -16
var monster_right_x = 830


func _ready():
	pass


func unload_level():
	if (is_instance_valid(level_instance)):
		level_instance.queue_free()
	level_instance = null


func load_level(level_name : String):
	unload_level()
	var level_path := "res://scenes/Levels/%s.tscn" % level_name
	if (level_path):
		get_tree().change_scene_to_file(level_path)


func add_oil_point():
	score += 10
	score_label.text = str(score)
	oil_count -= 1
	check_level_end()

	print(oil_count)

func check_level_end():
	if oil_count == 0:
		level_counter += 1
		current_level = "Level_%s" % str(level_counter)
		load_level(current_level)
		
