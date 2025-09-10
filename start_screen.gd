extends CanvasLayer



func _process(delta: float) -> void:
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		get_tree().paused = false
		self.hide()
	
