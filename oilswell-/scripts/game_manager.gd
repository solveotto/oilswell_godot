extends Node2D


# Preloads
const MAIN = preload("res://scenes/Menues/main.tscn")
const NEXT_LEVEL_SCREEN = preload("res://scenes/Menues/next_level_screen.tscn")
const GAME_OVER = preload("res://scenes/Menues/game_over.tscn")
const HIGHSCORE = preload("res://scenes/Menues/highscore.tscn")

# Cups and bombs
const CUP_OR_BOMB = [
	preload("res://scenes/Enemies/enemy_cup.tscn"),
	preload("res://scenes/Enemies/enemy_bomb.tscn")]


@onready var backgorund = $Backgorund

# User Interface
@onready var level_instance : PackedScene
@onready var LIFE_TEXTURE: Texture2D = preload("res://assests/pipe/pipe_right.png")
@onready var score_label: Label 


# Game Stats
@onready var player_alive := true
@onready var level_counter := 1
@onready var life_count := 3
@onready var extra_lives_ctr := 0
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
@onready var map_rows = [
	{"y_pos": 214, "value": 20},
	{"y_pos": 264, "value": 40},
	{"y_pos": 312, "value": 50},
	{"y_pos": 360, "value": 60},
	{"y_pos": 408, "value": 70},
	{"y_pos": 456, "value": 80}
]

@onready var map_column_left = -16
@onready var map_column_right = 830


# Monster Data
@onready var monster_speed = 100
@onready var timestop = false
var active_cup_bomb = null
var spawning_enabled = false


func _ready():
	print("SceneTree",SceneTree)
	enable_spawning()



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
	life_count -= 1
	
	# Game over
	if life_count == 0:
		level_counter = 1
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


func check_level_end():
	if oil_count == 0:
		level_counter += 1
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
	check_level_end()
	
	

func add_monster_points(name):
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		if enemy.name == name:
			for row in map_rows:
				if row["y_pos"] == enemy.start_pos.y:
					score += row["value"]
					extra_life_mangaer(row["value"])
	
	# Updates score label
	score_label.text = str(score)
	


# SIGNALS
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





# Spawn Cups and Bombs randomly


func enable_spawning():
	spawning_enabled = true
	schedule_next_spawn()

func disable_spawning():
	spawning_enabled = false

func schedule_next_spawn():
	if not spawning_enabled:
		return
		
	var random_time = randi_range(1, 50)
	get_tree().create_timer(random_time).timeout.connect(try_spawn_monster)

func try_spawn_monster():
	print("Trying to spawn")
	if not spawning_enabled or active_cup_bomb != null:
		schedule_next_spawn()
		return
	spawn_cups_and_bombs()
	schedule_next_spawn()


func spawn_cups_and_bombs():
	print("SPAWN CUP OR BOMB")
	randomize()
	
	var instance = CUP_OR_BOMB[randi() % CUP_OR_BOMB.size()].instantiate()
	#var random_spawn_time = randi_range(2, 10)
	
	var target_pos: Vector2
	var random_row = GameManager.map_rows[randi_range(0, 5)]["y_pos"]
	
	
	var random_start_pos: int
	var random_left_right = randi_range(0,1)
	if random_left_right == 0:
		random_start_pos = GameManager.map_column_left
		target_pos = Vector2(GameManager.map_column_right, random_row)
	else:
		random_start_pos = GameManager.map_column_right
		target_pos = Vector2(GameManager.map_column_left, random_row)
	
	
	instance.start_pos = Vector2(random_start_pos, random_row)
	instance.target_pos = target_pos
	instance.spawn_pos = instance.start_pos
	instance.first_spawn_time = 1
	instance.spawn_time = 1
	instance.oneshot = true
	add_child(instance)
	
	active_cup_bomb = instance
