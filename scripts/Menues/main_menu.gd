extends Control

@onready var press_fire_to_play = $PressFireToPlay
@onready var high_score_text = $HighScoreText
@onready var high_score_amount = $HighScoreAmount

@onready var sierra_online = $SierraOnline
@onready var solve_label = $SolveLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	press_fire_to_play.hide()
	high_score_text.hide()
	high_score_amount.hide()
	sierra_online.show()
	solve_label.show()
	
	var timer = Timer.new()
	timer.wait_time = 4.0 
	timer.autostart = true
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timeout"))
	add_child(timer)  # Add the timer as a child of this node
	
	
func _on_timeout():
	press_fire_to_play.show()
	high_score_text.show()
	high_score_amount.show()
	sierra_online.hide()
	solve_label.hide()

func _input(event):
	if event.is_action_pressed("stop_reverse"):
		GameManager.load_level("Level_%s" % str(GameManager.level_counter))
