extends Node2D

"""
Description:
In this game Oils Well similar to Pac-Man you steer a drilling head that needs to collect all points in the aisles of the level. 
During this, enemies move horizontally on each plane. You can "eat them" with the drilling head, 
but if they touch the pipe the player will lose a life. So if an enemy gets too close to the pipe, 
you need to quickly climb up again. The difficulty is to choose the paths in dependence of your current position, 
so that you have enough time to advance to the deeper layers.

Number of levels:
After finishing the 8 levels they repeat and the enemies get faster each round.
When you have played through all levels three times it gets as fast as in the first round.

Lives:
You start with 3 lives.
Every 10.000 points you get another life.

from https://www.c64-wiki.com/wiki/Oils_Well
""" 


# Preloads
const LIFE_TEXTURE: Texture2D = preload("res://assests/pipe/pipe_right.png")
const MAIN = preload("res://scenes/Menues/main.tscn")
const NEXT_LEVEL_SCREEN = preload("res://scenes/Menues/next_level_screen.tscn")
const GAME_OVER = preload("res://scenes/Menues/game_over.tscn")
const HIGHSCORE = preload("res://scenes/Menues/highscore.tscn")
const CUP_OR_BOMB = [
	preload("res://scenes/Enemies/enemy_cup.tscn"),
	preload("res://scenes/Enemies/enemy_bomb.tscn")
	]

const MAP_COLUMN_LEFT = -32
const MAP_COLUMN_RIGHT = 830

# Map coordinates
const MAP_ROWS = {
	"row_13": {"y_pos": 208, "value": 20},
	"row_14": {"y_pos": 224, "value": 20},
	"row_15": {"y_pos": 240, "value": 30},
	"row_16": {"y_pos": 256, "value": 30},
	"row_17": {"y_pos": 272, "value": 40},
	"row_18": {"y_pos": 288, "value": 40},
	"row_19": {"y_pos": 304, "value": 50},
	"row_20": {"y_pos": 320, "value": 50},
	"row_21": {"y_pos": 336, "value": 60},
	"row_22": {"y_pos": 352, "value": 60},
	"row_23": {"y_pos": 368, "value": 70},
	"row_24": {"y_pos": 384, "value": 70},
	"row_25": {"y_pos": 400, "value": 80},
	"row_26": {"y_pos": 416, "value": 80},
	"row_27": {"y_pos": 432, "value": 90},
	"row_28": {"y_pos": 448, "value": 90},
	"row_29": {"y_pos": 464, "value": 100}
}

# Preloads enemies
const ENEMIES = {
	"enemy_1": preload("res://scenes/Enemies/enemy_1.tscn"),
	"enemy_2": preload("res://scenes/Enemies/enemy_2.tscn"),
	"enemy_3": preload("res://scenes/Enemies/enemy_3.tscn"),
	"enemy_4": preload("res://scenes/Enemies/enemy_4.tscn"),
	"enemy_5": preload("res://scenes/Enemies/enemy_5.tscn"),
	"enemy_6": preload("res://scenes/Enemies/enemy_6.tscn"),
	"enemy_7": preload("res://scenes/Enemies/enemy_7.tscn"),
	"enemy_8": preload("res://scenes/Enemies/enemy_8.tscn"),
	"enemy_9": preload("res://scenes/Enemies/enemy_9.tscn"),
	"enemy_10": preload("res://scenes/Enemies/enemy_10.tscn"),
	"enemy_11": preload("res://scenes/Enemies/enemy_11.tscn"),
	"enemy_12": preload("res://scenes/Enemies/enemy_12.tscn"),
	"enemy_13": preload("res://scenes/Enemies/enemy_13.tscn")
}


@onready var backgorund = $Backgorund
@onready var tile_size = 16

# User Interface
@onready var level_instance : PackedScene
@onready var score_label: Label 


# Game Stats
@onready var player_alive := true # Maby remove
@onready var level_counter := 1
@onready var level_rounds_counter := 1
@onready var life_count := 3
@onready var extra_lives_ctr := 0
@onready var oil_count := 0

