extends Area2D

@onready var bip_snd = $AudioStreamPlayer2D


func _on_body_entered(body):
	MusicManager.play_bip()
	self.hide()
	GameManager.add_oil_point()
	remove_from_group("oil_nodes")
	queue_free()  
