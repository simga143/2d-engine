extends Node2D

var battle_log = ""
var battle_active = false
@export_file("*.json") var sequence_file = "res://data/attack_sequences.json"
var sequence_data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(sequence_file))
@export_file("*.json") var attack_file = "res://data/attacks.json"
var attack_data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(attack_file))
var attacks: Dictionary[String,PackedScene]
@export_file("*.json") var skill_file = "res://data/skills.json"
var json_as_text = FileAccess.get_file_as_string(skill_file)
var skill_data = JSON.parse_string(json_as_text)
signal turn_control(start)
signal change_player_mode(new_mode: String)
#@export_file("*.json") var character_file = "res://data/characters.json"
#json_as_text = FileAccess.get_file_as_string(character_file)
#var character_data = JSON.parse_string(json_as_text)
var battle_info = {
	"friend_data": {
		"0":{
			"hp": 0,
			"to_hp": 0,
			"mp": 0,
			"to_mp": 0,
			"status": "",
			"effects": {},
			"id": "null"
		}
	},
	"enemy_data": {
		"0":{
			"hp": 0,
			"mp": 0,
			"status": "",
			"effects": {},
			"id": "null"
		}
	},
	"current_turn": 0,
	"turns": 0
}

var i = 0
var frame = 0
var box_target_pos = Vector2(240,180)
var box_target_size = Vector4(64,64,64,64)
var box_target_rot = 0
var box_speed = .1
var box_logarithm = true
var box_cur_pos = Vector2(240,180)
var box_cur_size = Vector4(64,64,64,64)
var box_cur_rot = 0

func load_attacks() -> void:
	for key in attack_data:
		var resource: PackedScene = ResourceLoader.load("".join(["res://attacks/",key,".tscn"]),"PackedScene",ResourceLoader.CACHE_MODE_REUSE)
		if resource == null: printerr(''.join(['Cannot load attack ',key]))
		else:
			attacks[key] = resource
			print(''.join(['Loaded attack ',key," | ",resource]))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_attacks()
	$Control/BG/BG.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	i += delta
	frame += 1
	parse_attack_sequence("test_sequence",frame)
	if box_cur_pos != box_target_pos || box_cur_size != box_target_size || box_cur_rot != box_target_rot:
		tween_box(box_target_pos,box_target_size,box_target_rot,box_logarithm,box_speed)
		if abs(box_target_pos.length_squared()-box_cur_pos.length_squared()) <= 1: box_cur_pos = box_target_pos
		if abs(box_target_size.length_squared()-box_cur_size.length_squared()) <= 2: box_cur_size = box_target_size
		if abs(box_target_rot-box_cur_rot) <= .5: box_cur_rot = box_target_rot
			
	#transform_box(Vector2(240,180),64,64+cos(i)*30,64,64,sin(i/4)*180)

func update_theme(theme) -> void:
	$Control/TopBox/Theme.region_rect = Rect2(96 * (theme % 2),96 * floor(theme/2),96,96)
	$Control/Friend/Theme.region_rect = Rect2(96 * (theme % 2),96 * floor(theme/2),96,96)
	$containmentBox/NinePatchRect.region_rect = Rect2(96 * (theme % 2),96 * floor(theme/2),96,96)

func begin_battle(battle_id = 0) -> void:
	transform_box(Vector2(240,180),64,64,64,64,0)
	i = 0
	frame = 0
	box_target_pos = Vector2(240,180)
	box_target_size = Vector4(64,64,64,64)
	box_target_rot = 0
	box_speed = .1
	box_logarithm = true
	box_cur_pos = Vector2(240,180)
	box_cur_size = Vector4(64,64,64,64)
	box_cur_rot = 0
	battle_log = "Attack sequence test\nFeaturing special guest:\n"
	$Control/TopBox/Margin/Text.visible_characters = 0
	$Control/TopBox/Margin/Text.text = battle_log
	$TypeCharacterTimer.start()
	add_to_battle_log("Red transparent accelerating square with no collison!!!",{"text_speed":0.05})

