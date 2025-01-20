extends CharacterBody2D


# Tilemap
const SEGMENT_ID = 8
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




var input_to_dir = {
	"move_down": Vector2.DOWN,
	"move_up": Vector2.UP,
	"move_left": Vector2.LEFT,
	"move_right": Vector2.RIGHT
}

@onready var cur_ray = $cur_dir_ray
@onready var nxt_ray = $nxt_dir_ray
@onready var pipe = $AnimatedSprite2D

#Load current tilemap
#@onready var collision_shape = $CollisionShape2D
@onready var rwd_timer = $ReversingTimer
@onready var tilemap = $"../TileMap"


func _ready():
	
	# Signals
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		if enemy.has_signal("kill"):  # Ensure the signal exists
			enemy.connect("kill", Callable(self, "_on_death"))
	
	position.snapped(Vector2(tile_size, tile_size))	
	rwd_timer.connect("timeout", Callable(self, "_on_ReversingTimer_timeout"))
	set_head_dir(Vector2.DOWN)


func _process(_delta):
	## DEBUG ##
	#if pipe_segments:
		#print(pipe_segments[-1])
	if not moving:
		move_head()
	
	

func _input(event):
	if not reversing_delay:
		for action in input_to_dir.keys():
			if event.is_action_pressed(action):
				nxt_dir = input_to_dir[action]
	if event.is_action_pressed("stop_reverse"):
		nxt_dir = Vector2.ZERO
		cur_dir = Vector2.ZERO
		reversing = true
		reversing_delay = true
	if event.is_action_released("stop_reverse"):
		reversing = false
		rwd_timer.start()


func move_head() -> void:
	## Retracting Head
	if reversing:
		if pipe_segments.size() > 0:
			#print("pos: ", position / tile_size, "Last segment: ",  pipe_segments[-1])
			#print(position / tile_size - pipe_segments[-1])
			var head_dir = position / tile_size - pipe_segments[-1]
			if head_dir != Vector2(0,0):
				set_head_dir(Vector2(head_dir))
			
			var rwd_head_tween = create_tween()
			var last_item = pipe_segments.pop_back()
			tilemap.set_cell(last_item, -1)
			rwd_head_tween.tween_property(self, "position", last_item * tile_size, 1.0/rwd_speed).set_trans(Tween.TRANS_SINE)
			moving = true
			await rwd_head_tween.finished
			moving = false
		elif pipe_segments.size() == 0:
			reversing = false  # Stop reversing when all segments are visited
		return
	
	## Moving forwards
	else:
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
	##var previous_segment: Vector2  # To track the previous segment
	##var next_segment: Vector2  # To store the segment before the last one
	#var segment_to_draw:Vector2
	#var head_pos = position / tile_size
	#

	
	# Ensure there is at least one segment to process
	if pipe_segments.size() > 1:
		for segment_index in pipe_segments.size():
			var segment = pipe_segments[segment_index]
			var previous_segment = null
			var next_segment = null
			print("Drawing segments", pipe_segments)
			
			# Skips previous or next segments if out of range
			if segment_index > 0:
				previous_segment = pipe_segments[segment_index - 1] - segment
			if segment_index < pipe_segments.size() - 1:
				next_segment = pipe_segments[segment_index + 1] - segment

			# Skips to draw the segment if its on top of cur_pos
			if segment == pipe_segments[-1]:
				previous_segment = segment
			
			# Draws a downwards segment on the first position
			elif segment == START_POS:
				tilemap.set_cell(segment, SEGMENT_ID, Vector2(6,1))
				
			# Vertical movmentz
			elif previous_segment.x == next_segment.x:
				tilemap.set_cell(segment, SEGMENT_ID, Vector2(6,1))
				
			# Horizontal movment
			elif previous_segment.y == next_segment.y:
				tilemap.set_cell(segment, SEGMENT_ID, Vector2(9,1))
				
			else:
				# left/up or down/left
				if previous_segment.y == -1 and next_segment.x == -1 or next_segment.y == -1 and previous_segment.x == -1:
					tilemap.set_cell(segment, SEGMENT_ID, Vector2(10,1))
				# up/right or left/down
				if previous_segment.y == 1 and next_segment.x == 1 or next_segment.y == 1 and previous_segment.x == 1:
					tilemap.set_cell(segment, SEGMENT_ID, Vector2(5,1))
				# left/up or down/right
				if previous_segment.y == -1 and next_segment.x == 1 or next_segment.y == -1 and previous_segment.x == 1:
					tilemap.set_cell(segment, SEGMENT_ID, Vector2(8,1))
				# up/left or right/down
				if previous_segment.y == 1 and next_segment.x == -1 or next_segment.y == 1 and previous_segment.x == -1:
					tilemap.set_cell(segment, SEGMENT_ID, Vector2(7,1))
			
			
			### DEBUG ####
			#print("Position: ", position / tile_size, " - ",
			  #"Previous segment: ", previous_segment, " - ",
			  #"Current Segment: ", segment, " - ",
			  #"Next Segment: ", next_segment)
			
			#print(pipe_segments)


func _on_ReversingTimer_timeout():
	# Timer has finished, set reversing to false
	reversing_delay = false

func _on_death():
	print("Player Killed")
	respawning = true
	
	for segment in pipe_segments:
		tilemap.erase_cell(segment)



	# Reset player position
	position = START_POS * tile_size

	# Clear all drawn segments from the tilemap
	#tilemap.clear()  # This removes all tiles. If you only want to clear specific ones, use erase_cell().

	pipe_segments.clear()  # Clear all stored segments
	# Reset movement state
	cur_dir = Vector2.ZERO
	nxt_dir = Vector2.ZERO
	moving = false
	reversing = false
	reversing_delay = false

	# Reset animation
	set_head_dir(Vector2.DOWN)
