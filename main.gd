extends Node2D

@export var enemy_scene: PackedScene = preload("res://enemy.tscn")
@export var enemy_shoot_scene: PackedScene = preload("res://enemy_shoot.tscn")
@export var spawn_interval: float = 1.0
@export var player_scene: PackedScene = preload("res://player.tscn")

@onready var enemy_timer = $Timer_enemy
@onready var enemy_timer_shoot = $Timer_enemy_shoot
@onready var label_score = $Label

@onready var player = $player
@export var score = 0
var screen_size: Vector2

func _ready() -> void:
	randomize()  
	screen_size = get_viewport_rect().size
	$Timer_score.timeout.connect(_on_score_timer_timeout)
	$Timer_score.start()
	player = player_scene.instantiate()
	add_child(player)
	player.player_died.connect(_on_player_died)
	
	player.position = screen_size / 2
	
	spawn_loop()  
	
func _on_score_timer_timeout():
	score += 1
	$Label.text = "Your score is " + str(score)

func spawn_loop() -> void:
	enemy_timer.timeout.connect(_on_enemy_timer_timeout)
	enemy_timer.start()  
	enemy_timer_shoot.timeout.connect(_on_enemy_shoot_timer_timeout)
	enemy_timer_shoot.start()

func _on_enemy_timer_timeout():
	if enemy_timer.wait_time > 0.5:
		enemy_timer.wait_time -= 0.2
	print(enemy_timer.wait_time)
	spawn_enemy()
	
func _on_enemy_shoot_timer_timeout():
	if enemy_timer_shoot.wait_time > 1.0:
		enemy_timer_shoot.wait_time -= 0.2
	print(enemy_timer_shoot.wait_time)
	spawn_enemy_shoot()

func _on_player_died(reason):
	var death_screen = preload("res://dead_screen.tscn").instantiate()
	add_child(death_screen)
	get_tree().paused = true
	death_screen.show_death_message(reason)
	
func show_game_over_screen(reason):
	var game_over_label = Label.new()
	game_over_label.text = "YOU DIED\n" + reason
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	game_over_label.size = Vector2(400, 200)
	game_over_label.position = get_viewport_rect().size / 2 - Vector2(200, 100)
	add_child(game_over_label)
	
	var restart_button = Button.new()
	restart_button.text = "Restart"
	restart_button.position = get_viewport_rect().size / 2 - Vector2(50, -50)
	restart_button.pressed.connect(_on_restart_pressed)
	add_child(restart_button)

func _on_restart_pressed():
	#get_tree().paused = false
	get_tree().reload_current_scene()
	
func spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()

	print("Instanced enemy:", enemy, "class:", enemy.get_class(), "script:", enemy.get_script())

	var edge = randi() % 4
	var spawn_pos = Vector2.ZERO

	if edge == 0:
		spawn_pos = Vector2(randf() * screen_size.x, 0)
	elif edge == 1:
		spawn_pos = Vector2(randf() * screen_size.x, screen_size.y)
	elif edge == 2:
		spawn_pos = Vector2(0, randf() * screen_size.y)
	else:
		spawn_pos = Vector2(screen_size.x, randf() * screen_size.y)

	enemy.global_position = spawn_pos


	if enemy.has_method("set_target"):
		enemy.set_target(player)
	else:
		push_warning("Spawned enemy has no set_target() method. Check enemy.tscn and its script.")

	add_child(enemy)

func spawn_enemy_shoot() -> void:
	var enemy = enemy_shoot_scene.instantiate()

	print("Instanced enemy:", enemy, "class:", enemy.get_class(), "script:", enemy.get_script())

	var edge = randi() % 4
	var spawn_pos = Vector2.ZERO

	if edge == 0:
		spawn_pos = Vector2(randf() * screen_size.x, 0)
	elif edge == 1:
		spawn_pos = Vector2(randf() * screen_size.x, screen_size.y)
	elif edge == 2:
		spawn_pos = Vector2(0, randf() * screen_size.y)
	else:
		spawn_pos = Vector2(screen_size.x, randf() * screen_size.y)

	enemy.global_position = spawn_pos


	if enemy.has_method("set_target"):
		enemy.set_target(player)
	else:
		push_warning("Spawned enemy has no set_target() method. Check enemy.tscn and its script.")

	add_child(enemy)
