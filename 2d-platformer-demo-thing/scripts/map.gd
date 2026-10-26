extends CanvasLayer

# Reference to the button node matching your exact node structure
@onready var close_button: Button = $Control/button if has_node("Control/button") else null

func _ready() -> void:
	# Connect the button's pressed signal when the scene loads
	if close_button:
		close_button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	# Return to your main game level scene
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")
