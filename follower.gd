extends CharacterBody2D

@export var id = 1
@export var type = "default"
var player
var last_positions
var run_follow_code = false
var pos_diff
var follow
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	run_follow_code = get_parent().has_meta("is_overworld")
	if run_follow_code:
		player = get_parent().find_child("Player")
		last_positions = get_parent().get_meta("LastPlayerPositions")
		if id == 1:
			follow = player
		else:
			follow = get_parent().find_child("".join(["Follower",(id-1)]))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if run_follow_code:
		if player.velocity.length() != 0:
			#last_positions = get_parent().get_meta("LastPlayerPositions")
			#pos_diff = (last_positions[16*id-1]-position)
			pos_diff = follow.position-position
			var old_pos = position
			if abs(pos_diff.y)+.1 >= abs(pos_diff.x):
				if pos_diff.y<0:
					$AnimatedSprite2D.play("up_"+type)
				elif pos_diff.y>0:
					$AnimatedSprite2D.play("down_"+type)
			else:
				if pos_diff.x<0:
					$AnimatedSprite2D.play("side_"+type)
					$AnimatedSprite2D.flip_h = false
				elif pos_diff.x>0:
					$AnimatedSprite2D.play("side_"+type)
					$AnimatedSprite2D.flip_h = true
			
			if position.distance_to(follow.position) > 32:
				position = follow.position - (position.direction_to(follow.position)*32)
			if old_pos == position:
				$AnimatedSprite2D.stop()
			#position = last_positions[16*id-1]
		else:
			$AnimatedSprite2D.stop()
