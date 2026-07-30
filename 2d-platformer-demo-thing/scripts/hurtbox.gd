extends Area2D
class_name Hurtbox

func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox or "damage" in area:
		# Climb up the node tree to find the character node with take_damage()
		var target: Node = get_parent()
		while target and not target.has_method("take_damage"):
			target = target.get_parent()
		
		if target and target.has_method("take_damage"):
			var dmg = area.damage if "damage" in area else 10
			target.take_damage(dmg)
			print("SUCCESS: Dealt ", dmg, " damage to ", target.name)
		else:
			print("FAIL: Could not find any parent node with take_damage()!")
