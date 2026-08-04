extends CanvasLayer

@onready var respawn_button: Button = $Control/RespawnButton


func _on_respawn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")
