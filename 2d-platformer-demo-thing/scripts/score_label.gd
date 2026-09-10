extends Label

func _ready() -> void:
	# Force the label to sit on top of other canvas elements
	z_index = 10
	
	# Connect to the ScoreManager signal using the global singleton directly
	if Engine.has_singleton("ScoreManager") or ScoreManager:
		ScoreManager.score_changed.connect(_on_score_changed)
		# Set initial score text right away
		text = "Score: " + str(ScoreManager.current_score)
		print("ScoreLabel successfully connected to ScoreManager! Initial score: ", ScoreManager.current_score)
	else:
		print("Error: ScoreLabel could not find ScoreManager!")

func _on_score_changed(new_score: int) -> void:
	# Update the text on screen
	text = "Score: " + str(new_score)
	print("ScoreLabel UI updated on screen to: ", text)
