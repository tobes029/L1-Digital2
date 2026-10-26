extends CharacterBody2D

signal health_changed(current_health)
signal player_died

@export var speed: float = 600.0
@export var max_health: int = 100
@export var death_screen_scene: PackedScene

# --- AXE POSITION SLIDERS ---
@export_range(0.0, 50.0, 1.0) var axe_side_distance: float = 20.0
@export_range(-50.0, 50.0, 1.0) var axe_hand_y_offset: float = -16.0

@onready var health: int = max_health
@onready var axe_hitbox_shape = $Pivot/AxeHitbox/CollisionShape2D if has_node("Pivot/AxeHitbox/CollisionShape2D") else null
@onready var axe_hitbox: Area2D = $Pivot/AxeHitbox if has_node("Pivot/AxeHitbox") else null
@onready var axe_flash: ColorRect = $Pivot/AxeHitbox/HitboxFlash if has_node("Pivot/AxeHitbox/HitboxFlash") else null
@onready var hurtbox: Area2D = $Hurtbox if has_node("Hurtbox") else null
@onready var pivot: Node2D = $Pivot if has_node("Pivot") else null

# Node reference for Sprite2D
@onready var sprite: Sprite2D = $Pivot/Sprite2D if has_node("Pivot/Sprite2D") else null

# Preloaded directional textures
@export var tex_down: Texture2D = preload("res://sprites/playerfront.png")
@export var tex_up: Texture2D = preload("res://sprites/playerback.png")
@export var tex_left: Texture2D = preload("res://sprites/playerleft.png")
@export var tex_right: Texture2D = preload("res://sprites/playerright.png")

# UI References
var health_bar: ProgressBar = null
var portrait: TextureRect = null
@onready var message_label: Label = $HUD/MessageLabel if has_node("HUD/MessageLabel") else null

# Map UI References
var map_button: Button = null
@onready var map_overlay: Control = $HUD/MapOverlay if has_node("HUD/MapOverlay") else null

# Face sprites
var face_full = preload("res://sprites/full_health.png")
var face_half = preload("res://sprites/half_health.png")
var face_low = preload("res://sprites/low_health.png")

# State variables
var last_direction: Vector2 = Vector2.DOWN
var is_attacking: bool = false

func _ready() -> void:
	z_index = 2

	# Restore saved position from Global Autoload if returning from map
	if get_node_or_null("/root/Global") and Global.position_saved:
		global_position = Global.last_player_position
		print("Restored player position to: ", global_position)

	if axe_hitbox_shape:
		axe_hitbox_shape.disabled = true

	if axe_flash:
		axe_flash.visible = false

	if has_node("HUD/PlayerHealthBar"):
		health_bar = $HUD/PlayerHealthBar
		
	if has_node("HUD/Portrait"):
		portrait = $HUD/Portrait

	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	
	_update_portrait()
	
	if hurtbox:
		hurtbox.area_entered.connect(_on_hurtbox_area_entered)

	# --- DYNAMIC MAP BUTTON FINDER ---
	map_button = _find_map_button()
	if map_button:
		print("MapButton found! Signal connected successfully.")
		map_button.pressed.connect(_on_map_button_pressed)
	else:
		print("WARNING: MapButton could not be found under HUD.")

	if map_overlay:
		map_overlay.visible = false

# Helper function to find MapButton regardless of nesting
func _find_map_button() -> Button:
	if has_node("HUD/MapButton"):
		return $HUD/MapButton as Button
	elif has_node("HUD/CanvasLayer/MapButton"):
		return $HUD/CanvasLayer/MapButton as Button
	elif has_node("HUD/Control/MapButton"):
		return $HUD/Control/MapButton as Button
	
	# Fallback recursive search inside HUD
	if has_node("HUD"):
		var hud_node = $HUD
		for child in hud_node.get_children():
			if child.name == "MapButton" and child is Button:
				return child as Button
			for grandchild in child.get_children():
				if grandchild.name == "MapButton" and grandchild is Button:
					return grandchild as Button
	return null

func _physics_process(_delta: float) -> void:
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()
	
	if direction != Vector2.ZERO:
		last_direction = direction
		update_direction_and_axe(direction)
	else:
		update_direction_and_axe(last_direction)

	if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("ui_accept"):
		attack()

