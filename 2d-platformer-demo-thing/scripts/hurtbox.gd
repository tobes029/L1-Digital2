extends Area2D
class_name Hurtbox

func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		# Target the immediate character parent, NOT the scene root (level1)
		var target = get_parent()
		
		if target and target.has_method("take_damage"):
			var dmg = area.damage if "damage" in area else 10
			target.take_damage(dmg)
			print("SUCCESS: Dealt ", dmg, " damage to ", target.name)
		else:
			print("FAIL: ", target.name if target else "Null", " does not have take_damage()!")
