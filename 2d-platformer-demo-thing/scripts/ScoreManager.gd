extends Node

# Signal emitted whenever the score changes
signal score_changed(new_score)

# Primary score variable
var score: int = 0:
	set(value):
		score = value
		score_changed.emit(score)

# Property alias so code looking for 'current_score' works without errors
var current_score: int:
	get:
		return score
	set(value):
		score = value

# Function to increase score
func add_score(amount: int) -> void:
	score += amount

# Function to reset score on player death
func reset_score() -> void:
	score = 0
