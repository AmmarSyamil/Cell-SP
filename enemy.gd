extends CharacterBody2D

@export var speed: float = 200.0
var target: Node2D = null

func set_target(t: Node2D) -> void:
	target = t
	
	
func _hit(body):
	pass

func _physics_process(delta: float) -> void:
	
	if target == null:
		return 

	var dir: Vector2 = (target.global_position - global_position).normalized()
	velocity = dir * speed
	rotation = dir.angle()
	var collision = move_and_collide(dir * speed * delta)
	#if collision and collision.get_collider().is_in_group("Boom"):
		#queue_free()
		
	move_and_slide()
