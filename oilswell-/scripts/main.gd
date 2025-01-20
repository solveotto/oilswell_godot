extends Node2D


func _ready():
	GameManager.load_level("Level_1")
	
	print(GameManager.get("Pipe"))
