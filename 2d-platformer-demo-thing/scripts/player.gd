extends CharacterBody2D

signal health_changed(current_health)
signal player_died

@export var speed: float = 200.0
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

# Face sprites
var face_full = preload("res://sprites/full_health.png")
var face_half = preload("res://sprites/half_health.png")
var face_low = preload("res://sprites/low_health.png")

# State variables
var last_direction: Vector2 = Vector2.DOWN
var is_attacking: bool = false

func _ready() -> void:
	z_index = 2

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

	# Enable hitbox shape
	if axe_hitbox_shape:
		axe_hitbox_shape.disabled = false

	# Show visual indicator
	var temp_rect: ColorRect = null
	if axe_flash:
		axe_flash.visible = true
	elif axe_hitbox:
		# Fallback: create visual shape in code if node isn't found
		temp_rect = ColorRect.new()
		temp_rect.size = Vector2(32, 50)
		temp_rect.position = Vector2(23, -25)
		temp_rect.color = Color(1, 0, 0, 0.5) # Semi-transparent red
		axe_hitbox.add_child(temp_rect)

	await get_tree().create_timer(0.2).timeout

	# Disable hitbox shape
	if axe_hitbox_shape:
		axe_hitbox_shape.disabled = true

	# Hide or remove visual indicator
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
	elif health_percent > 0.25:
		portrait.texture = face_half
	else:
		portrait.texture = face_low

func die() -> void:
	# Safely access ScoreManager Autoload node and reset score to 0
	if get_tree().root.has_node("ScoreManager"):
		get_tree().root.get_node("ScoreManager").reset_score()

	player_died.emit()
	get_tree().change_scene_to_file("res://scenes/death_screen.tscn")
