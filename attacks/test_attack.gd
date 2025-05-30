extends Area2D

var accel = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += Vector2.from_angle(rotation)*accel
	accel += .03
	if accel > 8:
		queue_free()
