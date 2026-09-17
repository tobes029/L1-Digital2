extends Area2D

# The amount of health this potion restores
@export var heal_amount: int = 25

func _ready() -> void:
	# Connect the body_entered signal so it triggers when the player walks over it
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the node that touched the potion is the player
	if body.has_method("heal"):
		body.heal(heal_amount)
		queue_free() # Remove the potion from the game world
	elif "health" in body and "max_health" in body:
		# Alternative check: directly adjust health if no heal() method exists
		if body.health < body.max_health:
			body.health = min(body.health + heal_amount, body.max_health)
			if body.has_method("take_damage"):
				# Call take_damage with 0 to trigger UI and portrait updates
				body.take_damage(0)
			queue_free()
