extends Area2D
class_name Hurtbox

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		# Get the node this Hurtbox belongs to
		var my_owner = owner if owner else get_parent()
		print("Hurtbox on '", my_owner.name, "' detected a strike from '", area.name, "'!")
		
		# Look for take_damage on the direct parent or owner
		var entity = get_parent()
		if entity and entity.has_method("take_damage"):
			var dmg = area.damage if "damage" in area else 10
			print("Dealing ", dmg, " damage to: ", entity.name)
			entity.take_damage(dmg)
		else:
			print("ERROR: ", get_parent().name, " does not have take_damage()!")
