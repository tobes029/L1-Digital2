extends Area2D
class_name Hurtbox

# Reference to the main CharacterBody2D script that owns this hurtbox
@onready var entity = get_parent()

func _ready() -> void:
	# Connect the signal that detects when another Area2D enters this one
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	# Check if the area that entered us is a Hitbox
	if area is Hitbox:
		# If the entity has a take_damage function, call it
		if entity.has_method("take_damage"):
			entity.take_damage(area.damage)
