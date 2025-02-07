extends Area2D

signal timestop

@onready var blink_timer = $BlinkTimer
@onready var color_rect = $"../ColorRect"
@onready var collision_shape_2d = $CollisionShape2D


var is_visible = true

func _ready():
	GameManager.connect_signal_to_function(self, "timestop", "_on_time_stop")
	blink_timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	

func _on_timer_timeout():
	# Toggle visibility
	is_visible = !is_visible
	visible = is_visible


func _on_body_entered(body):
	collision_shape_2d.disabled
	self.is_visible = false
	MusicManager.timestop_sound.play()
	
	color_rect.visible = true
	await get_tree().create_timer(0.1).timeout
	color_rect.visible = false
	await get_tree().create_timer(0.1).timeout
	color_rect.visible = true
	await get_tree().create_timer(0.1).timeout
	color_rect.visible = false
	await get_tree().create_timer(0.1).timeout
	
	queue_free()
	emit_signal("timestop")
