extends CharacterBody2D


signal pipe_fully_retracted

const START_POS = Vector2(25,12)

var tile_size = 16
var animation_speed = 45
var rwd_speed = 60
var moving = false
var reversing = false
var reversing_delay = false
var respawning = false


var cur_dir := Vector2.ZERO
var nxt_dir := Vector2.ZERO

var pipe_segments = []
var pipe_segments_color_index = 0

var oil_position_data = []

@onready var move_sound = $AudioStreamPlayer
@onready var life = $"../HUD/Life"
@onready var cur_ray = $cur_dir_ray
@onready var nxt_ray = $nxt_dir_ray
@onready var collision_shape_2d = $CollisionShape2d

@onready var pipe = $AnimatedSprite2D

#Load current tilemap
@onready var respawn_timer = $RespawnTimer
@onready var tilemap = $"../TileMap"
@onready var pb_tilemap = $"../PipeBody_TileMap"

var colors = [
	Color(1, 1, 0), # Yellow
	Color(1, 0, 0), # Red
	Color(0, 1, 0), # Green
	Color(0, 0, 1), # Blue
	Color(1, 0, 1), # Magenta
	Color(0, 1, 1)  # Cyan
]


func _ready():
	# Signals
	#var enemies = get_tree().get_nodes_in_group("Enemies")
	#for enemy in enemies:
		#if enemy.has_signal("kill"):  # Ensure the signal exists
			#enemy.connect("kill", Callable(self, "_on_death"))
	
	self.connect("pipe_fully_retracted", Callable(self, "_on_pipe_fully_retracted"))
	
	call_deferred("_connect_enemy_signals")  # Delays execution slightly
	
	respawn_timer.connect("timeout", Callable(self, "_on_RespawnTimer_timeout"))
	
	
	position.snapped(Vector2(tile_size, tile_size))	
	set_head_dir(Vector2.DOWN)
	
	# Set the initial color
	pb_tilemap.modulate = colors[pipe_segments_color_index]
	
	



func _connect_enemy_signals():
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		_connect_enemy(enemy)


# handles dynamically spawned enemies
func _on_node_added(node):
	if node.is_in_group("Enemies"):
		_connect_enemy(node)


func _connect_enemy(enemy):
	if enemy.has_signal("kill") and not enemy.is_connected("kill", Callable(self, "_on_death")):
		enemy.connect("kill", Callable(self, "_on_death"))


func _process(_delta):
	
	# Movement Logic
	if !respawning:
		_get_user_input()

	if moving or respawning:
		if reversing:
			retract_pipe()
		else:
			return
	else:
		if reversing:
			retract_pipe()
		else:
			move_head()


func _get_user_input():
	if Input.is_action_pressed("move_down"):
		nxt_dir = Vector2.DOWN
	elif Input.is_action_pressed("move_up"):
		nxt_dir = Vector2.UP
	elif Input.is_action_pressed("move_left"):
		nxt_dir = Vector2.LEFT
	elif Input.is_action_pressed("move_right"):
		nxt_dir = Vector2.RIGHT
	elif Input.is_action_just_pressed("stop_reverse"):
		nxt_dir = Vector2.ZERO
		cur_dir = Vector2.ZERO
		reversing = true
	elif Input.is_action_just_released("stop_reverse"):
		reversing = false


func retract_pipe():
	if pipe_segments.size() > 0:
			var head_dir: Vector2 
			
			# Stops animation when reversing
			pipe.stop()
			
			# Sets the head direction
			if pipe_segments.size() != 1:
				head_dir = pipe_segments[-1] - pipe_segments[-2]
			else:
				head_dir = position/tile_size - pipe_segments[-1]
			if head_dir != Vector2(0,0):
				set_head_dir(Vector2(head_dir))
			
			var rwd_head_tween = create_tween()
			var last_item = pipe_segments.pop_back()
			pb_tilemap.set_cell(last_item, -1)
			rwd_head_tween.tween_property(self, "position", last_item * tile_size, 1.0/rwd_speed).set_trans(Tween.TRANS_SINE)
			moving = true
			await rwd_head_tween.finished
			moving = false
		
	elif pipe_segments.size() == 0:
		reversing = false  # Stop reversing when all segments are visited
		add_segment()
		emit_signal("pipe_fully_retracted")
	return


