extends CanvasLayer
# souta
@onready var start: Button = $Control/start

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")
