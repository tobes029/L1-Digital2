extends Area2D

# Configurable speed increase amount
@export var speed_increase: float = 600.0

func _ready() -> void:
	# Connect the collision signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	print("Item touched by: ", body.name)
	
	# Primary Check: Call boost_speed if it exists on Player
	if body.has_method("boost_speed"):
		print("Player speed before boost: ", body.speed)
		body.boost_speed(speed_increase)
		print("Player speed after boost: ", body.speed)
		
		# Display UI message if player has show_message method
		if body.has_method("show_message"):
			body.show_message("Speed Boosted!")
			
		queue_free()
		
	# Fallback Check: Direct property modification
	elif "speed" in body:
		print("Player speed before direct boost: ", body.speed)
		body.speed += speed_increase
		print("Player speed after direct boost: ", body.speed)
		
		# Display UI message if player has show_message method
		if body.has_method("show_message"):
			body.show_message("Speed Boosted!")
			
		queue_free()
	else:
		print("Touched node has no 'boost_speed' method or 'speed' variable!")
