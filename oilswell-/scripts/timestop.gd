extends Area2D

signal timestop

@onready var blink_timer = $BlinkTimer

var is_visible = true

func _ready():
	GameManager.connect_signal_to_function(self, "timestop", "_on_time_stop")
	blink_timer.connect("timeout", Callable(self, "_on_timer_timeout"))

func _on_timer_timeout():
	# Toggle visibility
	is_visible = !is_visible
	visible = is_visible



func _on_body_entered(body):
	queue_free()
	emit_signal("timestop")