func tween_box(pos:Vector2,size:Vector4,rot:float,logarithm=true,rate=.1):
	if logarithm:
		var new_box_pos = $containmentBox.position.lerp(pos,rate)
		var new_box_size = Vector4(lerp(-$containmentBox/up.position.y,size.x,rate),lerp($containmentBox/bottom.position.y,size.y,rate),lerp(-$containmentBox/left.position.x,size.z,rate),lerp($containmentBox/right.position.x,size.w,rate))
		var new_box_rot = lerp($containmentBox.rotation_degrees,rot,rate)
		transform_box(new_box_pos,new_box_size.x,new_box_size.y,new_box_size.z,new_box_size.w,new_box_rot)
	else:
		var xinc; var yinc; var sxinc; var syinc; var szinc; var swinc; var rinc;
		if round($containmentBox.position.x/rate) == round(pos.x/rate): xinc = 0
		elif $containmentBox.position.x < pos.x: xinc = rate
		else: xinc = -rate
		if round($containmentBox.position.y/rate) == round(pos.y/rate): yinc = 0
		elif $containmentBox.position.y < pos.y: yinc = rate
		else: yinc = -rate
		if abs(round($containmentBox/up.position.y/rate)) == round(size.x/rate): sxinc = 0
		elif abs($containmentBox/up.position.y) < size.x: sxinc = rate
		else: sxinc = -rate
		if round($containmentBox/bottom.position.y/rate) == round(size.y/rate): syinc = 0
		elif $containmentBox/bottom.position.y < size.y: syinc = rate
		else: syinc = -rate
		if abs(round($containmentBox/left.position.x/rate)) == round(size.z/rate): szinc = 0
		elif abs($containmentBox/left.position.x) < size.z: szinc = rate
		else: szinc = -rate
		if round($containmentBox/right.position.x/rate) == round(size.w/rate): swinc = 0
		elif $containmentBox/right.position.x < size.w: swinc = rate
		else: swinc = -rate
		if round($containmentBox.rotation_degrees/rate) == round(rot/rate): rinc = 0
		elif $containmentBox.rotation_degrees < rot: rinc = rate
		else: rinc = -rate
		transform_box(Vector2($containmentBox.position.x+xinc,$containmentBox.position.y+yinc),abs($containmentBox/up.position.y-sxinc),$containmentBox/bottom.position.y+syinc,abs($containmentBox/left.position.x-szinc),$containmentBox/right.position.x+swinc,$containmentBox.rotation_degrees+rinc)
	
func transform_box(pos,up,bottom,left,right,rot=0):
	box_cur_pos = pos
	box_cur_size = Vector4(up,bottom,left,right)
	box_cur_rot=rot
	$containmentBox.rotation_degrees = rot
	$containmentBox.position = pos
	$containmentBox/up.position.y = -up
	$containmentBox/bottom.position.y = bottom
	$containmentBox/left.position.x = -left
	$containmentBox/right.position.x = right
	$containmentBox/NinePatchRect.position.x = $containmentBox/left.position.x-4
	$containmentBox/NinePatchRect.position.y = $containmentBox/up.position.y-4
	$containmentBox/NinePatchRect.size.x = -$containmentBox/left.position.x+$containmentBox/right.position.x+8
	$containmentBox/NinePatchRect.size.y = -$containmentBox/up.position.y+$containmentBox/bottom.position.y+8
	
func plr_turn():
	turn_control.emit(true)
	
func spawn_attack(attack_name,pos,rot=0):
	var attack = attacks[attack_name]
	if !attack.can_instantiate(): printerr("Cannot instantiate attack "+attack_name); return
	var clone = await attack.instantiate()
	clone.position = pos
	clone.rotation_degrees = rot
	add_child(clone)
		
