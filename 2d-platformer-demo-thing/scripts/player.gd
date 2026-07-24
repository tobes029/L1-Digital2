extends CharacterBody2D

# Signals to notify UI or game managers when health changes
signal health_changed(current_health)
signal player_died

@export var speed: float = 200.0
@export var max_health: int = 100

@onready var health: int = max_health
@onready var axe_hitbox_shape = $AxeHitbox/CollisionShape2D

# Reference to the Player Health Bar in the HUD
@export var health_bar: ProgressBar

func _ready() -> void:
	# If health_bar was assigned in Inspector, set initial values
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health

func _physics_process(_delta: float) -> void:
	# 1. Top-Down Movement
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()
	
	# 2. Attack Input
	if Input.is_action_just_pressed("ui_accept"):
		attack()

func attack() -> void:
	print("Player swings the axe!")
	if axe_hitbox_shape:
		axe_hitbox_shape.disabled = false
		await get_tree().create_timer(0.2).timeout
		axe_hitbox_shape.disabled = true

# --- TAKING DAMAGE LOGIC ---

func take_damage(amount: int) -> void:
	health -= amount
	print("Player took damage! Health left: ", health)
	
	# Emit health change signal
	health_changed.emit(health)
	
	# Update health bar UI
	if health_bar:
		health_bar.value = health
	
	if health <= 0:
		die()

func die() -> void:
	print("Player died! Game Over.")
	player_died.emit()
	queue_free() # Removes player from the scene
