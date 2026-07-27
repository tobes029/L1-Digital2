extends CharacterBody2D

signal health_changed(current_health)
signal player_died

@export var speed: float = 200.0
@export var max_health: int = 100

@onready var health: int = max_health
@onready var axe_hitbox_shape = $AxeHitbox/CollisionShape2D

# UI References
@onready var health_bar: ProgressBar = $HUD/PlayerHealthBar 
@onready var portrait: TextureRect = $HUD/Portrait

# Load your face sprites here (change paths to match your actual files!)
var face_full = preload("res://sprites/full_health.png")
var face_half = preload("res://sprites/half_health.png")
var face_low = preload("res://sprites/low_health.png")

func _ready() -> void:
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	
	# sets initial portrait
	_update_portrait()

func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()
	
	if Input.is_action_just_pressed("ui_accept"):
		attack()

func attack() -> void:
	print("Player swings the axe!")
	if axe_hitbox_shape:
		axe_hitbox_shape.disabled = false
		await get_tree().create_timer(0.2).timeout
		axe_hitbox_shape.disabled = true

func take_damage(amount: int) -> void:
	health -= amount
	print("Player took damage! Health left: ", health)
	
	if health_bar:
		health_bar.value = health
		
	_update_portrait()
	
	if health <= 0:
		die()

# portrait updater logic

func _update_portrait() -> void:
	if not portrait:
		return
		
	# Calculate health percentage (0.0 to 1.0)
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
	queue_free()
