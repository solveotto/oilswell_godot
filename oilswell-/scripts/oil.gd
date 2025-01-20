extends Area2D


func _on_body_entered(body):
	GameManager.add_oil_point()
	remove_from_group("oil_nodes")
	queue_free()
	
	
