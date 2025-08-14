extends CharacterBody2D
@export var bullet_scene: PackedScene = preload("res://bullet.tscn")
@export var speed: float = 80
@export var shoot_cooldown := 0.3
var target: Node2D = null
var can_shoot = true

func set_target(t: Node2D) -> void:
	target = t

func _process(delta):
	if can_shoot:
		shoot()

func shoot(): 	
	can_shoot = false
	var bullet = bullet_scene.instantiate()
	bullet.position = global_position
	bullet.direction = Vector2.RIGHT.rotated(rotation)
	get_parent().add_child(bullet)
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true

func _physics_process(delta: float) -> void:
	if target == null:
		return 

	var dir: Vector2 = (target.global_position - global_position).normalized()
	velocity = dir * speed
	rotation = dir.angle()
	var collision = move_and_collide(dir * speed * delta)
	move_and_slide()