# Score
@onready var score := 0
@onready var new_highscore := true
@onready var new_highscore_index: int = 3
@onready var player_initials := "___"
@onready var highscore_max_entries := 10

@onready var player = null
@onready var timestop_node
@onready var life_icon

# Enemies
var monster_speed_timestop = 10
var monster_speed_round_1 = 100
var monster_speed_round_2 = 130
var monster_speed_round_3 = 150
var monster_speed_current_level = monster_speed_round_1
var monster_current_speed = monster_speed_current_level
var timestop = false
var active_cup_bomb = null
var cups_and_bombs_spawning_enabled = false



func _ready():
	enable_cups_and_bombs()
 

# LEVEL HANDLING
func load_level(level_name : String):
	unload_level()
	var level_path := "res://scenes/Levels/%s.tscn" % level_name
	
	
	# Level splash screen
	get_tree().change_scene_to_packed(NEXT_LEVEL_SCREEN)
	MusicManager.next_level_sound.play()
	await get_tree().create_timer(4).timeout


	if (level_path):
		get_tree().change_scene_to_file(level_path)


func unload_level():
	if (is_instance_valid(level_instance)):
		level_instance.queue_free()
	level_instance = null
	disable_cups_and_bombs()


# Life and GameOver
func loose_life():
	life_count -= 1
	
	# Game over
	if life_count == 0:
		level_counter = 1
		level_rounds_counter = 0
		life_count = 3
		add_highscore()
		
		unload_level()
		
		# Show game over screen
		get_tree().change_scene_to_packed(GAME_OVER)
		await get_tree().create_timer(4).timeout
		
		# Load highscore screeen
		get_tree().change_scene_to_packed(HIGHSCORE)
	else:
		player_alive = true


func level_logic():
	if oil_count == 0:
		# Start level 1 after levl 8 is finished. Speed incease each time.
		# Repeates the all levels 3 times then speed is set to original speed.
		if level_counter == 2: # The last level
			if level_rounds_counter == 1:
				monster_speed_current_level = monster_speed_round_2
				level_rounds_counter += 1
			elif level_rounds_counter == 2:
				monster_speed_current_level = monster_speed_round_3
				level_rounds_counter += 1
			else: # Resets speed after three rounds
				monster_speed_current_level = monster_speed_round_1
				level_rounds_counter = 1
			
			
			level_counter = 1
			monster_current_speed = monster_speed_current_level
			
		else:		
			level_counter += 1
		
		print("monster_speed_current_level = ", monster_speed_current_level, " level_counter = ", level_counter, " level_rounds_counter = ", level_rounds_counter)
		var current_level = "Level_%s" % str(level_counter)
		load_level(current_level)


func extra_life_mangaer(score_to_add: int):
	extra_lives_ctr += score_to_add
	
	if extra_lives_ctr > 100 and life_count >= 8:
		life_count += 1
		extra_lives_ctr = 0
		life_icon.update_lives()
	


# SCORE HANDELING
func add_oil_point():
	score += 10
	score_label.text = str(score)
	oil_count -= 1
	
	extra_life_mangaer(10)
	level_logic()
	

func add_monster_points(name):
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		if enemy.name == name:
			for row in MAP_ROWS.values():
				if row["y_pos"] == enemy.start_pos.y:
					score += row["value"]
					extra_life_mangaer(row["value"])
	
	# Updates score label
	score_label.text = str(score)


func add_cup_points():
	score += 1000
	extra_life_mangaer(1000)
	score_label.text = str(score)
	


# SIGNALS
func connect_signal_to_function(_node, _signal, _func):
	# Connect the signal from the Area2D instance
	_node.connect(_signal, Callable(self, _func))

