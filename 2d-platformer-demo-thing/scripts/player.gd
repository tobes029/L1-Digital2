extends CharacterBody2D

signal health_changed(current_health)
signal player_died

@export var speed: float = 200.0
@export var max_health: int = 100


@onready var health: int = max_health
@onready var axe_hitbox_shape = $Pivot/AxeHitbox/CollisionShape2D if has_node("Pivot/AxeHitbox/CollisionShape2D") else null
@onready var hurtbox: Area2D = $Hurtbox if has_node("Hurtbox") else null
@onready var pivot: Node2D = $Pivot if has_node("Pivot") else null
@export var death_screen_scene: PackedScene

# UI References
var health_bar: ProgressBar = null
var portrait: TextureRect = null


# Face sprites
#var death_screen_scene = preload("res://scenes/respawn.gd")
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
	
	# --- FLIP EVERYTHING (SPRITE + WEAPON + HITBOX) TOGETHER ---
	if pivot:
		if direction.x < 0:
			pivot.scale.x = -1 # Mirrors everything inside Pivot to the LEFT
		elif direction.x > 0:
			pivot.scale.x = 1  # Mirrors everything inside Pivot to the RIGHT

	if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("ui_accept"):
		attack()

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
