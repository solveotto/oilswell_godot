extends Control

@onready var highscores = GameManager.load_highscores()


# Labels
@onready var congratualtions = $Congratualtions
@onready var your_final_score_is_in_the = $"Your final score is in the"
@onready var top_ten = $"Top ten"
@onready var please_enter_your_initials = $"Please enter your initials"
@onready var rank = $Rank
@onready var score = $Score
@onready var initials_label = $Initials
@onready var initials_container = $MarginContainer/VBoxContainer
@onready var margin_container = $MarginContainer
@onready var continue_label = $continue

const FONT_SIZE = 22
const LINE_SPACING = -4
const c64_font = preload("res://assests/Commodore Pixelized v1.2.ttf")


func _ready():
	# Reset highscore
	#clear_highscore_file()
	_display_highscore()
	_focus_input_if_needed()
	print(GameManager.new_highscore_index, GameManager.new_highscore)
	pass


func _input(event):
	if event.is_action_pressed("stop_reverse") or event.is_action_pressed("quit"):
		get_tree().change_scene_to_packed(GameManager.MAIN)
		continue_label.hide()



func _display_highscore():
	var score_data = []
	
	initials_container.set("theme_override_constants/separation", LINE_SPACING)
	initials_container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	margin_container.position = Vector2(496, 260)
	rank.position = Vector2(244, 260)
	score.position = Vector2(304, 260)
	
	
	# Display if highscore not reached
	if GameManager.new_highscore == false:
		congratualtions.text = "HIGH SCORES"
		congratualtions.position = Vector2(0,180)
		
		continue_label.show()
		
		your_final_score_is_in_the.hide()
		top_ten.hide()
		please_enter_your_initials.hide()
		

	

	for i in range(highscores.size()):
		score_data.append(str(highscores[i]["score"]))
		var concatenated_score = "\n".join(score_data)
		score.text = concatenated_score
		
		if i == GameManager.new_highscore_index and GameManager.new_highscore:
			var focus_style = StyleBoxFlat.new()
			focus_style.bg_color = Color(0, 0, 0)  # Dark blue background
			focus_style.border_color = Color(0, 0, 0)  # Yellow border
			focus_style.border_width_top = 0
			focus_style.border_width_bottom = 0

			
			var line_edit = LineEdit.new()
			#line_edit.text = highscores[i]["initials"]
			line_edit.max_length = 3  # Limit to 3 characters
			line_edit.focus_mode = Control.FOCUS_CLICK
			line_edit.caret_blink = true
			line_edit.caret_blink_interval = 0.2
			line_edit.add_theme_stylebox_override("focus", focus_style)
			line_edit.add_theme_color_override("font_color", Color("c24cb0"))
			line_edit.add_theme_font_size_override("font_size", 20)

			# Connect Enter key event
			line_edit.text_changed.connect(_on_text_changed.bind(line_edit))
			line_edit.text_submitted.connect(_on_text_submitted.bind(i))

			initials_container.add_child(line_edit)
		else:
			var label = Label.new()
			label.text = highscores[i]["initials"]
			label.add_theme_font_size_override("font_size", FONT_SIZE)
			label.add_theme_constant_override("LINE_SPACING", LINE_SPACING)
			label.add_theme_color_override("font_color", Color("c24cb0"))
			
			initials_container.add_child(label)
			
	


### 🔹 Focus the Editable Input (If Needed) ###
func _focus_input_if_needed():
	if GameManager.new_highscore_index != -1:
		var line_edit = initials_container.get_child(GameManager.new_highscore_index) as LineEdit
		if line_edit:
			line_edit.grab_focus()

### 🔹 Update Initials in Real-Time ###
func _on_text_changed(new_text: String, index: int):
	highscores[index]["initials"] = new_text.to_upper()  # Convert to uppercase

	

### 🔹 Handle Enter Key Press ###
func _on_text_submitted(new_text: String, index: int):
	highscores[index]["initials"] = new_text.to_upper()
	print("Finalized initials:", highscores)
	GameManager.save_highscores(highscores)  # Save the updated highscores
	GameManager.new_highscore = false
	get_tree().reload_current_scene()
	
