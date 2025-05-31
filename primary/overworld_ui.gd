extends Control

var dialogue = ""
var dialogueQueue = []
var nextDia = -1
var text_box
@export_file("*.json") var dialogue_file = "res://data/dialogue.json"
var json_as_text = FileAccess.get_file_as_string(dialogue_file)
var dialogue_data = JSON.parse_string(json_as_text)

func _ready() -> void:
	text_box = $canvas/dialogue/text_box/margin/text
	
func _process(delta: float) -> void:
	if text_box.visible_characters > 1 && (Input.is_action_just_pressed("cancel") || Input.is_action_just_pressed("accept")):
		if text_box.visible_characters == dialogue.length():
			close_dialogue()
		text_box.visible_characters = dialogue.length()

func close_dialogue() -> void:
	if nextDia == -1:
		$TypeCharacterTimer.stop()
		$canvas.hide()
	else:
		load_dialogue(nextDia)
		nextDia = -1
		
func load_dialogue(diaID) -> void:
	dialogue = ""
	if dialogue_data.has(diaID):
		var diaDat = dialogue_data[diaID]
		for dia in diaDat:
			add_to_dialogue(dia["text"],dia["effects"])
		text_box.visible_characters = 0
		text_box.text = dialogue
		$TypeCharacterTimer.start()

func _on_type_character_timer_timeout() -> void:
	if text_box.visible_characters < dialogue.length():
		text_box.visible_characters += 1
	elif dialogueQueue.size() > 0:
		var dia = dialogueQueue.pop_at(0)
		var adding_text = dia["text"]
		var effects = dia["effects"]
		dialogue = "".join([dialogue,adding_text])
		if effects.has("text_speed"):
			$TypeCharacterTimer.wait_time = effects["text_speed"]
		if effects.has("portrait"):
			var portraitImg = load("res://art/portraits/"+effects["portrait"]+".png")
			$canvas/dialogue/picture/portrait/portraitImg.texture = portraitImg
		if effects.has("close"):
			close_dialogue()
		if effects.has("nextID"):
			nextDia = effects["nextID"]
		text_box.text = dialogue

func add_to_dialogue(adding_text,effects = {}) -> void:
	dialogueQueue.append({"text":adding_text,"effects":effects})

func _on_main_dialogue_start(dialogue_id: Variant) -> void:
	load_dialogue("test_dialogue")
