extends Area2D

# This allows you to pick the next level file right from the Inspector!
@export_file("*.tscn") var next_scene: String

func _on_body_entered(body: Node2D) -> void:
	# Check if the object entering the portal is actually the player
	# (Change "Player" to match your player node's name or class)
	if body.name == "Player":
		change_level()

func change_level() -> void:
	if next_scene != "":
		# This line tells Godot to wipe the current level and load the new one
		get_tree().change_scene_to_file(next_scene)
	else:
		print("Warning: No next scene assigned to this portal!")