func parse_attack_sequence(name: String,frame: int) -> void:
	if !sequence_data.has(name): return;
	var sequence: Dictionary = sequence_data[name]
	var sequences = []
	var parse = false
	for key: String in sequence:
		if key.contains("-"):
			var parts: PackedStringArray = key.split("-");
			if key.contains("%"):
				if frame % (key.get_slice("%",1) as int) == 0:
					if (parts[0] as int) <= frame && (parts[1].get_slice("%",0) as int) >= frame:
						parse = true
						sequences.append(key)
			elif (parts[0] as int) <= frame && (parts[1] as int) >= frame:
				parse = true
				sequences.append(key)
		elif key == str(frame):
			parse = true
			sequences.append(key)
	if parse:
		var expression := Expression.new()
		for sqnc: String in sequences:
			var primary_key: Array = sequence[sqnc]
			for key: Dictionary in primary_key:
				if key.has("end_turn"):
					plr_turn()
				elif key.has("player_mode"):
					change_player_mode.emit(key["player_mode"])
				elif key.has("box_transform"):
					if key.has("x"): if key["x"] is float: box_target_pos.x = key["x"]
					else:
						expression.parse(key["x"]); box_target_pos.x = await expression.execute()
						if expression.has_execute_failed(): printerr("".join(["failed to parse x position for box transformation, expression was ",key["x"]]))
					if key.has("y"): if key["y"] is float: box_target_pos.y = key["y"]
					else:
						expression.parse(key["y"]); box_target_pos.y = await expression.execute()
						if expression.has_execute_failed(): printerr("".join(["failed to parse y position for box transformation, expression was ",key["y"]]))
					if key.has("r"): if key["r"] is float: box_target_rot = key["r"]
					else:
						expression.parse(key["r"]); box_target_rot = await expression.execute()
						if expression.has_execute_failed(): printerr("".join(["failed to parse rotation for box transformation, expression was ",key["r"]]))
					if key.has("size_top"): if key["size_top"] is float: box_target_size.x = key["size_top"]
					else:
						expression.parse(key["size_top"]); box_target_size.x = await expression.execute()
						if expression.has_execute_failed(): printerr("".join(["failed to parse top size for box transformation, expression was ",key["size_top"]]))
					if key.has("size_bottom"): if key["size_bottom"] is float: box_target_size.y = key["size_bottom"]
					else:
						expression.parse(key["size_bottom"]); box_target_size.y = await expression.execute()
						if expression.has_execute_failed(): printerr("".join(["failed to parse bottom size for box transformation, expression was ",key["size_bottom"]]))
					if key.has("size_left"): if key["size_left"] is float: box_target_size.z = key["size_left"]
					else:
						expression.parse(key["size_left"]); box_target_size.z = await expression.execute()
						if expression.has_execute_failed(): printerr("".join(["failed to parse right size for box transformation, expression was ",key["size_left"]]))
					if key.has("size_right"): if key["size_right"] is float: box_target_size.w = key["size_right"]
					else:
						expression.parse(key["size_right"]); box_target_size.w = await expression.execute()
						if expression.has_execute_failed(): printerr("".join(["failed to parse left size for box transformation, expression was ",key["size_right"]]))
					if key.has("speed"): if key["speed"] is float:
						box_speed = key["speed"]
					if key.has("log"): if key["log"] is bool:
						box_logarithm = key["log"]
					if key.has("now"): if key["now"] is bool:
						transform_box(box_target_pos,box_target_size.x,box_target_size.y,box_target_size.z,box_target_size.w,box_target_rot)
				else:
					var attack_name = key["attack"]
					var attack_x := 0.0; var attack_y := 0.0; var attack_rot := 0.0;
					if key["x"] is String:
						expression.parse(key["x"],["f"]); attack_x = await expression.execute([frame])
						if expression.has_execute_failed(): printerr("".join(["failed to parse x position for attack ",attack_name,", expression was ",key["x"]]))
					else: attack_x = key["x"]
					if key["y"] is String:
						expression.parse(key["y"],["f"]); attack_y = await expression.execute([frame])
						if expression.has_execute_failed(): printerr("".join(["failed to parse y position for attack ",attack_name,", expression was ",key["y"]]))
					else: attack_y = key["y"]
					if key["r"] is String:
						expression.parse(key["r"],["f"]); attack_rot = await expression.execute([frame])
						if expression.has_execute_failed(): printerr("".join(["failed to parse rotation for attack ",attack_name,", expression was ",key["r"]]))
					else: attack_rot = key["r"]
					spawn_attack(attack_name,Vector2(attack_x,attack_y),attack_rot)

func _on_type_character_timer_timeout() -> void:
	if $Control/TopBox/Margin/Text.visible_characters < battle_log.length():
		$Control/TopBox/Margin/Text.visible_characters += 1

func add_to_battle_log(adding_text,effects = {}) -> void:
	battle_log = "".join([battle_log,adding_text])
	if effects.has("text_speed"):
		$TypeCharacterTimer.wait_time = effects["text_speed"]
	$Control/TopBox/Margin/Text.text = battle_log

func show_action_buttons() -> void:
	$Control/Actions/Attack.visible = true
	$Control/Actions/Skill.visible = true
	$Control/Actions/Item.visible = true
	$Control/Actions/Guard.visible = true
	
func hide_action_buttons() -> void:
	$Control/Actions/Attack.visible = false
	$Control/Actions/Skill.visible = false
	$Control/Actions/Item.visible = false
	$Control/Actions/Guard.visible = false

func _on_attack_pressed() -> void:
	hide_action_buttons()

func _on_skill_pressed() -> void:
	hide_action_buttons()

func _on_item_pressed() -> void:
	hide_action_buttons()

func _on_guard_pressed() -> void:
	hide_action_buttons()

func _on_main_update_theme_all(theme: Variant) -> void:
	update_theme(theme)

func _on_turn_control(start: Variant) -> void:
	if start:
		box_target_pos = Vector2(240,440)
		box_target_size = Vector4(64,64,64,64)
		box_logarithm = true
		box_speed = .1
	else:
		box_target_pos = Vector2(240,180)
		box_target_size = Vector4(64,64,64,64)
		box_logarithm = true
		box_speed = .1
		frame = -60
