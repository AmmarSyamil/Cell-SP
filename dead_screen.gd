extends CanvasLayer 

@onready var death_label = $Label
@onready var restart_button = $Button

func _ready():
	layer = 100
	process_mode = PROCESS_MODE_ALWAYS
	restart_button.pressed.connect(_on_restart_button_pressed)

func show_death_message(reason: String):
	death_label.text = reason
	death_label.visible = true
	restart_button.visible = true
	restart_button.disabled = false
	restart_button.grab_focus() 



func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	
