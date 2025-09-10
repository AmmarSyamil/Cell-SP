extends CharacterBody2D

@export var speed := 500
@export var dash_speed := 1500.0     
@export var dash_time := 0.2       
#@export var bullet_scene: PackedScene = preload("res://bullet.tscn")
@export var shoot_cooldown := 0.1

signal player_died(reason)
signal boom_at(cd)
signal invincible
signal at_invicible

#var can_shoot := true
var is_dashing := false
var dash_dir := Vector2.ZERO
@onready var boom: Area2D = $Boom
@onready var boom_shape: CollisionShape2D = $Boom/CollisionShape2D
@onready var boom_cd: Timer = $boom_cd

@onready var invincible_timer: Timer = $invinsible_cd
@onready var invincible_timer_cd: Timer = $invincible_cooldown
#@onready var timer_start: Timer = $Timer_start

#meletup
@export var boom_scale := 20
@export var grow_speed := 700
@export var shrink_speed := 700
@export var boom_cooldown = false

@export var  invincible_cd = false
@export var is_invincible = false

#@export var start = true

var growing := "neither"

func _process(delta):
	await get_tree().create_timer(1.0).timeout
	#if Input.is_action_pressed("shoot") and can_shoot:
		#shoot()
	#boom_cd.timeout.connect(_on_boom_cd_timeout)

	if growing=="grow":
		$Boom.visible=true
		boom_shape.disabled = false
		$Boom.scale += Vector2.ONE * grow_speed * delta
		if $Boom.scale.x >= boom_scale:
			growing = "shrink"
	elif growing=="shrink":
		$Boom.scale -= Vector2.ONE * shrink_speed * delta
		if $Boom.scale.x <= 0.1:
			growing="neither"
			boom_shape.disabled = true
			$Boom.visible=false
			
	if Input.is_action_just_pressed("boom") and boom_cooldown==false:
		emit_signal("boom_at", 4)
		boom_cooldown=true
		boom_cd.start()
		growing="grow"
		
		# invinsicle
	if Input.is_action_just_pressed("invinsible") and invincible_cd==false:
		_invincible()
		
		

func _invincible():
	invincible_cd = true
	#invincible_timer_cd.start()
	$invincible_sprite.show()
	$Hitbox.set_collision_mask_value(2, false)
	$Hitbox.set_collision_mask_value(3, false)
	print("masuk ler")
	emit_signal("at_invicible")
	invincible_timer.start()

	
	pass
	
func _invincible_timeout():
	print("niga")
	#invincible_cd = false
	$invincible_sprite.hide()
	$Hitbox.set_collision_mask_value(2, true)
	$Hitbox.set_collision_mask_value(3, true)
	#print("tes tes tes")
	invincible_timer_cd.start()
	emit_signal("invincible")

func _on_boom_cd_timeout():
	boom_cooldown=false
	#print("timeout")
	#invincible_cd.start()
	

	
		
#func shoot(): 	
	#can_shoot = false
	#var bullet = bullet_scene.instantiate()
	#bullet.position = global_position
	#bullet.direction = Vector2.RIGHT.rotated(rotation)
	#get_parent().add_child(bullet)
	#await get_tree().create_timer(shoot_cooldown).timeout
	#can_shoot = true
	
func _invincible_cd_timeout():
	invincible_cd=false

func _ready():
	# Connect the correct signals
	$Boom.visible=false
	$Hitbox.body_entered.connect(_on_body_entered)
	$Hitbox.area_entered.connect(_on_area_entered)
	$invincible_sprite.hide()
	
	invincible_timer_cd.timeout.connect(_invincible_cd_timeout)
	
	invincible_timer.timeout.connect(_invincible_timeout)
	
	boom.body_entered.connect(_on_boom_entered)
	boom_shape.disabled = false
	boom_cd.timeout.connect(_on_boom_cd_timeout)
	
	#print("Player collision layer: ", collision_layer)
	#print("Player collision mask: ", collision_mask)
	#print("Hitbox collision layer: ", $Hitbox.collision_layer)
	#print("Hitbox collision mask: ", $Hitbox.collision_mask)
	
	
	

func _on_boom_entered(body):
	if body.is_in_group("Enemy"):
		print("tes")
		body.queue_free()
		#delete teh colide body
		#pass

func _on_body_entered(body):
	print("Body entered: ", body.name)
	if body.is_in_group("Enemy"):
		print("Enemy collision detected!")
		emit_signal("player_died", "killed by enemy")

func _on_area_entered(area):
	print("Area entered: ", area.name)
	if area.is_in_group("EnemyHitbox"):
		print("Enemy attack hit!")
		emit_signal("player_died", "killed by enemy")

func _physics_process(delta):
	var mouse_pos = get_global_mouse_position()

	#if Input.is_action_just_pressed("dash") and not is_dashing:
		#is_dashing = true
		#dash_dir = (mouse_pos - position).normalized()
		#await get_tree().create_timer(dash_time).timeout
		#is_dashing = false
#
	#if is_dashing:
		#velocity = dash_dir * dash_speed
	#elif Input.is_action_pressed("freeze"):
		#velocity = Vector2.ZERO
	#else:
		#velocity = (mouse_pos - position).normalized() * speed

	position = mouse_pos
	rotation = (mouse_pos - position).angle()
	#var collision = move_and_collide(velocity * delta)
	#if collision and collision.get_collider().is_in_group("Enemy"):
		#print("Hit enemy!")
		#collision.get_collider().queue_free()


	move_and_slide()
