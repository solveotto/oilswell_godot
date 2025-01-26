extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	#GameManager.load_level("Level_1")
	pass # Replace with function body.


func _input(event):
	if event.is_action_pressed("ui_left"):
		print("left")

func _on_play_pressed():
	GameManager.load_level("Level_1")


func _on_quit_pressed():
	get_tree().quit()