func _on_time_stop():
	monster_current_speed = monster_speed_timestop
	timestop = true

	# Create timer
	var timer = Timer.new()
	timer.wait_time = 10.0 
	timer.autostart = true
	timer.one_shot = false
	timer.connect("timeout", Callable(self, "_on_timestop_timer_timeout"))
	add_child(timer)  # Add the timer as a child of this node


func _on_timestop_timer_timeout():
	monster_current_speed = monster_speed_current_level
	timestop = false


### HIGHSCORE ###
 
func load_highscores() -> Array:
	var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		if content.is_empty():
			return [] # default empty list
			
		# Create an instance of JSON and parse the content
		var json = JSON.new()
		var parse_result = json.parse(content)

		# Check if parsing was successful
		if parse_result == OK:
			if json.data is Array:  # Ensure the data is the correct type
				return json.data
			else:
				print("Highscore file is not in the expected format.")
				return []  # Default value
		else:
			print("Failed to parse highscore file. Error code: %d" % parse_result)
			return []  # Default value
	else:
		print("No highscore file found.")
		return []  # Default value


func add_highscore() -> void:
	var highscores = load_highscores()
	var new_entry = {"score": GameManager.score, "initials": player_initials}

	# Add new entry to the list if it qualifies
	if highscores.size() < highscore_max_entries or score > highscores[-1]["score"]:
		highscores.append(new_entry)
		
		# Sort in decendig order by score
		highscores.sort_custom(sort_ascending)
		
		# Trim list to top 10 scores
		if highscores.size() > highscore_max_entries:
			highscores = highscores.slice(0, highscore_max_entries)
		
		# Save the update
		save_highscores(highscores)
		
		# Stores index for typing intitals in highscore screen
		new_highscore_index = highscores.find(new_entry)
		new_highscore = true
	else:
		# For highscore screen
		new_highscore = false


# Save highscore (score and initials) to a file
func save_highscores(highscores_data: Array) -> void:
	var file = FileAccess.open("user://save_game.dat", FileAccess.ModeFlags.WRITE)
	if file:
		file.store_string(JSON.stringify(highscores_data))
		file.close()
	else:
		print("Failed to save highscore.")


# Custom sorting function to sort scores in descending order
func _compare_scores(a: Dictionary, b: Dictionary) -> int:
	#print("Comparing %s with %s" % [a, b])  # Debug the comparisons
	return b["score"] - a["score"]

func sort_ascending(a, b):
	if a["score"] > b["score"]:
		return true
	return false


func clear_highscore_file():
	var file = FileAccess.open("user://save_game.dat", FileAccess.ModeFlags.WRITE)
	if file:
		file.store_string("")  # Write an empty string to clear the file
		file.close()
		print("Highscore file cleared.")
	else:
		print("Failed to open highscore file for clearing.")





# Spawn Cups and Bombs randomly
func enable_cups_and_bombs():
	cups_and_bombs_spawning_enabled = true
	schedule_next_cup_or_bomb_spawn()


func disable_cups_and_bombs():
	cups_and_bombs_spawning_enabled = false


func schedule_next_cup_or_bomb_spawn():
	if not cups_and_bombs_spawning_enabled:
		return
	get_tree().create_timer(randi_range(15, 45)).timeout.connect(try_spawn_cup_or_bomb)


func try_spawn_cup_or_bomb():
	if not cups_and_bombs_spawning_enabled or active_cup_bomb == true:
		schedule_next_cup_or_bomb_spawn()
		return
	GameManager.active_cup_bomb = true
	spawn_cups_and_bombs()
	schedule_next_cup_or_bomb_spawn()


func spawn_cups_and_bombs():
	# Ensure randomness
	randomize()
	
	# Determin if cup or bomb is spawned
	var cup_bomb_instance = CUP_OR_BOMB[randi() % CUP_OR_BOMB.size()].instantiate()
	
	# Connects the kill signal from the bomb to the player
	if cup_bomb_instance:
		cup_bomb_instance.connect("kill", Callable(player, "_on_death"))
	
	# Adds instance to curren scene
	add_child(cup_bomb_instance)
	
	
