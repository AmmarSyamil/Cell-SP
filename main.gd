extends Node2D

@export var enemy_scene: PackedScene = preload("res://enemy.tscn")
@export var enemy_shoot_scene: PackedScene = preload("res://enemy_shoot.tscn")
@export var spawn_interval: float = 1.0
@export var player_scene: PackedScene = preload("res://player.tscn")
#@export var 
@onready var pause_menu : Node = null
@onready var start_menu : Node = null

@onready var enemy_timer = $Timer_enemy
@onready var enemy_timer_shoot = $Timer_enemy_shoot
@onready var label_score = $Label
@onready var Boom_cd = $Boom_cd

@onready var player = $player
@export var score = 0

@export var cd_boom = 0
@export var cd_invincible = 0
@export var is_pause = false
@export var invincible_at = 0
@export var start = true
@export var wait_start = true

var screen_size: Vector2

func _ready() -> void:
	if start == true:
		$Label.hide()
		$Boom_cd.hide()
		$Invincible_cd.hide()
		$Invincible_at.hide()
		get_tree().paused = true
		var start_screen = preload("res://start_screen.tscn").instantiate()
		add_child(start_screen)
		start_screen.show()
		
	elif start == true and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if start_menu and start_menu.get_parent():
			remove_child(start_menu)
			start_menu.hide()
			start_menu.queue_free()
			start_menu = null
		get_tree().paused = false
		start = false
		$Timer_start.start()
		
	
	
	randomize()  
	screen_size = get_viewport_rect().size
	$Timer_score.timeout.connect(_on_score_timer_timeout)
	$Timer_score.start()
	$Timer_start.timeout.connect(_on_start_wait)
	
	$Timer_boom_cd.timeout.connect(_on_boom_cd_timeout)

	
	$Timer_invincible_cd.timeout.connect(_on_invincible_cd_timeout)
	$Timer_at_invincible.timeout.connect(_on_at_invincible_timeout)
	
	player = player_scene.instantiate()
	add_child(player)
	
	player.player_died.connect(_on_player_died)
	player.boom_at.connect(_on_boom_at)
	player.invincible.connect(_on_invincible)
	player.at_invicible.connect(_at_invincible)
	
	
	player.position = screen_size / 2
	
	spawn_loop()

func _on_start_wait():
	wait_start = false

func _on_at_invincible_timeout():
	if invincible_at > 0:
		invincible_at = max(invincible_at - 0.1, 0)
		$Invincible_at.text = "Invincible time " + str(snapped(invincible_at, 0.1))

func _at_invincible():
	print("masuk at invincible")
	invincible_at = 2.5
	$Timer_at_invincible.start()

func _on_invincible():
	print("Masuk ")
	$Timer_invincible_cd.start()
	cd_invincible = 5
	#$Invincible_cd.text
	

func _on_invincible_cd_timeout():
	if cd_invincible >0:
		cd_invincible = max(cd_invincible - 0.1, 0)
		$Invincible_cd.text = "Invincible cooldown " + str(snapped(cd_invincible, 0.1))
		
func _on_boom_cd_timeout():
	if cd_boom > 0:
		cd_boom = max(cd_boom - 0.1, 0)
		$Boom_cd.text = "Boom cooldown " + str(snapped(cd_boom, 0.1))
		
	
	
func _on_boom_at(time):
	cd_boom = 4
	$Timer_boom_cd.start()
	print("nuclear")
	
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
	death_screen.show_death_message(reason, score)
	
#func show_game_over_screen(reason):
	#var game_over_label = Label.new()
	#game_over_label.text = "YOU DIED\n" + reason
	#game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	#game_over_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	#game_over_label.size = Vector2(400, 200)
	#game_over_label.position = get_viewport_rect().size / 2 - Vector2(200, 100)
	#add_child(game_over_label)
	#
	#var restart_button = Button.new()
	#restart_button.text = "Restart"
	#restart_button.position = get_viewport_rect().size / 2 - Vector2(50, -50)
	#restart_button.pressed.connect(_on_restart_pressed)
	#add_child(restart_button)

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
	
	
	
func _process(delta) -> void:
	#await get_tree().create_timer(1.0).timeout
	$Label.show()
	$Boom_cd.show()
	$Invincible_cd.show()
	$Invincible_at.show()
	
	#var pause_menu = preload("res://pause_menu.tscn").instantiate()
	if Input.is_action_just_pressed("pause") and is_pause==false:
		pause_menu = preload("res://pause_menu.tscn").instantiate()
		#pause_menu.pause_mode = Node.PAUSE_MODE_PROCESS
		add_child(pause_menu)
		pause_menu.show()
		get_tree().paused = true
		
		is_pause=true
		#self.pause_mode = Node.PAUSE_MODE_PROCESS
		
	
	elif is_pause==true and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		print("ted")
		if pause_menu and pause_menu.get_parent():
			remove_child(pause_menu)
			pause_menu.hide()
			pause_menu.queue_free()
			pause_menu = null
		get_tree().paused = false
		is_pause=false
	
		
	pass
