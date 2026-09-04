extends Node

# Signal emitted whenever the score changes so UI elements can update automatically
signal score_changed(new_score: int)

# The player's current total score
var current_score: int = 0

# Adds points to the total score and emits a signal to update UI
func add_score(amount: int) -> void:
	current_score += amount
	score_changed.emit(current_score)
	print("Score updated: ", current_score)

# Resets score back to zero (useful when restarting or dying)
func reset_score() -> void:
	current_score = 0
	score_changed.emit(current_score)
