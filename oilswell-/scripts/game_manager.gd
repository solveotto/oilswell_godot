extends Node2D

# System
var level_instance : PackedScene

const MAIN = preload("res://scenes/main.tscn")
const LEVEL_1 = preload("res://scenes/Levels/Level_1.tscn")
const NEXT_LEVEL_SCREEN = preload("res://next_level_screen.tscn")

# User Interface
@onready var score_label: Label 
@onready var life_texture: Texture2D = preload("res://assests/pipe/pipe_right.png")
# Stats
@export var current_level = "Level_1"
@export var score:int = 0
@export var lives:int = 1
var oil_count: int = 0
var level_counter: int = 2

var player
var timestop_node
var life_icon


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



func unload_level():
	if (is_instance_valid(level_instance)):
		level_instance.queue_free()
	level_instance = null


func load_level(level_name : String):
	unload_level()
	var level_path := "res://scenes/Levels/%s.tscn" % level_name
	
	# Level splash screen
	get_tree().change_scene_to_file("res://next_level_screen.tscn")
	await get_tree().create_timer(3).timeout
	
	if (level_path):
		get_tree().change_scene_to_file(level_path)


func loose_life():
	lives -= 1
	print("Current lives: ", lives)
	
	# Game over
	if lives == 0:
		print("Game Over!")
		level_counter = 1
		lives = 3
		unload_level()
		get_tree().change_scene_to_packed(MAIN)
		
		

func add_oil_point():
	score += 10
	score_label.text = str(score)
	oil_count -= 1
	check_level_end()


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
