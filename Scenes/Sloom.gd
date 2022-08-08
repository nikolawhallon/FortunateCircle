extends RigidBody2D

var speed = 20
var destination = Vector2(0, 0)

func _physics_process(_delta):
	linear_velocity = (destination - position).normalized() * speed

func destroy():
	get_tree().queue_delete(self)
