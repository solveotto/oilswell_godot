extends Node

# System
var level_instance : PackedScene

# User Interface
@onready var score_label: Label 
	
# Stats
@export var current_level = "Level_1"
@export var score:int = 0
@export var lives:int = 3
var oil_count: int = 0
var level_counter: int = 1


# Map coordinates
var map_row_1 = 214
var map_row_2 = 264
var map_row_3 = 312
var map_row_4 = 360
var map_row_5 = 408
var map_row_6 = 456
var map_column_left = -16
var map_column_right = 830


# Monster Data
var monster_speed = 100
var timestop = false


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

	#print(oil_count)

func check_level_end():
	if oil_count == 0:
		level_counter += 1
		current_level = "Level_%s" % str(level_counter)
		load_level(current_level)
		

func reload_level():
	pass
	

func connect_signal_to_function(_node, _signal, _func):
	# Connect the signal from the Area2D instance
	_node.connect(_signal, Callable(self, _func))

func _on_time_stop():
	print("TIMESTOP")

	monster_speed = 10
	timestop = true
	
	var timer = Timer.new()
	timer.wait_time = 10.0 
	timer.autostart = true
	timer.one_shot = false
	timer.connect("timeout", Callable(self, "_on_timestop_timer_timeout"))
	add_child(timer)  # Add the timer as a child of this node

func _on_timestop_timer_timeout():
	monster_speed = 100
	timestop = false