func move_head() -> void:

	# Create and force update of ray in current direction
	cur_ray.target_position = cur_dir * tile_size
	cur_ray.force_raycast_update()	
	# Create and force update of ray in wanted direction
	nxt_ray.target_position = nxt_dir * tile_size
	nxt_ray.force_raycast_update()
	
	# Movement logic
	if not nxt_ray.is_colliding():
		cur_dir = nxt_dir
	if cur_ray.is_colliding():
		cur_dir = Vector2.ZERO
		nxt_dir = Vector2.ZERO
	
	# Sets head direction before moving the head
	set_head_dir(cur_dir)

	## Animates and moves player
	var head_tween = create_tween()
	head_tween.tween_property(self, "position", 
		position + cur_dir * tile_size, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
	moving = true
	await head_tween.finished
	moving = false

	#Record current position for tail
	add_segment()
	draw_segments()


func set_head_dir(dir):
	if dir == Vector2.ZERO:
		pipe.stop()
	elif dir == Vector2.UP:
		pipe.play("up")
	elif dir == Vector2.DOWN:
		pipe.play("down")
	elif dir == Vector2.RIGHT:
		pipe.play("right")
	elif dir == Vector2.LEFT:
		pipe.play("left")


func add_segment():
	var tile_pos = position / tile_size
	# Ensure the position is added only when not reversing
	if tile_pos not in pipe_segments:
		pipe_segments.append(tile_pos)


#
func draw_segments():
	
	# Pipebody tilemap ID ID
	const PB_TILEMAP_ID = 0
	
	# Tilmap coordinates
	const TILE_VERTICAL = Vector2(1,0)
	const TILE_HORIZONTAL = Vector2(4,0)
	const TILE_UP_RIGHT_LEFT_DOWN = Vector2(0,0)
	const TILE_UP_LEFT_RIGHT_DOWN = Vector2(2,0)
	const TILE_LEFT_UP_DOWN_RIGHT = Vector2(3,0)
	const TILE_RIGHT_UP_DOWN_LEFT = Vector2(5,0)
	
	# Ensure there is at least one segment to process
	if pipe_segments.size() > 1:
		for segment_index in pipe_segments.size():
			var segment = pipe_segments[segment_index]
			var previous_segment = null
			var next_segment = null
			#print("Drawing segments", pipe_segments)
			
			# Skips previous or next segments if out of range
			if segment_index > 0:
				previous_segment = pipe_segments[segment_index - 1] - segment
				#print("previous: ", previous_segment)
			if segment_index < pipe_segments.size() - 1:
				next_segment = pipe_segments[segment_index + 1] - segment
				#print("next: ",next_segment)
			
	
			# Skips to draw the segment if its on top of cur_pos
			if segment == pipe_segments[-1]:
				previous_segment = segment
			
			# Draws a downwards segment on the first position
			elif segment == START_POS:
				pb_tilemap.set_cell(segment, PB_TILEMAP_ID, TILE_VERTICAL)
			
			if previous_segment and next_segment:
				# Vertical movmentz
				if previous_segment.x == next_segment.x:
					pb_tilemap.set_cell(segment, PB_TILEMAP_ID, TILE_VERTICAL)
					
				# Horizontal movment
				elif previous_segment.y == next_segment.y:
					pb_tilemap.set_cell(segment, PB_TILEMAP_ID, TILE_HORIZONTAL)
					
				else:
					# right/up or down/left
					if previous_segment.y == -1 and next_segment.x == -1 or next_segment.y == -1 and previous_segment.x == -1:
						pb_tilemap.set_cell(segment, PB_TILEMAP_ID, TILE_RIGHT_UP_DOWN_LEFT)
					# up/right or left/down
					if previous_segment.y == 1 and next_segment.x == 1 or next_segment.y == 1 and previous_segment.x == 1:
						pb_tilemap.set_cell(segment, PB_TILEMAP_ID, TILE_UP_RIGHT_LEFT_DOWN)
					# left/up or down/right
					if previous_segment.y == -1 and next_segment.x == 1 or next_segment.y == -1 and previous_segment.x == 1:
						pb_tilemap.set_cell(segment, PB_TILEMAP_ID, TILE_LEFT_UP_DOWN_RIGHT)
					# up/left or right/down
					if previous_segment.y == 1 and next_segment.x == -1 or next_segment.y == 1 and previous_segment.x == -1:
						pb_tilemap.set_cell(segment, PB_TILEMAP_ID, TILE_UP_LEFT_RIGHT_DOWN)
				
				
			### DEBUG ####
			#print("Position: ", position / tile_size, " - ",
			  #"Previous segment: ", previous_segment, " - ",
			  #"Current Segment: ", segment, " - ",
			  #"Next Segment: ", next_segment)
			
			#print(pipe_segments)


func _on_death():
	print("Player Killed")
	cur_dir = Vector2.ZERO
	nxt_dir = Vector2.ZERO
	respawning = true
	collision_shape_2d.disabled = true
	
	var colors = [Color.RED, Color.GREEN, Color(1, 1, 1, 0), Color.BLUE, Color.WHITE,  Color(1, 1, 1, 0), Color.YELLOW, ]
	
	for pipe_body in get_tree().get_nodes_in_group("pipe_tiles"):
		# Rapid bliking
		for color in colors:
			pipe_body.modulate = color
			await get_tree().create_timer(0.1).timeout
		
		# Slow blinking effect
		for x in range(3):
			pipe_body.modulate = Color.WHITE
			await get_tree().create_timer(0.3).timeout
			pipe_body.modulate = Color(1, 1, 1, 0)
			await get_tree().create_timer(0.3).timeout
		
		# Restore color
		pipe_body.modulate =  Color.YELLOW
		
		#await get_tree().create_timer(0.1).timeout
	#respawning = false
	lose_life()
	reversing = true
	
	#respawn_timer.start()
	#respawning = false
	

func _on_RespawnTimer_timeout():
	print("Respawned")
	#reversing = false
	respawning = false
	collision_shape_2d.disabled = false

func _on_pipe_fully_retracted():
	respawning = false
	reversing = false


func lose_life():
	GameManager.loose_life()
	# Notify the life display to redraw
	life.update_lives()
