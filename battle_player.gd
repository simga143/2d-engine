extends CharacterBody2D

const SPEED = 100.0
enum modes {
	red,
	blue
}
var mode = modes.blue
var jumpFrames = 0

func _physics_process(delta: float) -> void:
	if mode == modes.red:
		velocity = Input.get_vector("move_left","move_right","move_up","move_down") * SPEED
	elif mode == modes.blue:
		velocity.x = Input.get_axis("move_left","move_right") * SPEED
		if !is_on_floor() && jumpFrames == 0:
			velocity.y += 9.8
		if Input.is_action_pressed("move_down"):
			if velocity.y < 0:
				velocity.y *= .5
			velocity.y += 4.9
		if Input.is_action_pressed("move_up"):
			if is_on_floor():
				jumpFrames = 1
				velocity.y = -130
			elif jumpFrames > 0 && jumpFrames < 10:
				jumpFrames += 1
				velocity.y -= 9
		if Input.is_action_just_released("move_up") || jumpFrames == 10:
			jumpFrames = 0
	move_and_slide()

func spawn():
	mode = modes.red
	jumpFrames = 0
	position = Vector2(240,180)
	show()

func vanish():
	hide()

func _on_battle_turn_control(start: Variant) -> void:
	if start:
		spawn()
	else:
		hide()

func _on_battle_change_player_mode(new_mode: String) -> void:
	if new_mode == "blue":
		mode = modes.blue
	else:
		mode = modes.red
