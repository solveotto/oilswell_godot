extends Node2D


# Preloads
const MAIN = preload("res://scenes/Menues/main.tscn")
const NEXT_LEVEL_SCREEN = preload("res://scenes/Menues/next_level_screen.tscn")
const GAME_OVER = preload("res://scenes/Menues/game_over.tscn")
const HIGHSCORE = preload("res://scenes/Menues/highscore.tscn")

@onready var backgorund = $Backgorund

# User Interface
@onready var level_instance : PackedScene
@onready var LIFE_TEXTURE: Texture2D = preload("res://assests/pipe/pipe_right.png")
@onready var score_label: Label 


# Game Stats
@onready var level_counter := 1
@onready var lives := 1
@onready var oil_count := 0

@onready var score := 0
@onready var new_highscore := true
@onready var new_highscore_index: int = 3
@onready var player_initials := "___"
@onready var highscore_max_entries := 10

@onready var player
@onready var timestop_node
@onready var life_icon


# Map coordinates
@onready var map_row_1 = 214
@onready var map_row_2 = 264
@onready var map_row_3 = 312
@onready var map_row_4 = 360
@onready var map_row_5 = 408
@onready var map_row_6 = 456
@onready var map_column_left = -16
@onready var map_column_right = 830


# Monster Data
@onready var monster_speed = 100
@onready var timestop = false


func _ready():
	pass



# LEVEL HANDLING
func load_level(level_name : String):
	unload_level()
	var level_path := "res://scenes/Levels/%s.tscn" % level_name
	
	# Level splash screen
	get_tree().change_scene_to_packed(NEXT_LEVEL_SCREEN)
	MusicManager.next_level_sound.play()
	await get_tree().create_timer(4).timeout
	
	# Check if highscore reached
	
	if (level_path):
		get_tree().change_scene_to_file(level_path)


func unload_level():
	if (is_instance_valid(level_instance)):
		level_instance.queue_free()
	level_instance = null



func loose_life():
	lives -= 1
	
	# Game over
	if lives == 0:
		level_counter = 1
		lives = 3
		add_highscore()
		
		unload_level()
		
		# Show game over screen
		get_tree().change_scene_to_packed(GAME_OVER)
		await get_tree().create_timer(4).timeout
		
		# Load highscore screeen
		get_tree().change_scene_to_packed(HIGHSCORE)


func add_oil_point():
	score += 10
	score_label.text = str(score)
	oil_count -= 1
	check_level_end()

func add_monster_points():
	score += 40
	score_label.text = str(score)


func check_level_end():
	if oil_count == 0:
		level_counter += 1
		var current_level = "Level_%s" % str(level_counter)
		load_level(current_level)


func connect_signal_to_function(_node, _signal, _func):
	# Connect the signal from the Area2D instance
	_node.connect(_signal, Callable(self, _func))


func _on_time_stop():
	monster_speed = 10
	timestop = true
	
	
	# Create timer
	var timer = Timer.new()
	timer.wait_time = 10.0 
	timer.autostart = true
	timer.one_shot = false
	timer.connect("timeout", Callable(self, "_on_timestop_timer_timeout"))
	add_child(timer)  # Add the timer as a child of this node


func _on_timestop_timer_timeout():
	monster_speed = 100
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
	print("save_highscore:", highscores_data)
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
