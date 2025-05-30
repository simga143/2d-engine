extends Node

signal battle_start(battle_id)
signal dialogue_start(dialogue_id)
signal update_theme_all(theme)
signal transition_completed(in_out)

var pos = Vector2.ZERO
var scene = 0
var theme = 0
var transitioning = false
var transition_pct = 1.0
var transition_in = false
var next_scene = 0
var next_battle = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Battle.process_mode = Node.PROCESS_MODE_DISABLED
	$Battle.visible = false
	$overworld_ui/canvas.visible = false
	update_theme_all.emit(theme)
	
func update_theme(theme) -> void:
	$overworld_ui/canvas/dialogue/picture/texture.region_rect = Rect2(96 * (theme % 2),96 * floor(theme/2),96,96)
	$overworld_ui/canvas/dialogue/text_box/texture.region_rect = Rect2(96 * (theme % 2),96 * floor(theme/2),96,96)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if transitioning:
		$transitionContainer/transition.get_material().set_shader_parameter("dissolve_value",transition_pct)
		if transition_in:
			transition_pct -= 0.01
			if transition_pct <= 0:
				transitioning = false
				transition_pct = 0
				transition_completed.emit(true)
		else:
			transition_pct += 0.01
			if transition_pct >= 1:
				transitioning = false
				transition_pct = 1
				transition_completed.emit(false)
				
	# scene switching functionality for testing purposes only
	if Input.is_action_just_pressed("switch"):
		if scene == 0:
			scene = 1
			go_to_battle()
		elif scene == 1:
			scene = 0
			go_to_overworld()
			
	if Input.is_action_just_pressed("accept"):
		$Overworld/Player/Interaction/InteractCollision.debug_color = Color.hex(0xfe00336b)
		var list = $Overworld/Player/Interaction.get_overlapping_areas()
		if list.size() > 0:
			var meta_list = list[0].get_meta_list()
			if meta_list.has("ID"):
				var interactionID = meta_list.find("ID")
				handle_interaction(interactionID)
	
	if Input.is_action_just_released("accept"):
		$Overworld/Player/Interaction/InteractCollision.debug_color = Color.hex(0x00a53e6b)
		
	if Input.is_action_just_pressed("update_theme"):
		theme = (theme + 1) % 4
		update_theme_all.emit(theme)
			
func go_to_room(roomID: String, entryID = "") -> void:
	var room = $Overworld.find_child(roomID)
	var shape = room.find_child("Area").shape
	$Overworld/Player/Camera.limit_left = shape
	pass
			
func go_to_overworld() -> void:
	$transitionContainer/transition.get_material().set_shader_parameter("dissolve_value",0.0)
	transitioning = true
	transition_pct = 0.0
	transition_in = false
	next_scene = 0
	
func actually_go_to_overworld() -> void:
	$Overworld.process_mode = Node.PROCESS_MODE_ALWAYS
	$Overworld.visible = true
	$Overworld/Player/Camera.enabled = true
	$Battle.process_mode = Node.PROCESS_MODE_DISABLED
	$Battle.visible = false
	$Battle/Camera.enabled = false

func go_to_battle(battle_id = 0) -> void:
	$transitionContainer/transition.get_material().set_shader_parameter("dissolve_value",0.0)
	transitioning = true
	transition_pct = 0.0
	transition_in = false
	next_scene = 1
	next_battle = battle_id
	
func actually_go_to_battle(battle_id = 0) -> void:
	$Overworld.process_mode = Node.PROCESS_MODE_DISABLED
	$Overworld.visible = false
	$Overworld/Player/Camera.enabled = false
	$Battle.process_mode = Node.PROCESS_MODE_ALWAYS
	$Battle.visible = true
	$Battle/Camera.enabled = true
	battle_start.emit(battle_id)

func handle_interaction(interactionID = 0) -> void:
	$overworld_ui/canvas.visible = true
	dialogue_start.emit(interactionID)

func _on_update_theme_all(theme: Variant) -> void:
	update_theme(theme)

func _on_transition_completed(in_out: Variant) -> void:
	if !in_out:
		$transitionContainer/transition.get_material().set_shader_parameter("dissolve_value",1.0)
		transitioning = true
		transition_pct = 1.0
		transition_in = true
		if next_scene == 0:
			actually_go_to_overworld()
		else:
			actually_go_to_battle(next_battle)
