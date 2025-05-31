extends CharacterBody2D

@export var speed = 150
var screen_size
var sprinting = 1
var upload_position = false
var last_pos_list
var followers
var controls_enabled = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	position = screen_size/2
	upload_position = get_parent().has_meta("LastPlayerPositions")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if controls_enabled:
		velocity = Input.get_vector("move_left","move_right","move_up","move_down")
		if (velocity.y > 0):
			$AnimatedSprite2D.play("down")
			$Interaction.rotation_degrees = 0
		elif (velocity.y < 0):
			$AnimatedSprite2D.play("up")
			$Interaction.rotation_degrees = 180
		else:
			if (velocity.x > 0):
				$AnimatedSprite2D.play("side")
				$AnimatedSprite2D.flip_h = true
				$Interaction.rotation_degrees = 270
			elif (velocity.x < 0):
				$AnimatedSprite2D.play("side")
				$AnimatedSprite2D.flip_h = false
				$Interaction.rotation_degrees = 90
	
		if Input.is_action_pressed("sprint"):
			sprinting = 2
		else:
			sprinting = 1
	
		if velocity.length() > 0: 
			velocity *= speed * sprinting
			move_and_slide()
			$FollowTrail.curve 
			if upload_position:
				last_pos_list = get_parent().get_meta("LastPlayerPositions")
				followers = get_parent().find_children("Follower*").size()
				if last_pos_list.size() < 16*followers:
					while last_pos_list.size() < 16*followers:
						last_pos_list.insert(0,position)
				elif last_pos_list.size() > 16*followers:
					while last_pos_list.size() > 16*followers:
						last_pos_list.remove_at(16*followers)
				last_pos_list.insert(0,position)
				last_pos_list.remove_at(16*followers)
				get_parent().set_meta("LastPlayerPositions",last_pos_list)
		else:
			$AnimatedSprite2D.stop()
	
