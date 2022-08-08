extends Area2D

var speed = 200
var angular_speed = 10
var direction = Vector2(0.0, 0.0)

func destroy():
	get_tree().queue_delete(self)

func _on_Diamond_body_entered(body):
	if body.is_in_group("Sloom"):
		body.destroy()
		destroy()

func _process(delta):
	position += speed * direction * delta
	rotation += angular_speed * delta
