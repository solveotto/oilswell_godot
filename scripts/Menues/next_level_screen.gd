extends CanvasLayer


@onready var levelnumber_label = $Levelnumber


# Called when the node enters the scene tree for the first time.
func _ready():
	levelnumber_label.text = str(GameManager.level_counter)
