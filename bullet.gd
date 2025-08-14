extends CharacterBody2D

@export var speed: float = 1200
var direction: Vector2
var target: Node2D = null

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(direction * speed * delta)
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	#if collision:
		#var collider = collision.get_collider()
		#print("Hit:", collision.get_collider().name)
		#if collider.is_in_group("Enemy"):
			#collider.queue_free()
		#queue_free()
