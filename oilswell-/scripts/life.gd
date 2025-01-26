extends Node2D

@onready var sprite_2d = $Sprite2D
const PIPE_RIGHT = preload("res://assests/pipe/pipe_right.png")

func _ready():
	queue_redraw()	


func _draw():
	var life_count = GameManager.lives
	var icon_size = Vector2(16, 16)
	var start_position = Vector2(10, 10)
	
	for i in range(GameManager.lives):
		var position = start_position + Vector2(i * (icon_size.x + 5), 0)
		draw_texture(PIPE_RIGHT, position)
		
func update_lives():
	print("update_lives()")
	queue_redraw()
