extends Area2D

# The number of points required to open this door (editable in the Inspector)
@export var required_score: int = 13

# The path to the scene file to load when unlocked (editable in the Inspector)
@export_file("*.tscn") var target_scene: String = "res://scenes/end.tscn"

func _ready() -> void:
	# Automatically connect the body_entered signal when the door initializes
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the colliding object is the player character
	if body.is_in_group("player") or body.name == "Player":
		
		var current_score: int = _get_current_score()

		# Check if the player has collected enough points
		if current_score >= required_score:
			print("Door unlocked! Changing scene to: ", target_scene)
			
			# Reset saved position in Globle so player starts at default spawn of new level
			if get_node_or_null("/root/Globle") and "position_saved" in ScoreManager:
				ScoreManager.position_saved = false
			elif get_node_or_null("/root/Global") and "position_saved" in Global:
				Global.position_saved = false
			
			# Load the new level scene safely
			if FileAccess.file_exists(target_scene):
				get_tree().change_scene_to_file(target_scene)
			else:
				print("ERROR: Target scene file not found at path: ", target_scene)
		else:
			# Player doesn't have enough points — notify them via HUD message
			var points_needed: int = required_score - current_score
			print("Door locked! You need ", points_needed, " more points.")
			
			if body.has_method("show_message"):
				body.show_message("Locked! Need " + str(required_score) + " points (" + str(points_needed) + " more)", 3.0)

# Helper function to dynamically check your ScoreManager
func _get_current_score() -> int:
	# Check for ScoreManager Autoload
	if get_node_or_null("/root/ScoreManager"):
		var sm = get_node("/root/ScoreManager")
		if "score" in sm:
			return sm.score
		elif sm.has_method("get_score"):
			return sm.get_score()
			
	# Check inside Globle Autoload as fallback
	if get_node_or_null("/root/Globle") and "score" in ScoreManager:
		return ScoreManager.score
		
	return 0
