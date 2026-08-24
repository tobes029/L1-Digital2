extends CharacterBody2D

signal health_changed(current_health)
signal player_died

@export var speed: float = 200.0
@export var max_health: int = 100
@export var death_screen_scene: PackedScene

@onready var health: int = max_health
@onready var axe_hitbox_shape = $Pivot/AxeHitbox/CollisionShape2D if has_node("Pivot/AxeHitbox/CollisionShape2D") else null
@onready var axe_hitbox: Area2D = $Pivot/AxeHitbox if has_node("Pivot/AxeHitbox") else null
@onready var hurtbox: Area2D = $Hurtbox if has_node("Hurtbox") else null
@onready var pivot: Node2D = $Pivot if has_node("Pivot") else null
@onready var sprite: Sprite2D = $Pivot/Sprite2D if has_node("Pivot/Sprite2D") else null

# directional Textures
var tex_up = preload("res://sprites/playerback.png")
var tex_down = preload("res://sprites/playerfront.png")
var tex_left = preload("res://sprites/playerleft.png")
var tex_right = preload("res://sprites/playerright.png")

# ui refs
var health_bar: ProgressBar = null
var portrait: TextureRect = null

# healthbar sprites
var face_full = preload("res://sprites/full_health.png")
var face_half = preload("res://sprites/half_health.png")
var face_low = preload("res://sprites/low_health.png")

func _ready() -> void:
	get_tree().debug_collisions_hint = true
	
	if axe_hitbox_shape:
		print("FOUND AXE SHAPE SUCCESSFULLY!")
		axe_hitbox_shape.disabled = true
	else:
		print("ERROR: Could not find node path '$Pivot/AxeHitbox/CollisionShape2D'!")

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
		print("Player Hurtbox successfully connected!")

func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()
	
	# directional sprite and weapon pivots
	if direction != Vector2.ZERO:
		update_sprite_direction(direction)

	if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("ui_accept"):
		attack()

func update_sprite_direction(dir: Vector2) -> void:
	if not sprite:
		return

	# Prioritize horizontal or vertical movement
	if abs(dir.x) > abs(dir.y):
		if pivot: pivot.z_index = 0
		if dir.x > 0:
			sprite.texture = tex_right
			sprite.flip_h = false # Keep sprite original
			if pivot: pivot.scale.x = 1 # default axe pos
		else:
			sprite.texture = tex_left
			sprite.flip_h = true # counter flippage
			if pivot: pivot.scale.x = -1 # mirrors weapon & hitbox across the center line
	else:
		if pivot: pivot.scale.x = 1 # reset pivot scale for vertical movement
		sprite.flip_h = false
		
		if dir.y > 0:
			sprite.texture = tex_down
			if pivot: pivot.z_index = 1 # Axe in FRONT when moving down
		else:
			sprite.texture = tex_up
			if pivot: pivot.z_index = -1 # Axe BEHIND when moving up

func attack() -> void:
	print("Player swings the axe!")
	if axe_hitbox_shape:
		axe_hitbox_shape.disabled = false
		await get_tree().create_timer(0.2).timeout
		axe_hitbox_shape.disabled = true

func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("PLAYER HURTBOX TOUCHED BY: ", area.name)
	if area is Hitbox or "damage" in area:
		var dmg = area.damage if "damage" in area else 10
		take_damage(dmg)

func take_damage(amount: int) -> void:
	health -= amount
	print("Player took damage! Health left: ", health)
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
	print("Player died! Game Over.")
	player_died.emit()
	get_tree().change_scene_to_file("res://scenes/death_screen.tscn")