func _on_map_button_pressed() -> void:
	# Save current position into Global Autoload before leaving scene
	if get_node_or_null("/root/Global"):
		Global.last_player_position = global_position
		Global.position_saved = true
		print("Saved player position to Global: ", global_position)

	print("MapButton pressed! Searching for map scene file...")

	var possible_paths = [
		"res://scenes/map.tscn",
		"res://scenes/Map.tscn",
		"res://map.tscn",
		"res://Map.tscn",
		"res://Scenes/map.tscn",
		"res://Scenes/Map.tscn"
	]

	var valid_path = ""

	for path in possible_paths:
		if FileAccess.file_exists(path):
			valid_path = path
			break

	if valid_path != "":
		print("SUCCESS: Found map scene at '", valid_path, "'! Changing scene now...")
		var error_code = get_tree().change_scene_to_file(valid_path)
		if error_code != OK:
			print("ERROR: Could not change scene. Godot Error Code: ", error_code)
	else:
		print("ERROR: Could not find map scene in any common locations!")

func update_direction_and_axe(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			if sprite and tex_right:
				sprite.texture = tex_right
			if axe_hitbox:
				axe_hitbox.scale = Vector2.ONE
				axe_hitbox.position = Vector2(axe_side_distance, axe_hand_y_offset)
				axe_hitbox.z_index = 0
		else:
			if sprite and tex_left:
				sprite.texture = tex_left
			if axe_hitbox:
				axe_hitbox.scale = Vector2(-1, 1)
				axe_hitbox.position = Vector2(-axe_side_distance, axe_hand_y_offset)
				axe_hitbox.z_index = 0
	else:
		if dir.y > 0:
			if sprite and tex_down:
				sprite.texture = tex_down
			if axe_hitbox:
				axe_hitbox.scale = Vector2.ONE
				axe_hitbox.position = Vector2(0, axe_side_distance)
				axe_hitbox.z_index = 1
		else:
			if sprite and tex_up:
				sprite.texture = tex_up
			if axe_hitbox:
				axe_hitbox.scale = Vector2.ONE
				axe_hitbox.position = Vector2(0, -axe_side_distance)
				axe_hitbox.z_index = -1

func attack() -> void:
	if is_attacking:
		return

	is_attacking = true

	if axe_hitbox_shape:
		axe_hitbox_shape.disabled = false

	var temp_rect: ColorRect = null
	if axe_flash:
		axe_flash.visible = true
	elif axe_hitbox:
		temp_rect = ColorRect.new()
		temp_rect.size = Vector2(32, 50)
		temp_rect.position = Vector2(23, -25)
		temp_rect.color = Color(1, 0, 0, 0.5)
		axe_hitbox.add_child(temp_rect)

	await get_tree().create_timer(0.2).timeout

	if axe_hitbox_shape:
		axe_hitbox_shape.disabled = true

	if axe_flash:
		axe_flash.visible = false
	elif temp_rect:
		temp_rect.queue_free()

	is_attacking = false

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area is Hitbox or "damage" in area:
		var dmg = area.damage if "damage" in area else 10
		take_damage(dmg)

func take_damage(amount: int) -> void:
	health -= amount
	health_changed.emit(health)
	
	if health_bar:
		health_bar.value = health
		
	_update_portrait()
	
	if health <= 0:
		die()

func _update_portrait() -> void:
	if not portrait:
		return
		
	var health_percent: float = float(health) / float(max_health)
	
	if health_percent > 0.6:
		portrait.texture = face_full
	elif health_percent > 0.30:
		portrait.texture = face_half
	else:
		portrait.texture = face_low

func die() -> void:
	if get_tree().root.has_node("ScoreManager"):
		get_tree().root.get_node("ScoreManager").reset_score()

	player_died.emit()
	get_tree().change_scene_to_file("res://scenes/death_screen.tscn")
	
func heal(amount: int) -> void:
	health = min(health + amount, max_health)
	
	if health_bar:
		health_bar.value = health
		
	_update_portrait()

func boost_speed(amount: float, max_speed_cap: float = 10000000000000000000.0) -> void:
	speed = min(speed + amount, max_speed_cap)

func show_message(text: String, duration: float = 4.0) -> void:
	var label: Label = null
	if has_node("HUD/MessageLabel"):
		label = $HUD/MessageLabel
	else:
		var canvas = CanvasLayer.new()
		label = Label.new()
		label.name = "TempMessageLabel"
		
		label.anchors_preset = Control.PRESET_CENTER_TOP
		label.position = Vector2(-100, 50)
		label.grow_horizontal = Control.GROW_DIRECTION_BOTH
		
		canvas.add_child(label)
		add_child(canvas)

	label.text = text
	label.visible = true

	await get_tree().create_timer(duration).timeout

	if label and is_instance_valid(label):
		if label.name == "TempMessageLabel":
			label.get_parent().queue_free()
		else:
			label.text = ""
			label.visible = false
